extends FSMState 


@export var repetitions: int = 2
@export var to_repeat: FSMState

var _current_state_index: int = -1


func _init() -> void:
	activated.connect(_start)


func _start() -> void:
	_current_state_index = 0
	_prompt_start_next_state()


func _on_child_finished() -> void:
	_current_state_index += 1
	_prompt_start_next_state()


func _prompt_start_next_state() -> void:
	if not active:
		return
		
	if _current_state_index >= repetitions:
		state_finished.emit()
	
	else:
		to_repeat.state_finished.connect(_on_child_finished, CONNECT_ONE_SHOT)
		# TODO disconenct this when deactivated before it fires
		_activate_state(to_repeat)

	
func _activate_state(state: FSMState) -> void:
	state._active = false
	state._active = true
