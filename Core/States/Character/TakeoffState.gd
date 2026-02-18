## Takeoff state - preparation animation before jumping.
## Transitions to Jump state when animation completes via callback.
class_name TakeoffState
extends State

## Failsafe timer so enemies don't get stuck in takeoff if an animation callback is missing.
var elapsed_time: float = 0.0
var max_takeoff_time: float = 0.35


func get_state_name() -> StringName:
	return &"Takeoff"


func get_animation_name() -> String:
	return "takeoff"


func enter() -> void:
	elapsed_time = 0.0
	character.velocity = Vector2.ZERO


func update(delta: float) -> void:
	elapsed_time += delta
	# If takeoff animation callbacks don't fire, force completion.
	if elapsed_time >= max_takeoff_time:
		if character and character.has_method("on_takoff_complete"):
			character.on_takoff_complete()


func can_transition_to(target_state: StringName) -> bool:
	# Takeoff transitions to Jump when animation completes
	var allowed := [
		&"Jump",   # Animation complete
		&"Hurt",   # Interrupted by damage
		&"Fall",   # Knocked down
		&"Fly",    # Launched
		&"Beaten", # Defeated
	]
	return target_state in allowed
