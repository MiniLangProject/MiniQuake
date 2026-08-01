# BP-001R1 unter Windows testen

BP-001R1 repariert den BP-001-Kompilierabbruch in den neuen Diagnoseformatierern
und verbessert den Build-Rückkanal. Das vollständige ZIP bitte in einen **neuen,
leeren Ordner** entpacken.

## Vollständige Abnahme

```powershell
.\TEST_BP-001R1.ps1 `
  -Compiler C:\Users\nilsk\Desktop\MiniLangCompilerPy\mlc_win64.py `
  -StdLib C:\Users\nilsk\Desktop\MiniLangCompilerPy `
  -QuakeBase "C:\Program Files (x86)\Steam\steamapps\common\Quake" `
  -Game id1 `
  -Map start `
  -Frames 120 `
  -TraceFrames 64 `
  -NetworkTests
```

Der alte Befehl `TEST_BP-001.ps1` bleibt als Weiterleitungswrapper erhalten,
empfohlen ist aber der explizite R1-Befehl.

## Erwartete frühe Ausgaben

Die statische Prüfung muss unter anderem melden:

```text
[PASS] bp001r1_diagnostics_contract
[PASS] compiler_safe_diagnostic_expressions
```

Danach muss der Spielcompile nun erfolgreich enden. Sein vollständiger Text
steht unabhängig vom PowerShell-Transcript in:

```text
build\compile-game.log
```

Die Versionsausgabe muss enthalten:

```text
Package: BP-001R1
Parent package: BP-001
Compatibility profile: compat_109
Native text ABI: caller_owned_bytes_v1
```

Die vollständige Abnahme baut und startet anschließend:

- 16 Core-Tests,
- 24 Milestone-Tests,
- 8 Diagnosefixtures,
- `id1/start`-Validierung,
- 120 Headless-Frames,
- zwei unabhängige 64-Frame-Kompatibilitätstraces,
- Snapshot- und Schemaabnahme,
- optional den Winsock-UDP-Loopback.

Das erwartete Ende lautet:

```text
MiniQuake BP-001R1 diagnostics tests passed: 8
MiniQuake BP-001R1 acceptance test: PASS
```

## Nur Build und assetfreie Tests

```powershell
.\TEST_BP-001R1.ps1 `
  -Compiler C:\Users\nilsk\Desktop\MiniLangCompilerPy\mlc_win64.py `
  -StdLib C:\Users\nilsk\Desktop\MiniLangCompilerPy
```

## Bei einem Fehler

Unabhängig vom Fehlerzeitpunkt ausführen:

```powershell
.\COLLECT_RESULTS.ps1
```

Das Resultat enthält nun zusätzlich:

```text
build\bp001r1-build-child.log
build\compile-game.log
build\compile-core-tests.log
build\compile-milestone-tests.log
build\compile-diagnostics-tests.log
```

Nur tatsächlich entstandene Logs werden aufgenommen. EXE/DLL und Quake-Daten
werden weiterhin nicht kopiert. `environment.json` vermerkt für Spiel-, Core-,
Milestone- und Diagnose-EXE sowie beide DLLs explizit Existenz und gegebenenfalls
SHA-256; unterbrochene `*.partial.exe`-Ausgaben werden separat ausgewiesen.
