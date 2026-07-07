class_name FSM
extends FSMState

signal pre_state_change_values(current: StringName, next: StringName)
signal pre_state_change
signal state_change_values(previous: StringName, current: StringName)
signal state_change

@export var _is_root: bool = true
@export var _assert_all_children_are_states: bool = true


var states: Array[StringName]:
	get:
		return _states.keys()

var _states: Dictionary[StringName, FSMState] = {}


var state_name: StringName:
	get:
		return _state_name

var state_node: FSMState:
	get:
		return _states.get(_state_name, null)

var _state_name: StringName:
	set(value):
		_state_name = value.to_upper()


#region Initialization


func _init() -> void:
	deactivated.connect(func():
		if state_node != null:
			state_node._active = false
	)


func _enter_tree() -> void:
	_load_state_nodes()

	if _is_root:
		# TODO assert that there is actually no parent FSM 
		_active = true

	if _states.size() == 0:
		push_error("State machine %s does not have any states!" % [get_path()])
		return


func _load_state_nodes() -> void:
	for node in get_children():
		if node is not FSMState:
			assert(not _assert_all_children_are_states, "FSM %s has child %s that is not FSM states!" % [ self , node])
		else:
			_states[node.name.to_upper()] = node

	if _verbose:
		var state_names_bullet_points = _states.keys().map(func(state_name): return "\n - %s" % state_name)
		print("%s loaded states:" % self +"".join(state_names_bullet_points))


func create_state(state_name: StringName) -> FSMState:
	state_name = state_name.to_upper()

	if has_state(state_name):
		push_error("%s already has state_name \"%s\"" % [ self , state_name])
		return null

	var node := FSMState.new()
	node.name = state_name
	add_state(node)
	return node


func add_state(state_node: FSMState) -> void:
	var key := state_node.name.to_upper()

	if has_state(key):
		push_error("%s already has state_name \"%s\"" % [ self , key])
		return

	add_child(state_node)
	_states[key] = state_node


#endregion
#region ???


## Returns whether the current state_name matches target_state.
## Pushes an error and returns false when target_state is not declared.
func is_state(target_state: StringName) -> bool:
	target_state = target_state.to_upper()

	if not has_state(target_state):
		_push_missing_state_error(target_state)
		return false
	return state_name == target_state


func has_state(target_state: StringName) -> bool:
	target_state = target_state.to_upper()
	return _states.has(target_state)


## Gets the state of self and all active child states
func get_full_state() -> Array[FSMState]:
	if state_node == null:
		return [] as Array[FSMState]

	var full_state: Array[FSMState] = [state_node]

	while true:
		var deepest := full_state[full_state.size() - 1]

		if not deepest is FSM:
			break
		
		var deepest_state: FSMState = deepest.state_node
		if deepest_state == null:
			break

		full_state.append(deepest_state)

	return full_state


#region Transitions


## Changes to target_state if it is declared.
## Invalid states push an error and leave the current state_name unchanged.
func force_transition_to(target_state: StringName) -> void:
	target_state = target_state.to_upper()

	if not has_state(target_state):
		_push_missing_state_error(target_state)
		return

	if _verbose:
		print("State change request (force) %s->%s." % [state_name, target_state])

	_set_state(target_state)


## Attempts to change to target_state and returns whether the change succeeded.
## Invalid states push an error, leave the current state_name unchanged, and return false.
func try_transition_to(target_state: StringName) -> bool:
	target_state = target_state.to_upper()

	if not has_state(target_state):
		_push_missing_state_error(target_state)
		return false
	
	if _verbose:
		print("State changing %s->%s" % [state_name, target_state])

	_set_state(target_state)
	return true


func _set_state(target_state: StringName) -> void:
	var previous_state := state_name

	pre_state_change_values.emit(state_name, target_state)
	pre_state_change.emit()

	_state_name = target_state

	if _states.has(previous_state):
		_states[previous_state]._active = false

	_states[_state_name]._active = true

	state_change_values.emit(previous_state, state_name)
	state_change.emit()


func _push_missing_state_error(target_state: StringName) -> void:
	var message := "\n".join([
		"State \"%s\" does not exist on %s!" % [target_state, get_path()],
		"\tvalid states: %s" % [_states]
	])
	push_error(message)


#endregion
