# Semantic GLQuake port review

This report tracks agent source reviews of complete logical units. It is separate from name mapping, differential fixtures, and end-to-end gates.

## Summary

- Reviewed logical units: **6/63 (9.523810 %)**
- Functions inside passing unit reviews: **52/1069 (4.864359 %)**
- Assembly exports inside passing unit reviews: **0/9**
- Missing unit reviews: **56**
- Reviews with open findings: **1**

A passing review is an inspection record, not by itself behavioral proof. The strict differential and process-wide gates remain independently required.

## Units

| Unit | Status | Reviewer | Features | Limitations |
|---|---|---|---:|---:|
| `alias_tables` | pass | alias_viewmodel_parity | 2 | 1 |
| `bsp_format` | missing | — | 0 | 0 |
| `cd_audio` | missing | — | 0 | 0 |
| `chase` | missing | — | 0 | 0 |
| `cl_demo` | missing | — | 0 | 0 |
| `cl_input` | missing | — | 0 | 0 |
| `cl_main` | missing | — | 0 | 0 |
| `cl_parse` | missing | — | 0 | 0 |
| `cl_tent` | open | client_network_audit | 3 | 1 |
| `cmd` | missing | — | 0 | 0 |
| `common` | missing | — | 0 | 0 |
| `conproc` | pass | platform_bridge_parity | 4 | 1 |
| `console` | missing | — | 0 | 0 |
| `crc` | missing | — | 0 | 0 |
| `cvar` | missing | — | 0 | 0 |
| `gl_draw` | missing | — | 0 | 0 |
| `gl_mesh` | pass | alias_viewmodel_parity | 3 | 1 |
| `gl_model` | missing | — | 0 | 0 |
| `gl_refrag` | missing | — | 0 | 0 |
| `gl_rlight` | missing | — | 0 | 0 |
| `gl_rmain` | missing | — | 0 | 0 |
| `gl_rmisc` | missing | — | 0 | 0 |
| `gl_rsurf` | missing | — | 0 | 0 |
| `gl_screen` | missing | — | 0 | 0 |
| `gl_test` | missing | — | 0 | 0 |
| `gl_vidnt` | missing | — | 0 | 0 |
| `gl_warp` | missing | — | 0 | 0 |
| `host` | missing | — | 0 | 0 |
| `host_cmd` | missing | — | 0 | 0 |
| `in_win` | missing | — | 0 | 0 |
| `keys` | missing | — | 0 | 0 |
| `mathlib` | missing | — | 0 | 0 |
| `menu` | missing | — | 0 | 0 |
| `model_format` | missing | — | 0 | 0 |
| `net_dgrm` | pass | client_network_audit | 5 | 3 |
| `net_loop` | pass | client_network_audit | 2 | 1 |
| `net_main` | missing | — | 0 | 0 |
| `net_win` | missing | — | 0 | 0 |
| `net_wins` | missing | — | 0 | 0 |
| `pr_cmds` | missing | — | 0 | 0 |
| `pr_edict` | missing | — | 0 | 0 |
| `pr_exec` | missing | — | 0 | 0 |
| `protocol` | missing | — | 0 | 0 |
| `quakec_abi` | missing | — | 0 | 0 |
| `quakedef` | missing | — | 0 | 0 |
| `r_part` | missing | — | 0 | 0 |
| `render_types` | missing | — | 0 | 0 |
| `resource` | pass | platform_bridge_parity | 1 | 2 |
| `sbar` | missing | — | 0 | 0 |
| `snd_dma` | missing | — | 0 | 0 |
| `snd_mem` | missing | — | 0 | 0 |
| `snd_mix` | missing | — | 0 | 0 |
| `snd_win` | missing | — | 0 | 0 |
| `sprite_format` | missing | — | 0 | 0 |
| `sv_main` | missing | — | 0 | 0 |
| `sv_move` | missing | — | 0 | 0 |
| `sv_phys` | missing | — | 0 | 0 |
| `sv_user` | missing | — | 0 | 0 |
| `sys_win` | missing | — | 0 | 0 |
| `view` | missing | — | 0 | 0 |
| `wad` | missing | — | 0 | 0 |
| `world` | missing | — | 0 | 0 |
| `zone` | missing | — | 0 | 0 |

## Open findings

- `cl_tent`: The isolated CL_UpdateTEnts pendant creates the original progs/bolt.mdl, progs/bolt2.mdl, progs/bolt3.mdl, and progs/beam.mdl entities every 30 units, but the live Host path stores only endpoint events in client_effects.processTemporary and render/particles.renderTemporary emits one GL_LINES primitive. The production renderer must consume the segmented model entities, including per-segment roll and MAX_TEMP_ENTITIES/MAX_VISEDICTS truncation, before this unit can pass.
