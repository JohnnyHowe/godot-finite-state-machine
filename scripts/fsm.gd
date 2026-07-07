class_name FSM
extends FSMState

signal pre_state_change_values(current: StringName, next: StringName)
signal pre_state_change
signal state_change_values(previous: StringName, current: StringName)
signal state_change

@export var is_root: bool = true
@export var assert_all_children_are_states: bool = true
@export var default_state: FSMState


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
	activated.connect(func():
		if default_state:
			try_transition_to(default_state.name)
	)

	deactivated.connect(func():
		if state_node != null:
			state_node._active = false
	)


func _enter_tree() -> void:
	_load_state_nodes()

	if is_root:
		# TODO assert that there is actually no parent FSM 
		_active = true

	if _states.size() == 0:
		push_error("State machine %s does not have any states!" % [get_path()])
		return


func _load_state_nodes() -> void:
	for node in get_children():
		if node is not FSMState:
			assert(not assert_all_children_are_states, "FSM %s has child %s that is not FSM states!" % [ self , node])
		else:
			add_state(node)

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


func add_state(new_state_node: FSMState) -> void:
	var key := new_state_node.name.to_upper()

	if has_state(key):
		push_error("%s already has state_name \"%s\"" % [ self , key])
		return

	if not _try_add_as_child_node(new_state_node):
		return

	new_state_node.state_finished.connect(
		func():
			if new_state_node == new_state_node:
				try_transition_default()
			else:
				push_warning("%s state %s emitted finished but it is not active!" % [ self , new_state_node])
	)

	_states[key] = new_state_node


## Returns whether the node was added.
## Fails only if there is already a different parent.
func _try_add_as_child_node(new_state_node: FSMState) -> bool:
	var current_parent := new_state_node.get_parent()

	if current_parent == self:
		return true

	if current_parent == null:
		add_child(new_state_node)
		return true

	push_error("%s could not add child %s as it already has a different parent (%s)!" % [self, new_state_node, current_parent])
	return false


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


## Go to the next state defined by the current.
## If no current state active, goes to the default for the FSM if it exists, otherwise no change.
## Returns whether a transition was actually made.
func try_transition_default() -> bool:
	if state_node != null and state_node.next_state != null:
		return try_transition_to(state_node.next_state.name)

	if default_state != null:
		return try_transition_to(default_state.name)

	return false


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
