# MiniQuake BP-075–BP-079

This cumulative block closes the remaining WinQuake gameplay/presentation surface around `mathlib.c`, `chase.c`, `view.c`, `gl_screen.c`, `sbar.c` and numeric paths from `host_cmd.c`.

| Step | Scope | Runtime fixtures |
|---|---|---:|
| BP-075 | mathlib and chase camera | 22 |
| BP-076 | view, palette and refdef | 22 |
| BP-077 | screen, loading and screenshots | 22 |
| BP-078 | statusbar and scoreboard | 22 |
| BP-079 | host-command and closure contract | 24 |
| **Total** |  | **112** |

Candidate contract:

```text
gameplay_presentation_109_frozen_v1
fingerprint=0xad91624c
```
