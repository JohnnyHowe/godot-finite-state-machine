const RepeatTestStates := preload("./repeat_test_states.gd")


func test_deactivationWhileWaiting_deactivatesChild():
	var child := RepeatTestStates.ManualFinishState.new()
	var repeat := FSM.Repeat.new()
	repeat.to_repeat = child
	repeat.repetitions = 2

	repeat._active = true
	repeat._active = false

	return [
		TestCaseResult.from_equals(false, child.active, "Deactivating Repeat should deactivate its running child"),
		TestCaseResult.from_equals(1, child.deactivation_count, "The running child should be deactivated exactly once"),
	]


func test_childFinishAfterRepeatDeactivation_isIgnored():
	var child := RepeatTestStates.ManualFinishState.new()
	var repeat := FSM.Repeat.new()
	var completions: Array[bool] = []
	repeat.state_finished.connect(completions.append.bind(true))
	repeat.to_repeat = child
	repeat.repetitions = 2

	repeat._active = true
	repeat._active = false
	child.finish()

	return [
		TestCaseResult.from_equals(1, child.activation_count, "A cancelled child must not start another repetition"),
		TestCaseResult.from_equals(0, completions.size(), "A cancelled sequence must not finish later"),
	]


func test_deactivationWhileWaiting_disconnectsChildCompletion():
	var child := RepeatTestStates.ManualFinishState.new()
	var repeat := FSM.Repeat.new()
	repeat.to_repeat = child
	repeat.repetitions = 2

	repeat._active = true
	var connected_while_active := child.state_finished.is_connected(repeat._on_child_finished)
	repeat._active = false

	return [
		TestCaseResult.from_equals(true, connected_while_active, "Repeat should listen for the running child to finish"),
		TestCaseResult.from_equals(
			false,
			child.state_finished.is_connected(repeat._on_child_finished),
			"Deactivating Repeat should disconnect its pending child completion callback",
		),
	]


func test_reactivationAfterCancellation_startsFreshSequence():
	var child := RepeatTestStates.ManualFinishState.new()
	var repeat := FSM.Repeat.new()
	var completions: Array[bool] = []
	repeat.state_finished.connect(completions.append.bind(true))
	repeat.to_repeat = child
	repeat.repetitions = 2

	repeat._active = true
	repeat._active = false
	repeat._active = true
	child.finish()
	child.finish()

	return [
		TestCaseResult.from_equals(3, child.activation_count, "Reactivation should start a new full sequence"),
		TestCaseResult.from_equals(1, completions.size(), "Only the reactivated sequence should complete"),
	]


func test_deactivationAfterPartialProgress_reactivationStartsFromFirstRepetition():
	var child := RepeatTestStates.ManualFinishState.new()
	var repeat := FSM.Repeat.new()
	var completions: Array[bool] = []
	repeat.state_finished.connect(completions.append.bind(true))
	repeat.to_repeat = child
	repeat.repetitions = 3

	repeat._active = true
	child.finish()
	repeat._active = false
	var activations_before_reactivation := child.activation_count

	repeat._active = true
	child.finish()
	child.finish()
	var completions_before_third_fresh_run := completions.size()
	child.finish()

	return [
		TestCaseResult.from_equals(2, activations_before_reactivation, "The cancelled sequence should have started two child runs"),
		TestCaseResult.from_equals(0, completions_before_third_fresh_run, "A reactivated sequence should not resume partial progress"),
		TestCaseResult.from_equals(5, child.activation_count, "Reactivation should run every repetition from the beginning"),
		TestCaseResult.from_equals(1, completions.size(), "Only the fresh sequence should complete"),
	]
