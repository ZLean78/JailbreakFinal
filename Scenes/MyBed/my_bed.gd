class_name MyBed
extends Node2D
@onready var player=%Player
@onready var animated_sprite = $AnimatedSprite2D


func _on_area_2d_body_entered(body):
	if body==player:
		animated_sprite.play("InBed")


func _on_area_2d_body_exited(body):
	if body==player:
		animated_sprite.play("default")
