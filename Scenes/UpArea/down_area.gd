class_name DownArea
extends Node2D

@export var player:CharacterBody2D=null
@export var tilemap:TileMap=null
@export var tilemap2:TileMap=null
@export var animation_player:AnimationPlayer=null
@export var waterdrains:Node2D=null
@export var entrance:Entrance=null
@export var conduct_railings:Node2D=null
@export var Beds:Node2D=null
@export var noisy_obstacles:Node2D=null
@onready var down_area=$DownArea
@onready var help_sprite=%HelpSprite
@onready var main_label=%MainLabel



		
		

func _on_animation_player_animation_finished(anim_name):
	if anim_name=="appear":
		for waterdrain in waterdrains.get_children():
			waterdrain.visible=true
			waterdrain.area.set_collision_mask_value(2,true)
		for conduct_railing in conduct_railings.get_children():
			conduct_railing.visible=true
		for bed in Beds.get_children():
			bed.visible=true
			bed.set_collision_mask_value(2,true)
		for bottle in noisy_obstacles.get_children():
			bottle.visible=true
			bottle.area_2d.set_collision_mask_value(2,true)
		entrance.visible=true
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
		for bottle in noisy_obstacles.get_children():
			bottle.visible=false
			bottle.area_2d.set_collision_mask_value(2,false)
		entrance.visible=false
		
		tilemap.hide()
		tilemap.set_layer_enabled(0,false)
		tilemap2.set_layer_enabled(0,true)





func _on_down_area_body_entered(body):
	if body==player:
		help_sprite.texture=load("res://Scenes/UI/HelpButtonE.png")
		main_label.text="BAJAR"
		if(tilemap.visible==true):
			animation_player.play("fade")
			player.can_control=false
			player.state=player.States.waiting
			await animation_player.animation_finished
			player.can_control=true
			player.state=player.States.crawl_idle


		
