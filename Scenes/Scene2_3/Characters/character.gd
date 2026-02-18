class_name Character
extends CharacterBody2D

@export var health:int
@export var damage:int
@export var knockback_intensity:int
@export var GRAVITY:int
@export var JUMP_FORCE:int
@export var speed:float
var sprite_velocity:float
var heading:Vector2


@onready var animation_player:=$AnimationPlayer
@onready var character_sprite:=$CharacterSprite
@onready var damage_emitter:=$DamageEmitter
@onready var damage_receiver:=$DamageReceiver

enum State{IDLE,WALK,JUMP,ATTACK,JUMPKICK,HURT,FALL,DEAD,PREP_ATTACK,TAKEOFF}

var anim_map={
	State.IDLE:"idle",
	State.WALK:"walk",
	State.JUMP:"jump",
	State.ATTACK:"punch",
	State.JUMPKICK:"jumpkick",
	State.HURT:"hurt",
	State.FALL:"fall",
	State.DEAD:"grounded",
	State.PREP_ATTACK:"idle",
	State.TAKEOFF:"jump"
}

var state=State.IDLE

const MAX_COMBO:int=3
const COMBO_TIMEOUT:float=1.0

var combo_step:int=0
var combo_timer:float=0.0

func _ready()->void:
	damage_emitter.area_entered.connect(on_emit_damage.bind())
	damage_receiver.damage_received.connect(on_receive_damage.bind())
	

func _process(delta:float)->void:
	if state!=State.DEAD:
		handle_input(delta)
	handle_air_time(delta)
	handle_movement()
	handle_animations(delta)
	if state!=State.DEAD:
		flip_sprite()
	#print_state()
	move_and_slide()
	if combo_step>0:
		combo_timer-=delta
		if combo_timer<=0:
			reset_combo()
		
			
	
func handle_input(_delta:float)->void:
	pass
		
		
func handle_air_time(delta:float)->void:
	#Si el sprite no está en el suelo.
	if !sprite_on_floor():
		#y si el estado es JUMP
		if state==State.JUMP || state==State.JUMPKICK || state==State.HURT || state==State.DEAD:
			#a sprite velocity (negativa), le sumamos la gravedad por delta
			sprite_velocity+=GRAVITY*delta
			#y a character_sprite.position.y, le sumamos sprite_velocity*delta
			character_sprite.position.y+=sprite_velocity*delta
			if state==State.DEAD:
				if character_sprite.flip_h:
					position.x+=knockback_intensity*-1*delta
				else:
					position.x+=knockback_intensity*delta
			
	else:
		character_sprite.position.y=0
		if state==State.HURT:
			if combo_step>=MAX_COMBO:
				if character_sprite.flip_h:
					position.x+=knockback_intensity*delta
				else:
					position.x+=knockback_intensity*-1*delta
	
func handle_movement()->void:
	if sprite_on_floor() and state!=State.ATTACK and state!=State.HURT and state!=State.DEAD:
		if velocity!=Vector2.ZERO:
			state=State.WALK
		elif velocity==Vector2.ZERO:
			state=State.IDLE
	elif state==State.HURT:
		velocity=Vector2.ZERO
	
	
	
	
func handle_animations(delta:float)->void:
	if animation_player.has_animation(anim_map[state]):
		animation_player.play(anim_map[state])
	if state==State.DEAD:
		modulate.a-=delta
		if modulate.a==0:
			queue_free()
		

		
func on_action_complete()->void:
	state=State.IDLE



func on_land_complete():
	if sprite_on_floor():
		state=State.IDLE
	else:
		state=State.JUMP	
		
func on_fall_complete():
	if sprite_on_floor():
		if health<=0:
			state=State.DEAD
		else:
			state=State.IDLE
	else:
		state=State.FALL	

func flip_sprite()->void:
	if velocity.x<0:
		damage_emitter.scale.x=-1
		character_sprite.flip_h=true
	elif velocity.x>0:
		damage_emitter.scale.x=1
		character_sprite.flip_h=false
		
func sprite_on_floor()->bool:
	return character_sprite.position.y>=0
	
func on_emit_damage(damage_receiver:DamageReceiver)->void:
	var direction=Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	direction.normalized()
	damage_receiver.damage_received.emit(damage,direction,knockback_intensity)	
	print(damage_receiver)

func on_receive_damage(damage:int,_direction:Vector2,_knockback_intensity:int)->void:
	state=State.HURT
	health-=damage
	combo_step+=1
	combo_timer=COMBO_TIMEOUT
	print("combo_step is:" + str(combo_step))
		
	if health<=0:
		character_sprite.position.y=-1
		sprite_velocity=-JUMP_FORCE
		state=State.DEAD
		

func reset_combo():
	combo_step=0

		
func print_state()->void:
	if state==State.JUMP:
		print("state is jump")
	if state==State.IDLE:
		print("state is idle")
	if state==State.WALK:
		print("state is walk")
