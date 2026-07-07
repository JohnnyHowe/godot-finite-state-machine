func test_noActiveStateWithDefault_transitionsToDefaultAndReturnsTrue():
	var machine := FSM.new()
	var start := machine.create_state("START")
	var end := machine.create_state("END")
	machine.default_state = start

	var transitioned := machine.try_transition_default()

	return [
		TestCaseResult.from_equals(true, transitioned, "Default transition should report success"),
		TestCaseResult.from_equals(start, machine.state_node, "Machine should select default state"),
		TestCaseResult.from_equals(&"START", machine.state_name, "Machine should update state name"),
		TestCaseResult.from_equals(true, start.active, "Default state should be active"),
		TestCaseResult.from_equals(false, end.active, "Other state should remain inactive"),
	]


func test_noActiveStateWithoutDefault_returnsFalseAndMakesNoChange():
	var machine := FSM.new()
	var start := machine.create_state("START")

	var transitioned := machine.try_transition_default()

	return [
		TestCaseResult.from_equals(false, transitioned, "Missing default should report no transition"),
		TestCaseResult.from_equals(null, machine.state_node, "Machine should not select a state"),
		TestCaseResult.from_equals(false, start.active, "State should remain inactive"),
	]


func test_noActiveStateWithInvalidDefault_returnsFalseAndMakesNoChange():
	var machine := FSM.new()
	var start := machine.create_state("START")
	var missing := FSMState.new()
	missing.name = "MISSING"
	machine.default_state = missing

	var transitioned := machine.try_transition_default()

	return [
		TestCaseResult.from_equals(false, transitioned, "Invalid default should report no transition"),
		TestCaseResult.from_equals(null, machine.state_node, "Machine should not select a state"),
		TestCaseResult.from_equals(false, start.active, "State should remain inactive"),
	]
