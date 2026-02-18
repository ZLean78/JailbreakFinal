## Dynamic cinematic loader that reads from a data folder.
## Loads images and configuration from a folder, eliminating the need for
## separate .gd/.tscn files per cinematic.
##
## Usage:
##     var loader = preload("res://Core/Cinematics/CinematicLoader.tscn").instantiate()
##     loader.cinematic_path = "res://Cinematics/intro"
##     get_tree().root.add_child(loader)
##
## Folder structure:
##     Cinematics/intro/
##         config.json     # Configuration and dialogues
##         01.png          # First image
##         02.png          # Second image
##         ...
class_name CinematicLoader
extends CinematicBase


## Path to the cinematic data folder (e.g., "res://Cinematics/intro").
@export_dir var cinematic_path: String = ""

## Cached configuration loaded from JSON.
var _loaded_config: CinematicConfig = null

## Image files loaded from config (for export compatibility).
var _image_files_from_config: Array = []

## Initial audio path from config.
var _initial_audio_path: String = ""


func _ready() -> void:
	_load_cinematic_data()
	super._ready()


## Loads configuration and images from the cinematic folder.
func _load_cinematic_data() -> void:
	if cinematic_path.is_empty():
		push_error("CinematicLoader: cinematic_path is empty")
		return

	# Load config.json
	_load_config_json()

	# Load and create image nodes
	_load_images()

	# Load initial audio if specified
	_load_initial_audio()


## Loads and parses config.json from the cinematic folder.
func _load_config_json() -> void:
	var config_path := cinematic_path + "/config.json"

	# Use load() for res:// paths (works in exported builds)
	var json_resource = load(config_path)
	var json_text: String = ""
	
	if json_resource != null and json_resource is JSON:
		# Godot 4.x can load JSON as a resource
		var data: Dictionary = json_resource.data
		_parse_config_data(data)
		return
	
	# Fallback: try FileAccess (works in editor, may fail in exports)
	var file := FileAccess.open(config_path, FileAccess.READ)
	if file == null:
		push_error("CinematicLoader: Failed to open " + config_path)
		return

	json_text = file.get_as_text()
	file.close()

	var json := JSON.new()
	var error := json.parse(json_text)
	if error != OK:
		push_error("CinematicLoader: Failed to parse config.json: " + json.get_error_message())
		return

	_parse_config_data(json.data)


## Parses the configuration data dictionary into CinematicConfig.
func _parse_config_data(data: Dictionary) -> void:
	# Create CinematicConfig from JSON data
	_loaded_config = CinematicConfig.new()
	_loaded_config.time_per_dialogue = data.get("time_per_dialogue", 10.0)
	_loaded_config.next_scene_path = data.get("next_scene", "")
	_loaded_config.next_cinematic = data.get("next_cinematic", "")
	_loaded_config.end_delay = data.get("end_delay", 12.0)
	_loaded_config.uses_images = data.get("uses_images", true)

	# Load dialogues (supports both array-of-lines and legacy string formats)
	var dialogues_array: Array = data.get("dialogues", [])
	var dialogues := PackedStringArray()
	for dialogue in dialogues_array:
		if dialogue is Array:
			# New format: array of lines - join with newlines
			var lines := PackedStringArray()
			for line in dialogue:
				lines.append(str(line))
			dialogues.append("\n".join(lines))
		else:
			# Legacy format: string (may contain \n)
			dialogues.append(str(dialogue))
	_loaded_config.dialogues = dialogues

	# Load image_sequence (1-based in JSON)
	var sequence_array: Array = data.get("image_sequence", [])
	var image_sequence := PackedInt32Array()
	for idx in sequence_array:
		image_sequence.append(int(idx))
	_loaded_config.image_sequence = image_sequence

	# Load audio switches
	var switches: Dictionary = data.get("audio_switches", {})
	var audio_switches := {}
	for key in switches:
		audio_switches[int(key)] = str(switches[key])
	_loaded_config.audio_switches = audio_switches
	
	# Store image files list from config (for export compatibility)
	_image_files_from_config = []
	var images_array: Array = data.get("images", [])
	for img in images_array:
		_image_files_from_config.append(str(img))
	
	# Store initial audio path
	_initial_audio_path = data.get("initial_audio", "")


## Loads images and creates TextureRect nodes.
## Uses image list from config.json (export-safe) or falls back to directory scanning (editor only).
func _load_images() -> void:
	if _loaded_config == null or not _loaded_config.uses_images:
		return

	var image_files: Array[String] = []
	
	# Prefer images list from config.json (works in exported builds)
	if _image_files_from_config.size() > 0:
		for img in _image_files_from_config:
			image_files.append(str(img))
	else:
		# Fallback: scan directory (only works in editor, not in exports)
		image_files = _scan_directory_for_images()
		if image_files.is_empty():
			push_warning("CinematicLoader: No images found. Add 'images' array to config.json for export compatibility.")

	# Sort alphabetically (ensures 01 comes before 02, etc.)
	image_files.sort()

	# Find ColorRect to insert images after it (for proper z-ordering)
	var insert_index := 1  # After ColorRect (index 0)
	for i in get_child_count():
		if get_child(i) is ColorRect:
			insert_index = i + 1
			break

	# Create TextureRect nodes for each image
	for img_file in image_files:
		var img_path := cinematic_path + "/" + img_file
		var texture := load(img_path) as Texture2D
		if texture:
			var tex_rect := TextureRect.new()
			tex_rect.texture = texture
			tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			tex_rect.visible = false
			# Position in center of screen
			tex_rect.offset_left = 257
			tex_rect.offset_top = 13
			tex_rect.offset_right = 898
			tex_rect.offset_bottom = 440
			add_child(tex_rect)
			move_child(tex_rect, insert_index)
			insert_index += 1


## Scans directory for numbered images (editor fallback, does NOT work in exports).
func _scan_directory_for_images() -> Array[String]:
	var image_files: Array[String] = []
	
	var dir := DirAccess.open(cinematic_path)
	if dir == null:
		push_error("CinematicLoader: Cannot open directory " + cinematic_path)
		return image_files

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir():
			var lower_name := file_name.to_lower()
			if _is_numbered_image(lower_name):
				image_files.append(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	
	return image_files


## Checks if a filename is a numbered image file.
func _is_numbered_image(file_name: String) -> bool:
	# Must start with a digit
	if file_name.is_empty() or not file_name[0].is_valid_int():
		return false

	# Must be an image extension
	var extensions := [".png", ".jpg", ".jpeg", ".webp"]
	for ext in extensions:
		if file_name.ends_with(ext):
			return true
	return false


## Loads the initial audio stream if specified in config.
func _load_initial_audio() -> void:
	if _loaded_config == null:
		return

	if not _initial_audio_path.is_empty():
		var audio_stream := load(_initial_audio_path) as AudioStream
		if audio_stream and audio_stream_player:
			audio_stream_player.stream = audio_stream


## Override to return the loaded configuration.
func _get_config() -> CinematicConfig:
	return _loaded_config
