extends Node2D

var active=false
var player_in_trap=false
@export var time:float=1.0
@onready var timer = $Timer
@onready var animation_player = $AnimationPlayer
@onready var player = %Player
@onready var ui = %UI

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.wait_time=time
	timer.start()

func _process(_delta):
	animate()
	check_trap()

func check_trap():
	if is_instance_valid(player):
		if player_in_trap && active:
			player.health-=25
			if ui and ui.has_method("update_health"):
				ui.update_health()
			_on_timer_timeout()

func animate():
	if active:
		animation_player.play("activate")
	else:
		animation_player.play("idle")


func _on_timer_timeout():
	active=!active
	timer.start()


func _on_area_2d_body_entered(body):
	if body == player:
		player_in_trap=true
	if body.is_in_group("guards"):
		body.queue_free()


func _on_area_2d_body_exited(body):
	if body == player:
		player_in_trap=false
