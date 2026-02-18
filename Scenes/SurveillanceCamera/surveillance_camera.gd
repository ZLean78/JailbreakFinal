extends Node2D


@export var camera_type:int=0
@export var player:CharacterBody2D=null

@onready var sprite = $Sprite2D
@onready var animation_player=$AnimationPlayer
@onready var ray=$Node2D/Ray
@onready var ray2=$Node2D/Ray2
@onready var ray3=$Node2D/Ray3
@onready var timer=$Timer
var must_rotate=false
# Called when the node enters the scene tree for the first time.

func _ready():
	timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta)->void:
	if is_instance_valid(player):
		animate()
		check_rays()


func animate()->void:
	if camera_type==1:
		if must_rotate:
			animation_player.play("slow_turn")
		else:
			animation_player.play("still")
	elif camera_type==2:
		if must_rotate:
			animation_player.play("turn")
		else:
			animation_player.play("still")

func check_rays()->void:
	if ray.get_collider()==player||ray2.get_collider()==player||ray3.get_collider()==player:
		player.state=player.States.dead
		sprite.texture=load("res://Scenes/SurveillanceCamera/SC_Red.png")
		


func _on_timer_timeout():
	must_rotate=!must_rotate
	timer.start()
