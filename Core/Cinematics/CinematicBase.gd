## Base class for visual novel style cinematics.
## Handles timer-based dialogue progression, image visibility, audio playback,
## skip/advance input, and scene transitions.
##
## Usage:
##     1. Create a scene extending CinematicBase
##     2. Override _get_config() to return your CinematicConfig
##     3. Add TextureRect children for images (optional)
##     4. Add DialogueLabel (Label) and AudioStreamPlayer nodes
##
## Child classes should override:
##     - _get_config(): Return configuration with dialogues, timing, etc.
##     - _on_dialogue_advanced(index): Custom logic when dialogue advances
##     - _on_cinematic_complete(): Custom logic before scene transition
class_name CinematicBase
extends Node2D


#region Signals
## Emitted when dialogue advances to a new index.
signal dialogue_advanced(index: int)

## Emitted when the cinematic is about to end.
signal cinematic_ending
#endregion


#region Node References
@onready var dialogue_label: Label = $DialogueLabel
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
#endregion


#region State Variables
## Array of TextureRect images collected from children.
var images: Array[TextureRect] = []

## Current dialogue/image index.
var current_index: int = 0

## Timer for auto-advance.
var _timer: float = 0.0

## Whether the cinematic has completed.
var _is_complete: bool = false

## Whether the cinematic is in the ending phase (waiting before transition).
var _is_ending: bool = false

## Cache for loaded audio streams.
var _audio_cache: Dictionary = {}

## Tracks which audio switches have been applied.
var _applied_switches: Dictionary = {}

## Current image index (may differ from dialogue index when using image_sequence).
var _current_image_index: int = -1
#endregion


#region Virtual Methods (Override in child classes)
## Override to provide configuration.
## Must return a valid CinematicConfig.
func _get_config() -> CinematicConfig:
	push_error("CinematicBase._get_config() not overridden")
	return null


## Called when dialogue advances to a new index.
## Override for custom behavior at specific indices.
func _on_dialogue_advanced(_index: int) -> void:
	pass


## Called before transitioning to the next scene.
## Override to add custom end-of-cinematic logic.
func _on_cinematic_complete() -> void:
	pass
#endregion


#region Lifecycle
func _ready() -> void:
	if audio_stream_player:
		audio_stream_player.bus = "Music"
	_collect_images()
	_preload_audio()
	_initialize_display()


func _process(delta: float) -> void:
	# Always allow skipping, even during end delay
	if _is_ending:
		if Input.is_action_pressed("Enter") or Input.is_action_just_pressed("NextStage"):
			_transition_to_next_scene()
		return

	if _is_complete:
		return

	_handle_skip_input()
	_handle_advance_input()
	_handle_auto_advance(delta)
#endregion


#region Initialization
## Collects all TextureRect children into the images array.
func _collect_images() -> void:
	var cfg := _get_config()
	if cfg == null or not cfg.uses_images:
		return

	for child in get_children():
		if child is TextureRect:
			images.append(child)


## Preloads audio streams defined in config.
func _preload_audio() -> void:
	var cfg := _get_config()
	if cfg == null:
		return

	for switch_index in cfg.audio_switches:
		var path: String = cfg.audio_switches[switch_index]
		if not path.is_empty() and not _audio_cache.has(path):
			_audio_cache[path] = load(path)


## Sets up initial display state.
func _initialize_display() -> void:
	var cfg := _get_config()
	if cfg == null:
		return

	# Start audio if not already playing
	if audio_stream_player and not audio_stream_player.is_playing():
		audio_stream_player.play()

	# Show first image (if using images)
	if cfg.uses_images and images.size() > 0:
		var first_image_index := _get_image_index_for_dialogue(0)
		if first_image_index >= 0 and first_image_index < images.size():
			images[first_image_index].visible = true
			_current_image_index = first_image_index

	# Show first dialogue
	if cfg.dialogues.size() > 0:
		dialogue_label.text = cfg.dialogues[0]
#endregion


#region Input Handling
## Handles skip input (Enter key) to immediately end cinematic.
func _handle_skip_input() -> void:
	if Input.is_action_pressed("Enter"):
		_transition_to_next_scene()


## Handles manual advance input (NextStage action).
func _handle_advance_input() -> void:
	if Input.is_action_just_pressed("NextStage"):
		_advance_dialogue()


## Handles timer-based auto-advance.
func _handle_auto_advance(delta: float) -> void:
	var cfg := _get_config()
	if cfg == null:
		return

	if not audio_stream_player.is_inside_tree():
		return

	# Ensure audio is playing
	if not audio_stream_player.is_playing():
		audio_stream_player.play()

	_timer += delta

	var max_index := _get_max_index()

	if _timer >= cfg.time_per_dialogue and current_index < max_index:
		_advance_dialogue()
	elif current_index >= max_index:
		_end_cinematic()
#endregion


#region Dialogue Progression
## Advances to the next dialogue/image.
func _advance_dialogue() -> void:
	var cfg := _get_config()
	if cfg == null:
		return

	var max_index := _get_max_index()

	if current_index >= max_index:
		return

	# Update image visibility (if using images)
	if cfg.uses_images and images.size() > 0:
		var new_image_index := _get_image_index_for_dialogue(current_index)
		if new_image_index != _current_image_index:
			# Hide previous image
			if _current_image_index >= 0 and _current_image_index < images.size():
				images[_current_image_index].visible = false
			# Show new image
			if new_image_index >= 0 and new_image_index < images.size():
				images[new_image_index].visible = true
			_current_image_index = new_image_index

	# Update dialogue text
	if current_index < cfg.dialogues.size():
		dialogue_label.text = cfg.dialogues[current_index]

	_timer = 0.0
	current_index += 1

	# Check for audio switches
	_check_audio_switch()

	# Emit signal and call virtual method
	dialogue_advanced.emit(current_index)
	_on_dialogue_advanced(current_index)


## Checks if audio should switch at current index.
func _check_audio_switch() -> void:
	var cfg := _get_config()
	if cfg == null:
		return

	for switch_index in cfg.audio_switches:
		# Apply switch when we pass the threshold, but only once
		if current_index > switch_index and not _applied_switches.has(switch_index):
			var audio_path: String = cfg.audio_switches[switch_index]
			_switch_audio(audio_path)
			_applied_switches[switch_index] = true


## Switches to a different audio stream.
func _switch_audio(audio_path: String) -> void:
	if audio_path.is_empty():
		return

	var stream: AudioStream
	if _audio_cache.has(audio_path):
		stream = _audio_cache[audio_path]
	else:
		stream = load(audio_path)

	if stream and audio_stream_player.stream != stream:
		audio_stream_player.stop()
		audio_stream_player.stream = stream
		audio_stream_player.play()
#endregion


#region Scene Transition
## Ends the cinematic and transitions after delay.
func _end_cinematic() -> void:
	if _is_complete or _is_ending:
		return

	_is_ending = true
	cinematic_ending.emit()
	_on_cinematic_complete()

	var cfg := _get_config()
	if cfg == null:
		return

	await get_tree().create_timer(cfg.end_delay).timeout
	_transition_to_next_scene()


## Transitions to the next scene or cinematic.
func _transition_to_next_scene() -> void:
	if _is_complete:
		return

	_is_complete = true

	if audio_stream_player.is_playing():
		audio_stream_player.stop()

	var cfg := _get_config()
	if cfg == null:
		return

	# Check for cinematic chaining first
	if not cfg.next_cinematic.is_empty():
		CinematicManager.play(cfg.next_cinematic)
	elif not cfg.next_scene_path.is_empty():
		get_tree().change_scene_to_file(cfg.next_scene_path)
#endregion


#region Utility
## Returns the maximum dialogue index.
func _get_max_index() -> int:
	var cfg := _get_config()
	if cfg == null:
		return 0
	return cfg.dialogues.size()


## Returns which image index to show for a given dialogue index.
## Uses image_sequence if provided (1-based), otherwise defaults to 1:1 mapping.
func _get_image_index_for_dialogue(dialogue_index: int) -> int:
	var cfg := _get_config()
	if cfg == null:
		return dialogue_index

	# If image_sequence is provided, use it (convert from 1-based to 0-based)
	if cfg.image_sequence.size() > 0:
		if dialogue_index < cfg.image_sequence.size():
			return cfg.image_sequence[dialogue_index] - 1  # Convert 1-based to 0-based
		return cfg.image_sequence[cfg.image_sequence.size() - 1] - 1

	# Default: 1:1 mapping (dialogue 0 = image 0, etc.)
	return dialogue_index
#endregion
