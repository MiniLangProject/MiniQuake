# BP-015–BP-019 – Windows-Abnahme

Das vollständige ZIP in einen **neuen, leeren Ordner** entpacken.

```powershell
.\TEST_BP-015-019.ps1 `
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

Der Endstand BP-019 wird einmal gebaut. Danach laufen die unabhängigen
Testprogramme weiter, auch wenn eine einzelne Gruppe fehlschlägt. Das logische
Bisecting ordnet den ersten Fehler BP-015 bis BP-019 zu und verweist auf den
passenden Teilpatch; es führt bewusst keinen zweiten Compilerlauf aus.

Erwartete neue Erfolgsmeldungen:

```text
MiniQuake BP-015 Protocol 15 signon tests passed: 12
MiniQuake BP-016 Protocol 15 delivery tests passed: 14
MiniQuake BP-017 Protocol 15 datagram tests passed: 18
MiniQuake BP-018 Protocol 15 demo tests passed: 19
MiniQuake BP-019 Protocol 15 closure tests passed: 15
MiniQuake BP-015-019 acceptance test: PASS
```

Zusätzlich müssen sämtliche Elternregressionen, 300 Headless-Frames, zwei
untereinander byteidentische 128-Frame-Traces, Snapshot/Context/Summary und der
UDP-Loopback bestehen.

Nach jedem Lauf, auch nach einem Fehler:

```powershell
.\COLLECT_RESULTS.ps1
```

Das Ergebnisarchiv heißt ungefähr:

```text
build\MiniQuake_BP-015-019_RESULTS_YYYYMMDD-HHMMSS.zip
```

Es enthält Logs, Reports, Traces und Metadaten, aber keine Quake-Spieldaten und
keine ausführbaren Binärdateien.
