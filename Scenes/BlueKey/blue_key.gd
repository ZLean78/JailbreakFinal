class_name BlueKey
extends Node2D

@onready var player=%Player
@onready var ui=%UI


func _on_area_2d_body_entered(body):
	if body == player:
		GameStates.has_blue_key=true
		GameStates.checkpoint=1
		for item in ui.items_container.get_children():
			if item.get_child(0).texture==load("res://Scenes/UI/emptycell.png"):
				item.get_child(0).texture=load("res://Scenes/UI/bluekey.png")
				break
		queue_free()
