extends Node2D

var open=false
var player_in_trap=false
@export var time:float=1.0
@onready var timer = $Timer
@onready var animation_player = $AnimationPlayer
@onready var player = %Player



func _ready():
	timer.wait_time=time
	timer.start()

func _process(_delta):
	animate()
	check_trap()
	
func check_trap():
	if is_instance_valid(player):
		if player_in_trap && open:
			player.state=player.States.dead

func animate():
	if open:
		animation_player.play("open")
	else:
		animation_player.play("closed")


func _on_timer_timeout():
	open=!open
	timer.start()

func _on_area_2d_body_entered(body):
	if body == player:
		player_in_trap=true
	if body.is_in_group("guards"):
		body.queue_free()


func _on_area_2d_body_exited(body):
	if body == player:
		player_in_trap=false
