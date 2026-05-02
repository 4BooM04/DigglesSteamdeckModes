# Diggles Mod Manager (DMM) for Linux

`dmm.py` is a Python-based CLI tool designed to manage mods for "Diggles: The Myth of Fenris" on Linux. It handles file deployment, surgical patching of game scripts, and automatic backups to ensure game integrity.

## Commands

Run these commands from the game root directory:

| Command | Usage | Description |
| :--- | :--- | :--- |
| **list** | `python3 dmm.py list` | Lists all available mods in the `Mods/` folder and their status. |
| **enable** | `python3 dmm.py enable <ModID>` | Activates a mod, copying files and applying patches. |
| **disable** | `python3 dmm.py disable <ModID>` | Deactivates a mod and restores original files from backup. |
| **disable-all** | `python3 dmm.py disable-all` | Deactivates all currently active mods. |
| **apply** | `python3 dmm.py apply` | Re-applies all mods marked as active in the configuration. |

## How it Works

### 1. Mod Structure
Mods are located in the `Mods/` directory. Each mod requires a `config.json` file.
- **Direct Copy:** Files in the mod folder are copied to the game root (e.g., `Mods/MyMod/data/scripts/test.tcl` -> `data/scripts/test.tcl`).
- **Patching:** Folders or files prefixed with `change_` indicate a patch rather than an overwrite. The manager will look for the target file and apply surgical changes defined in the patch file.

### 2. Patching Engine
DMM supports a custom patch format using `$start`, `$end`, `$replace`, `$before`, and `$after` tags. This allows multiple mods to modify the same file without complete overwrites.

### 3. Backups
Before a mod modifies or overwrites a game file for the first time, DMM creates a backup in the `.dmm_backup/` directory. Disabling a mod restores these original files.

### 4. Linux Compatibility
- **Case-Insensitive Resolution:** The manager resolves paths case-insensitively to match Windows-style pathing used by the game's original assets.
- **Encoding:** Handles both UTF-8 (with BOM) and Latin-1 encodings commonly found in the game's `.tcl` files.

## Configuration
Active mods and their settings are tracked in `diggles-mod-manager.json` in the game root.
