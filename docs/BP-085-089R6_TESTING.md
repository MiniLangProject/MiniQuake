# BP-085–BP-089R6 Windows acceptance

Extract the complete ZIP into a new, empty directory. Do not overlay R5.
Output remains live and is flushed to logs line by line.

```powershell
$QuakeBase = "C:\Users\nilsk\Dropbox\Quake"
$CompilerRoot = "C:\Users\nilsk\Desktop\MiniLang\MiniLangCompilerPy"

Test-Path "$QuakeBase\id1\pak0.pak"
Test-Path "$CompilerRoot\mlc_win64.py"
```

Both checks must return `True`. Then run:

```powershell
.\TEST_BP-085-089R6.ps1 `
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

The diagnostics suite keeps its historical public count and must report:

```text
MiniQuake BP-001R3 diagnostics tests passed: 10
```

Its canonical-stability fixture now also runs the actual QuakeC-to-server
mirror with 96 Edicts, a 512-byte periodic-GC threshold, six full rebuilds and
explicit collections. No message beginning with this text may appear:

```text
SV_SyncQuakeCEdict: edict
```

The R5 savegame corrections must remain green:

```text
save_float_format=4097:4097.000000 negative:-4097.000000
save_float_parse=-0.000000:80000000
first_pass_exact=true
semantic=true
stable_exact=true
stable_semantic=true
result=PASS
```

Most importantly, both main traces must complete and compare exactly:

```text
compatibility trace A: PASS
compatibility trace B: PASS
byte-identical trace comparison: PASS
```

Expected final line:

```text
MiniQuake BP-085-089R6 acceptance test: PASS
```

Collect the result with:

```powershell
.\COLLECT_RESULTS.ps1
```
