# MiniQuake BP-090–BP-094R13 – Windows test

Keep `OriginalQuakeSourceCode.zip` outside the MiniQuake project directory. Run PowerShell as Administrator so temporary loopback-only firewall rules can be created and removed without an unattended prompt.

```powershell
$QuakeBase = "C:\Users\nilsk\Dropbox\Quake"
$CompilerRoot = "C:\Users\nilsk\Desktop\MiniLang\MiniLangCompilerPy"
$OriginalSource = "$env:USERPROFILE\Downloads\OriginalQuakeSourceCode.zip"

.\TEST_BP-090-094R13.ps1 `
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

Before the persistent connect, expect:

```text
MiniQuake original interop pre-fallback connect
  target=127.0.0.1:<port> local_server_active=false
```

No local `map start: Introduction` may occur before that connect. The readiness report must state:

```text
guard_socket_open=true
guard_close_order=after_original_process_stop
```

After the original process stops, expect:

```text
original GLQuake readiness guard <suffix> closed after server stop
```

Final success:

```text
MiniQuake BP-090-094R13 acceptance test: PASS
```
