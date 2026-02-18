extends Node2D

@export var player:CharacterBody2D=null


func _on_area_2d_body_entered(body):
	if body==player:
		GameStates.has_letter1=true
		queue_free()
