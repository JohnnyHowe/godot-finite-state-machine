
func test_addSingleStateNode():
	var root := FSM.new()

	var state_name := "START"
	var state := FSM.new()
	state.name = state_name

	root.add_state(state)

	return [
		root.states.has(state_name),
		root.has_state(state_name),
		TestCaseResult.from_equals(root, state.get_parent())
	]


func test_addMultipleSubStateMachines():
	var root := FSM.new()

	var start_state := FSM.new()
	start_state.name = "START"
	root.add_state(start_state)

	var mid_state := FSM.new()
	mid_state.name = "MID"
	root.add_state(mid_state)

	var end_state := FSM.new()
	end_state.name = "END"
	root.add_state(end_state)

	return [
		root.has_state(start_state.name),
		root.has_state(mid_state.name),
		root.has_state(end_state.name),
	]
