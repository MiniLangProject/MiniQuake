# BP-001R3 unter Windows testen

BP-001R3 isoliert deterministische Headless-Läufe von live abgefragten
Desktop-Eingaben und ergänzt einen feldweisen Tracevergleich.

Das vollständige Paket in einen neuen, leeren Ordner entpacken. Nicht über ein
älteres BP-Paket kopieren.

```powershell
.\TEST_BP-001R3.ps1 `
  -Compiler C:\Users\nilsk\Desktop\MiniLangCompilerPy\mlc_win64.py `
  -StdLib C:\Users\nilsk\Desktop\MiniLangCompilerPy `
  -QuakeBase "C:\Program Files (x86)\Steam\steamapps\common\Quake" `
  -Game id1 `
  -Map start `
  -Frames 120 `
  -TraceFrames 64 `
  -NetworkTests
```

## Erwartete neue Prüfungen

Die statische Prüfung muss zusätzlich die Headless-Eingabeisolierung und das
Vergleichswerkzeug bestätigen. Die assetfreie Suite muss enden mit:

```text
MiniQuake BP-001R3 diagnostics tests passed: 10
```

Der Pakettest führt den Selbsttest des Vergleichswerkzeugs aus:

```text
MiniQuake trace comparator self-test: PASS
```

Danach müssen beide 64-Frame-Traces byteidentisch sein. Der Bericht liegt auch
bei Erfolg unter:

```text
build\bp001r3-trace-comparison.json
```

Das erwartete Ende lautet:

```text
MiniQuake BP-001R3 acceptance test: PASS
```

## Rückmeldung

Unabhängig vom Ergebnis:

```powershell
.\COLLECT_RESULTS.ps1
```

Erzeugt wird ungefähr:

```text
build\MiniQuake_BP-001R3_RESULTS_20260724-....zip
```

Bei einer erneuten Abweichung enthält das Archiv automatisch den ersten
abweichenden Frame und die konkreten Felder. Es werden keine Quake-Spieldaten,
EXE- oder DLL-Dateien aufgenommen.
