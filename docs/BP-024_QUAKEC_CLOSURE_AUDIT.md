# BP-024 – Abschlussaudit QuakeC 1.09

Der Block BP-020 bis BP-024 bindet die fünf Ebenen des originalen QuakeC-
Subsystems zusammen:

1. `progs.dat`-Format und Runtime-CRC,
2. `PR_ExecuteProgram` und alle 66 Opcodes,
3. Edict-/Global-Text- und Savegame-Semantik,
4. die 79 Stock-Builtins aus `pr_cmds.c`,
5. den gemeinsamen QuakeC-1.09-Vertrag.

## Eingefrorene Werte

| Eigenschaft | Wert |
|---|---:|
| `PROG_VERSION` | 6 |
| `PROGHEADER_CRC` | 5927 |
| Opcodes | 66 |
| Builtin-Slots | 79 |
| absichtliche `PF_Fixme`-Slots | 14 |
| Callstack | 32 |
| Localstack | 2048 Wörter |
| Builtin-Fingerprint | `0xb86a0245` |
| QuakeC-Vertragsfingerprint | `0xbc89cbf1` |
| Status | `quakec_109_frozen_v1` |

Der Stock-Datentest lädt `progs.dat` über MiniQuakes echte PAK-/Dateisystem-
Suche, parst es mit dem Produktionsparser und prüft anschließend Version, CRC,
Builtinreferenzen, generierte Globals/Felder und die elf zentralen
Engine-Einstiegsfunktionen. Das Paket enthält keine Quake-Spieldaten.

Der Freeze bedeutet: Änderungen an VM, Edicts, Builtins oder `progs.dat`-ABI
müssen künftig entweder den unveränderten Vertrag weiter erfüllen oder als
explizite, getestete Kompatibilitätsrevision dokumentiert werden. Ein späterer
Mod-Korpus kann zusätzliche zulässige Definitionen abdecken, ohne die Stock-
Semantik aufzuweichen.
