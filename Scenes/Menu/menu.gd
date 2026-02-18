extends Node2D
@onready var animation_player=$AnimationPlayer
@onready var settings_menu = $SettingsMenu
@onready var main_button = $Button
@onready var exit_button = $ExitButton
@onready var settings_button = $SettingsButton
@onready var main_theme = $MainTheme
var save_path=GameStates.SAVE_PATH



func _load():
	#GameStates.reset_game_state()
	if FileAccess.file_exists(save_path):
		if GameStates.checkpoint==-1:
			GameStates.reset_game_state()
		var file = FileAccess.open(save_path, FileAccess.READ)
		while file.get_position()<file.get_length():
			var json=JSON.new()
			json.parse(file.get_line())
			var node_data=json.get_data()
			
			GameStates.checkpoint=str_to_var(node_data["checkpoint"])
			GameStates.has_pen=str_to_var(node_data["haspen"])
			GameStates.has_book=str_to_var(node_data["hasbook"])
			GameStates.has_mask=str_to_var(node_data["hasmask"])
			GameStates.has_acid=str_to_var(node_data["hasacid"])
			GameStates.acid_applied=str_to_var(node_data["acidapplied"])
			GameStates.has_uniform=str_to_var(node_data["hasuniform"])
			GameStates.has_wax=str_to_var(node_data["haswax"])
			# Inventory counts (backward-compatible with old saves).
			if node_data.has("firstaid"):
				GameStates.first_aid = str_to_var(node_data["firstaid"])
			
			
				
		file.close()

	
func _save():
	return GameStates.save_to_file()

# Called when the node enters the scene tree for the first time.
func _ready():
	# Ensure MainTheme uses Music bus (set after VolumeManager creates buses)
	main_theme.bus = "Music"

	# Load save game when menu starts
	_load()

	animation_player.play("Intro1")
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		if animation_player.is_playing() and animation_player.current_animation == "Intro1":
			var anim = animation_player.get_animation("Intro1")
			if anim:
				# Disable looping so animation finishes naturally
				anim.loop_mode = Animation.LOOP_NONE
				# Seek to just before the end, then let it finish naturally
				animation_player.seek(anim.length - 0.01)


func _on_button_pressed():
	# Always load the save game before starting (in case it was updated)
	_load()

	if not is_instance_valid(get_tree()):
		return

	var checkpoint_value = int(GameStates.checkpoint)

	# Special case: cinematic prologue when the checkpoint is -1 (new game or final win).
	if checkpoint_value == -1:
		CinematicManager.play("chapter1")
		return

	_ensure_checkpoint_keys(checkpoint_value)

	if checkpoint_value == 0:
		# No save file yet? continue with the cinematic intro.
		if FileAccess.file_exists(save_path):
			get_tree().change_scene_to_file("res://Scenes/Scene1/scene_1.tscn")
		else:
			CinematicManager.play("chapter1")
		return

	if checkpoint_value >= 1 and checkpoint_value <= 4:
		# Checkpoints 1-4 are different parts of Scene1
		get_tree().change_scene_to_file("res://Scenes/Scene1/scene_1.tscn")
	elif checkpoint_value == 5:
		# Checkpoint 5 is the start of Scene2
		get_tree().change_scene_to_file("res://Scenes/Scene2/scene_2.tscn")
	elif checkpoint_value == 6:
		get_tree().change_scene_to_file("res://Scenes/Scene2_2/scene_2_2.tscn")
	elif checkpoint_value == 7:
		get_tree().change_scene_to_file("res://Scenes/Scene2_3/scene_2_3.tscn")
	elif checkpoint_value == 8:
		get_tree().change_scene_to_file("res://Scenes/Scene2_4/scene_2_4.tscn")
	elif checkpoint_value == 9:
		get_tree().change_scene_to_file("res://Scenes/Scene2_5/scene_2_5.tscn")
	elif checkpoint_value > 9:
		# Future-proof: if more checkpoints are added later, keep the player in the latest chapter.
		get_tree().change_scene_to_file("res://Scenes/Scene2_5/scene_2_5.tscn")
	else:
		# Fallback - should not happen
		get_tree().change_scene_to_file("res://Scenes/Scene1/scene_1.tscn")

func _ensure_checkpoint_keys(checkpoint_value:int) -> void:
	# Give the player the keys that correspond to the loaded checkpoint.
	if checkpoint_value >= 1:
		GameStates.has_blue_key = true
	if checkpoint_value >= 2:
		GameStates.has_yellow_key = true
	if checkpoint_value >= 3:
		GameStates.has_red_key = true
	if checkpoint_value >= 4:
		GameStates.has_white_key = true

func _on_exit_button_pressed():
	GameStates.save_to_file()
	get_tree().quit()

func _on_settings_button_pressed():
	settings_menu.visible = true
	# Ensure the settings panel draws above the menu UI.
	settings_menu.move_to_front()
	main_button.visible = false
	exit_button.visible = false
	settings_button.visible = false

func _on_settings_back():
	settings_menu.visible = false
	main_button.visible = true
	exit_button.visible = true
	settings_button.visible = true
