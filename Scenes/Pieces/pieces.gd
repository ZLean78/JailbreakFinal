extends Node2D

@export var conduct_railing:Node2D=null
@onready var sprite=$Sprite2D

func _process(_delta):
	if conduct_railing.conduct_open:
		sprite.visible=true
	else:
		sprite.visible=false
