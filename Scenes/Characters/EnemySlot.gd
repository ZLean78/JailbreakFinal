## Represents a position around the player where enemies can stand to attack.
## Used for coordinated enemy positioning and attack patterns.
class_name EnemySlot
extends Node2D


## The enemy currently occupying this slot.
var occupant: Node = null


## Returns whether this slot is available.
func is_free() -> bool:
	return occupant == null


## Assigns an enemy to this slot.
func occupy(enemy: Node) -> void:
	occupant = enemy


## Clears the occupant from this slot.
func free_up() -> void:
	occupant = null


## Returns the current occupant.
func get_occupant() -> Node:
	return occupant
