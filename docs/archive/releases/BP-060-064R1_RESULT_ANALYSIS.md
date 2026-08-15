# BP-060–BP-064: Analyse der scheinbar hängenden Abnahme

Der Akzeptanzrunner startete `build.ps1` mit einer Konstruktion der Form

```powershell
$Lines = @(& $Executable @Arguments 2>&1)
```

PowerShell sammelte dadurch die vollständige Kindprozessausgabe, bevor sie auf der
Konsole ausgegeben wurde. Da der aktuelle kumulative Build zahlreiche Programme
kompiliert und ausführt, blieb die Konsole nach den Kopfzeilen lange unverändert,
obwohl der Kindprozess weiterarbeitete.

R1 ersetzt diese Konstruktion durch eine zeilenweise Pipeline. Jede Zeile wird
sofort angezeigt und gleichzeitig mit explizitem `Flush()` in das Log geschrieben.
Auch die bislang innerhalb von `build.ps1` gepufferten Runtime-Testprogramme wurden
auf denselben Streamingpfad umgestellt. Python erhält zusätzlich
`PYTHONUNBUFFERED=1`.

Es handelt sich um einen Fehler der Testinfrastruktur, nicht um einen Befund zur
Netzwerk-/Plattformimplementierung. Der ursprüngliche Lauf wurde vor einer
verwertbaren Windows-Abnahme abgebrochen.
