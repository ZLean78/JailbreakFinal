## Player character implementation.
## Extends BaseCharacter with input handling and enemy slot system.
class_name PlayerCharacter
extends BaseCharacter


## Emitted when player interacts with something.
signal interacted(target: Node)


## Input handler for player controls.
var input_handler: PlayerInputHandler

## Enemy slots for coordinated enemy attacks.
@export var enemy_slots: Array[Node2D] = []

## Reference to lever for interaction.
@export var lever: Node

## Whether player can currently interact with something.
var can_interact: bool = false


func _ready() -> void:
	# Find existing input handler before super._ready()
	input_handler = get_node_or_null("PlayerInputHandler")
	super._ready()
	_setup_input_handler()
	_setup_enemy_slots()
	_setup_fighting_audio()
	_setup_beaten_audio()


## Sets up enemy slots from child nodes if not set via export.
func _setup_enemy_slots() -> void:
	if enemy_slots.is_empty():
		var slots_node := get_node_or_null("EnemySlots")
		if slots_node:
			for child in slots_node.get_children():
				if child is Node2D:
					enemy_slots.append(child)


## Sets up the input handler component.
func _setup_input_handler() -> void:
	if input_handler == null:
		input_handler = PlayerInputHandler.new()
		input_handler.name = "PlayerInputHandler"
		add_child(input_handler)

	input_handler.character = self


## Ensures the fighting player has punch SFX wired up.
func _setup_fighting_audio() -> void:
	# Avoid duplicates if the scene already has one.
	if get_node_or_null("FightingPlayerAudioController") != null:
		return

	var ctrl := preload("res://Core/Audio/FightingPlayerAudioController.gd").new()
	ctrl.name = "FightingPlayerAudioController"
	add_child(ctrl)


## Ensures the player plays the "Beaten" SFX on defeat.
func _setup_beaten_audio() -> void:
	if get_node_or_null("BeatenAudioController") != null:
		return

	var ctrl := preload("res://Core/Audio/BeatenAudioController.gd").new()
	ctrl.name = "BeatenAudioController"
	add_child(ctrl)


## Overrides base input handling (handled by PlayerInputHandler).
func _handle_input() -> void:
	# Input is handled by PlayerInputHandler component
	pass


## Reserves an enemy slot for the given enemy.
## Returns the slot node, or null if none available.
func reserve_slot(enemy: Node) -> Node2D:
	# Filter to find free slots
	var available_slots: Array[Node2D] = []
	for slot in enemy_slots:
		if slot.has_method("is_free") and slot.is_free():
			available_slots.append(slot)

	if available_slots.is_empty():
		return null

	# Sort by distance to enemy
	available_slots.sort_custom(
		func(a: Node2D, b: Node2D) -> bool:
			var dist_a: float = enemy.global_position.distance_to(a.global_position)
			var dist_b: float = enemy.global_position.distance_to(b.global_position)
			return dist_a < dist_b
	)

	# Occupy the closest slot
	var slot := available_slots[0]
	if slot.has_method("occupy"):
		slot.occupy(enemy)

	return slot


## Reserves an enemy slot, optionally preferring a side.
## - prefer_side: -1 = left, 0 = no preference, 1 = right
func reserve_slot_preferred(enemy: Node, prefer_side: int = 0) -> Node2D:
	# Filter to find free slots
	var available_slots: Array[Node2D] = []
	for slot in enemy_slots:
		if slot.has_method("is_free") and slot.is_free():
			available_slots.append(slot)

	if available_slots.is_empty():
		return null

	# Apply side preference (based on slot local X: left < 0, right > 0).
	var candidate_slots: Array[Node2D] = available_slots
	if prefer_side != 0:
		candidate_slots = []
		for slot in available_slots:
			if slot.position.x == 0:
				continue
			if prefer_side < 0 and slot.position.x < 0:
				candidate_slots.append(slot)
			elif prefer_side > 0 and slot.position.x > 0:
				candidate_slots.append(slot)
		if candidate_slots.is_empty():
			candidate_slots = available_slots

	# Sort by distance to enemy (still keep it reasonable).
	candidate_slots.sort_custom(
		func(a: Node2D, b: Node2D) -> bool:
			var dist_a: float = enemy.global_position.distance_to(a.global_position)
			var dist_b: float = enemy.global_position.distance_to(b.global_position)
			return dist_a < dist_b
	)

	# Occupy the closest candidate
	var slot := candidate_slots[0]
	if slot.has_method("occupy"):
		slot.occupy(enemy)
	return slot


## Frees the slot occupied by the given enemy.
func free_slot(enemy: Node) -> void:
	for slot in enemy_slots:
		if slot.has_method("get_occupant") and slot.get_occupant() == enemy:
			if slot.has_method("free_up"):
				slot.free_up()
			return


## Tries to interact with nearby objects.
func try_interact() -> bool:
	if can_interact and lever:
		lever.is_activated.emit()
		interacted.emit(lever)
		return true
	return false


## Called when player receives damage - can add player-specific reactions.
func _on_damage_received(damage_data: DamageData, direction: Vector2, source: Node) -> void:
	super._on_damage_received(damage_data, direction, source)
	# Add player-specific damage reactions here (e.g., camera shake)


## Called when fly state ends - players always recover to idle.
func _on_fly_complete() -> void:
	heading_locked = false
	state_machine.transition_to(&"Idle")


## Returns whether the player can be stunned (not in protected states).
func can_be_stunned() -> bool:
	return not state_machine.is_in_any_state([&"Jump", &"Backdash", &"Fly", &"JumpAttack", &"Stunned", &"Grounded", &"Beaten"])


## Stuns the player temporarily.
func stun() -> void:
	if can_be_stunned():
		state_machine.force_transition(&"Stunned")
		velocity = Vector2.ZERO
