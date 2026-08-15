# BP-001 unter Windows testen

> **Historisches Dokument:** Der beschriebene BP-001-Lauf scheiterte beim
> MiniLang-Compile. Die korrigierte Abnahme steht in `BP-001R1_TESTING.md`.

Das Paket in einen neuen, leeren Ordner entpacken. Nicht über BP-000R1 kopieren.

## Vollständige Abnahme

```powershell
.\TEST_BP-001.ps1 `
  -Compiler C:\Pfad\MiniLangCompilerPy\mlc_win64.py `
  -StdLib C:\Pfad\MiniLangCompilerPy `
  -QuakeBase "C:\Program Files (x86)\Steam\steamapps\common\Quake" `
  -Game id1 `
  -Map start `
  -Frames 120 `
  -TraceFrames 64 `
  -NetworkTests
```

Der Lauf:

1. prüft Manifest, MiniLang-Packages, beide nativen ABIs und den Diagnosevertrag,
2. baut `MiniQuake.exe`, 16 Core-, 24 Milestone- und 8 Diagnosetests,
3. prüft Paketkennung `BP-001` und Elternpaket `BP-000R1`,
4. validiert `id1/start` und 120 Headless-Frames,
5. erzeugt zwei unabhängige 64-Frame-Traces,
6. verlangt byteidentische `.mqtrace`-Dateien,
7. parst Snapshot, Kontext und Summary,
8. prüft die vier Artefakte über `--compat-report`,
9. validiert den direkten `--compat-snapshot`-CLI-Pfad,
10. führt optional den UDP-Loopbacktest aus.

## Nur Build und assetfreie Tests

```powershell
.\TEST_BP-001.ps1 `
  -Compiler C:\Pfad\MiniLangCompilerPy\mlc_win64.py `
  -StdLib C:\Pfad\MiniLangCompilerPy
```

Ohne `-QuakeBase` werden Echtdaten-, Runtime- und Traceabnahme übersprungen;
Core-, Milestone- und Diagnosefixtures laufen trotzdem.

## Einzelner Trace

```powershell
.\build\MiniQuake.exe `
  --compat-trace $QuakeBase start 120 .\build\manual-start `
  -game id1
```

## Einzelner Snapshotlauf

```powershell
.\build\MiniQuake.exe `
  --compat-snapshot $QuakeBase start 32 .\build\manual-snapshot `
  -game id1
```

## Artefakt prüfen

```powershell
.\build\MiniQuake.exe --compat-report .\build\manual-start.mqtrace
.\build\MiniQuake.exe --compat-report .\build\manual-start-summary.json
```

## Rückmeldung erzeugen

Nach Erfolg oder Fehler:

```powershell
.\COLLECT_RESULTS.ps1
```

Das Ergebnis-ZIP enthält Logs, JSON und `.mqtrace`, aber keine EXE/DLL und keine
Quake-Spieldaten. Bitte dieses ZIP wieder hochladen.
