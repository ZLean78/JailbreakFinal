class_name Door
extends Node2D

var open=false
var can_open_door=false
var trying_mother_door=false
@onready var player=%Player
@onready var help_sprite=%HelpSprite
@onready var main_label=%MainLabel

func _input(_event):
	if Input.is_action_just_pressed("Interact"):
		if player.interaction_area_entered && trying_mother_door:
			help_sprite.texture=null
			main_label.text="Cerrado..."
			

func _on_area_2d_body_entered(body):
	if body==player:
		body.interaction_area_entered=true
		trying_mother_door=true
		help_sprite.texture=load("res://Scenes/UI/HelpButtonE.png")
		main_label.text="INTERACTUAR"


func _on_area_2d_body_exited(body):
	if body==player:
		body.interaction_area_entered=false
		trying_mother_door=false
		help_sprite.texture=null
		main_label.text=""
