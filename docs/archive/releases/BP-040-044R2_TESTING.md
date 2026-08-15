# BP-040–BP-044R2 Windows acceptance

Extract the complete source archive into a new, empty directory. Do not overlay
R2 on an older MiniQuake tree.

```powershell
.\TEST_BP-040-044R2.ps1 `
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

## Early gates

The preflight must include:

```text
[PASS] minilang_entry_function_shadow_arity
[PASS] bp040044r1_renderer_member_write_contract
[PASS] bp040044r2_entry_symbol_shadow_contract
```

The cumulative build must now create all 43 executables, including:

```text
MiniQuake.exe
MiniQuakeWorldSurfaceRenderTests.exe
MiniQuakeLightmapAtlasTests.exe
MiniQuakeDynamicLightRenderTests.exe
MiniQuakeSkyWaterRenderTests.exe
MiniQuakeWorldRenderClosureTests.exe
```

The new world-render groups must end with:

```text
MiniQuake BP-040 world surface tests passed: 20
MiniQuake BP-041 lightmap atlas tests passed: 22
MiniQuake BP-042 dynamic-light render tests passed: 20
MiniQuake BP-043 sky/water render tests passed: 22
MiniQuake BP-044 world-render closure tests passed: 24
```

All inherited Protocol 15, QuakeC, world/physics, host/lifecycle and
client/render tests must remain green. With Quake data supplied, the run also
performs installed-game validation, 300 headless frames, two independent
128-frame compatibility traces, byte-identical trace comparison and Winsock UDP
loopback.

Expected final line:

```text
MiniQuake BP-040-044R2 acceptance test: PASS
```

After either success or failure:

```powershell
.\COLLECT_RESULTS.ps1
```

Expected result name:

```text
build\MiniQuake_BP-040-044R2_RESULTS_YYYYMMDD-HHMMSS.zip
```
