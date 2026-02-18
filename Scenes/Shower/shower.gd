extends StaticBody2D

@export var player:CharacterBody2D=null
@onready var game_manager=%GameManager
@onready var label=%MainLabel
@onready var animation_player = $AnimationPlayer
@onready var raycast1 = $ShowerGuard/RayCast2D
@onready var raycast2 = $ShowerGuard/RayCast2D2
@onready var raycast3 = $ShowerGuard/RayCast2D3

const SFX_GUARD_NOTICE_1 = preload("res://Sound/sfxGuardNoticePlayer.ogg")
const SFX_GUARD_NOTICE_2 = preload("res://Sound/sfxGuardNoticePlayer2.ogg")
const SFX_GUARD_NOTICE_3 = preload("res://Sound/sfxGuardNoticePlayer3.ogg")

var notice_audio_player: AudioStreamPlayer2D
var guard_notice_sounds: Array = []

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

func _process(_delta):
	check_wd_noise()


func check_wd_noise():
	if is_instance_valid(player):
		if game_manager.player_made_waterdrain_noise:
			animation_player.play("checking")
			if (raycast1.get_collider()==player ||
			 	raycast2.get_collider()==player ||
			 	raycast3.get_collider()==player):
					play_guard_notice_sound()
					player.queue_free()
					await(get_tree().create_timer(2.0).timeout)
					get_tree().reload_current_scene()
		else:
			animation_player.play("Dancing")


func _on_guard_area_body_entered(body):
	if body==player:
		play_guard_notice_sound()
		animation_player.play("checking")
		label.text="¡Eh, usted!"
		await(get_tree().create_timer(3.0).timeout)
		player.dead=true
