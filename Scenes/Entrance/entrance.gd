class_name Entrance
extends Node2D

@export var waterdrains:Node2D=null
@export var tilemap:TileMap=null
@export var tilemap2:TileMap=null
@export var tilemap3:TileMap=null
@export var stairs:Node2D=null
@export var animation_player:AnimationPlayer=null
@export var player_ref:CharacterBody2D=null
@export var Beds:Node2D=null
@export var noisy_obstacles:Node2D=null
@export var surveillance_cameras:Node2D=null
@onready var game_manager=%GameManager
@onready var player=%Player
@onready var help_sprite=%HelpSprite
@onready var main_label=%MainLabel
@onready var area = $Area2D
@onready var sprite = $Sprite




func _on_area_2d_body_entered(body):
	if body==player:
		help_sprite.texture=load("res://Scenes/UI/EntranceHelp.png")
		main_label.text="GATEAR,ENTRAR POR AGUJERO"
		if body.state==body.States.crawling && tilemap.self_modulate==Color(1.0,1.0,1.0,1.0):
			animation_player.play("fade")
			
func _on_area_2d_body_exited(_body):
	help_sprite.texture=null
	main_label.text=""			


func _on_animation_player_animation_finished(anim_name):
	if anim_name=="fade":
		#animation_player.stop()
		for waterdrain in waterdrains.get_children():
			waterdrain.visible=false
			waterdrain.area.set_collision_mask_value(2,false)
		for bed in Beds.get_children():
			bed.visible=false
			bed.set_collision_mask_value(2,false)
		for bottle in noisy_obstacles.get_children():
			bottle.visible=false
			bottle.area_2d.set_collision_mask_value(2,false)
		for camera in surveillance_cameras.get_children():
			camera.visible=false
		for stair in stairs.get_children():
			stair.visible=false
		tilemap.hide()
		tilemap.set_layer_enabled(0,false)
		tilemap2.set_layer_enabled(0,true)
		sprite.visible=false
