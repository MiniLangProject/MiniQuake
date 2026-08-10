# MiniQuake BP-090–BP-094R11 – Analyse des R10-Ergebnislaufs

## Ergebnis

Der R10-Lauf hat den vollständigen kumulativen Windows-Build erfolgreich
abgeschlossen:

- 97 MiniLang-Ziele wurden kompiliert.
- Sämtliche internen Unit-, Regression- und BP-090–BP-094-Fixtures bestanden.
- Die Paketidentität `BP-094 / BP-090-094R10` war korrekt.
- Der Lauf brach erst beim Staging der verifizierten Originalreferenz ab.

SHA-256 des Ergebnisarchivs:

```text
5d7f3daa22678c5494427030f93e91ae022118bb53daf162223dc06c73d106d4
```

Die beobachtete Meldung war:

```text
usage: prepare_original_reference.py [-h] (--archive ARCHIVE | --exe EXE)
```

Das Pythonwerkzeug erhielt damit keinen wirksamen Quellselektor. Die eigentliche
Original-Binary-Interop, die R10-Readinessprobe und der visuelle Vergleich
wurden in diesem Lauf nicht erreicht.

## Einordnung

Aus dem Ergebnis lässt sich nicht sicher unterscheiden, ob der Selektor beim
PowerShell-Native-Call, bei einem erhöhten Neustart oder bei einer impliziten
Pfadauflösung verloren ging. Belegt ist nur:

1. Der Harness behandelte eine Originalreferenz als ausgewählt.
2. `prepare_original_reference.py` sah weder `--archive` noch `--exe`.
3. Der Fehler liegt vor jedem Original-GLQuake-Prozess und nicht in MiniQuake.

R11 beseitigt diese Mehrdeutigkeit durch einen redundanten, überprüfbaren
Übergabevertrag.

## R11-Korrektur

Die Originalreferenz wird jetzt **vor UAC-Neustart und langem Build** aufgelöst.

Auflösungsreihenfolge:

1. expliziter Parameter,
2. `MINIQUAKE_ORIGINAL_SOURCE` beziehungsweise `MINIQUAKE_ORIGINAL_EXE`,
3. `%USERPROFILE%\Downloads\OriginalQuakeSourceCode.zip`,
4. Archiv im Elternordner des Projekts.

Eine Datei innerhalb des MiniQuake-Projektbaums bleibt verboten.

Der kanonische Pfad wird:

- in den erhöhten Kindprozess übernommen,
- zusätzlich in einer Environmentvariablen gespiegelt,
- vor dem Build sichtbar ausgegeben,
- vor dem Staging nochmals auf Existenz und Projektgrenze geprüft.

Vor dem Pythonstart baut R11 eine typisierte Argumentliste und verlangt exakt
einen Selektor:

```text
--archive
oder
--exe
```

Der Bericht

```text
build\bp090-094r11-original-reference-input.json
```

dokumentiert Quelle, Auflösungsweg, Selektorzahl und Argumentnamen.

Auch das Pythonwerkzeug besitzt nun einen unabhängigen Environment-Fallback.
Der CLI-Pfad bleibt kanonisch; der Fallback verhindert aber, dass ein erneut
verlorener PowerShell-Selektor den langen Lauf erst nach dem Build beendet.

## Unverändert

R11 verändert keine Datei unter:

```text
src/
native/
```

Die R8-Rendererkorrekturen, R9-Netzwerkprovenienz, R10-Readinessprobe,
temporären Loopback-Firewallregeln und alle Kompatibilitätsfingerprints bleiben
unverändert.
