# BP-085–BP-089R2 Windows acceptance

Extract the complete archive into a new, empty directory. Output is streamed
live and flushed to the logs.

```powershell
$QuakeBase = "C:\Users\nilsk\Dropbox\Quake"
Test-Path "$QuakeBase\id1\pak0.pak"

.\TEST_BP-085-089R2.ps1 `
  -Compiler C:\Users\nilsk\Desktop\MiniLang\MiniLangCompilerPy\mlc_win64.py `
  -StdLib C:\Users\nilsk\Desktop\MiniLang\MiniLangCompilerPy `
  -QuakeBase $QuakeBase `
  -Game id1 `
  -Map start `
  -Frames 300 `
  -TraceFrames 128 `
  -BlackPortCorpusFrames 64 `
  -SoakFrames 5000 `
  -ListenSoakFrames 5000 `
  -NetworkTests `
  -ContinueIndependentTests `
  -BisectOnFailure
```

The retail artifact evidence must include:

```text
save_float_format=4097:4097.000000 negative:-4097.000000
first_pass_exact=true
semantic=true
stable_exact=true
stable_semantic=true
result=PASS
```

Afterwards run:

```powershell
.\COLLECT_RESULTS.ps1
```
