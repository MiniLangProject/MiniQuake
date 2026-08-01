# BP-045–BP-049R2 Windows-Abnahme

R2 behebt ausschließlich die BP-048-Summary-Fixture und verschärft die
Abnahme gegen versehentlich übersprungene Echtdaten- und Bildgates.

## 1. Paket sauber entpacken

Das ZIP vollständig in einen neuen, leeren Ordner entpacken. Nicht über R1
oder einen älteren MiniQuake-Ordner kopieren.

## 2. Quake-Pfad festlegen

```powershell
$QuakeBase = "C:\Pfad\zu\Quake"
Test-Path "$QuakeBase\id1\pak0.pak"
```

Die zweite Zeile muss `True` ausgeben. `-QuakeBase` bezeichnet den Ordner, der
den Unterordner `id1` enthält, nicht `id1` oder `pak0.pak` selbst.

## 3. Vollständige Abnahme

```powershell
.\TEST_BP-045-049R2.ps1 `
  -Compiler C:\Users\nilsk\Desktop\MiniLangCompilerPy\mlc_win64.py `
  -StdLib C:\Users\nilsk\Desktop\MiniLangCompilerPy `
  -QuakeBase $QuakeBase `
  -Game id1 `
  -Map start `
  -Frames 300 `
  -TraceFrames 128 `
  -RenderEvidenceFrame 128 `
  -NetworkTests `
  -ContinueIndependentTests `
  -BisectOnFailure
```

Die reparierte Gruppe muss melden:

```text
MiniQuake BP-048 render evidence tests passed: 18
```

Anschließend müssen die Echtdaten-Gates wirklich ausgeführt werden:

```text
Validation result: PASS
300 headless frames
two byte-identical 128-frame traces
two byte-identical 640x480 framebuffer captures
render evidence SSIM = 1.0
MiniQuake UDP loopback smoke
  result=PASS
MiniQuake BP-045-049R2 acceptance test: PASS
```

Ein assetfreier Diagnoselauf ist weiterhin möglich, aber nur ausdrücklich:

```powershell
.\TEST_BP-045-049R2.ps1 `
  -Compiler C:\Pfad\mlc_win64.py `
  -StdLib C:\Pfad\MiniLangCompilerPy `
  -SkipGameValidation `
  -SkipTraceValidation `
  -SkipRenderEvidence
```

Ein solcher Lauf ist keine vollständige Blockabnahme.

## 4. Ergebnisarchiv

```powershell
.\COLLECT_RESULTS.ps1
```

Erwarteter Name:

```text
build\MiniQuake_BP-045-049R2_RESULTS_*.zip
```
