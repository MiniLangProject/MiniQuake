# OPT-001A – Baselinevertrag

Für `e1m1` und `e1m2` werden BSP-Parse, Headless Runtime Smoke, Render Smoke,
zwei byteidentische Compatibility-Traces sowie Headless- und Renderbenchmarks
ausgeführt.

Standardbenchmark:

- 300 Warm-up-Frames;
- 3000 Messframes;
- fester Simulationsschritt 0,02 s;
- Median, P95, P99 und Maximum;
- Host-Checkpoint-Zeiten;
- Heap- und Prozessressourcen vor und nach der Messung.

Listen-Server-Stabilität:

- 1200 Warm-up-Frames;
- drei Fenster mit je 5000 Frames;
- Probe alle 100 Frames;
- Klassifikation STABLE, PLATEAU, LEAK, RESOURCE_GROWTH oder INCONCLUSIVE.

OPT-001A ist diagnostisch. Korrektheits- und Performanceänderungen beginnen in
OPT-001B.
