# BP-045–BP-049 Windows acceptance

This cumulative block is based on the Windows-accepted delivery
`BP-040-044R3`. It preserves all frozen Protocol 15, QuakeC, world/physics,
host/lifecycle, client/render and world/render contracts and adds alias model,
sprite, 2D/HUD and deterministic framebuffer-evidence coverage.

## Prerequisites

- Windows x64;
- the MiniLang Python reference compiler or compatible native compiler;
- the MiniLang source standard library containing `std/fs.ml`;
- a legal Quake installation whose base directory contains `id1/pak0.pak`;
- Python 3 for preflight, trace and framebuffer comparison.

The value passed to `-QuakeBase` is the directory **above** `id1`, not the
`id1` directory itself and not the path to `pak0.pak`.

```powershell
$QuakeBase = "C:\Path\To\Quake"
Test-Path "$QuakeBase\id1\pak0.pak"
```

The final command must print `True`.

## Full acceptance run

Extract the ZIP into a new, empty directory and run:

```powershell
.\TEST_BP-045-049.ps1 `
  -Compiler C:\Users\nilsk\Desktop\MiniLangCompilerPy\mlc_win64.py `
  -StdLib C:\Users\nilsk\Desktop\MiniLangCompilerPy `
  -QuakeBase $QuakeBase `
  -Game id1 `
  -Map start `
  -Frames 300 `
  -TraceFrames 128 `
  -RenderEvidenceFrame 128 `
  -NetworkTests `
  -ContinueIndependentTests `
  -BisectOnFailure
```

The script performs one cumulative build and then runs all inherited and new
independent test groups. Important new success markers are:

```text
MiniQuake BP-045 alias model tests passed: 22
MiniQuake BP-046 sprite sync tests passed: 22
MiniQuake BP-047 2D/HUD tests passed: 24
MiniQuake BP-048 render evidence tests passed: 18
MiniQuake BP-049 model/UI/render closure tests passed: 24
```

The real-game acceptance additionally requires:

- installed `id1/start` validation;
- 300 headless frames;
- two byte-identical 128-frame compatibility traces;
- two independent 640×480 framebuffer captures at frame 128;
- exact TGA identity and SSIM 1.0 between those two MiniQuake captures;
- Winsock UDP loopback.

Expected final line:

```text
MiniQuake BP-045-049 acceptance test: PASS
```

## Render-evidence artifacts

The command used by the acceptance script is equivalent to:

```powershell
.\build\MiniQuake.exe --render-evidence `
  $QuakeBase start 128 build\evidence\run-a -game id1
```

For each run MiniQuake writes:

```text
PREFIX.tga
PREFIX-summary.json
```

Capture occurs after 3D, HUD, console/menu and other 2D composition, but before
the back-buffer swap. The summary records dimensions, full framebuffer hash,
sampled hash, non-black pixel count and the exact capture stage.

BP-048 currently proves **cross-process MiniQuake determinism** on the test
machine. The included comparator also supports a future original-GLQuake image
corpus through `--min-ssim 0.95`, but no original copyrighted screenshot corpus
is bundled and this block by itself does not claim that the external >95%
visual target has already been measured.

## Optional reduced runs

Build and asset-free tests only:

```powershell
.\TEST_BP-045-049.ps1 `
  -Compiler C:\Path\MiniLangCompilerPy\mlc_win64.py `
  -StdLib C:\Path\MiniLangCompilerPy `
  -SkipGameValidation `
  -SkipTraceValidation `
  -SkipRenderEvidence `
  -ContinueIndependentTests
```

Reuse already compiled binaries:

```powershell
.\TEST_BP-045-049.ps1 `
  -SkipBuild `
  -QuakeBase $QuakeBase `
  -NetworkTests `
  -ContinueIndependentTests
```

## Result collection

Run this after a PASS, FAIL or native crash:

```powershell
.\COLLECT_RESULTS.ps1
```

It creates approximately:

```text
build\MiniQuake_BP-045-049_RESULTS_YYYYMMDD-HHMMSS.zip
```

The archive contains logs, JSON reports, traces and TGA evidence. It does not
contain PAKs, maps, models, sounds, `progs.dat`, compiled EXEs or DLL binaries.
Upload that archive for the next black-port iteration.
