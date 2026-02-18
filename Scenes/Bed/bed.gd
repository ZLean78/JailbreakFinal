class_name Bed
extends StaticBody2D

const SFX_INMATE_NOTICE = preload("res://Sound/sfxInmateNoticePlayer.ogg")

@export var cell:int=0
@export var cell_mark:Marker2D
@export var player:CharacterBody2D=null
@onready var animation_player = $AnimationPlayer
@onready var ray_cast1 = $View/RayCast2D
@onready var ray_cast2 = $View/RayCast2D2
@onready var ray_cast3 = $View/RayCast2D3
@onready var sprite2 = $View/Sprite2D
@onready var view = $View
@onready var bed_sprite: Sprite2D = $Sprite2D
@onready var game_manager=%GameManager
@onready var label=%MainLabel
@onready var collision_shape=$CollisionShape2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

var type:int=0
var has_played_notice: bool = false
var forced_awake: bool = false

func _ready():
	type=randi_range(1,2)
	animation_player.play("Sleep"+str(type))
	ray_cast1.add_exception(self)
	ray_cast2.add_exception(self)
	ray_cast3.add_exception(self)
	if audio_player:
		audio_player.bus = "SFX"
		audio_player.stream = SFX_INMATE_NOTICE


func _process(_delta):
	if forced_awake:
		return
	if is_instance_valid(player):
		check_noise()
		check_collider()

func check_noise():
	if forced_awake:
		return
	if GameStates.player_has_made_noise && player.cell==cell:
		view.visible=true
		animation_player.play("Check" + str(type))
		
		if(ray_cast1.get_collider()==player ||
			ray_cast2.get_collider()==player ||
			ray_cast3.get_collider()==player):
			sprite2.texture=load("res://Scenes/Bed/ConeYellow.png")
			await(get_tree().create_timer(0.2).timeout)
			if(ray_cast1.get_collider()==player ||
			ray_cast2.get_collider()==player ||
			ray_cast3.get_collider()==player):
				if audio_player and !has_played_notice:
					audio_player.play()
					has_played_notice = true
				if get_tree().get_root().get_child(4).name=="Scene1":
					label.text="¡Alerta!"
					sprite2.texture=load("res://Scenes/Bed/ConeRed.png")
					game_manager.emit_signal("alert_state")
				elif get_tree().get_root().get_child(4).name=="Scene2":
					player.state=player.States.dead
	else:
		view.visible=false
		animation_player.play("Sleep"+str(type))
		has_played_notice = false	


func check_collider()->void:
	if player.state==player.States.crawling || player.state==player.States.crawl_idle:
		collision_shape.disabled=true
	else:
		collision_shape.disabled=false


## Forces the prisoner-in-bed to wake up (used on player loss).
func wake_up_for_loss() -> void:
	forced_awake = true
	view.visible = false
	has_played_notice = true
	if animation_player:
		animation_player.stop()

	# Use the same "awake" frames used by Check animations.
	if bed_sprite:
		if type == 1:
			bed_sprite.frame = 14
		else:
			bed_sprite.frame = 15
