## Cinematic 5 - Collins fights and defeats Sharaka, escapes.
extends CinematicBase


func _get_config() -> CinematicConfig:
	var cfg := CinematicConfig.new()
	cfg.time_per_dialogue = 10.0
	cfg.next_scene_path = "res://Scenes/Scene2_4/scene_2_4.tscn"
	cfg.end_delay = 12.0
	cfg.uses_images = true
	cfg.audio_switches = {3: "res://Sound/DecisiveMoment.mp3"}
	cfg.dialogues = PackedStringArray([
		"Sharaka: 'el mundo está bien tal cual está...Gracias a este sistema, mis cuatro hijos pueden comer...\nNo vengas a hacerte el salvador de nadie...\nNo trates de cambiar el mundo.'",
		"Voz del pasado: '¡vamos, Collins!¡Muévete, patea ese balón\nde una buena vez!'",
		"Sharaka: ¡aaaah!",
		"Collins: ¡hora de dormir, Sharaka!",
		"",
		"Collins: hasta luego, 'amigo'."
	])
	return cfg
