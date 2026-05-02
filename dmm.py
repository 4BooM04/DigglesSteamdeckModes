#!/usr/bin/env python3
import os
import json
import shutil
import sys
import argparse
import re

def smart_read(file_path):
    # Try utf-8-sig first, then fall back to latin-1
    try:
        with open(file_path, "r", encoding="utf-8-sig") as f:
            return f.read()
    except UnicodeDecodeError:
        with open(file_path, "r", encoding="latin-1") as f:
            return f.read()

def smart_json_load(file_path):
    content = smart_read(file_path)
    # Strip trailing commas
    content = re.sub(r",\s*([\]}])", r"\1", content)
    return json.loads(content)

def resolve_path_ci(root, rel_path):
    """Resolves a relative path case-insensitively within a root directory."""
    current = root
    parts = rel_path.replace("\\", "/").split("/")
    for part in parts:
        if not part: continue
        found = False
        if os.path.isdir(current):
            for item in os.listdir(current):
                if item.lower() == part.lower():
                    current = os.path.join(current, item)
                    found = True
                    break
        if not found:
            # If not found, we just append the part as-is for the rest of the path
            return os.path.join(current, *parts[parts.index(part):])
    return current

class PatchEngine:
    def __init__(self, settings=None):
        self.settings = settings or {}

    def apply_patch(self, original_content, patch_content):
        # Normalize line endings
        original_content = original_content.replace("\r\n", "\n")
        patch_content = patch_content.replace("\r\n", "\n")
        
        # Handle $if:mod: blocks
        def handle_if_mod(match):
            mod_id = match.group(1)
            content = match.group(2)
            # We need to know which mods are active. 
            # This is a bit hacky as the engine doesn't know about ModManager.
            # But we can assume it's in self.settings for now or pass it.
            active_mods = self.settings.get("active_mods", [])
            if mod_id in active_mods:
                return content
            return ""

        patch_content = re.sub(r"\$if:mod:(\w+)\n(.*?)\n\$ifend", handle_if_mod, patch_content, flags=re.DOTALL)

        blocks = re.findall(r"\$start\n(.*?)\n\$end", patch_content, re.DOTALL)
        if not blocks:
            # Try without newline if it's a tight block
            blocks = re.findall(r"\$start(.*?)\$end", patch_content, re.DOTALL)

        result = original_content
        for block in blocks:
            result = self._apply_block(result, block)
        return result

    def _apply_block(self, content, block):
        lines = block.splitlines()
        search_lines = []
        replace_lines = []
        mode = "search"
        
        current_cmd = None
        for line in lines:
            trimmed = line.strip()
            if trimmed.startswith("$replace"):
                current_cmd = "replace"
                mode = "search"
            elif trimmed.startswith("$before"):
                current_cmd = "before"
                mode = "search"
            elif trimmed.startswith("$after"):
                current_cmd = "after"
                mode = "search"
            elif trimmed.startswith("$with") or trimmed.startswith("$put"):
                mode = "replace"
            else:
                if mode == "search":
                    search_lines.append(line)
                else:
                    replace_lines.append(line)
        
        # Fuzzy multi-line match
        content_lines = content.splitlines()
        search_lines_trimmed = [l.strip() for l in search_lines if l.strip()]
        if not search_lines_trimmed:
            return content

        match_start_idx = -1
        match_len = 0
        
        for i in range(len(content_lines)):
            if content_lines[i].strip() == search_lines_trimmed[0]:
                potential_match = True
                k = 0
                for j in range(len(search_lines_trimmed)):
                    while i+k < len(content_lines) and not content_lines[i+k].strip():
                        k += 1 # skip empty lines in content
                    if i+k >= len(content_lines) or content_lines[i+k].strip() != search_lines_trimmed[j]:
                        potential_match = False
                        break
                    k += 1
                if potential_match:
                    match_start_idx = i
                    match_len = k
                    break
        
        if match_start_idx == -1:
            return content

        # Perform the operation
        replace_str = "\n".join(replace_lines)
        for key, val in self.settings.items():
            # Support both $KEY and $print:KEY (used by some mods)
            replace_str = replace_str.replace(f"$print:{key}", str(val))
            replace_str = replace_str.replace(f"${key}", str(val))

        new_content_lines = content_lines[:match_start_idx]
        if current_cmd == "replace":
            new_content_lines.append(replace_str)
        elif current_cmd == "before":
            new_content_lines.append(replace_str)
            new_content_lines.extend(content_lines[match_start_idx:match_start_idx+match_len])
        elif current_cmd == "after":
            new_content_lines.extend(content_lines[match_start_idx:match_start_idx+match_len])
            new_content_lines.append(replace_str)
        
        new_content_lines.extend(content_lines[match_start_idx+match_len:])
        return "\n".join(new_content_lines)

class ModManager:
    def __init__(self, game_root):
        self.game_root = os.path.abspath(game_root)
        self.mods_dir = os.path.join(self.game_root, "Mods")
        self.backup_dir = os.path.join(self.game_root, ".dmm_backup")
        self.config_file = os.path.join(self.game_root, "diggles-mod-manager.json")
        
        if not os.path.exists(self.backup_dir):
            os.makedirs(self.backup_dir)

    def list_mods(self):
        mods = []
        if not os.path.exists(self.mods_dir):
            print(f"Warning: Mods directory not found: {self.mods_dir}")
            return mods
        for item in sorted(os.listdir(self.mods_dir)):
            mod_path = os.path.join(self.mods_dir, item)
            if os.path.isdir(mod_path):
                config_path = os.path.join(mod_path, "config.json")
                if os.path.exists(config_path):
                    try:
                        config = smart_json_load(config_path)
                        name = config.get("name", item)
                        if isinstance(name, dict):
                            name = name.get("en") or name.get("de") or list(name.values())[0]
                        mods.append({
                            "id": item,
                            "name": name,
                            "active": self.is_active(item)
                        })
                    except Exception as e:
                        print(f"Warning: Failed to load config for {item}: {e}")
        return mods

    def is_active(self, mod_id):
        if not os.path.exists(self.config_file):
            return False
        try:
            config = smart_json_load(self.config_file)
            return mod_id in config.get("activeMods", {})
        except:
            return False

    def enable_mod(self, mod_id, update_config=True):
        mod_path = os.path.join(self.mods_dir, mod_id)
        if not os.path.exists(mod_path):
            print(f"Error: Mod {mod_id} not found.")
            return

        # Get active mods for $if:mod
        active_mods = []
        if os.path.exists(self.config_file):
            try:
                config = smart_json_load(self.config_file)
                active_mods = list(config.get("activeMods", {}).keys())
            except:
                pass

        mod_config = smart_json_load(os.path.join(mod_path, "config.json"))
        
        # Load default settings from mod config
        mod_settings = {}
        for s in mod_config.get("settings", []):
            if "id" in s and "default" in s:
                mod_settings[s["id"]] = s["default"]
        
        # Override with user settings from diggles-mod-manager.json
        is_first_enable = True
        if os.path.exists(self.config_file):
            try:
                global_config = smart_json_load(self.config_file)
                if mod_id in global_config.get("activeMods", {}):
                    is_first_enable = False
                    user_settings = global_config.get("activeMods", {}).get(mod_id, {})
                    mod_settings.update(user_settings)
            except:
                pass

        # Interactive prompt if first enable and has settings (and it's the 'enable' command)
        if update_config and is_first_enable and mod_config.get("settings") and sys.stdin.isatty():
             print(f"\nConfiguring settings for {mod_id}:")
             for s in mod_config.get("settings"):
                 setting_id = s.get("id")
                 if not setting_id: continue
                 
                 name = s.get("name", setting_id)
                 if isinstance(name, dict):
                     name = name.get("en") or list(name.values())[0]
                 
                 desc = s.get("description", "")
                 if isinstance(desc, dict):
                     desc = desc.get("en") or list(desc.values())[0]
                 
                 default = s.get("default")
                 setting_type = s.get("type", "string")
                 
                 print(f"\n  {name} ({setting_id})")
                 if desc: print(f"  {desc}")
                 
                 if setting_type == "select":
                     possible = s.get("possibleValues", [])
                     print("  Possible values:")
                     for v in possible:
                         v_name = v.get("name", v.get("value"))
                         if isinstance(v_name, dict):
                             v_name = v_name.get("en") or list(v_name.values())[0]
                         print(f"    - {v.get('value')}: {v_name}")
                 
                 try:
                     user_input = input(f"  Enter value [default: {default}]: ").strip()
                     if user_input:
                         if setting_type == "bool" or isinstance(default, bool):
                             mod_settings[setting_id] = user_input.lower() in ["true", "yes", "1", "y"]
                         elif setting_type == "int" or isinstance(default, int):
                             try:
                                 mod_settings[setting_id] = int(user_input)
                             except ValueError:
                                 print(f"  Invalid integer. Using default: {default}")
                         else:
                             mod_settings[setting_id] = user_input
                 except (EOFError, KeyboardInterrupt):
                     print("\n  Using default values.")
                     break

        settings = {"active_mods": active_mods}
        settings.update(mod_settings)
        engine = PatchEngine(settings)

        mod_directories = mod_config.get("directories", [])
        # Sort by path length descending to match more specific paths first
        mod_directories.sort(key=lambda x: len(str(x.get("path", ""))), reverse=True)

        for root, dirs, files in os.walk(mod_path):
            for file in files:
                if file == "config.json":
                    continue
                
                rel_path = os.path.relpath(os.path.join(root, file), mod_path)
                
                # Directory condition and mapping evaluation
                skip_file = False
                mapped_rel_path = rel_path
                rel_path_fwd = rel_path.replace("\\", "/")
                
                for dir_config in mod_directories:
                    dir_path = str(dir_config.get("path", "")).replace("\\", "/")
                    if not dir_path: continue
                    if rel_path_fwd == dir_path or rel_path_fwd.startswith(dir_path + "/"):
                        # Evaluate condition
                        condition = dir_config.get("condition", {})
                        if condition:
                            if condition.get("type") == "variable":
                                c_id = condition.get("id")
                                c_val = condition.get("value")
                                if mod_settings.get(c_id) != c_val:
                                    skip_file = True
                                    break
                        
                        # Apply mapping
                        if dir_config.get("type") == "data":
                            # Replace the prefix with 'data'
                            mapped_rel_path = "data" + rel_path[len(dir_path):]
                        break
                
                if skip_file:
                    continue

                is_patch = False
                target_rel_path = mapped_rel_path
                
                # Check if any part of the path starts with change_
                parts = mapped_rel_path.split(os.sep)
                new_parts = []
                for part in parts:
                    if part.startswith("change_"):
                        is_patch = True
                        new_parts.append(part[len("change_"):])
                    else:
                        new_parts.append(part)
                
                if is_patch:
                    target_rel_path = os.path.join(*new_parts)
                    target_path = resolve_path_ci(self.game_root, target_rel_path)
                    
                    if os.path.exists(target_path):
                        self._backup_file(target_rel_path)
                        original_content = smart_read(target_path)
                        patch_content = smart_read(os.path.join(root, file))
                        
                        new_content = engine.apply_patch(original_content, patch_content)
                        if new_content != original_content:
                            with open(target_path, "w", encoding="utf-8") as f:
                                f.write(new_content)
                            print(f"Patched: {os.path.relpath(target_path, self.game_root)}")
                        else:
                            print(f"Warning: Patch failed (no match or already applied): {os.path.relpath(target_path, self.game_root)}")
                    else:
                        print(f"Warning: Patch target not found: {target_rel_path}")
                else:
                    # Direct Copy
                    target_path = resolve_path_ci(self.game_root, mapped_rel_path)
                    os.makedirs(os.path.dirname(target_path), exist_ok=True)
                    self._backup_file(mapped_rel_path)
                    shutil.copy2(os.path.join(root, file), target_path)
                    print(f"Copied: {os.path.relpath(target_path, self.game_root)}")

        if update_config:
            self._update_active_status(mod_id, True, mod_settings)

    def disable_mod(self, mod_id):
        mod_path = os.path.join(self.mods_dir, mod_id)
        if not os.path.exists(mod_path):
            return

        mod_config = smart_json_load(os.path.join(mod_path, "config.json"))
        
        # Load settings to know what was enabled
        mod_settings = {}
        for s in mod_config.get("settings", []):
            if "id" in s and "default" in s:
                mod_settings[s["id"]] = s["default"]
        
        if os.path.exists(self.config_file):
            try:
                global_config = smart_json_load(self.config_file)
                if mod_id in global_config.get("activeMods", {}):
                    user_settings = global_config["activeMods"][mod_id]
                    mod_settings.update(user_settings)
            except:
                pass

        mod_directories = mod_config.get("directories", [])
        mod_directories.sort(key=lambda x: len(str(x.get("path", ""))), reverse=True)

        for root, dirs, files in os.walk(mod_path):
            for file in files:
                if file == "config.json":
                    continue
                rel_path = os.path.relpath(os.path.join(root, file), mod_path)
                
                # Directory condition and mapping evaluation
                skip_file = False
                mapped_rel_path = rel_path
                rel_path_fwd = rel_path.replace("\\", "/")
                
                for dir_config in mod_directories:
                    dir_path = str(dir_config.get("path", "")).replace("\\", "/")
                    if not dir_path: continue
                    if rel_path_fwd == dir_path or rel_path_fwd.startswith(dir_path + "/"):
                        # Evaluate condition
                        condition = dir_config.get("condition", {})
                        if condition:
                            if condition.get("type") == "variable":
                                c_id = condition.get("id")
                                c_val = condition.get("value")
                                if mod_settings.get(c_id) != c_val:
                                    skip_file = True
                                    break
                        
                        # Apply mapping
                        if dir_config.get("type") == "data":
                            mapped_rel_path = "data" + rel_path[len(dir_path):]
                        break

                if skip_file:
                    continue

                # Resolve target rel path
                parts = mapped_rel_path.split(os.sep)
                new_parts = []
                for part in parts:
                    if part.startswith("change_"):
                        new_parts.append(part[len("change_"):])
                    else:
                        new_parts.append(part)
                target_rel_path = os.path.join(*new_parts)
                
                self._restore_file(target_rel_path)
        
        self._update_active_status(mod_id, False)

    def restore_all(self):
        """Restores all backed up files to their original state."""
        if not os.path.exists(self.backup_dir):
            return
        
        for root, dirs, files in os.walk(self.backup_dir):
            for file in files:
                rel_path = os.path.relpath(os.path.join(root, file), self.backup_dir)
                target = os.path.join(self.game_root, rel_path)
                shutil.copy2(os.path.join(root, file), target)
        print("Restored all files from backup.")

    def apply_active_mods(self):
        if not os.path.exists(self.config_file):
            print("No mod manager config found.")
            return
        
        config = smart_json_load(self.config_file)
        active_mods = config.get("activeMods", {})
        if not active_mods:
            print("No active mods.")
            return

        # Restore first to ensure clean state
        self.restore_all()
        
        # Apply mods in order
        for mod_id in active_mods:
            print(f"Applying {mod_id}...")
            self.enable_mod(mod_id, update_config=False)

    def _backup_file(self, rel_path):
        src = resolve_path_ci(self.game_root, rel_path)
        actual_rel_path = os.path.relpath(src, self.game_root)
        dst = os.path.join(self.backup_dir, actual_rel_path)
        if os.path.exists(src) and not os.path.exists(dst):
            os.makedirs(os.path.dirname(dst), exist_ok=True)
            shutil.copy2(src, dst)

    def _restore_file(self, rel_path):
        target = resolve_path_ci(self.game_root, rel_path)
        actual_rel_path = os.path.relpath(target, self.game_root)
        backup = os.path.join(self.backup_dir, actual_rel_path)
        
        if os.path.exists(backup):
            shutil.copy2(backup, target)
            print(f"Restored: {actual_rel_path}")
        elif os.path.exists(target):
            # If it was a new file added by mod, remove it
            os.remove(target)
            print(f"Removed: {actual_rel_path}")

    def _update_active_status(self, mod_id, active, settings=None):
        config = {"activeMods": {}}
        if os.path.exists(self.config_file):
            try:
                config = smart_json_load(self.config_file)
            except:
                pass
        
        if active:
            config["activeMods"][mod_id] = settings if settings is not None else config["activeMods"].get(mod_id, {})
        else:
            if mod_id in config["activeMods"]:
                del config["activeMods"][mod_id]
        
        with open(self.config_file, "w", encoding="utf-8") as f:
            json.dump(config, f, indent=2)

def main():
    parser = argparse.ArgumentParser(description="Diggles Linux Mod Manager")
    parser.add_argument("command", choices=["list", "enable", "disable", "apply", "disable-all", "restore-all"])
    parser.add_argument("mod", nargs="?", help="Name of the mod")
    
    args = parser.parse_args()
    manager = ModManager(".")

    if args.command == "list":
        mods = manager.list_mods()
        print(f"{'ID':<25} {'Status':<10} {'Name'}")
        print("-" * 60)
        for mod in mods:
            status = "[ACTIVE]" if mod["active"] else "[INACTIVE]"
            print(f"{mod['id']:<25} {status:<10} {mod['name']}")
    
    elif args.command == "enable":
        if not args.mod:
            print("Error: Specify a mod ID.")
            return
        manager.enable_mod(args.mod)
    
    elif args.command == "disable":
        if not args.mod:
            print("Error: Specify a mod ID.")
            return
        manager.disable_mod(args.mod)
    
    elif args.command == "disable-all":
        if os.path.exists(manager.config_file):
            try:
                config = smart_json_load(manager.config_file)
                active_mods = list(config.get("activeMods", {}).keys())
                if not active_mods:
                    print("No active mods found.")
                    return
                for mod_id in active_mods:
                    print(f"Disabling {mod_id}...")
                    manager.disable_mod(mod_id)
            except Exception as e:
                print(f"Error: Failed to process config: {e}")
        else:
            print("No mod manager config found. No mods are active.")
    
    elif args.command == "apply":
        manager.apply_active_mods()
    
    elif args.command == "restore-all":
        manager.restore_all()

if __name__ == "__main__":
    main()
