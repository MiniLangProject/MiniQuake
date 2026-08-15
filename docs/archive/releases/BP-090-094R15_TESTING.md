# BP-090–BP-094R15 – Windows-Test

R15 gleicht die Simulationsschrittweite des originalen GLQuake-Captures an MiniQuakes festen Evidence-Schritt von `0.02` Sekunden an. Der Originalprozess erhält dazu exakt `host_framerate 0.02`.

## Voraussetzungen

```powershell
$QuakeBase = "C:\Users\nilsk\Dropbox\Quake"
$CompilerRoot = "C:\Users\nilsk\Desktop\MiniLang\MiniLangCompilerPy"
$OriginalSource = "$env:USERPROFILE\Downloads\OriginalQuakeSourceCode.zip"

Test-Path "$QuakeBase\id1\pak0.pak"
Test-Path "$CompilerRoot\mlc_win64.py"
Test-Path $OriginalSource
Test-Path ".\OriginalQuakeSourceCode.zip"
```

Erwartet: `True`, `True`, `True`, `False`.

## Test

PowerShell als Administrator starten. Das Paket muss flach in einen neuen, leeren MiniQuake-Ordner entpackt sein.

```powershell
Get-Process GLQUAKE, MiniQuake -ErrorAction SilentlyContinue | Stop-Process -Force
Get-ChildItem -Recurse -File | Unblock-File

.\TEST_BP-090-094R15.ps1 `
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

## Entscheidend

Der BP-093-Preflight muss melden:

```text
simulation_timestep=fixed_0.02_seconds
original_host_framerate=0.02 miniquake_frame_step=0.02
```

Die beiden Interoperabilitätsrichtungen müssen grün bleiben. Für `demo1`, `demo2` und `demo3` gilt weiterhin ohne Normalisierung:

```text
reference_min_ssim >= 0.98
candidate worst-reference SSIM >= 0.95
```

Erwartetes Ende:

```text
MiniQuake BP-090-094R15 acceptance test: PASS
```

Danach:

```powershell
.\COLLECT_RESULTS.ps1
```
