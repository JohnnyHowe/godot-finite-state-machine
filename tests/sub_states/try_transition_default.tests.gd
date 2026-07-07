func test_nestedMachineWithNoActiveChild_usesOwnDefaultState():
	var root := FSM.new()

	var in_play := FSM.new()
	in_play.name = "IN_PLAY"
	root.add_state(in_play)

	var moving := in_play.create_state("MOVING")
	var attacking := in_play.create_state("ATTACKING")
	in_play.default_state = moving

	var transitioned := in_play.try_transition_default()

	return [
		TestCaseResult.from_equals(true, transitioned, "Nested machine default transition should report success"),
		TestCaseResult.from_equals(moving, in_play.state_node, "Nested machine should select its default state"),
		TestCaseResult.from_equals(&"MOVING", in_play.state_name, "Nested machine should update state name"),
		TestCaseResult.from_equals(true, moving.active, "Default child state should be active"),
		TestCaseResult.from_equals(false, attacking.active, "Other child state should remain inactive"),
	]


func test_nestedMachineWithActiveChild_usesChildNextState():
	var root := FSM.new()

	var in_play := FSM.new()
	in_play.name = "IN_PLAY"
	root.add_state(in_play)

	var moving := in_play.create_state("MOVING")
	var attacking := in_play.create_state("ATTACKING")
	moving.next_state = attacking

	root.force_transition_to("IN_PLAY")
	in_play.force_transition_to("MOVING")
	var transitioned := in_play.try_transition_default()

	return [
		TestCaseResult.from_equals(true, transitioned, "Nested next transition should report success"),
		TestCaseResult.from_equals(true, in_play.active, "Nested machine should remain active"),
		TestCaseResult.from_equals(attacking, in_play.state_node, "Nested machine should select child next state"),
		TestCaseResult.from_equals(false, moving.active, "Previous child state should be inactive"),
		TestCaseResult.from_equals(true, attacking.active, "Next child state should be active"),
	]


func test_rootTryTransitionDefault_doesNotAdvanceNestedChildMachine():
	var root := FSM.new()

	var in_play := FSM.new()
	in_play.name = "IN_PLAY"
	root.add_state(in_play)

	var moving := in_play.create_state("MOVING")
	var attacking := in_play.create_state("ATTACKING")
	moving.next_state = attacking

	root.force_transition_to("IN_PLAY")
	in_play.force_transition_to("MOVING")
	var transitioned := root.try_transition_default()

	return [
		TestCaseResult.from_equals(false, transitioned, "Root transition should report no transition without root next/default target"),
		TestCaseResult.from_equals(in_play, root.state_node, "Root should remain on nested machine state"),
		TestCaseResult.from_equals(moving, in_play.state_node, "Nested machine should keep current child state"),
		TestCaseResult.from_equals(true, moving.active, "Nested current child should remain active"),
		TestCaseResult.from_equals(false, attacking.active, "Nested next child should not be advanced by root"),
	]
