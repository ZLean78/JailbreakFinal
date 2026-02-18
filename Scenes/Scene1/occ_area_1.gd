extends Area2D

@export var door:YellowDoor=null



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if door.open:
		visible=false
	else:
		visible=true
