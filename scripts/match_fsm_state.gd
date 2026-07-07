## Activates and deactivates a FSMState to mirror another.
extends Node


@export var listen_to: FSMState 
@export var subject: FSMState 


func _enter_tree() -> void:
	listen_to.activated.connect(func(): subject._active = true)
	listen_to.deactivated.connect(func(): subject._active = false)
	subject._active = listen_to.active
