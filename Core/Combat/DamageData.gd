## Resource class containing all information about a damage instance.
## Replaces the scattered damage parameters and magic numbers.
##
## Can be created at runtime or saved as .tres files for preset damage types.
##
## Usage:
##     var damage := DamageData.new()
##     damage.amount = 10
##     damage.type = DamageTypes.Type.POWER
##     receiver.receive_damage(damage, direction, self)
class_name DamageData
extends Resource


## The amount of damage to deal.
@export var amount: int = 10

## The type of damage, determines receiver's reaction.
@export var type: DamageTypes.Type = DamageTypes.Type.NORMAL

## The source of the damage.
@export var source_type: DamageTypes.Source = DamageTypes.Source.ENEMY


@export_group("Physics")

## Horizontal knockback force applied on hit.
@export var knockback_force: float = 150.0

## Vertical force applied for knockdown attacks.
@export var knockdown_force: float = 250.0

## Speed for power hits that launch enemies.
@export var flight_speed: float = 200.0


@export_group("Status Effects")

## Duration the target remains stunned (0 = no stun).
@export var stun_duration: float = 0.0

## Duration of hitstun preventing actions (0 = default based on type).
@export var hitstun_duration: float = 0.0


@export_group("Flags")

## Whether this damage can be blocked.
@export var can_be_blocked: bool = true

## Whether this damage can be dodged/rolled through.
@export var can_be_dodged: bool = true

## Whether this damage ignores invincibility frames.
@export var ignores_immunity: bool = false


## Creates a modified copy of this damage data with a multiplier applied.
func with_multiplier(multiplier: float) -> DamageData:
	var copy := DamageData.new()
	copy.amount = int(amount * multiplier)
	copy.type = type
	copy.source_type = source_type
	copy.knockback_force = knockback_force * multiplier
	copy.knockdown_force = knockdown_force * multiplier
	copy.flight_speed = flight_speed * multiplier
	copy.stun_duration = stun_duration
	copy.hitstun_duration = hitstun_duration
	copy.can_be_blocked = can_be_blocked
	copy.can_be_dodged = can_be_dodged
	copy.ignores_immunity = ignores_immunity
	return copy


## Creates a DamageData configured for normal attacks.
static func create_normal(damage_amount: int, knockback: float = 150.0) -> DamageData:
	var data := DamageData.new()
	data.amount = damage_amount
	data.type = DamageTypes.Type.NORMAL
	data.knockback_force = knockback
	return data


## Creates a DamageData configured for power attacks (final combo hit).
static func create_power(damage_amount: int, flight: float = 200.0) -> DamageData:
	var data := DamageData.new()
	data.amount = damage_amount
	data.type = DamageTypes.Type.POWER
	data.flight_speed = flight
	return data


## Creates a DamageData configured for knockdown attacks (jump attacks).
static func create_knockdown(damage_amount: int, knockback: float = 150.0, knockdown: float = 250.0) -> DamageData:
	var data := DamageData.new()
	data.amount = damage_amount
	data.type = DamageTypes.Type.KNOCKDOWN
	data.knockback_force = knockback
	data.knockdown_force = knockdown
	return data
