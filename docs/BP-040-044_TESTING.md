# BP-040–BP-044 Windows acceptance

Extract the complete source ZIP into a new, empty directory. Do not overlay an
older MiniQuake worktree.

```powershell
.\TEST_BP-040-044.ps1 `
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

## New runtime gates

```text
MiniQuake BP-040 world surface tests passed: 20
MiniQuake BP-041 lightmap atlas tests passed: 22
MiniQuake BP-042 dynamic-light render tests passed: 20
MiniQuake BP-043 sky/water render tests passed: 22
MiniQuake BP-044 world-render closure tests passed: 24
```

The executable identity must include:

```text
Package: BP-044
Block: BP-040-044
Block parent package: BP-035-039R1
World/render status: world_render_109_frozen_v1
World/render fingerprint: 0x846a74de
```

All inherited tests, installed-game validation, 300 headless frames, two
independent byte-identical 128-frame traces and Winsock UDP loopback must also
pass.

Expected final line:

```text
MiniQuake BP-040-044 acceptance test: PASS
```

After the run, regardless of success or failure:

```powershell
.\COLLECT_RESULTS.ps1
```

The collector intentionally excludes Quake PAKs, maps, media and generated
executables/DLLs.
