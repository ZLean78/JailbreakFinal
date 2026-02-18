## Command for character movement.
## Applies a movement direction to the character's movement component.
class_name MoveCommand
extends Command


## The movement direction.
var direction: Vector2


func _init(move_direction: Vector2 = Vector2.ZERO) -> void:
	direction = move_direction


func execute(character: BaseCharacter) -> void:
	character.movement_component.set_input_direction(direction)


func can_execute(character: BaseCharacter) -> bool:
	return character.state_machine.can_move()
