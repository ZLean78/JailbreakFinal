## Fly Attack state - attacking while flying/charging.
## Used by bosses like Kaluga for charge attacks.
## Transitions to Idle when landing or attack completes.
class_name FlyAttackState
extends State


func get_state_name() -> StringName:
	return &"FlyAttack"


func get_animation_name() -> String:
	return "attack"


func can_transition_to(target_state: StringName) -> bool:
	var allowed := [
		&"Idle",   # Attack complete
		&"Hurt",   # Interrupted
		&"Stunned", # Stunned during attack
		&"Beaten", # Defeated
	]
	return target_state in allowed
