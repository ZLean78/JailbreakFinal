## Base class for the Command pattern.
## Commands encapsulate actions that can be executed on a character.
## This decouples input handling from character logic.
##
## Usage:
##     class_name AttackCommand
##     extends Command
##
##     func execute(character: BaseCharacter) -> void:
##         character.try_attack()
##
##     func can_execute(character: BaseCharacter) -> bool:
##         return character.state_machine.can_attack()
class_name Command
extends RefCounted


## Executes the command on the given character.
## Must be overridden by subclasses.
func execute(_character: BaseCharacter) -> void:
	assert(false, "execute must be overridden")


## Returns whether this command can currently be executed.
## Override to add conditions.
func can_execute(_character: BaseCharacter) -> bool:
	return true
