extends StaticBody2D


@export var prisoner2:CharacterBody2D=null
@onready var animation_player=$AnimationPlayer

func _start():
	animation_player.play("empty")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	animate()


func animate()->void:
	if prisoner2.state==prisoner2.States.hanging:
		animation_player.play("load")
	elif prisoner2.state==prisoner2.States.unhanging:
		animation_player.play("unload")
