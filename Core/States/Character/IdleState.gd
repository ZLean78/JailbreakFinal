## Idle state - character is standing still, ready for action.
## This is the default resting state that most actions return to.
class_name IdleState
extends State


func get_state_name() -> StringName:
	return &"Idle"


func get_animation_name() -> String:
	return "idle"


func enter() -> void:
	character.velocity = Vector2.ZERO


func physics_update(_delta: float) -> void:
	# Transition to walk if moving
	if character.velocity.length() > 0:
		request_transition(&"Walk")


func can_transition_to(target_state: StringName) -> bool:
	# Idle can transition to most active states
	var allowed := [
		&"Walk",
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
