## Component that manages combat and attack combos.
## Handles combo progression, attack timing, and damage creation.
##
## Follows Single Responsibility Principle - only manages combat-related logic.
##
## Usage:
##     @onready var combat: CombatComponent = $CombatComponent
##
##     func try_attack() -> void:
##         if combat.can_start_attack():
##             var attack_name := combat.start_attack()
##             state_machine.transition_to(&"Attack")
class_name CombatComponent
extends Node


## Emitted when an attack starts.
signal attack_started(attack_name: String, combo_index: int)

## Emitted when an attack successfully hits a target.
signal attack_hit(target: Node)

## Emitted when the combo advances.
signal combo_advanced(new_index: int)

## Emitted when the combo resets.
signal combo_reset


## Array of attack animation names for the combo sequence.
@export var attack_animations: Array[String] = ["punch"]

## Base damage for normal attacks.
@export var base_damage: int = 10

## Damage for power attacks (final combo hit).
@export var power_damage: int = 20

## Time window to continue combo after a hit (seconds).
@export var combo_window: float = 0.5

## Knockback force for normal hits.
@export var knockback_force: float = 150.0

## Knockdown force for jump attacks.
@export var knockdown_force: float = 250.0

## Flight speed for power hits.
@export var flight_speed: float = 200.0


## Current position in the combo sequence.
var current_combo_index: int = 0

## Whether the last attack hit successfully.
var last_hit_successful: bool = false

## Whether currently in an attack.
var is_attacking: bool = false

## Whether an attack is queued (input buffering).
var attack_queued: bool = false

## Timer for combo window.
var _combo_timer: float = 0.0


func _process(delta: float) -> void:
	if _combo_timer > 0:
		_combo_timer -= delta
		if _combo_timer <= 0:
			_reset_combo()


## Returns whether an attack can be started.
func can_start_attack() -> bool:
	return not is_attacking


## Queues an attack to execute when current attack finishes.
func queue_attack() -> void:
	if is_attacking:
		attack_queued = true


## Returns whether an attack is queued.
func has_queued_attack() -> bool:
	return attack_queued


## Starts an attack and returns the animation name to play.
func start_attack() -> String:
	is_attacking = true
	attack_queued = false  # Clear queue when attack starts

	# Advance combo if within window and last hit was successful
	if last_hit_successful and _combo_timer > 0:
		current_combo_index = (current_combo_index + 1) % attack_animations.size()
		combo_advanced.emit(current_combo_index)
	else:
		current_combo_index = 0

	_combo_timer = combo_window
	last_hit_successful = false

	var attack_name := get_current_attack_animation()
	attack_started.emit(attack_name, current_combo_index)

	return attack_name


## Called when the attack animation finishes.
func finish_attack() -> void:
	is_attacking = false


## Called when the attack hits a target.
func on_hit(target: Node) -> void:
	last_hit_successful = true
	_combo_timer = combo_window
	attack_hit.emit(target)


## Returns the current attack animation name.
func get_current_attack_animation() -> String:
	if current_combo_index < attack_animations.size():
		return attack_animations[current_combo_index]
	return "punch"


## Returns whether currently on the final combo attack.
func is_final_combo_attack() -> bool:
	return current_combo_index == attack_animations.size() - 1


## Creates damage data for the current attack.
func create_damage_data(is_jump_attack: bool = false) -> DamageData:
	var data := DamageData.new()

	if is_jump_attack:
		data.amount = base_damage
		data.type = DamageTypes.Type.KNOCKDOWN
		data.knockback_force = knockback_force
		data.knockdown_force = knockdown_force
	elif is_final_combo_attack():
		data.amount = power_damage
		data.type = DamageTypes.Type.POWER
		data.flight_speed = flight_speed
	else:
		data.amount = base_damage
		data.type = DamageTypes.Type.NORMAL
		data.knockback_force = knockback_force

	return data


## Returns the current damage amount.
func get_current_damage() -> int:
	if is_final_combo_attack():
		return power_damage
	return base_damage


## Resets the combo to the beginning.
func _reset_combo() -> void:
	if current_combo_index != 0:
		current_combo_index = 0
		combo_reset.emit()
	last_hit_successful = false
	_combo_timer = 0.0


## Forces a combo reset (call when interrupted).
func force_reset() -> void:
	_reset_combo()
	is_attacking = false
	attack_queued = false
