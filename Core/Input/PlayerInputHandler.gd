## Handles player input and translates it to commands.
## Supports double-tap detection for backdash.
##
## Usage:
##     # Add as child of player character
##     @onready var input_handler: PlayerInputHandler = $PlayerInputHandler
##
##     func _ready() -> void:
##         input_handler.character = self
class_name PlayerInputHandler
extends Node


## The character this handler controls.
@export var character: BaseCharacter

## Action names for input mapping.
@export var action_left: String = "Left"
@export var action_right: String = "Right"
@export var action_up: String = "Up"
@export var action_down: String = "Down"
@export var action_attack: String = "Attack"
@export var action_jump: String = "Jump"
@export var action_interact: String = "Interact"

## Time window for double-tap detection (seconds).
@export var double_tap_window: float = 0.3


## Command instances (reused to avoid allocations).
var _move_command: MoveCommand
var _attack_command: AttackCommand
var _jump_command: JumpCommand
var _backdash_command: BackdashCommand

## Double-tap tracking.
var _last_tap_time: float = 0.0
var _last_tap_direction: float = 0.0
var _tap_count: int = 0


func _ready() -> void:
	_move_command = MoveCommand.new()
	_attack_command = AttackCommand.new()
	_jump_command = JumpCommand.new()
	_backdash_command = BackdashCommand.new()


func _process(delta: float) -> void:
	if character == null:
		return

	_handle_movement_input()
	_handle_action_input()
	_update_double_tap_timer(delta)


## Handles movement input.
func _handle_movement_input() -> void:
	var direction := Input.get_vector(action_left, action_right, action_up, action_down)

	_move_command.direction = direction
	if _move_command.can_execute(character):
		_move_command.execute(character)

	# Double-tap detection
	if Input.is_action_just_pressed(action_left):
		_detect_double_tap(-1.0)
	elif Input.is_action_just_pressed(action_right):
		_detect_double_tap(1.0)


## Handles action input (attack, jump, interact).
func _handle_action_input() -> void:
	if Input.is_action_just_pressed(action_attack):
		if _attack_command.can_execute(character):
			_attack_command.execute(character)

	if Input.is_action_just_pressed(action_jump):
		if _jump_command.can_execute(character):
			_jump_command.execute(character)

	if Input.is_action_just_pressed(action_interact):
		if character.has_method("try_interact"):
			character.try_interact()


## Detects double-tap for backdash.
func _detect_double_tap(direction: float) -> void:
	var current_time := Time.get_ticks_msec() / 1000.0

	if direction == _last_tap_direction and (current_time - _last_tap_time) <= double_tap_window:
		_tap_count += 1
		if _tap_count >= 2:
			_trigger_backdash(direction)
			_tap_count = 0
	else:
		_tap_count = 1

	_last_tap_direction = direction
	_last_tap_time = current_time


## Triggers a backdash in the tap direction.
func _trigger_backdash(tap_direction: float) -> void:
	# Backdash goes in the direction of the double-tap
	var backdash_dir := Vector2.RIGHT if tap_direction > 0 else Vector2.LEFT

	_backdash_command.dash_direction = backdash_dir
	if _backdash_command.can_execute(character):
		_backdash_command.execute(character)


## Updates double-tap timer to reset if window expires.
func _update_double_tap_timer(_delta: float) -> void:
	var current_time := Time.get_ticks_msec() / 1000.0
	if (current_time - _last_tap_time) > double_tap_window:
		_tap_count = 0
