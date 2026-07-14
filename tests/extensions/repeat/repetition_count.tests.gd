const RepeatTestStates := preload("./repeat_test_states.gd")


func test_zeroRepetitions_doesNotActivateChildAndFinishesOnce():
	var child := RepeatTestStates.ManualFinishState.new()
	var repeat := FSM.Repeat.new()
	var completions: Array[bool] = []
	repeat.state_finished.connect(completions.append.bind(true))
	repeat.to_repeat = child
	repeat.repetitions = 0

	repeat._active = true

	return [
		TestCaseResult.from_equals(0, child.activation_count, "Zero repetitions should not activate the child"),
		TestCaseResult.from_equals(1, completions.size(), "Zero repetitions should finish immediately and exactly once"),
	]


func test_negativeRepetitions_doesNotActivateChildAndFinishesOnce():
	var child := RepeatTestStates.ManualFinishState.new()
	var repeat := FSM.Repeat.new()
	var completions: Array[bool] = []
	repeat.state_finished.connect(completions.append.bind(true))
	repeat.to_repeat = child
	repeat.repetitions = -1

	repeat._active = true

	return [
		TestCaseResult.from_equals(0, child.activation_count, "Negative repetitions should not activate the child"),
		TestCaseResult.from_equals(1, completions.size(), "Negative repetitions should finish immediately and exactly once"),
	]


func test_oneRepetition_waitsForChildThenFinishes():
	var child := RepeatTestStates.ManualFinishState.new()
	var repeat := FSM.Repeat.new()
	var completions: Array[bool] = []
	repeat.state_finished.connect(func(): completions.append(true))
	repeat.to_repeat = child
	repeat.repetitions = 1

	repeat._active = true
	var completions_before_child_finishes := completions.size()
	child.finish()

	return [
		TestCaseResult.from_equals(1, child.activation_count, "One repetition should activate the child once"),
		TestCaseResult.from_equals(0, completions_before_child_finishes, "Repeat should wait for its child"),
		TestCaseResult.from_equals(1, completions.size(), "Repeat should finish after its only child run"),
	]


func test_threeRepetitions_advanceOneAtATimeAndFinishOnce():
	var child := RepeatTestStates.ManualFinishState.new()
	var repeat := FSM.Repeat.new()
	var completions: Array[bool] = []
	repeat.state_finished.connect(completions.append.bind(true))
	repeat.to_repeat = child
	repeat.repetitions = 3

	repeat._active = true
	var activations_at_start := child.activation_count
	child.finish()
	var activations_after_first_finish := child.activation_count
	child.finish()
	var activations_after_second_finish := child.activation_count
	var completions_before_last_finish := completions.size()
	child.finish()

	return [
		TestCaseResult.from_equals(1, activations_at_start, "Only the first repetition should start immediately"),
		TestCaseResult.from_equals(2, activations_after_first_finish, "First completion should start only the second repetition"),
		TestCaseResult.from_equals(3, activations_after_second_finish, "Second completion should start only the third repetition"),
		TestCaseResult.from_equals(0, completions_before_last_finish, "Repeat should not finish early"),
		TestCaseResult.from_equals(3, child.activation_count, "Configured number of child runs should be exact"),
		TestCaseResult.from_equals(1, completions.size(), "Repeat should finish exactly once"),
	]


func test_extraChildFinishAfterCompletion_isIgnored():
	var child := RepeatTestStates.ManualFinishState.new()
	var repeat := FSM.Repeat.new()
	var completions: Array[bool] = []
	repeat.state_finished.connect(completions.append.bind(true))
	repeat.to_repeat = child
	repeat.repetitions = 1

	repeat._active = true
	child.finish()
	child.finish()

	return [
		TestCaseResult.from_equals(1, child.activation_count, "A stale completion must not restart the child"),
		TestCaseResult.from_equals(1, completions.size(), "A stale completion must not finish Repeat again"),
	]


func test_instantChild_completesAllRepetitions():
	var child := RepeatTestStates.InstantFinishState.new()
	var repeat := FSM.Repeat.new()
	var completions: Array[bool] = []
	repeat.state_finished.connect(completions.append.bind(true))
	repeat.to_repeat = child
	repeat.repetitions = 3

	repeat._active = true

	return [
		TestCaseResult.from_equals(3, child.activation_count, "Synchronous completion should still run every repetition"),
		TestCaseResult.from_equals(1, completions.size(), "Synchronous completion should finish Repeat once"),
	]
