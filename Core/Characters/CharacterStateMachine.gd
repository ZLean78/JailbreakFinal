## State machine specialized for character states.
## Pre-registers all character states and provides character-specific helpers.
##
## Usage:
##     var state_machine := CharacterStateMachine.new()
##     add_child(state_machine)
##     state_machine.initialize(self)
##     state_machine.start(&"Idle")
class_name CharacterStateMachine
extends StateMachine


## Reference to states for direct access.
var idle_state: IdleState
var walk_state: WalkState
var attack_state: AttackState
var hurt_state: HurtState
var jump_state: JumpState
var jump_attack_state: JumpAttackState
var takeoff_state: TakeoffState
var land_state: LandState
var fall_state: FallState
var fly_state: FlyState
var fly_attack_state: FlyAttackState
var grounded_state: GroundedState
var beaten_state: BeatenState
var stunned_state: StunnedState
var backdash_state: BackdashState
var prep_attack_state: PrepAttackState
var attack_complete_state: AttackCompleteState


func _init() -> void:
	_create_and_register_states()


## Creates and registers all character states.
func _create_and_register_states() -> void:
	idle_state = IdleState.new()
	register_state(&"Idle", idle_state)

	walk_state = WalkState.new()
	register_state(&"Walk", walk_state)

	attack_state = AttackState.new()
	register_state(&"Attack", attack_state)

	hurt_state = HurtState.new()
	register_state(&"Hurt", hurt_state)

	jump_state = JumpState.new()
	register_state(&"Jump", jump_state)

	jump_attack_state = JumpAttackState.new()
	register_state(&"JumpAttack", jump_attack_state)

	takeoff_state = TakeoffState.new()
	register_state(&"Takeoff", takeoff_state)

	land_state = LandState.new()
	register_state(&"Land", land_state)

	fall_state = FallState.new()
	register_state(&"Fall", fall_state)

	fly_state = FlyState.new()
	register_state(&"Fly", fly_state)

	fly_attack_state = FlyAttackState.new()
	register_state(&"FlyAttack", fly_attack_state)

	grounded_state = GroundedState.new()
	register_state(&"Grounded", grounded_state)

	beaten_state = BeatenState.new()
	register_state(&"Beaten", beaten_state)

	stunned_state = StunnedState.new()
	register_state(&"Stunned", stunned_state)

	backdash_state = BackdashState.new()
	register_state(&"Backdash", backdash_state)

	prep_attack_state = PrepAttackState.new()
	register_state(&"PrepAttack", prep_attack_state)

	attack_complete_state = AttackCompleteState.new()
	register_state(&"AttackComplete", attack_complete_state)


## Configures state durations from character stats.
func configure_from_stats(stats: CharacterStats) -> void:
	hurt_state.hurt_duration = stats.hurt_duration
	grounded_state.grounded_duration = stats.grounded_duration
	stunned_state.stun_duration = stats.stun_duration


## Returns whether the character can currently move.
func can_move() -> bool:
	# Allow AI to keep moving while telegraphing an attack.
	# (Players don't enter PrepAttack, so this doesn't affect player controls.)
	return is_in_any_state([&"Idle", &"Walk", &"PrepAttack"])


## Returns whether the character can currently attack.
func can_attack() -> bool:
	# Allow AI strategies to "prep" an attack (telegraph) and then start attacking.
	# Players don't enter PrepAttack, so this doesn't change player controls.
	return is_in_any_state([&"Idle", &"Walk", &"PrepAttack"])


## Returns whether the character can currently jump.
func can_jump() -> bool:
	# Allow jump attacks to trigger after PrepAttack as well.
	return is_in_any_state([&"Idle", &"Walk", &"PrepAttack"])


## Returns whether the character can perform a jump attack.
func can_jump_attack() -> bool:
	return is_in_state(&"Jump")


## Returns whether the character can take damage.
func can_take_damage() -> bool:
	return not is_in_any_state([&"Grounded", &"Beaten"])


## Returns whether the character is in an airborne state.
func is_airborne() -> bool:
	return is_in_any_state([&"Jump", &"JumpAttack", &"Fall", &"Fly", &"FlyAttack"])


## Returns whether the character is in a hurt/down state.
func is_incapacitated() -> bool:
	return is_in_any_state([&"Hurt", &"Fall", &"Fly", &"Grounded", &"Beaten", &"Stunned"])


## Returns whether the character is attacking.
func is_attacking() -> bool:
	return is_in_any_state([&"Attack", &"JumpAttack", &"FlyAttack"])
