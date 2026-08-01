# BP-070–BP-074R1 Windows acceptance

Extract the complete package into a new empty directory. Output is streamed live and flushed to the logs line by line.

```powershell
$QuakeBase = "C:\Users\nilsk\Dropbox\Quake"
Test-Path "$QuakeBase\id1\pak0.pak"

.\TEST_BP-070-074R1.ps1 `
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

The repaired early gate must print:

```text
MiniQuake BP-069 frontend closure verification: PASS
  ... downstream=true package=BP-074 block=BP-070-074
```

The five new runtime groups must then complete with 24, 24, 20, 24 and 24 fixtures, followed by two byte-identical retail core-asset evidence reports and all inherited runtime gates.

After the run:

```powershell
.\COLLECT_RESULTS.ps1
```
