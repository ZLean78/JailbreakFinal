# Phase 5: Scene Migration Guide

This guide covers the manual steps required to migrate existing scenes to use the new character architecture. The code infrastructure (Phases 1-4) is complete - this phase focuses on updating `.tscn` scene files in the Godot editor.

---

## Overview

### What Was Already Done (Code)
- ✅ Core damage system (`Core/Combat/`)
- ✅ State machine pattern (`Core/StateMachine/`, `Core/States/Character/`)
- ✅ Component architecture (`Core/Components/`)
- ✅ Character resources (`Core/Resources/`, `Resources/Characters/`)
- ✅ Base character class (`Core/Characters/BaseCharacter.gd`)
- ✅ Input system (`Core/Input/`)
- ✅ AI system (`Core/AI/`)
- ✅ Specific characters (`Scenes/Characters/PlayerCharacter.gd`, `SharakaCharacter.gd`, `KalugaCharacter.gd`)

### What Requires Manual Work (Scenes)
- ⏳ Update `player.tscn` (Scene2_3) node structure and script reference
- ⏳ Update `sharaka.tscn` node structure and script reference
- ⏳ Update `kaluga.tscn` node structure and script reference
- ⏳ Update `player2.tscn` (Scene2_5) if still used
- ⏳ Decide fate of `boss_enemy.gd` (appears to be older boss implementation)
- ⏳ Update main game scenes to use new character scenes
- ⏳ Re-link signals in scene editor

### Files NOT Requiring Migration (Different Systems)
These files extend `CharacterBody2D` directly and are separate from the combat system:
- `Scenes/Guard/guard.gd` - Patrolling guard NPC (stealth levels)
- `Scenes/Guard/guard_2.gd` - Guard variant
- `Scenes/Prisoner/prisoner.gd` - Laundry NPC
- `Scenes/Player/player.gd` - Stealth player with crawling/disguise (different from combat player)
- `rahiri.gd` - Path-following NPC

---

## Migration Steps by Character

### 1. Player Character Migration

**File:** `Scenes/Scene2_3/Characters/player.tscn`

#### Step 1.1: Update Root Node Script
1. Open `player.tscn` in Godot
2. Select the root `Player` node
3. In the Inspector, change the script from:
   - Old: `res://Scenes/Scene2_3/Characters/player.gd`
   - New: `res://Scenes/Characters/PlayerCharacter.gd`

#### Step 1.2: Add Required Component Nodes
Add these child nodes to the root `Player` node:

```
Player (PlayerCharacter)
├── CharacterStateMachine (Node)          # NEW - Add this
├── HealthComponent (Node)                 # NEW - Add this
├── MovementComponent (Node)               # NEW - Add this
├── CombatComponent (Node)                 # NEW - Add this
├── AnimationComponent (Node)              # NEW - Add this
├── PlayerInputHandler (Node)              # NEW - Add this
├── CharacterSprite (Sprite2D)             # EXISTING - Keep
├── Shadow (Sprite2D)                      # EXISTING - Keep
├── AnimationPlayer (AnimationPlayer)      # EXISTING - Keep
├── DamageReceiver (Area2D)                # UPDATE - Change script
│   └── CollisionShape2D
├── DamageEmitter (Area2D)                 # UPDATE - Change script
│   └── CollisionShape2D
└── ... (other existing nodes)
```

**How to add each node:**
1. Right-click `Player` → Add Child Node → Select `Node`
2. Rename to the component name (e.g., "CharacterStateMachine")
3. Attach the corresponding script:
   - `CharacterStateMachine`: `res://Core/Characters/CharacterStateMachine.gd`
   - `HealthComponent`: `res://Core/Components/HealthComponent.gd`
   - `MovementComponent`: `res://Core/Components/MovementComponent.gd`
   - `CombatComponent`: `res://Core/Components/CombatComponent.gd`
   - `AnimationComponent`: `res://Core/Components/AnimationComponent.gd`
   - `PlayerInputHandler`: `res://Core/Input/PlayerInputHandler.gd`

#### Step 1.3: Update DamageReceiver/DamageEmitter
1. Select `DamageReceiver` node
2. Change script to: `res://Core/Combat/DamageReceiver.gd`
3. Select `DamageEmitter` node (or `Hitbox` if named differently)
4. Change script to: `res://Core/Combat/DamageEmitter.gd`

#### Step 1.4: Configure Component References
Select the root `Player` node and set these exports in the Inspector:

| Export Property | Node to Assign |
|-----------------|----------------|
| `config` | `res://Resources/Characters/player_config.tres` |
| `character_sprite` | `CharacterSprite` (Sprite2D node) |
| `shadow_sprite` | `Shadow` (Sprite2D node) |
| `animation_player` | `AnimationPlayer` node |
| `state_machine` | `CharacterStateMachine` node |
| `health_component` | `HealthComponent` node |
| `movement_component` | `MovementComponent` node |
| `combat_component` | `CombatComponent` node |
| `animation_component` | `AnimationComponent` node |
| `damage_receiver` | `DamageReceiver` node |
| `damage_emitter` | `DamageEmitter` node |

Configure `PlayerInputHandler`:
| Export Property | Node to Assign |
|-----------------|----------------|
| `character` | Root `Player` node |

Configure `HealthComponent`:
| Export Property | Value |
|-----------------|-------|
| `max_health` | 100 (or leave default, loaded from config) |
| `health_bar` | Link to UI health bar if exists |

#### Step 1.5: Verify Animations
The existing `AnimationPlayer` animations should work if they use these names:
- `idle`, `walk`, `punch`, `punch_alt`, `kick`, `roundkick`
- `jump`, `land`, `hurt`, `fall`, `fly`, `grounded`, `beaten`

If animation names differ, either rename them or update `attack_animations` in `player_stats.tres`.

---

### 2. Sharaka Character Migration

**File:** `Scenes/Scene2_3/Characters/sharaka.tscn`

#### Step 2.1: Update Root Node Script
1. Open `sharaka.tscn` in Godot
2. Select the root `Sharaka` node
3. Change script to: `res://Scenes/Characters/SharakaCharacter.gd`

#### Step 2.2: Add Required Component Nodes
```
Sharaka (SharakaCharacter)
├── CharacterStateMachine (Node)          # NEW
├── HealthComponent (Node)                 # NEW
├── MovementComponent (Node)               # NEW
├── CombatComponent (Node)                 # NEW
├── AnimationComponent (Node)              # NEW
├── AIController (Node)                    # NEW
├── CharacterSprite (Sprite2D)             # EXISTING
├── Shadow (Sprite2D)                      # EXISTING
├── AnimationPlayer (AnimationPlayer)      # EXISTING
├── DamageReceiver (Area2D)                # UPDATE script
└── DamageEmitter (Area2D)                 # UPDATE script
```

**Scripts to attach:**
- `AIController`: `res://Core/AI/AIController.gd`
- Others same as Player

#### Step 2.3: Configure Component References
Select root `Sharaka` node:

| Export Property | Value/Node |
|-----------------|------------|
| `config` | `res://Resources/Characters/sharaka_config.tres` |
| `player` | Leave empty (set at runtime by game scene) |
| (other component refs) | Same pattern as Player |

Configure `AIController`:
| Export Property | Value |
|-----------------|-------|
| `character` | Root `Sharaka` node |

**Note:** The `player` reference and AI strategy are set programmatically in `SharakaCharacter._setup_ai()`.

#### Step 2.4: Verify Animations
Required animations: `idle`, `walk`, `punch`, `punch_alt`, `jump_attack`, `hurt`, `fall`, `beaten`

---

### 3. Kaluga Character Migration

**File:** `Scenes/Scene2_5/scenes/characters/kaluga.tscn`

#### Step 3.1: Update Root Node Script
1. Open `kaluga.tscn` in Godot
2. Select root `Kaluga` node
3. Change script to: `res://Scenes/Characters/KalugaCharacter.gd`

#### Step 3.2: Add Required Component Nodes
```
Kaluga (KalugaCharacter)
├── CharacterStateMachine (Node)          # NEW
├── HealthComponent (Node)                 # NEW
├── MovementComponent (Node)               # NEW
├── CombatComponent (Node)                 # NEW
├── AnimationComponent (Node)              # NEW
├── AIController (Node)                    # NEW
├── StunTimer (Timer)                      # KEEP or ADD if missing
├── AttackTimer (Timer)                    # KEEP or ADD if missing
├── FallTimer (Timer)                      # NEW - Add this
├── Aim (RayCast2D)                        # KEEP - for line-of-sight
├── CharacterSprite (Sprite2D)             # EXISTING
├── Shadow (Sprite2D)                      # EXISTING
├── AnimationPlayer (AnimationPlayer)      # EXISTING
├── DamageReceiver (Area2D)                # UPDATE script
└── DamageEmitter (Area2D)                 # UPDATE script
```

**Additional nodes for Kaluga:**
- `FallTimer`: Add Timer node, set `one_shot = true`, `wait_time = 2.0`

#### Step 3.3: Configure Component References
Select root `Kaluga` node:

| Export Property | Value/Node |
|-----------------|------------|
| `config` | `res://Resources/Characters/kaluga_config.tres` |
| `player` | Leave empty (set at runtime) |
| `kickback_multiplier` | `1.5` |
| `fall_recovery_time` | `2.0` |
| (component refs) | Same pattern as Player |

#### Step 3.4: Verify Timers
Ensure these timers exist and are configured:
- `StunTimer`: one_shot = true
- `AttackTimer`: one_shot = true
- `FallTimer`: one_shot = true, wait_time = 2.0

#### Step 3.5: Verify Aim RayCast
The `Aim` RayCast2D should:
- Target mask include player collision layer
- Be oriented in the attack direction
- Have appropriate length for attack range

#### Step 3.6: Verify Animations
Required: `idle`, `walk`, `attack`, `hurt`, `stunned`, `fly`, `beaten`

---

## 4. Update Game Scenes

### Scene2_3 Main Scene

1. Open your main Scene2_3 scene
2. Find where Player is instantiated
3. Update any direct references from old player script to new
4. Update signal connections if they reference old method names

**Common Signal Updates:**
| Old Signal/Method | New Signal/Method |
|-------------------|-------------------|
| `damage_received` on character | `damage_received` on `DamageReceiver` node |
| `health_depleted` | `health_depleted` on `HealthComponent` |
| Direct state checks | Use `state_machine.is_in_state(&"StateName")` |

### Scene2_5 Main Scene

1. Open your main Scene2_5 scene
2. Update Kaluga and Player2 references
3. Ensure `set_player()` is called on enemies after instantiation

---

## 5. Common Issues & Solutions

### Issue: "Invalid call. Nonexistent function"
**Cause:** Old code calling methods that moved to components
**Solution:** Update calls to use component references:
```gdscript
# Old
character.take_damage(10)

# New
character.health_component.take_damage(10)
# Or use the damage system:
character.damage_receiver.receive_damage(damage_data, direction, source)
```

### Issue: State enum not found
**Cause:** Old `State.IDLE` enum replaced with StringName states
**Solution:** Use StringName states:
```gdscript
# Old
if state == State.IDLE:

# New
if state_machine.is_in_state(&"Idle"):
```

### Issue: Animation not playing
**Cause:** Animation name mismatch
**Solution:** Check `attack_animations` array in stats resource matches AnimationPlayer track names

### Issue: AI not working
**Cause:** Player reference not set
**Solution:** Call `enemy.set_player(player_node)` after instantiation

### Issue: Damage not registering
**Cause:** DamageReceiver/DamageEmitter scripts not updated
**Solution:** Ensure both use new scripts and collision layers are correct

---

## 6. Testing Checklist

### Player Testing
- [ ] Movement (WASD/arrows) works
- [ ] Attack combo (punch → punch_alt → kick → roundkick) cycles
- [ ] Jump works
- [ ] Jump attack works
- [ ] Backdash (double-tap) works
- [ ] Taking damage shows hurt animation
- [ ] Health bar updates
- [ ] Death triggers beaten state

### Sharaka Testing
- [ ] Chases player when in range
- [ ] Attacks when close enough
- [ ] Takes damage and shows hurt
- [ ] Dies and frees enemy slot
- [ ] Multiple Sharakas respect slot system

### Kaluga Testing
- [ ] Follows player
- [ ] Attacks with raycast aim
- [ ] Only takes damage when stunned
- [ ] Kick sends into fly state with recovery
- [ ] Gas stun works
- [ ] Death triggers fly → beaten

---

## 7. Files Safe to Delete (After Migration)

Once all scenes are migrated and tested:

```
# Old Character Scripts
Scenes/Scene2_3/Characters/character.gd
Scenes/Scene2_3/Characters/player.gd
Scenes/Scene2_3/Characters/sharaka.gd
Scenes/Scene2_5/scenes/characters/character2.gd
Scenes/Scene2_5/scenes/characters/player2.gd
Scenes/Scene2_5/scenes/characters/kaluga.gd

# Old Damage System
Scenes/Scene2_3/Colliders/damage_receiver.gd
Scenes/Scene2_5/scenes/colliders/damage_receiver2.gd
```

**Do NOT delete until fully tested!**

---

---

## 4. Additional Characters (Scene2_5)

### 4.1 Player2 Migration

**File:** `Scenes/Scene2_5/scenes/characters/player2.tscn`

If this scene is still used, follow the same steps as the Player migration (Section 1).
The `PlayerCharacter.gd` script is designed to work for both Scene2_3 and Scene2_5.

**Key difference:** Scene2_5 may have slightly different animations. Verify animation names match.

### 4.2 BossEnemy Decision

**File:** `Scenes/Scene2_5/scenes/characters/boss_enemy.gd`

This appears to be an older/simpler boss implementation that extends `Character2`.
It has different logic than `kaluga.gd` (simpler movement, direct raycast attacks).

**Options:**
1. **Delete** - If `kaluga.gd`/`KalugaCharacter` is the canonical boss
2. **Migrate** - If this is used in other scenes, create `BossEnemyCharacter.gd` following the Kaluga pattern
3. **Keep temporarily** - Leave as-is until you determine which scenes use it

**To check usage:** Search for "boss_enemy" or "BossEnemy" in your scene files.

---

## Quick Reference: New File Locations

| Purpose | Path |
|---------|------|
| Base Character | `Core/Characters/BaseCharacter.gd` |
| State Machine | `Core/Characters/CharacterStateMachine.gd` |
| Player | `Scenes/Characters/PlayerCharacter.gd` |
| Sharaka | `Scenes/Characters/SharakaCharacter.gd` |
| Kaluga | `Scenes/Characters/KalugaCharacter.gd` |
| Player Config | `Resources/Characters/player_config.tres` |
| Sharaka Config | `Resources/Characters/sharaka_config.tres` |
| Kaluga Config | `Resources/Characters/kaluga_config.tres` |
| Damage Receiver | `Core/Combat/DamageReceiver.gd` |
| Damage Emitter | `Core/Combat/DamageEmitter.gd` |
| Health Component | `Core/Components/HealthComponent.gd` |
| AI Controller | `Core/AI/AIController.gd` |
| Player Input | `Core/Input/PlayerInputHandler.gd` |

---

## Migration Order Recommendation

1. **Start with Player** - Most critical, affects all combat scenes
2. **Then Sharaka** - Test basic enemy AI works with new player
3. **Then Kaluga** - Boss with more complex mechanics
4. **Finally main scenes** - Update instantiation and signal connections

Test each character individually before moving to the next.
