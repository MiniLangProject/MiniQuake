# BP-020 – Source-guided Audit von `pr_comp.h` und `PR_LoadProgs`

## Originalreferenzen

- `pr_comp.h`: binäre Strukturen und `PROG_VERSION`.
- `progdefs.h`: `PROGHEADER_CRC` 5927.
- `pr_edict.c:PR_LoadProgs`: Headerprüfung, Byte-Swapping, Voll-Datei-CRC und
  verbotene `DEF_SAVEGLOBAL`-Bits bei Felddefinitionen.
- `sv_main.c:SV_SendServerinfo`: Übertragung des vollständigen `pr_crc`.

## Geschlossene Abweichungen

MiniQuake hatte vorher nur den Headerwert 5927 als Server-CRC übertragen. Der
Originalserver sendet dagegen den CRC16 über die vollständige `progs.dat`.
Außerdem dekodierte der Parser Quake-Stringtabellen versehentlich als UTF-8.
BP-020 trennt beide CRC-Bedeutungen und verwendet die bestehende
`quake_latin1_cstring_v1`-Abbildung für QuakeC-Strings.

## Bewusste sichere Abweichung

Fehlerhafte Abschnittsgrenzen oder Definitionen werden als kontrollierbarer
MiniLang-Fehler gemeldet, statt außerhalb des geladenen Puffers zu lesen. Für
gültige v6-Programme bleibt das beobachtbare Verhalten unverändert.
