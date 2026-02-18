extends Node



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if %Player.health<=0:
		get_tree().reload_current_scene()


func _on_chase_area_body_entered(body):
	if body.is_in_group("player"):
		for a_dog in get_tree().get_nodes_in_group("dogs"):
			a_dog.can_chase=true


func _on_chase_area_body_exited(body):
	if body.is_in_group("dogs"):
		body.can_chase=false
