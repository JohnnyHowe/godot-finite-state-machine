## Tracks a current state from a FiniteStateMachineDefinition and emits signals around state changes.
## State names are matched case-insensitively and stored as lowercase StringName values.
class_name FiniteStateMachine
extends FSMState

signal pre_state_change_values(current: StringName, next: StringName)
signal pre_state_change
signal state_change_values(previous: StringName, current: StringName)
signal state_change

@export var verbose: bool = false
@export var definition: FiniteStateMachineDefinition


var state: StringName:
	get:
		return _state
@export var _state: StringName:
	set(value):
		_state = value.to_lower()


func _enter_tree() -> void:
	if definition.states.size() == 0:
		push_error("State machine %s does not have any states!" % [get_path()])
		return
	if not definition.has_state(_state):
		force_transition_to(definition.states[0])


## Returns whether the current state matches target_state.
## Pushes an error and returns false when target_state is not declared in definition.
func is_state(target_state: StringName) -> bool:
	if not definition.has_state(target_state):
		_push_missing_state_error(target_state)
		return false
	return state == target_state.to_lower()


## Changes to target_state if it is declared in definition.
## Invalid states push an error and leave the current state unchanged.
func force_transition_to(target_state: StringName) -> void:
	if not definition.has_state(target_state):
		_push_missing_state_error(target_state)
		return

	if verbose:
		print("State change request (force) %s->%s." % [state, target_state])

	_set_state(target_state)


## Attempts to change to target_state and returns whether the change succeeded.
## Invalid states push an error, leave the current state unchanged, and return false.
func try_transition_to(target_state: StringName) -> bool:
	if not definition.has_state(target_state):
		_push_missing_state_error(target_state)
		return false
	
	if verbose:
		print("State changing %s->%s" % [state, target_state])

	_set_state(target_state)
	return true


func _set_state(target_state: StringName) -> void:
	var previous_state := state
	pre_state_change_values.emit(state, target_state)
	pre_state_change.emit()
	_state = target_state
	state_change_values.emit(previous_state, state)
	state_change.emit()


func _push_missing_state_error(target_state: StringName) -> void:
	var message := "\n".join([
		"State \"%s\" does not exist on %s!" % [target_state, get_path()],
		"\tvalid states: %s" % [definition.states]
	])
	push_error(message)
