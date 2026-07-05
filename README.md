# Finite State Machine

THIS DOC IS OUTDATED

Small Godot state machine utility for tracking a named state and emitting signals around changes.

## Public API

- `is_state(target_state)`: Returns whether the current state matches a declared target state.
- `force_transition_to(target_state)`: Changes to a declared target state or pushes an error for an invalid one.
- `try_transition_to(target_state)`: Attempts to change state and returns whether it succeeded.

State changes emit signals in this order:

1. `pre_state_change_values(current, next)`
2. `pre_state_change`
3. `state_change_values(previous, current)`
4. `state_change`

## Testing

Run the project test suite from the repository root:

```powershell
godot --headless --path godot --script addons/gdscript-script-test-runner/src/run_tests.gd
```

## TODO
 - Transition rules/graph
