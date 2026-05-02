# Diggles: Myth of Fenris Modding Environment

This directory contains a workspace for modding the game "Diggles: Myth of Fenris" (Wiggles) on Linux.

## Project Overview
The project consists of:
- **`dmm.py`**: A custom-built Linux CLI Mod Manager that handles non-destructive patching of game scripts.
- **`BetterCookingPriority` Mod**: A custom mod that fixes late-game starvation by boosting food production priority.
- **`RevisedPlanner` Mod**: A comprehensive AI overhaul that replaces the game's work scheduler and leisure logic.
- **`MODDING_GUIDE.md`**: Technical documentation of the game's internal script structure.

## Building and Running
The "build" process consists of applying patches to the game's `.tcl` scripts.
ALL THE CHANGES SHOULD BE DONE IN MODES AND THEN APPLIED TO GAME VIA DMM PATCHING

### Mod Manager Commands (`./dmm.py`):
- `list`: Lists all available mods in the `Mods/` directory and their active status.
- `enable <ModID>`: Backs up original files and applies the mod's patches/files.
- `disable <ModID>`: Restores files from backup and removes mod-added files.
- `apply`: Re-applies all mods marked as active in `diggles-mod-manager.json`.

### Game Execution:
Run the game via Steam/Proton. The scripts are loaded from `data/Scripts/` at runtime.

## Development Conventions
### Patching System
Modifications to existing game scripts MUST use the surgical patch system to maintain compatibility between mods.
- Create a file named `change_<original_filename>.tcl` inside the mod folder.
- Use the following syntax:
    - `$start` / `$end`: Mark block boundaries.
    - `$replace` / `$with`: Standard search and replace.
    - `$before` | `$after` / `$put`: Insert content relative to a found string.
- Case-insensitivity: Always account for Linux case-sensitivity by using `resolve_path_ci` in tools or ensuring paths match the on-disk `data/` structure.

### Scripting (TCL)
- The game uses Tcl 8.3.
- Key AI logic is located in `data/Scripts/misc/z_autoprod.tcl` (Work Scheduler) and `data/Scripts/classes/zwerg/` (Gnome behavior).
### Documentation
- Detailed analysis of game logic and modded behavior can be found in `docs/analysis/`:
    - `GAME_LOGIC.md`: Base game execution model and tick logic.
    - `MODDED_LOGIC.md`: Analysis of changes by currently applied mods (RevisedPlanner, BetterCookingPriority, BatchCollection, TickRateFix).

## Modding Conventions
- **New Mods**:
    - Always include a `config.json` in the mod root.
    - Always include a `README.md` describing the mod's purpose, features, and technical changes.
    - Store surgical script patches in `change_data/Scripts/` (or matching the game's internal structure).
