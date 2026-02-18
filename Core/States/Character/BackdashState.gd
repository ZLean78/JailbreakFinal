## Backdash state - quick evasive movement backwards.
## Triggered by double-tap input (player only).
## Briefly invincible during the dash.
class_name BackdashState
extends State


## Speed of the backdash movement.
var backdash_speed: float = 300.0

## Duration of the backdash.
var backdash_duration: float = 0.3

## Time elapsed since entering backdash.
var elapsed_time: float = 0.0

## Direction of the backdash (opposite of facing).
var dash_direction: Vector2 = Vector2.LEFT


func get_state_name() -> StringName:
	return &"Backdash"


func get_animation_name() -> String:
	return "backdash"


func enter() -> void:
	elapsed_time = 0.0
	# Direction is set by the character before transition


func physics_update(delta: float) -> void:
	elapsed_time += delta

	# Apply backdash velocity
	character.velocity = dash_direction * backdash_speed

	if elapsed_time >= backdash_duration:
		request_transition(&"Idle")


func can_transition_to(target_state: StringName) -> bool:
	var allowed := [
		&"Idle",   # Dash complete
		&"Hurt",   # Hit (if not invincible)
		&"Fall",   # Knocked down
		&"Beaten", # Defeated
	]
	return target_state in allowed
