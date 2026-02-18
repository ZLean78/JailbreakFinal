class_name Bottle
extends Node2D

@export var player:CharacterBody2D=null
@onready var area_2d:Area2D=$Area2D

func _on_area_2d_body_entered(body):
	if body==player:
		GameStates.player_has_made_noise=true
		await (get_tree().create_timer(2.0).timeout)
		GameStates.player_has_made_noise=false
