extends Node2D

@export var player:CharacterBody2D=null
@onready var ui=%UI

func _on_area_2d_body_entered(body):
	if body==player:
		GameStates.first_aid+=1
		if ui and ui.has_method("update_items"):
			ui.update_items()
		queue_free()
