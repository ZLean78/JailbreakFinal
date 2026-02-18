## Cinematic 1 - Walton introduces himself as Collins' lawyer and explains the danger.
extends CinematicBase


func _get_config() -> CinematicConfig:
	var cfg := CinematicConfig.new()
	cfg.time_per_dialogue = 10.0
	cfg.next_scene_path = "res://Scenes/Scene1/scene_1.tscn"
	cfg.end_delay = 2.0
	cfg.uses_images = true
	cfg.audio_switches = {6: "res://Sound/Cinematic_1_valid2.mp3"}
	cfg.dialogues = PackedStringArray([
		"Guardia: Dr. Geoffrey Collins, su abogado está aquí.",
		"Walton: soy Thomas Frederic Walton y he asumido el rol de tu abogado.\nCollins: creí que tenía derecho a escoger mi abogado.\nWalton: confía en mí, estás en buenas manos.\nEntremos, por favor.",
		"Walton: lo que te voy a decir ahora es horroroso, pero es la verdad\nTe preguntarás '¿cómo es que este viejo viene hasta aquí\ndiciendo ser mi abogado y luego me cuenta ésto?'.",
		"Walton: me encantaría poder defenderte ante un estrado\ny que salieras en libertad, ganando airoso contra estos desgraciados.\nPero la verdad, Geoffrey, es que alguien trata de matarte,\npor eso te puso aquí.",
		"Walton: yo soy abogado, sí, pero mi rol de abogado en esta historia es una fachada.\nEstoy aquí para ayudarte a salir de este nido de ratas.",
		"Collins: ¿alguien quiere matarme?, ¿¡quién!?\nWalton: sé que mi historia no suena nada convincente, pero debes creerme.\nNo sólo estoy haciendo esto por ti, sino por alguien a quien le preocupas mucho.\nTú no la conoces demasiado, pero ELLA sí te conoce a ti.",
		"Walton: ahora, vamos a entrenarte, para que puedas escapar.\nTengo algo aquí para ti, un libro. Parece poco, pero es la llave para dar el primer paso.\nExamínalo cuando vuelvas a tu celda, busca una forma de salir de allí, y explora los alrededores sin ser visto.",
		"Collins: ¿pero, quién quiere matarme?\nWalton: no te conviene saberlo ahora, sólo haz lo que te digo,y confía en mí.\nSuerte, Geoffrey Collins."
	])
	return cfg
