# Windows-Abnahme: MiniQuake BP-020–BP-024R2

## Vorbereitung

Das vollständige ZIP in einen neuen, leeren Ordner entpacken. Nicht über eine
ältere MiniQuake-Lieferung kopieren.

## Vollständiger Test

```powershell
.\TEST_BP-020-024R2.ps1 `
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

## Entscheidende R2-Gates

```text
MiniQuake BP-020 QuakeC progs.dat tests passed: 18
MiniQuake BP-021 QuakeC VM tests passed: 16
MiniQuake BP-022 QuakeC edict tests passed: 22
MiniQuake BP-023 QuakeC builtin tests passed: 22
MiniQuake BP-024 QuakeC closure tests passed: 20
MiniQuake BP-024 stock QuakeC test: PASS
Validation result: PASS
```

Der Trace muss diesmal tatsächlich 128 Frames schreiben. Zwei unabhängige
Prozesse müssen byteidentische `.mqtrace`-Dateien erzeugen.

Das erwartete Ende lautet:

```text
byte-identical trace comparison: PASS
MiniQuake UDP loopback smoke
  result=PASS
MiniQuake BP-020-024R2 acceptance test: PASS
```

## Ergebnisarchiv

Unabhängig vom Ergebnis anschließend ausführen:

```powershell
.\COLLECT_RESULTS.ps1
```

Erwarteter Dateiname:

```text
build\MiniQuake_BP-020-024R2_RESULTS_YYYYMMDD-HHMMSS.zip
```

Das Archiv enthält Logs, Summaries, Traces und Reports, aber keine PAKs,
Modelle, Sounds, Maps, EXE- oder DLL-Dateien.
