extends StaticBody2D


@export var player:CharacterBody2D=null
@export var prisoner:CharacterBody2D=null
@export var prisoner2:CharacterBody2D=null
@onready var animation_player=$AnimationPlayer
@onready var light_occluder=$CollisionShape2D/LightOccluder2D

func _physics_process(delta):
	if is_instance_valid(player):
		if player.state==player.States.crawl_idle || player.state==player.States.crawling:
			light_occluder.visible=true
		else:
			light_occluder.visible=false

func _on_area_2d_body_entered(body):
	if body==prisoner:
		animation_player.play("OpenClose")
		body.state=body.States.loading
	if body==prisoner2:
		animation_player.play("OpenClose")
		body.state=body.States.unloading


func _on_area_2d_body_exited(body):
	if body==prisoner || body==prisoner2:
		animation_player.play_backwards("OpenClose")
