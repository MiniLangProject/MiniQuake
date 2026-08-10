# MiniQuake BP-090–BP-094R10 – Windows-Test

## Zweck

R10 schließt die Cold-Start-/Readiness-Lücke beim Start des verifizierten Original-GLQuake-Listenservers. Vor dem vollständigen MiniQuake-Interopclient muss nun eine echte Protocol-3-Serverinfoantwort vom exakten Zielport vorliegen.

## Voraussetzungen

Das MiniQuake-Paket in einen neuen, leeren Ordner entpacken. `OriginalQuakeSourceCode.zip` muss außerhalb des Projektordners liegen.

PowerShell als Administrator starten, damit die temporären, ausschließlich auf Loopback begrenzten Firewallregeln ohne spätere Interaktion eingerichtet und wieder entfernt werden können.

```powershell
Get-Process GLQUAKE, MiniQuake -ErrorAction SilentlyContinue |
  Stop-Process -Force

Get-ChildItem -Recurse -File | Unblock-File

$QuakeBase = "C:\Users\nilsk\Dropbox\Quake"
$CompilerRoot = "C:\Users\nilsk\Desktop\MiniLangCompilerPy"
$OriginalSource = "$env:USERPROFILE\Downloads\OriginalQuakeSourceCode.zip"
```

Prüfen:

```powershell
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

## Vollständiger Lauf

```powershell
.\TEST_BP-090-094R10.ps1 `
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
  -OriginalServerReadyTimeoutMs 180000 `
  -OriginalVisualFrame 256 `
  -NetworkTests `
  -ContinueIndependentTests `
  -BisectOnFailure
```

Die Ausgabe bleibt live und wird gleichzeitig in die jeweiligen Logs geschrieben.

## Neue entscheidende Ausgabe

Vor jedem Originalserver-/MiniQuake-Client-Paar muss zunächst erscheinen:

```text
waiting for original GLQuake server a Protocol-3 readiness ...
original GLQuake server a ready: probes=<N> elapsed_ms=<MS> map=start ... protocol=3
```

Danach erst:

```text
transport=udp
local_server_active=false
local_authoritative=false
demo_playback=false
network_provenance=target_udp
result=PASS
```

Die Readiness-Berichte liegen unter:

```text
build\bp090-094r10-original-server-a-readiness.json
build\bp090-094r10-original-server-b-readiness.json
```

Bei einem erneuten Timeout muss der Bericht Prozessstatus und erkannte UDP-Endpunkte enthalten. Der Fehler wird als `INFRA_FAILURE` klassifiziert.

## Gesamterwartung

```text
Original-GLQuake-Server -> MiniQuake-Client pair A: PASS
Original-GLQuake-Server -> MiniQuake-Client pair B: PASS
MiniQuake-Server -> Original-GLQuake-Client pair A: PASS
MiniQuake-Server -> Original-GLQuake-Client pair B: PASS
```

Danach folgen die drei unveränderten Rohbildvergleiche mit:

```text
SSIM >= 0.95
```

Das gewünschte Ende lautet:

```text
MiniQuake BP-090-094R10 acceptance test: PASS
```

Anschließend:

```powershell
.\COLLECT_RESULTS.ps1
```

Erzeugtes Archiv:

```text
build\MiniQuake_BP-090-094R10_RESULTS_*.zip
```
