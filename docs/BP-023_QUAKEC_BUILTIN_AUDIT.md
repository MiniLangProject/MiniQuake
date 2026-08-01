# BP-023 – Source-guided Audit von `pr_cmds.c`

Der Stock-Build ohne `QUAKE2` besitzt **79** Builtin-Slots. 14 davon sind im
Original absichtlich `PF_Fixme`: `0, 5, 33, 39, 42, 50, 60–66, 71`.
MiniQuake hält Namen, Reihenfolge und Fixme-Slots in einem maschinenlesbaren
Vertrag fest. Der aktuelle Tabellenfingerprint lautet `0xb86a0245`.

Besonders relevant ist `pr_string_temp[128]`: `PF_ftos` und `PF_vtos` liefern
im Original immer denselben Stringzeiger; der nächste Aufruf überschreibt den
vorherigen Inhalt. MiniQuake verwendet dafür den stabilen abstrakten Handle
`0xffffffff` und genau einen kanonischen Latin-1-Bytepuffer.

Die Formatierung folgt `sprintf("%5.1f")` nach der Binary32-Grenze. Dadurch
werden unter anderem diese Fälle festgeschrieben:

- `1.25f -> "  1.2"` (half-even),
- `-1.25f -> " -1.2"`,
- `2.35f -> "  2.3"`, weil der tatsächliche Binary32-Wert unter 2.35 liegt,
- `-0.04f -> " -0.0"`.

Weitere Fixtures prüfen `PF_Find`, `PF_findradius`, Precache-Gates,
`WriteDest`, den einmaligen Changelevel-Pfad, Spawnparameter, `PF_nextent` und
den ersten Wert der MSVC-`rand()`-Sequenz.
