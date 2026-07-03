
func test_emptyMachine_false():
	var machine := FSM.new()
	return TestCaseResult.from_equals(false, machine.has_state("START"))


func test_machineWithSingleState_true():
	var machine := FSM.new()
	machine.create_state("START")
	return TestCaseResult.from_equals(true, machine.has_state("START"))
