## Plays Sharaka's combat SFX: knife slash sounds and hit-by-punch/kick sounds.
class_name SharakaAttackAudioController
extends Node

## Character to listen to. If null, uses parent if it is a BaseCharacter.
@export var character: BaseCharacter

## Attack animation names that count as "knife" for SFX purposes.
## In the Sharaka scene, knife stab animations are named "punch" / "punch_alt".
@export var knife_attack_names: Array[String] = ["punch", "punch_alt"]

## State name that represents attack state.
@export var attack_state_name: StringName = &"Attack"

## Audio stream to play when Sharaka slashes.
@export var slash_stream: AudioStream = preload("res://Sound/sharakaKnifeSlash.ogg")

## Group name used by the fighting player character scenes.
@export var player_group: StringName = &"player"

# -- Sound arrays for random selection when Sharaka gets hit --
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

var _slash_player: AudioStreamPlayer
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
		push_warning("SharakaAttackAudioController: No BaseCharacter found to bind to.")
		return

	_slash_player = _get_or_create_player(&"SharakaSlashSfx")
	_hit_player = _get_or_create_player(&"SharakaHitSfx")
	_fall_player = _get_or_create_player(&"SharakaFallSfx")

	# Primary: play when CombatComponent attack starts (gives attack animation name).
	if character.combat_component != null:
		character.combat_component.attack_started.connect(_on_attack_started)

	# Fallback: play when entering Attack state, using current attack animation name if available.
	if character.state_machine and character.state_machine.has_signal("state_changed"):
		character.state_machine.state_changed.connect(_on_state_changed)

	# Play hit SFX when Sharaka receives a hit from the player.
	if character.damage_receiver and character.damage_receiver.has_signal("damage_received"):
		character.damage_receiver.damage_received.connect(_on_damage_received)

	_is_bound = true


func _on_attack_started(attack_name: String, _combo_index: int) -> void:
	if attack_name in knife_attack_names:
		_play_one_shot(_slash_player, slash_stream)


func _on_state_changed(_from_state: StringName, to_state: StringName) -> void:
	if to_state == &"Grounded":
		_play_one_shot(_fall_player, _fall_after_kick_stream)
		return

	if to_state != attack_state_name:
		return

	# Try to filter to knife-only attacks.
	var attack_anim := ""
	if character.combat_component != null:
		attack_anim = character.combat_component.get_current_attack_animation()

	if attack_anim != "" and attack_anim not in knife_attack_names:
		return

	_play_one_shot(_slash_player, slash_stream)


func _on_damage_received(damage_data: DamageData, _direction: Vector2, source: Node) -> void:
	if damage_data == null or damage_data.amount <= 0:
		return
	if not _is_player_source(source):
		return

	if damage_data.type == DamageTypes.Type.KNOCKDOWN:
		_play_random(_hit_player, _hit_by_kick_streams)
	else:
		_play_random(_hit_player, _hit_by_punch_streams)


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


func _get_or_create_player(node_name: StringName) -> AudioStreamPlayer:
	var node_path := NodePath(String(node_name))
	var p := get_node_or_null(node_path) as AudioStreamPlayer
	if p == null:
		p = AudioStreamPlayer.new()
		p.name = String(node_name)
		p.bus = "SFX"
		add_child(p)
	return p
