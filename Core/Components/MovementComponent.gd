## Component that manages character movement and physics.
## Handles velocity, knockback, and movement direction.
##
## Follows Single Responsibility Principle - only manages movement-related logic.
##
## Usage:
##     @onready var movement: MovementComponent = $MovementComponent
##
##     func _physics_process(delta: float) -> void:
##         var input_dir := Input.get_vector("left", "right", "up", "down")
##         movement.set_input_direction(input_dir)
##         movement.apply_movement(delta)
class_name MovementComponent
extends Node


## The CharacterBody2D this component controls.
## Set automatically if parent is CharacterBody2D.
@export var character: CharacterBody2D

## Base movement speed.
@export var speed: float = 100.0

## Acceleration rate (higher = snappier movement).
@export var acceleration: float = 10.0

## Friction/deceleration rate.
@export var friction: float = 10.0


## Current input/desired movement direction.
var input_direction: Vector2 = Vector2.ZERO

## The direction the character is facing (for attacks/sprites).
var facing_direction: Vector2 = Vector2.RIGHT

## Whether facing direction updates are locked (during attacks, etc).
var facing_locked: bool = false


func _ready() -> void:
	if character == null:
		character = get_parent() as CharacterBody2D
		if character == null:
			push_error("MovementComponent: No CharacterBody2D found. Set 'character' export or add as child of CharacterBody2D.")


## Sets the desired movement direction from input.
func set_input_direction(direction: Vector2) -> void:
	input_direction = direction.normalized() if direction.length() > 0 else Vector2.ZERO

	# Update facing direction if not locked
	if not facing_locked and input_direction.length() > 0:
		if input_direction.x > 0:
			facing_direction = Vector2.RIGHT
		elif input_direction.x < 0:
			facing_direction = Vector2.LEFT


## Applies movement physics based on input direction.
## Call this in _physics_process.
func apply_movement(delta: float) -> void:
	if character == null:
		return

	var target_velocity := input_direction * speed

	if input_direction.length() > 0:
		# Accelerate toward target velocity
		character.velocity = character.velocity.lerp(target_velocity, acceleration * delta)
	else:
		# Apply friction when no input
		character.velocity = character.velocity.lerp(Vector2.ZERO, friction * delta)

		# Snap to zero if very small
		if character.velocity.length() < 1.0:
			character.velocity = Vector2.ZERO


## Applies an immediate knockback velocity.
func apply_knockback(direction: Vector2, force: float) -> void:
	if character == null:
		return

	character.velocity = direction.normalized() * force


## Stops all movement immediately.
func stop() -> void:
	if character:
		character.velocity = Vector2.ZERO
	input_direction = Vector2.ZERO


## Sets the facing direction directly.
func set_facing(direction: Vector2) -> void:
	if direction.x > 0:
		facing_direction = Vector2.RIGHT
	elif direction.x < 0:
		facing_direction = Vector2.LEFT


## Locks facing direction updates (for attacks, etc).
func lock_facing() -> void:
	facing_locked = true


## Unlocks facing direction updates.
func unlock_facing() -> void:
	facing_locked = false


## Returns whether the character is currently moving.
func is_moving() -> bool:
	return character and character.velocity.length() > 1.0


## Returns whether there is input being applied.
func has_input() -> bool:
	return input_direction.length() > 0
