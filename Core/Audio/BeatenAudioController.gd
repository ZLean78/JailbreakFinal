## Plays a SFX when the owning character enters the Beaten state.
class_name BeatenAudioController
extends Node

## Character to listen to. If null, uses parent if it is a BaseCharacter.
@export var character: BaseCharacter

## Which state name counts as "beaten".
@export var beaten_state_name: StringName = &"Beaten"

## Sound to play when beaten.
@export var beaten_stream: AudioStream = preload("res://Sound/Beaten.ogg")

## Optional child AudioStreamPlayer name. If missing, it will be created.
@export var player_node_name: StringName = &"BeatenSfx"

var _player: AudioStreamPlayer
var _is_bound: bool = false
var _played_for_current_beaten: bool = false


func _ready() -> void:
	# Defer so BaseCharacter has finished creating the state machine.
	call_deferred("_bind")


func _bind() -> void:
	if _is_bound:
		return

	if character == null:
		var p := get_parent()
		if p is BaseCharacter:
			character = p

	if character == null:
		push_warning("BeatenAudioController: No BaseCharacter found to bind to.")
		return

	if character.state_machine == null:
		push_warning("BeatenAudioController: Character has no state machine.")
		return

	var node_path := NodePath(String(player_node_name))
	_player = get_node_or_null(node_path) as AudioStreamPlayer
	if _player == null:
		_player = AudioStreamPlayer.new()
		_player.name = String(player_node_name)
		add_child(_player)

	if _player.stream == null and beaten_stream != null:
		_player.stream = beaten_stream

	if character.state_machine.has_signal("state_changed"):
		character.state_machine.state_changed.connect(_on_state_changed)

	_is_bound = true


func _on_state_changed(from_state: StringName, to_state: StringName) -> void:
	# Allow replay on future lives/respawns.
	if from_state == beaten_state_name and to_state != beaten_state_name:
		_played_for_current_beaten = false

	if to_state != beaten_state_name:
		return
	if _played_for_current_beaten:
		return

	_played_for_current_beaten = true
	_play()


func _play() -> void:
	if _player == null:
		return
	if _player.stream == null and beaten_stream != null:
		_player.stream = beaten_stream
	if _player.playing:
		_player.stop()
	_player.play()
