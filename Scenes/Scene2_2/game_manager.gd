extends Node


@export var sinks:Node2D=null
@onready var audio=$"../Audio"
@onready var help_sprite=%HelpSprite
@onready var label = %MainLabel
@onready var player = %Player
@onready var guards = $"../Pausable/Guards"
@warning_ignore("unused_signal")
signal alert_state

func _physics_process(delta):
	if is_instance_valid(player):
		check_player_dead()	
		if player.state==player.States.crawling || player.state==player.States.crawl_idle:
			for sink in sinks.get_children():
				sink.collider.disabled=true
		else:
			for sink in sinks.get_children():
				sink.collider.disabled=false
			
func _input(_event):
	if GameStates.game_won:
		if Input.is_action_just_pressed("NextStage"):
			GameStates.game_won=false
			CinematicManager.play("chapter4")


func check_player_dead():
	if is_instance_valid(player):
		if player.health<=0:
			player.state=player.States.dead
		
		if player.state==player.States.dead:
			player.visible=false
			await(get_tree().create_timer(2.0).timeout)
			GameStates.has_uniform=false
			get_tree().reload_current_scene()


func _on_goal_body_entered(body):
	if body==player:
		if GameStates.has_essential_medicine:
			if body.state!=body.States.crawling && body.state!=body.States.crawl_idle:
				help_sprite.texture=load("res://Scenes/UI/HelpButtonM.png")				
				label.text="Pulsa M para pasar."
			else:
				GameStates.game_won=true
				help_sprite.texture=load("res://Scenes/UI/HelpButtonSpace.png")
				label.text="SIGUIENTE ESCENA."
		else:
			player.interaction_area_entered=true
			label.text="Necesito la medicina\nque hay en este cuarto."


func _on_goal_2_body_entered(body):
	GameStates.has_essential_medicine=true
	
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
		audio.stream=load("res://Sound/stealth.mp3")
		audio.play()
