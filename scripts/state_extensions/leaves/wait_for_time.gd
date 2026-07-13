extends FSMState


@export var _delay_seconds: float = 1


func _enter_tree() -> void:
	activated.connect(_run)


func _run() -> void:
	get_tree().create_timer(_delay_seconds).timeout.connect(_on_timeout)


func _on_timeout() -> void:
	if active:
		state_finished.emit()
