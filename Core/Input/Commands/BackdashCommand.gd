## Command for backdash evasion.
class_name BackdashCommand
extends Command


## Direction of the backdash (opposite of facing).
var dash_direction: Vector2


func _init(direction: Vector2 = Vector2.LEFT) -> void:
	dash_direction = direction


func execute(character: BaseCharacter) -> void:
	# Set backdash direction on the state
	character.state_machine.backdash_state.dash_direction = dash_direction
	character.state_machine.transition_to(&"Backdash")


func can_execute(character: BaseCharacter) -> bool:
	return character.state_machine.can_move()
