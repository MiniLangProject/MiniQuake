# BP-089 cumulative compatibility release candidate

BP-089 aggregates 18 Windows-accepted or current-block contracts into:

```text
compat_109_release_candidate_v1
fingerprint=0x29b72a98
```

The release-candidate matrix includes Protocol 15, QuakeC, physics, host,
rendering, audio, network/platform, frontend, assets/memory, gameplay,
source-function accounting, game profiles, mod runtime, artifacts and stability.

Two claims remain deliberately open:

```text
original_binary_interop
external_glquake_visual_reference
```

The first requires actual original WinQuake/GLQuake binaries communicating with
MiniQuake in both directions. The second requires a legally generated external
GLQuake reference-image corpus and the already implemented SSIM comparison
(>= 0.95). Neither is inferred from MiniQuake-vs.-MiniQuake determinism.
