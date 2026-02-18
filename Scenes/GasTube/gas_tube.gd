extends StaticBody2D

@onready var player=%Player
@onready var ui=%UI
@onready var animation_player=$AnimationPlayer
@onready var sprite = $Sprite2D
@onready var timer = $Timer
@export var time:float=1.0
var can_throw_gas=false

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.wait_time=time
	timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	animate()


func _on_timer_timeout():
	can_throw_gas=!can_throw_gas
	timer.start()


func animate():
	if can_throw_gas:
		animation_player.play("throw_gas")
	else:
		animation_player.play("empty")


func _on_area_2d_body_entered(body):
	if is_instance_valid(player):
		if body == player && can_throw_gas && !GameStates.mask_on:
			player.health-=25
			if ui and ui.has_method("update_health"):
				ui.update_health()
			_on_timer_timeout()
		if body.is_in_group("guards") && can_throw_gas:
			body.queue_free()
