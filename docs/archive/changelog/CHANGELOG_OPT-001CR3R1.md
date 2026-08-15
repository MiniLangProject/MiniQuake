# MiniQuake OPT-001CR3R1 – Changelog

- Dauerhafte Live-Ausgabe über `tools/run_process_live.py` ohne PowerShell-`Tee-Object`-Pipeline.
- Sofortiges Flushen jeder Kindprozesszeile in Konsole und UTF-8-Log.
- Die letzten 80 Logzeilen werden bei einem Kindprozessfehler nochmals ausgegeben.
- EXE-abhängige Tests werden nach einem Buildfehler als `SKIPPED` markiert.
- Neun riskante Inline-Wrapper mit weiteren Package-/Native-Aufrufen wurden zurückgestellt.
- Drei reine Skalareinzelfunktionen bleiben selektiv inline.
- Alle CR3-Array-, Builder- und Diagnoseallokationsoptimierungen bleiben erhalten.
- Der Hotpath-Compiletest läuft vor dem vollständigen Spielbuild.
