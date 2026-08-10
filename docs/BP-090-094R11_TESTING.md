# MiniQuake BP-090–BP-094R11 – Windows-Test

## Vorbereitung

Das Paket in einen neuen, leeren Ordner entpacken. Die Originalreferenz muss
außerhalb des MiniQuake-Projektordners liegen.

```powershell
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

PowerShell für den vollständigen Interoptest als Administrator starten, damit
die temporären, nur auf `127.0.0.1` begrenzten Firewallregeln unbeaufsichtigt
angelegt und entfernt werden können.

## Vollständiger Lauf

```powershell
.\TEST_BP-090-094R11.ps1 `
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

## Neue frühe R11-Gates

Noch vor dem Build muss erscheinen:

```text
[MiniQuake] original reference input resolved:
kind=archive
resolution=explicit
path=...\OriginalQuakeSourceCode.zip
```

Nach dem Build muss das Stagingwerkzeug melden:

```text
source_selector=cli_archive
result=PASS
```

Der Bericht `build\bp090-094r11-original-reference-input.json` muss enthalten:

```text
source_kind=archive
source_exists=true
source_inside_project=false
selector=--archive
selector_count=1
```

Nicht mehr auftreten darf:

```text
usage: prepare_original_reference.py [-h] (--archive ARCHIVE | --exe EXE)
```

## Danach unverändert

```text
Protocol-3-Readiness des Originalservers
Original-GLQuake-Server -> MiniQuake-Client A/B
MiniQuake-Server -> Original-GLQuake-Client A/B
demo1/demo2/demo3 Rohbildvergleich mit SSIM >= 0.95
alle geerbten Runtime-, Artefakt- und Stabilitätsgates
```

Das gewünschte Ende lautet:

```text
MiniQuake BP-090-094R11 acceptance test: PASS
```

Anschließend:

```powershell
.\COLLECT_RESULTS.ps1
```

Der Collector erzeugt:

```text
build\MiniQuake_BP-090-094R11_RESULTS_*.zip
```
