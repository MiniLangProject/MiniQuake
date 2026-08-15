# BP-035–BP-039 Windows acceptance

Extract the package into a new, empty directory and run:

```powershell
.\TEST_BP-035-039.ps1 `
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

Expected new success lines:

```text
MiniQuake BP-035 client state/render tests passed: 20
MiniQuake BP-036 view state tests passed: 22
MiniQuake BP-037 temporary beam render tests passed: 22
MiniQuake BP-038 particle runtime tests passed: 22
MiniQuake BP-039 client/render closure tests passed: 24
MiniQuake BP-035-039 acceptance test: PASS
```

After the run, execute `.\COLLECT_RESULTS.ps1` and upload the generated ZIP.
The collector contains the BP-030–034R1 trailing-comma correction.
