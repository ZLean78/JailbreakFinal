extends StaticBody2D

const LAYER_1=1
const LAYER_2=2

var is_dragged=false
var can_be_dragged=false
var drop_position=Vector2.ZERO

@export var player:CharacterBody2D

@onready var sprite = $Sprite2D
@onready var tree=get_tree().root.get_child(1)
@onready var animation_player = $AnimationPlayer




func _unhandled_key_input(event):
	if event.is_action_pressed("Interact"):
		if can_be_dragged && get_parent().conduct_open:
			is_dragged=!is_dragged
			if is_dragged:
				animation_player.play("open")
			else:
				animation_player.play_backwards("open")
		
		
		
func _on_area_2d_body_entered(body):	
	if body == player:
		if get_parent().conduct_open:
			can_be_dragged=true
		

func _on_area_2d_body_exited(body):
	if body == player:
		can_be_dragged=false
		
