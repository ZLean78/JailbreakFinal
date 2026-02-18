## Legacy DamageReceiver - no longer used.
## For new code, use Core/Combat/DamageReceiver.gd
extends Area2D

enum HitType{NORMAL,KNOCKDOWN,POWER}

signal damage_received(damage:int,direction:Vector2,hit_type:HitType)
