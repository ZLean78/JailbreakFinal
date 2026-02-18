## Attack Complete state - brief recovery after an attack.
## Allows for combo window timing before returning to idle.
class_name AttackCompleteState
extends State


## Duration of the attack recovery.
var recovery_duration: float = 0.15

## Time elapsed since entering recovery.
var elapsed_time: float = 0.0


func get_state_name() -> StringName:
	return &"AttackComplete"


func get_animation_name() -> String:
	return "attack_complete"


func enter() -> void:
	elapsed_time = 0.0


func update(delta: float) -> void:
	elapsed_time += delta

	if elapsed_time >= recovery_duration:
		request_transition(&"Idle")


func can_transition_to(target_state: StringName) -> bool:
	var allowed := [
		&"Idle",    # Recovery complete
		&"Attack",  # Combo continuation
		&"Hurt",    # Interrupted
		&"Fall",    # Knocked down
		&"Fly",     # Launched
		&"Beaten",  # Defeated
	]
	return target_state in allowed
