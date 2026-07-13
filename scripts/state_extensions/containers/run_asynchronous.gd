## Activates direct children based on own state.
## So when this is active, all children are set to active, and same for when this is deactivated.
extends FSMState


var _waiting_for: int = 0


func _init() -> void:
	activated.connect(_activate_all)
	deactivated.connect(_deactivate_all)
	_update_all()


func _update_all() -> void:
	if active:
		_activate_all()
	else:
		_deactivate_all()


func _activate_all() -> void:
	for state in _get_states():
		_waiting_for += 1
		state.state_finished.connect(_on_child_finished, CONNECT_ONE_SHOT)
		state._active = true


func _on_child_finished() -> void:
	_waiting_for -= 1
	if _waiting_for == 0:
		state_finished.emit()


func _deactivate_all() -> void:
	for state in _get_states():
		state._active = false


func _get_states() -> Array[FSMState]:
	var states: Array[FSMState] = []
	for child in get_children():
		if child is FSMState:
			states.append(child)
	return states
