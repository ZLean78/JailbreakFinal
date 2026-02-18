## Cinematic Intro - Collins' backstory in Zunanda and his arrest.
extends CinematicBase


func _get_config() -> CinematicConfig:
	var cfg := CinematicConfig.new()
	cfg.time_per_dialogue = 10.0
	cfg.next_scene_path = "res://Scenes/Menu/menu.tscn"
	cfg.end_delay = 12.0
	cfg.uses_images = true
	cfg.audio_switches = {
		4: "res://Sound/Shock.mp3",
		9: "res://Sound/DecisiveMoment.mp3"
	}
	cfg.dialogues = PackedStringArray([
		"En Zunanda, una joven república de África central, Geoffrey Collins, un\nmédico sin territorio, se encuentra dando lo mejor de sí para hacer la diferencia.",
		"Collins: listo, amiguito, vacunado contra sarampión,\npoliomielitis, difteria y paludismo.",
		"A lo lejos, la agente internacional Julia Mellinguer observa con admiración su labor.\nMellinguer: ¡buenos días, Doctor Collins!",
		"Mellinguer: ¡qué buen profesional y persona es Collins!",
		"Oficial: disculpe, doctor, pero debemos revisar su bolso.\nInspección de rutina, lo hemos hecho con todos los demás aquí.\nCollins: está bien.",
		"Oficial: ¿qué tenemos aquí? ¡Diamantes en bruto!\nCollins: ¡ey, eso no es mío!",
		"Collins: ¡yo no tomé eso ni lo puse en el bolso!",
		"Mellinguer: ¡no puede ser! ¡Se llevan a Collins!",
		"",
		"Mellinguer: no me detengas, Walton. Voy a renunciar.\nWalton: ¿ah, sí? ¿No quieres, en cambio, rescatar al muchacho?\nTengo un plan para sacarlo de allí, pero tendrá que cooperar y hacerme caso.\nMellinguer: ¡sí! ¡Pase lo que pase, hagámoslo!"
	])
	return cfg
