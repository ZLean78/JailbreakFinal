extends Node

#var has_blue_key=false
var make_floorboards_noise=false
var player_made_fb_noise=false
var make_waterdrain_noise=false
var player_made_waterdrain_noise=false


@onready var guards=get_parent().get_node("Pausable/Guards")

@onready var guard = $"../Pausable/Guards/Guard"
@onready var guard_2 = $"../Pausable/Guards/Guard2"
@onready var guard_3 = $"../Pausable/Guards/Guard3"

@onready var remote_transform1 = $"../Pausable/Paths/Path2D/PathFollow2D/RemoteTransform2D"
@onready var remote_transform2 = $"../Pausable/Paths/Path2D2/PathFollow2D/RemoteTransform2D"
@onready var remote_transform3 = $"../Pausable/Paths/Path2D3/PathFollow2D/RemoteTransform2D"

@export var label:Label=null
@onready var player = %Player
@export var help_sprite:Sprite2D = null
@onready var audio_stream_player = %AudioStreamPlayer

@export var audio:AudioStreamPlayer=null

const FLOORBOARDS = preload("res://Resources/Sounds/floorboards.mp3")

@warning_ignore("unused_signal")
signal alert_state

func _ready():
	if audio_stream_player:
		audio_stream_player.bus = "SFX"
	if audio:
		audio.bus = "SFX"

func _process(_delta):
	if !GameStates.game_won:
		check_player_dead()
		check_fb_noise()
		check_wd_noise()
		if player_made_fb_noise:
			await (get_tree().create_timer(3.0).timeout)
			player_made_fb_noise=false
		if player_made_waterdrain_noise:
			await (get_tree().create_timer(3.0).timeout)
			player_made_waterdrain_noise=false
	else:
		help_sprite.texture=load("res://Scenes/UI/HelpButtonSpace.png")
		label.text="SIGUIENTE CAPÍTULO"
		#audio.stop()
		#audio.stream=load("res://Sound/goal.wav")
		#audio.play()
		if is_instance_valid(player):
			player.queue_free()
	
func _input(_event):
	if Input.is_action_just_pressed("Reset"):
		get_tree().reload_current_scene()
		GameStates.player_has_made_noise=false
		GameStates.has_blue_key=false
		GameStates.has_yellow_key=false
		GameStates.has_red_key=false
		GameStates.has_white_key=false
		GameStates.checkpoint=0
		GameStates.has_wax=false
		GameStates.has_uniform=false
		GameStates.uniform_on=false
		GameStates.has_pen=false
	if Input.is_action_just_pressed("NextStage"):
		if GameStates.game_won:
			GameStates.game_won=false
			GameStates.checkpoint=5  # Set checkpoint to 5 when transitioning to Scene2
			get_tree().change_scene_to_file("res://Scenes/Scene2/scene_2.tscn")
		
func check_wd_noise():
	if is_instance_valid(player):
		if player.velocity!=Vector2.ZERO && make_waterdrain_noise:
			player_made_waterdrain_noise=true

func check_fb_noise():
	if is_instance_valid(player):
		if player.velocity!=Vector2.ZERO && make_floorboards_noise:
			if !audio_stream_player.is_playing():
				audio_stream_player.play()
				player_made_fb_noise=true

func check_player_dead():
	if is_instance_valid(player):
		if player.health<=0:
			player.state=player.States.dead
		
		if player.state==player.States.dead:
			player.visible=false
			await(get_tree().create_timer(2.0).timeout)
			GameStates.has_uniform=false
			get_tree().reload_current_scene()
			
func kill_player():
	player.state=player.States.dead
	

#func set_cell_alert_state(_cell_mark:Marker2D):
	#audio.stop()
	#audio.stream=load("res://Sound/alert.wav")
	#audio.play()
	#GameStates.alert_state=true
	#print("entering alert state")
	#for a_guard in guards.get_children():
		#a_guard.state=a_guard.State.CHECK_CELLS
		#a_guard.cell_mark=_cell_mark
	

func _on_fb_area_body_entered(body):
	if body == player:
		make_floorboards_noise=true

func _on_fb_area_body_exited(body):
	if body == player:
		make_floorboards_noise=false


func _on_goal_body_entered(body):
	if body.is_in_group("player"):
		GameStates.game_won=true
		#player.queue_free()
		#GameStates.game_won=true
		#help_sprite.texture=load("res://Scenes/UI/HelpButtonSpace.png")
		#label.text="SIGUIENTE CAPÍTULO"
		audio.stop()
		audio.stream=load("res://Sound/goal.wav")
		audio.play()

func assign_transform(object,type):
	if type==1:
		remote_transform1.remote_path=object.get_path()
	elif type==2:
		remote_transform2.remote_path=object.get_path()
	elif type==3:
		remote_transform3.remote_path=object.get_path()


func _on_alert_state():
	audio.stop()
	audio.stream=load("res://Sound/alert.wav")
	audio.play()
	GameStates.alert_state=true
	print("entering alert state")
	if guards:
		for a_guard in guards.get_children():
			if a_guard:
				#a_guard.last_patrol_position=a_guard.global_position
				a_guard.state=a_guard.State.CHASE
				#a_guard.vision_cone.visible=false
				a_guard.navigation_agent.set_target_position(a_guard.objective.global_position)
			else:
				print("Warning: Null guard found in guards array")
	else:
		print("Warning: Guards node not found")
		#if a_guard.position.distance_to(a_guard.navigation_agent.target_position)>a_guard.max_distance_chase:
			#a_guard.navigation_agent.set_target_position(Vector2(700,387))		
			#a_guard.state=a_guard.states.TO_CENTER
			#print("Changed state to TO_CENTER")

func lift_alert_state():
	for a_guard in guards.get_children():
		if a_guard.position.distance_to(player.position)>400:
			a_guard.state=a_guard.State.RETURN
			#a_guard.vision_cone.visible=false
	var counter=0
	for a_guard in guards.get_children():
		if a_guard.state==a_guard.State.CHASE:
			counter+=1
	if counter==0:
		GameStates.alert_state=false
		audio.stream=load("res://Sound/intro3.wav")
		audio.play()
