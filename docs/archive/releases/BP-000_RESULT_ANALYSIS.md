# Analyse des BP-000-Anwendertests

Ausgewerteter Lauf: 24. Juli 2026

## Bestanden

- statischer Paketverifier,
- 210/210 Manifestdateien,
- 1.138 lokale MiniLang-Imports,
- 160/160/160 Hauptbridge-ABI-Abgleich,
- PE32+/AMD64-Prüfung,
- Kompilierung von `MiniQuake.exe`, `MiniQuakeTests.exe` und
  `MiniQuakeMilestoneTests.exe`,
- `MiniQuake.exe --version` und Paketkennung BP-000,
- Core-Tests bis einschließlich Schritt 02.14.

## Fehlgeschlagen

```text
[02.15] native C string return
MiniQuake core tests exit code: -1073741819 (0xC0000005)
```

`0xC0000005` ist eine Windows Access Violation. Der Fehler tritt beim ersten
externen Stringzeiger-Rückgabepfad auf. Vorherige native Integer- und
Floatbit-Rückgaben funktionieren; der aufgerufene C-Export liefert laut Quelle
einen statischen Zwei-Byte-Puffer. Damit ist der direkte `returns cstr`-
Marshallingpfad die engste durch den Lauf belegte Fehlergrenze. Die genaue
Compilerursache (beispielsweise Zeigerverkürzung vor der Stringkopie) bleibt
ohne Debuggertrace eine technische Arbeitshypothese.

## Folgerung

Die Baseline darf noch nicht als grün gelten. BP-000R1 ersetzt den betroffenen
ABI-Typ vollständig durch caller-owned Bytepuffer. Milestone-, Netzwerk- und
Echtdatenstatus bleiben bis zur erneuten Abnahme unbekannt.
