# BP-080–BP-084R1 Windows acceptance

Extract the ZIP into a new empty directory.  Do not overlay it on an older
MiniQuake tree.

```powershell
$QuakeBase = "C:\Users\nilsk\Dropbox\Quake"
Test-Path "$QuakeBase\id1\pak0.pak"

.\TEST_BP-080-084R1.ps1 `
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

The early verifier must report:

```text
[PASS] minilang_main_entry_scope
required_bp080_084_entries=5
packaged_entries=0
```

The five new programs must then compile and report:

```text
MiniQuake BP-080 cvar source-surface tests passed: 20
MiniQuake BP-081 CD audio source-surface tests passed: 20
MiniQuake BP-082 source function inventory tests passed: 20
MiniQuake BP-083 black-port corpus tests passed: 18
MiniQuake BP-084 source black-port closure tests passed: 24
```

The final line must be:

```text
MiniQuake BP-080-084R1 acceptance test: PASS
```

Collect the result with:

```powershell
.\COLLECT_RESULTS.ps1
```
