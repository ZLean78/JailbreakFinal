class_name Desk2
extends StaticBody2D
@onready var player=%Player
@onready var game_manager=%GameManager
@onready var animation_player = $AnimationPlayer
@onready var raycast1 = $View/RayCast2D
@onready var raycast2 = $View/RayCast2D2
@onready var raycast3 = $View/RayCast2D3
@onready var cone = $View/Cone
@onready var label=%MainLabel

const SFX_GUARD_NOTICE_1 = preload("res://Sound/sfxGuardNoticePlayer.ogg")
const SFX_GUARD_NOTICE_2 = preload("res://Sound/sfxGuardNoticePlayer2.ogg")
const SFX_GUARD_NOTICE_3 = preload("res://Sound/sfxGuardNoticePlayer3.ogg")

var notice_audio_player: AudioStreamPlayer2D
var guard_notice_sounds: Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	notice_audio_player = AudioStreamPlayer2D.new()
	notice_audio_player.bus = "SFX"
	add_child(notice_audio_player)
	guard_notice_sounds = [SFX_GUARD_NOTICE_1, SFX_GUARD_NOTICE_2, SFX_GUARD_NOTICE_3]

func play_guard_notice_sound() -> void:
	if notice_audio_player and !notice_audio_player.is_playing():
		var random_index = randi() % guard_notice_sounds.size()
		notice_audio_player.stream = guard_notice_sounds[random_index]
		notice_audio_player.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if is_instance_valid(player):
		animate()

func animate():
	if game_manager.player_made_fb_noise:
		animation_player.play("check")
		check_view()
	else:
		animation_player.play("sleep")


func check_view():
	if (raycast1.get_collider()==player ||
	 	raycast2.get_collider()==player ||
		raycast3.get_collider()==player):
		cone.texture=load("res://Scenes/Desk2/ConeYellow.png")
		await (get_tree().create_timer(0.5).timeout)
		if (raycast1.get_collider()==player ||
	 		raycast2.get_collider()==player ||
			raycast3.get_collider()==player):
				if !GameStates.uniform_on:
					play_guard_notice_sound()
					player.state=player.States.dead
					label.text="¡Eh, tú!"
				else:
					await(get_tree().create_timer(3.0).timeout)
					if (raycast1.get_collider()==player ||
	 				raycast2.get_collider()==player ||
					raycast3.get_collider()==player):
						play_guard_notice_sound()
						player.state=player.States.dead
						label.text="¿¡Quién eres tú!?"
