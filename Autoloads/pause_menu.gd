extends CanvasLayer

var is_paused = false

var pause_menu: Panel
var resume_button: Button
var reset_level_button: Button
var settings_button: Button
var save_quit_button: Button
var main_menu_button: Button
var settings_menu: Panel

# Scenes where pause should not work
var non_pausable_scenes = [
	"res://Scenes/Menu/menu.tscn",
	"res://Core/Cinematics/CinematicLoader.tscn"
]

func _ready():
	# Get references to nodes
	pause_menu = $PauseMenu
	resume_button = $PauseMenu/VBoxContainer/ResumeButton
	reset_level_button = $PauseMenu/VBoxContainer/ResetLevelButton
	settings_button = $PauseMenu/VBoxContainer/SettingsButton
	save_quit_button = $PauseMenu/VBoxContainer/SaveQuitButton
	main_menu_button = $PauseMenu/VBoxContainer/MainMenuButton
	settings_menu = $SettingsMenu

	# Hide the pause menu and settings initially
	pause_menu.visible = false
	settings_menu.visible = false
	# Connect button signals
	resume_button.pressed.connect(_on_resume_pressed)
	reset_level_button.pressed.connect(_on_reset_level_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	save_quit_button.pressed.connect(_on_save_quit_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	settings_menu.back_pressed.connect(_on_settings_back)
	# Make sure the pause menu processes even when game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS

func _is_inventory_open() -> bool:
	# Check if the inventory UI is currently open
	var current_scene = get_tree().current_scene
	if not current_scene:
		return false
	
	# Try to find the UI node or ColorRect/BoxContainer nodes
	# Different scenes might have different structures, so we check multiple ways
	var ui_node = current_scene.get_node_or_null("%UI")
	if ui_node:
		# If UI node exists, check its color_rect and box_container
		var ui_color_rect = ui_node.get_node_or_null("ColorRect")
		var ui_box_container = ui_node.get_node_or_null("BoxContainer")
		if ui_color_rect and ui_box_container:
			return ui_color_rect.visible and ui_box_container.visible
	
	# Also check if ColorRect and BoxContainer exist directly in the scene
	var scene_color_rect = current_scene.get_node_or_null("%ColorRect")
	var scene_box_container = current_scene.get_node_or_null("%BoxContainer")
	if scene_color_rect and scene_box_container:
		return scene_color_rect.visible and scene_box_container.visible
	
	return false

func _input(event):
	if event.is_action_pressed("Escape"):
		# Check if inventory is open - if so, don't allow pause
		if _is_inventory_open():
			return
		# Check if we're in a pausable scene
		if _can_pause():
			toggle_pause()

func _can_pause() -> bool:
	var current_scene = get_tree().current_scene
	if not current_scene:
		return false
	
	# If we're paused but in a non-pausable scene, reset pause state
	var scene_path = current_scene.scene_file_path
	for non_pausable in non_pausable_scenes:
		if scene_path == non_pausable:
			# Reset pause state if we're in a non-pausable scene
			if is_paused:
				is_paused = false
				get_tree().paused = false
				pause_menu.visible = false
			return false
	
	return true

func toggle_pause():
	is_paused = !is_paused
	get_tree().paused = is_paused
	pause_menu.visible = is_paused
	settings_menu.visible = false
	if is_paused:
		DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
	else:
		# Restore previous mouse mode (could be hidden in game)
		DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_HIDDEN)

func _on_resume_pressed():
	toggle_pause()

func _on_reset_level_pressed():
	close_menu()
	get_tree().reload_current_scene()

func _on_settings_pressed():
	pause_menu.visible = false
	settings_menu.visible = true
	# Ensure the settings panel draws above any other UI.
	settings_menu.move_to_front()

func _on_settings_back():
	settings_menu.visible = false
	pause_menu.visible = true
	# Ensure the pause panel draws above any other UI.
	pause_menu.move_to_front()

func _on_save_quit_pressed():
	close_menu()
	# Save and verify before quitting
	if GameStates.save_to_file():
		# Ensure file is flushed and closed before quitting
		get_tree().quit()
	else:
		# If save failed, show error (or just quit anyway)
		print("Warning: Save failed, but quitting anyway")
		get_tree().quit()

func _on_main_menu_pressed():
	close_menu()
	# Save before changing scene
	GameStates.save_to_file()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Menu/menu.tscn")

func close_menu():
	# Close the pause menu
	is_paused = false
	get_tree().paused = false
	pause_menu.visible = false
	settings_menu.visible = false
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_HIDDEN)

func _save() -> bool:
	return GameStates.save_to_file()
