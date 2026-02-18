## Walk state - character is moving horizontally.
## Transitions to Idle when velocity becomes zero.
class_name WalkState
extends State


func get_state_name() -> StringName:
	return &"Walk"


func get_animation_name() -> String:
	return "walk"


func physics_update(_delta: float) -> void:
	# Transition to idle if stopped
	if character.velocity.length() == 0:
		request_transition(&"Idle")


func can_transition_to(target_state: StringName) -> bool:
	# Walk can transition to same states as Idle
	var allowed := [
		&"Idle",
		&"Attack",
		&"Jump",
		&"Takeoff",
		&"Hurt",
		&"Fall",
		&"Fly",
		&"Stunned",
		&"Beaten",
		&"Backdash",
		&"PrepAttack",
	]
	return target_state in allowed
