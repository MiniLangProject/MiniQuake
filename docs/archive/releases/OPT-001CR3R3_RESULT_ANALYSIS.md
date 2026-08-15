# OPT-001CR3R3 – Analyse des CR3R2-Laufs

Die Paketprüfung bestand vollständig. Der Build scheiterte jedoch vor der MiniLang-Kompilierung mit einer `ParameterBindingValidationException`: Der StdLib-Pfad wurde als Wert des Parameters `Configuration` gebunden, dessen `ValidateSet` nur `Release` oder `Debug` zulässt.

Ursache war das Array-Splatting einer Liste aus vermeintlichen Parameternamen und Werten im verschachtelten PowerShell-Kindprozess. CR3R3 startet `build.ps1` direkt über `powershell.exe -File` und übergibt `-Compiler`, `-StdLib`, `-Configuration`, `-NoRunTests` und `-SkipPreflight` als echte, separate Prozessargumente.

Die Live-Ausgabe bleibt binärsicher und ungepuffert. Die produktiven Inline- und Arrayoptimierungen wurden nicht zurückgenommen.
