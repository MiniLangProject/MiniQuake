# BP-035–BP-039R1 Windows acceptance

Extract the complete archive into a new, empty directory. Do not overlay an
older source tree.

```powershell
.\TEST_BP-035-039R1.ps1 `
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

The repaired gate is:

```text
[18/20] rotate flag
MiniQuake BP-035 client state/render tests passed: 20
```

The complete expected ending is:

```text
byte-identical trace comparison: PASS
MiniQuake UDP loopback smoke
  result=PASS
MiniQuake BP-035-039R1 acceptance test: PASS
```

After the run:

```powershell
.\COLLECT_RESULTS.ps1
```

The collector produces a `MiniQuake_BP-035-039R1_RESULTS_*.zip` archive without
Quake game data or binaries.
