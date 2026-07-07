func test_stateActivated_onTransition():
	var root := FSM.new()
	var state := root.create_state("TEST")

	var activated_calls = []
	state.activated.connect(
		func():
			activated_calls.append(true)
	)

	root.try_transition_to(state.name)

	return TestCaseResult.from_equals(1, activated_calls.size())


func test_stateDeactivated_onTransition():
	var root := FSM.new()
	var start_state := root.create_state("START")
	var end_state := root.create_state("TEST")

	var deactivated = []
	start_state.deactivated.connect(
		func():
			deactivated.append(true)
	)

	root.try_transition_to(start_state.name)
	root.try_transition_to(end_state.name)

	return TestCaseResult.from_equals(1, deactivated.size())

