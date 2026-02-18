## Fall state - character has been knocked down and is falling.
## Applies knockdown physics (upward then downward trajectory).
## Transitions to Grounded when height reaches zero.
class_name FallState
extends State

func enter() -> void:
	# Ensure knockdown has lift even if damage didn't specify a knockdown force.
	if character.height <= 0.0 and is_equal_approx(character.height_speed, 0.0):
		var knockdown_intensity: float = 250.0
		if character.config and character.config.stats:
			knockdown_intensity = character.config.stats.knockdown_intensity
		character.height_speed = knockdown_intensity


func get_state_name() -> StringName:
	return &"Fall"


func get_animation_name() -> String:
	return "fly"  # Uses fly animation for falling


func can_transition_to(target_state: StringName) -> bool:
	# Fall ends when hitting ground
	var allowed := [
		&"Grounded",  # Hit the ground
		&"Beaten",    # Defeated
	]
	return target_state in allowed
