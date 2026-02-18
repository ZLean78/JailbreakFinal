extends Node2D

@onready var color_rect=%ColorRect
@onready var box_container=%BoxContainer
@onready var player=%Player

const CHECKPOINT_SCENE_2_4 := 8


func _ready():
	# Save checkpoint for this chapter so Continue loads Scene2_4.
	if int(GameStates.checkpoint) < CHECKPOINT_SCENE_2_4:
		GameStates.checkpoint = CHECKPOINT_SCENE_2_4
		GameStates.save_to_file()

	GameStates.has_red_key=true
	player.direction=Vector2(1,0)
	player.sprite.rotation=deg_to_rad(90)
	

	


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
