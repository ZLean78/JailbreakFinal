extends Node2D

@onready var color_rect=%ColorRect
@onready var box_container=%BoxContainer

@onready var player=%Player

@onready var guard = $Pausable/Guards/Guard
@onready var guard_2 = $Pausable/Guards/Guard2
@onready var guard_3 = $Pausable/Guards/Guard3

@onready var remote_transform1 = $Pausable/Paths/Path2D/PathFollow2D/RemoteTransform2D
@onready var remote_transform2 = $Pausable/Paths/Path2D2/PathFollow2D/RemoteTransform2D
@onready var remote_transform3 = $Pausable/Paths/Path2D3/PathFollow2D/RemoteTransform2D
@onready var game_manager=%GameManager
@onready var help_sprite=%HelpSprite
@onready var label=%MainLabel

@onready var audio=$Audio

func _show_help_for_seconds(texture_path: String, text: String, seconds: float) -> void:
	# Fire-and-forget: show help, then clear it *only if* it wasn't replaced.
	var tex := load(texture_path)
	help_sprite.texture = tex
	label.text = text
	await(get_tree().create_timer(seconds).timeout)
	if help_sprite.texture == tex and label.text == text:
		help_sprite.texture = null
		label.text = ""

func _run_scene1_intro_help() -> void:
	# Requirement: always show the main help at Scene1 start.
	_show_help_for_seconds("res://Scenes/UI/HelpKeys0.png", "MOVERSE", 3.0)
	await(get_tree().create_timer(3.0).timeout)
	_show_help_for_seconds("res://Scenes/UI/HelpButtonM.png", "GATEAR O TREPAR/PARARSE", 3.0)
	await(get_tree().create_timer(3.0).timeout)
	_show_help_for_seconds("res://Scenes/UI/HelpButtonTab.png", "ABRIR/CERRAR INVENTARIO", 3.0)

#func _run_checkpoint0_extra_help() -> void:
	## Keep the original checkpoint-0 tutorial sequence, but don't block _ready().
	#$Pausable/Beds/MyBed.animated_sprite.play("InBed")
	#await(get_tree().create_timer(3.0).timeout)
	#if !GameStates.has_pen:
		#if !color_rect.visible:
			#help_sprite.texture=load("res://Scenes/UI/HelpButtonM.png")
			#label.text="GATEAR O TREPAR/PARARSE"
			#await(get_tree().create_timer(3.0).timeout)
			#help_sprite.texture=load("res://Scenes/UI/HelpButtonTab.png")
			#label.text="ABRIR/CERRAR INVENTARIO"

# Called when the node enters the scene tree for the first time.
func _ready():
	
	
	remote_transform1.remote_path=guard.get_path()
	remote_transform2.remote_path=guard_2.get_path()
	remote_transform3.remote_path=guard_3.get_path()
	
	audio.bus = "Music"
	if GameStates.checkpoint<=0:
		audio.stream=load("res://Sound/intro0.mp3")
	else:
		audio.stream=load("res://Sound/intro3.wav")

	audio.play()

	# Always show the main help label/text for 3 seconds when Scene1 starts.
	_run_scene1_intro_help()
	
		
	#if GameStates.checkpoint==0:
		#_run_checkpoint0_extra_help()
		
		
		
	if GameStates.checkpoint==1:
		if is_instance_valid(player):
			player.position=$Pausable/Keys/BlueKey.position
			$Pausable/Keys/BlueKey.queue_free()
	if GameStates.checkpoint==2:
		if is_instance_valid(player):
			player.position=$Pausable/Keys/YellowKey.position
			$Pausable/Keys/YellowKey.queue_free()
	if GameStates.checkpoint==3:
		if is_instance_valid(player):
			player.position=$Pausable/Keys/RedKey.position
			$Pausable/Keys/RedKey.queue_free()
	if GameStates.checkpoint==4:
		if is_instance_valid(player):
			player.position=$Pausable/Keys/WhiteKey.position
			$Pausable/Keys/WhiteKey.queue_free()
			
	
	

func _process(_delta):
	check_guards_state()		

func _input(_event):
	if Input.is_action_pressed("UI"):
		color_rect.visible=!color_rect.visible
		box_container.visible=!box_container.visible
		set_tree_pause(get_tree().paused)
	#if _event is InputEventKey and _event.pressed and _event.keycode == KEY_END:
		#if is_instance_valid(player):
			#player.queue_free()
		#GameStates.game_won=true
		#help_sprite.texture=load("res://Scenes/UI/HelpButtonSpace.png")
		#label.text="SIGUIENTE CAPÍTULO"
		
func set_tree_pause(paused:bool):
	if paused:
		get_tree().paused=false
	else:
		get_tree().paused=true
#
#func _on_area_1_body_entered(body):
	#if body.is_in_group("guards"):
		#if body.state==4:
			#body.state=41
			#body.rotation=deg_to_rad(180)
			#if player.cell==2:
				#player.dead=true
			#await(get_tree().create_timer(2.0).timeout)
			#body.state=42
			#body.rotation=deg_to_rad(0)
			#if player.cell==3:
				#player.dead=true
			#await(get_tree().create_timer(2.0).timeout)
			#body.state=5
		#if body.state==8:
			#game_manager.assign_transform(body,body.type)
			#body.state=0
#
#
#func _on_area_2_body_entered(body):
	#if body.is_in_group("guards"):
		#if body.state==1:
			#body.state=2
		#if body.state==3:
			#body.state=4
		#if body.state==5:
			#body.state=6
		#if body.state==7:
			#body.state=8
				#
#
#func _on_area_3_body_entered(body):
	#if body.is_in_group("guards"):
		#if body.state==2:
			#body.state=21
			#body.rotation=deg_to_rad(90)
			#if player.cell==4:
				#player.dead=true
			#await(get_tree().create_timer(2.0).timeout)
			#body.state=3
		#if body.state==8:
			#game_manager.assign_transform(body,body.type)
			#body.state=0
#
#func _on_area_4_body_entered(body):
	#if body.is_in_group("guards"):
		#if body.state==6:
			#body.state=61
			#body.rotation=deg_to_rad(-90)
			#if player.cell!=1:
				#player.dead=true
			#else:
				#label.text="Cese de\nestado de alerta."
			#await(get_tree().create_timer(2.0).timeout)
			#label.text=""
			#body.state=7
#
#
#func _on_area_5_body_entered(body):
	#if body.state==8:
		#game_manager.assign_transform(body,body.type)
		#body.state=0


func _on_cell_1_body_entered(body):
	if body==player:
		body.cell=1


func _on_cell_1_body_exited(body):
	if body==player:
		body.cell=0


func _on_cell_2_body_entered(body):
	if body==player:
		body.cell=2




func _on_cell_2_body_exited(body):
	if body==player:
		body.cell=0


func _on_cell_3_body_entered(body):
	if body==player:
		body.cell=3


func _on_cell_3_body_exited(body):
	if body==player:
		body.cell=0


func _on_cell_4_body_entered(body):
	if body==player:
		body.cell=4


func _on_cell_4_body_exited(body):
	if body==player:
		body.cell=0


func check_guards_state():
	if is_instance_valid(guard):
		if guard.state==guard.State.CHASE:
			remote_transform1.remote_path=""
	if is_instance_valid(guard_2):
		if guard_2.state==guard_2.State.CHASE:
			remote_transform2.remote_path=""
	if is_instance_valid(guard_3):
		if guard_3.state==guard_3.State.CHASE:
			remote_transform3.remote_path=""
	
	if is_instance_valid(guard):
		if guard.state==guard.State.PATROL:
			remote_transform1.remote_path=guard.get_path()
	if is_instance_valid(guard_2):
		if guard_2.state==guard_2.State.PATROL:
			remote_transform2.remote_path=guard_2.get_path()
	if is_instance_valid(guard_3):
		if guard_3.state==guard_3.State.PATROL:
			remote_transform3.remote_path=guard_3.get_path()

	# Check if alert state has ceased (all guards are patrolling)
	if GameStates.alert_state:
		if is_instance_valid(guard) && is_instance_valid(guard_2) && is_instance_valid(guard_3):
			if (guard.state == guard.State.PATROL and guard_2.state == guard_2.State.PATROL and guard_3.state == guard_3.State.PATROL):
				GameStates.alert_state = false
				audio.stream = load("res://Sound/intro3.wav")
				audio.play()
				print("Changed audio to intro3.wav")


func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		body.light.enabled=false


func _on_area_2d_body_exited(body):
	if body.is_in_group("player"):
		body.light.enabled=true
