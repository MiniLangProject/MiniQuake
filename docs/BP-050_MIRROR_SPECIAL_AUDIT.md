# BP-050 mirror special-render audit

Source-guided against `gl_rmain.c:R_Mirror`, `gl_rsurf.c:R_MirrorChain`, `gl_rmisc.c:R_NewMap`, and `R_SetupGL`.

Bound behavior:
- mirror texture prefix `window02_1` (10 bytes);
- first mirror chain selects the plane;
- reflected origin and forward vector use the original plane equations;
- reflected scene uses depth range 0.5..1 and back-face culling after projection reflection;
- mirror overlay restores 0..0.5, the unreflected base projection, front-face culling, alpha blending, and the original chain;
- view entity is present in the reflected entity list;
- mirror recursion is prevented.

Asset-free fixtures: 22.
