# BP-020 – QuakeC `progs.dat` ABI und Runtime-CRC

BP-020 beginnt den QuakeC-Kompatibilitätsblock. Der `dprograms_t`-Parser wird
gegen `pr_comp.h`, `progs.h`, `pr_edict.c` und `sv_main.c` gehärtet.

- Benannter `PROGHEADER_CRC = 5927` statt verteilter Literale.
- QuakeC-Strings werden als rohe Quake-Einbytezeichen dekodiert.
- Statements, Definitionen, Funktionsparameter, Speicherbereiche und
  `DEF_SAVEGLOBAL` bei Felddefinitionen werden semantisch geprüft.
- `runtimeCrc(program)` berechnet wie `PR_LoadProgs` den CRC über die vollständige
  `progs.dat`, während `program.crc` weiterhin den ABI-Header-CRC bezeichnet.
- `SV_SendServerinfo` verwendet nun den vollständigen Laufzeit-CRC.
- 18 MiniLang-Fixtures sowie ein unabhängiges C-/Python-Oracle sichern den ABI.
