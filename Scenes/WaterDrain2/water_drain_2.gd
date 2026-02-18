extends Node2D

var can_open=false
var is_open=false
@export var player:CharacterBody2D=null
@export var entrance:Entrance=null
@onready var animation_player = $AnimationPlayer
@onready var area = $Node2D/Area2D
@onready var help_sprite=%HelpSprite
@onready var main_label=%MainLabel

func _input(_event):
	if Input.is_action_pressed("Interact"):
		if can_open:
			if GameStates.has_letter1:
				if !is_open:
					is_open=true
					animation_player.play("open")
					entrance.area.set_collision_mask_value(1,false)
					entrance.area.set_collision_mask_value(2,true)
				else:
					is_open=false
					animation_player.play_backwards("open")
					entrance.area.set_collision_mask_value(1,true)
					entrance.area.set_collision_mask_value(2,false)


func _on_area_2d_body_entered(body):
	if body==player:
		if GameStates.has_letter1:
			can_open=true
			player.interaction_area_entered=true
			if !is_open:
				help_sprite.texture=load("res://Scenes/UI/HelpButtonE.png")
				main_label.text="INTERACTUAR"





func _on_area_2d_body_exited(body):
	if body==player:
		can_open=false
		player.interaction_area_entered=false
		help_sprite.texture=null
		main_label.text=""
