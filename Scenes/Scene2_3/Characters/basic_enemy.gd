class_name BasicEnemy
extends Character


@export var player:Player
@onready var attack_timer:=$AttackTimer



func handle_input(delta:float)->void:
	if state!=State.ATTACK && state!=State.HURT:
		if player.position.distance_to(position)>12:
			state=State.WALK
			var direction = (player.position - position).normalized()
			velocity += direction * speed * delta
		elif player.position.distance_to(position)<=12:
			state=State.IDLE
			velocity=Vector2.ZERO
			
				


func _on_attack_timer_timeout():
	if state==State.IDLE && state!=State.HURT:
		state=State.ATTACK
		attack_timer.start()
