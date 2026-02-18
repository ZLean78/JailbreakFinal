class_name Dog
extends CharacterBody2D

const SPEED = 60.0
const BackwardIntensity = 80

@export var meat:Meat
@export var player:CharacterBody2D

@onready var animation_player:=$AnimationPlayer
@onready var damage_area:=$DamageArea
@onready var damage_timer:=$DamageTimer
@onready var tail_objective:=$TailObjective
@onready var tail_objective_timer:=$TailOjectiveTimer


var can_chase=false
var is_damaging_player=false
var is_following_path=false

func _process(_delta):
	move_towards_objective()
	move_and_slide()
		
func move_towards_objective()->void:
	var objective
	if can_chase:
		if meat==null:
			objective=player
		else:
			objective=meat
	else:
		objective=tail_objective
		
	if position.distance_to(objective.position)>10:
		velocity=position.direction_to(objective.position)*SPEED
	
			
		if abs(velocity.x)>abs(velocity.y):
			if velocity.x>0:
				animation_player.play("walk_right")
				damage_area.rotation=deg_to_rad(0)
			else:
				animation_player.play("walk_left")
				damage_area.rotation=deg_to_rad(180)
		if abs(velocity.y)>abs(velocity.x):
			if velocity.y>0:
				animation_player.play("walk_down")
				damage_area.rotation=deg_to_rad(90)
			else:
				animation_player.play("walk_up")
				damage_area.rotation=deg_to_rad(-90)
	else:
		velocity=Vector2.ZERO
				
		


func _on_damage_area_body_entered(body):
	if body.is_in_group("player"):
		is_damaging_player=true
			
func _on_damage_area_body_exited(body):
	if body.is_in_group("player"):
		is_damaging_player=false		


func _on_damage_timer_timeout():
	if is_damaging_player:
		player.health-=5
		get_tree().get_nodes_in_group("UI")[0].update_health()
		can_chase=false
		tail_objective_timer.start()
		damage_timer.start()

func _on_tail_ojective_timer_timeout():
	can_chase=true
