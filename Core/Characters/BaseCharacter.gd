## Base class for all characters in the game.
## Orchestrates components (health, movement, combat, animation) and state machine.
## Replaces the monolithic Character and Character2 classes.
##
## Usage:
##     # Extend for specific character types
##     class_name PlayerCharacter
##     extends BaseCharacter
##
##     func _ready() -> void:
##         super._ready()
##         # Player-specific setup
class_name BaseCharacter
extends CharacterBody2D


## Emitted when this character dies.
signal died

## Emitted when this character takes damage.
signal damage_taken(amount: int, source: Node)

## Emitted when this character deals damage.
signal damage_dealt(target: Node, amount: int)


## Configuration resource containing stats and settings.
@export var config: CharacterConfig

## Optional health bar to display.
@export var health_bar: ProgressBar


## Component references - set in editor or created automatically.
var health_component: HealthComponent
var movement_component: MovementComponent
var combat_component: CombatComponent
var animation_component: AnimationComponent

## Node references.
var character_sprite: Sprite2D
var collision_shape: CollisionShape2D
var damage_emitter: DamageEmitter
var damage_receiver: DamageReceiver
var animation_player: AnimationPlayer

## State machine for character states.
var state_machine: CharacterStateMachine

## Height for jump/fly simulation (sprite offset).
var height: float = 0.0

## Vertical speed for jump/fly physics.
var height_speed: float = 0.0

## Facing direction for attacks and sprites.
var heading: Vector2 = Vector2.RIGHT

## Whether heading updates are locked.
var heading_locked: bool = false

## Gravity constant.
var gravity: float = 600.0

## Speed property for animation compatibility - syncs with movement_component.
var speed: float = 100.0:
	set(value):
		speed = value
		if movement_component:
			movement_component.speed = value


func _ready() -> void:
	_find_node_references()
	_setup_state_machine()
	_setup_components()
	_connect_signals()
	_apply_config()
	# Defer a second config application to ensure values stick after scene setup
	call_deferred("_apply_config")
	


## Finds existing node references in the scene tree.
func _find_node_references() -> void:
	# Get required node references
	character_sprite = get_node_or_null("CharacterSprite")
	collision_shape = get_node_or_null("CollisionShape2D")
	damage_emitter = get_node_or_null("DamageEmitter")
	damage_receiver = get_node_or_null("DamageReceiver")
	animation_player = get_node_or_null("AnimationPlayer")

	# Get component references if they exist in scene
	health_component = get_node_or_null("HealthComponent")
	movement_component = get_node_or_null("MovementComponent")
	combat_component = get_node_or_null("CombatComponent")
	animation_component = get_node_or_null("AnimationComponent")


## Creates and initializes the state machine.
func _setup_state_machine() -> void:
	state_machine = CharacterStateMachine.new()
	state_machine.name = "StateMachine"
	add_child(state_machine)
	state_machine.initialize(self)
	state_machine.start(&"Idle")


## Sets up component references and creates missing components.
func _setup_components() -> void:
	# Ensure components exist
	if health_component == null:
		health_component = HealthComponent.new()
		health_component.name = "HealthComponent"
		add_child(health_component)

	if movement_component == null:
		movement_component = MovementComponent.new()
		movement_component.name = "MovementComponent"
		add_child(movement_component)

	if combat_component == null:
		combat_component = CombatComponent.new()
		combat_component.name = "CombatComponent"
		add_child(combat_component)

	if animation_component == null:
		animation_component = AnimationComponent.new()
		animation_component.name = "AnimationComponent"
		add_child(animation_component)

	# Configure component references
	movement_component.character = self
	animation_component.animation_player = animation_player
	animation_component.character_sprite = character_sprite
	animation_component.damage_emitter = damage_emitter

	if health_bar:
		health_component.health_bar = health_bar


## Connects all component signals.
func _connect_signals() -> void:
	# Health signals
	health_component.damage_taken.connect(_on_health_damage_taken)
	health_component.health_depleted.connect(_on_health_depleted)

	# Combat signals
	combat_component.attack_hit.connect(_on_attack_hit)

	# Damage signals
	if damage_receiver:
		damage_receiver.damage_received.connect(_on_damage_received)

	if damage_emitter:
		damage_emitter.damage_dealt.connect(_on_damage_emitter_hit)
		# Ignore own damage receiver
		if damage_receiver:
			damage_emitter.add_ignored_receiver(damage_receiver)

	# Animation signals
	animation_component.animation_finished.connect(_on_animation_finished)


## Applies configuration from the CharacterConfig resource.
func _apply_config() -> void:
	if config == null or config.stats == null:
		push_warning("BaseCharacter: No config or stats assigned")
		return

	var stats := config.stats

	# Apply to health component
	health_component.max_health = stats.max_health
	health_component.starting_health = stats.starting_health if stats.starting_health > 0 else stats.max_health
	health_component.reset()

	# Apply to movement component (use BaseCharacter.speed for animation compatibility)
	speed = stats.speed
	movement_component.acceleration = stats.acceleration
	movement_component.friction = stats.friction

	# Apply to combat component
	combat_component.attack_animations = stats.attack_animations.duplicate()
	combat_component.base_damage = stats.base_damage
	combat_component.power_damage = stats.power_damage
	combat_component.combo_window = stats.combo_window
	combat_component.knockback_force = stats.knockback_intensity
	combat_component.knockdown_force = stats.knockdown_intensity
	combat_component.flight_speed = stats.flight_speed

	# Apply to state machine
	state_machine.configure_from_stats(stats)

	# Apply physics
	gravity = stats.gravity


func _physics_process(delta: float) -> void:
	_handle_input()
	_handle_ai(delta)

	state_machine.physics_update(delta)

	_handle_height_physics(delta)
	_handle_movement(delta)
	_update_heading()
	_update_sprites()
	_update_collision()

	
	move_and_slide()
	set_frame_safe(character_sprite.frame)
	_update_animation()
	
	
	
	
	


func _process(delta: float) -> void:
	state_machine.update(delta)
	_handle_grounded_recovery()


## Override in subclasses for player input.
func _handle_input() -> void:
	pass


## Override in subclasses for AI behavior.
func _handle_ai(_delta: float) -> void:
	pass


## Handles height simulation for jumps/falls.
func _handle_height_physics(delta: float) -> void:
	if not state_machine.is_airborne() and height <= 0 and height_speed == 0:
		return

	height += height_speed * delta
	# Only apply "air forward drift" to jump/jump-attack.
	# For Fly/Fall (knockback/launch), horizontal movement should come from velocity,
	# otherwise enemies can incorrectly slide toward the player while airborne.
	if state_machine.is_in_any_state([&"Jump", &"JumpAttack"]):
		position.x += heading.x * movement_component.speed * delta

	# Apply forward movement during jump attack
	if state_machine.is_in_state(&"JumpAttack"):
		var move_dir := heading.x * movement_component.speed * delta
		position.x += move_dir

	# Handle landing
	if height <= 0:
		height = 0
		height_speed = 0
		_on_landed()
	else:
		height_speed -= gravity * delta


## Called when character lands from airborne state.
func _on_landed() -> void:
	var current_state := state_machine.get_current_state_name()

	match current_state:
		&"Fall":
			state_machine.transition_to(&"Grounded")
		&"Jump", &"JumpAttack":
			state_machine.transition_to(&"Land")
		&"Fly", &"FlyAttack":
			_on_fly_complete()


## Handles state-based movement and applies velocity.
func _handle_movement(delta: float) -> void:
	if state_machine.is_incapacitated():
		# Preserve knockback/launch velocity for airborne + hurt states.
		# Previously, stop() would zero velocity immediately, cancelling throwback on Fly/Fall/Hurt.
		if state_machine.is_in_any_state([&"Stunned", &"Grounded", &"Beaten"]):
			movement_component.stop()
		else:
			# Block player/AI input but let friction naturally slow the current velocity.
			movement_component.set_input_direction(Vector2.ZERO)
			movement_component.apply_movement(delta)
		return

	# Apply movement from the movement component
	if state_machine.can_move():
		movement_component.apply_movement(delta)

		if velocity.length() < 1.0:
			state_machine.transition_to(&"Idle")
		else:
			state_machine.transition_to(&"Walk")


## Updates heading based on input direction (primary) or velocity (fallback).
func _update_heading() -> void:
	if heading_locked:
		return

	# Update based on input direction first (more responsive, prevents moonwalk)
	if movement_component.has_input():
		if movement_component.input_direction.x > 0:
			heading = Vector2.RIGHT
		elif movement_component.input_direction.x < 0:
			heading = Vector2.LEFT
	# Fallback to velocity-based heading when no input
	elif state_machine.can_move() and velocity.length() > 1.0:
		if velocity.x > 0:
			heading = Vector2.RIGHT
		elif velocity.x < 0:
			heading = Vector2.LEFT


## Updates sprite and emitter based on heading.
func _update_sprites() -> void:
	# Update animation component facing
	var is_backdash := state_machine.is_in_state(&"Backdash")
	animation_component.set_backdash_mode(is_backdash)
	animation_component.set_facing(heading)

	# Update height offset
	animation_component.set_height_offset(height)


## Updates collision based on state.
func _update_collision() -> void:
	if collision_shape:
		collision_shape.disabled = state_machine.is_in_any_state([&"Grounded", &"Beaten"])


## Updates animation based on current state.
func _update_animation() -> void:
	var anim_name := state_machine.get_current_animation()
	
	
	# Use attack animation from combat component if attacking
	if state_machine.is_in_state(&"Attack"):
		anim_name = combat_component.get_current_attack_animation()
	
	animation_component.play_animation(anim_name)


## Handles grounded recovery timing.
func _handle_grounded_recovery() -> void:
	if not state_machine.is_in_state(&"Grounded"):
		return

	var grounded := state_machine.grounded_state
	if grounded.elapsed_time >= grounded.grounded_duration:
		if health_component.is_alive():
			state_machine.transition_to(&"Land")
		else:
			state_machine.transition_to(&"Beaten")


## Called when damage is received.
func _on_damage_received(damage_data: DamageData, direction: Vector2, source: Node) -> void:
	if not state_machine.can_take_damage():
		return

	heading_locked = true
	combat_component.force_reset()  # Reset any in-progress attack
	if damage_emitter:
		damage_emitter.end_attack()   # Ensure we can't keep dealing damage after being interrupted

	health_component.take_damage(damage_data.amount)
	damage_taken.emit(damage_data.amount, source)

	_apply_damage_reaction(damage_data, direction)


## Applies state change and physics based on damage type.
func _apply_damage_reaction(damage_data: DamageData, direction: Vector2) -> void:
	var stats := config.stats if config else null

	if not health_component.is_alive():
		# Death - fall state
		state_machine.force_transition(&"Fall")
		height_speed = stats.knockdown_intensity if stats else 250.0
		velocity = direction * (stats.knockback_intensity if stats else 150.0)

	elif damage_data.type == DamageTypes.Type.KNOCKDOWN:
		# Knockdown attack
		state_machine.force_transition(&"Fall")
		height_speed = damage_data.knockdown_force
		velocity = direction * damage_data.knockback_force

	elif damage_data.type == DamageTypes.Type.POWER:
		# Power attack - fly state
		state_machine.force_transition(&"Fly")
		height_speed = stats.jump_intensity if stats else 300.0
		velocity = direction * damage_data.flight_speed

	else:
		# Normal damage - hurt state
		state_machine.force_transition(&"Hurt")
		velocity = direction * damage_data.knockback_force


## Called when health reaches zero.
func _on_health_depleted() -> void:
	died.emit()


## Called when an attack hits.
func _on_attack_hit(target: Node) -> void:
	pass


## Called when damage emitter hits a receiver.
func _on_damage_emitter_hit(receiver: DamageReceiver, damage_data: DamageData) -> void:
	combat_component.on_hit(receiver.get_parent())
	damage_dealt.emit(receiver.get_parent(), damage_data.amount)


## Called when health component takes damage.
func _on_health_damage_taken(amount: int) -> void:
	pass


## Called when animation finishes.
func _on_animation_finished(anim_name: String) -> void:
	match anim_name:
		"takeoff":
			_on_takeoff_complete()
		"land":
			_on_land_complete()
		"backdash":
			_on_backdash_complete()
		"hurt":
			_on_hurt_complete()
		_:
			if state_machine.is_in_state(&"Attack"):
				_on_attack_complete()


## Called when takeoff animation completes.
func _on_takeoff_complete() -> void:
	state_machine.transition_to(&"Jump")
	var stats := config.stats if config else null
	height_speed = stats.jump_intensity if stats else 300.0


## Called when landing animation completes.
func _on_land_complete() -> void:
	heading_locked = false
	state_machine.transition_to(&"Idle")


## Called when attack animation completes.
func _on_attack_complete() -> void:
	combat_component.finish_attack()
	if damage_emitter:
		damage_emitter.end_attack()
	heading_locked = false
	state_machine.transition_to(&"Idle")


## Called when backdash completes.
func _on_backdash_complete() -> void:
	animation_component.set_backdash_mode(false)
	state_machine.transition_to(&"Idle")


## Called when hurt animation completes.
func _on_hurt_complete() -> void:
	heading_locked = false
	combat_component.force_reset()
	if state_machine.is_in_state(&"Hurt"):
		state_machine.transition_to(&"Idle")


## Called when fly state ends (landing).
func _on_fly_complete() -> void:
	heading_locked = false
	state_machine.transition_to(&"Idle")


## Starts an attack if possible.
func try_attack() -> bool:
	if not state_machine.can_attack():
		return false
	if not combat_component.can_start_attack():
		return false

	var attack_anim := combat_component.start_attack()
	state_machine.attack_state.current_attack_animation = attack_anim

	# Create damage data and start emitter
	var damage_data := combat_component.create_damage_data(false)
	damage_emitter.start_attack(damage_data)

	state_machine.transition_to(&"Attack")
	return true


## Starts a jump if possible.
func try_jump() -> bool:
	if not state_machine.can_jump():
		return false

	state_machine.transition_to(&"Takeoff")
	return true


## Starts a jump attack if possible.
func try_jump_attack() -> bool:
	if not state_machine.can_jump_attack():
		return false

	var damage_data := combat_component.create_damage_data(true)
	damage_emitter.start_attack(damage_data)

	state_machine.transition_to(&"JumpAttack")
	return true


## Gets the current health.
func get_health() -> int:
	return health_component.current_health


## Gets the max health.
func get_max_health() -> int:
	return health_component.max_health


## Returns whether the character is alive.
func is_alive() -> bool:
	return health_component.is_alive()


## Resets the character to initial state.
func reset() -> void:
	health_component.reset()
	combat_component.force_reset()
	state_machine.force_transition(&"Idle")
	height = 0.0
	height_speed = 0.0
	heading_locked = false
	velocity = Vector2.ZERO
	modulate.a = 1.0


#region Animation Callbacks (called by AnimationPlayer method tracks)

## Called by animations when an action (attack, hurt, etc.) completes.
func on_action_complete() -> void:
	heading_locked = false  # Always reset heading lock
	if state_machine.is_in_state(&"Attack"):
		_on_attack_complete()
	elif state_machine.is_in_state(&"Hurt"):
		combat_component.force_reset()
		state_machine.transition_to(&"Idle")
	else:
		state_machine.transition_to(&"Idle")


## Called by takeoff animation. Note: typo preserved from original animations.
func on_takoff_complete() -> void:
	_on_takeoff_complete()


## Called by land animation.
func on_land_complete() -> void:
	_on_land_complete()


## Called when fly state starts (animation callback).
func on_fly_started() -> void:
	# Height physics are handled in _handle_height_physics
	pass


## Called when fly state ends (animation callback).
func on_fly_complete() -> void:
	_on_fly_complete()


## Called when backdash animation completes.
func on_backdash_complete() -> void:
	_on_backdash_complete()

#endregion

func set_frame_safe(frame: int):
	var max_frames := character_sprite.hframes * character_sprite.vframes

	if frame < 0 or frame >= max_frames:
		push_error(
			"Sprite2D frame fuera de rango\n" +
			"Nodo: %s\nFrame pedido: %d\nFrames totales: %d\nStack:\n%s"+
			"error en animación: "+str(animation_player.current_animation)
			%[
				character_sprite.name,
				frame,
				max_frames,
				get_stack()
				]
				
			)
		
		return
	character_sprite.frame = frame
