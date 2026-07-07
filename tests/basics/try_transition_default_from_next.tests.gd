func test_activeStateWithNextState_transitionsToNextAndReturnsTrue():
	var machine := FSM.new()
	var start := machine.create_state("START")
	var end := machine.create_state("END")
	start.next_state = end

	machine.try_transition_to("START")
	var transitioned := machine.try_transition_default()

	return [
		TestCaseResult.from_equals(true, transitioned, "Next transition should report success"),
		TestCaseResult.from_equals(end, machine.state_node, "Machine should select next state"),
		TestCaseResult.from_equals(&"END", machine.state_name, "Machine should update state name"),
		TestCaseResult.from_equals(false, start.active, "Previous state should be inactive"),
		TestCaseResult.from_equals(true, end.active, "Next state should be active"),
	]


func test_activeStateWithoutNextState_returnsFalseAndMakesNoChange():
	var machine := FSM.new()
	var start := machine.create_state("START")
	var end := machine.create_state("END")

	machine.try_transition_to("START")
	var transitioned := machine.try_transition_default()

	return [
		TestCaseResult.from_equals(false, transitioned, "Missing next state should report no transition"),
		TestCaseResult.from_equals(start, machine.state_node, "Machine should stay on current state"),
		TestCaseResult.from_equals(&"START", machine.state_name, "Machine should keep state name"),
		TestCaseResult.from_equals(true, start.active, "Current state should remain active"),
		TestCaseResult.from_equals(false, end.active, "Other state should remain inactive"),
	]
