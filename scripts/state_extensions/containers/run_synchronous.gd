## Runs all child states in order
extends FSMState


var _states: Array[FSMState] = []
var _current_state_index: int = -1


func _init() -> void:
	_deactivate_all()

	activated.connect(_start)
	deactivated.connect(_deactivate_all)


func _enter_tree() -> void:
	_reload_states()


func _update_all() -> void:
	if active:
		_start()
	else:
		_deactivate_all()


func _start() -> void:
	_current_state_index = 0
	_deactivate_all()
	_prompt_start_next_state()


func _on_child_finished() -> void:
	_current_state_index += 1
	_prompt_start_next_state()


func _prompt_start_next_state() -> void:
	if not active:
		return
		
	if _current_state_index >= _states.size():
		state_finished.emit()
	
	else:
		var state := _states[_current_state_index]
		state.state_finished.connect(_on_child_finished, CONNECT_ONE_SHOT)
		# TODO disconenct this when deactivated before it fires
		_activate_state(state)


func _activate_state(state: FSMState) -> void:
	state._active = false
	state._active = true


func _deactivate_all() -> void:
	for state in _states:
		state._active = false


func _reload_states() -> void:
	_states = _get_states()


func _get_states() -> Array[FSMState]:
	var states: Array[FSMState] = []
	for child in get_children():
		if child is FSMState:
			states.append(child)
	return states
