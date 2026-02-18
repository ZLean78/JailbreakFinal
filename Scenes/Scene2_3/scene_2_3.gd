extends Node2D

@export var enemy_name:Label=null

const INTRO_HELP_TEXTURE := preload("res://Scenes/UI/HelpKeys3.png")
const INTRO_HELP_TEXT := "SALTAR,PEGAR,AYUDA"




@onready var color_rect=%ColorRect
@onready var box_container=%BoxContainer
@onready var help_screen=$CanvasLayer/Help/CanvasLayer
@onready var help_sprite: Sprite2D = %HelpSprite
@onready var main_label: Label = %MainLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	enemy_name.text="SHARAKA"
	# Show the main help briefly at scene start (max 3 seconds).
	help_sprite.texture = INTRO_HELP_TEXTURE
	main_label.text = INTRO_HELP_TEXT
	await(get_tree().create_timer(3.0).timeout)
	# Clear only if nothing else replaced it.
	if help_sprite.texture == INTRO_HELP_TEXTURE and main_label.text == INTRO_HELP_TEXT:
		help_sprite.texture = null
		main_label.text = ""
	

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		get_tree().reload_current_scene()
		return
	if Input.is_action_pressed("UI"):
		color_rect.visible=!color_rect.visible
		box_container.visible=!box_container.visible
		set_tree_pause(get_tree().paused)
	if Input.is_action_pressed("Help"):
		help_screen.visible=!help_screen.visible
		set_tree_pause(get_tree().paused)
		
func set_tree_pause(paused:bool):
	if paused:
		get_tree().paused=false
	else:
		get_tree().paused=true
