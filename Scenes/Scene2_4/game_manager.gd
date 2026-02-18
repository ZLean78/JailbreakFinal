extends Node


var make_waterdrain_noise=false
var player_made_waterdrain_noise=false
var noises_to_make=3
var game_won=false


@onready var help_sprite=%HelpSprite
@onready var label = %MainLabel
@onready var player = %Player


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	check_player_dead()
	
	#check_wd_noise()
	#check_noises_number()
	
func _input(_event):
	if GameStates.game_won:
		if Input.is_action_just_pressed("NextStage"):
			GameStates.game_won=false
			CinematicManager.play("chapter6")
	
func check_player_dead():
	if is_instance_valid(player):
		if player.state==player.States.dead:
			player.visible=false
			await(get_tree().create_timer(2.0).timeout)
			GameStates.has_uniform=false
			get_tree().reload_current_scene()
			
#func check_wd_noise():
	#if is_instance_valid(player):
		#if make_waterdrain_noise:
			#player_made_waterdrain_noise=true
			#
		#
#
#func check_noises_number():
	#if player_made_waterdrain_noise:
		#make_waterdrain_noise=false
		#noises_to_make-=1
		#player_made_waterdrain_noise=false
	#if noises_to_make<=0:
		#player.state=player.States.dead
	


func _on_goal_body_entered(body):
	if body.is_in_group("player"):
		GameStates.game_won=true
		help_sprite.texture=load("res://Scenes/UI/HelpButtonSpace.png")
		label.text="SIGUIENTE ESCENA"
		
