func test_nestedChildStateFinished_advancesOnlyNestedMachine():
	var root := FSM.new()

	var in_play := FSM.new()
	in_play.name = "IN_PLAY"
	root.add_state(in_play)

	var moving := in_play.create_state("MOVING")
	var attacking := in_play.create_state("ATTACKING")
	moving.next_state = attacking

	root.try_transition_to("IN_PLAY")
	in_play.try_transition_to("MOVING")
	moving.state_finished.emit()

	return [
		TestCaseResult.from_equals(in_play, root.state_node, "Root should remain on nested machine"),
		TestCaseResult.from_equals(&"IN_PLAY", root.state_name, "Root should keep state name"),
		TestCaseResult.from_equals(attacking, in_play.state_node, "Nested machine should transition to child next state"),
		TestCaseResult.from_equals(false, moving.active, "Finished child state should be inactive"),
		TestCaseResult.from_equals(true, attacking.active, "Next child state should be active"),
	]


func test_nestedMachineStateFinished_advancesRootMachine():
	var root := FSM.new()

	var in_play := FSM.new()
	in_play.name = "IN_PLAY"
	root.add_state(in_play)

	var destroyed := root.create_state("DESTROYED")
	in_play.next_state = destroyed

	root.try_transition_to("IN_PLAY")
	in_play.state_finished.emit()

	return [
		TestCaseResult.from_equals(destroyed, root.state_node, "Root should transition to nested machine next state"),
		TestCaseResult.from_equals(&"DESTROYED", root.state_name, "Root should update state name"),
		TestCaseResult.from_equals(false, in_play.active, "Finished nested machine should be inactive"),
		TestCaseResult.from_equals(true, destroyed.active, "Root next state should be active"),
	]
