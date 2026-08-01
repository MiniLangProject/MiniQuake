# BP-042 audit – dynamic-light frame ordering

## Original reference

`gl_rlight.c`, `gl_rmain.c` and the dynamic-light section of brush-model
rendering in `gl_rsurf.c`.

## Ported behavior

- Dynamic lights are pushed before the render frame counter advances.
- Lightstyles are animated in the same frame boundary.
- Expired lights are ignored using the current Binary32 client time.
- Surface bitmasks union all active lights and reset stale-frame state.
- Movable brush-model surfaces are marked in model-local coordinates.
- `gl_flashblend` and disabled dynamic-light paths skip surface marking.

## Evidence

The C oracle and 20 MiniLang fixtures bind frame-count transitions, active and
expired lights, bit unions, stale resets, flashblend/dynamic bypasses and brush
model marking.
