class_name Player2
extends Character2

@export var lever:Lever=null
@onready var stun_timer:Timer=$StunTimer

var can_interact:bool=false


var double_tap_time = 300  # tiempo máximo entre toques (en milisegundos)
var last_tap_time = 0
var tap_direction = ""

func handle_input()->void:
	if state!=States.FLY:
		var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

		if Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("ui_left"):
			var current_time = Time.get_ticks_msec()
			var current_direction = "right" if Input.is_action_just_pressed("ui_right") else "left"

			if current_direction == tap_direction and current_time - last_tap_time <= double_tap_time:
				state = States.ROLL
				last_tap_time = 0  # reinicia para evitar múltiples activaciones
				tap_direction = ""
			else:
				tap_direction = current_direction
				last_tap_time = current_time
		if state==States.ROLL:
			velocity=direction*speed*2
		else:
			velocity=direction*speed	
	if Input.is_action_just_pressed("Attack") and can_attack():
		state=States.ATTACK
	if Input.is_action_just_pressed("Jump") and can_jump():
		state=States.TAKEOFF
	if Input.is_action_just_pressed("Attack") and can_jumpkick():
		state=States.JUMPKICK
	if Input.is_action_just_pressed("Interact") and can_interact:
		
		activate_lever()
		
	if state==States.STUNNED:
		stun_timer.start()	

func activate_lever():
	lever.animation_player.play("activate")
	lever.emit_signal("is_activated")


func _on_stun_timer_timeout():
	if state==States.STUNNED:
		state=States.IDLE
