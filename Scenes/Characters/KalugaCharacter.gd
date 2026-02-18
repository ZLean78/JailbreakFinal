## Kaluga boss character implementation.
## Boss enemy with charge attacks, stun vulnerability, and enrage mechanic.
class_name KalugaCharacter
extends BaseCharacter


## Reference to the player target.
@export var player: PlayerCharacter

## Multiplier for kick knockback force.
@export var kickback_multiplier: float = 1.5

## Duration of fall recovery timer.
@export var fall_recovery_time: float = 5.0


## AI controller for behavior.
var ai_controller: AIController

## Raycast for line-of-sight attacks.
var aim_raycast: RayCast2D

## Timer for stun recovery.
var stun_timer: Timer

## Timer for attack cooldown.
var attack_timer: Timer

## Timer for fall recovery.
var fall_timer: Timer


## The boss strategy used by this enemy.
var _boss_strategy: BossAIStrategy

## Whether currently stunned by gas.
var is_gas_stunned: bool = false

## Throttle for debug logging when immune to normal punches.
const _IMMUNE_LOG_COOLDOWN_MSEC: int = 600
const _IMMUNE_GRANT_IMMUNITY_SEC: float = 0.15
var _last_immune_log_msec: int = 0
var _last_immune_state: StringName = &""

var _flash_material: ShaderMaterial


func _ready() -> void:
	# Find existing nodes before super._ready()
	ai_controller = get_node_or_null("AIController")
	aim_raycast = get_node_or_null("Aim")
	stun_timer = get_node_or_null("StunTimer")
	attack_timer = get_node_or_null("AttackTimer")
	fall_timer = get_node_or_null("FallTimer")

	super._ready()
	_setup_flash_material()
	_setup_attack_audio()
	_setup_beaten_audio()
	_setup_timers()
	_setup_ai()
	

func _setup_flash_material() -> void:
	_flash_material = ShaderMaterial.new()
	_flash_material.shader = preload("res://Core/Shaders/white_flash.gdshader")
	_flash_material.set_shader_parameter("flash_intensity", 0.0)
	character_sprite.material = _flash_material


func _flash_white() -> void:
	_flash_material.set_shader_parameter("flash_intensity", 0.6)
	get_tree().create_timer(0.1).timeout.connect(
		func(): _flash_material.set_shader_parameter("flash_intensity", 0.0)
	)


## Ensures Kaluga plays attack SFX on every punch/attack.
func _setup_attack_audio() -> void:
	if get_node_or_null("KalugaAttackAudioController") != null:
		return

	var ctrl := preload("res://Core/Audio/KalugaAttackAudioController.gd").new()
	ctrl.name = "KalugaAttackAudioController"
	add_child(ctrl)


## Ensures Kaluga plays the "Beaten" SFX on defeat.
func _setup_beaten_audio() -> void:
	if get_node_or_null("BeatenAudioController") != null:
		return

	var ctrl := preload("res://Core/Audio/BeatenAudioController.gd").new()
	ctrl.name = "BeatenAudioController"
	add_child(ctrl)


## Sets up timer nodes.
func _setup_timers() -> void:
	# Create timers if they don't exist
	if stun_timer == null:
		stun_timer = Timer.new()
		stun_timer.name = "StunTimer"
		stun_timer.one_shot = true
		add_child(stun_timer)

	if attack_timer == null:
		attack_timer = Timer.new()
		attack_timer.name = "AttackTimer"
		attack_timer.one_shot = true
		add_child(attack_timer)

	if fall_timer == null:
		fall_timer = Timer.new()
		fall_timer.name = "FallTimer"
		fall_timer.one_shot = true
		fall_timer.wait_time = fall_recovery_time
		add_child(fall_timer)

	# Connect timer signals
	stun_timer.timeout.connect(_on_stun_timer_timeout)
	fall_timer.timeout.connect(_on_fall_timer_timeout)


## Sets up AI controller with boss strategy.
func _setup_ai() -> void:
	if ai_controller == null:
		ai_controller = AIController.new()
		ai_controller.name = "AIController"
		add_child(ai_controller)

	ai_controller.character = self

	# Create and configure strategy
	_boss_strategy = BossAIStrategy.new()

	if config:
		_boss_strategy.attack_distance = config.attack_distance
		_boss_strategy.chase_distance = config.chase_distance
	if config and config.stats:
		_boss_strategy.attack_cooldown = config.stats.attack_cooldown

	if aim_raycast:
		_boss_strategy.set_aim_raycast(aim_raycast)

	ai_controller.set_strategy(_boss_strategy)

	if player:
		ai_controller.set_target(player)


## Override AI handling - delegated to AIController.
func _handle_ai(_delta: float) -> void:
	# AI is handled by AIController component
	# But we need to handle special states

	# Keep frozen while gas stun timer is running (only in Stunned state).
	# Important: knockdowns during gas stun use Fly; we must not zero velocity there,
	# otherwise Kaluga won't be thrown back.
	if is_gas_stunned and stun_timer != null and not stun_timer.is_stopped() and state_machine.is_in_state(&"Stunned"):
		velocity = Vector2.ZERO
		return

	# Keep in fly state during fall recovery
	if state_machine.is_in_state(&"Fly") and fall_timer != null and not fall_timer.is_stopped():
		return


## Updates heading to face the player.
func _update_heading() -> void:
	if heading_locked:
		return

	if player and is_instance_valid(player):
		if not state_machine.is_in_any_state([&"Stunned", &"Beaten"]):
			if global_position.x > player.global_position.x:
				heading = Vector2.LEFT
			else:
				heading = Vector2.RIGHT


## Flips aim raycast to match heading.
func _update_sprites() -> void:
	super._update_sprites()

	if aim_raycast:
		aim_raycast.scale.x = -1 if heading == Vector2.LEFT else 1


## Override damage reception - boss-specific reactions.
func _apply_damage_reaction(damage_data: DamageData, direction: Vector2) -> void:
	var stats := config.stats if config else null

	if not health_component.is_alive():
		# Death - fly state with boss animation
		character_sprite.vframes = 2
		character_sprite.hframes = 3
		state_machine.force_transition(&"Fly")
		height_speed = stats.jump_intensity if stats else 300.0
		velocity = direction * (stats.flight_speed if stats else 200.0)

	# While gas-stunned, regular punches should NOT push Kaluga back.
	# The throwback should only happen on knockdown (kick or the 4th punch we convert to KNOCKDOWN).
	elif is_gas_stunned and damage_data.type != DamageTypes.Type.KNOCKDOWN:
		state_machine.force_transition(&"Hurt")
		velocity = Vector2.ZERO

	elif damage_data.type == DamageTypes.Type.KNOCKDOWN:
		# Kick - fly with increased force and recovery timer
		state_machine.force_transition(&"Fly")
		velocity = direction * (stats.knockback_intensity if stats else 150.0) * kickback_multiplier
		height_speed = stats.jump_intensity if stats else 300.0
		fall_timer.start()

	elif damage_data.type == DamageTypes.Type.POWER:
		# Power attack - fly state
		state_machine.force_transition(&"Fly")
		velocity = direction * (stats.flight_speed if stats else 200.0)

	else:
		# Normal damage - hurt state
		state_machine.force_transition(&"Hurt")
		velocity = direction * (stats.knockback_intensity if stats else 150.0)


## Stuns the boss (e.g., from gas).
func stun(duration: float) -> void:
	is_gas_stunned = true
	stun_timer.wait_time = duration
	stun_timer.start()
	state_machine.force_transition(&"Stunned")
	velocity = Vector2.ZERO


## Called when stun timer expires.
func _on_stun_timer_timeout() -> void:
	is_gas_stunned = false
	# Reset sprite properties
	character_sprite.hframes = 4
	character_sprite.vframes = 1
	state_machine.transition_to(&"Idle")


## Called when fall recovery timer expires.
func _on_fall_timer_timeout() -> void:
	if state_machine.is_in_state(&"Fly"):
		state_machine.transition_to(&"Idle")
		heading_locked = false
		height = 0.0
		height_speed = 0.0


## Override can_take_damage - boss can only be hurt when stunned by gas OR hit by kick.
func _on_damage_received(damage_data: DamageData, direction: Vector2, source: Node) -> void:
	# Kicks (KNOCKDOWN type) always damage Kaluga - special move that bypasses defense
	var is_kick := damage_data.type == DamageTypes.Type.KNOCKDOWN

	# Boss takes damage when: gas stunned OR hit by kick
	if not is_gas_stunned and not is_kick:
		# Important: player melee spam can call into this constantly.
		# Grant short immunity so we don't flood callbacks/logs and freeze the game.
		if damage_receiver:
			damage_receiver.grant_immunity(_IMMUNE_GRANT_IMMUNITY_SEC)

		# Throttled debug log (avoid output spam stalls).
		if OS.is_debug_build():
			var now := Time.get_ticks_msec()
			var st := state_machine.get_current_state_name()
			if st != _last_immune_state or (now - _last_immune_log_msec) >= _IMMUNE_LOG_COOLDOWN_MSEC:
				_last_immune_state = st
				_last_immune_log_msec = now
				print("Kaluga: Cannot get hurt (needs gas stun or kick). State: ", st)
		return

	super._on_damage_received(damage_data, direction, source)
	_flash_white()


## Sets the player target.
func set_player(p_player: PlayerCharacter) -> void:
	player = p_player
	if ai_controller:
		ai_controller.set_target(player)
