extends Node

var has_discovered=false

func _input(_event):
	if Input.is_action_pressed("Discover"):
		has_discovered=true
		get_parent().get_node("CameraLimitMax").position=Vector2(863.0,456.0)
