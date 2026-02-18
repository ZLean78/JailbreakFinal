## Plays combat SFX for the fighting player (Collins).
## Handles punch throw sounds, hit-by-punch/kick sounds, evade, and slash sounds.
class_name FightingPlayerAudioController
extends Node

## Character to listen to. If null, uses parent if it is a BaseCharacter.
@export var character: BaseCharacter

## Attack animation names that count as "punch" for SFX purposes.
@export var punch_attack_names: Array[String] = ["punch", "punch_alt"]

## Group name used by Kaluga characters/scenes.
@export var kaluga_group: StringName = &"kaluga"

## Sounds to play when the player is slashed by Sharaka (random selection).
var _hit_by_knife_streams: Array[AudioStream] = [
	preload("res://Sound/CollinsSlashed.ogg"),
	preload("res://Sound/collinsGetHitByKnife1.wav"),
	preload("res://Sound/collinsGetHitByKnife2.wav"),
]

## Group name used by Sharaka characters/scenes (if any).
@export var sharaka_group: StringName = &"sharaka"

## State name that triggers evade SFX.
@export var evade_state_name: StringName = &"Backdash"

# -- Sound arrays for random selection --
var _punch_streams: Array[AudioStream] = [
	preload("res://Sound/collinsPunch1.wav"),
	preload("res://Sound/collinsPunch2.wav"),
	preload("res://Sound/collinsPunch3.wav"),
]

var _hit_by_punch_streams: Array[AudioStream] = [
	preload("res://Sound/getHitByPunch1.ogg"),
	preload("res://Sound/getHitByPunch2.ogg"),
	preload("res://Sound/getHitByPunch3.ogg"),
	preload("res://Sound/getHitByPunch4.ogg"),
]

var _hit_by_kick_streams: Array[AudioStream] = [
	preload("res://Sound/getHitByKick1.ogg"),
	preload("res://Sound/getHitByKick2.ogg"),
	preload("res://Sound/getHitByKick3.ogg"),
]

var _evade_stream: AudioStream = preload("res://Sound/collinsEvade.wav")
var _kick_stream: AudioStream = preload("res://Sound/collinsStartKick.wav")

var _punch_player: AudioStreamPlayer
var _hit_player: AudioStreamPlayer
var _slashed_player: AudioStreamPlayer
var _evade_player: AudioStreamPlayer
var _kick_player: AudioStreamPlayer
var _is_bound: bool = false


func _ready() -> void:
	call_deferred("_bind")


func _bind() -> void:
	if _is_bound:
		return

	if character == null:
		var p := get_parent()
		if p is BaseCharacter:
			character = p

	if character == null:
		push_warning("FightingPlayerAudioController: No BaseCharacter found to bind to.")
		return

	_punch_player = _get_or_create_player(&"PunchSfx")
	_hit_player = _get_or_create_player(&"HitSfx")
	_slashed_player = _get_or_create_player(&"SlashedSfx")
	_evade_player = _get_or_create_player(&"EvadeSfx")
	_kick_player = _get_or_create_player(&"KickSfx")

	if character.combat_component == null:
		push_warning("FightingPlayerAudioController: Character has no CombatComponent.")
		return

	character.combat_component.attack_started.connect(_on_attack_started)

	# Connect to damage_receiver for DamageData (punch vs kick distinction).
	if character.damage_receiver and character.damage_receiver.has_signal("damage_received"):
		character.damage_receiver.damage_received.connect(_on_damage_received)

	# Connect to state machine for evade detection.
	if character.state_machine and character.state_machine.has_signal("state_changed"):
		character.state_machine.state_changed.connect(_on_state_changed)

	_is_bound = true


func _on_attack_started(attack_name: String, _combo_index: int) -> void:
	if attack_name not in punch_attack_names and not attack_name.begins_with("punch"):
		return
	_play_random(_punch_player, _punch_streams)


func _on_damage_received(damage_data: DamageData, _direction: Vector2, source: Node) -> void:
	if damage_data.amount <= 0:
		return

	if _is_sharaka_source(source):
		_play_random(_slashed_player, _hit_by_knife_streams)
	elif _is_kaluga_source(source):
		if damage_data.type == DamageTypes.Type.KNOCKDOWN:
			_play_random(_hit_player, _hit_by_kick_streams)
		else:
			_play_random(_hit_player, _hit_by_punch_streams)


func _on_state_changed(_from_state: StringName, to_state: StringName) -> void:
	if to_state == evade_state_name:
		_play_one_shot(_evade_player, _evade_stream)
	elif to_state == &"JumpAttack":
		_play_one_shot(_kick_player, _kick_stream)


func _is_kaluga_source(source: Node) -> bool:
	if source == null:
		return false
	if kaluga_group != &"" and source.is_in_group(String(kaluga_group)):
		return true
	var n := source.name.to_lower()
	if n.find("kaluga") != -1:
		return true
	if source is BaseCharacter:
		var bc := source as BaseCharacter
		if bc.config != null and bc.config.character_name.to_lower() == "kaluga":
			return true
	return false


func _is_sharaka_source(source: Node) -> bool:
	if source == null:
		return false
	if sharaka_group != &"" and source.is_in_group(String(sharaka_group)):
		return true
	var n := source.name.to_lower()
	if n.find("sharaka") != -1:
		return true
	if source is BaseCharacter:
		var bc := source as BaseCharacter
		if bc.config != null and bc.config.character_name.to_lower() == "sharaka":
			return true
	return false


func _play_random(p: AudioStreamPlayer, streams: Array[AudioStream]) -> void:
	if p == null or streams.is_empty():
		return
	p.stream = streams[randi() % streams.size()]
	if p.playing:
		p.stop()
	p.play()


func _play_one_shot(p: AudioStreamPlayer, stream: AudioStream) -> void:
	if p == null:
		return
	if p.stream == null and stream != null:
		p.stream = stream
	if p.playing:
		p.stop()
	p.play()


func _get_or_create_player(node_name: StringName) -> AudioStreamPlayer:
	var node_path := NodePath(String(node_name))
	var p := get_node_or_null(node_path) as AudioStreamPlayer
	if p == null:
		p = AudioStreamPlayer.new()
		p.name = String(node_name)
		p.bus = "SFX"
		add_child(p)
	return p
