## Legacy Sharaka implementation - no longer used.
## For new code, use Scenes/Characters/SharakaCharacter.gd
extends "res://Scenes/Scene2_3/Characters/character.gd"

@export var duration_between_hits: int
@export var duration_prep_hit: int
@export var player: Node = null

var player_slot:Node2D=null

var time_since_last_hit=Time.get_ticks_msec()
var time_since_prep_hit=Time.get_ticks_msec()


func _ready()->void:
	super._ready()
	var anim_attacks=["punch","punch_alt","jump_attack"]
	if player!=null:
		var target_position=player.position
	
func _physics_process(delta):
	if is_instance_valid(player):
		handle_air_time(delta)
		super._process(delta)
	
func handle_input(delta:float)->void:
	if player==null:
		velocity=Vector2.ZERO
	else:
		if player.get_health()<=0:
			player.free_slot(self)
		if player!=null and can_move():
			if player_slot==null:
				player_slot=player.reserve_slot(self)

		if player_slot!=null:
			var target_position=player_slot.position
			
			if can_attack():
				velocity=Vector2.ZERO
				state=State.PREP_ATTACK
				print("prep_attack")
				time_since_prep_hit=Time.get_ticks_msec()
			else:			
				var direction=(player_slot.global_position-global_position).normalized()
				velocity=direction*speed
				
func handle_prep_attack()->void:
	if state==State.PREP_ATTACK and (Time.get_ticks_msec()-time_since_prep_hit>duration_prep_hit):
		if(player_slot.global_position-global_position).length()<1:
			state=State.ATTACK
			print("attacking")
			time_since_last_hit=Time.get_ticks_msec()
			animation_player.play("punch")
		else:
			state=State.TAKEOFF

			
			
			
func can_jump_attack()->bool:
	return state==State.JUMP 



func handle_air_time(delta:float):
	if can_jump_attack():
		state=State.JUMPKICK
		print("jump_attack")

	super.handle_air_time(delta)
		
func is_player_within_range()->bool:
	return (player_slot.global_position-global_position).length()<=1
	
func is_player_within_long_range()->bool:
	return (player_slot.global_position-global_position).length()>15
	
	
func can_move()->bool:
	return state!=State.HURT
	
func can_attack()->bool:
	if Time.get_ticks_msec()-time_since_last_hit<duration_between_hits:
		return false
	return state==State.WALK || state==State.IDLE
	
	
func set_heading()->void:
	if player==null:
		return
	heading=Vector2.LEFT if global_position.x > player.global_position.x else Vector2.RIGHT
	
func on_receive_damage(amount:int,direction:Vector2,hit_type:int)->void:
	super.on_receive_damage(amount,direction,hit_type)
	if health<=0:
		player_slot=null
		player.free_slot(self)
	
