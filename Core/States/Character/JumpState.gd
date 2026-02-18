## Jump state - character is in the air from a jump.
## Physics height simulation is handled by the character.
## Transitions to Land when height reaches zero.
class_name JumpState
extends State

func enter() -> void:
	# Ensure jump actually lifts off even if takeoff callbacks didn't set height_speed.
	if character.height <= 0.0 and is_equal_approx(character.height_speed, 0.0):
		var jump_intensity: float = 300.0
		if character.config and character.config.stats:
			jump_intensity = character.config.stats.jump_intensity
		character.height_speed = jump_intensity


func get_state_name() -> StringName:
	return &"Jump"


func get_animation_name() -> String:
	return "jump"


func can_transition_to(target_state: StringName) -> bool:
	var allowed := [
		&"Land",        # Landed normally
		&"JumpAttack",  # Attack during jump
		&"Fall",        # Knocked down mid-air
		&"Fly",         # Launched
		&"Hurt",        # Hit mid-air
		&"Beaten",      # Defeated
	]
	return target_state in allowed
