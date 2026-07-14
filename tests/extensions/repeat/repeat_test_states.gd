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
