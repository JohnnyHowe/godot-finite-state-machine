class_name FiniteStateMachine
extends FSMState

signal pre_state_change_values(current: StringName, next: StringName)
signal pre_state_change
signal state_change_values(previous: StringName, current: StringName)
signal state_change

@export var _verbose: bool = false
@export var _is_root: bool = true
@export var _assert_all_children_are_states: bool = true

var _states: Dictionary[StringName, FSMState] = {}


var state: StringName:
	get:
		return _state
@export var _state: StringName:
	set(value):
		_state = value.to_lower()


func _enter_tree() -> void:
	_load_state_nodes()

	if _is_root:
		# TODO assert that there is actually no parent FSM 
		_active = true

	if _states.size() == 0:
		push_error("State machine %s does not have any states!" % [get_path()])
		return
	if not has_state(_state):
		force_transition_to(_states.keys()[0])


func has_state(target_state: StringName) -> bool:
	target_state = target_state.to_upper()
	return _states.has(target_state)


func _load_state_nodes() -> void:
	_states = {}
	for node in get_children():
		if node is not FSMState:
			assert(not _assert_all_children_are_states, "FSM %s has child %s that is not FSM states!" % [self, node])
		else:
			_states[node.name.to_upper()] = node

	if _verbose:
		var state_names_bullet_points = _states.keys().map(func(state_name): return "\n - %s" % state_name)
		print("%s loaded states:" % self + "".join(state_names_bullet_points))


## Returns whether the current state matches target_state.
## Pushes an error and returns false when target_state is not declared.
func is_state(target_state: StringName) -> bool:
	if not has_state(target_state):
		_push_missing_state_error(target_state)
		return false
	return state == target_state.to_lower()


## Changes to target_state if it is declared.
## Invalid states push an error and leave the current state unchanged.
func force_transition_to(target_state: StringName) -> void:
	if not has_state(target_state):
		_push_missing_state_error(target_state)
		return

	if _verbose:
		print("State change request (force) %s->%s." % [state, target_state])

	_set_state(target_state)


## Attempts to change to target_state and returns whether the change succeeded.
## Invalid states push an error, leave the current state unchanged, and return false.
func try_transition_to(target_state: StringName) -> bool:
	if not has_state(target_state):
		_push_missing_state_error(target_state)
		return false
	
	if _verbose:
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
		"\tvalid states: %s" % [_states]
	])
	push_error(message)
