## Grounded state - character is lying on the ground after knockdown.
## Has a duration before transitioning to Land (recovery) or Beaten (death).
class_name GroundedState
extends State


## Duration to stay grounded before recovery/death.
var grounded_duration: float = 0.5

## Time elapsed since entering grounded state.
var elapsed_time: float = 0.0


func get_state_name() -> StringName:
	return &"Grounded"


func get_animation_name() -> String:
	return "grounded"


func enter() -> void:
	elapsed_time = 0.0
	character.velocity = Vector2.ZERO


func update(delta: float) -> void:
	elapsed_time += delta

	if elapsed_time >= grounded_duration:
		# Character will check health and transition appropriately
		# This is handled by the character/state machine
		pass


func can_transition_to(target_state: StringName) -> bool:
	var allowed := [
		&"Land",    # Recovery (if health > 0)
		&"Beaten",  # Death (if health <= 0)
		&"Idle",    # Direct recovery
	]
	return target_state in allowed
