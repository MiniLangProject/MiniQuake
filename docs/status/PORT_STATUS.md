# MiniQuake current port status

Updated: 2026-09-01

MiniQuake targets GLQuake/WinQuake 1.09 behavior on Windows x64, Protocol 15
and the original Quake data formats. Engine behavior is implemented in
MiniLang. The native boundary is limited to operating-system integration,
rendering, audio, UDP, controller and codec facilities.

## Current repository state

- The source inventory accounts for all 1,094 selected `compat_109`
  definitions. This measures source coverage; it is not a claim that every
  runtime scenario is defect-free.
- OpenGL, Direct3D 9 and Vulkan backends are present. Vulkan is loaded at
  runtime and preserves the OpenGL fallback path.
- All three backends provide an optional enhanced path for per-pixel dynamic
  lights and geometry-projected real-time shadows while retaining the original
  BSP lightmaps.
- The production documentation audit covers MiniLang and maintained native
  sources, including file provenance and function summaries.
- Build products (`build`, `build_perf`, `native/build` and
  `native/text_build`) are excluded from source integrity checks.
- Proprietary Quake data is not part of the repository. Retail qualification
  uses a local Quake installation.
- The `v2026.09.01` Windows x64 release is built with MiniLangPy revision
  `d7e143a`; its package contains only MiniQuake, the required native runtime
  bridges, documentation and license notices.
- Safe fixed-array hot paths use MiniLang's native `copyArray` primitive.
  Differential traces remain byte-identical, all 59 optimization checks pass,
  and a 5,000-frame OpenGL A/B workload measured an 18% conservative
  paired-median improvement. Headless and map-loading measurements remained
  neutral within normal noise.

## Compatibility qualification

The checked-in contracts cover Protocol 15, QuakeC, world and physics,
client/world rendering, audio, frontend behavior, assets, savegames, demos and
the source inventory. Original-binary interoperability, reference-image
comparison, retail-map traversal and long-running soak tests remain runtime
acceptance gates; they cannot be replaced by source accounting alone.

The reported engine identity remains `BP-094` / `OPT-001D` so existing build
and evidence consumers keep working. `SOURCE_MANIFEST.sha256` independently
binds the current deliverable file set. Its text entries use canonical LF line
endings while binary entries remain byte-exact, making the hashes independent
of the checkout platform.

## Reproducible checks

```powershell
python tools/verify.py --root .
python tools/check_source_documentation.py --root .
python tools/check_minilang_delimiters.py --root .
```

After an intentional source change, refresh and verify the manifest in one
explicit operation:

```powershell
python tools/verify.py --root . --refresh-manifest
```

Historical acceptance detail remains in `PORT_LEDGER.json`,
`BLOCK_LEDGER.json`, `docs/archive/changelog/`, `docs/archive/releases/`,
`scripts/TEST_*.ps1`, and `audit/`.
