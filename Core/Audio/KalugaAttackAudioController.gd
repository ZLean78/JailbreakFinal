## Plays Kaluga's combat SFX: attack sounds, hit-by-punch/kick sounds, and fall-after-kick.
class_name KalugaAttackAudioController
extends Node

## Character to listen to. If null, uses parent if it is a BaseCharacter.
@export var character: BaseCharacter

## Attack animation names that should trigger this SFX.
## Kaluga uses "attack" by default.
@export var attack_names: Array[String] = ["attack"]

## State name that represents Kaluga's punch/attack.
## Boss AI transitions to this state directly (bypassing CombatComponent.start_attack()).
@export var attack_state_name: StringName = &"Attack"

## Audio stream to play when Kaluga attacks.
@export var attack_stream: AudioStream = preload("res://Sound/KalugaThrowPunch.ogg")

## Group name used by the fighting player character scenes.
@export var player_group: StringName = &"player"

# -- Sound arrays for random selection when Kaluga gets hit --
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

var _fall_after_kick_stream: AudioStream = preload("res://Sound/kalugaFallAfterKick.ogg")

var _attack_player: AudioStreamPlayer
var _hit_player: AudioStreamPlayer
var _fall_player: AudioStreamPlayer
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
		push_warning("KalugaAttackAudioController: No BaseCharacter found to bind to.")
		return

	if character.combat_component == null:
		push_warning("KalugaAttackAudioController: Character has no CombatComponent.")

	_attack_player = _get_or_create_player(&"KalugaAttackSfx")
	_hit_player = _get_or_create_player(&"KalugaHitSfx")
	_fall_player = _get_or_create_player(&"KalugaFallSfx")

	# Primary: play when the state machine enters Attack (works for boss AI path).
	if character.state_machine and character.state_machine.has_signal("state_changed"):
		character.state_machine.state_changed.connect(_on_state_changed)

	# Fallback: play when CombatComponent emits attack_started (works for input-driven characters).
	if character.combat_component != null:
		character.combat_component.attack_started.connect(_on_attack_started)

	# Play hit SFX when Kaluga receives a hit from the player.
	if character.damage_receiver and character.damage_receiver.has_signal("damage_received"):
		character.damage_receiver.damage_received.connect(_on_damage_received)
	_is_bound = true


func _on_attack_started(attack_name: String, _combo_index: int) -> void:
	if not attack_names.is_empty():
		if attack_name not in attack_names:
			return
	_play_attack_sfx()


func _on_state_changed(_from_state: StringName, to_state: StringName) -> void:
	if to_state == attack_state_name:
		_play_attack_sfx()

	# Play fall sound when Kaluga is defeated.
	if to_state == &"Beaten":
		_play_one_shot(_fall_player, _fall_after_kick_stream)


func _play_attack_sfx() -> void:
	if _attack_player == null:
		return
	if _attack_player.stream == null and attack_stream != null:
		_attack_player.stream = attack_stream
	if _attack_player.playing:
		_attack_player.stop()
	_attack_player.play()


func _on_damage_received(damage_data: DamageData, _direction: Vector2, source: Node) -> void:
	if not _is_player_source(source):
		return

	if damage_data.type == DamageTypes.Type.KNOCKDOWN:
		_play_random(_hit_player, _hit_by_kick_streams)
	else:
		_play_random(_hit_player, _hit_by_punch_streams)


func _is_player_source(source: Node) -> bool:
	if source == null:
		return false
	if player_group != &"" and source.is_in_group(String(player_group)):
		return true
	if source is BaseCharacter:
		var bc := source as BaseCharacter
		if bc.config != null and bc.config.is_player:
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
