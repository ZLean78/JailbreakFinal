class_name Wax
extends Node2D

@onready var player=%Player
@onready var label=%MainLabel
@onready var ui=%UI


func _on_area_2d_body_entered(body):
	if body==player:
		GameStates.has_wax=true
		label.text="Tienes pomada negra."
		for item in ui.items_container.get_children():
			if item.get_child(0).texture==load("res://Scenes/UI/emptycell.png"):
				item.get_child(0).texture=load("res://Scenes/UI/wax.png")
				break
		self.visible=false
		await(get_tree().create_timer(3.0).timeout)
		label.text=""
		queue_free()
