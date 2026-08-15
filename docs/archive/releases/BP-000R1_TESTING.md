# BP-000R1 unter Windows testen

> **Historisches Dokument:** Diese Anleitung gehört zum archivierten Elternpaket
> `BP-000R1`. Im aktuellen Paket wird `TEST_BP-001R1.ps1` verwendet; `TEST_BP-001.ps1` leitet dorthin weiter;
> die folgenden Befehle dienen nur der Nachvollziehbarkeit der bestätigten Baseline.

BP-000R1 repariert den Access-Violation-Abbruch des vorherigen Pakets bei
Core-Test 02.15. Das Paket bitte in einen **neuen, leeren Ordner** entpacken.
Nicht über BP-000 kopieren, da nun eine zweite DLL benötigt wird.

## Vollständige Abnahme

```powershell
.\TEST_BP-000R1.ps1 `
  -Compiler C:\Pfad\MiniLangCompilerPy\mlc_win64.py `
  -StdLib C:\Pfad\MiniLangCompilerPy `
  -QuakeBase "C:\Program Files (x86)\Steam\steamapps\common\Quake" `
  -Map start `
  -Frames 120 `
  -NetworkTests
```

## Ohne Quake-Daten

```powershell
.\TEST_BP-000R1.ps1 `
  -Compiler C:\Pfad\MiniLangCompilerPy\mlc_win64.py `
  -StdLib C:\Pfad\MiniLangCompilerPy
```

## Erwartete Schlüsselausgaben

Die Versionsausgabe muss enthalten:

```text
Package: BP-000R1
Compatibility profile: compat_109
Native text ABI: caller_owned_bytes_v1
```

Der bisher abstürzende Abschnitt muss nun weiterlaufen:

```text
[02/16] byte I/O
  [02.15] buffered native ASCII return
  [02.16] buffered native NUL return
  [02.17] buffered native float text
  [02.18] byte I/O complete
```

Die vollständige Abnahme endet mit:

```text
MiniQuake core tests passed: 16
MiniQuake milestone tests passed: 24
MiniQuake BP-000R1 acceptance test: PASS
```

## Native Textbridge optional neu bauen

Bei installiertem `clang-cl` und `lld-link`:

```powershell
python .\native\build_text_bridge.py --clean
```

`-RebuildNative` im Buildskript baut diese Textbridge ebenfalls neu. Die
Hauptbridge wird nur neu gebaut, wenn die im Ausgangsarchiv fehlende Datei
`third_party\stb\stb_vorbis.c` vorhanden ist.

## Ergebnis einsammeln

Auch nach einem Fehler ausführen:

```powershell
.\COLLECT_RESULTS.ps1
```

Das erzeugte `MiniQuake_BP-000R1_RESULTS_*.zip` enthält Logs, JSON-Berichte und
Binärhashes, aber keine Quake-Daten und keine Binärdateien.
