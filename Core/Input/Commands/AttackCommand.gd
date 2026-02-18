## Command for initiating an attack.
class_name AttackCommand
extends Command


func execute(character: BaseCharacter) -> void:
	# Try jump attack if airborne, otherwise normal attack
	if character.state_machine.can_jump_attack():
		character.try_jump_attack()
	else:
		character.try_attack()


func can_execute(character: BaseCharacter) -> bool:
	return character.state_machine.can_attack() or character.state_machine.can_jump_attack()
