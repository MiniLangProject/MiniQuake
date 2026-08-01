# MiniQuake BP-020–BP-024 – kumulativer QuakeC-Block

Elternbasis: **BP-015–BP-019R1**, unter Windows vollständig angenommen.
Endstand: **BP-024**.

## BP-020 – `progs.dat`

- bindet `dprograms_t`, `dstatement_t`, `ddef_t` und `dfunction_t` an die Originalgrößen,
- validiert Bereiche, Typen, Funktionsparameter und Opcodegrenzen,
- dekodiert die QuakeC-Stringtabelle als reversible Quake-Einbytezeichen,
- verwendet für Serverinfo den CRC des vollständigen geladenen `progs.dat`.

## BP-021 – VM

- schließt Binary32-, Signed-Zero- und NaN-Randfälle,
- bindet Callstack 32 und Localstack 2048,
- validiert Edict-Pointer und Vektorzugriffe,
- gleicht Stringvergleiche byteweise und `OP_STATE` wortgenau ab,
- setzt Tracezustand pro Programmlauf reproduzierbar zurück.

## BP-022 – Edicts und Save-Text

- erhält Quake-Einbytezeichen in BSP-Entitytext und Epairwerten,
- behandelt `EV_VOID` als ein QuakeC-Wort,
- ergänzt Originaldiagnosen für unbekannte Felder und Globals,
- serialisiert Floats mit sechs Nachkommastellen einschließlich `-0.000000`,
- bindet Savegame-Feldbreiten an dieselbe Typgrößentabelle.

## BP-023 – Builtins

- friert die 79 Stock-Slots und 14 ursprünglichen `PF_Fixme`-Positionen ein,
- bildet den gemeinsamen temporären `pr_string_temp`-Puffer nach,
- gleicht `ftos`, `vtos`, `fabs`, `find`, `changelevel` und den MSVC-`rand()`-Zustand ab,
- ergänzt einen maschinenlesbaren Builtin-Fingerprint.

## BP-024 – QuakeC-Abschluss

- definiert den Status `quakec_109_frozen_v1`,
- bindet Version 6, System-CRC 5927, 66 Opcodes, 79 Builtins, Stack- und Localgrenzen,
- prüft 54 benötigte Globals, 77 Felder und 11 Stock-Einstiegsfunktionen,
- weist Builtinreferenzen außerhalb 1..78 zurück,
- ergänzt einen realen Gate-Test für das benutzereigene `id1/progs.dat`,
- friert den Contract-Fingerprint `0xbc89cbf1` ein.

## Testumfang

- 98 neue assetfreie MiniLang-Fixtures,
- ein zusätzlicher Stock-`progs.dat`-Gate-Test,
- fünf unabhängige C-Oracles plus Pythonmodelle,
- vollständige Regression der bestätigten Protocol-15-Basis,
- Real-Game-, Headless-, Doppeltrace- und UDP-Abnahme.
