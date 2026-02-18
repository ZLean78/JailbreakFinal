extends Node


var make_waterdrain_noise=false
var player_made_waterdrain_noise=false
var noises_to_make=3
var game_won=false

const CROWD_SHOUT_STREAM: AudioStream = preload("res://Sound/crowd_shouting.ogg")
var _crowd_player: AudioStreamPlayer
var _loss_handled: bool = false

@onready var help_sprite=%HelpSprite
@onready var label = %MainLabel
@onready var player = %Player

# Called when the node enters the scene tree for the first time.
func _ready():
	_crowd_player = AudioStreamPlayer.new()
	_crowd_player.name = "CrowdShoutPlayer"
	_crowd_player.stream = CROWD_SHOUT_STREAM
	add_child(_crowd_player)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if GameStates.checkpoint!=6:
		check_letter()
	check_player_dead()
	check_wd_noise()
	check_noises_number()
	
func _input(_event):
	if GameStates.game_won:
		GameStates.game_won=false
		GameStates.checkpoint=6
		await(get_tree().create_timer(1.0).timeout)
		CinematicManager.play("chapter3")
	
func check_player_dead():
	if is_instance_valid(player):
		if player.state==player.States.dead:
			if _loss_handled:
				return
			_loss_handled = true
			_wake_bed_prisoners()
			_play_crowd_shout()
			player.visible=false
			await(get_tree().create_timer(2.0).timeout)
			GameStates.has_uniform=false
			get_tree().reload_current_scene()
			
func _play_crowd_shout() -> void:
	if _crowd_player == null:
		return
	if _crowd_player.playing:
		_crowd_player.stop()
	_crowd_player.play()


func _wake_bed_prisoners() -> void:
	if get_tree() == null or get_tree().current_scene == null:
		return
	var beds := get_tree().current_scene.get_node_or_null("Beds")
	if beds == null:
		return
	for child in beds.get_children():
		if child and child.has_method("wake_up_for_loss"):
			child.wake_up_for_loss()
			
func check_wd_noise():
	if is_instance_valid(player):
		if make_waterdrain_noise:
			player_made_waterdrain_noise=true
			
		

func check_noises_number():
	if player_made_waterdrain_noise:
		make_waterdrain_noise=false
		noises_to_make-=1
		player_made_waterdrain_noise=false
	if noises_to_make<=0:
		player.state=player.States.dead
	
func check_letter()->void:
	if GameStates.has_letter1:
		GameStates.checkpoint=6
		CinematicManager.play("chapter2")
			
