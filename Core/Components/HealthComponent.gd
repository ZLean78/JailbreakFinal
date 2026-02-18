## Component that manages character health.
## Handles damage, healing, death detection, and health bar updates.
##
## Follows Single Responsibility Principle - only manages health-related logic.
##
## Usage:
##     @onready var health: HealthComponent = $HealthComponent
##
##     func _ready() -> void:
##         health.health_depleted.connect(_on_death)
##
##     func _on_damage_received(data: DamageData, dir: Vector2, src: Node) -> void:
##         health.take_damage(data.amount)
class_name HealthComponent
extends Node


## Emitted when health value changes.
signal health_changed(old_value: int, new_value: int)

## Emitted when damage is taken (after health_changed).
signal damage_taken(amount: int)

## Emitted when healed (after health_changed).
signal healed(amount: int)

## Emitted when health reaches zero.
signal health_depleted


## Maximum health value.
@export var max_health: int = 100

## Starting health value (defaults to max_health if 0).
@export var starting_health: int = 0

## Optional ProgressBar to update with health changes.
@export var health_bar: ProgressBar


## Current health value.
var current_health: int = 0


func _ready() -> void:
	reset()


## Resets health to starting value and updates health bar.
func reset() -> void:
	var starting := starting_health if starting_health > 0 else max_health
	current_health = starting

	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = current_health


## Applies damage, clamping to [0, max_health].
## Returns the actual damage dealt after clamping.
func take_damage(amount: int) -> int:
	if amount <= 0:
		return 0

	var old_health := current_health
	current_health = clampi(current_health - amount, 0, max_health)
	var actual_damage := old_health - current_health

	if actual_damage > 0:
		health_changed.emit(old_health, current_health)
		damage_taken.emit(actual_damage)
		_update_health_bar()

		if current_health <= 0:
			health_depleted.emit()

	return actual_damage


## Heals the character, clamping to max_health.
## Returns the actual amount healed after clamping.
func heal(amount: int) -> int:
	if amount <= 0:
		return 0

	var old_health := current_health
	current_health = clampi(current_health + amount, 0, max_health)
	var actual_heal := current_health - old_health

	if actual_heal > 0:
		health_changed.emit(old_health, current_health)
		healed.emit(actual_heal)
		_update_health_bar()

	return actual_heal


## Sets health to a specific value.
func set_health(value: int) -> void:
	var old_health := current_health
	current_health = clampi(value, 0, max_health)

	if old_health != current_health:
		health_changed.emit(old_health, current_health)
		_update_health_bar()

		if current_health <= 0:
			health_depleted.emit()


## Returns health as a percentage (0.0 to 1.0).
func get_health_percentage() -> float:
	if max_health <= 0:
		return 0.0
	return float(current_health) / float(max_health)


## Returns whether the character is alive (health > 0).
func is_alive() -> bool:
	return current_health > 0


## Returns whether the character is at full health.
func is_full_health() -> bool:
	return current_health >= max_health


## Updates the health bar if one is assigned.
func _update_health_bar() -> void:
	if health_bar:
		health_bar.value = current_health
