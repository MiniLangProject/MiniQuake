# BP-090–BP-094R5 Windows test

R5 is intended for unattended execution. All original-binary interoperability traffic is bound to `127.0.0.1`; original visual captures run with UDP and IPX disabled.

Keep `OriginalQuakeSourceCode.zip` outside the MiniQuake project directory.

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

Expected:

```text
True
True
True
False
```

Run:

```powershell
.\TEST_BP-090-094R5.ps1 `
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

The external process reports must show:

```text
network_scope=loopback_only
bind_address=127.0.0.1
firewall_prompt_expected=false
```

The original visual reports must show:

```text
network_scope=disabled
firewall_prompt_expected=false
```

Expected final line:

```text
MiniQuake BP-090-094R5 acceptance test: PASS
```

Collect results:

```powershell
.\COLLECT_RESULTS.ps1
```

## Optional package preflight

Canonical form:

```powershell
python .\tools\verify.py --root .
```

Historical compatible form:

```powershell
python .\tools\verify.py .
```
