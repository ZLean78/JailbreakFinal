class_name UpArea
extends Node2D

@export var player:CharacterBody2D=null
@export var tilemap:TileMap=null
@export var tilemap2:TileMap=null
@export var animation_player:AnimationPlayer=null
@export var waterdrains:Node2D=null
@export var entrance:Entrance=null

@onready var up_area = $UpArea



func _on_up_area_body_entered(body):
	if body==player:
		print("Vector2("+str(body.direction.x)+","+str(body.direction.y)+")")
		if body.direction==Vector2(1,0):
			print("animating appear")
			animation_player.play("appear")
		if body.direction==Vector2(0,1)||body.direction==Vector2(0,-1):
			animation_player.play("fade")
		
			










func _on_animation_player_animation_finished(anim_name):
	if anim_name=="appear":
		for waterdrain in waterdrains.get_children():
			waterdrain.visible=true
			waterdrain.area.set_collision_mask_value(2,true)
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
		entrance.visible=false
		
		tilemap.hide()
		tilemap.set_layer_enabled(0,false)
		tilemap2.set_layer_enabled(0,true)
	
	
	
	
	
		



		
