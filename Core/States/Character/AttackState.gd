## Attack state - character is performing an attack.
## Animation is determined by CombatComponent's current combo attack.
## Exits when animation completes via on_action_complete callback.
class_name AttackState
extends State


## The attack animation to play, set before entering state.
var current_attack_animation: String = "punch"


func get_state_name() -> StringName:
	return &"Attack"


func get_animation_name() -> String:
	return current_attack_animation


func enter() -> void:
	# Stop movement during attack
	character.velocity = Vector2.ZERO


func can_transition_to(target_state: StringName) -> bool:
	# Attack can only be interrupted by damage or forced transitions
	var allowed := [
		&"Idle",          # Animation complete
		&"AttackComplete", # Post-attack state
		&"Hurt",          # Interrupted by damage
		&"Fall",          # Knocked down
		&"Fly",           # Launched
		&"Stunned",       # Stunned
		&"Beaten",        # Defeated
	]
	return target_state in allowed
