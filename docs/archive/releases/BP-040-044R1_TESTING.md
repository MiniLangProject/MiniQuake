# BP-040–BP-044R1 Windows acceptance

Extract the complete source package into a new, empty directory. Do not overlay
it on the failed BP-040–BP-044 tree.

```powershell
.\TEST_BP-040-044R1.ps1 `
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

The new preflight must include:

```text
[PASS] bp040044r1_renderer_member_write_contract
```

The first repaired gate is successful compilation of:

```text
build\MiniQuake.exe
```

After that, the five block-specific suites must report:

```text
MiniQuake BP-040 world surface tests passed: 20
MiniQuake BP-041 lightmap atlas tests passed: 22
MiniQuake BP-042 dynamic-light render tests passed: 20
MiniQuake BP-043 sky/water render tests passed: 22
MiniQuake BP-044 world-render closure tests passed: 24
```

All inherited gates must remain green, followed by installed-game validation,
300 headless frames, two byte-identical 128-frame traces and UDP loopback.

Expected final line:

```text
MiniQuake BP-040-044R1 acceptance test: PASS
```

After the run, execute:

```powershell
.\COLLECT_RESULTS.ps1
```

The result archive is named approximately:

```text
build\MiniQuake_BP-040-044R1_RESULTS_YYYYMMDD-HHMMSS.zip
```
