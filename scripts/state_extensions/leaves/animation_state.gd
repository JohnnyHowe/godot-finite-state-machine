## Plays an animation on activated.
## Emits state_finished when animation is finished
extends FSMState


@export var _animation_player: AnimationPlayer
@export var _animation_name: StringName


func _init() -> void:
	activated.connect(_start)


func _enter_tree() -> void:
	_animation_player.animation_finished.connect(_on_animation_finished)


func _start() -> void:
	if not _animation_player.has_animation(_animation_name):
		push_warning("animation_state %s cannot play animation \"%s\" as it does not exist on player %s", [self, _animation_name, _animation_player])
		return

	_animation_player.play(_animation_name)


func _on_animation_finished(animation_name: StringName) -> void:
	if not active:
		return

	if animation_name != _animation_name:
		return

	state_finished.emit()
