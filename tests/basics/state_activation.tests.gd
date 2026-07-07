func test_createdState_isInactiveByDefault():
	var machine := FSM.new()
	var state := machine.create_state("START")

	return TestCaseResult.from_equals(false, state.active, "Newly created state should be inactive")


func test_forceTransitionToState_marksStateActive():
	var machine := FSM.new()
	var start := machine.create_state("START")

	machine.force_transition_to("START")

	return TestCaseResult.from_equals(true, start.active, "Transitioned state should be active")


func test_transitionToAnotherState_deactivatesPreviousAndActivatesNext():
	var machine := FSM.new()
	var start := machine.create_state("START")
	var end := machine.create_state("END")

	machine.force_transition_to("START")
	machine.force_transition_to("END")

	return [
		TestCaseResult.from_equals(false, start.active, "Previous state should be inactive"),
		TestCaseResult.from_equals(true, end.active, "Current state should be active"),
	]


func test_invalidTransition_doesNotChangeActiveFlags():
	var machine := FSM.new()
	var start := machine.create_state("START")
	var end := machine.create_state("END")

	machine.force_transition_to("START")
	machine.force_transition_to("MISSING")

	return [
		TestCaseResult.from_equals(true, start.active, "Current state should remain active"),
		TestCaseResult.from_equals(false, end.active, "Inactive state should remain inactive"),
	]
