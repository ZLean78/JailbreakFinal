extends CharacterBody2D


@export var pathfollow:PathFollow2D=null
@onready var animation_player=$AnimationPlayer

var active=false
var can_activate=false

func _process(_delta):
	if active:
		if pathfollow.progress<100:
			pathfollow.progress+=1
			animate()
	
func animate():
	animation_player.play("Run")
