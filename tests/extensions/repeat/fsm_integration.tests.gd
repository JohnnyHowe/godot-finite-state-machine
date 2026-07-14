const RepeatTestStates := preload("./repeat_test_states.gd")


func test_repeatCompletion_advancesOwningMachineOnlyAfterFinalRepetition():
	var machine := FSM.new()
	var repeat := FSM.Repeat.new()
	repeat.name = "REPEAT"
	var child := RepeatTestStates.ManualFinishState.new()
	var end := FSMState.new()
	end.name = "END"
	repeat.to_repeat = child
	repeat.repetitions = 2
	repeat.next_state = end
	machine.add_state(repeat)
	machine.add_state(end)

	machine.try_transition_to(repeat.name)
	child.finish()
	var state_after_first_finish := machine.state_node
	child.finish()

	return [
		TestCaseResult.from_equals(repeat, state_after_first_finish, "Owning machine should not advance before the final repetition"),
		TestCaseResult.from_equals(end, machine.state_node, "Owning machine should advance after Repeat finishes"),
		TestCaseResult.from_equals(false, repeat.active, "Completed Repeat should be deactivated by its owner"),
		TestCaseResult.from_equals(true, end.active, "Repeat's next state should become active"),
	]


func test_transitionAwayFromRepeat_cancelsPendingSequence():
	var machine := FSM.new()
	var repeat := FSM.Repeat.new()
	repeat.name = "REPEAT"
	var child := RepeatTestStates.ManualFinishState.new()
	var end := FSMState.new()
	end.name = "END"
	repeat.to_repeat = child
	repeat.repetitions = 2
	machine.add_state(repeat)
	machine.add_state(end)

	machine.try_transition_to(repeat.name)
	machine.try_transition_to(end.name)
	child.finish()

	return [
		TestCaseResult.from_equals(end, machine.state_node, "A cancelled child completion must not disturb the owning machine"),
		TestCaseResult.from_equals(1, child.activation_count, "A cancelled child completion must not start another repetition"),
		TestCaseResult.from_equals(false, child.active, "Transitioning away should deactivate Repeat's child"),
	]
