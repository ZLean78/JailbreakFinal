class_name Door2
extends Node2D

var open=false
var can_open_door=false
@export var player:CharacterBody2D=null
@onready var animation_player=$AnimationPlayer
@onready var help_sprite=%HelpSprite
@onready var label=%MainLabel

func _input(_event):
	if Input.is_action_just_pressed("Interact"):
		if can_open_door:
			open=!open
			animate()
				
func animate():
	if open:
		animation_player.play("open")
	else:
		animation_player.play_backwards("open")

func _on_area_2d_body_entered(body):
	if body == player:
		can_open_door=true
		help_sprite.texture=load("res://Scenes/UI/HelpButtonE.png")
		label.text="INTERACTUAR"


func _on_area_2d_body_exited(body):
	if body == player:
		can_open_door=false
		help_sprite.texture=load("")
		label.text=""
		
