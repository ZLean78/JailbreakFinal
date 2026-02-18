class_name Kaluga
extends Character2

@export var player:Player2
@export var chase_distance:float = 10.0
@export var attack_distance:float = 50.0
@export var disengage_distance:float = 150.0
@export var attack_cooldown:float = 1.25

@onready var aim:RayCast2D=$Aim
@onready var attack_timer:Timer=$AttackTimer
@onready var stun_timer:Timer=$StunTimer

var heading:Vector2 = Vector2.RIGHT
var ready_to_attack:bool=true

func _ready()->void:
	super._ready()
	ready_to_attack = true
	attack_timer.one_shot = true
	attack_timer.wait_time = attack_cooldown

func handle_ai(_delta:float)->void:
	if not _has_viable_target():
		_enter_idle()
		return

	if state == States.BEATEN:
		velocity = Vector2.ZERO
		return

	if state in [States.STUNNED, States.LAND, States.ATTACK]:
		velocity = Vector2.ZERO
		return

	var distance := position.distance_to(player.position)

	if ready_to_attack and can_attack() and distance <= attack_distance:
		attack()
	elif distance > disengage_distance:
		_enter_idle()
	elif distance > chase_distance:
		_move_towards_player()
	else:
		_hold_position()

	flip_aim()

func _has_viable_target()->bool:
	return is_instance_valid(player) and player.state != player.States.BEATEN

func _enter_idle()->void:
	state = States.IDLE
	velocity = Vector2.ZERO

func _move_towards_player()->void:
	var direction := (player.position - position).normalized()
	velocity = direction * speed
	state = States.WALK

func _hold_position()->void:
	velocity = Vector2.ZERO
	state = States.IDLE

func attack()->void:
	if not ready_to_attack or not _has_viable_target():
		return
	var direction := (player.position - position)
	if direction == Vector2.ZERO:
		direction = heading
	direction = direction.normalized()
	ready_to_attack = false
	attack_timer.start()
	state = States.FLY_ATTACK
	velocity = direction * flight_speed

func on_attack_complete()->void:
	state=States.IDLE
	velocity=Vector2.ZERO

func can_attack()->bool:
	if not _has_viable_target():
		return false
	if health>30:
		return aim.is_colliding() and aim.get_collider()==player
	return position.distance_to(player.position) <= attack_distance * 1.5

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
	ready_to_attack=true

func set_heading()->void:
	if player==null:
		return
	heading=Vector2.LEFT if global_position.x > player.global_position.x else Vector2.RIGHT
