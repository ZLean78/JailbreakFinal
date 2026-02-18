## Global cinematic manager for loading cinematics by name.
## Add this as an autoload named "CinematicManager" in Project Settings.
##
## Usage:
##     CinematicManager.play("intro")
##     CinematicManager.play("chapter1")
extends Node


const CinematicLoaderScene = preload("res://Core/Cinematics/CinematicLoader.tscn")
const CINEMATICS_PATH = "res://Cinematics/"


## Plays a cinematic by folder name.
## @param cinematic_name: The folder name under res://Cinematics/ (e.g., "intro", "chapter1")
func play(cinematic_name: String) -> void:
	var cinematic_path := CINEMATICS_PATH + cinematic_name

	# Verify the folder exists
	if not DirAccess.dir_exists_absolute(cinematic_path):
		push_error("CinematicManager: Cinematic folder not found: " + cinematic_path)
		return

	# Instantiate and configure the loader
	var loader = CinematicLoaderScene.instantiate()
	loader.cinematic_path = cinematic_path

	# Replace current scene with the loader
	var old_scene = get_tree().current_scene
	get_tree().root.add_child(loader)
	get_tree().current_scene = loader
	if old_scene:
		old_scene.queue_free()
