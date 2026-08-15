# MiniQuake OPT-001CR3R6 – Ergebnisanalyse

- Ergebnisarchiv SHA-256: `472378d77754e41114ab69c3eb82c5b1dcfc40619255b1626367b7adfb2e6d71`
- Gesamtstatus: **INCONCLUSIVE**
- Handleklassifikation: **INCONCLUSIVE**
- Testschritte: **27**
- Fehlgeschlagene/übersprungene Schritte: **3**

## Fehlgeschlagene Schritte
- `listen-server handle plateau`: **DIAGNOSTIC**, Exitcode `3`, Log `opt001cr3r6-handle-plateau.log`
- `OPT-001CR3R6 aggregate analysis`: **DIAGNOSTIC**, Exitcode `2`, Log `opt001cr3r6-aggregate-analysis.log`
- `OPT-001CR3R6 incremental performance comparison`: **DIAGNOSTIC**, Exitcode `2`, Log `opt001cr3r6-incremental-performance.log`

## Übergangstest
- `OPT-001CR3R6 e1m1-e1m2-e1m1 transition`: **PASS**, Exitcode `0`

## Performance- und Audiomessung

| Map | Modus | Median | P95 | P99 | Maximum | Audioanteil | Screenanteil | Serveranteil |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| e1m1 | headless | 15 ms | 16 ms | 16 ms | 32 ms | 0.00% | 0.00% | 96.59% |
| e1m1 | render | 63 ms | 94 ms | 110 ms | 141 ms | 0.00% | 71.89% | 27.29% |
| e1m2 | headless | 16 ms | 32 ms | 47 ms | 47 ms | 0.00% | 0.00% | 97.76% |
| e1m2 | render | 93 ms | 110 ms | 125 ms | 172 ms | 0.00% | 64.15% | 35.08% |

## Einordnung

- Die vom Benutzer wahrgenommene Audio-Störung muss nicht bedeuten, dass der Mixer den größten CPU-Anteil hat. Bei langsamen sichtbaren Frames kann der Hauptthread den WaveOut-Puffer zu spät nachfüllen; das klingt wie ein Audio-Problem, obwohl der Renderer die Ursache der Pufferunterläufe ist.
- CR3R7 erhöht deshalb den standardmäßigen Vorlaufpuffer, stoppt alte Sounds vor dem Kartenwechsel und entfernt weitere kurzlebige Audio-/Renderarrays.
- Der Kartenwechsel erhält dieselbe Sound- und Rendererbereinigung wie der explizite `map`-Pfad.
- Zusätzlich werden stabile Cvarwerte funktionslokal gecacht, kleine reine Funktionen selektiv inlined, stabile `len()`-Abfragen aus Schleifen gezogen und unveränderte Viewleaf-PVS wiederverwendet, sofern der bestehende Rendererzustand dies zulässt.
