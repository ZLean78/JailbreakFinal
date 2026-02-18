## Fly state - character has been launched by a power attack.
## Similar to Fall but triggered by power hits and may have different recovery.
## Transitions to Idle (player) or Beaten (enemy) when landing.
class_name FlyState
extends State


func get_state_name() -> StringName:
	return &"Fly"


func get_animation_name() -> String:
	return "fly"


func can_transition_to(target_state: StringName) -> bool:
	var allowed := [
		&"Idle",      # Player recovery
		&"Grounded",  # Hit the ground (will evaluate health)
		&"Beaten",    # Enemy defeated
		&"Fall",      # Wall bounce converts to fall
	]
	return target_state in allowed
