## Prep Attack state - enemy is preparing to attack.
## Brief pause before executing the attack.
## Used by AI to telegraph attacks to the player.
class_name PrepAttackState
extends State


## Duration of the preparation before attacking.
var prep_duration: float = 0.3

## Time elapsed since entering prep state.
var elapsed_time: float = 0.0


func get_state_name() -> StringName:
	return &"PrepAttack"


func get_animation_name() -> String:
	return "idle"  # Uses idle animation during prep


func enter() -> void:
	elapsed_time = 0.0
	character.velocity = Vector2.ZERO


func update(delta: float) -> void:
	elapsed_time += delta

	# AI controller will check elapsed_time and trigger attack


func can_transition_to(target_state: StringName) -> bool:
	var allowed := [
		&"Attack",   # Execute the attack
		&"Takeoff",  # Jump attack
		&"Idle",     # Cancelled
		&"Hurt",     # Interrupted
		&"Fall",     # Knocked down
		&"Fly",      # Launched
		&"Beaten",   # Defeated
	]
	return target_state in allowed
