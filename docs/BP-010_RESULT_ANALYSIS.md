# BP-010 – Windows-Ergebnisanalyse

Datum: 2026-07-24  
Ergebnisarchiv: `MiniQuake_BP-010_RESULTS_20260724-203941.zip`  
SHA-256: `5f099c56ae95f5c7c604331fa316da045da1e7e3bb1776b31a20b236c7ee51f3`

## Ergebnisgrenze

Der Windows-Lauf bestätigte zunächst sämtliche paketierten Vorprüfungen:

| Schritt | Ergebnis |
|---|---:|
| Manifest, Packages und Imports | PASS |
| Native Hauptbridge | 160/160 PASS |
| Native Textbridge | 11/11 PASS |
| BP-001R3-Diagnoseverträge | PASS |
| Protocol-15-Goldenvektoren | 13/13 PASS |
| Protocol-Konstanten | 18/18 PASS |
| MiniLang-Compile von `MiniQuake.exe` | FAIL, Exitcode 2 |
| Core-/Milestone-/Diagnose-/Wiretests | nicht erreicht |
| Echtdaten-, Trace- und UDP-Abnahme | nicht erreicht |

Die erste Compilerdiagnose war:

```text
CompileError: Undefined variable 'value'
  at src/miniquake/protocol_text.ml:49:29
        output[outputCount] = value
                              ^
```

## Ursache

MiniLang verwendet lexikalische Blockscopes. In `encodeBytes` wurde `value`
erstmals jeweils innerhalb der beiden Zweige eines inneren `if` zugewiesen und
danach außerhalb dieses `if` gelesen. Die beiden Zweigvariablen sind dort nicht
sichtbar. Der Quelltext war syntaktisch gültig, scheiterte aber korrekt bei der
semantischen Namensauflösung.

Bei der Nachprüfung wurde ein zweiter, noch nicht erreichter Fall desselben
Musters in `sizebuf.printText` gefunden: `offset` wurde in drei Zweigen erstmals
zugewiesen und nach dem Block gemeinsam verwendet. BP-010R1 beseitigt beide
Muster, damit der nächste Windows-Lauf nicht nur bis zur unmittelbar gemeldeten
Stelle, sondern auch über den folgenden SizeBuffer-Code hinauskommt.

## Klassifikation

`B0`: Buildblocker in neu hinzugefügtem BP-010-Code. Es wurde keine neue Engine-
oder Wire-Semantik ausgeführt. Die vollständig angenommene BP-001R3-Baseline
bleibt daher unverändert gültig; die funktionale BP-010-Abnahme steht noch aus.

Im Ergebnisarchiv vorhandene ältere Traceartefakte stammen aus vorherigen
Läufen des wiederverwendeten Buildverzeichnisses und sind keine BP-010-
Laufzeitevidenz.

## Korrektur in BP-010R1

- `protocol_text.encodeBytes` schreibt den ausgewählten Bytewert direkt im
  jeweiligen Zweig.
- `sizebuf.printText` beendet jeden Reservierungszweig direkt über den
  gemeinsamen Helfer `writeEncodedCStringAt`.
- Der statische Verifier bindet diese compiler-sicheren Kontrollflussformen und
  lehnt die beiden ursprünglichen Merge-Muster ab.
- Paket- und Ergebnisartefakte tragen eine eigene Kennung `BP-010R1`.

Die Wirebytes, Goldenvektoren und dokumentierten sicheren Abweichungen von
BP-010 werden durch diesen Hotfix nicht geändert.
