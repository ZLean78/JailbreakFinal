extends Node2D

@onready var ui=%UI

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		if GameStates.meat_can<=0:
			GameStates.meat_can_amount=5
		GameStates.meat_can+=1
		if ui and ui.has_method("update_items"):
			ui.update_items()
		queue_free()
