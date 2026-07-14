class InstantFinishState extends FSMState:
	func _init(verbose: bool = false) -> void:
		_verbose = verbose
		activated.connect(func():
			state_finished.emit()
		)


func test_zero_repetitions_cause_no_substate_activation():
	var activation_pattern: Array[bool] = []

	var substate := InstantFinishState.new()
	substate.activated.connect(activation_pattern.append.bind(true))

	var repeat := FSM.Repeat.new()
	repeat.state_finished.connect(func(): repeat._active = false)
	repeat.to_repeat = substate
	repeat.repetitions = 0

	repeat._active = true

	return TestCaseResult.from_equivalent(0, activation_pattern.size())


func test_single_repetition_causes_single_substate_activation():
	var activation_pattern: Array[bool] = []

	var substate := InstantFinishState.new(false)
	substate.activated.connect(activation_pattern.append.bind(true))
	var repeat := FSM.Repeat.new()

	repeat.to_repeat = substate
	repeat.repetitions = 1
	repeat._active = true

	return TestCaseResult.from_equivalent(1, activation_pattern.size())


func test_3_repetitions_causes_3_substate_activations():
	var activation_pattern: Array[bool] = []

	var substate := InstantFinishState.new(false)
	substate.activated.connect(activation_pattern.append.bind(true))
	var repeat := FSM.Repeat.new()

	repeat.to_repeat = substate
	repeat.repetitions = 3
	repeat._active = true

	return TestCaseResult.from_equivalent(3, activation_pattern.size())
