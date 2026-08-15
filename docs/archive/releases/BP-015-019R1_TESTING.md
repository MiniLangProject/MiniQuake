# BP-015–BP-019R1 – Windows-Abnahme

Diese Revision korrigiert ausschließlich die veraltete Signon-Phasenannahme im
historischen Meilensteintest. Der Engine-Endstand bleibt BP-019.

Das ZIP in einen neuen, vollständig leeren Ordner entpacken und ausführen:

```powershell
.\TEST_BP-015-019R1.ps1 `
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

Das erste entscheidende Gate ist:

```text
[20/24] complete loopback signon
```

Es darf nicht mehr mit `server consumes prespawn: expected 1, got 0` abbrechen.
Der vollständige Meilensteintest muss enden mit:

```text
MiniQuake milestone tests passed: 24
```

Alle Blockfixtures müssen ebenfalls grün bleiben:

```text
MiniQuake BP-015 Protocol 15 signon tests passed: 12
MiniQuake BP-016 Protocol 15 delivery tests passed: 14
MiniQuake BP-017 Protocol 15 datagram tests passed: 18
MiniQuake BP-018 Protocol 15 demo tests passed: 19
MiniQuake BP-019 Protocol 15 closure tests passed: 15
```

Das erwartete Ende lautet:

```text
byte-identical trace comparison: PASS
MiniQuake UDP loopback smoke
  result=PASS
MiniQuake BP-015-019R1 acceptance test: PASS
```

Danach unabhängig vom Ergebnis ausführen:

```powershell
.\COLLECT_RESULTS.ps1
```

Das Ergebnisarchiv trägt ungefähr den Namen:

```text
build\MiniQuake_BP-015-019R1_RESULTS_YYYYMMDD-HHMMSS.zip
```
