class_name FSMState
extends Node


signal state_enter
signal state_exit


var active: bool:
	get:
		return _active

var _active: bool = false:
	set(value):
		if value == _active:
			return
		if value:
			state_enter.emit()
		else:
			state_exit.emit()

