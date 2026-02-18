extends Area2D

@export var Audio:AudioStreamPlayer=null



func _on_body_entered(body):
	if body.is_in_group("player"):
		Audio.stream=load("res://Sound/goal.wav")
		Audio.play()
