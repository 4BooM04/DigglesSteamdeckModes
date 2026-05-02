# TickRateFix Mod for Diggles: Myth of Fenris

## Overview
This mod doubles the frequency of character logic checks by halving the interval of key gnomish timers from 1.0s to 0.5s. It includes a comprehensive rebalance of attribute drain mechanics to ensure that gnomes do not consume resources or age twice as fast.

## Features
- **0.5s Tick Rate**: Gnomes check for work, update their attributes, and react to their environment every 0.5 seconds.
- **Rebalanced Drains**:
    - Environmental damage (Lava, Burning, Sulfur, Drowning) halved per tick.
    - Breath-holding time (Remaining Air) maintained by halving decrement.
    - Attribute depletion (Hunger, Energy, Mood) and Health loss scaled to the new tick rate.
    - Timeline statistics scaled for accurate long-term tracking.

## Technical Details
- Modifies `evt_zwerg_attribupdate` and `evt_zwerg_workannounce` timer intervals in `zwerg.tcl`.
- Patches `evt_zwerg_attribupdate_proc` in `z_events.tcl` to scale all attribute changes by 0.5.
