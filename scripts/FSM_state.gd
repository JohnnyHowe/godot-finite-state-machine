class_name FSMState
extends Node


signal state_enter
signal state_exit


@export var _verbose: bool = false


var active: bool:
	get:
		return _active

var _active: bool = false:
	set(value):
		if value == _active:
			return
		if value:
			if _verbose:
				print("%s activated" % self)
			state_enter.emit()
		else:
			if _verbose:
				print("%s deactivated" % self)
			state_exit.emit()

