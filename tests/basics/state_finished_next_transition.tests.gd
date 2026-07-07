func test_stateFinishedOnActiveState_transitionsToNextState():
	var machine := FSM.new()
	var start := machine.create_state("START")
	var end := machine.create_state("END")
	start.next_state = end

	machine.try_transition_to("START")
	start.state_finished.emit()

	return [
		TestCaseResult.from_equals(end, machine.state_node, "Machine should transition to next state"),
		TestCaseResult.from_equals(&"END", machine.state_name, "Machine should update state name"),
		TestCaseResult.from_equals(false, start.active, "Finished state should be inactive"),
		TestCaseResult.from_equals(true, end.active, "Next state should be active"),
	]


func test_stateFinishedOnActiveStateWithoutNextState_keepsCurrentState():
	var machine := FSM.new()
	var start := machine.create_state("START")

	machine.try_transition_to("START")
	start.state_finished.emit()

	return [
		TestCaseResult.from_equals(start, machine.state_node, "Machine should stay on current state"),
		TestCaseResult.from_equals(&"START", machine.state_name, "Machine should keep state name"),
		TestCaseResult.from_equals(true, start.active, "Current state should remain active"),
	]
