extends CharacterBody2D


@export var remote_transform:RemoteTransform2D
@export var start_mark:Marker2D
@export var objective:CharacterBody2D
@export var pathfollow:PathFollow2D
@onready var navigation_agent=$NavigationAgent2D


var inc=0

enum State{PATROL,CHASE,RETURN,CHECK_CELLS}
var state=State.PATROL



const SPEED = 60.0
const SPRITE_FACING_OFFSET_RAD := PI * 0.5 # Sprite is authored "facing up", but Node2D.look_at aims +X.
const RAYCAST_FACING_OFFSET_RAD := PI * 0.5 # Raycasts authored "up" (-Y); rotate to face +X in CHASE/RETURN.





#@export var starting_position:Vector2



@export var type:int=0
@export var player:CharacterBody2D
@export var path:Path2D

@onready var animation_player = $AnimationPlayer
@onready var raycast = $RayCast2D
@onready var raycast2 = $RayCast2D2
@onready var raycast3 = $RayCast2D3
@onready var game_manager=%GameManager
@onready var mark1: Marker2D = get_node_or_null("../../../Marks/Mark1") as Marker2D
@onready var mark2: Marker2D = get_node_or_null("../../../Marks/Mark2") as Marker2D
@onready var mark3: Marker2D = get_node_or_null("../../../Marks/Mark3") as Marker2D
@onready var mark4: Marker2D = get_node_or_null("../../../Marks/Mark4") as Marker2D
@onready var mark5: Marker2D = get_node_or_null("../../../Marks/Mark5") as Marker2D
#@onready var path4 = $"../../../Pausable/Paths/Path2D4"
#@onready var path_follow4 = $"../../../Pausable/Paths/Path2D4/PathFollow2D"
#@onready var remote_transform4 = $"../../../Pausable/Paths/Path2D4/PathFollow2D/RemoteTransform2D"
@onready var label=%MainLabel

@onready var sprite=$Sprite2D
@onready var collision_shape=$CollisionShape2D
@onready var shoot_timer: Timer = $ShootTimer
@onready var spawner=$Spawner
@onready var vision_cone=$VisionCone

const BULLET_SCENE = preload("res://Scenes/Bullet/bullet.tscn")
const SFX_GUARD_STEP = preload("res://Sound/sfxGuardStep.ogg")
const SFX_GUARD_NOTICE_1 = preload("res://Sound/sfxGuardNoticePlayer.ogg")
const SFX_GUARD_NOTICE_2 = preload("res://Sound/sfxGuardNoticePlayer2.ogg")
const SFX_GUARD_NOTICE_3 = preload("res://Sound/sfxGuardNoticePlayer3.ogg")

var can_shoot = true
var shoot_timer_started = false
var step_timer: float = 0.0
const STEP_INTERVAL: float = 0.4
const STEP_SOUND_MAX_DISTANCE: float = 200.0
var guard_notice_sounds: Array = []

@onready var step_audio_player: AudioStreamPlayer2D = $StepAudioPlayer
@onready var notice_audio_player: AudioStreamPlayer2D = $NoticeAudioPlayer

var cell_mark:Marker2D

func _ready():
	# Setup shooting timer
	shoot_timer.wait_time = 3.0
	shoot_timer.one_shot = false
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)

	# Setup audio players
	guard_notice_sounds = [SFX_GUARD_NOTICE_1, SFX_GUARD_NOTICE_2, SFX_GUARD_NOTICE_3]
	if step_audio_player:
		step_audio_player.bus = "SFX"
		step_audio_player.stream = SFX_GUARD_STEP
		step_audio_player.volume_db = -6.0  # Half volume
	if notice_audio_player:
		notice_audio_player.bus = "SFX"


func play_footstep(delta: float) -> void:
	step_timer += delta
	if step_timer >= STEP_INTERVAL:
		step_timer = 0.0
		if step_audio_player and !step_audio_player.is_playing():
			if is_instance_valid(player) and global_position.distance_to(player.global_position) <= STEP_SOUND_MAX_DISTANCE:
				step_audio_player.play()

func play_guard_notice_sound() -> void:
	if notice_audio_player and !notice_audio_player.is_playing():
		var random_index = randi() % guard_notice_sounds.size()
		notice_audio_player.stream = guard_notice_sounds[random_index]
		notice_audio_player.play()

func _physics_process(delta):
	decide_state(delta)

	if state==State.CHASE:
		if not shoot_timer_started:
			shoot_timer.start()
			shoot_timer_started = true
			shoot()  # Shoot immediately when entering alert state
		
		
#
	## Stop shooting timer if leaving CHASING state
	if state != State.CHASE:
		shoot_timer.stop()
		shoot_timer_started = false
		can_shoot = true


func check_view():
	if is_instance_valid(player):
		if (raycast.get_collider()==player||
		raycast2.get_collider()==player ||
		raycast3.get_collider()==player):
			if !GameStates.uniform_on:
				#last_patrol_position=global_position
				play_guard_notice_sound()
				game_manager.emit_signal("alert_state")
				#state=states.CHASING
				#navigation_agent.set_target_position(player.global_position)
				#last_target_position=player.global_position
			else:
				await(get_tree().create_timer(3.0).timeout)
				if(is_instance_valid(player)):
					if (raycast.get_collider()==player||
					raycast2.get_collider()==player ||
					raycast3.get_collider()==player):
						label.text="¿¡Quién eres tú!?"
						#last_patrol_position=global_position
						play_guard_notice_sound()
						game_manager.emit_signal("alert_state")
						#state=states.CHASING
						#navigation_agent.set_target_position(player.global_position)
						#last_target_position=player.global_position

func animate():
	animation_player.play("Walk")



func cell_search(_delta):
	var next_point = navigation_agent.get_next_path_position()
	var _to_next = next_point - global_position

	
	
	


	



func _on_navigation_agent_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()

func shoot():
	if BULLET_SCENE and state == State.CHASE:
		var bullet = BULLET_SCENE.instantiate()
		if is_instance_valid(player):
			look_at(player.global_position)
		# Add to the same parent as the guards (Pausable node)
		spawner.add_child(bullet)

		# Position bullet at guard's position
		bullet.global_position = global_position

		# Set bullet direction based on player position
		var direction = Vector2.RIGHT.rotated(rotation)
		if is_instance_valid(player):
			direction = (player.global_position - global_position).normalized()
		bullet.direction = direction
		if bullet.has_method("set_direction"):
			bullet.set_direction(direction)

		can_shoot = false

func _on_shoot_timer_timeout():
	can_shoot = true
	shoot()

func patrol(delta:float):
	inc+=delta*SPEED
	pathfollow.progress=inc
	
	play_footstep(delta)
	animate()
	check_view()
	
func decide_state(delta:float):
	match state:
		State.PATROL:
			# During patrol, the guard's rotation comes from the path/remote transform.
			# Keep the sprite un-offset in this mode.
			if is_instance_valid(sprite):
				sprite.rotation = 0.0
			_set_raycast_offset(0.0)
			patrol(delta)
		State.CHASE:
			# In chase/return we rotate the guard with look_at(), which aims the node's +X axis.
			# Our sprite is drawn facing "up", so we apply a +90° local offset.
			if is_instance_valid(sprite):
				sprite.rotation = SPRITE_FACING_OFFSET_RAD
			_set_raycast_offset(RAYCAST_FACING_OFFSET_RAD)
			if is_instance_valid(player):
				if position.distance_to(player.position)>100:
					move_towards_player(delta)
					#sprite.rotation=deg_to_rad(90)
					game_manager.lift_alert_state()
				else:
					if player.cell!=0 and player.cell!=1:
						game_manager.kill_player()
		State.RETURN:
			if is_instance_valid(sprite):
				sprite.rotation = SPRITE_FACING_OFFSET_RAD
			_set_raycast_offset(RAYCAST_FACING_OFFSET_RAD)
			move_towards_start_mark(delta)
			#look_at(start_mark.position)
			#sprite.rotation=deg_to_rad(90)
			if is_instance_valid(start_mark) and global_position.distance_to(start_mark.global_position) <= 20.0:
				inc=0
				global_position = start_mark.global_position
				state=State.PATROL
				vision_cone.visible=true
		
				
				
func move_towards_player(delta:float):
	if !is_instance_valid(objective):
		return
	navigation_agent.target_position = objective.global_position
	if navigation_agent.is_navigation_finished():
		return
	var next_position=navigation_agent.get_next_path_position()
	var direction=(next_position-global_position).normalized()
	global_position+=direction*SPEED*delta
	look_at(objective.global_position)

func move_towards_start_mark(delta:float):
	if !is_instance_valid(start_mark):
		return
	navigation_agent.target_position = start_mark.global_position
	if navigation_agent.is_navigation_finished():
		return
	var next_position=navigation_agent.get_next_path_position()
	var direction=(next_position-global_position).normalized()
	global_position+=direction*SPEED*delta
	look_at(start_mark.global_position)

func _set_raycast_offset(offset_rad: float) -> void:
	# RayCast2D casts toward local `target_position`.
	# Our ray vectors are authored as "up" (-Y), but during chase/return the guard aims +X
	# toward the objective via `look_at()`. Rotating the ray nodes by -90° aligns the casts.
	if is_instance_valid(raycast):
		raycast.rotation = offset_rad
	if is_instance_valid(raycast2):
		raycast2.rotation = offset_rad
	if is_instance_valid(raycast3):
		raycast3.rotation = offset_rad
	
#func move_towards_cell_mark(delta:float,mark:Marker2D):
	#navigation_agent.target_position=mark.position
	#if navigation_agent.is_navigation_finished():
		#return
	#var next_position=navigation_agent.get_next_path_position()
	#var direction=(next_position-global_position).normalized()
	#global_position+=direction*SPEED*delta
	#look_at(direction)
	#
#func check_cell(delta,mark:Marker2D):
	#if position.distance_to(mark.position)<=30:
		#match mark:	
			#mark1:
				#if player.cell==2 || player.cell==3:
					#player.state=player.States.dead
				#else:
					#cell_mark=null
			#mark3:
				#if player.cell==4:
					#player.state=player.States.dead
				#else:
					#cell_mark=null
				
					
						


func _on_detection_area_body_entered(body):
	if body.is_in_group("player"):
		play_guard_notice_sound()
		game_manager.emit_signal("alert_state")
