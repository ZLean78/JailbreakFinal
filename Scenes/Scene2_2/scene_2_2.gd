extends Node2D

@onready var color_rect=%ColorRect
@onready var box_container=%BoxContainer
@onready var player_point_light=$"Pausable/Player/PointLight2D"

func _ready():
	GameStates.uniform_on=false
	player_point_light.enabled=false

func _input(_event):
	if Input.is_action_pressed("UI"):
		color_rect.visible=!color_rect.visible
		box_container.visible=!box_container.visible
		set_tree_pause(get_tree().paused)
		
		
func set_tree_pause(paused:bool):
	if paused:
		get_tree().paused=false
	else:
		get_tree().paused=true
