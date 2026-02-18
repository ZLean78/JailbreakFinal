## Centralized damage type definitions for the combat system.
## Replaces the scattered HitType enums from DamageReceiver and DamageReceiver2.
##
## Usage:
##     var hit_type := DamageTypes.Type.POWER
##     var source := DamageTypes.Source.PLAYER
class_name DamageTypes
extends RefCounted


## The type of damage being dealt, determines how the receiver reacts.
enum Type {
	NORMAL,     ## Standard hit - triggers HURT state with basic knockback
	POWER,      ## Power attack - triggers FLY state (final combo hits, boss attacks)
	KNOCKDOWN,  ## Knockdown attack - triggers FALL state (jump attacks, kicks)
	KNOCKBACK,  ## Heavy knockback without knockdown - stronger horizontal push
}


## The source of the damage, useful for damage calculations and reactions.
enum Source {
	PLAYER,      ## Damage originated from player character
	ENEMY,       ## Damage from regular enemies (Sharaka, etc.)
	BOSS,        ## Damage from boss enemies (Kaluga, etc.)
	ENVIRONMENT, ## Damage from walls, hazards, traps
}
