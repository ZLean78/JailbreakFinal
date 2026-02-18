class_name YellowKey
extends Node2D

@onready var player=%Player
@onready var ui=%UI
@onready var main_label=%MainLabel

func _on_area_2d_body_entered(body):
	if body == player:
		if !GameStates.has_yellow_key:
			GameStates.has_yellow_key=true
			GameStates.checkpoint=2
			for item in ui.items_container.get_children():
				if item.get_child(0).texture==load("res://Scenes/UI/emptycell.png"):
					item.get_child(0).texture=load("res://Scenes/UI/yellowkey.png")
					break
			queue_free()
		else:
			main_label.text="Ya tienes una llave como esa."
			await(get_tree().create_timer(2.0).timeout)
