class_name Lever
extends Node2D

@export var hole:Hole=null
@onready var animation_player=$AnimationPlayer

signal is_activated
signal is_deactivated

# Called when the node enters the scene tree for the first time.
func _ready()->void:
	is_activated.connect(on_activate.bind())
	is_deactivated.connect(on_deactivate.bind())
	_setup_damage_receiver()
	_setup_activation_sfx()
	animation_player.animation_finished.connect(_on_animation_finished)
	if hole:
		_connect_hole_timer.call_deferred()


func _setup_activation_sfx() -> void:
	_activation_sfx = AudioStreamPlayer.new()
	_activation_sfx.name = "ActivationSfx"
	_activation_sfx.stream = preload("res://Sound/leverActivation.wav")
	_activation_sfx.bus = "SFX"
	add_child(_activation_sfx)


func _connect_hole_timer() -> void:
	hole.activated_timer.timeout.connect(on_deactivate)


func _setup_damage_receiver() -> void:
	var area: Area2D = $Area
	var area_shape: CollisionShape2D = $Area/CollisionShape2D

	var receiver := DamageReceiver.new()
	receiver.name = "DamageReceiver"
	receiver.collision_layer = 32  # Layer 6 - detectable by player's DamageEmitter
	receiver.collision_mask = 0
	receiver.monitoring = false
	receiver.position = area.position

	var shape := CollisionShape2D.new()
	shape.shape = area_shape.shape.duplicate()
	shape.position = area_shape.position
	receiver.add_child(shape)

	add_child(receiver)
	receiver.damage_received.connect(_on_punched)
	_damage_receiver = receiver


var _damage_receiver: DamageReceiver
var _lever_active: bool = false
var _activation_sfx: AudioStreamPlayer


@export var activation_y_range: float = 10.0

func _on_punched(_damage_data: DamageData, _direction: Vector2, source: Node) -> void:
	if is_instance_valid(source):
		var y_diff := absf(source.global_position.y - global_position.y)
		if y_diff > activation_y_range:
			return
	emit_signal("is_activated")

func on_activate()->void:
	if _lever_active:
		return
	_lever_active = true
	hole.particles.emitting=true
	hole.is_activated=true
	hole.activated_timer.start()
	animation_player.play("activate")
	_damage_receiver.disable()
	if _activation_sfx:
		_activation_sfx.play()


func on_deactivate()->void:
	if not _lever_active:
		return
	_lever_active = false
	hole.activated_timer.stop()
	hole.particles.emitting=false
	hole.is_activated=false
	animation_player.play("deactivate")


func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == &"deactivate":
		_damage_receiver.enable()
