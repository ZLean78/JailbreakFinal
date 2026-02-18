## Controller node that manages AI behavior for a character.
## Owns and updates an AIStrategy, allowing hot-swapping behaviors.
##
## Usage:
##     # Add as child of enemy character
##     @onready var ai: AIController = $AIController
##
##     func _ready() -> void:
##         ai.set_strategy(BasicMeleeStrategy.new())
##         ai.set_target(player)
class_name AIController
extends Node


## The character this controller manages.
@export var character: BaseCharacter

## The target for the AI to pursue.
@export var target: BaseCharacter

## Whether the AI is currently active.
@export var is_active: bool = true


## The current AI strategy.
var strategy: AIStrategy


func _ready() -> void:
	if character == null:
		character = get_parent() as BaseCharacter
		if character == null:
			push_error("AIController: No character found")


func _process(delta: float) -> void:
	if not is_active:
		return

	if strategy == null:
		return

	if character == null:
		return

	# Don't update AI if character is incapacitated
	if character.state_machine.is_incapacitated():
		return

	strategy.update(delta)


## Sets a new AI strategy.
func set_strategy(new_strategy: AIStrategy) -> void:
	strategy = new_strategy
	strategy.initialize(character)
	if target:
		strategy.set_target(target)


## Sets the target for the AI.
func set_target(new_target: BaseCharacter) -> void:
	target = new_target
	if strategy:
		strategy.set_target(target)


## Enables AI processing.
func enable() -> void:
	is_active = true


## Disables AI processing.
func disable() -> void:
	is_active = false
