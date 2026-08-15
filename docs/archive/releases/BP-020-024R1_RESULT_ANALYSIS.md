# Auswertung: BP-020–BP-024R1 unter Windows

Ergebnisarchiv: `MiniQuake_BP-020-024R1_RESULTS_20260725-214138.zip`  
SHA-256: `3936e942473029af1cdf2dad784919e45fc34c3ba8b91bdf06f2328f4e7468e1`

## Gesamtergebnis

Von 42 protokollierten Abnahmeschritten bestanden 37. Der vollständige Build
war erfolgreich. Sämtliche bisherigen Core-, Milestone-, Diagnose- und
Protocol-15-Gruppen sowie BP-020, BP-021, BP-023 und BP-024 bestanden ihre
assetfreien Tests.

| Gate | Ergebnis |
|---|---:|
| Vollständiger Build | PASS |
| BASE Core | PASS |
| BASE Milestones | PASS |
| Protocol 15 BP-010R1 bis BP-019 | vollständig PASS |
| BP-020 `progs.dat` | 18/18 PASS |
| BP-021 VM | 16/16 PASS |
| BP-022 Edicts | 21/22; Fehler in `ED_Write` |
| BP-023 Builtins | 22/22 PASS |
| BP-024 Closure | 20/20 PASS |
| Stock-`id1/progs.dat` | FAIL |
| installierte Quake-Datenvalidierung | FAIL bei `progs.dat` |
| Headless-Runtime | FAIL bei `Host_Init` |
| Trace A | 0/128 Frames; Fehler vor Frame 0 |

## Fehler 1: falsche Beziehung zwischen Parametern und Locals

Die konkrete Meldung war:

```text
progs.dat: parameters exceed locals in function SUB_AttackFinished
```

`dfunction_t.locals` beschreibt die Wörter, die beim Betreten einer Funktion
für die spätere Wiederherstellung gesichert werden. Die Parameter werden davon
getrennt nach `parm_start` kopiert. Deshalb kann gültiger qcc-Bytecode Parameter
besitzen, obwohl `locals == 0` ist. Die R1-Regel `parameterWords <= locals` war
somit nicht Teil des QuakeC-ABI und lehnte das originale Stock-Programm ab.

Folgen im R1-Lauf:

- Stock-Gate: FAIL,
- `--validate-game`: FAIL,
- `--validate-runtime`: FAIL,
- deterministischer Trace: Abbruch in `before_filter`, Frame 0 noch nicht
  geschrieben.

## Fehler 2: `ED_Write`-Stringgrenze

Die BP-022-Suite meldete:

```text
[16/22] ED_Write
FAIL: Cannot stringify void for string concatenation
```

Die Feldwertkonvertierung und das Erzeugen der vollständigen Quoted-Pair-Zeile
waren noch zu eng gekoppelt. An einer Runtimegrenze konnte dadurch ein `void`
implizit in eine Stringkonkatenation gelangen. R2 trennt Typkonvertierung,
Validierung und Anhängen des Paars und verwendet denselben Pfad auch für
Globals und Savegames.

## Klassifikation

Beide Fehler gehören zur neuen QuakeC-Schicht. Der bereits eingefrorene
Protocol-15-Unterbau und die bestätigten vorherigen Enginepfade blieben
unverändert grün.
