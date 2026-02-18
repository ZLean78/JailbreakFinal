class_name Character2
extends CharacterBody2D

const GRAVITY:float=600.0

@export var damage:float
@export var health:float
@export var flight_speed:float
@export var jump_intensity:float
@export var speed:float
@export var throwback_intensity:float

@onready var animation_player:=$"AnimationPlayer"
@onready var character_sprite:=$CharacterSprite
@onready var damage_emitter:=$DamageEmitter
@onready var damage_receiver:DamageReceiver2=$DamageReceiver

enum States{IDLE,WALK,ATTACK,TAKEOFF,JUMP,LAND,JUMPKICK,HURT,ATTACK_COMPLETE,FLY_ATTACK,FLY,STUNNED,ROLL,BEATEN}

var can_get_stunned=false
var height:float=0.0
var height_speed:float=0.0
var state:=States.IDLE
var sense:int=1


var anim_map:={
	States.IDLE:"idle",
	States.WALK:"walk",
	States.ATTACK:"punch",
	States.TAKEOFF:"takeoff",
	States.JUMP:"jump",
	States.LAND:"land",
	States.JUMPKICK:"jumpkick",
	States.HURT:"hurt",
	States.ATTACK_COMPLETE:"attack_complete",
	States.FLY_ATTACK:"attack",
	States.FLY:"fly",
	States.STUNNED:"stunned",
	States.ROLL:"roll",
	States.BEATEN:"beaten"
}

func _ready()->void:
	#capturar la señal de colisión con damage receiver
	damage_emitter.area_entered.connect(on_emit_damage.bind())
	#capturar la señal de colisión con damage emitter
	damage_receiver.damage_received.connect(on_receive_damage.bind())

func _process(delta:float)->void:
	handle_input()
	handle_movement()
	handle_air_time(delta)
	handle_animations()
	flip_sprites()	
	if state==States.FLY:
		apply_impulse(delta,get_sense())
	
	character_sprite.position=Vector2.UP*height
	move_and_slide()
	check_health()
	#print(height)
		

func handle_air_time(delta:float)->void:
	if state==States.JUMP || state==States.JUMPKICK:
		height+=height_speed*delta
		if height<0:
			height=0
			state=States.LAND
		else:
			height_speed-=GRAVITY*delta
	
func handle_movement()->void:
	if !state==States.BEATEN:
		if can_move():
			if velocity.length()==0:
				state=States.IDLE
			else:
				if !(state==States.FLY_ATTACK):
					state=States.WALK
	else:
		state=States.FLY
		await (get_tree().create_timer(2.0).timeout)
		state=States.BEATEN
		height = 0
		height_speed = 0
		speed=0
		velocity=Vector2.ZERO
	
	
		
func handle_input()->void:
	pass

func handle_animations()->void:
	if animation_player.has_animation(anim_map[state]):
		animation_player.play(anim_map[state])


func flip_sprites()->void:
	if velocity.x > 0:
		character_sprite.flip_h=false
		damage_emitter.scale.x=1
	if velocity.x < 0:
		character_sprite.flip_h=true
		damage_emitter.scale.x=-1
	
	

func can_attack()->bool:
	return state==States.IDLE || state==States.WALK
	
func can_jump()->bool:
	return state==States.IDLE || state==States.WALK
	
func can_jumpkick()->bool:
	return state==States.JUMP

func can_move()->bool:
	return state==States.IDLE || state==States.WALK

func on_action_complete()->void:
	state=States.IDLE

func on_takeoff_complete()->void:
	state=States.JUMP
	height_speed=jump_intensity
	

	
func on_land_complete()->void:
	state=States.IDLE
	
func on_receive_damage(amount:int)->void:
	if !state==States.JUMP && !state==States.ROLL && !state==States.LAND:
		state=States.HURT
		health-=amount
		if self.is_in_group("player"):
			state=States.FLY
	
	

func on_emit_damage(receiver:DamageReceiver2)->void:
	if !state==States.BEATEN:
		receiver.damage_received.emit(damage)
		#receiver.emit_signal("damage_received",damage)

func on_fly_started()->void:
	height_speed=jump_intensity
	

	
func on_fly_complete()->void:
	if self.is_in_group("player"):
		state=States.IDLE
	else:
		state=States.BEATEN	
		
	
	


func apply_impulse(delta: float, sense: int) -> void:
	velocity.x = speed * sense
	height += height_speed * delta

	if height <= 0:
		height = 0
		height_speed = 0
	else:
		height_speed -= GRAVITY * delta
	
	
func get_sense()->int:
	if damage_emitter.scale.x==1:
		return 1
	else:
		return -1

func check_health()->void:
	if health<=0:
		state=States.BEATEN
