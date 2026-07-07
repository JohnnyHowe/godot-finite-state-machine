func test_nestedTransition_marksParentAndChildActive():
	var root := FSM.new()

	var in_play := FSM.new()
	in_play.name = "IN_PLAY"
	root.add_state(in_play)

	var moving := in_play.create_state("MOVING")

	root.try_transition_to("IN_PLAY")
	in_play.try_transition_to("MOVING")

	return [
		TestCaseResult.from_equals(true, in_play.active, "Parent state should be active"),
		TestCaseResult.from_equals(true, moving.active, "Child state should be active"),
	]


func test_switchingNestedState_deactivatesPreviousChildAndActivatesNextChild():
	var root := FSM.new()

	var in_play := FSM.new()
	in_play.name = "IN_PLAY"
	root.add_state(in_play)

	var moving := in_play.create_state("MOVING")
	var attacking := in_play.create_state("ATTACKING")

	root.try_transition_to("IN_PLAY")
	in_play.try_transition_to("MOVING")
	in_play.try_transition_to("ATTACKING")

	return [
		TestCaseResult.from_equals(true, in_play.active, "Parent state should remain active"),
		TestCaseResult.from_equals(false, moving.active, "Previous child state should be inactive"),
		TestCaseResult.from_equals(true, attacking.active, "Current child state should be active"),
	]


func test_switchingRootState_deactivatesNestedParentAndActiveChild():
	var root := FSM.new()

	var in_play := FSM.new()
	in_play.name = "IN_PLAY"
	root.add_state(in_play)

	var moving := in_play.create_state("MOVING")
	var destroyed := root.create_state("DESTROYED")

	root.try_transition_to("IN_PLAY")
	in_play.try_transition_to("MOVING")
	root.try_transition_to("DESTROYED")

	return [
		TestCaseResult.from_equals(false, in_play.active, "Nested parent state should be inactive"),
		TestCaseResult.from_equals(false, moving.active, "Active child state should be inactive"),
		TestCaseResult.from_equals(true, destroyed.active, "New root state should be active"),
	]


func test_invalidRootTransition_doesNotChangeNestedActiveFlags():
	var root := FSM.new()

	var in_play := FSM.new()
	in_play.name = "IN_PLAY"
	root.add_state(in_play)

	var moving := in_play.create_state("MOVING")

	root.try_transition_to("IN_PLAY")
	in_play.try_transition_to("MOVING")
	root.try_transition_to("MISSING")

	return [
		TestCaseResult.from_equals(true, in_play.active, "Parent state should remain active"),
		TestCaseResult.from_equals(true, moving.active, "Child state should remain active"),
	]


func test_invalidNestedTransition_doesNotChangeNestedActiveFlags():
	var root := FSM.new()

	var in_play := FSM.new()
	in_play.name = "IN_PLAY"
	root.add_state(in_play)

	var moving := in_play.create_state("MOVING")

	root.try_transition_to("IN_PLAY")
	in_play.try_transition_to("MOVING")
	in_play.try_transition_to("MISSING")

	return [
		TestCaseResult.from_equals(true, in_play.active, "Parent state should remain active"),
		TestCaseResult.from_equals(true, moving.active, "Child state should remain active"),
	]
