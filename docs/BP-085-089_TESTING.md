# BP-085–BP-089 Windows acceptance

Extract the complete ZIP into a new, empty directory. Output is streamed live
and flushed after every line.

```powershell
$QuakeBase = "C:\Users\nilsk\Dropbox\Quake"
Test-Path "$QuakeBase\id1\pak0.pak"
```

The path check must return `True`.

```powershell
.\TEST_BP-085-089.ps1 `
  -Compiler C:\Users\nilsk\Desktop\MiniLang\MiniLangCompilerPy\mlc_win64.py `
  -StdLib C:\Users\nilsk\Desktop\MiniLang\MiniLangCompilerPy `
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

New runtime markers:

```text
MiniQuake BP-085 game-profile tests passed: 22
MiniQuake BP-086 mod runtime tests passed: 22
MiniQuake BP-087 artifact compatibility tests passed: 24
MiniQuake BP-088 stability tests passed: 20
MiniQuake BP-089 compatibility release closure tests passed: 24
```

When `rogue` or `hipnotic` PAK files exist, the script additionally validates
and runs each installed mission pack. It also executes two retail demo/save
evidence runs, two 5,000-frame soaks, the accepted four-map corpus, exact
framebuffer evidence, two UDP control process pairs and UDP loopback.

Expected final line:

```text
MiniQuake BP-085-089 acceptance test: PASS
```

Then collect the result:

```powershell
.\COLLECT_RESULTS.ps1
```
