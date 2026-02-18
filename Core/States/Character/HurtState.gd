## Hurt state - character is reacting to taking damage.
## Plays hurt animation and applies knockback velocity.
## Has a duration before returning to Idle.
class_name HurtState
extends State


## Duration of the hurt state in seconds.
var hurt_duration: float = 0.5

## Time elapsed since entering hurt state.
var elapsed_time: float = 0.0


func get_state_name() -> StringName:
	return &"Hurt"


func get_animation_name() -> String:
	return "hurt"


func enter() -> void:
	elapsed_time = 0.0
	# Knockback velocity should already be set by damage handler


func exit() -> void:
	# Hurt state can end via timer-based transition, which may interrupt the hurt animation.
	# Always unlock heading here so the character can't "moonwalk" when control returns.
	if character is BaseCharacter:
		(character as BaseCharacter).heading_locked = false


func physics_update(delta: float) -> void:
	elapsed_time += delta

	# Apply friction to knockback
	character.velocity = character.velocity.lerp(Vector2.ZERO, 0.1)

	# Transition out after duration
	if elapsed_time >= hurt_duration:
		request_transition(&"Idle")


func can_transition_to(target_state: StringName) -> bool:
	# Hurt can be interrupted by stronger states
	var allowed := [
		&"Idle",     # Recovery complete
		&"Fall",     # Knocked down
		&"Fly",      # Launched
		&"Grounded", # Hit the ground
		&"Beaten",   # Defeated
		&"Stunned",  # Stunned
	]
	return target_state in allowed
