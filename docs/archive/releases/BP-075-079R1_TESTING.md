# BP-075–BP-079R1 Windows acceptance

Extract the complete ZIP into a new, empty directory. Do not overlay an older MiniQuake tree.

```powershell
$QuakeBase = "C:\Users\nilsk\Dropbox\Quake"
Test-Path "$QuakeBase\id1\pak0.pak"
```

The path check must return `True`.

```powershell
.\TEST_BP-075-079R1.ps1 `
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

The repaired preflight must report:

```text
MiniQuake BP-029 world/physics closure verification: PASS
  downstream=true
  authoritative_mode=historical_files_plus_server_sections
  package=BP-079 block=BP-075-079
```

The five new runtime groups must finish with:

```text
MiniQuake BP-075 math/chase tests passed: 22
MiniQuake BP-076 view/palette tests passed: 22
MiniQuake BP-077 screen/loading tests passed: 22
MiniQuake BP-078 statusbar/scoreboard tests passed: 22
MiniQuake BP-079 gameplay/presentation closure tests passed: 24
```

Expected final line:

```text
MiniQuake BP-075-079R1 acceptance test: PASS
```

Collect the result afterwards:

```powershell
.\COLLECT_RESULTS.ps1
```
