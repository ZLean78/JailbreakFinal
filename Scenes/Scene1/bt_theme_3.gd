extends Area2D

@export var Audio:AudioStreamPlayer=null



func _on_body_entered(body):
	if body.is_in_group("player"):
		if Audio.stream==load("res://Sound/La_Donna.ogg"):
			Audio.stream=load("res://Sound/intro3.wav")
			Audio.play()
