## Cinematic 3 - Amir Rahiri meets Collins and gives survival tips.
extends CinematicBase


func _get_config() -> CinematicConfig:
	var cfg := CinematicConfig.new()
	cfg.time_per_dialogue = 14.0
	cfg.next_scene_path = "res://Scenes/Scene2_2/scene_2_2.tscn"
	cfg.end_delay = 12.0
	cfg.uses_images = true
	cfg.audio_switches = {3: "res://Sound/DecisiveMoment.mp3"}
	cfg.dialogues = PackedStringArray([
		"¡Tranquilo, no te asustes!...No grites, estás con un amigo.",
		"Soy Amir Rahiri, tu contacto en esta prisión.\nSoy de Madagascar y estoy aquí por delitos menores.",
		"Rahiri: tengo una carta más de Walton para ti.\nMira, es su letra.",
		"'Querido Geoffrey, si ya has conocido a Amir, vas por buen camino'\nÉl te dará información sobre algunos ítems que te serán de utilidad\nDeberás continuar hasta la lavandería.\nTen especial cuidado con el jefe de pabellón, Benjamin Kaluga,\nboxeador profesional, y con su mano derecha, Mbeki Sharaka,\nque es mucho peor y tiene un particular odio por la gente com tú.\nSuerte, Geoffrey Collins.\nTu amigo,\nT.F.W.",
		"Rahiri: detrás del tender hay un botiquín.\nSi cierran las puertas, el conducto a la derecha será la única salida.\nLamentablemente, lleva al taller de Sharaka,\npero a esta hora, no debería estar allí.",
		"Collins:....\nRahiri:......suerte, Geoffrey Collins."
	])
	return cfg
