## Base class for all character states in the state machine pattern.
## Each state encapsulates behavior for a specific character state (idle, walk, attack, etc.)
##
## States handle their own:
## - Entry/exit logic
## - Per-frame updates
## - Physics updates
## - Input processing (for player states)
## - Transition rules
##
## Usage:
##     class_name IdleState
##     extends State
##
##     func get_state_name() -> StringName:
##         return &"Idle"
##
##     func physics_update(delta: float) -> void:
##         if character.velocity.length() > 0:
##             request_transition(&"Walk")
class_name State
extends RefCounted


## Emitted when this state requests a transition to another state.
## The state machine listens to this to perform the transition.
signal transition_requested(target_state: StringName)


## Reference to the state machine managing this state.
var state_machine: StateMachine

## Reference to the character this state controls.
## Set by the state machine when initializing states.
var character: CharacterBody2D


## Initializes the state with references.
## Called by StateMachine when registering the state.
func initialize(p_character: CharacterBody2D, p_state_machine: StateMachine) -> void:
	character = p_character
	state_machine = p_state_machine


## Returns the unique name of this state.
## Must be overridden by subclasses.
func get_state_name() -> StringName:
	assert(false, "get_state_name() must be overridden")
	return &"State"


## Returns the animation name to play in this state.
## Override to return the appropriate animation for each state.
func get_animation_name() -> String:
	return "idle"


## Called when entering this state.
## Override to perform setup like resetting velocities, playing sounds, etc.
func enter() -> void:
	pass


## Called when exiting this state.
## Override to perform cleanup.
func exit() -> void:
	pass


## Called every frame while in this state.
## Use for non-physics logic like animation updates, timers, etc.
func update(_delta: float) -> void:
	pass


## Called every physics frame while in this state.
## Use for physics-related logic like movement, velocity changes.
func physics_update(_delta: float) -> void:
	pass


## Called to handle input events while in this state.
## Only relevant for player-controlled characters.
func handle_input(_event: InputEvent) -> void:
	pass


## Returns whether a transition from this state to target_state is allowed.
## Override to define valid transitions for each state.
func can_transition_to(_target_state: StringName) -> bool:
	return true


## Helper method to request a state transition.
## The state machine will validate and perform the transition.
func request_transition(target_state: StringName) -> void:
	transition_requested.emit(target_state)


## Helper method to get the current state name from the state machine.
func get_current_state_name() -> StringName:
	if state_machine:
		return state_machine.get_current_state_name()
	return &""
