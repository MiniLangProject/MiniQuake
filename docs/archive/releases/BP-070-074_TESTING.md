# BP-070–BP-074 Windows acceptance

Run from a clean extracted directory. Output is streamed live and flushed to logs.

```powershell
$QuakeBase = "C:\Users\nilsk\Dropbox\Quake"
.\TEST_BP-070-074.ps1 `
  -Compiler C:\Users\nilsk\Desktop\MiniLangCompilerPy\mlc_win64.py `
  -StdLib C:\Users\nilsk\Desktop\MiniLangCompilerPy `
  -QuakeBase $QuakeBase `
  -Game id1 -Map start -Frames 300 -TraceFrames 128 `
  -NetworkTests -ContinueIndependentTests -BisectOnFailure
```

Expected new markers:

```text
MiniQuake BP-070 common core tests passed: 24
MiniQuake BP-071 filesystem/PACK tests passed: 24
MiniQuake BP-072 WAD/graphics tests passed: 20
MiniQuake BP-073 model asset tests passed: 24
MiniQuake BP-074 core assets/memory closure tests passed: 24
MiniQuake BP-074 retail core asset evidence
result=PASS
MiniQuake BP-070-074 acceptance test: PASS
```
