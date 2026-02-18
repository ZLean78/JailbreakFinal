extends StaticBody2D

@export var rahiri:CharacterBody2D=null
@export var player:CharacterBody2D=null


@onready var collision_shape=$CollisionShape2D
@onready var animation_player=$AnimationPlayer



var rahiri_sleeping=true





# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	check_collision_shape()
	animate()


func animate():
	if rahiri_sleeping:
		animation_player.play("Sleep")
	else:
		animation_player.play("empty")
		
func check_collision_shape():
	if player.state==player.States.crawl_idle || player.state==player.States.crawling:
		collision_shape.disabled=true
	else:
		collision_shape.disabled=false

func _on_area_2d_body_entered(body):
	if body==rahiri:
		rahiri_sleeping=true
	
		


func _on_area_2d_body_exited(_body):
	rahiri_sleeping=false
