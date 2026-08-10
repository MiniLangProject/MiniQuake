# MiniQuake OPT-001CR3R1 – Auswertung des CR3-Laufs

Das Ergebnisarchiv `MiniQuake_OPT-001CR3_RESULTS_20260808-234854.zip` besitzt den SHA-256-Wert `a57053a39cc4cb26a71cf638c2004374007380f89c7f20d525065bc4c4e78af8`.

Der Paketverifier bestand. Der nachfolgende Build endete mit Exitcode 1. Danach versuchte der alte Runner trotz fehlgeschlagenem Build die nicht erzeugte Datei `MiniQuakeOPT001CAllocationTests.exe` zu starten. Das ist ein Folgefehler des Harnesses.

Das Ergebnisarchiv enthält weder `opt001cr3-build.log` noch `compile-*.log`. Daher unterstützt die Evidenz keine seriöse Behauptung, welcher einzelne Compilerfehler den Build stoppte. R1 zieht deshalb eine konservative Grenze:

- die MiniLang-spezifischen Array- und Builderoptimierungen bleiben erhalten;
- die neun Inline-Wrapper, deren Bodies weitere Package-/Native-Helfer aufrufen, werden auf normale Funktionen zurückgestellt;
- nur drei einzeilige, reine, allokationsfreie Funktionen bleiben inline;
- der Build wird über einen separaten Python-Prozess zeilenweise in Konsole und Log weitergereicht;
- nach einem Buildfehler werden alle EXE-abhängigen Tests als `SKIPPED` markiert.

Damit liefert ein weiterer Fehler erstmals die tatsächliche Compilerdiagnose und beschädigt die Zusammenfassung nicht durch Folgefehler.
