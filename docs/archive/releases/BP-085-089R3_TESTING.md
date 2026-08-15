# MiniQuake BP-085–BP-089R3 Windows acceptance

Extract the complete ZIP into a new empty directory. Do not overlay R2.

```powershell
$QuakeBase = "C:\Users\nilsk\Dropbox\Quake"
Test-Path "$QuakeBase\id1\pak0.pak"
```

The path check must return `True`.

```powershell
.\TEST_BP-085-089R3.ps1 `
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

The repaired inherited gate must report:

```text
MiniQuake BP-022 QuakeC edict verification: PASS
  downstream_package=true fixed_six_formatter=native_msvcrt_percent_f
```

The subsequent artifact evidence must still report:

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
MiniQuake BP-085-089R3 acceptance test: PASS
```

Then collect the result:

```powershell
.\COLLECT_RESULTS.ps1
```

The collector creates `build\MiniQuake_BP-085-089R3_RESULTS_*.zip`.
