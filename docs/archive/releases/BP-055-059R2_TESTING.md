# BP-055–BP-059R2 unter Windows testen

Das ZIP in einen neuen, vollständig leeren Ordner entpacken. Der Quake-
Basisordner muss `id1\pak0.pak` enthalten.

```powershell
$QuakeBase = "C:\Pfad\zu\Quake"
Test-Path "$QuakeBase\id1\pak0.pak"
```

Die Prüfung muss `True` ergeben. Danach:

```powershell
.\TEST_BP-055-059R2.ps1 `
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

Die reparierten Gates sind:

```text
MiniQuake BP-055 audio memory tests passed: 20
MiniQuake BP-056 audio DMA tests passed: 22
MiniQuake BP-059 audio closure tests passed: 24
MiniQuake BP-059 retail audio evidence: PASS
```

Die zugrunde liegenden R2-Korrekturen binden `FindChunk` an `iff_data = 12`,
behandeln `S_ClearPrecache` als Original-No-op, formatieren die CD-Lautstärke
wie C-`%f` und leiten die Retail-Kanalzahl aus `stereo + 1` ab.

Danach müssen zwei unabhängige Retail-Evidenzläufe byteidentisch sein. Es folgen
300 Headless-Frames, zwei byteidentische 128-Frame-Traces, geerbte Render-
Evidenz und UDP-Loopback.

Erwartete Abschlusszeile:

```text
MiniQuake BP-055-059R2 acceptance test: PASS
```

Anschließend:

```powershell
.\COLLECT_RESULTS.ps1
```

Der Collector erzeugt:

```text
build\MiniQuake_BP-055-059R2_RESULTS_*.zip
```
