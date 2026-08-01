# BP-022 – Source-guided Audit von `pr_edict.c`

Der Audit umfasst `ED_Alloc`, `ED_Free`, `ED_ParseEpair`, `ED_ParseEdict`,
`ED_ParseGlobals`, `ED_Write`, `ED_WriteGlobals`, `ED_NewString` und die
Debugkommandos.

Besonders relevant sind die historischen Grenzwerte: Ein Edict darf erst nach
mehr als 0,5 Sekunden wiederverwendet werden, außer sein `freetime` liegt noch
unter zwei Sekunden. Der Vergleich ist strikt. Feldkomponenten mit dem
vorletzten Zeichen `_` werden beim Schreiben übersprungen. Nur String-, Float-
und Entityglobals mit `DEF_SAVEGLOBAL` werden archiviert.

BSP-Entitytext ist wie QuakeC-Stringtabellen Byteinhalt. BP-022 führt ihn daher
nicht mehr durch eine UTF-8-Neuinterpretation.

## BP-024R3: exakter Quake-Byte-Serializer

Der Windows-Lauf von BP-020–BP-024R2 bestätigte Stock-`progs.dat`,
Spielinitialisierung, 300 Headless-Frames, deterministische Traces und alle
übrigen QuakeC-Gruppen. Ausschließlich die synthetische `ED_Write`-Fixture
traf noch eine MiniLang-Stringkonkatenationsgrenze.

BP-024R3 modelliert die `fprintf`-Folge des C-Originals deshalb nicht länger
als wiederholt wachsenden MiniLang-String. `ED_Write`, `ED_WriteGlobals` und
die Savegame-Writer verwenden gemeinsam zwei Durchläufe:

1. Definitionen nach den Originalregeln auswählen und die exakte Bytelänge
   berechnen;
2. einen caller-owned `bytes`-Puffer einmalig befüllen und das fertige
   Dokument anschließend über `quake_latin1_cstring_v1` dekodieren.

Entityfelder mit ausschließlich Nullwörtern werden weiterhin ausgelassen.
`ED_WriteGlobals` schreibt dagegen wie das Original jedes geeignete
`DEF_SAVEGLOBAL`-String-, Float- und Entityglobal – auch bei Nullwerten.
Erweiterte Quake-Einbytezeichen werden unverändert erhalten.
