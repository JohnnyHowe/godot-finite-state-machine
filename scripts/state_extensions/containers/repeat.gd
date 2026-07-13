extends "./run_synchronous.gd"

@export var repetitions: int = 2
@export var to_repeat: FSMState


func _get_states() -> Array[FSMState]:
	var states : Array[FSMState] = []
	states.resize(repetitions)
	states.fill(to_repeat)
	return states
