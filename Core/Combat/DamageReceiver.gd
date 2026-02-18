## Unified damage receiver component that replaces both DamageReceiver and DamageReceiver2.
## Attach to characters as a child Area2D to receive damage from DamageEmitter collisions.
##
## Emits damage_received signal with full context (damage data, direction, source).
## Supports immunity frames and damage multipliers.
##
## Usage:
##     @onready var damage_receiver: DamageReceiver = $DamageReceiver
##
##     func _ready() -> void:
##         damage_receiver.damage_received.connect(_on_damage_received)
##
##     func _on_damage_received(data: DamageData, direction: Vector2, source: Node) -> void:
##         health_component.take_damage(data.amount)
class_name DamageReceiver
extends Area2D


## Emitted when damage is received. Connect to this to handle damage.
## Parameters:
##   - damage_data: DamageData resource with all damage information
##   - direction: Vector2 indicating the direction damage came from (for knockback)
##   - source: Node that dealt the damage (can be null for environmental damage)
signal damage_received(damage_data: DamageData, direction: Vector2, source: Node)


## Multiplier applied to all incoming damage (for resistances/vulnerabilities).
@export var damage_multiplier: float = 1.0

## Duration of immunity after taking damage (0 = no immunity frames).
@export var immunity_duration: float = 0.0

## Whether this receiver is currently active and can receive damage.
@export var is_active: bool = true


## Internal timer tracking remaining immunity time.
var _immunity_timer: float = 0.0


func _process(delta: float) -> void:
	if _immunity_timer > 0.0:
		_immunity_timer -= delta


## Returns true if this receiver can currently take damage.
func can_receive_damage() -> bool:
	if not is_active:
		return false
	if _immunity_timer > 0.0:
		return false
	return true


## Called by DamageEmitter when damage should be applied.
## Applies damage multiplier and immunity frame logic before emitting signal.
func receive_damage(damage_data: DamageData, direction: Vector2, source: Node) -> void:
	if not can_receive_damage():
		return

	if damage_data.ignores_immunity:
		pass
	elif _immunity_timer > 0.0:
		return

	# Apply damage multiplier if not 1.0
	var final_damage := damage_data
	if not is_equal_approx(damage_multiplier, 1.0):
		final_damage = damage_data.with_multiplier(damage_multiplier)

	# Start immunity frames if configured
	if immunity_duration > 0.0:
		_immunity_timer = immunity_duration

	damage_received.emit(final_damage, direction, source)


## Temporarily disables damage reception.
func disable() -> void:
	is_active = false


## Re-enables damage reception.
func enable() -> void:
	is_active = true


## Grants temporary immunity for the specified duration.
func grant_immunity(duration: float) -> void:
	_immunity_timer = maxf(_immunity_timer, duration)


## Returns whether currently immune to damage.
func is_immune() -> bool:
	return _immunity_timer > 0.0
