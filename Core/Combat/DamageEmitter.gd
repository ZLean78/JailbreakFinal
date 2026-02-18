## Damage emitter component that deals damage to DamageReceivers on collision.
## Attach to characters as a child Area2D to deal damage when attacking.
##
## The emitter detects when it overlaps with DamageReceiver areas and
## calls their receive_damage method with the configured damage data.
##
## Usage:
##     @onready var damage_emitter: DamageEmitter = $DamageEmitter
##
##     func attack() -> void:
##         var damage := DamageData.create_normal(10)
##         damage_emitter.set_damage(damage)
##         damage_emitter.enable()
##
##     func on_attack_complete() -> void:
##         damage_emitter.disable()
class_name DamageEmitter
extends Area2D


## Emitted when damage is successfully dealt to a target.
## Useful for hit confirmation, combo tracking, effects.
signal damage_dealt(receiver: DamageReceiver, damage_data: DamageData)

## Emitted when the emitter hits something but damage was not applied
## (e.g., target was immune or blocking).
signal hit_blocked(receiver: DamageReceiver)


## The damage data to apply when hitting a receiver.
## Can be changed dynamically based on attack type.
@export var current_damage: DamageData

## The node considered as the source of damage (usually the owner character).
## If null, uses get_parent().
@export var damage_source: Node

## Whether this emitter is currently active and can deal damage.
@export var is_active: bool = false

## Receivers that should be ignored (e.g., self, allies).
## Checked by instance_id for performance.
var _ignored_receivers: Array[int] = []

## Tracks receivers already hit this attack to prevent multi-hit.
var _hit_this_attack: Array[int] = []


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	if damage_source == null:
		damage_source = get_parent()


## Called when this emitter overlaps with another area.
func _on_area_entered(area: Area2D) -> void:
	if not is_active:
		return

	if not area is DamageReceiver:
		return

	var receiver := area as DamageReceiver

	# Check if this receiver should be ignored
	if receiver.get_instance_id() in _ignored_receivers:
		return

	# Check if already hit this attack
	if receiver.get_instance_id() in _hit_this_attack:
		return

	# Attempt to deal damage
	_deal_damage_to(receiver)


## Deals damage to a specific receiver.
func _deal_damage_to(receiver: DamageReceiver) -> void:
	if current_damage == null:
		push_warning("DamageEmitter: No damage data configured")
		return

	if not receiver.can_receive_damage():
		hit_blocked.emit(receiver)
		return

	# Calculate direction from emitter to receiver (for knockback)
	var direction := Vector2.ZERO
	if receiver.global_position.x < global_position.x:
		direction = Vector2.LEFT
	else:
		direction = Vector2.RIGHT

	# Mark as hit to prevent multi-hit this attack
	_hit_this_attack.append(receiver.get_instance_id())

	# Deal the damage
	receiver.receive_damage(current_damage, direction, damage_source)
	damage_dealt.emit(receiver, current_damage)


## Enables the emitter to deal damage.
func enable() -> void:
	is_active = true
	# Also enable Area2D monitoring so overlap events fire.
	monitoring = true


## Disables the emitter from dealing damage.
func disable() -> void:
	is_active = false
	monitoring = false


## Clears the hit tracking for a new attack.
## Call this when starting a new attack sequence.
func reset_hit_tracking() -> void:
	_hit_this_attack.clear()


## Sets the damage data to use for hits.
func set_damage(damage_data: DamageData) -> void:
	current_damage = damage_data


## Adds a receiver to the ignore list (e.g., self, allies).
func add_ignored_receiver(receiver: DamageReceiver) -> void:
	var id := receiver.get_instance_id()
	if id not in _ignored_receivers:
		_ignored_receivers.append(id)


## Removes a receiver from the ignore list.
func remove_ignored_receiver(receiver: DamageReceiver) -> void:
	var id := receiver.get_instance_id()
	_ignored_receivers.erase(id)


## Clears all ignored receivers.
func clear_ignored_receivers() -> void:
	_ignored_receivers.clear()


## Enables the emitter and starts a new attack with the given damage.
## Convenience method combining set_damage, reset_hit_tracking, and enable.
func start_attack(damage_data: DamageData) -> void:
	set_damage(damage_data)
	reset_hit_tracking()
	enable()


## Disables the emitter and clears hit tracking.
## Call when attack animation ends.
func end_attack() -> void:
	disable()
	reset_hit_tracking()
