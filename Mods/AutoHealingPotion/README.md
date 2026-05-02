# AutoHealingPotion Mod

Allows gnomes to automatically consume healing potions during combat if their health falls below a certain threshold.

## Features
- **Automatic Healing**: Gnomes will check their health during every combat tick.
- **Configurable Threshold**: You can set the health percentage at which they should drink a potion.
- **Smart Prioritization**: Gnomes will prefer larger potions first to maximize survival chance during intense fights.

## Configuration
The mod includes a setting in `config.json`:
- `AUTO_HEAL_THRESHOLD`: Default is `0.4` (40% health).

## Technical Details
This mod patches `data/Scripts/misc/genericfight.tcl` to inject a health check within the `fight_dispatch` state. If the condition is met and a potion is found in the gnome's inventory, it calls the standard `drinkpotion` procedure, which:
1. Removes the potion from inventory.
2. Plays the drinking animation.
3. Disables the fight state during the animation.
4. Applies the healing effect.
5. Re-enables the gnome's state after the animation finishes.
