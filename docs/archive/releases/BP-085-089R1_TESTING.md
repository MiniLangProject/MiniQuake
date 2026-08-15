# BP-085–BP-089R1 Windows acceptance

Extract the complete ZIP into a new empty directory. Do not merge it over an
older MiniQuake tree.

```powershell
$QuakeBase = "C:\Users\nilsk\Dropbox\Quake"
Test-Path "$QuakeBase\id1\pak0.pak"
```

The path check must return `True`.

```powershell
.\TEST_BP-085-089R1.ps1 `
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

The corrected artifact evidence must include:

```text
first_pass_exact=true
semantic=true
stable_exact=true
stable_semantic=true
result=PASS
```

The three Host sessions must run sequentially; no `NET_FreeQSocket: not active`
message is allowed.

Expected final line:

```text
MiniQuake BP-085-089R1 acceptance test: PASS
```

Then collect the result:

```powershell
.\COLLECT_RESULTS.ps1
```

The archive name is:

```text
build\MiniQuake_BP-085-089R1_RESULTS_*.zip
```
