# MiniQuake BP-090–BP-094R6 – Windows-Test

## Zweck der R6-Revision

R6 verhindert die während eines unbeaufsichtigten R5-Laufs beobachtete
Windows-Defender-Firewallabfrage. Der Test installiert temporär vier
programmgenaue UDP-Regeln, beschränkt auf `127.0.0.1` in beide Richtungen, und
entfernt sie nach dem Lauf automatisch.

## Administrator/UAC

Der normale Aufruf kann aus einer nicht erhöhten PowerShell erfolgen. Das
Skript fordert dann **sofort vor dem langen Build** Administratorrechte an und
öffnet die erhöhte Testinstanz. Die UAC-Abfrage muss einmal am Anfang bestätigt
werden. Danach kann der Lauf unbeaufsichtigt weiterlaufen.

Alternativ kann PowerShell bereits als Administrator gestartet werden.

Die Option `-SkipTemporaryFirewallRules` ist nur für Systeme gedacht, auf denen
bereits passende lokale Regeln administrativ eingerichtet wurden. Sie gehört
nicht zum empfohlenen Standardlauf.

## Voraussetzungen

```powershell
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

Das Originalarchiv muss außerhalb des MiniQuake-Projektordners liegen.

## Test

```powershell
Get-ChildItem -Recurse -File | Unblock-File

.\TEST_BP-090-094R6.ps1 `
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

Nach Bestätigung der frühen UAC-Abfrage werden die temporären Regeln angelegt.
Der Lauf muss melden:

```text
temporary loopback firewall rules: PASS
rules=4 programs=2 addresses=127.0.0.1/127.0.0.1
```

Für beide Interoprichtungen werden anschließend jeweils zwei Prozesspaare
verlangt. Am Ende muss erscheinen:

```text
MiniQuake BP-090-094R6 acceptance test: PASS
```

Die Regeln werden danach automatisch entfernt. Der Bericht
`build\bp090-094r6-temporary-firewall-rules.json` muss
`cleanup_status=removed` enthalten.

## Ergebnis einsammeln

```powershell
.\COLLECT_RESULTS.ps1
```

Der Collector erzeugt `build\MiniQuake_BP-090-094R6_RESULTS_*.zip`.

## Verifier-Schnelltest

Beide Aufrufformen müssen funktionieren:

```powershell
python .\tools\verify.py --root .
python .\tools\verify.py .
```

The script requests administrator rights at startup. The four temporary rules
are automatically removed in `finally`.
