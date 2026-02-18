## AI strategy for basic melee enemies like Sharaka.
## Behavior: Chase target, prep attack when in range, then attack.
## Supports enemy slot system for coordinated attacks.
class_name BasicMeleeStrategy
extends AIStrategy


## Distance at which to attack.
var attack_distance: float = 50.0

## Distance at which to start the attack prep/wind-up.
## Defaults to attack_distance (no behavior change) but can be larger for enemies
## that should "commit" earlier and use jump attacks if the player keeps distance.
var prep_start_distance: float = 50.0

## If true, when prep finishes but we're out of range, use a jump attack.
## If false, cancel the attack and keep chasing until close.
var allow_jump_attack: bool = true

## Maximum distance to allow a jump attack when prep finishes.
## Prevents ridiculous long-range jump attacks.
var jump_attack_max_distance: float = 120.0

## If true, keep walking closer during the "prep" wind-up when out of range.
## This prevents enemies from "prepping" too early and attacking from far away.
var approach_during_prep: bool = true

## If true, randomly choose between standing and jump attacks.
## This is useful for enemies like Sharaka to vary patterns.
var randomize_attack_choice: bool = false

## Probability of choosing a jump attack when randomizing (0..1).
var jump_attack_probability: float = 0.5

## If true, prefer jump attack when the target is airborne,
## and standing attack when the target is grounded.
var jump_attack_when_target_airborne: bool = false

## If false, do not change facing direction while the character is airborne.
## Prevents mid-air flip_x changes for enemies like Sharaka.
var face_target_when_airborne: bool = true

## Cooldown between attacks (seconds).
var attack_cooldown: float = 1.5

## Duration of attack preparation.
var prep_duration: float = 0.3


## Time since last attack.
var _cooldown_timer: float = 0.0

## Time spent preparing attack.
var _prep_timer: float = 0.0

## Whether currently preparing to attack.
var _is_prepping: bool = false

## Planned attack type for the current prep.
var _planned_attack_is_jump: bool = false

## Enemy slot reference (for coordinated attacks).
var _slot: Node2D = null

## Reference to player for slot system.
var _player_with_slots: Node = null

## Preferred side when reserving an enemy slot around the player.
## -1 = left, 0 = no preference (default), 1 = right
var preferred_slot_side: int = 0

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func initialize(p_character: BaseCharacter) -> void:
	super.initialize(p_character)
	_rng.randomize()


func update(delta: float) -> void:
	# Update cooldown
	if _cooldown_timer > 0:
		_cooldown_timer -= delta

	if not has_valid_target():
		stop_movement()
		return

	if face_target_when_airborne or not character.state_machine.is_airborne():
		face_target()

	# Get slot position if using slot system
	var target_position := _get_target_position()
	var distance := character.global_position.distance_to(target_position)

	# State machine
	if _is_prepping:
		_handle_prep_attack(delta, distance, target_position)
	elif _can_attack() and distance <= prep_start_distance:
		_start_prep_attack()
	else:
		_chase_target(target_position)


## Gets the position to move toward (slot or direct).
func _get_target_position() -> Vector2:
	if _slot and is_instance_valid(_slot):
		return _slot.global_position
	return target.global_position


## Chases toward the target position.
func _chase_target(target_pos: Vector2) -> void:
	# Only move when the character is allowed to move (Idle/Walk).
	# This prevents "sliding" during AttackComplete/PrepAttack and ensures walk animation plays when moving.
	if not character.state_machine.can_move():
		stop_movement()
		return

	var direction := (target_pos - character.global_position).normalized()
	character.movement_component.set_input_direction(direction)
	# Let BaseCharacter + MovementComponent drive velocity and state transitions (Idle/Walk).


## Starts attack preparation.
func _start_prep_attack() -> void:
	_is_prepping = true
	_prep_timer = 0.0
	_planned_attack_is_jump = false
	if jump_attack_when_target_airborne and allow_jump_attack and has_valid_target() and target.state_machine.is_airborne():
		_planned_attack_is_jump = true
	elif randomize_attack_choice and allow_jump_attack:
		var p := clampf(jump_attack_probability, 0.0, 1.0)
		_planned_attack_is_jump = _rng.randf() < p
	# When approach_during_prep is enabled, preserve chase velocity so the enemy
	# doesn't stall at the prep boundary. Otherwise stop immediately.
	if not approach_during_prep:
		stop_movement()
	character.state_machine.transition_to(&"PrepAttack")


## Handles attack preparation phase.
func _handle_prep_attack(delta: float, distance: float, target_pos: Vector2) -> void:
	_prep_timer += delta
	# If the target drifts away during prep, keep closing the gap instead of freezing.
	# For planned jump attacks, don't approach: keep the spacing so the flying kick makes sense.
	if approach_during_prep and distance > attack_distance and not _planned_attack_is_jump:
		_chase_target(target_pos)
	else:
		stop_movement()

	if _prep_timer >= prep_duration:
		_is_prepping = false
		var target_airborne := allow_jump_attack and has_valid_target() and target.state_machine.is_airborne()
		var can_use_jump := allow_jump_attack and distance <= jump_attack_max_distance
		if jump_attack_when_target_airborne:
			can_use_jump = can_use_jump and target_airborne

		if _planned_attack_is_jump:
			if can_use_jump:
				_execute_jump_attack()
			elif distance <= attack_distance:
				_execute_attack()
			else:
				_cancel_attack_prep()
		else:
			if distance <= attack_distance:
				_execute_attack()
			elif can_use_jump:
				_execute_jump_attack()
			else:
				_cancel_attack_prep()


func _cancel_attack_prep() -> void:
	stop_movement()
	# Small cooldown prevents rapid prep-cancel cycling when the target
	# hovers just outside attack_distance (e.g. after a slot switch).
	_cooldown_timer = prep_duration
	# Ensure the character can move again next frame.
	if character and character.state_machine and character.state_machine.is_in_state(&"PrepAttack"):
		character.state_machine.transition_to(&"Idle")


## Executes a melee attack.
func _execute_attack() -> void:
	if try_attack():
		_cooldown_timer = attack_cooldown


## Executes a jump attack.
func _execute_jump_attack() -> void:
	if try_jump():
		_cooldown_timer = attack_cooldown


## Returns whether an attack can be executed.
func _can_attack() -> bool:
	if _cooldown_timer > 0:
		return false
	return character.state_machine.can_attack()


## Reserves a slot from the player's slot system.
func reserve_slot(player: Node) -> void:
	_player_with_slots = player
	if player.has_method("reserve_slot_preferred"):
		_slot = player.reserve_slot_preferred(character, preferred_slot_side)
	elif player.has_method("reserve_slot"):
		_slot = player.reserve_slot(character)


## Frees the currently held slot.
func free_slot() -> void:
	if _player_with_slots and _player_with_slots.has_method("free_slot"):
		_player_with_slots.free_slot(character)
	_slot = null
