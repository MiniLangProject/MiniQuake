# BP-013 Windows-Abnahme

## Voraussetzungen

- Windows x64
- Python 3
- MiniLang-Python-Compiler einschließlich `std/`
- eine legale Quake-Installation mit `id1/pak0.pak`

Das BP-013-ZIP muss in einen neuen, vollständig leeren Ordner entpackt werden.
Es darf nicht über ein älteres Paket kopiert werden.

## Vollständiger Test

```powershell
.\TEST_BP-013.ps1 `
  -Compiler C:\Users\nilsk\Desktop\MiniLangCompilerPy\mlc_win64.py `
  -StdLib C:\Users\nilsk\Desktop\MiniLangCompilerPy `
  -QuakeBase "C:\Program Files (x86)\Steam\steamapps\common\Quake" `
  -Game id1 `
  -Map start `
  -Frames 120 `
  -TraceFrames 64 `
  -NetworkTests
```

## Neue BP-013-Gates

Die statische Vorprüfung muss enthalten:

```text
[PASS] protocol15_event_contract
MiniQuake BP-013 Protocol 15 event verification: PASS
```

Der neue MiniLang-Test muss vollständig enden mit:

```text
MiniQuake BP-013 Protocol 15 event tests passed: 22
```

Die 22 Fixtures prüfen:

1. `svc_spawnstatic`-Grundpayload,
2. Bytewrapping statischer Entities,
3. Parser-Roundtrip statischer Entities,
4. `svc_spawnstaticsound`-Vektoren,
5. Parser-Roundtrip statischer Sounds,
6. Partikel-Grundpayload,
7. signed-Char-Klammerung und Bytewrapping,
8. Partikelcount 255 → 1024,
9. direkter `SV_StartParticle`-Pfad,
10. historisches `MAX_DATAGRAM-16`-Gate,
11. integrierter Partikelwriter,
12. Scoreboard-Goldenvektoren,
13. Latin-1-Name und 15-Byte-Begrenzung,
14. integrierte Name-/Farbproduktion,
15. integrierter Frag-Fanout,
16. fractional-frag-Rebroadcast und Binary32-Vergleich,
17. `Host_Spawn_f` mit `old_frags`,
18. Reliable-Verteilung und Overflow,
19. integrierter geordneter Drop,
20. direkter `sv_main`-Drop,
21. blockierter und Crash-Drop,
22. verbleibende Reliable-Planungsgrenzen.

## Vollständige erwartete Regression

```text
MiniQuake core tests passed: 16
MiniQuake milestone tests passed: 24
MiniQuake BP-001R3 diagnostics tests passed: 10
MiniQuake BP-010R1 Protocol 15 wire tests passed: 15
MiniQuake BP-011 Protocol 15 command tests passed: 14
MiniQuake BP-012R1 Protocol 15 server-data tests passed: 17
MiniQuake BP-013 Protocol 15 event tests passed: 22
byte-identical trace comparison: PASS
MiniQuake UDP loopback smoke
  result=PASS
MiniQuake BP-013 acceptance test: PASS
```

Der BP-013-Tracehash darf sich gegenüber BP-012R1 aufgrund der bewusst
geänderten produktiven Nachrichtenpfade ändern. Entscheidend sind zwei
vollständige, untereinander byteidentische BP-013-Traces.

## Ergebnisarchiv

Unabhängig von PASS oder FAIL:

```powershell
.\COLLECT_RESULTS.ps1
```

Das Skript erzeugt ungefähr:

```text
build\MiniQuake_BP-013_RESULTS_20260725-....zip
```

Das Archiv enthält Logs, JSON-Berichte und Traces, aber keine Quake-Spieldaten,
EXE- oder DLL-Dateien. Binärhashes werden nur in `environment.json` erfasst.
