func _assert_full_state(actual, expected, message := ""):
	var results := [
		TestCaseResult.from_equals(expected.size(), actual.size(), "%s size" % message),
	]

	var count = min(actual.size(), expected.size())
	for i in count:
		results.append(TestCaseResult.from_equals(expected[i], actual[i], "%s index %s" % [message, i]))

	return results


func test_emptyMachine_returnsEmptyArray():
	var root := FSM.new()

	return _assert_full_state(root.get_full_state(), [], "empty machine")


func test_machineWithStatesButNoActiveState_returnsEmptyArray():
	var root := FSM.new()
	root.create_state("START")
	root.create_state("END")

	return _assert_full_state(root.get_full_state(), [], "machine without active state")


func test_singleLevelTransition_returnsActiveState():
	var root := FSM.new()
	var start := root.create_state("START")

	root.try_transition_to("START")

	return _assert_full_state(root.get_full_state(), [start], "single active state")


func test_singleLevelTransitionUpdate_excludesInactiveState():
	var root := FSM.new()
	root.create_state("START")
	var end := root.create_state("END")

	root.try_transition_to("START")
	root.try_transition_to("END")

	return _assert_full_state(root.get_full_state(), [end], "single active state after switch")


func test_invalidTransition_doesNotChangeFullState():
	var root := FSM.new()
	var start := root.create_state("START")

	root.try_transition_to("START")
	var before := root.get_full_state()

	root.try_transition_to("MISSING")

	var results: Array = _assert_full_state(before, [start], "before invalid transition")
	results.append_array(_assert_full_state(root.get_full_state(), [start], "after invalid transition"))
	return results


func test_nestedActiveState_returnsRootStateToLeafChain():
	var root := FSM.new()

	var in_play := FSM.new()
	in_play.name = "IN_PLAY"
	root.add_state(in_play)

	var moving := in_play.create_state("MOVING")

	root.try_transition_to("IN_PLAY")
	in_play.try_transition_to("MOVING")

	return _assert_full_state(root.get_full_state(), [in_play, moving], "nested active state")


func test_nestedMachineWithoutActiveState_stopsAtNestedMachine():
	var root := FSM.new()

	var in_play := FSM.new()
	in_play.name = "IN_PLAY"
	root.add_state(in_play)
	in_play.create_state("MOVING")

	root.try_transition_to("IN_PLAY")

	return _assert_full_state(root.get_full_state(), [in_play], "nested machine without active state")


func test_deepNestedActiveState_returnsEveryActiveStateInOrder():
	var root := FSM.new()

	var combat := FSM.new()
	combat.name = "COMBAT"
	root.add_state(combat)

	var attacking := FSM.new()
	attacking.name = "ATTACKING"
	combat.add_state(attacking)

	var windup := attacking.create_state("WINDUP")

	root.try_transition_to("COMBAT")
	combat.try_transition_to("ATTACKING")
	attacking.try_transition_to("WINDUP")

	return _assert_full_state(root.get_full_state(), [combat, attacking, windup], "deep nested active state")


func test_switchingRootBranch_returnsOnlyActiveRootBranch():
	var root := FSM.new()

	var in_play := FSM.new()
	in_play.name = "IN_PLAY"
	root.add_state(in_play)
	in_play.create_state("MOVING")

	var destroyed := root.create_state("DESTROYED")

	root.try_transition_to("IN_PLAY")
	in_play.try_transition_to("MOVING")
	root.try_transition_to("DESTROYED")

	return _assert_full_state(root.get_full_state(), [destroyed], "switched root branch")


func test_switchingNestedBranch_updatesRootFullState():
	var root := FSM.new()

	var in_play := FSM.new()
	in_play.name = "IN_PLAY"
	root.add_state(in_play)

	in_play.create_state("MOVING")
	var attacking := in_play.create_state("ATTACKING")

	root.try_transition_to("IN_PLAY")
	in_play.try_transition_to("MOVING")
	in_play.try_transition_to("ATTACKING")

	return _assert_full_state(root.get_full_state(), [in_play, attacking], "switched nested branch")
