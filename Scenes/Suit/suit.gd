class_name Suit
extends Node2D

@onready var player=%Player
@onready var label=%MainLabel
@onready var ui=%UI
@onready var area: Area2D = $Area2D
@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D

var _picked_up := false


func _on_area_2d_body_entered(body):
	# Prevent multiple pickups/duplicate inventory inserts.
	if _picked_up:
		return
	if body != player:
		return
	if GameStates.has_uniform:
		_picked_up = true
		queue_free()
		return

	_picked_up = true
	# Disable interactions immediately (Area2D can otherwise re-trigger while we show text).
	area.set_deferred("monitoring", false)
	area.set_deferred("monitorable", false)
	collision_shape.set_deferred("disabled", true)

	GameStates.has_uniform = true
	visible = false

	# Update inventory deterministically (prevents the uniform appearing in multiple slots).
	if ui and ui.has_method("update_items"):
		ui.update_items()

	# UI.gd auto-hides help after 3 seconds globally.
	label.text = "Tienes un uniforme de policía.\nAbre tu inventario para seleccionarlo."
	queue_free()
