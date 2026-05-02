# Diggles: Myth of Fenris - Modded Logic Documentation

This document describes the changes to the game logic introduced by currently applied mods.

## Active Mods
- **RevisedPlanner**: Comprehensive AI and Scheduler overhaul.
- **BetterCookingPriority**: Food production and supply chain optimization.
- **BatchCollection**: Resource collection optimization for production sites.
- **MushroomSettings**: (Likely attribute/config changes, not major logic overhaul).

---

## 1. RevisedPlanner Overhaul

The `RevisedPlanner` mod replaces the original work scheduler and leisure logic with a custom implementation.

### 1.1 Work Scheduler Changes
- **New Implementation**: The `autoprod_rate_task` and `autoprodx_do_proc` in `z_autoprod.tcl` are rewritten.
- **Improved Responsiveness**: The "slack" delay for searching new tasks has been reduced from **10 seconds to 5 seconds**, making gnomes much more proactive.
- **Barkeeper Logic**: Improved responsiveness (no 10s delay).
- **Bugfixes**: Handles stuck bowling alleys, hospitals, and disco-related AI loops.
- **Known Issue**: Progress indicators (green bars) on production sites are broken in this version.

### 1.2 Spare Time (Leisure) Logic
- **Hospital Range**: Increased from 40 to 160 units, making it easier for gnomes to find medical help.
- **Late-game Balancing**: Reduced impossible quality/variety requirements in high-civilization states to prevent "unfixable" bad moods.
- **Food Variety**: Completely new judgment system for food variety.
- **Mood Buffs**: Reduced mood loss from bad sleep quality by 50%.

### 1.3 Miscellaneous AI Tweaks
- **Item Dropping (F9)**: Now smarter—only drops materials if present, otherwise drops everything.
- **Kitchen Range**: Increased range for considering items "in" the kitchen (from 7 to 10 units).

---

## 2. BetterCookingPriority Improvements

This mod patches the work scheduler (`z_autoprod.tcl`) to ensure the colony never starves in the late game.

### 2.1 Priority Scoring
It injects a high-priority scoring block into the task rating system:
- **Food-related Bonus**: Adds **+5000** score to any task involving food items or kitchen/farm workplaces.
- **Health-based Scaling**:
    - **Production/Cooking**: Healthier gnomes (high nutrition) get a bonus (up to **+4000**) to stay in the kitchen and cook.
    - **Supplying/Carrying**: Hungrier gnomes get a bonus (up to **+6000**) to carry ingredients TO the kitchen (placing them near food).
- **Starvation Emergency**: If any gnome in the colony has <20% nutrition, a global **+15000** bonus is applied to ALL food tasks, forcing the entire workforce to prioritize survival.

---

## 3. BatchCollection Optimization

This mod optimizes how gnomes supply materials to production buildings (Kitchens, Smelters, etc.).

### 3.1 Batch Procurement
- **Production Target Awareness**: Instead of bringing materials for just one production run, gnomes now check the production counter.
- **Multi-trip Logic**: If a building needs 10 mushrooms and the gnome can carry 8, they will try to find and bring all 8 in one go.
- **Batch Limit**: Currently capped at **8 items** per trip to prevent excessive pathfinding and inventory overflow.

### 3.2 Partial Delivery
- **Non-blocking Search**: If a gnome is tasked to bring a batch but can't find ALL required items (e.g., only 5 out of 8 are available), they will now bring what they found instead of abandoning the task.

---

## 4. Impact on Game Tick

While the 1-second interval remains, the **decision-making** within that tick is much more aggressive:
1.  Gnomes are more likely to find work due to the `RevisedPlanner`'s rewritten logic.
2.  Food crises are averted by the `BetterCookingPriority`'s massive score injections.
3.  Leisure activities are more effective and less frustrating in the late game.
