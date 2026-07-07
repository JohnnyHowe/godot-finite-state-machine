func test_stateFinishedOnOwnedInactiveState_transitionsMachineToDefaultState():
	var machine := FSM.new()
	var start := machine.create_state("START")
	machine.default_state = start

	start.state_finished.emit()

	return [
		TestCaseResult.from_equals(start, machine.state_node, "Machine should transition to default state"),
		TestCaseResult.from_equals(&"START", machine.state_name, "Machine should update state name"),
		TestCaseResult.from_equals(true, start.active, "Default state should be active"),
	]


func test_stateFinishedOnOwnedInactiveStateWithoutDefault_keepsMachineInactive():
	var machine := FSM.new()
	var start := machine.create_state("START")

	start.state_finished.emit()

	return [
		TestCaseResult.from_equals(null, machine.state_node, "Machine should not select a state"),
		TestCaseResult.from_equals(false, start.active, "State should remain inactive"),
	]
