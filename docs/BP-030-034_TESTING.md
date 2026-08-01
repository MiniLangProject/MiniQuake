# BP-030–BP-034 Windows acceptance

Extract the complete archive into a new empty directory and run:

```powershell
.\TEST_BP-030-034.ps1 `
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

New success lines:

```text
MiniQuake BP-030 host timing tests passed: 18
MiniQuake BP-031 command/cvar lifecycle tests passed: 20
MiniQuake BP-032 demo lifecycle tests passed: 20
MiniQuake BP-033 savegame v5 tests passed: 24
MiniQuake BP-034 host lifecycle closure tests passed: 24
MiniQuake BP-030-034 acceptance test: PASS
```

After the run, execute `.\COLLECT_RESULTS.ps1` and upload the generated ZIP.
No Quake game data is collected.
