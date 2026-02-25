## Sharaka enemy character implementation.
## Basic melee enemy that chases the player and attacks when in range.
class_name SharakaCharacter
extends BaseCharacter


## Reference to the player target.
@export var player: PlayerCharacter

## AI controller for behavior.
@onready var ai_controller: AIController = get_node_or_null("AIController")


## The melee strategy used by this enemy.
var _melee_strategy: BasicMeleeStrategy

var _flash_material: ShaderMaterial


func _ready() -> void:
	super._ready()
	_setup_flash_material()
	_setup_attack_audio()
	_setup_beaten_audio()
	_setup_ai()
	
func _process(delta) -> void:
	# IMPORTANT: must call BaseCharacter._process so grounded recovery runs
	# (otherwise Sharaka can get stuck on the floor after knockdown).
	super._process(delta)


## Sets up AI controller with melee strategy.
func _setup_ai() -> void:
	if ai_controller == null:
		ai_controller = AIController.new()
		ai_controller.name = "AIController"
		add_child(ai_controller)

	ai_controller.character = self
	# We'll drive the strategy from _handle_ai (physics) to ensure movement/attacks
	# are in sync with the character state machine and animations.
	ai_controller.is_active = false

	# Create and configure strategy
	_melee_strategy = BasicMeleeStrategy.new()

	if config and config.stats:
		_melee_strategy.attack_cooldown = config.stats.attack_cooldown
		_melee_strategy.attack_distance = config.attack_distance if config else 50.0
		# Sharaka should punch at close range, but still be able to do a flying kick
		# if the player keeps distance during the wind-up.
		_melee_strategy.prep_start_distance = (config.attack_distance if config else 50.0) * 1.5
		_melee_strategy.allow_jump_attack = true
		_melee_strategy.jump_attack_max_distance = _melee_strategy.prep_start_distance
		_melee_strategy.approach_during_prep = true
		# Deterministic choice: standing attack vs airborne target => jump attack.
		_melee_strategy.randomize_attack_choice = false
		_melee_strategy.jump_attack_when_target_airborne = true
		_melee_strategy.face_target_when_airborne = false

	ai_controller.set_strategy(_melee_strategy)

	if player:
		ai_controller.set_target(player)


## Sets up the white flash shader on the character sprite.
func _setup_flash_material() -> void:
	_flash_material = ShaderMaterial.new()
	_flash_material.shader = preload("res://Core/Shaders/white_flash.gdshader")
	_flash_material.set_shader_parameter("flash_intensity", 0.0)
	character_sprite.material = _flash_material


## Briefly flashes the sprite white when taking damage.
func _flash_white() -> void:
	_flash_material.set_shader_parameter("flash_intensity", 0.6)
	get_tree().create_timer(0.1).timeout.connect(
		func(): _flash_material.set_shader_parameter("flash_intensity", 0.0)
	)


## Ensures Sharaka plays knife slash SFX on attack.
func _setup_attack_audio() -> void:
	if get_node_or_null("SharakaAttackAudioController") != null:
		return

	var ctrl := preload("res://Core/Audio/SharakaAttackAudioController.gd").new()
	ctrl.name = "SharakaAttackAudioController"
	add_child(ctrl)


## Ensures Sharaka plays the "Beaten" SFX on defeat.
func _setup_beaten_audio() -> void:
	if get_node_or_null("BeatenAudioController") != null:
		return

	var ctrl := preload("res://Core/Audio/BeatenAudioController.gd").new()
	ctrl.name = "BeatenAudioController"
	add_child(ctrl)

## During PrepAttack, apply movement (for approach_during_prep) without letting
## BaseCharacter._handle_movement transition the state to Walk/Idle.
## This keeps PrepAttack stable so the prep timer can finish properly.
func _handle_movement(delta: float) -> void:
	if state_machine.is_in_state(&"PrepAttack"):
		movement_component.apply_movement(delta)
		return
	super._handle_movement(delta)


## Override AI handling - delegated to AIController.
func _handle_ai(_delta: float) -> void:
	if _melee_strategy == null:
		return
	if player and is_instance_valid(player):
		_melee_strategy.set_target(player)
	_melee_strategy.update(_delta)



## Sets the player target.
func set_player(p_player: PlayerCharacter) -> void:
	player = p_player
	if ai_controller:
		ai_controller.set_target(player)
	if _melee_strategy:
		_melee_strategy.set_target(player)


## Updates heading to always face the player.
func _update_heading() -> void:
	# Don't flip while airborne (prevents mid-air flip_x changes).
	# Heading is set before the jump/attack begins; keep it stable until landing.
	if heading_locked or state_machine.is_airborne():
		return
	if player and is_instance_valid(player):
		if global_position.x > player.global_position.x:
			heading = Vector2.LEFT
		else:
			heading = Vector2.RIGHT


## Guard against double-trigger from both animation_finished signal and method track.
func _on_attack_complete() -> void:
	if not combat_component.is_attacking:
		return
	super._on_attack_complete()


## Flash white when taking damage.
func _on_damage_received(damage_data: DamageData, direction: Vector2, source: Node) -> void:
	# Sharaka is only vulnerable to jump attacks (knockdown-type hits).
	# All other hits should have no effect (no damage, no hit reaction).
	if damage_data.type != DamageTypes.Type.KNOCKDOWN:
		return

	super._on_damage_received(damage_data, direction, source)
	_flash_white()


## Called when this enemy is defeated.
func _on_health_depleted() -> void:
	super._on_health_depleted()
