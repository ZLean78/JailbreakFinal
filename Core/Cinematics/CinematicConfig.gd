## Configuration resource for cinematic scenes.
## Allows editor-based or code-based configuration of cinematic parameters.
##
## Usage:
##     # Option 1: Create .tres resource in editor
##     # Option 2: Override _get_config() in CinematicBase child class
class_name CinematicConfig
extends Resource


## Time in seconds before automatically advancing to next dialogue.
@export var time_per_dialogue: float = 10.0

## The scene path to transition to when cinematic completes.
@export_file("*.tscn") var next_scene_path: String = ""

## The cinematic name to play next (alternative to next_scene_path for chaining cinematics).
## If set, CinematicManager.play() will be called instead of change_scene_to_file().
@export var next_cinematic: String = ""

## Time to wait before transitioning after the last dialogue.
@export var end_delay: float = 12.0

## Whether this cinematic uses multiple images (false = text-only mode).
@export var uses_images: bool = true


@export_group("Audio")

## The initial audio stream to play (assigned in scene).
@export var initial_audio: AudioStream

## Audio switch configuration: maps dialogue index to audio resource path.
## When dialogue advances past this index, switches to the specified audio.
## Example: {6: "res://Sound/DecisiveMoment.mp3"}
@export var audio_switches: Dictionary = {}


@export_group("Dialogue")

## Array of dialogue strings for each frame/image.
@export_multiline var dialogues: PackedStringArray = []

## Maps each dialogue to an image number (1-based for human readability).
## Example: [1, 1, 1, 2, 3] = First 3 dialogues use image 01, then 02, then 03.
## If empty, defaults to 1:1 mapping (each dialogue advances to next image).
@export var image_sequence: PackedInt32Array = []
