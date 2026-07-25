@tool
extends RefCounted


const ACTIVE_NAME_PREFIX: StringName = "▶ "
const DEACTIVE_NAME_PREFIX: StringName = "▷ "
const ACTIVE_ROOT_NAME_PREFIX: StringName = "■ "
const DEACTIVE_ROOT_NAME_PREFIX: StringName = "□ "


var _synchronizing := false
var _state: FSMState


func _init(state: FSMState) -> void:
	_state = state
	_state.renamed.connect(_on_node_renamed)
	_state.state_name_changed.connect(_on_state_name_changed)


func _on_state_name_changed() -> void:
	update_node_name()


func update_node_name() -> void:
	if _synchronizing:
		return

	var expected_name := _get_display_name_from_state_name()
	if _state.name == expected_name:
		return

	_synchronizing = true
	_state.name = expected_name
	_synchronizing = false


func _get_display_name_from_state_name() -> StringName:
	var prefix := ""
	if _state.is_root:
		prefix = ACTIVE_ROOT_NAME_PREFIX if _state.active else DEACTIVE_ROOT_NAME_PREFIX
	else:
		prefix = ACTIVE_NAME_PREFIX if _state.active else DEACTIVE_NAME_PREFIX
	return prefix + _state.state_name


func _on_node_renamed() -> void:
	if _synchronizing:
		return

	if Engine.is_editor_hint():
		_state.state_name = _get_state_name_from_display_name(_state.name)

	update_node_name()


func _get_state_name_from_display_name(display_name: String) -> String:
	for prefix in [
		ACTIVE_NAME_PREFIX,
		DEACTIVE_NAME_PREFIX,
		ACTIVE_ROOT_NAME_PREFIX,
		DEACTIVE_ROOT_NAME_PREFIX
	]:
		display_name = display_name.trim_prefix(prefix)

	return _get_sanitised_state_name(display_name)


static func _get_sanitised_state_name(original: StringName) -> StringName:
	var sanitised = original
	sanitised = sanitised.to_upper()
	sanitised = sanitised.trim_prefix(" ").trim_suffix(" ")
	sanitised = sanitised.replace(" ", "_")

	var regex := RegEx.new()
	regex.compile("[^A-Z0-9_]")
	sanitised = regex.sub(sanitised.to_upper(), "", true)

	return sanitised


func sanitise(original: StringName) -> StringName:
	return _get_sanitised_state_name(original)
