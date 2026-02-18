## Cinematic 4 - Sharaka confronts Collins about his "savior" mentality.
extends CinematicBase


func _get_config() -> CinematicConfig:
	var cfg := CinematicConfig.new()
	cfg.time_per_dialogue = 8.0
	cfg.next_scene_path = "res://Scenes/Scene2_3/scene_2_3.tscn"
	cfg.end_delay = 12.0
	cfg.uses_images = true
	cfg.audio_switches = {}
	cfg.dialogues = PackedStringArray([
		"Collins:.....",
		"Sharaka: llegas tarde, Collins. Estaba esperándote.",
		"Sharaka: el bueno de Collins, el que todo lo puede. El gran salvador.",
		"Sharaka: no trates de cambiar el mundo.\nEl mundo está bien tal cual está.\nGracias a este sistema, mis cuatro hijos pueden comer.",
		"Collins: entiendo lo de la diferencia de oportunidades,\npero no la tomes conmigo, que soy uno de los que\nquieren reducir esa diferencia.",
		"Sharaka: tu no sabes nada. ¡No vengas aquí a hacerte el salvador de nadie!",
		"Collins: de acuerdo, muy bien, ¡ataca! Aquí te espero."
	])
	return cfg
