# MiniQuake BP-090--BP-094R3 Windows testing

## Preconditions

Keep the original source archive outside the MiniQuake source tree.

```powershell
$QuakeBase = "C:\Users\nilsk\Dropbox\Quake"
$CompilerRoot = "C:\Users\nilsk\Desktop\MiniLangCompilerPy"
$OriginalSource = "$env:USERPROFILE\Downloads\OriginalQuakeSourceCode.zip"

Test-Path "$QuakeBase\id1\pak0.pak"
Test-Path "$CompilerRoot\mlc_win64.py"
Test-Path $OriginalSource
```

All three commands must print `True`.

Remove Windows download-zone markers from the freshly extracted package:

```powershell
Get-ChildItem -Recurse -File | Unblock-File
```

## Static verifier smoke test

The canonical invocation is:

```powershell
python .\tools\verify.py --root .
```

The historical positional form remains supported for compatibility:

```powershell
python .\tools\verify.py .
```

Both commands must end with `MiniQuake BP-090-094R3 verification: PASS`.

## Full test

```powershell
.\TEST_BP-090-094R3.ps1 `
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

Output remains live and is flushed to the corresponding log after every line.

## R3-specific expected output

The static verifier must include:

```text
[PASS] original_glquake_server_mode
process_mode=listen
video_context_required=True
```

The original-server direction now opens a small original GLQuake window and
must report:

```text
[MiniQuake] starting original GLQuake listen server a ...
MiniQuake client to original GLQuake server a: PASS
[MiniQuake] starting original GLQuake listen server b ...
MiniQuake client to original GLQuake server b: PASS
```

The final result must be:

```text
MiniQuake BP-090-094R3 acceptance test: PASS
```

## Result collection

```powershell
.\COLLECT_RESULTS.ps1
```

The collector creates:

```text
build\MiniQuake_BP-090-094R3_RESULTS_*.zip
```

The result archive contains logs and summaries, but not GLQUAKE.EXE, PAK files
or captured TGA images.
