class_name BlueDoor
extends Door


@onready var animation_player = $AnimationPlayer


func _input(_event):
	if Input.is_action_just_pressed("Interact"):
		if can_open_door:
			if GameStates.has_blue_key:
				open=!open
				animate()
			else:
				help_sprite.texture=null
				main_label.text="Cerrado..."
				
func animate():
	if open:
		animation_player.play("open")
	else:
		animation_player.play_backwards("open")

func _on_area_2d_body_entered(body):
	if body == player:
		body.interaction_area_entered=true
		can_open_door=true
		help_sprite.texture=load("res://Scenes/UI/HelpButtonE.png")
		main_label.text="INTERACTUAR"


func _on_area_2d_body_exited(body):
	if body == player:
		body.interaction_area_entered=false
		can_open_door=false
		help_sprite.texture=null
		main_label.text=""
