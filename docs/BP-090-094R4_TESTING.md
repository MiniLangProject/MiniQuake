# BP-090--BP-094R4 Windows testing

## Preconditions

Keep the external original archive outside the MiniQuake source tree.

```powershell
$QuakeBase = "C:\Users\nilsk\Dropbox\Quake"
$CompilerRoot = "C:\Users\nilsk\Desktop\MiniLangCompilerPy"
$OriginalSource = "$env:USERPROFILE\Downloads\OriginalQuakeSourceCode.zip"

Test-Path "$QuakeBase\id1\pak0.pak"
Test-Path "$CompilerRoot\mlc_win64.py"
Test-Path $OriginalSource
Test-Path ".\OriginalQuakeSourceCode.zip"
```

Expected:

```text
True
True
True
False
```

Optional package-only verification:

```powershell
python .\tools\verify.py --root .
python .\tools\verify.py .
```

Both forms must report:

```text
MiniQuake BP-090-094R4 verification: PASS
```

## Full acceptance

```powershell
.\TEST_BP-090-094R4.ps1 `
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

The output remains live and unbuffered.

## External process behavior

Several original GLQuake windows appear.  Do not interact with them while the
harness is running.  R4 deliberately does not pass `-condebug`; the 1997 debug
logger has an unsafe 1024-byte buffer that modern OpenGL extension strings can
overflow.

Expected original-server markers include:

```text
starting original GLQuake listen server ... without -condebug
starting MiniQuake client attempt ...
connected=true spawned=true signon=4
result=PASS
```

Expected original-client evidence is a MiniQuake server summary with at least
one active, spawned Protocol-15 client.  Original visual evidence is accepted
only after an actual `quake*.tga` has been produced.

## Final result

```text
MiniQuake BP-090-094R4 acceptance test: PASS
```

Collect the result with:

```powershell
.\COLLECT_RESULTS.ps1
```

The result archive excludes `GLQUAKE.EXE`, PAKs and TGA images.
