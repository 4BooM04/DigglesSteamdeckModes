# BetterCookingPriority

Increases the priority of food production tasks in the auto-production system to prevent starvation in large bases.

## Features
- **Enhanced Food Priority**: Significantly boosts the priority score for all food-related production and transport tasks.
- **Dynamic Hunger Escalation**: If any gnome in the colony drops below 20% nutrition, the mod triggers a "Colony Starving" state, pushing kitchen tasks to the absolute top of the priority list.
- **Smart Task Assignment**:
    - **Healthy Gnomes**: Encouraged to work *inside* the kitchen to keep production moving.
    - **Hungry Gnomes**: Encouraged to *carry* ingredients to the kitchen, naturally leading them toward food sources when they finish their task.

## Implementation Details
Surgically patches the `z_autoprod.tcl` work scheduler to intercept item requests and production checks, injecting custom scoring logic based on `atr_Nutrition` and object class checks.
