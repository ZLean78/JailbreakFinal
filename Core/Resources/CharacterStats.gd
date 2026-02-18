## Resource containing all stat values for a character.
## Saves as .tres files for easy editing and reuse.
## Replaces scattered @export variables across character scripts.
##
## Usage:
##     # Create in editor: Resources/Characters/player_stats.tres
##     # Or in code:
##     var stats := CharacterStats.new()
##     stats.max_health = 100
##     stats.speed = 150.0
class_name CharacterStats
extends Resource


@export_group("Health")

## Maximum health points.
@export var max_health: int = 100

## Starting health (0 = use max_health).
@export var starting_health: int = 0

## Whether health regenerates over time.
@export var can_regenerate: bool = false

## Health regeneration rate (per second).
@export var regeneration_rate: float = 0.0


@export_group("Movement")

## Base movement speed.
@export var speed: float = 100.0

## Movement acceleration (higher = snappier).
@export var acceleration: float = 10.0

## Movement friction/deceleration.
@export var friction: float = 10.0


@export_group("Combat")

## Base damage for normal attacks.
@export var base_damage: int = 10

## Damage for power attacks (final combo hit).
@export var power_damage: int = 20

## Array of attack animation names for combo sequence.
@export var attack_animations: Array[String] = ["punch"]

## Time window to continue combo after hit.
@export var combo_window: float = 0.5


@export_group("Physics")

## Initial vertical speed when jumping.
@export var jump_intensity: float = 300.0

## Horizontal knockback force when hit.
@export var knockback_intensity: float = 150.0

## Vertical force when knocked down.
@export var knockdown_intensity: float = 250.0

## Speed when launched by power attack.
@export var flight_speed: float = 200.0

## Gravity acceleration.
@export var gravity: float = 600.0


@export_group("State Durations")

## Time spent on ground after knockdown before recovery/death.
@export var grounded_duration: float = 0.5

## Duration of hurt state hitstun.
@export var hurt_duration: float = 0.5

## Duration of stun effect.
@export var stun_duration: float = 1.0

## Cooldown between attacks (for enemies).
@export var attack_cooldown: float = 1.0


## Creates a copy of these stats with modifications.
func duplicate_stats() -> CharacterStats:
	var copy := CharacterStats.new()
	copy.max_health = max_health
	copy.starting_health = starting_health
	copy.can_regenerate = can_regenerate
	copy.regeneration_rate = regeneration_rate
	copy.speed = speed
	copy.acceleration = acceleration
	copy.friction = friction
	copy.base_damage = base_damage
	copy.power_damage = power_damage
	copy.attack_animations = attack_animations.duplicate()
	copy.combo_window = combo_window
	copy.jump_intensity = jump_intensity
	copy.knockback_intensity = knockback_intensity
	copy.knockdown_intensity = knockdown_intensity
	copy.flight_speed = flight_speed
	copy.gravity = gravity
	copy.grounded_duration = grounded_duration
	copy.hurt_duration = hurt_duration
	copy.stun_duration = stun_duration
	copy.attack_cooldown = attack_cooldown
	return copy
