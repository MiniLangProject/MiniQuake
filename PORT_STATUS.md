# OPT-001C frame-allocation optimization

Current delivery: `OPT-001C`, parent `OPT-001B`.

OPT-001B is Windows-accepted: `e1m2` completed 1,000 visible and 10,000 headless frames, `e1m1 -> e1m2 -> e1m1` passed, deterministic traces matched, and the handle sequence `278,279,279,279` was classified as a plateau rather than a leak. OPT-001C removes trace-only argument-array construction from the disabled GL diagnostic fast path and compares the result against the accepted OPT-001B performance baseline.

# MiniQuake port status

## Current delivery: BP-090–BP-094R15

R14 passed both interoperability directions plus demo1/demo2 visual parity. R15 fixes the remaining demo3 experiment by binding both original GLQuake and MiniQuake to a fixed 0.02-second simulation step; the raw SSIM gates remain unchanged.


## Current delivery: BP-090--BP-094R4

R4 keeps the verified original `GLQUAKE.EXE` byte-identical but disables its
unsafe `-condebug` path.  The 1997 `Con_DebugLog` implementation owns a fixed
1024-byte `vsprintf` buffer; the modern GL extension line observed in R3 was
2580 bytes and caused access violation `0xC0000005`.  External evidence now
uses real Protocol-3/15 summaries, process liveness and produced TGA files
instead of `qconsole.log`.

Candidate remains:

```text
compat_109_final_candidate_v1
fingerprint=0xe04a7727
```


## Current delivery: BP-090–BP-094R3

Accepted Windows parent: **BP-085–BP-089R8**.

The accepted parent confirms the cumulative `compat_109` release-candidate
matrix on Windows: all unit/regression suites, `id1`, `rogue`, `hipnotic`,
retail demos, exact Quake-v5 savegame roundtrips, deterministic traces, the
four-map black-port corpus, two 5,000-frame stability soaks, retail asset/audio
evidence, deterministic framebuffer evidence, Protocol-3 process handshakes
and UDP loopback are green.

BP-090 through BP-094 implement the two deliberately open external gates.

R3 launches the verified original GLQuake binary as a windowed listen server for the original-server direction. True GLQuake dedicated mode skips video initialization while the GL BSP loader still uploads textures, so it cannot safely load `start.bsp` for this gate. The
original executable and tester-owned PAK files are supplied only at test time
and are excluded from both the source ZIP and the result archive.

| Step | Scope | Fixtures |
|---|---|---:|
| BP-090 | exact original GLQuake executable provenance and staging | 20 |
| BP-091 | original GLQuake server → MiniQuake client Protocol-15 interop | 20 |
| BP-092 | MiniQuake server → original GLQuake client Protocol-15 interop | 20 |
| BP-093 | raw full-frame original GLQuake visual-reference corpus | 20 |
| BP-094 | cumulative external compatibility closure | 24 |
| **Total** |  | **104** |

External reference candidate:

```text
original_reference_109_candidate_v1
fingerprint=0xdc355175
GLQUAKE.EXE sha256=04862c835c399bc9184f62101ae0390c2a758c21656ec06dcc0384e0f373d588
```

Final compatibility candidate:

```text
compat_109_final_candidate_v1
fingerprint=0xe04a7727
```

Windows acceptance is still pending for this delivery. The mandatory acceptance
run requires two process pairs in each original-binary interop direction and
three independent original-GLQuake visual scenarios (`demo1`, `demo2`, `demo3`)
with raw full-frame SSIM of at least `0.95`. No crop, translation, rescaling,
gamma correction or color normalization is permitted.

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


## Current optimization delivery: OPT-001CR1

The first OPT-001C Windows run passed package verification but failed before
`MiniQuake.exe` compiled because a guarded lightmap trace expression in
`render/world.ml` contained a mismatched `]`/`)` delimiter.  No performance
measurement ran.

OPT-001CR1 repairs both affected trace-only call sites and adds a lexical
delimiter preflight across every project `.ml` file before the long build.
The OPT-001C allocation contract and accepted OPT-001B correctness baseline are
unchanged.

## Current optimization delivery: OPT-001CR2

The OPT-001CR1 Windows run passed every product, correctness, map, render,
trace and long-run gate.  Its two final analysis steps failed because they
still assumed the historical `opt001a-*` and `opt001c-*` artifact prefixes,
while the runner generated `opt001cr1-*` files.

Reconstructing the comparison from the emitted JSON reports proves that the
OPT-001C target was reached: average render median improved by 45.901%, average
render P99 by 47.209%, and average render throughput by 1.7345x.

OPT-001CR2 makes both analyzers prefix-aware and adds one confirmation handle
window.  The engine and native sources remain unchanged from OPT-001CR1.


## OPT-001CR3R2

Harness-Hotfix für skalare Exitcodes bei ungepufferter Live-Ausgabe; Windows-Abnahme ausstehend.


## OPT-001CR3R3

Harness-Hotfix für exakte benannte Buildparameterbindung; Windows-Abnahme ausstehend.


## OPT-001CR3R4

- Parent: OPT-001CR3R3
- Status: Windows build pending
- Fix: package-free Hotpath-Testhelfer eindeutig präfixiert; Importclosure-/Arity-Kollisionen werden vor dem Build geprüft.
