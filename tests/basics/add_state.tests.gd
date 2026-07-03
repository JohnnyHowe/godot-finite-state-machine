
func test_addFirstStateNode_addsToMachine():
	var machine := FSM.new()

	var state_name := "START"
	var state := FSMState.new()
	state.name = state_name

	machine.add_state(state)

	return [
		machine.states.has(state_name),
		machine.has_state(state_name),
		TestCaseResult.from_equals(machine, state.get_parent())
	]


func test_addDuplicateState_isIgnored():
	var machine := FSM.new()

	var state := FSMState.new()
	state.name = "START"
	machine.add_state(state)

	var duplicate := FSMState.new()
	duplicate.name = "START"

	machine.add_state(duplicate)
	
	return [
		TestCaseResult.from_equivalent(true, machine.has_state("START"), "Machine doesn't have the state at all!"),
		TestCaseResult.from_equivalent(machine, state.get_parent(), "Unexpected parent of state"),
		TestCaseResult.from_equivalent(null, duplicate.get_parent(), "Unexpected parent of duplicate"),
	]
