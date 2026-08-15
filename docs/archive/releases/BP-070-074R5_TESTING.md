# BP-070–BP-074R5 Windows acceptance

Extract into a new empty directory. Output remains live and unbuffered.

```powershell
$QuakeBase = "C:\Users\nilsk\Dropbox\Quake"
Test-Path "$QuakeBase\id1\pak0.pak"

.\TEST_BP-070-074R5.ps1 `
  -Compiler C:\Users\nilsk\Desktop\MiniLangCompilerPy\mlc_win64.py `
  -StdLib C:\Users\nilsk\Desktop\MiniLangCompilerPy `
  -QuakeBase $QuakeBase `
  -Game id1 `
  -Map start `
  -Frames 300 `
  -TraceFrames 128 `
  -NetworkTests `
  -ContinueIndependentTests `
  -BisectOnFailure
```

The repaired gate must end with:

```text
MiniQuake BP-073 model asset tests passed: 24
```

The full target is:

```text
MiniQuake BP-070 common core tests passed: 24
MiniQuake BP-071 filesystem/PACK tests passed: 24
MiniQuake BP-072 WAD/graphics tests passed: 20
MiniQuake BP-073 model asset tests passed: 24
MiniQuake BP-074 core assets/memory closure tests passed: 24
MiniQuake BP-070-074R5 acceptance test: PASS
```

Then run:

```powershell
.\COLLECT_RESULTS.ps1
```

The collector must complete under Windows PowerShell 5.1 even with synthetic `build\bp071_fs\id1` artifacts present.
