class_name InOutArea
extends Area2D


@export var cell:int=0
@export var player:CharacterBody2D=null

func _on_body_entered(body):
	if body==player:
		body.cell=cell
