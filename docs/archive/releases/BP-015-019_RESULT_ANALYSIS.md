# Auswertung der Windows-Abnahme BP-015–BP-019

## Ergebnis

Die erste kumulative Blockabnahme erreichte den Endstand BP-019 und meldete
exakt eine unabhängige fehlgeschlagene Testgruppe:

```text
ERROR: Independent test groups failed: 1; first=BASE milestone tests
```

Der letzte Meilensteinmarker und die erste Abweichung waren:

```text
[20/24] complete loopback signon
FAIL: server consumes prespawn: expected 1, got 0
```

## Bestätigte Bereiche

- statische Paket-, Manifest-, Import- und ABI-Prüfung: PASS
- alle fünf neuen BP-015- bis BP-019-Checker: PASS
- vollständiger Build aller 14 EXE-Ziele: PASS
- Core-Tests: PASS
- deterministische Diagnosetests: PASS
- Protocol-15-Wire-, Command-, Serverdata-, Event- und Runtime-Event-Tests: PASS
- BP-015 Signonfixtures: 12/12 PASS
- BP-016 Deliveryfixtures: 14/14 PASS
- BP-017 Datagrammfixtures: 18/18 PASS
- BP-018 Demofixtures: 19/19 PASS
- BP-019 Closurefixtures: 15/15 PASS
- Echtdatenvalidierung `id1/start`: PASS
- 300 Headless-Frames: PASS
- zwei unabhängige 128-Frame-Traces: vollständig und byteidentisch
- Trace-SHA-256: `635b830d00997026fab868ab135e66062a367ef2855a103be38d96a7c04a3ddd`
- Rolling Hash: `58a7d245`
- Winsock-UDP-Loopback: PASS

Das hochgeladene Ergebnisarchiv besitzt den SHA-256-Wert:

```text
60cecc48944c8da5faad037f7c1df33fe48ac82a9cabcd7dce52c06a03ba6e8f
```

## Fehlerklasse

**Veraltete Testannahme; kein Produktionsfehler.**

BP-015 änderte die Signonübertragung absichtlich auf die Original-Quake-
Phasengrenze. `CL_SignonReply` schreibt lediglich in `cls.message`; der Versand
erfolgt später aus `CL_SendCmd`. Analog stellen `Host_PreSpawn_f` und
`Host_Spawn_f` Daten in `client_t.message` ein, die erst durch
`SV_SendClientMessages` versendet werden.

Der historische Meilensteintest rief nach dem Parser unmittelbar den jeweils
anderen Endpoint auf und erwartete damit die alte Sofortübertragung. Die neuen,
source-guided BP-015-Fixtures prüften bereits den korrekten Ablauf und bestanden
unter Windows vollständig.

## Reparatur

BP-015–BP-019R1 ändert nur den Meilensteintest und die Abnahme-/Diagnosewerkzeuge.
Die Enginequellen, Protocol-15-Writer, Transportlogik, Goldenwerte und der
Freeze-Fingerprint `0x0cf1e12a` bleiben byteidentisch zur BP-019-Lieferung.
