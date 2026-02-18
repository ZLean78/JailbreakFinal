extends StaticBody2D


@export var player:CharacterBody2D=null
@onready var collision_shape=$CollisionShape2D

func _physics_process(_delta):
	if is_instance_valid(self) && is_instance_valid(player):
		if player.state==player.States.crawl_idle || player.state==player.States.crawling:
			collision_shape.disabled=true
		else:
			collision_shape.disabled=false
