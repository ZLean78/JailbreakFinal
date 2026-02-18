extends Node2D


@export var enemy_name:Label=null
@export var debug_mode: bool = true

@onready var color_rect=%ColorRect
@onready var box_container=%BoxContainer
@onready var help_screen=$ActorsContainer/CanvasLayer/Help/CanvasLayer
@onready var player_node=$ActorsContainer/Pausables/Player
@onready var kaluga_node=$ActorsContainer/Pausables/Kaluga
@onready var win_screen=$ActorsContainer/CanvasLayer/WinScreen

var game_won:bool=false
const CHECKPOINT_SCENE_2_5 := 9
var _loss_handled: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# Save checkpoint for this boss chapter so Continue loads Scene2_5.
	if int(GameStates.checkpoint) < CHECKPOINT_SCENE_2_5:
		GameStates.checkpoint = CHECKPOINT_SCENE_2_5
		GameStates.save_to_file()

	enemy_name.text="KALUGA"
	_reset_fight_health()
	if win_screen:
		win_screen.visible=false
	

func _process(_delta):
	check_win_condition()
	check_player_defeat()

func _input(event):
	# Debug: instant win with G key (only when debug_mode is enabled)
	if debug_mode and event is InputEventKey and event.pressed and event.keycode == KEY_G:
		if is_instance_valid(kaluga_node) and not game_won:
			kaluga_node.state_machine.force_transition(&"Beaten")
		return

	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		get_tree().reload_current_scene()
		return

	if game_won:
		if is_instance_valid(kaluga_node):
			kaluga_node.state_machine.force_transition(&"Beaten")

		if Input.is_action_just_pressed("NextStage"):
			CinematicManager.play("chapter6_post")
		return

	if Input.is_action_pressed("UI"):
		color_rect.visible=!color_rect.visible
		box_container.visible=!box_container.visible
		set_tree_pause(get_tree().paused)
	if Input.is_action_pressed("Help"):
		help_screen.visible=!help_screen.visible
		set_tree_pause(get_tree().paused)
		
func set_tree_pause(paused:bool):
	if paused:
		get_tree().paused=false
	else:
		get_tree().paused=true

func check_win_condition()->void:
	if game_won:
		return
	if is_instance_valid(kaluga_node):
		if not kaluga_node.is_alive() or kaluga_node.state_machine.is_in_state(&"Beaten"):
			game_won = true
			GameStates.checkpoint = -1
			GameStates.save_to_file()
			if win_screen:
				win_screen.visible = true

func check_player_defeat()->void:
	if game_won or _loss_handled:
		return
	if is_instance_valid(player_node) and not player_node.is_alive():
		_loss_handled = true
		# Wait a bit before restarting, so the defeat feels responsive (and SFX/UI can show).
		var t := get_tree().create_timer(2.0)
		t.timeout.connect(_restart_after_loss)


func _restart_after_loss() -> void:
	get_tree().reload_current_scene()

func _reset_fight_health()->void:
	if is_instance_valid(player_node):
		player_node.reset()
	if is_instance_valid(kaluga_node):
		kaluga_node.reset()
