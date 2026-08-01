# BP-025–BP-029 Windows acceptance

Extract the complete source ZIP into a new, empty directory. Do not overlay an
older package.

```powershell
.\TEST_BP-025-029.ps1 `
  -Compiler C:\Users\nilsk\Desktop\MiniLangCompilerPy\mlc_win64.py `
  -StdLib C:\Users\nilsk\Desktop\MiniLangCompilerPy `
  -QuakeBase "C:\Program Files (x86)\Steam\steamapps\common\Quake" `
  -Game id1 `
  -Map start `
  -Frames 300 `
  -TraceFrames 128 `
  -NetworkTests `
  -ContinueIndependentTests `
  -BisectOnFailure
```

New expected runtime summaries:

```text
MiniQuake BP-025 world hull tests passed: 14
MiniQuake BP-025 world trace tests passed: 10
MiniQuake BP-026 world link/collision tests passed: 15
MiniQuake BP-027 server movement tests passed: 14
MiniQuake BP-028 server physics tests passed: 18
MiniQuake BP-028 sv_user movement tests passed: 16
MiniQuake BP-029 server user tests passed: 18
MiniQuake BP-029 world/physics closure tests passed: 20
```

All inherited Protocol 15 and QuakeC gates must remain green. The acceptance
also requires installed-game validation, 300 headless frames, two complete and
byte-identical 128-frame traces, a direct snapshot command and Winsock UDP
loopback.

Expected final line:

```text
MiniQuake BP-025-029 acceptance test: PASS
```

After the run, including after a failure:

```powershell
.\COLLECT_RESULTS.ps1
```

The collector excludes executables, DLL contents and Quake game data. It records
binary hashes and includes logs, reports, traces and source-side evidence.
