class_name WhiteDoor
extends Door


@onready var animation_player = $AnimationPlayer


func _input(_event):
	if Input.is_action_just_pressed("Interact"):
		if can_open_door:
			if GameStates.has_white_key:
				if get_tree().root.get_child(2).name!="Scene2":
					open=!open
					animate()
				else:
					main_label.text="No puedo volver atrás."
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
		player.interaction_area_entered=true
		can_open_door=true
		help_sprite.texture=load("res://Scenes/UI/HelpButtonE.png")
		main_label.text="INTERACTUAR"

func _on_area_2d_body_exited(body):
	if body == player:
		player.interaction_area_entered=false
		can_open_door=false
		help_sprite.texture=null
		main_label.text=""
