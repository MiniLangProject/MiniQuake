# BP-045–BP-049R3 Windows acceptance

Extract the package into a new, empty directory. Confirm the installed Quake
path first:

```powershell
$QuakeBase = "C:\Path\To\Quake"
Test-Path "$QuakeBase\id1\pak0.pak"
```

The second command must return `True`.

Run:

```powershell
.\TEST_BP-045-049R3.ps1 `
  -Compiler C:\Users\nilsk\Desktop\MiniLangCompilerPy\mlc_win64.py `
  -StdLib C:\Users\nilsk\Desktop\MiniLangCompilerPy `
  -QuakeBase $QuakeBase `
  -Game id1 `
  -Map start `
  -Frames 300 `
  -TraceFrames 128 `
  -RenderEvidenceFrame 128 `
  -NetworkTests `
  -ContinueIndependentTests `
  -BisectOnFailure
```

The new preflight must include:

```text
[PASS] bp045049r3_render_input_isolation_contract
MiniQuake BP-048 render evidence verification: PASS
```

The decisive runtime section must report two byte-identical evidence images:

```text
deterministic render evidence A: PASS
deterministic render evidence B: PASS
byte-identical render evidence comparison: PASS
render evidence SSIM = 1.0
MiniQuake BP-045-049R3 acceptance test: PASS
```

After the run, regardless of PASS or FAIL:

```powershell
.\COLLECT_RESULTS.ps1
```
