# Diggles: Myth of Fenris Modding Guide

This guide provides a technical overview of the game's script structure and how to modify game logic using the Diggles Mod Manager.

## 1. Mod Manager System
The mod manager uses a non-destructive patching system. Mods are placed in the `Mods/` directory.

### Directory Structure
- `Mods/<ModName>/config.json`: Metadata and settings for the mod.
- `Mods/<ModName>/<Filepath>`: Any file placed here will be added to the game or overwrite an original file if the path matches.
- `Mods/<ModName>/change_<Filepath>`: A surgical patch file that modifies the original file without overwriting it entirely.

### Patch Syntax (change_*.tcl)
Surgical patches allow multiple mods to modify the same file safely.
- `$start`: Beginning of a patch block.
- `$before <string>`: Finds the line containing `<string>` and targets the space before it.
- `$after <string>`: Finds the line containing `<string>` and targets the space after it.
- `$replace`: Replaces the targeted block or the found string with new code.
- `$end`: End of a patch block.

## 2. Game Logic Mapping

### Gnome AI & Behavior
Location: `data/Scripts/classes/zwerg/`
- `zwerg.tcl`: Main class definition for gnomes.
- `z_events.tcl`: Handles life events like hunger, sleep, and injuries.
- `z_spare_procs.tcl`: Logic for gnomes during their leisure time (deciding what to eat, where to sleep).
- `z_work_states.tcl`: The state machine governing how gnomes transition between jobs.
- `actors.tcl`: Defines gnome animations and visual behavior.

### Production & Automation (AI)
Location: `data/Scripts/misc/`
- `z_autoprod.tcl`: The "heart" of the automatic production AI. Contains `autoprod_rate_task`, which calculates the priority score for every potential job a gnome could do.
- `autoprod.tcl`: Scans all buildings and digsites to generate tasks for the automation system.
- `techtreetunes.tcl`: Contains the technology tree, invention requirements, and item stats.

### Workplaces & Jobs
Location: `data/Scripts/classes/work/`
- `feuerstelle.tcl`: Campfire (basic cooking).
- `mittelalterkueche.tcl`: Medieval kitchen.
- `industriekueche.tcl`: Industrial kitchen.
- `luxuskueche.tcl`: Luxury kitchen.
- `lager.tcl`: Warehouse logic (transporting and storing items).
- `prodman_proc.tcl`: General production manager logic.

### Gameplay Mechanics
- `data/Scripts/gameplay/`: Combat logic, damage calculation, and trading.
- `data/Scripts/ai/`: General AI behaviors for enemies and creatures.

## 3. Best Practices
- Always use `change_` files when modifying existing scripts to maintain compatibility with other mods.
- Test TCL changes for syntax errors; a single error in a core script like `zwerg.tcl` or `z_autoprod.tcl` can crash the entire game AI.
- Use `log` or `print` statements in TCL to debug logic at runtime.
