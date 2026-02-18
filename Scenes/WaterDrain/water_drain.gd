class_name WaterDrain
extends Node2D

const SFX_GRID_OPEN = preload("res://Sound/sfxGridOpen.ogg")

@export var player:CharacterBody2D=null
@onready var game_manager=%GameManager
@onready var area = $Area2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready():
	if audio_player:
		audio_player.bus = "SFX"
		audio_player.stream = SFX_GRID_OPEN

func _on_area_2d_body_entered(body):
	if body==player:
		game_manager.make_waterdrain_noise=true
		if audio_player:
			audio_player.play()


func _on_area_2d_body_exited(body):
	if body==player:
		game_manager.make_waterdrain_noise=false
