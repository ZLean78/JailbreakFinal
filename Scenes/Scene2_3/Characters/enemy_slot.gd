## Legacy enemy slot - used by enemy_slot.tscn
## For new code, use Scenes/Characters/EnemySlot.gd
extends Node2D

var occupant: Node = null


func is_free()->bool:
	return occupant==null
	
func free_up()->void:
	occupant = null
	
func occupy(enemy: Node) -> void:
	occupant = enemy


func get_occupant() -> Node:
	return occupant
