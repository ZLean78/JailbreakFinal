class_name Hole
extends Node2D

@onready var activated_timer:Timer=$ActivatedTimer
@onready var particles:GPUParticles2D=$Particles


var is_activated=false

## Tracks which bodies are currently in the gas area
var _bodies_in_area: Array[Node] = []


func _on_area_body_entered(body):
	if body.is_in_group("player") or body.is_in_group("kaluga"):
		if body not in _bodies_in_area:
			_bodies_in_area.append(body)
		if body.is_in_group("kaluga"):
			print("kaluga entered gas area")


func _on_area_body_exited(body):
	if body.is_in_group("player") or body.is_in_group("kaluga"):
		_bodies_in_area.erase(body)


## Returns whether a body is currently in the gas area
func is_body_in_area(body: Node) -> bool:
	return body in _bodies_in_area


func _on_activated_timer_timeout():
	is_activated=false
	particles.emitting=false
