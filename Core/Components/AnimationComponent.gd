## Component that manages character animations and sprite flipping.
## Handles playing animations, facing direction, and height offset for jumps.
##
## Follows Single Responsibility Principle - only manages animation-related logic.
##
## Usage:
##     @onready var anim: AnimationComponent = $AnimationComponent
##
##     func _process(delta: float) -> void:
##         anim.play_animation(state_machine.get_current_animation())
##         anim.set_facing(movement.facing_direction)
class_name AnimationComponent
extends Node


## Emitted when an animation finishes.
signal animation_finished(anim_name: String)


## Reference to the AnimationPlayer node.
@export var animation_player: AnimationPlayer

## Reference to the character sprite.
@export var character_sprite: Sprite2D

## Reference to the damage emitter (for flipping with sprite).
@export var damage_emitter: Area2D


## Currently playing animation.
var current_animation: String = ""

## Height offset (in pixels) applied to the sprite for jump/fall simulation.
var _height_offset: float = 0.0

## Base sprite position when standing on the ground (height == 0).
var _base_sprite_position: Vector2 = Vector2.ZERO

## Current facing direction (RIGHT or LEFT).
var facing_direction: Vector2 = Vector2.RIGHT

## Whether to flip sprite for backdash (face away from movement).
var invert_flip_for_backdash: bool = false


func _ready() -> void:
	# Try to find nodes if not set
	if animation_player == null:
		animation_player = get_parent().get_node_or_null("AnimationPlayer")
	if character_sprite == null:
		character_sprite = get_parent().get_node_or_null("CharacterSprite")
	if damage_emitter == null:
		damage_emitter = get_parent().get_node_or_null("DamageEmitter")

	# Connect animation finished signal
	if animation_player:
		animation_player.animation_finished.connect(_on_animation_finished)

	# Ensure our height offset application runs after AnimationPlayer updates.
	# (Some legacy animations keyframe CharacterSprite.position; we need to override Y afterward.)
	process_priority = 1000

	if character_sprite:
		_base_sprite_position = character_sprite.position


func _process(_delta: float) -> void:
	# Re-apply height offset after animations have potentially modified sprite position.
	if character_sprite == null:
		return

	# When grounded, refresh the base position so animations can define a baseline.
	if is_equal_approx(_height_offset, 0.0):
		_base_sprite_position = character_sprite.position

	character_sprite.position = Vector2(_base_sprite_position.x, _base_sprite_position.y - _height_offset)


## Animation fallbacks for missing animations.
const ANIMATION_FALLBACKS := {
	"stunned": "hurt",
	"beaten": "grounded",
	"fall": "fall",
	"fly_attack": "jump_attack",
	"prep_attack": "idle",
	"attack_complete": "idle",
	"fly": "fall",
	"walk": "walk"
}


## Plays an animation by name. Won't restart if already playing unless forced.
func play_animation(anim_name: String, force_restart: bool = false) -> void:
	if animation_player == null:
		return

	if current_animation == anim_name and not force_restart:
		return

	var anim_to_play := anim_name

	# Try fallback if animation doesn't exist
	if not animation_player.has_animation(anim_to_play):
		if ANIMATION_FALLBACKS.has(anim_to_play):
			anim_to_play = ANIMATION_FALLBACKS[anim_to_play]

	if animation_player.has_animation(anim_to_play):
		animation_player.play(anim_to_play)
		current_animation = anim_name  # Keep original name for state tracking
	else:
		push_warning("AnimationComponent: Animation '%s' not found" % anim_name)


## Sets the facing direction and updates sprite flip.
func set_facing(direction: Vector2) -> void:
	facing_direction = direction
	_update_sprite_flip()


## Updates sprite flip based on facing direction and backdash state.
func _update_sprite_flip() -> void:
	if character_sprite == null:
		return

	var should_flip := false

	if invert_flip_for_backdash:
		# Backdash: face opposite of movement
		should_flip = facing_direction.x > 0.0
	else:
		# Normal: face direction of movement
		should_flip = facing_direction.x < 0.0

	character_sprite.flip_h = should_flip

	# Also flip damage emitter to match
	if damage_emitter:
		# NOTE:
		# Negative scale on physics/collision nodes can be unreliable.
		# Instead of scaling the Area2D, mirror the hitbox(es) explicitly.
		# Keep any intentional scaling, but avoid negative scale.
		damage_emitter.scale.x = absf(damage_emitter.scale.x)
		_mirror_collision_shapes_x(damage_emitter, should_flip)


## Mirrors CollisionShape2D children across X axis for left/right facing.
## Stores the initial X offset the first time it sees each shape.
func _mirror_collision_shapes_x(emitter: Node, flipped: bool) -> void:
	var x_sign := -1.0 if flipped else 1.0

	for child in emitter.get_children():
		if child is CollisionShape2D:
			var shape := child as CollisionShape2D
			var base_x: float
			if shape.has_meta(&"_base_x"):
				base_x = float(shape.get_meta(&"_base_x"))
			else:
				base_x = shape.position.x
				shape.set_meta(&"_base_x", base_x)

			shape.position.x = base_x * x_sign
		elif child.get_child_count() > 0:
			# Support nested shapes if the scene has them.
			_mirror_collision_shapes_x(child, flipped)


## Sets the vertical offset for jump height simulation.
func set_height_offset(height: float) -> void:
	_height_offset = height
	# Apply immediately too (helps when called from physics).
	if character_sprite:
		character_sprite.position = Vector2(_base_sprite_position.x, _base_sprite_position.y - _height_offset)


## Enables backdash flip mode (sprite faces opposite of movement).
func set_backdash_mode(enabled: bool) -> void:
	invert_flip_for_backdash = enabled
	_update_sprite_flip()


## Returns whether the current animation is playing.
func is_playing() -> bool:
	return animation_player and animation_player.is_playing()


## Returns the current animation name.
func get_current_animation() -> String:
	return current_animation


## Stops the current animation.
func stop() -> void:
	if animation_player:
		animation_player.stop()


## Callback for animation finished signal.
func _on_animation_finished(anim_name: String) -> void:
	animation_finished.emit(anim_name)
