# BP-065 key/focus audit

Compared paths: `keys.c::Key_Event`, `keys.c::Key_ClearStates`, and `gl_vidnt.c::ClearAllStates`.
The original emits key-up commands for every key before clearing the physical tables. MiniQuake now queues the same direct and shifted `+`-binding releases and drains them into the command buffer before later key-down events.
