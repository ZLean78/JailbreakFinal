extends Node2D

@onready var color_rect=%ColorRect
@onready var box_container=%BoxContainer

@onready var player=%Player
@onready var map_2 = $Map2
@onready var tilemap = $Map2/TileMap
@onready var tilemap2 = $Map2/TileMap2
@onready var tilemap3 = $Map2/TileMap3
@onready var animation_player = $Map2/TileMap/AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	tilemap2.set_layer_enabled(0,false)
	GameStates.uniform_on=false
	if GameStates.has_letter1:
		player.position=$Pausable/Letter.position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _input(_event):
	if Input.is_action_pressed("UI"):
		color_rect.visible=!color_rect.visible
		box_container.visible=!box_container.visible
		set_tree_pause(get_tree().paused)
		
func set_tree_pause(paused:bool):
	if paused:
		get_tree().paused=false
	else:
		get_tree().paused=true
