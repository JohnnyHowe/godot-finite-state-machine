## Plays an animation on activated.
## Emits state_finished when animation is finished
extends FSMState


@export var animation_player: AnimationPlayer
@export var animation_name: StringName


func _init() -> void:
	activated.connect(_start)


func _enter_tree() -> void:
	animation_player.animation_finished.connect(_on_animation_finished)


func _start() -> void:
	if not animation_player.has_animation(animation_name):
		push_warning("animation_state %s cannot play animation \"%s\" as it does not exist on player %s", [self, animation_name, animation_player])
		return

	animation_player.play(animation_name)


func _on_animation_finished(animation_name: StringName) -> void:
	if not active:
		return

	if animation_name != animation_name:
		return

	state_finished.emit()
