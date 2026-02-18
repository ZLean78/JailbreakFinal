## Stunned state - character cannot act for a duration.
## Used for effects like gas stun on Kaluga.
## Character is vulnerable to attacks while stunned.
class_name StunnedState
extends State


## Duration of the stun effect.
var stun_duration: float = 1.0

## Time elapsed since entering stunned state.
var elapsed_time: float = 0.0


func get_state_name() -> StringName:
	return &"Stunned"


func get_animation_name() -> String:
	return "stunned"


func enter() -> void:
	elapsed_time = 0.0
	character.velocity = Vector2.ZERO


func update(delta: float) -> void:
	elapsed_time += delta

	if elapsed_time >= stun_duration:
		request_transition(&"Idle")


func can_transition_to(target_state: StringName) -> bool:
	var allowed := [
		&"Idle",    # Stun wore off
		&"Hurt",    # Hit while stunned
		&"Fall",    # Knocked down
		&"Fly",     # Launched
		&"Beaten",  # Defeated
	]
	return target_state in allowed
