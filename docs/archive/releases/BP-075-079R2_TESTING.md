# BP-075–BP-079R2 Windows acceptance

Extract the complete ZIP into a new, empty directory. Do not overlay an older MiniQuake tree.

```powershell
$QuakeBase = "C:\Users\nilsk\Dropbox\Quake"
Test-Path "$QuakeBase\id1\pak0.pak"
```

The path check must return `True`.

```powershell
.\TEST_BP-075-079R2.ps1 `
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

The repaired inherited preflight must report:

```text
MiniQuake BP-036 client/render verification: PASS
  downstream=true
  downstream_package=true
  view_number_parser=c_atoi
```

The five current runtime groups must finish with:

```text
MiniQuake BP-075 math/chase tests passed: 22
MiniQuake BP-076 view/palette tests passed: 22
MiniQuake BP-077 screen/loading tests passed: 22
MiniQuake BP-078 statusbar/scoreboard tests passed: 22
MiniQuake BP-079 gameplay/presentation closure tests passed: 24
```

Expected final line:

```text
MiniQuake BP-075-079R2 acceptance test: PASS
```

Collect the result afterwards:

```powershell
.\COLLECT_RESULTS.ps1
```
