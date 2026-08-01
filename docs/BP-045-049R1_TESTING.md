# BP-045–BP-049R1 unter Windows testen

Das vollständige ZIP in einen neuen, leeren Ordner entpacken. Der angegebene
Quake-Basispfad muss den Unterordner `id1` enthalten.

```powershell
$QuakeBase = "C:\Pfad\zu\Quake"
Test-Path "$QuakeBase\id1\pak0.pak"
```

Die Prüfung muss `True` ergeben. Danach:

```powershell
.\TEST_BP-045-049R1.ps1 `
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

Das neue frühe Gate lautet:

```text
[PASS] bp045049r1_collector_history_contract
MiniQuake BP-012R1 Protocol 15 server-data verification: PASS
```

Danach müssen die fünf aktuellen Gruppen erfolgreich enden:

```text
MiniQuake BP-045 alias model tests passed: 22
MiniQuake BP-046 sprite sync tests passed: 22
MiniQuake BP-047 render UI/HUD tests passed: 24
MiniQuake BP-048 render evidence tests passed: 18
MiniQuake BP-049 model/UI/render closure tests passed: 24
```

Erwarteter Abschluss:

```text
MiniQuake BP-045-049R1 acceptance test: PASS
```

Danach:

```powershell
.\COLLECT_RESULTS.ps1
```

Der Collector erzeugt `build\MiniQuake_BP-045-049R1_RESULTS_*.zip` und enthält
keine Quake-Spieldaten oder kompilierten Binärdateien.
