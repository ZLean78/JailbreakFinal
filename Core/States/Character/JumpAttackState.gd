## Jump Attack state - attacking while airborne.
## Applies horizontal movement in facing direction during attack.
## Transitions to Land when height reaches zero.
class_name JumpAttackState
extends State


func get_state_name() -> StringName:
	return &"JumpAttack"


func get_animation_name() -> String:
	return "jump_attack"


func can_transition_to(target_state: StringName) -> bool:
	var allowed := [
		&"Land",    # Landed
		&"Fall",    # Knocked down
		&"Fly",     # Launched
		&"Beaten",  # Defeated
		&"Grounded", # Hit ground after knockdown
	]
	return target_state in allowed
