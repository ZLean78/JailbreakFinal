class_name BossEnemy
extends Character2

@export var player:Player2

@onready var aim:RayCast2D=$Aim
@onready var attack_timer:Timer=$AttackTimer
@onready var stun_timer:Timer=$StunTimer


var ready_to_attack=false


func _start()->void:
	attack_timer.start()
	


func handle_movement()->void:
	if !state==States.BEATEN:
		if !player.state==player.States.BEATEN:
			if can_attack() && !state==States.STUNNED:
				attack()
			else:
				if !state==States.STUNNED:
					if abs(position.distance_to(player.position))>10:
						var direction=(player.position-position).normalized()
						velocity=direction*speed
						state=States.WALK
					else:
						if ready_to_attack:
							state=States.ATTACK
				else:
					speed=0.0
					velocity=Vector2.ZERO
		else:
			state=States.IDLE
			speed=0.0
			velocity=Vector2.ZERO
	else:
		state=States.FLY
		await (get_tree().create_timer(2.0).timeout)
		state=States.BEATEN
		height = 0
		height_speed = 0
		speed=0
		velocity=Vector2.ZERO	
	flip_sprites()			
	flip_aim()
		

func attack()->void:
	if abs(position.distance_to(player.position))>10:
		if !state==States.ATTACK_COMPLETE:
			state=States.FLY_ATTACK
			var direction=(player.position-position).normalized()
			velocity=direction*flight_speed
	else:
		state=States.ATTACK_COMPLETE
	

func on_emit_damage(receiver:DamageReceiver2)->void:
	super.on_emit_damage(receiver)
	on_attack_complete()
	state==States.IDLE
	

func on_attack_complete()->void:
	state=States.ATTACK_COMPLETE
	
func can_attack()->bool:
	if health>30:
		return aim.is_colliding() && aim.get_collider()==player
	else:
		return abs(position.distance_to(player.position))<50
	
	
	
func is_attacking()->bool:
	return state==States.FLY_ATTACK
	
		

	


func flip_aim():
	if velocity.x<0:
		aim.scale.x=-1
	else:
		aim.scale.x=1
	


func _on_stun_timer_timeout():
	if state==States.STUNNED:
		state=States.IDLE
	stun_timer.start()


func _on_attack_timer_timeout():
	ready_to_attack=!ready_to_attack
