# MiniQuake OPT-001CR3R8 – Ergebnisanalyse und OPT-001D-Zielbasis

- Ergebnisarchiv SHA-256: `0b93fc3fca22332ebc369748de713770e16c60df3b818c327f7be20f05cfff8f`
- Gesamtstatus: `FAIL`
- Fehlerzahl: `1`
- Handleklassifikation: `PLATEAU`

## Gemessene Framezeiten

| Map | Modus | Median | P95 | P99 | Näherungs-FPS |
|---|---|---:|---:|---:|---:|
| e1m1 | headless | 15 ms | 16 ms | 16 ms | 66.7 |
| e1m1 | render | 63 ms | 79 ms | 94 ms | 15.9 |
| e1m2 | headless | 16 ms | 32 ms | 47 ms | 62.5 |
| e1m2 | render | 63 ms | 79 ms | 109 ms | 15.9 |

## Einordnung

Der Benutzer beobachtet praktisch ungefähr 13 FPS. Der nächste Stand setzt daher nicht nur weitere kleine Quelltext-Mikrooptimierungen um, sondern reduziert die teuerste bekannte Grenze des MiniLang-Renderpfads: viele einzelne MiniLang→Native→OpenGL-Aufrufe für statische Polygongeometrie.

OPT-001D enthält zusätzlich einen harten 60-FPS-Mediangrenzwert für die sichtbaren Referenzbenchmarks. Die Windows-Laufzeit entscheidet, ob das Ziel bereits vollständig erreicht ist; ein Unterschreiten wird nicht schöngerechnet.
