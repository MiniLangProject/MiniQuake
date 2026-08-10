# MiniQuake BP-090–BP-094 – Windows acceptance

This block executes the two external gates left open by the accepted
BP-085–BP-089R8 release candidate:

1. direct Protocol-15 interoperability with the original GLQuake executable in
   both client/server directions;
2. raw full-frame comparison against original GLQuake with SSIM at least 0.95.

The original executable is **not included** in the MiniQuake package.  The test
extracts and verifies it from the user-supplied `OriginalQuakeSourceCode.zip`
or accepts an explicit path to `GLQUAKE.EXE`.

## Prerequisites

- Windows with 32-bit system OpenGL support.
- A Quake installation containing `id1\pak0.pak` (and preferably `pak1.pak`).
- MiniLang Python compiler and standard library.
- `OriginalQuakeSourceCode.zip`, whose `kit\GLQUAKE.EXE` hashes to
  `04862c835c399bc9184f62101ae0390c2a758c21656ec06dcc0384e0f373d588`.

The original archive can be placed next to the extracted MiniQuake directory;
the runner discovers it automatically.  It can also be supplied explicitly.

## Run

```powershell
$QuakeBase = "C:\Users\nilsk\Dropbox\Quake"
$CompilerRoot = "C:\Users\nilsk\Desktop\MiniLang\MiniLangCompilerPy"
$OriginalSource = "C:\Users\nilsk\Downloads\OriginalQuakeSourceCode.zip"

Test-Path "$QuakeBase\id1\pak0.pak"
Test-Path "$CompilerRoot\mlc_win64.py"
Test-Path $OriginalSource
```

All three checks must be `True`.

```powershell
.\TEST_BP-090-094R5.ps1 `
  -Compiler "$CompilerRoot\mlc_win64.py" `
  -StdLib $CompilerRoot `
  -QuakeBase $QuakeBase `
  -OriginalQuakeSourceArchive $OriginalSource `
  -Game id1 `
  -Map start `
  -Frames 300 `
  -TraceFrames 128 `
  -BlackPortCorpusFrames 64 `
  -SoakFrames 5000 `
  -ListenSoakFrames 5000 `
  -OriginalInteropFrames 10000 `
  -OriginalVisualFrame 256 `
  -NetworkTests `
  -ContinueIndependentTests `
  -BisectOnFailure
```

The output remains live and is flushed to log files line by line.

## External interop gates

The test executes two independent pairs in each direction:

```text
original GLQuake listen server → MiniQuake client
MiniQuake dedicated server     → original GLQuake client
```

The supplied `GLQUAKE.EXE` is intentionally run as a windowed listen server:
its GL-specific BSP loader uploads textures and therefore needs a valid OpenGL
context.

Both directions must complete Protocol-15 signon and produce byte-identical
normalized A/B reports.

## External visual gate

For each of `demo1`, `demo2` and `demo3`:

1. original GLQuake is run twice at 640×480 and logical frame 256;
2. its two TGA captures must be byte-identical;
3. MiniQuake captures frames 254–258;
4. the best temporal candidate is selected;
5. raw full-frame SSIM must be at least 0.95.

No crop, translation, gamma, color, scaling or other image normalization is
permitted.

## Expected result

```text
MiniQuake BP-090-094 acceptance test: PASS
```

Then collect the textual evidence:

```powershell
.\COLLECT_RESULTS.ps1
```

The result ZIP excludes the original executable, Quake game data, TGAs, DLLs
and compiled binaries.  It contains logs, summaries, hashes and comparison
metrics only.
