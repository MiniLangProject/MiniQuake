# BP-014 Windows acceptance

## Clean extraction

Extract the complete BP-014 ZIP into a new, empty directory. Do not overlay it
on BP-013 or an older package; the manifest intentionally rejects stale files.

## Complete acceptance command

```powershell
.\TEST_BP-014.ps1 `
  -Compiler C:\Users\nilsk\Desktop\MiniLangCompilerPy\mlc_win64.py `
  -StdLib C:\Users\nilsk\Desktop\MiniLangCompilerPy `
  -QuakeBase "C:\Program Files (x86)\Steam\steamapps\common\Quake" `
  -Game id1 `
  -Map start `
  -Frames 120 `
  -TraceFrames 64 `
  -NetworkTests
```

## Expected runtime suites

```text
MiniQuake core tests passed: 16
MiniQuake milestone tests passed: 24
MiniQuake BP-001R3 diagnostics tests passed: 10
MiniQuake BP-010R1 Protocol 15 wire tests passed: 15
MiniQuake BP-011 Protocol 15 command tests passed: 14
MiniQuake BP-012R1 Protocol 15 server-data tests passed: 17
MiniQuake BP-013 Protocol 15 event tests passed: 22
MiniQuake BP-014 Protocol 15 runtime-event tests passed: 27
```

The package test also requires:

- static manifest/package/ABI verification,
- all five Protocol-15 oracle/checker families,
- executable identity `Package: BP-014`, parent `BP-013`,
- installed `id1/start` validation,
- 120 headless frames,
- two independent 64-frame traces,
- byte-identical trace comparison,
- snapshot/context/summary schema checks,
- direct `--compat-snapshot` execution,
- Winsock UDP loopback when `-NetworkTests` is supplied.

The final line must be:

```text
MiniQuake BP-014 acceptance test: PASS
```

## Asset-free build and tests

```powershell
.\build.ps1 `
  -Compiler C:\Users\nilsk\Desktop\MiniLangCompilerPy\mlc_win64.py `
  -StdLib C:\Users\nilsk\Desktop\MiniLangCompilerPy
```

The new executable is:

```text
build\MiniQuakeProtocol15RuntimeEventTests.exe
```

## Standalone static/oracle checks

```powershell
python .\tools\verify.py .
python .\tools\check_protocol15_vectors.py .
python .\tools\check_protocol15_commands.py .
python .\tools\check_protocol15_serverdata.py --root .
python .\tools\check_protocol15_events.py --root .
python .\tools\check_protocol15_runtime_events.py --root .
```

When a C compiler is available, the last checker compiles its bundled C oracle.
The acceptance does not require a locally installed C compiler; the independent
Python model, golden document, C source hash and MiniLang runtime fixtures still
run.

## Result collection

After success or failure run:

```powershell
.\COLLECT_RESULTS.ps1
```

This creates a file similar to:

```text
build\MiniQuake_BP-014_RESULTS_20260725-....zip
```

The archive includes logs, JSON reports, traces and source manifests, but no
Quake game data, executables or DLLs. Binary presence and SHA-256 hashes are
recorded in `environment.json`.
