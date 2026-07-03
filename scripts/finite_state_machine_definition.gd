## Declares the states and the state transitions.
class_name FiniteStateMachineDefinition
extends Resource


@export var states: Array[StringName]


func has_state(target_state: StringName) -> bool:
	var states_lowercase := states.map(func(state): return state.to_lower())
	return states_lowercase.has(target_state.to_lower())
