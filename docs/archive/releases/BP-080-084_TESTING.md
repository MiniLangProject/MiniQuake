# BP-080–BP-084 Windows acceptance

Extract the complete ZIP into a new, empty directory.

```powershell
$QuakeBase = "C:\Users\nilsk\Dropbox\Quake"
Test-Path "$QuakeBase\id1\pak0.pak"
```

The path check must return `True`.

```powershell
.\TEST_BP-080-084.ps1 `
  -Compiler C:\Users\nilsk\Desktop\MiniLang\MiniLangCompilerPy\mlc_win64.py `
  -StdLib C:\Users\nilsk\Desktop\MiniLang\MiniLangCompilerPy `
  -QuakeBase $QuakeBase `
  -Game id1 `
  -Map start `
  -Frames 300 `
  -TraceFrames 128 `
  -BlackPortCorpusFrames 64 `
  -NetworkTests `
  -ContinueIndependentTests `
  -BisectOnFailure
```

New runtime markers:

```text
MiniQuake BP-080 cvar source-surface tests passed: 20
MiniQuake BP-081 CD audio source-surface tests passed: 20
MiniQuake BP-082 source function inventory tests passed: 20
MiniQuake BP-083 black-port corpus tests passed: 18
MiniQuake BP-084 source black-port closure tests passed: 24
```

The acceptance script additionally runs two independent 64-frame traces for
`start`, `e1m1`, `e1m2` and `e1m3`; every pair must be byte-identical.

Expected final line:

```text
MiniQuake BP-080-084 acceptance test: PASS
```

Then collect the result:

```powershell
.\COLLECT_RESULTS.ps1
```
