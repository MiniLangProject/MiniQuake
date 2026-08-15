# BP-090–BP-094R8 Windows test

Das Originalarchiv muss außerhalb des MiniQuake-Projektordners liegen. Starte
PowerShell als Administrator, damit die eng begrenzten temporären
Loopback-Firewallregeln unbeaufsichtigt eingerichtet und wieder entfernt werden.

```powershell
Get-Process GLQUAKE, MiniQuake -ErrorAction SilentlyContinue | Stop-Process -Force
Get-ChildItem -Recurse -File | Unblock-File

$QuakeBase = "C:\Users\nilsk\Dropbox\Quake"
$CompilerRoot = "C:\Users\nilsk\Desktop\MiniLangCompilerPy"
$OriginalSource = "$env:USERPROFILE\Downloads\OriginalQuakeSourceCode.zip"

.\TEST_BP-090-094R8.ps1 `
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

Die Ausgabe bleibt live und ungepuffert. Erwartet werden weiterhin vier grüne
Original-Binary-Interop-Paare. Im visuellen Gate muss für `demo1`, `demo2` und
`demo3` jeweils ein Rohbild ohne Normalisierung mindestens `SSIM 0.95` erreichen.

Wichtige R8-Preflightmarker:

```text
mini_startup_gamma=1
clear_color=1,0,0,0
brush_path=canonical_R_DrawBrushModelForSubmodel
brush_lightmap_blend=GL_ZERO/GL_ONE_MINUS_SRC_COLOR
brush_texture_frame=entity.frame
```

Abschluss:

```text
MiniQuake BP-090-094R8 acceptance test: PASS
```

Danach:

```powershell
.\COLLECT_RESULTS.ps1
```
