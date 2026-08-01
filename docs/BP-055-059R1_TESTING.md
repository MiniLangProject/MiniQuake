# BP-055–BP-059R1 unter Windows testen

Das ZIP in einen neuen, vollständig leeren Ordner entpacken. Anschließend den
tatsächlichen Quake-Basisordner setzen; darin muss `id1\pak0.pak` liegen.

```powershell
$QuakeBase = "C:\Pfad\zu\Quake"
Test-Path "$QuakeBase\id1\pak0.pak"
```

Die Prüfung muss `True` ergeben.

Danach:

```powershell
.\TEST_BP-055-059R1.ps1 `
  -Compiler C:\Users\nilsk\Desktop\MiniLangCompilerPy\mlc_win64.py `
  -StdLib C:\Users\nilsk\Desktop\MiniLangCompilerPy `
  -QuakeBase $QuakeBase `
  -Game id1 `
  -Map start `
  -Frames 300 `
  -TraceFrames 128 `
  -NetworkTests `
  -ContinueIndependentTests `
  -BisectOnFailure
```

Das reparierte frühe Gate muss melden:

```text
MiniQuake BP-054 render-special closure verification: PASS
```

Der JSON-Bericht muss außerdem enthalten:

```text
downstream_package=true
build_package_id=BP-059
build_block_id=BP-055-059
```

Danach werden die neuen Audiogruppen erwartet:

```text
MiniQuake BP-055 audio memory tests passed: 20
MiniQuake BP-056 audio DMA tests passed: 22
MiniQuake BP-057 audio mixer tests passed: 22
MiniQuake BP-058 audio Win32 tests passed: 20
MiniQuake BP-059 audio closure tests passed: 24
MiniQuake BP-059 retail audio evidence: PASS
```

Zum vollständigen Abschluss müssen ebenfalls Spieldatenvalidierung, 300
Headless-Frames, zwei byteidentische 128-Frame-Traces, die geerbte
Framebuffer-Evidenz und UDP-Loopback bestehen.

Erwartete Schlusszeile:

```text
MiniQuake BP-055-059R1 acceptance test: PASS
```

Danach:

```powershell
.\COLLECT_RESULTS.ps1
```

Das Ergebnisarchiv trägt das Muster:

```text
build\MiniQuake_BP-055-059R1_RESULTS_*.zip
```
