# MiniQuake BP-001R3 – Deterministische Headless-Eingabeisolierung

Elternpaket: `BP-001R2`

## Anlass

BP-001R2 bestand Build, 16 Core-, 24 Milestone- und 9 Diagnosetests sowie beide
vollständigen 64-Frame-Traceläufe. Der bytegenaue Vergleich fand die erste
Abweichung in Frame 15: Nur Trace A erhielt einen exakt zum originalen
`cl_pitchspeed`-Blicktastenpfad passenden Pitchimpuls.

## Änderungen

### Engine

- `host.shouldPollLiveButtonBindings(...)` zentralisiert die Entscheidung über
  interaktives Win32-Buttonpolling.
- Headless-Sitzungen dürfen keine live abgefragten Tastatur- oder Maustasten
  mehr in `CL_BaseMove` einspeisen.
- Fensterbetrieb bleibt unverändert: Polling erfolgt weiterhin nur im Spiel,
  nicht bei aktiver Konsole oder aktivem Menü.
- `compat_trace` übergibt zusätzlich `-nomouse -nojoy`, damit auch die
  Geräteinitialisierung aus dem deterministischen Referenzpfad entfernt ist.

### Tests und Rückkanal

- Die Diagnosefixtures steigen von 9 auf 10.
- Test 10 deckt Headless-, Fenster-, Menü-, Konsolen- und Nicht-Spiel-Ziele ab.
- Neues Standardbibliothek-freies Werkzeug `tools/compare_traces.py`:
  - bytegenauer Vergleich,
  - SHA-256, Größe und Zeilenzahl,
  - erste abweichende Zeile und Frame,
  - feldweiser Unterschied,
  - JSON-Bericht,
  - eingebauter Selbsttest.
- `TEST_BP-001R3.ps1` sammelt den Vergleich in
  `build/bp001r3-trace-comparison.json` und `.log`.
- `COLLECT_RESULTS.ps1` nimmt diese Dateien automatisch mit.

## Nicht geändert

Keine beabsichtigte Änderung an Protocol 15, QuakeC, Physik, Spielzustand,
Renderer, Mixer, Savegames, Demos oder Netzwerksemantik. BP-010 beginnt erst
nach einer grünen BP-001R3-Doppeltrace-Abnahme.
