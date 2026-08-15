# BP-070–BP-074R3 Windows acceptance

Extract the package into a new, empty directory. Output is streamed live and flushed to the build logs line by line.

```powershell
$QuakeBase = "C:\Users\nilsk\Dropbox\Quake"
Test-Path "$QuakeBase\id1\pak0.pak"
```

The path check must return `True`. Then run:

```powershell
.\TEST_BP-070-074R3.ps1 `
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

The corrected early gate is:

```text
[10/24] shareware loose restriction
...
MiniQuake BP-071 filesystem/PACK tests passed: 24
```

The remaining new groups must then complete:

```text
MiniQuake BP-072 WAD/graphics tests passed: 20
MiniQuake BP-073 model asset tests passed: 24
MiniQuake BP-074 core assets/memory closure tests passed: 24
```

Two independent retail core-asset reports must be byte-identical, followed by installed game validation, 300 headless frames, two byte-identical 128-frame traces, inherited audio/render/network evidence and UDP loopback. The final line must be:

```text
MiniQuake BP-070-074R3 acceptance test: PASS
```

Collect the result with:

```powershell
.\COLLECT_RESULTS.ps1
```
