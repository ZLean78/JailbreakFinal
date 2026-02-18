## Land state - brief landing recovery after a jump.
## Transitions to Idle when animation completes.
class_name LandState
extends State


func get_state_name() -> StringName:
	return &"Land"


func get_animation_name() -> String:
	return "land"


func enter() -> void:
	character.velocity = Vector2.ZERO


func can_transition_to(target_state: StringName) -> bool:
	var allowed := [
		&"Idle",   # Recovery complete
		&"Walk",   # Recovery complete with movement
		&"Hurt",   # Interrupted by damage
		&"Fall",   # Knocked down
		&"Fly",    # Launched
		&"Beaten", # Defeated
	]
	return target_state in allowed
