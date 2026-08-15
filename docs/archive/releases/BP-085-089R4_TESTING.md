# BP-085–BP-089R4 Windows acceptance

Extract the complete ZIP into a new empty directory. Do not overlay R3.

```powershell
$QuakeBase = "C:\Users\nilsk\Dropbox\Quake"
Test-Path "$QuakeBase\id1\pak0.pak"
```

The check must return `True`. Then run:

```powershell
.\TEST_BP-085-089R4.ps1 `
  -Compiler C:\Users\nilsk\Desktop\MiniLangCompilerPy\mlc_win64.py `
  -StdLib C:\Users\nilsk\Desktop\MiniLangCompilerPy `
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

The repaired early gate must report:

```text
MiniQuake BP-031 command/cvar verification: PASS
  downstream_package=true fixed_six_formatter=native_msvcrt_percent_f
```

The retail save evidence must subsequently report:

```text
save_float_format=4097:4097.000000 negative:-4097.000000
first_pass_exact=true
semantic=true
stable_exact=true
stable_semantic=true
result=PASS
```

Expected final line:

```text
MiniQuake BP-085-089R4 acceptance test: PASS
```

Collect the result with:

```powershell
.\COLLECT_RESULTS.ps1
```
