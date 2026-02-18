## Command for jumping.
class_name JumpCommand
extends Command


func execute(character: BaseCharacter) -> void:
	character.try_jump()


func can_execute(character: BaseCharacter) -> bool:
	return character.state_machine.can_jump()
