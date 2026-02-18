class_name UpArea2
extends Node2D


@export var tilemap:TileMap=null
@export var tilemap2:TileMap=null
@export var animation_player:AnimationPlayer=null
@export var waterdrains:Node2D=null
@export var entrance:Entrance=null
@export var conduct_railings:Node2D=null
@export var Beds:Node2D=null
@export var noisy_obstacles:Node2D=null
@export var surveillance_cameras:Node2D=null
@onready var up_area = $UpArea
@onready var player=%Player
@onready var help_sprite=%HelpSprite
@onready var main_label=%MainLabel
var can_go_up=false




func _process(_delta):
	if Input.is_action_just_pressed("Interact") && can_go_up:
		player.position=Vector2(position.x,position.y-20)
		player.can_control=false
		animation_player.play("appear")
		await animation_player.animation_finished
		player.can_control=true
#func _on_up_area_body_entered(body):
	#if body==player:
		#print("Vector2("+str(body.direction.x)+","+str(body.direction.y)+")")
		#if body.direction==Vector2(-1,0):
			#print("animating appear")
			#animation_player.play("appear")
		#if body.direction==Vector2(1,0):
			#print("animating appear")
			#animation_player.play("fade")
		#if body.direction==Vector2(0,1)||body.direction==Vector2(0,-1):
			##if tilemap.self_modulate==Color(1.0,1.0,1.0,1.0):
			#animation_player.play("fade")
		
	

func _on_animation_player_animation_finished(anim_name):
	if anim_name=="appear":
		for waterdrain in waterdrains.get_children():
			waterdrain.visible=true
			waterdrain.area.set_collision_mask_value(2,true)
		for conduct_railing in conduct_railings.get_children():
			conduct_railing.visible=true
		entrance.visible=true
		for bed in Beds.get_children():
			bed.visible=true
			bed.set_collision_mask_value(2,true)
		for bottle in noisy_obstacles.get_children():
			bottle.visible=true
			bottle.area_2d.set_collision_mask_value(2,true)	
		for camera in surveillance_cameras.get_children():
			camera.visible=true
		entrance.sprite.visible=true
		entrance.area.set_collision_mask_value(2,true)
		tilemap.show()
		tilemap.set_layer_enabled(0,true)
		tilemap2.set_layer_enabled(0,false)
		
	if anim_name=="fade":
		for waterdrain in waterdrains.get_children():
			waterdrain.visible=false
			waterdrain.area.set_collision_mask_value(2,false)
		for conduct_railing in conduct_railings.get_children():
			conduct_railing.visible=false
		for bed in Beds.get_children():
			bed.visible=false
			bed.set_collision_mask_value(2,false)
		entrance.visible=false
		for bottle in noisy_obstacles.get_children():
			bottle.visible=false
			bottle.area_2d.set_collision_mask_value(2,false)	
		for camera in surveillance_cameras.get_children():
			camera.visible=true
		tilemap.hide()
		tilemap.set_layer_enabled(0,false)
		tilemap2.set_layer_enabled(0,true)


func _on_up_area_body_entered(body):
	if body==player:
		body.interaction_area_entered=true
		can_go_up=true
		help_sprite.texture=load("res://Scenes/UI/HelpButtonE.png")
		main_label.text="SUBIR"


func _on_up_area_body_exited(body):
	if body==player:
		body.interaction_area_entered=false
		can_go_up=false
		help_sprite.texture=null
		main_label.text=""
