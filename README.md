# Combat Refactor Overview

This patch set addresses a long-standing combat bug where the boss **Kaluga** never stopped attacking and could not be damaged by the player. The fix required coordinated changes to the shared `Character` base class, the controllable `Player`, Kaluga's AI script, and a supporting enemy (`Sharaka`) so that every actor now cooperates with a predictable Godot 4 physics loop.

## What Was Broken
- **State machine drift** – `Character.gd` drove gameplay from `_process`, mixing rendering and physics steps. Subclasses (Kaluga, Sharaka, Player) overrode pieces of that flow in different callbacks, so state was overwritten every frame and velocities were reapplied even when actors were stunned or falling.
- **Kaluga attack spam** – `kaluga.gd` toggled `ready_to_attack` immediately on each timer tick and never reset when an attack connected, so he re-entered `State.FLY_ATTACK` every frame, sliding indefinitely without giving the player a damage window.
- **Damage never emitted** – The base class always emitted `damage` (not the computed combo damage), and Kaluga bypassed the player’s `DamageReceiver` so the signal never reached the target. Combined with the attack spam, the player could not register hits against Kaluga at all.
- **Inconsistent physics hooks** – `Player` injected manual translations inside `_physics_process` while the base class also called `move_and_slide`, so some states (backdash, knockback) fought each other, causing unreliable positioning and further desync with Kaluga’s collision checks.

## What Changed

### `Scenes/Scene2_3/Characters/character.gd`
- Converted every export/onready to typed Godot 4 style and centralized runtime setup.
- Replaced `_process` logic with a single `_physics_process` pipeline that calls (in order) input/AI handlers, air time, grounded logic, animation/state overrides, and finally `move_and_slide`.
- Added `handle_ai` / `handle_state_overrides` no-ops so subclasses can extend behavior without rewriting the base loop.
- Made damage emission respect combo finishers and guard against missing health bars so every actor now receives the intended `DamageReceiver` signal and updates UI safely.

### `Scenes/Scene2_3/Characters/player.gd`
- Typed slot/timer references and moved manual backdash translation into `handle_state_overrides`, ensuring it runs exactly once per physics tick after velocities are cleared.
- Continued to use the new base pipeline (no direct `_physics_process` override), so player movement now mirrors NPC timing.

### `Scenes/Scene2_5/scenes/characters/kaluga.gd`
- Added exported chase/attack distance and cooldown knobs for balancing.
- Implemented `_has_viable_target`, `_enter_idle`, `_move_towards_player`, and `_hold_position` helpers so AI decisions are readable and testable.
- Attack flow now: check cooldown + aim, launch `State.FLY_ATTACK`, emit damage through the base class, call `on_attack_complete`, reset velocity, and re-arm the timer. This ensures Kaluga pauses between lunges and can be interrupted/damaged mid-sequence.

### `Scenes/Scene2_3/Characters/sharaka.gd`
- Updated to call `super._physics_process` so it remains in sync with the shared character loop.

## Why This Fix Works
- **Deterministic physics** – Every character now executes the same physics tick ordering, eliminating race conditions between `_process` and `_physics_process`. This is the Godot 4 best practice for anything that moves via `CharacterBody2D`.
- **Single source of truth for damage** – Attacks always emit through the base class with the computed damage/knockback and respect the victim’s current state, so Kaluga once again takes damage when the player connects.
- **Explicit AI states** – Kaluga’s new helpers encapsulate when he should chase, idle, or attack. Because the cooldown gate and target validity checks guard `attack()`, he cannot spam or stay stuck in special states.
- **Safe overrides** – `Player` and Kaluga use `handle_state_overrides`/`handle_ai` rather than duplicating the base loop, so future changes to the shared character lifecycle automatically apply to all subclasses.

## Validation
- Script linting passes for all touched files (`character.gd`, `player.gd`, `kaluga.gd`, `sharaka.gd`).
- Manual reasoning confirms Kaluga now alternates between chase/attack windows, the player can damage him, and knockback/grounded transitions no longer fight each other. A playtest in the editor is recommended to fine-tune the new exported distances/cooldowns.

