# BP-085–BP-089R8 Windows acceptance

Extract the ZIP into a new, empty directory. Output is streamed live.

```powershell
$QuakeBase = "C:\Users\nilsk\Dropbox\Quake"
$CompilerRoot = "C:\Users\nilsk\Desktop\MiniLang\MiniLangCompilerPy"

Test-Path "$QuakeBase\id1\pak0.pak"
Test-Path "$CompilerRoot\mlc_win64.py"

.\TEST_BP-085-089R8.ps1 `
  -Compiler "$CompilerRoot\mlc_win64.py" `
  -StdLib $CompilerRoot `
  -QuakeBase $QuakeBase `
  -Game id1 `
  -Map start `
  -Frames 300 `
  -TraceFrames 128 `
  -BlackPortCorpusFrames 64 `
  -SoakFrames 5000 `
  -ListenSoakFrames 5000 `
  -NetworkTests `
  -ContinueIndependentTests `
  -BisectOnFailure
```

Critical R8 listen-soak output:

```text
client entities: 66 -> 67 (max 67)
client entity high-water limit=67
stability gates: heap=true server_edicts=true client_entities=true ...
result=PASS
```

The exact start value may differ on another valid asset set, but the final
client table must remain within the printed derived limit.

All Savegame, trace, black-port corpus, render, audio and network gates must
remain green. The final line is:

```text
MiniQuake BP-085-089R8 acceptance test: PASS
```

After the run:

```powershell
.\COLLECT_RESULTS.ps1
```
