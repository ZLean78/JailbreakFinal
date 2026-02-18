## Cinematic 2 - Collins reads Walton's letter explaining the conspiracy.
extends CinematicBase


func _get_config() -> CinematicConfig:
	var cfg := CinematicConfig.new()
	cfg.time_per_dialogue = 14.0
	cfg.next_scene_path = "res://Scenes/Scene2/scene_2.tscn"
	cfg.end_delay = 12.0
	cfg.uses_images = false
	cfg.audio_switches = {}
	cfg.dialogues = PackedStringArray([
		"Querido Geoffrey,\nahora que has llegado hasta aquí, ya estás en condiciones de conocer los pormenores de esta historia.",
		"Seguramente habrás oído hablar del conglomerado polifarmacéutico 'Aluminum Pharma'.\nPues bien, ellos son quienes están detrás de que un alto funcionario del gobierno de Zunanda\nte incriminara y te hiciera encarcelar.",
		"Ellos tienen un acuerdo con el gobierno por el cual\nvan a estar a cargo de la implementación del plan de salud.",
		"Para ellos esto es un negocio, y la gente como tú les molesta.\nLa idea es que a quien no pueda pagar, se le brinde 'opciones',\npero de ninguna forma debe esa persona recibir atención médica gratuita.",
		"Tú has sido el más reacio de los miembros de Médicos sin Territorio a abandonar el país,\ngracias a que tu primo, abogado, conoce bien la legislación internacional.\nEs por eso que la mano derecha del Ministro de Salud\nha tomado la decisión de matarte.",
		"No es por acabar contigo en sí que lo hace,\nsino porque quiere que tu muerte sirva de\nescarmiento a los demás Médicos sin Territorio en el país.",
		"Ahora ya sabes la verdad. No dejes que te afecte.\nMantén la mente en frío y recuerda\nque si vemos que tu vida corre peligro, intervendremos.\nEn el pasillo donde tu estás hay unas rejillas que no hacen ruido.\nTe darás cuenta cuando las veas. Sólo ponte delante de ellas\ny no las toques si no estás seguro. Te llevarán adonde tienes que llegar.",
		"¡Sigue adelante, Geoffrey Collins!\nTu amigo,\nT.F.W.\n\nCollins: increíble..."
	])
	return cfg
