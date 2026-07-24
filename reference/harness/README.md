# GLQuake diagnostic harnesses

These files are maintained outside the pinned `reference/quake` submodule.
They provide deterministic engine services and serializers for diagnostic
builds without modifying the reference tree.

`tools/sv_user_differential.py` creates a detached worktree at the locked
commit, applies the external `sv_user_pinned_oracle*.patch` instrumentation,
and compiles the selected bodies directly from that worktree's
`WinQuake/sv_user.c`. `sv_user_oracle_stubs.h` and
`sv_user_pinned_driver.c` replace engine globals and BSP services with explicit
fixtures; they do not contain copies of the claimed function bodies. The
matching MiniLang fixture is compared as JSONL at `1e-5`.

`tools/sv_move_differential.py` uses the same detached-worktree design for all
seven `sv_move.c` functions. The only source patch selects the Oracle stub
header; the compiled bodies remain the pinned source bodies.
