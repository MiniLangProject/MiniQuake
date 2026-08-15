# MiniQuake BP-001R1 – Compilerfeste Diagnosebasis

Datum: 24. Juli 2026  
Elternpaket: `BP-001`  
Letzte bestätigte Runtime-Baseline: `BP-000R1`  
Kompatibilitätsprofil: `compat_109`

## Anlass

Der zurückgelieferte BP-001-Zielsystemlauf bestand die vollständige statische
Paketprüfung, brach aber beim ersten MiniLang-Kompilierschritt mit Exitcode `2`
ab. Deshalb wurden weder die Core-/Milestone-/Diagnosetests noch Echtdaten,
Traces oder UDP erreicht.

Das ursprüngliche Rückmeldepaket enthielt nur den übergeordneten Exitcode. Eine
lokale Reproduktion mit dem MiniLang-Python-Compiler grenzte zwei neue,
ausschließlich in BP-001 eingeführte Diagnoseausdrücke ein:

```text
Expression temp overflow ... miniquake.compat_diagnostics.contextJson
Expression temp overflow ... miniquake.compat_trace.canonicalFrame
```

Beide Funktionen hatten vollständige JSON- beziehungsweise Tracezeilen als eine
sehr tiefe binäre `+`-Ausdruckskette formuliert. Der Win64-Backendpfad reserviert
einen begrenzten Bereich für Ausdruckstemporäre; die Engine-Basis aus BP-000R1
war davon nicht betroffen.

## Korrektur

Die Serialisierung verwendet nun kurze, geordnete Append-Anweisungen und kleine
Abschnittsfunktionen. Unverändert bleiben:

- alle Feldnamen,
- die Reihenfolge der Felder,
- Float32- und U32-Hexkodierung,
- Trace-, Snapshot-, Summary- und Crashkontext-Schemaversion,
- Zustands- und Rolling-Hash-Verfahren,
- Host-Checkpoint-Reihenfolge,
- Gameplay-, Protokoll-, QuakeC-, Physik-, Render- und Audiosemantik.

Eine neue statische Prüfung lehnt erneut eingeführte, übergroße
Konkatenationsausdrücke in den beiden Diagnosemodulen ab. Der vollständige
Programmeinstieg sowie die Core-, Milestone- und Diagnose-Testziele wurden
danach lokal mit dem MiniLang-Python-Compiler und einem kleinen, API-kompatiblen
`std`-Compile-Harness erfolgreich erzeugt. Die vollständige Standardbibliothek,
Windows-Runtime und Doppeltrace-Abnahme bleiben Bestandteil des Anwenderlaufs.

## Verlustfreie Builddiagnose

`build.ps1` schreibt für jedes Kompilierziel eine eigene Datei:

```text
build/compile-game.log
build/compile-core-tests.log
build/compile-milestone-tests.log
build/compile-diagnostics-tests.log
```

Die Logs enthalten Compilerstdout, Compilerstderr, Ziel, Start-/Endzeit und den
Exitcode. Das Abnahmeskript sichert den vollständigen Kindprozess zusätzlich in
`build/bp001r1-build-child.log`.

Compilerziele entstehen zunächst als partielle Datei und werden erst nach einem
erfolgreichen Compile atomar an ihren endgültigen Namen verschoben. Vor jedem
Zielbuild werden alte Ziel- und Partialdateien entfernt. Damit kann eine alte
`MiniQuake.exe` nicht mehr fälschlich wie das Resultat eines fehlgeschlagenen
Builds erscheinen.

`COLLECT_RESULTS.ps1` sammelt diese Logs automatisch und dokumentiert zusätzlich
explizit, ob Spiel-, Core-, Milestone- und Diagnose-EXE sowie beide DLLs
tatsächlich vorhanden waren. Unterbrochene `*.partial.exe`-Ausgaben werden
separat ausgewiesen, aber nicht in das Ergebnisarchiv kopiert.

## Abgrenzung

BP-001R1 ist ein Buildblocker-Hotfix. Es enthält noch keine Protocol-15-,
QuakeC-, Physik- oder Rendererweiterung. Nach einer vollständig grünen
Windows-Abnahme wird der geplante Black-Port mit `BP-010` fortgesetzt.
