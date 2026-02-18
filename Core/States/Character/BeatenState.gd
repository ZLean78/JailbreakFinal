## Beaten state - character has been defeated.
## Fades out and removes the character from the scene.
## Final state with no transitions out (unless respawning).
class_name BeatenState
extends State


## Rate at which the character fades out (alpha per second).
var fade_rate: float = 0.5


func get_state_name() -> StringName:
	return &"Beaten"


func get_animation_name() -> String:
	return "grounded"  # Uses grounded animation while fading


func enter() -> void:
	character.velocity = Vector2.ZERO


func update(delta: float) -> void:
	# Fade out the character
	character.modulate.a -= fade_rate * delta

	if character.modulate.a <= 0:
		character.queue_free()


func can_transition_to(target_state: StringName) -> bool:
	# Beaten is a final state - only respawn can exit
	return target_state == &"Respawn"
