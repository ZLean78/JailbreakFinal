## AI strategy for boss enemies like Kaluga.
## Behavior: Charge attacks when in range, becomes more aggressive at low health.
## Can be stunned and has special recovery from stun.
class_name BossAIStrategy
extends AIStrategy


## Distance at which to attack.
var attack_distance: float = 50.0

## Distance below which boss holds position.
var chase_distance: float = 10.0

## Cooldown between attacks (seconds).
var attack_cooldown: float = 1.25

## Health percentage at which boss becomes enraged.
var enrage_threshold: float = 0.3

## Multiplier for attack distance when enraged.
var enrage_attack_multiplier: float = 1.5


## Time since last attack.
var _cooldown_timer: float = 0.0

## Whether boss is enraged.
var _is_enraged: bool = false

## Optional raycast for line-of-sight checks.
var _aim_raycast: RayCast2D = null


func update(delta: float) -> void:
	# Update cooldown
	if _cooldown_timer > 0:
		_cooldown_timer -= delta

	# Check enrage status
	_update_enrage_status()

	if not has_valid_target():
		stop_movement()
		return

	# Don't act during certain states
	var current_state := character.state_machine.get_current_state_name()
	if current_state in [&"Stunned", &"Attack", &"FlyAttack"]:
		stop_movement()
		return

	face_target()

	var distance := get_distance_to_target()
	var effective_attack_distance := attack_distance
	if _is_enraged:
		effective_attack_distance *= enrage_attack_multiplier

	# Decide behavior based on distance
	if _can_attack() and distance <= effective_attack_distance:
		_execute_charge_attack()
	else:
		_chase_target()


## Updates enrage status based on health.
func _update_enrage_status() -> void:
	var health_pct := character.health_component.get_health_percentage()
	_is_enraged = health_pct <= enrage_threshold


## Chases the target.
func _chase_target() -> void:
	move_toward_target()


## Executes a charging attack.
func _execute_charge_attack() -> void:
	if not character.state_machine.can_attack():
		return

	# Create charge attack damage
	var damage := DamageData.new()
	damage.amount = character.combat_component.base_damage
	damage.type = DamageTypes.Type.NORMAL
	damage.knockback_force = character.combat_component.knockback_force

	# Start the attack
	character.damage_emitter.start_attack(damage)
	character.state_machine.transition_to(&"Attack")

	# Apply charge velocity toward target
	var direction := get_direction_to_target()
	var stats := character.config.stats if character.config else null
	var charge_speed := stats.flight_speed if stats else 200.0
	character.velocity = direction * charge_speed

	_cooldown_timer = attack_cooldown


## Returns whether an attack can be executed.
func _can_attack() -> bool:
	if _cooldown_timer > 0:
		return false

	# Check line of sight if raycast available
	if _aim_raycast:
		if _aim_raycast.is_colliding():
			return _aim_raycast.get_collider() == target

	return character.state_machine.can_attack()


## Sets the aim raycast for line-of-sight checks.
func set_aim_raycast(raycast: RayCast2D) -> void:
	_aim_raycast = raycast


## Called when boss is stunned (e.g., by gas).
func on_stunned(duration: float) -> void:
	character.state_machine.force_transition(&"Stunned")
	character.state_machine.stunned_state.stun_duration = duration


## Returns whether the boss is enraged.
func is_enraged() -> bool:
	return _is_enraged
