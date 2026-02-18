extends Camera2D

@onready var label=%MainLabel
@onready var player=%Player

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	_follow_player()


func _follow_player():
	if is_instance_valid(player):
		position=Vector2(player.position.x,player.position.y)
		position.x=clamp(position.x,get_parent().get_node("CameraLimitMin").position.x,get_parent().get_node("CameraLimitMax").position.x)
		position.y=clamp(position.y,get_parent().get_node("CameraLimitMin").position.y,get_parent().get_node("CameraLimitMax").position.y)
		
	
	
