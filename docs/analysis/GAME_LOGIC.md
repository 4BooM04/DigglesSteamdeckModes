# Diggles: Myth of Fenris - Game Logic Documentation (Base)

This document describes the internal script logic of the unmodified game "Diggles: Myth of Fenris".

## 1. Execution Model

The game logic for characters (Gnomes/Zwerge) is primarily event-driven and state-based.

### 1.1 State Machine
Each Gnome has a state machine defined in `data/Scripts/classes/zwerg/zwerg.tcl`. Key states include:
- `idle`: The default state when no tasks are assigned.
- `task`: Executing a list of independent tasks.
- `work_dispatch`: Finding a workplace or task.
- `work_idle`: Assigned to a workplace but currently has no specific sub-task.
- `work_active`: Actively working at a workplace.
- `sparetime_dispatch`: Starting leisure activities.
- `sparetime`: Executing leisure activities (eating, sleeping, etc.).

### 1.2 Tick System (Timers)
Gnomes use several high-frequency timers for periodic logic:
- `evt_zwerg_attribupdate` (Interval: 1s): Updates hunger, energy, health, and checks for environmental hazards (lava, drowning).
- `evt_zwerg_workannounce` (Interval: 1s): High-level task re-evaluation.
- `evt_talkissue_update` (Interval: 5s): Updates social/talking state.
- `evt_sparewish_update` (Interval: 10s): Updates leisure desires.

## 2. The Game Tick (1 Second Cycle)

Every second, the following logic typically executes for each active gnome:

1.  **Attribute Update** (`evt_zwerg_attribupdate_proc`):
    - Drains `atr_Nutrition` (Hunger) and `atr_Alertness` (Energy).
    - Checks for environmental damage (Lava, Sulfurous water).
    - Handles drowning if underwater for too long.
    - Updates age (`GnomeAge`).
2.  **State Logic Execution**:
    - If in `idle` state:
        - Checks if it's time to switch to `work` or `sparetime` based on the schedule.
        - If `idletimeout > 5`, it usually triggers `sparetime_dispatch`.
    - If in `task` state:
        - Executes the next command in `tasklist`.
3.  **Work Announcement** (`evt_zwerg_workannounce_proc`):
    - Triggers the work scheduler if the gnome is looking for work.

## 3. Decision Making: Work vs. Sparetime

Transitions are managed in the `idle` state and event handlers for `evt_time_startwork` and `evt_time_startsparetime`.

- Gnomes follow a `current_plan` (Work or Sparetime).
- `get_remaining_sparetime` checks if the gnome should still be in leisure mode.
- The `idle` state logic in `zwerg.tcl` is the primary arbiter of these transitions.

## 4. Work Scheduler (`z_autoprod.tcl`)

The `z_autoprod.tcl` script contains the "brain" for task selection.

### 4.1 Task Scoring
When a gnome is in `work_idle` or `idle` and looking for work, the engine calls `autoprod_rate_task`.
- **Base Score**: Depends on the task type (carry, bringprod, etc.).
- **Proximity**: Score is penalized based on distance to the workplace.
- **Preferred Workplace**: Gnomes prefer tasks at their assigned workplace.
- **Equipment**: Preference for tasks they have tools for (Kettensaege, Hammer, etc.).
- **Inventory**: Carrying tasks are penalized if inventory is full.

### 4.2 Task Execution
`autoprodx_do_proc` handles the actual assignment of a task to a gnome, clearing their current tasklist and injecting the new sequence of actions.
