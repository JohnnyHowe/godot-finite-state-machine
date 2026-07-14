const RepeatTestStates := preload("./repeat_test_states.gd")


func test_reactivationAfterCompletion_runsFullSequenceAgain():
	var child := RepeatTestStates.ManualFinishState.new()
	var repeat := FSM.Repeat.new()
	var completions: Array[bool] = []
	repeat.state_finished.connect(completions.append.bind(true))
	repeat.to_repeat = child
	repeat.repetitions = 2

	repeat._active = true
	child.finish()
	child.finish()
	repeat._active = false
	repeat._active = true
	child.finish()
	child.finish()

	return [
		TestCaseResult.from_equals(4, child.activation_count, "Each activation cycle should run the full sequence"),
		TestCaseResult.from_equals(2, completions.size(), "Each activation cycle should finish exactly once"),
	]


func test_assigningActiveValueTwice_doesNotRestartChildOrDuplicateCallback():
	var child := RepeatTestStates.ManualFinishState.new()
	var repeat := FSM.Repeat.new()
	repeat.to_repeat = child
	repeat.repetitions = 2

	repeat._active = true
	repeat._active = true
	var connections_while_active := child.state_finished.get_connections().size()
	repeat._active = false
	repeat._active = false

	return [
		TestCaseResult.from_equals(1, child.activation_count, "Assigning active twice should activate the child only once"),
		TestCaseResult.from_equals(1, connections_while_active, "Assigning active twice should register only one child callback"),
		TestCaseResult.from_equals(1, child.deactivation_count, "Assigning inactive twice should deactivate the child only once"),
	]


func test_activationWithAlreadyActiveChild_restartsChildForFirstRepetition():
	var child := RepeatTestStates.ManualFinishState.new()
	var repeat := FSM.Repeat.new()
	repeat.to_repeat = child
	repeat.repetitions = 1

	child._active = true
	repeat._active = true

	return [
		TestCaseResult.from_equals(true, child.active, "The child should remain active for the first repetition"),
		TestCaseResult.from_equals(2, child.activation_count, "Repeat should reactivate an already-active child for a fresh run"),
		TestCaseResult.from_equals(1, child.deactivation_count, "Restarting an already-active child should deactivate it once"),
	]
