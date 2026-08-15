# BP-070–BP-074R2 Windows acceptance

Extract the complete package into a new, empty directory. Output is streamed live and flushed to the build logs line by line.

```powershell
$QuakeBase = "C:\Users\nilsk\Dropbox\Quake"
Test-Path "$QuakeBase\id1\pak0.pak"
```

The path check must return `True`. Then run:

```powershell
.\TEST_BP-070-074R2.ps1 `
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

The repaired first new gate must compile and then report:

```text
MiniQuake BP-070 common core tests passed: 24
```

The remaining block gates are:

```text
MiniQuake BP-071 filesystem/PACK tests passed: 24
MiniQuake BP-072 WAD/graphics tests passed: 20
MiniQuake BP-073 model asset tests passed: 24
MiniQuake BP-074 core assets/memory closure tests passed: 24
```

The complete run must additionally pass installed-game validation, two byte-identical retail core-asset reports, 300 headless frames, two byte-identical 128-frame traces, inherited audio/render evidence, two Protocol-3 process pairs and Winsock UDP loopback.

Expected final line:

```text
MiniQuake BP-070-074R2 acceptance test: PASS
```

Collect the result with:

```powershell
.\COLLECT_RESULTS.ps1
```
