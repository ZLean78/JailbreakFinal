## State machine controller that manages character states and transitions.
## Replaces the monolithic state enum approach with proper state pattern.
##
## The state machine:
## - Maintains a dictionary of registered states
## - Handles state transitions with validation
## - Delegates update/physics calls to the current state
## - Provides debugging info (state history, transition logging)
##
## Usage:
##     class_name CharacterStateMachine
##     extends StateMachine
##
##     func _init() -> void:
##         register_state(&"Idle", IdleState.new())
##         register_state(&"Walk", WalkState.new())
##
##     # In character:
##     func _ready() -> void:
##         state_machine.initialize(self)
##         state_machine.start(&"Idle")
class_name StateMachine
extends Node


## Emitted when a state transition occurs.
## Useful for debugging, UI updates, sound effects.
signal state_changed(from_state: StringName, to_state: StringName)

## Emitted when a transition is rejected.
signal transition_rejected(from_state: StringName, to_state: StringName, reason: String)


## The character this state machine controls.
var character: CharacterBody2D

## Currently active state.
var current_state: State

## Dictionary mapping state names to state instances.
var _states: Dictionary = {}

## History of recent states for debugging.
var _state_history: Array[StringName] = []

## Maximum history size to keep.
const MAX_HISTORY_SIZE: int = 10

## Whether to print debug info on state changes.
@export var debug_mode: bool = false


## Initializes the state machine with a character reference.
## Must be called before starting or updating.
func initialize(p_character: CharacterBody2D) -> void:
	character = p_character

	# Initialize all registered states
	for state_name in _states:
		var state: State = _states[state_name]
		state.initialize(character, self)
		state.transition_requested.connect(_on_state_transition_requested)


## Registers a state with the given name.
## States must be registered before initialization.
func register_state(state_name: StringName, state: State) -> void:
	if state_name in _states:
		push_warning("StateMachine: State '%s' already registered, overwriting" % state_name)
	_states[state_name] = state


## Starts the state machine with the specified initial state.
## Call after initialize().
func start(initial_state: StringName) -> void:
	if initial_state not in _states:
		push_error("StateMachine: Initial state '%s' not registered" % initial_state)
		return

	current_state = _states[initial_state]
	_add_to_history(initial_state)
	current_state.enter()

	if debug_mode:
		print("StateMachine: Started in state '%s'" % initial_state)


## Attempts to transition to a new state.
## Returns true if transition succeeded, false if rejected.
func transition_to(target_state: StringName, force: bool = false) -> bool:
	if target_state not in _states:
		push_error("StateMachine: Target state '%s' not registered" % target_state)
		return false

	var from_state_name := get_current_state_name()

	# Skip if already in target state (unless forcing)
	if not force and current_state and from_state_name == target_state:
		return false

	# Check if transition is allowed
	if not force and current_state:
		if not current_state.can_transition_to(target_state):
			var reason := "Transition not allowed by current state"
			transition_rejected.emit(from_state_name, target_state, reason)
			if debug_mode:
				print("StateMachine: Rejected %s -> %s (%s)" % [from_state_name, target_state, reason])
			return false

	# Perform the transition
	if current_state:
		current_state.exit()

	current_state = _states[target_state]
	_add_to_history(target_state)
	current_state.enter()

	state_changed.emit(from_state_name, target_state)

	if debug_mode:
		print("StateMachine: %s -> %s" % [from_state_name, target_state])

	return true


## Forces a transition to the target state, bypassing transition rules.
## Use sparingly - for things like damage interrupts that must always work.
func force_transition(target_state: StringName) -> bool:
	return transition_to(target_state, true)


## Called every frame. Delegates to current state.
func update(delta: float) -> void:
	if current_state:
		current_state.update(delta)


## Called every physics frame. Delegates to current state.
func physics_update(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)


## Handles input events. Delegates to current state.
func handle_input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)


## Returns the name of the current state.
func get_current_state_name() -> StringName:
	if current_state:
		return current_state.get_state_name()
	return &""


## Returns the animation name for the current state.
func get_current_animation() -> String:
	if current_state:
		return current_state.get_animation_name()
	return "idle"



## Returns whether the current state matches the given name.
func is_in_state(state_name: StringName) -> bool:
	return get_current_state_name() == state_name


## Returns whether the current state is any of the given names.
func is_in_any_state(state_names: Array[StringName]) -> bool:
	return get_current_state_name() in state_names


## Returns whether a specific state is registered.
func has_state(state_name: StringName) -> bool:
	return state_name in _states


## Returns the state history for debugging.
func get_state_history() -> Array[StringName]:
	return _state_history.duplicate()


## Returns a reference to a registered state by name.
## Useful for accessing state-specific properties.
func get_state(state_name: StringName) -> State:
	if state_name in _states:
		return _states[state_name]
	return null


## Callback for state transition requests.
func _on_state_transition_requested(target_state: StringName) -> void:
	transition_to(target_state)


## Adds a state to the history, maintaining max size.
func _add_to_history(state_name: StringName) -> void:
	_state_history.append(state_name)
	if _state_history.size() > MAX_HISTORY_SIZE:
		_state_history.pop_front()
