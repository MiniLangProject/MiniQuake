# MiniQuake OPT-001CR3R8 – Windows-Test

## Zweck

Dieser Zwischenstand kombiniert drei Ziele:

1. realer Kartenwechsel `e1m1 → e1m2` ohne Hänger,
2. robusterer Ton bei langsamen Frames und weniger Audio-Allokationen,
3. zusätzliche risikoarme MiniLang-Hotpath-Optimierungen.

## Voraussetzungen

```powershell
$QuakeBase = "C:\Users\nilsk\Dropbox\Quake"
$CompilerRoot = "C:\Users\nilsk\Desktop\MiniLangCompilerPy"

Test-Path "$QuakeBase\id1\pak0.pak"
Test-Path "$CompilerRoot\mlc_win64.py"
Test-Path .\TEST_OPT-001CR3R8.ps1
Test-Path .\tools\verify.py
```

Alle Prüfungen müssen `True` liefern.

## Lauf

```powershell
.\TEST_OPT-001CR3R8.ps1 `
  -Compiler "$CompilerRoot\mlc_win64.py" `
  -StdLib $CompilerRoot `
  -QuakeBase $QuakeBase `
  -Game id1 `
  -MatrixFrames 64 `
  -WarmupFrames 300 `
  -BenchmarkFrames 3000 `
  -HandleWarmupFrames 1200 `
  -HandleWindowFrames 5000 `
  -HandleWindows 3 `
  -HandleConfirmationWindows 2 `
  -E1M2VisibleFrames 1500 `
  -E1M2HeadlessFrames 10000 `
  -TransitionFrames 256 `
  -ContinueIndependentTests
```

Die Ausgabe wird live auf derselben Konsole angezeigt.

## Wichtige Gates

```text
MiniQuake OPT-001CR3R8 hotpath/transition/audio verification: PASS
e1m1 -> e1m2 -> e1m1 transition: PASS
handle_classification=STABLE oder PLATEAU
MiniQuake OPT-001CR3R8 audio cost analysis: ...
MiniQuake OPT-001CR3R8 acceptance test: PASS
```

## Manuelle Spielprüfung

Nach dem Build:

```powershell
.\build\MiniQuake.exe --play "$QuakeBase" e1m1
```

Der normale Start ist weiterhin fensterbasiert. Bitte bis zum Ausgang von `e1m1` spielen und prüfen:

- Wechsel nach `e1m2` beendet sich ohne dauerhaften Hänger,
- alter Kartenton läuft nicht in die neue Karte hinein,
- Musik/SFX reißen bei sichtbaren Langframes weniger ab,
- Eingabe und Fenster bleiben während und nach dem Kartenwechsel reaktionsfähig.

## Ergebnisse

```powershell
.\COLLECT_RESULTS.ps1
```
