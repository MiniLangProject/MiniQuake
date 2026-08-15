# BP-051 render-clear special-path audit

Source-guided against `gl_rmain.c:R_Clear` and `R_RenderView`.

Bound behavior:
- mirror depth split 0..0.5;
- normal clear depth 0..1;
- z-trick alternates 0..0.49999/LEQUAL and 1..0.5/GEQUAL;
- `gl_clear` controls color clearing;
- `gl_finish` occurs before rendering;
- `r_norefresh` skips the 3D render path without changing the normal default.

Asset-free fixtures: 20.
