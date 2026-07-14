class ManualFinishState extends FSMState:
	var activation_count: int = 0
	var deactivation_count: int = 0


	func _init() -> void:
		activated.connect(func(): activation_count += 1)
		deactivated.connect(func(): deactivation_count += 1)


	func finish() -> void:
		state_finished.emit()


class InstantFinishState extends ManualFinishState:
	func _init() -> void:
		super()
		activated.connect(finish)


func test_zeroRepetitions_doesNotActivateChildAndFinishesOnce():
	var child := ManualFinishState.new()
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


func test_oneRepetition_waitsForChildThenFinishes():
	var child := ManualFinishState.new()
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
	var child := ManualFinishState.new()
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
	var child := ManualFinishState.new()
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
	var child := InstantFinishState.new()
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


func test_deactivationWhileWaiting_deactivatesChild():
	var child := ManualFinishState.new()
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
	var child := ManualFinishState.new()
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


func test_reactivationAfterCancellation_startsFreshSequence():
	var child := ManualFinishState.new()
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


func test_reactivationAfterCompletion_runsFullSequenceAgain():
	var child := ManualFinishState.new()
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


func test_repeatCompletion_advancesOwningMachineOnlyAfterFinalRepetition():
	var machine := FSM.new()
	var repeat := FSM.Repeat.new()
	repeat.name = "REPEAT"
	var child := ManualFinishState.new()
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
	var child := ManualFinishState.new()
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
