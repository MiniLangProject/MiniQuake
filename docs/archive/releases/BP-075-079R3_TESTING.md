# BP-075–BP-079R3 Windows acceptance

Extract the package into a new, empty directory. Output is streamed live and flushed to the build logs.

```powershell
$QuakeBase = "C:\Users\nilsk\Dropbox\Quake"
Test-Path "$QuakeBase\id1\pak0.pak"

.\TEST_BP-075-079R3.ps1 `
  -Compiler C:\Users\nilsk\Desktop\MiniLang\MiniLangCompilerPy\mlc_win64.py `
  -StdLib C:\Users\nilsk\Desktop\MiniLang\MiniLangCompilerPy `
  -QuakeBase $QuakeBase `
  -Game id1 `
  -Map start `
  -Frames 300 `
  -TraceFrames 128 `
  -NetworkTests `
  -ContinueIndependentTests `
  -BisectOnFailure
```

The repaired inherited gate is:

```text
[12/22] cshift atoi
MiniQuake BP-036 view state tests passed: 22
```

The downstream preflight report must include:

```text
MiniQuake BP-036 client/render verification: PASS
downstream_package=true
view_number_parser=c_atoi
runtime_view_expectation=c_atoi
```

The five current block groups must then pass:

```text
MiniQuake BP-075 math/chase tests passed: 22
MiniQuake BP-076 view/palette tests passed: 22
MiniQuake BP-077 screen/loading tests passed: 22
MiniQuake BP-078 statusbar/scoreboard tests passed: 22
MiniQuake BP-079 gameplay/presentation closure tests passed: 24
```

Expected final line:

```text
MiniQuake BP-075-079R3 acceptance test: PASS
```

Collect results with:

```powershell
.\COLLECT_RESULTS.ps1
```
