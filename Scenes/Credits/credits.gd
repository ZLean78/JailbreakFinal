extends Node2D

@onready var credits_label: Label = $CreditsLabel
@onready var timer: Timer = $Timer
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var image_rect: TextureRect = $ImageRect

const SCROLL_SPEED := 50.0
const IMAGE_DISPLAY_TIME := 4.0
const FADE_DURATION := 1.0

var _can_skip := false
var _image_paths: Array[String] = [
	"res://Cinematics/intro/02_collins_working.png",
	"res://Cinematics/intro/09_collins_arrested_outside.png",
	"res://Cinematics/chapter1/03_collins_walton_table.jpeg",
	"res://Cinematics/chapter2/02.png",
	"res://Cinematics/chapter3/02_smiling_rahiri.png",
	"res://Cinematics/chapter4/01_collins_vent.png",
	"res://Cinematics/chapter4/03_sharaka_serious.png",
	"res://Cinematics/chapter5/03_kicking.png",
	"res://Cinematics/chapter6/03.png",
	"res://Cinematics/chapter6_post/09.png",
	"res://Cinematics/chapter7/05_Collins_y_Mellinger_Final2.png",
	"res://Cinematics/chapter7/10_Collins_Mellinguer_y_Sr_Mellinguer_Final.png",
]
var _current_image_index := 0
var _image_timer := 0.0
var _fade_alpha := 0.0
var _fading_in := true


func _ready() -> void:
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
	audio_player.bus = "Music"

	# Set credits label starting position (start below screen, scroll up)
	# Right half of 1152x648 screen: x=582, 20px margin from right (1132-550=582)
	credits_label.position = Vector2(582, 660)

	_show_next_image()

	await get_tree().create_timer(1.0).timeout
	_can_skip = true


func _show_next_image() -> void:
	if _image_paths.is_empty():
		return

	var image_path := _image_paths[_current_image_index]
	var texture := load(image_path) as Texture2D
	if texture:
		image_rect.texture = texture

	_current_image_index = (_current_image_index + 1) % _image_paths.size()
	_image_timer = 0.0
	_fade_alpha = 0.0
	_fading_in = true


func _process(delta: float) -> void:
	# Scroll credits upward
	credits_label.position.y -= SCROLL_SPEED * delta

	# Check if credits have scrolled off screen
	if credits_label.position.y + credits_label.size.y < 0:
		_go_to_menu()

	# Handle image fade transitions
	_update_image_fade(delta)


func _update_image_fade(delta: float) -> void:
	_image_timer += delta

	if _fading_in:
		_fade_alpha = minf(_fade_alpha + delta / FADE_DURATION, 1.0)
		if _fade_alpha >= 1.0:
			_fading_in = false
	else:
		var time_showing := _image_timer - FADE_DURATION
		if time_showing >= IMAGE_DISPLAY_TIME:
			_fade_alpha = maxf(_fade_alpha - delta / FADE_DURATION, 0.0)
			if _fade_alpha <= 0.0:
				_show_next_image()

	image_rect.modulate.a = _fade_alpha


func _input(event: InputEvent) -> void:
	if not _can_skip:
		return

	if event.is_action_pressed("ui_accept") or event.is_action_pressed("Escape"):
		_go_to_menu()
	elif event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
			_go_to_menu()


func _go_to_menu() -> void:
	GameStates.reset_game_state()
	GameStates.save_to_file()
	get_tree().change_scene_to_file("res://Scenes/Menu/menu.tscn")


func _on_timer_timeout() -> void:
	_go_to_menu()
