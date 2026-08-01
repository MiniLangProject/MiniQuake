# Auswertung des BP-001-Zielsystemlaufs

## Eingangsartefakt

```text
MiniQuake_BP-001_RESULTS_20260724-155921.zip
SHA-256 ff364f85b3394b11628e22aee805bf6d707d3b7dfb97a6cd5eaabed8640938eb
```

Zielsystem laut Ergebnisarchiv:

```text
Microsoft Windows NT 10.0.26200.0
AMD64
Windows PowerShell 5.1.26100.8894
```

## Beobachteter Ablauf

| Schritt | Ergebnis |
|---|---:|
| Paket- und Manifestprüfung | PASS |
| 101 Source- und 91 Test-ML-Dateien | PASS |
| 1.153 lokale Imports | PASS |
| Hauptbridge-ABI 160/160 | PASS |
| Textbridge-ABI 11/11 | PASS |
| 21 Host-Checkpoints | PASS |
| MiniLang-Build | FAIL, Exitcode 2 |
| Core-/Milestone-/Diagnosetests | nicht erreicht |
| Echtdaten-/Headless-/Trace-/UDP-Abnahme | nicht erreicht |

Das im Ergebnisarchiv gehashte `MiniQuake.exe` war noch das bereits bestätigte
BP-000R1-Artefakt. BP-001 hatte vor dem Ersetzen des Zielprogramms abgebrochen.
Das ist kein Runtime- oder Gameplaybefund zu BP-001.

## Exakte Reproduktion

Das frühere Sammelskript erfasste den Kindprozess-Compilertext nicht. Mit dem
Python-Referenzcompiler wurden deshalb zunächst die neu hinzugefügten Module
separat kompiliert.

Erster Blocker:

```text
CompileError: Expression temp overflow top=1032 max=1024
function=miniquake.compat_diagnostics.contextJson
at compat_diagnostics.ml:145
```

Nach isolierter Auflösung dieses ersten Ausdrucks wurde der zweite Blocker
sichtbar:

```text
CompileError: Expression temp overflow top=1032 max=1024
function=miniquake.compat_trace.canonicalFrame
at compat_trace.ml:203
```

Die Ursache waren tiefe, rechts fortgesetzte String-Konkatenationsbäume in den
neuen Diagnoseformatierern. BP-000R1 kompiliert und läuft bereits vollständig;
der Fehler liegt daher im neu eingeführten BP-001-Diagnosecode und nicht im
Quake-Portkern.

## Korrekturklassifikation

```text
Schweregrad: B0 – Buildblocker
Bereich: ausschließlich Diagnose-/Rückkanal
Engine-Semantik: unverändert
Dateiformat: unverändert
Runtime-Abnahme: mit BP-001R1 erneut erforderlich
```

BP-001R1 zerlegt die betroffenen Ausdrücke in kurze, geordnete Appends und
sichert künftig jeden Compilertext verlustfrei. Sollte ein weiterer
Zielsystemfehler auftreten, enthält das nächste Ergebnisarchiv deshalb die
vollständige Originaldiagnose statt nur des übergeordneten Exitcodes.
