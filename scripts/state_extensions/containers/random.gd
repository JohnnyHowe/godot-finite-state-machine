extends FSMState

const DEFAULT_WEIGHT: float = 1


@export var options: Array[FSMState] = []
## If a weight does not exist for an option, DEFAULT_WEIGHT is used
@export var weights: Array[float] = []

var rng := RandomNumberGenerator.new()


func _enter_tree() -> void:
	activated.connect(_start)


func _start() -> void:
	var state := _choose_state()
	state.state_finished.connect(_child_state_finished.bind(state), CONNECT_ONE_SHOT)
	state._active = true


func _child_state_finished(state: FSMState) -> void:
	state._active = false
	state_finished.emit()


func _choose_state() -> FSMState:
	var indices := Array(range(options.size()))
	var index: int = BetterRandom.choice_weighted(indices, _get_weight, rng)
	return options[index]


func _get_weight(index: int) -> float:
	if index >= weights.size():
		return DEFAULT_WEIGHT
	return weights[index]
