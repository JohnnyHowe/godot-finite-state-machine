# FSMState state_name

## Notes

* Ignore FSM.gd for now. This is to be removed.

## Source of Truth

a state name var is the source of truth.

It cannot be changed at runtime.
The only exception is if the FSMState node is created at runtime and it has not yet been set.

It can be changed in the editor only when the game is not running (that is, not the remote view).

## Node Name

The node name is tied to the state name.

On startup (both editor and runtime), the node name is derived from the state name.

IF the node name is changed in editor by the user, then the state name up derived from node name.
