func test_activeNestedMachine_transitionsToDefaultState():
	var root := FSM.new()

	var in_play := FSM.new()
	in_play.name = "IN_PLAY"
	root.add_state(in_play)

	var moving := in_play.create_state("MOVING")
	var attacking := in_play.create_state("ATTACKING")
	in_play.default_state = moving

	root.force_transition_to("IN_PLAY")

	return [
		TestCaseResult.from_equals(true, in_play.active, "Nested machine should be active"),
		TestCaseResult.from_equals(moving, in_play.state_node, "Nested machine should select default state"),
		TestCaseResult.from_equals(true, moving.active, "Default state should be active"),
		TestCaseResult.from_equals(false, attacking.active, "Non-default state should be inactive"),
	]


func test_reactivatingNestedMachine_resetsToDefaultState():
	var root := FSM.new()

	var in_play := FSM.new()
	in_play.name = "IN_PLAY"
	root.add_state(in_play)

	var moving := in_play.create_state("MOVING")
	var attacking := in_play.create_state("ATTACKING")
	var destroyed := root.create_state("DESTROYED")
	in_play.default_state = moving

	root.force_transition_to("IN_PLAY")
	in_play.force_transition_to("ATTACKING")
	root.force_transition_to("DESTROYED")
	root.force_transition_to("IN_PLAY")

	return [
		TestCaseResult.from_equals(moving, in_play.state_node, "Nested machine should reset to default state"),
		TestCaseResult.from_equals(true, moving.active, "Default state should be active after reactivation"),
		TestCaseResult.from_equals(false, attacking.active, "Previous nested state should be inactive"),
		TestCaseResult.from_equals(false, destroyed.active, "Previous root state should be inactive"),
	]


func test_nestedMachineWithoutDefault_doesNotAutoSelectState():
	var root := FSM.new()

	var in_play := FSM.new()
	in_play.name = "IN_PLAY"
	root.add_state(in_play)

	var moving := in_play.create_state("MOVING")

	root.force_transition_to("IN_PLAY")

	return [
		TestCaseResult.from_equals(true, in_play.active, "Nested machine should be active"),
		TestCaseResult.from_equals(null, in_play.state_node, "Nested machine should not select a state"),
		TestCaseResult.from_equals(false, moving.active, "Child state should remain inactive"),
	]


func test_invalidDefaultState_doesNotActivateChildState():
	var root := FSM.new()

	var in_play := FSM.new()
	in_play.name = "IN_PLAY"
	root.add_state(in_play)

	var moving := in_play.create_state("MOVING")
	var missing := FSMState.new()
	missing.name = "MISSING"
	in_play.default_state = missing

	root.force_transition_to("IN_PLAY")

	return [
		TestCaseResult.from_equals(true, in_play.active, "Nested machine should be active"),
		TestCaseResult.from_equals(null, in_play.state_node, "Invalid default should not select a state"),
		TestCaseResult.from_equals(false, moving.active, "Child state should remain inactive"),
	]
