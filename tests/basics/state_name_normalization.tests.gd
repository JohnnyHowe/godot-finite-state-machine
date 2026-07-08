func test_hasState_isCaseInsensitive():
	var machine := FSM.new()
	machine.create_state("Start")

	return [
		TestCaseResult.from_equals(true, machine.has_state("Start")),
		TestCaseResult.from_equals(true, machine.has_state("START")),
		TestCaseResult.from_equals(true, machine.has_state("start")),
		TestCaseResult.from_equals(true, machine.has_state("sTaRt")),
	]


func test_addState_duplicateNamesAreCaseInsensitive():
	var machine := FSM.new()

	var original := FSMState.new()
	original.name = "Start"
	machine.add_state(original)

	var duplicate := FSMState.new()
	duplicate.name = "START"
	machine.add_state(duplicate)

	return [
		TestCaseResult.from_equals(machine, original.get_parent(), "Original state should stay attached."),
		TestCaseResult.from_equivalent(null, duplicate.get_parent(), "Case-only duplicate should not be attached."),
		TestCaseResult.from_equals(1, machine.states.size(), "Case-only duplicate should not be registered."),
	]


func test_createState_duplicateNamesAreCaseInsensitive():
	var machine := FSM.new()

	var original := machine.create_state("Start")
	var duplicate := machine.create_state("START")

	return [
		TestCaseResult.new(original != null, "Original state should be created."),
		TestCaseResult.from_equals(null, duplicate, "Case-only duplicate should be rejected."),
		TestCaseResult.from_equals(1, machine.states.size(), "Case-only duplicate should not be registered."),
	]


func test_stateNames_areStoredInCanonicalUppercase():
	var machine := FSM.new()
	machine.create_state("Start")

	return TestCaseResult.from_equals([&"START"], machine.states.keys())


func test_transitionTargets_areCaseInsensitive():
	var machine := FSM.new()
	machine.create_state("Start")

	machine.try_transition_to("start")

	return [
		TestCaseResult.from_equals(&"START", machine.state_name),
		TestCaseResult.from_equals(true, machine.is_state("Start")),
		TestCaseResult.from_equals(true, machine.is_state("START")),
		TestCaseResult.from_equals(true, machine.is_state("start")),
	]


func test_tryTransitionTargets_areCaseInsensitive():
	var machine := FSM.new()
	machine.create_state("Start")

	var transitioned := machine.try_transition_to("sTaRt")

	return [
		TestCaseResult.from_equals(true, transitioned),
		TestCaseResult.from_equals(&"START", machine.state_name),
		TestCaseResult.from_equals(true, machine.is_state("start")),
	]
