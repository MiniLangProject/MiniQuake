# Absolute-compatibility preflight repair

The original packaged worktree referenced ten helper symbols that were missing
from the actual source overlay. This revision restores the intended source
implementations.

## Restored mathlib behavior

- `boxOnPlaneSide` / `BoxOnPlaneSide`
- `rotatePointAroundVector` / `RotatePointAroundVector`
- `projectPointOnPlane` / `ProjectPointOnPlane`
- `perpendicularVector` / `PerpendicularVector`

The axial plane classification preserves Quake's `BOX_ON_PLANE_SIDE` equality
behavior. The general path chooses the same support corners as the original
`signbits` switch.

## Restored entity-renderer behavior

- `spriteFrameAndTexture` with grouped-frame interval selection
- six-argument `drawSprite(..., time)`
- `SPR_ORIENTED` basis selection from entity angles
- upload and cleanup of every grouped sprite subframe
- `uploadIndexedTexture`
- `setTranslatedPlayerTexture` and translated player texture ownership

No native ABI or DLL export changed in this repair.

## Checks performed

- `tools/ml_lint.py`: PASS, 77 files
- official MiniLang parser via `tools/ml_scope_lint.py`: PASS, 77 files
- `tools/verify.py`: PASS

A Windows Python-compiler build and the existing native test suites remain the
final backend/runtime confirmation.

## Package-export and dynamic-light repair

The Python compiler subsequently exposed a second packaging mismatch:
`render/world.ml` referenced `c.MAX_DLIGHTS`, but the original `client.h`
constant had not been exported by `miniquake.constants`.  A complete scan of
every project-qualified `alias.symbol` reference found the related missing
exports in the compatibility renderer as well.

Restored original values:

- `MAX_DLIGHTS = 32`
- `MAX_VISEDICTS = 256`
- `TOP_RANGE = 16`
- `BOTTOM_RANGE = 96`
- `GL_FRONT = 0x0404`
- `GL_GEQUAL = 0x0206`
- the four original `EF_*` entity-effect bits

The fix also ports the fixed 32-entry `cl_dlights` pool and the original
`CL_AllocDlight` / `CL_DecayLights` behavior instead of satisfying the renderer
with an empty placeholder.  Explosion and entity-effect lights now feed that
pool, and the host decays it once per accepted client frame.

`tools/ml_lint.py` now validates package constants, enums and globals in
addition to functions and struct constructors.  This specifically catches a
missing expression such as `c.MAX_DLIGHTS` during preflight, before native code
generation begins.
