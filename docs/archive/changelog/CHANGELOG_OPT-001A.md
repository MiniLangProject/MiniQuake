# MiniQuake OPT-001A – Changelog

Parent: `BP-090–BP-094R15`

OPT-001A verändert noch keine Spiel- oder Rendersemantik. Die Lieferung schafft
eine reproduzierbare Diagnose- und Performancebasis für OPT-001B bis OPT-001E.

## Neu

- fester Frameprofiler mit Median, P95, P99 und Maximum;
- Checkpoint-basierte Subsystemzeiten;
- dreiteilige Handle-Plateauanalyse im selben Listen-Server-Prozess;
- Ressourcenmessung alle 100 Frames;
- BSP-, Runtime-, Render- und Trace-Matrix für `e1m1` und `e1m2`;
- JSON-, CSV- und Markdown-Berichte;
- ungepufferte Live-Ausgabe und automatischer Ergebniscollector.

## Bewusst unverändert

- Viewmodel-Depth-Range;
- `faceUnderwater`;
- PVS/BSP-Traversal und Surface-Chains;
- QuakeC-Stack und Kollisionspfad;
- sämtliche Kompatibilitätsfingerprints.
