# MiniQuake port status

## Current delivery: BP-085–BP-089R8

R8 corrects the final listen-server soak classification: MiniQuake's sparse
client entity prefix may legitimately catch up to WinQuake's existing server
Edict high-water. The leak-sensitive heap, socket, endpoint, handle and queue
gates remain unchanged and strict.
The revised stability fingerprint is `0xd0e3c03f` and the policy is
`server_high_water_plus_existing_static_offset`. Server Edict growth and any new static offset during the idle
measurement remain failures.

Accepted Windows parent: **BP-080–BP-084R2**.

The complete source inventory remains Windows-accepted (`1,094/1,094` target
definitions classified). R7 removes the remaining allocation-dependent
QuakeC-to-server mirror lifetime: the derived `GameServer.edicts` array, every
`QuakeEdict`, its `EntityBaseline` and all nested vectors now keep stable
identity across frames. QuakeC Binary32 words are copied into those existing
objects in place. The authoritative `EdictRuntime.numEdicts` high-water mark is
no longer reconstructed from free flags, so freeing the last Edict cannot
shrink or rebuild the mirror. Savegame loading uses the same stable path with
the explicitly stored high-water count.

The strengthened diagnostics exercise 227 synchronized Edicts for 80 passes
under a 256-byte periodic-GC limit, compare raw object identities, mutate live
QuakeC values on every pass and verify that a freed tail keeps the C-compatible
high-water mark.

| Step | Scope | Fixtures |
|---|---|---:|
| BP-085 | game/search-path profiles | 22 |
| BP-086 | mod and mission-pack runtime | 22 |
| BP-087 | demo/save artifacts | 24 |
| BP-088 | host/listen stability | 20 |
| BP-089 | cumulative release candidate | 24 |
| **Total** |  | **112** |

Candidate:

```text
compat_109_release_candidate_v1
fingerprint=0x29b72a98
```

Explicitly pending external gates:

```text
original_binary_interop
external_glquake_visual_reference
```


## Current delivery: BP-080–BP-084R2

Accepted Windows parent: **BP-075–BP-079R3**.

R2 corrects global entry-helper symbol collisions after the R1 entrypoint-scope fix; the block closes source-function accounting for the selected
WinQuake/GLQuake 1.09 `compat_109` profile and adds a deterministic four-map
black-port corpus.

| Step | Scope | Fixtures |
|---|---|---:|
| BP-080 | `cvar.c` exact-name context adapters | 20 |
| BP-081 | `cd_win.c` mechanical technical equivalents | 20 |
| BP-082 | source-function inventory | 20 |
| BP-083 | four-map deterministic corpus contract | 18 |
| BP-084 | source-guided closure contract | 24 |
| **Total** |  | **102** |

Source inventory:

```text
53 C translation units
10 header/data units
1,120 definitions discovered
26 positive QUAKE2-only definitions excluded
1,094 compat_109 target definitions
1,081 exact-name MiniLang functions
9 context adapters
4 technical equivalents
0 unclassified
```

Candidate contract:

```text
black_port_source_109_frozen_v1
fingerprint=0x309b0737
```

This contract closes source accounting. It does not replace later Original
binary interoperability, mod/mission-pack, long-soak or external visual
reference gates.

## Accepted compatibility contracts

```text
protocol15_frozen_v1
quakec_109_frozen_v1
world_physics_109_frozen_v1
host_lifecycle_109_frozen_v1
client_render_109_frozen_v1
world_render_109_frozen_v1
model_ui_render_109_frozen_v1
render_special_109_frozen_v1
audio_109_frozen_v1
network_platform_109_frozen_v1
frontend_109_frozen_v1
core_assets_memory_109_frozen_v1
gameplay_presentation_109_frozen_v1
```
