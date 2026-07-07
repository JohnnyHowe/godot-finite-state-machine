func test_activeStateWithInvalidNextState_returnsFalseAndKeepsCurrentStateActive():
	var machine := FSM.new()
	var start := machine.create_state("START")
	var end := machine.create_state("END")
	var missing := FSMState.new()
	missing.name = "MISSING"
	start.next_state = missing

	machine.force_transition_to("START")
	var transitioned := machine.try_transition_default()

	return [
		TestCaseResult.from_equals(false, transitioned, "Invalid next state should report no transition"),
		TestCaseResult.from_equals(start, machine.state_node, "Machine should stay on current state"),
		TestCaseResult.from_equals(&"START", machine.state_name, "Machine should keep state name"),
		TestCaseResult.from_equals(true, start.active, "Current state should remain active"),
		TestCaseResult.from_equals(false, end.active, "Other state should remain inactive"),
	]


func test_invalidDefaultDoesNotDeactivateExistingActiveState():
	var machine := FSM.new()
	var start := machine.create_state("START")
	var end := machine.create_state("END")
	var missing := FSMState.new()
	missing.name = "MISSING"
	machine.default_state = missing

	machine.force_transition_to("START")
	var transitioned := machine.try_transition_default()

	return [
		TestCaseResult.from_equals(false, transitioned, "Invalid default should report no transition when active state has no next"),
		TestCaseResult.from_equals(start, machine.state_node, "Machine should stay on current state"),
		TestCaseResult.from_equals(&"START", machine.state_name, "Machine should keep state name"),
		TestCaseResult.from_equals(true, start.active, "Current state should remain active"),
		TestCaseResult.from_equals(false, end.active, "Other state should remain inactive"),
	]
