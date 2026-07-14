@icon("../resources/FSM.svg")
class_name FSMState
extends Node


signal activated
signal deactivated
signal state_finished


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
				print("[%s] %s activated" % [Engine.get_frames_drawn(), self])
			activated.emit()
		else:
			if _verbose:
				print("[%s] %s deactivated" % [Engine.get_frames_drawn(), self])
			deactivated.emit()
