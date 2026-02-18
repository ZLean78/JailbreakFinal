extends StaticBody2D

const SFX_GRID_OPEN = preload("res://Sound/sfxGridOpen.ogg")

var conduct_open=false
var can_open_conduct=false

@export var help_sprite:Sprite2D=null
@export var main_label:Label=null

@onready var sprite = Sprite2D
@onready var player=%Player
@onready var collision_shape=$CollisionShape2D
@onready var animation_player=$AnimationPlayer
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

var hp_button_e="res://Scenes/UI/HelpButtonE.png"

func _ready():
	if audio_player:
		audio_player.bus = "SFX"
		audio_player.stream = SFX_GRID_OPEN

func _physics_process(_delta):
	check_collider()

func _input(_event):
	if Input.is_action_just_pressed("Interact") && can_open_conduct:
		if GameStates.has_pen:
			open_conduct()
		
func open_conduct():
	if !conduct_open:
		conduct_open=true
		animation_player.play("open")
		if audio_player:
			audio_player.play()
		collision_shape.disabled=true
	#else:
		#conduct_open=false
		#animation_player.play("close")
		#collision_shape.disabled=false

func check_collider():
	if is_instance_valid(player):
		if conduct_open && player.state==player.States.crawling:
			collision_shape.disabled=true
		else:
			collision_shape.disabled=false
		
func animate():
	if conduct_open:
		animation_player.play("open")
	else:
		animation_player.play("close")

func _on_conduct_area_body_entered(body):
	if body==player:
		if !GameStates.game_won:
			body.interaction_area_entered=true
			can_open_conduct=true
			help_sprite.texture=load(hp_button_e)
			main_label.text="INTERACTUAR"
	if body.is_in_group("guards"):
		collision_shape.disabled=false
		


func _on_conduct_area_body_exited(body):
	if body==player:
		if !GameStates.game_won:
			body.interaction_area_entered=false
			can_open_conduct=false
			help_sprite.texture=null
			main_label.text=""
