# BP-035 audit — `cl_main.c` and render handoff

The port checks the fixed dynamic-light pool, strict expiry comparison,
overflow fallback, decay, message-time interpolation, angle wrapping,
teleport/force-link snapping, view-entity filtering and the 256-entry visible
entity cap. Client-owned C-float fields are explicitly rounded to Binary32.
