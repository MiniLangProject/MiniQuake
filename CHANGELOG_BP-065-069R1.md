# MiniQuake BP-065–BP-069R1

Delivery/test revision for the BP-065–BP-069 frontend block.

## Corrected

- BP-068 no longer compares Quake Cvar `float` values directly with
  higher-precision MiniLang literals.
- The menu fixtures now bind both the original C Binary32 words and the
  six-decimal strings emitted by `Cvar_SetValue`:
  - `volume`: `0x3f4ccccd`, `0.800000`
  - inverted `m_pitch`: `0xbcb43958`, `-0.022000`
- BP-066 is now labelled with its actual 23 checks instead of 22.
- BP-068 is now labelled with its actual 24 checks instead of 22.
- The frontend block total is therefore 113 fixtures instead of 110.
- The C oracle for BP-068 now uses real C `float` storage and reports exact
  words and formatted Cvar text.
- Acceptance, collector, ledger and verifier metadata now use delivery
  revision `BP-065-069R1`.

## Unchanged

- No file below `src/` changed.
- No file below `native/` changed.
- Engine package remains `BP-069`.
- Frontend candidate contract remains `frontend_109_frozen_v1` with
  fingerprint `0x924251fa`.
