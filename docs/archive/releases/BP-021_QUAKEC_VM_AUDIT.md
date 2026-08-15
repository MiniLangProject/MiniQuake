# BP-021 – Source-guided Audit von `pr_exec.c`

Der Audit bindet die 66 Opcodes aus `pr_comp.h` an MiniQuakes
`PR_ExecuteProgram`-Pendant. Besonders geprüft werden diese C-Eigenschaften:

1. `pr_trace` wird am Anfang jeder `PR_ExecuteProgram`-Ausführung gelöscht;
   `traceon` gilt daher nur für die laufende Ausführung.
2. `OP_STATE` schreibt `frame` nur bei einem C-Floatvergleich `!=`. Das erhält
   `-0.0` bei Anforderung von `+0.0` und übernimmt NaN-Payloads wie das Original.
3. QuakeC-Strings sind Bytefolgen; Stringvergleiche verwenden vorzeichenlose
   Latin-1-Bytes statt UTF-8-Codeeinheiten.
4. LOAD-, ADDRESS- und STOREP-Fehler laufen kontrolliert über `PR_RunError`.
5. Funktionsrückgaben kopieren drei 32-Bit-Wörter ab `OFS_RETURN`.
6. Parameter liegen in acht Slots mit je drei Wörtern; der lokale Stack besitzt
   2048 Wörter und der Aufrufstack 32 Einträge.

Das Original kann bei einem beschädigten Pointer außerhalb des Edictspeichers
schreiben. MiniQuake meldet hier absichtlich einen kontrollierten Programmfehler.
Gültige Pointer behalten dieselbe Entity-/Feldadressierung.
