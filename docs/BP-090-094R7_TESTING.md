# MiniQuake BP-090–BP-094R7 – Windows-Test

## Zweck

R7 korrigiert die Originalclient-Portübergabe. Die originale Quake-Konsole darf
nicht mit `connect 127.0.0.1:PORT` gestartet werden: `COM_Parse` trennt den
Doppelpunkt ab und `Host_Connect_f` verwendet nur `Cmd_Argv(1)`. R7 startet das
Original deshalb mit `-port PORT` und führt `connect 127.0.0.1` aus.

Die temporären Windows Defender Firewall-Regeln aus R6 bleiben exakt auf beide
Programme, UDP und `127.0.0.1` beschränkt. Sie werden automatisch entfernt.
PowerShell sollte als Administrator gestartet werden; alternativ erscheint die
UAC-Abfrage sofort vor dem langen Build.

## Vorbereitung

Das Originalarchiv muss außerhalb des MiniQuake-Projektordners liegen.

```powershell
Get-ChildItem -Recurse -File | Unblock-File

$QuakeBase = "C:\Users\nilsk\Dropbox\Quake"
$CompilerRoot = "C:\Users\nilsk\Desktop\MiniLangCompilerPy"
$OriginalSource = "$env:USERPROFILE\Downloads\OriginalQuakeSourceCode.zip"

Test-Path "$QuakeBase\id1\pak0.pak"
Test-Path "$CompilerRoot\mlc_win64.py"
Test-Path $OriginalSource
Test-Path ".\OriginalQuakeSourceCode.zip"
```

Erwartet:

```text
True
True
True
False
```

## Testbefehl

```powershell
.\TEST_BP-090-094R7.ps1 `
  -Compiler "$CompilerRoot\mlc_win64.py" `
  -StdLib $CompilerRoot `
  -QuakeBase $QuakeBase `
  -OriginalQuakeSourceArchive $OriginalSource `
  -Game id1 `
  -Map start `
  -Frames 300 `
  -TraceFrames 128 `
  -BlackPortCorpusFrames 64 `
  -SoakFrames 5000 `
  -ListenSoakFrames 5000 `
  -OriginalInteropFrames 10000 `
  -OriginalVisualFrame 256 `
  -NetworkTests `
  -ContinueIndependentTests `
  -BisectOnFailure
```

Die Ausgabe bleibt live und ungepuffert.

## Entscheidend korrigiertes Gate

```text
starting original GLQuake client a: connect 127.0.0.1 via -port <PORT>
MiniQuake-Server -> Original-GLQuake-Client pair A: PASS
MiniQuake-Server -> Original-GLQuake-Client pair B: PASS
```

Der Prozessbericht muss enthalten:

```text
original_command_parser=COM_Parse_colon_punctuation
connect_token=127.0.0.1
remote_port_source=-port
remote_port=<PORT>
status=PASS
```

Nicht mehr zulässig ist ein Connect-Token der Form:

```text
connect 127.0.0.1:<PORT>
```

## Firewall und unbeaufsichtigter Lauf

Zu Beginn werden vier temporäre Regeln installiert. Die UAC-Abfrage erfolgt nur
unmittelbar am Anfang, sofern PowerShell nicht bereits als Administrator läuft.
Danach ist der Test unattended. Der Abschlussbericht muss zeigen:

```text
setup_status=installed
cleanup_status=removed
local_address=127.0.0.1
remote_address=127.0.0.1
```

## Erwartetes Ende

```text
MiniQuake BP-090-094R7 acceptance test: PASS
```

Danach:

```powershell
.\COLLECT_RESULTS.ps1
```

Der Collector erzeugt `build\MiniQuake_BP-090-094R7_RESULTS_*.zip`.

## Verifier separat prüfen

Beide unterstützten Aufrufformen müssen funktionieren:

```powershell
python .\tools\verify.py --root .
python .\tools\verify.py .
```

Der Test sollte möglichst aus einer bereits als administrator gestarteten PowerShell laufen.
Die einmalige UAC-Abfrage kommt andernfalls vor dem Build. Die temporary Regeln sind auf
Loopback begrenzt und werden nach dem Lauf automatically removed.
