# BP-075–BP-079 Windows acceptance

Extract the complete package into a new empty directory. Output is streamed live and flushed to the log after every line.

```powershell
$QuakeBase = "C:\Users\nilsk\Dropbox\Quake"

.\TEST_BP-075-079.ps1 `
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

Expected new markers:

```text
MiniQuake BP-075 math/chase tests passed: 22
MiniQuake BP-076 view/palette tests passed: 22
MiniQuake BP-077 screen/loading tests passed: 22
MiniQuake BP-078 statusbar/scoreboard tests passed: 22
MiniQuake BP-079 gameplay/presentation closure tests passed: 24
MiniQuake BP-075-079 acceptance test: PASS
```

Afterwards run `./COLLECT_RESULTS.ps1` and upload the generated result archive.
