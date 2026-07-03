func test_createFirstStateNode_addsToMachine():
	var machine := FSM.new()

	var state_name := "TEST_STATE"
	var state := machine.create_state(state_name)

	return [
		TestCaseResult.new(state != null, "New state is null!"),
		TestCaseResult.new(machine.states.has(state_name), "Machine does not have new state!"),
		TestCaseResult.new(machine.has_state(state_name), "Machine states does not have new state!"),
		TestCaseResult.from_equals(machine, state.get_parent(), "New state parent is not expected!")
	]


func test_createDuplicateState_isIgnored():
	var machine := FSM.new()

	var state_node_1 := machine.create_state("TEST_STATE")
	var state_node_2 := machine.create_state("TEST_STATE")

	
	return [
		TestCaseResult.new(state_node_1 != null, "Expected state to not be null!"),
		TestCaseResult.from_equivalent(null, state_node_2, "Expected duplicate to be null!"),
	]
