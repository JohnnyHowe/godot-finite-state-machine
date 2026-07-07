# Finite State Machine

A small Godot 4 addon for node-based finite state machines.

`FSM` nodes own named `FSMState` children. Transitions activate one state, deactivate the previous one, and emit change signals. State names are matched case-insensitively.

## Use

1. Add an `FSM` node.
2. Add `FSMState` children for each state.
3. Optionally set `default_state` and each state's `next_state` in the inspector.
4. Call `try_transition_to("StateName")` or `try_transition_default()`.

```gdscript
@onready var fsm: FSM = $FSM

func _ready() -> void:
	fsm.try_transition_to("Idle")

func _on_attack_finished() -> void:
	fsm.try_transition_default()
```

## API

- `create_state(name)`: Creates and registers a new `FSMState`.
- `add_state(state)`: Registers an existing `FSMState`.
- `has_state(name)`: Returns whether a state exists.
- `is_state(name)`: Returns whether the active state matches.
- `try_transition_to(name)`: Changes state and returns whether it succeeded.
- `try_transition_default()`: Moves to the active state's `next_state`, or to `default_state` if no state is active.
- `get_full_state()`: Returns the active state path through nested FSMs.

Signals:

- `pre_state_change_values(current, next)`
- `pre_state_change`
- `state_change_values(previous, current)`
- `state_change`

## Test

From the repository root:

```powershell
godot --headless --path godot --script addons/gdscript-script-test-runner/src/run_tests.gd
```
