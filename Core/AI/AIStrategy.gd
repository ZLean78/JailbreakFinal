## Base class for AI behavior strategies.
## Implements the Strategy pattern for pluggable enemy behaviors.
##
## Usage:
##     class_name AggressiveStrategy
##     extends AIStrategy
##
##     func update(delta: float) -> void:
##         if has_valid_target():
##             chase_and_attack()
class_name AIStrategy
extends RefCounted


## The character controlled by this AI.
var character: BaseCharacter

## The current target (usually the player).
var target: BaseCharacter


## Initializes the strategy with a character reference.
func initialize(p_character: BaseCharacter) -> void:
	character = p_character


## Sets the target to pursue/attack.
func set_target(p_target: BaseCharacter) -> void:
	target = p_target


## Called every frame to update AI behavior.
## Must be overridden by subclasses.
func update(_delta: float) -> void:
	assert(false, "update must be overridden")


## Returns whether there is a valid target.
func has_valid_target() -> bool:
	if not is_instance_valid(target):
		return false
	if not target.is_alive():
		return false
	return true


## Returns the distance to the target.
func get_distance_to_target() -> float:
	if not has_valid_target():
		return INF
	return character.global_position.distance_to(target.global_position)


## Returns the direction to the target.
func get_direction_to_target() -> Vector2:
	if not has_valid_target():
		return Vector2.ZERO
	return (target.global_position - character.global_position).normalized()


## Moves toward the target.
func move_toward_target() -> void:
	if not has_valid_target():
		return

	var direction := get_direction_to_target()
	character.movement_component.set_input_direction(direction)
	character.velocity = direction * character.movement_component.speed


## Stops movement.
func stop_movement() -> void:
	character.movement_component.set_input_direction(Vector2.ZERO)
	character.velocity = Vector2.ZERO


## Attempts to attack.
func try_attack() -> bool:
	return character.try_attack()


## Attempts to jump.
func try_jump() -> bool:
	return character.try_jump()


## Updates heading to face the target.
func face_target() -> void:
	if not has_valid_target():
		return

	if target.global_position.x < character.global_position.x:
		character.heading = Vector2.LEFT
	else:
		character.heading = Vector2.RIGHT
