class_name FSMState
extends Node


signal activated
signal deactivated


@export var _verbose: bool = false
@export var next_state: FSMState


var active: bool:
	get:
		return _active

var _active: bool = false:
	set(value):
		if value == _active:
			return
		_active = value
		if value:
			if _verbose:
				print("%s activated" % self)
			activated.emit()
		else:
			if _verbose:
				print("%s deactivated" % self)
			deactivated.emit()

