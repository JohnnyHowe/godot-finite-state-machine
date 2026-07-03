func test_force_transition_emits_pre_state_change_values() -> TestCaseResult:
	var machine := _create_machine()
	var actual: Array[StringName] = []
	machine.pre_state_change_values.connect(func(current: StringName, next: StringName):
		actual.append(current)
		actual.append(next)
	)

	machine.force_transition_to("running")

	return TestCaseResult.from_equals([&"idle", &"running"], actual)


func test_force_transition_emits_pre_state_change_before_state_changes() -> TestCaseResult:
	var machine := _create_machine()
	var states_during_signal: Array[StringName] = []
	machine.pre_state_change_values.connect(func(_current: StringName, _next: StringName): states_during_signal.append(machine.state))

	machine.force_transition_to("running")

	return TestCaseResult.from_equals([&"idle"], states_during_signal)


func test_force_transition_emits_state_change_values() -> TestCaseResult:
	var machine := _create_machine()
	var actual: Array[StringName] = []
	machine.state_change_values.connect(func(previous: StringName, current: StringName):
		actual.append(previous)
		actual.append(current)
	)

	machine.force_transition_to("running")

	return TestCaseResult.from_equals([&"idle", &"running"], actual)


func test_force_transition_emits_state_change_after_state_changes() -> TestCaseResult:
	var machine := _create_machine()
	var states_during_signal: Array[StringName] = []
	machine.state_change_values.connect(func(_previous: StringName, _current: StringName): states_during_signal.append(machine.state))

	machine.force_transition_to("running")

	return TestCaseResult.from_equals([&"running"], states_during_signal)


func test_force_transition_emits_simple_pre_state_change() -> TestCaseResult:
	var machine := _create_machine()
	var calls: Array[String] = []
	machine.pre_state_change.connect(func(): calls.append("called"))

	machine.force_transition_to("running")

	return TestCaseResult.from_equals(1, calls.size())


func test_force_transition_emits_simple_state_change() -> TestCaseResult:
	var machine := _create_machine()
	var calls: Array[String] = []
	machine.state_change.connect(func(): calls.append("called"))

	machine.force_transition_to("running")

	return TestCaseResult.from_equals(1, calls.size())


func test_force_transition_emits_signals_in_order() -> TestCaseResult:
	var machine := _create_machine()
	var order: Array[String] = []
	machine.pre_state_change_values.connect(func(_current: StringName, _next: StringName): order.append("pre_values"))
	machine.pre_state_change.connect(func(): order.append("pre"))
	machine.state_change_values.connect(func(_previous: StringName, _current: StringName): order.append("change_values"))
	machine.state_change.connect(func(): order.append("change"))

	machine.force_transition_to("running")

	return TestCaseResult.from_equals(["pre_values", "pre", "change_values", "change"], order)


func test_invalid_force_transition_emits_no_change_signals() -> TestCaseResult:
	var machine := _create_machine()
	var calls: Array[String] = []
	machine.pre_state_change_values.connect(func(_current: StringName, _next: StringName): calls.append("pre_values"))
	machine.pre_state_change.connect(func(): calls.append("pre"))
	machine.state_change_values.connect(func(_previous: StringName, _current: StringName): calls.append("change_values"))
	machine.state_change.connect(func(): calls.append("change"))

	machine.force_transition_to("missing")

	return TestCaseResult.from_equals(0, calls.size())


func test_invalid_force_transition_does_not_change_state() -> TestCaseResult:
	var machine := _create_machine()

	machine.force_transition_to("missing")

	return TestCaseResult.from_equals(&"idle", machine.state)


func _create_machine() -> FiniteStateMachine:
	var definition := FiniteStateMachineDefinition.new()
	definition.states = [&"idle", &"running"]

	var machine := FiniteStateMachine.new()
	machine.definition = definition
	machine._state = "idle"
	return machine
