# BP-065–BP-069R1 Windows acceptance

Extract the complete package into a new empty directory. Do not overlay it on
an older MiniQuake tree.

```powershell
$QuakeBase = "C:\Users\nilsk\Dropbox\Quake"
Test-Path "$QuakeBase\id1\pak0.pak"
```

The path check must return `True`.

Run:

```powershell
.\TEST_BP-065-069R1.ps1 `
  -Compiler C:\Users\nilsk\Desktop\MiniLangCompilerPy\mlc_win64.py `
  -StdLib C:\Users\nilsk\Desktop\MiniLangCompilerPy `
  -QuakeBase $QuakeBase `
  -Game id1 `
  -Map start `
  -Frames 300 `
  -TraceFrames 128 `
  -NetworkTests `
  -ContinueIndependentTests `
  -BisectOnFailure
```

Compiler and test output is streamed live and simultaneously written to the
build logs.

The corrected frontend groups must end with:

```text
MiniQuake BP-065 key/focus tests passed: 20
MiniQuake BP-066 input device tests passed: 23
MiniQuake BP-067 console/screen tests passed: 22
MiniQuake BP-068 menu lifecycle tests passed: 24
MiniQuake BP-069 frontend closure tests passed: 24
```

BP-068 specifically binds:

```text
volume bits:      0x3f4ccccd
volume Cvar text: 0.800000
m_pitch bits:     0xbcb43958
m_pitch text:     -0.022000
```

The complete acceptance still requires installed-game validation, 300 headless
frames, two byte-identical 128-frame traces, audio/render evidence, two
Protocol-3 UDP process pairs and UDP loopback.

Expected final line:

```text
MiniQuake BP-065-069R1 acceptance test: PASS
```

After the run:

```powershell
.\COLLECT_RESULTS.ps1
```
