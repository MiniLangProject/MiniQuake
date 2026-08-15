# BP-060–BP-064R1 – Windows-Abnahme

Das Paket in einen neuen, leeren Ordner entpacken. Die Abnahme zeigt Compiler-,
Preflight- und Testausgaben fortlaufend an und schreibt sie gleichzeitig in `build/`.

```powershell
$QuakeBase = "C:\Users\nilsk\Dropbox\Quake"

.\TEST_BP-060-064R1.ps1 `
  -Compiler C:\Users\nilsk\Desktop\MiniLangCompilerPy\mlc_win64.py `
  -StdLib C:\Users\nilsk\Desktop\MiniLangCompilerPy `
  -QuakeBase $QuakeBase `
  -Game id1 `
  -Map start `
  -Frames 300 `
  -TraceFrames 128 `
  -NetworkTests `
  -ContinueIndependentTests `
  -BisectOnFailure
```

Während des Builds müssen unmittelbar Zeilen wie diese erscheinen:

```text
[MiniQuake] starting single cumulative build and unit-test suite
[MiniQuake/BP-064] static package verification
[MiniQuake] compiling ...
```

Ein längerer Abschnitt ohne neue Ausgabe darf nur noch dann auftreten, wenn der
jeweilige native Kindprozess selbst gerade keine Zeile erzeugt. Der PowerShell-
Wrapper hält keine bereits empfangenen Zeilen zurück.

Nach dem Lauf:

```powershell
.\COLLECT_RESULTS.ps1
```

Das Archiv heißt `MiniQuake_BP-060-064R1_RESULTS_*.zip`.
