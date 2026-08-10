# MiniQuake OPT-001CR2 Windows test

Extract the flat ZIP into a new empty MiniQuake directory.  Run PowerShell as
Administrator so the temporary loopback-only firewall rules can be created and
removed without interaction.

```powershell
Get-ChildItem -Recurse -File | Unblock-File

$QuakeBase = "C:\Users\nilsk\Dropbox\Quake"
$CompilerRoot = "C:\Users\nilsk\Desktop\MiniLang\MiniLangCompilerPy"

.\TEST_OPT-001CR2.ps1 `
  -Compiler "$CompilerRoot\mlc_win64.py" `
  -StdLib $CompilerRoot `
  -QuakeBase $QuakeBase `
  -Game id1 `
  -MatrixFrames 64 `
  -WarmupFrames 300 `
  -BenchmarkFrames 3000 `
  -HandleWarmupFrames 1200 `
  -HandleWindowFrames 5000 `
  -HandleWindows 3 `
  -HandleConfirmationWindows 1 `
  -E1M2VisibleFrames 1000 `
  -E1M2HeadlessFrames 10000 `
  -TransitionFrames 64 `
  -ContinueIndependentTests
```

Expected analyzer output:

```text
MiniQuake optimization aggregate analysis
  prefix=opt001cr2
  handle_classification=STABLE or PLATEAU
  result=PASS

MiniQuake OPT-001C performance comparison: TARGET_MET
  current_prefix=opt001cr2
```

Expected final line:

```text
MiniQuake OPT-001CR2 acceptance test: PASS
```

Collect results with:

```powershell
.\COLLECT_RESULTS.ps1
```

## Live build output

During the build the runner prints `output_mode=attached_console_live`. The nested build PowerShell is not piped by the parent process. Output must appear immediately in the same console and is simultaneously written to `build\opt001cr2-build.log`.
