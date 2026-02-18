extends Node2D

@onready var timer=$Timer

const CinematicLoaderScene = preload("res://Core/Cinematics/CinematicLoader.tscn")

var _transitioning := false

func _ready():
	timer.start()

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER or event.keycode == KEY_ESCAPE:
			load_intro()

func load_intro():
	if _transitioning:
		return
	_transitioning = true
	var loader = CinematicLoaderScene.instantiate()
	loader.cinematic_path = "res://Cinematics/intro"
	get_tree().root.add_child(loader)
	get_tree().current_scene = loader
	queue_free()


func _on_timer_timeout():
	load_intro()
