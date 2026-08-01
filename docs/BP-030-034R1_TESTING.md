# BP-030–BP-034R1 Windows acceptance

Extract the full ZIP into a new empty directory. Do not overlay an older tree.

```powershell
.\TEST_BP-030-034R1.ps1 `
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
[3/18] filtered accumulation
```

It must proceed to:

```text
MiniQuake BP-030 host timing tests passed: 18
```

All already-green groups must remain green, including BP-031 through BP-034,
installed game validation, 300 headless frames, two byte-identical 128-frame
traces and UDP loopback. The final line must be:

```text
MiniQuake BP-030-034R1 acceptance test: PASS
```

After the run:

```powershell
.\COLLECT_RESULTS.ps1
```
