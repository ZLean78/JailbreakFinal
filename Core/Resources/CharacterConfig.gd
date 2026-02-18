## Configuration resource for a character.
## Wraps CharacterStats with additional metadata and settings.
##
## Usage:
##     # In editor: Create CharacterConfig resource
##     # Assign CharacterStats resource to stats property
##     # Set character name, flags, etc.
class_name CharacterConfig
extends Resource


## The character's stats (health, speed, damage, etc).
@export var stats: CharacterStats

## Display name for this character.
@export var character_name: String = "Character"

## Whether this is a player-controlled character.
@export var is_player: bool = false

## Whether this character can respawn after death.
@export var can_respawn: bool = false

## Whether this character can be stunned.
@export var can_be_stunned: bool = true

## Whether this character is a boss.
@export var is_boss: bool = false


@export_group("Animation Overrides")

## Override specific state animations.
## Key: state name (e.g., "Idle"), Value: animation name.
@export var animation_overrides: Dictionary = {}


@export_group("AI Settings")

## Distance at which AI starts chasing.
@export var chase_distance: float = 300.0

## Distance at which AI attacks.
@export var attack_distance: float = 50.0

## Distance at which AI disengages.
@export var disengage_distance: float = 500.0


## Returns the animation name for a state, considering overrides.
func get_animation_for_state(state_name: String, default_anim: String) -> String:
	if state_name in animation_overrides:
		return animation_overrides[state_name]
	return default_anim


## Returns whether this character should use AI.
func uses_ai() -> bool:
	return not is_player


## Validates the configuration and returns any issues.
func validate() -> Array[String]:
	var issues: Array[String] = []

	if stats == null:
		issues.append("No CharacterStats assigned")
	else:
		if stats.max_health <= 0:
			issues.append("max_health must be > 0")
		if stats.speed < 0:
			issues.append("speed cannot be negative")
		if stats.attack_animations.is_empty():
			issues.append("attack_animations is empty")

	if character_name.is_empty():
		issues.append("character_name is empty")

	return issues
