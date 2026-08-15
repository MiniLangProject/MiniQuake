# MiniQuake BP-090–BP-094R12 – Windows test

Use a new, empty extraction directory. Keep `OriginalQuakeSourceCode.zip` outside the project. Run PowerShell as Administrator so the temporary loopback-only firewall rules can be installed and removed without unattended prompts.

```powershell
Get-Process GLQUAKE, MiniQuake -ErrorAction SilentlyContinue | Stop-Process -Force
Get-ChildItem -Recurse -File | Unblock-File

$QuakeBase = "C:\Users\nilsk\Dropbox\Quake"
$CompilerRoot = "C:\Users\nilsk\Desktop\MiniLangCompilerPy"
$OriginalSource = "$env:USERPROFILE\Downloads\OriginalQuakeSourceCode.zip"

.\TEST_BP-090-094R12.ps1 `
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

The first original-server direction must print a persistent connect block similar to:

```text
MiniQuake Protocol-3 persistent connect
  local=127.0.0.1:<ephemeral> target=127.0.0.1:<control>
  request=8000000c015155414b450003 timeout_ms=20000 resend_ms=500
  accepted=true control_port=<control> game_port=<data> ...
```

Then both interop directions, all three visual scenarios and the inherited gates must pass. Final line:

```text
MiniQuake BP-090-094R12 acceptance test: PASS
```
