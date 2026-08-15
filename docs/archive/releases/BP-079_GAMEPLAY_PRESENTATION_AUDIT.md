# BP-079 gameplay/presentation audit

Reference units: `host_cmd.c`, `common.c` plus the accepted BP-075–BP-078 surfaces.

`color`, `give` and `viewframe` use C runtime `atoi` conversion. `edict` preserves the original Quake `Q_atoi` parser, including hexadecimal and character-literal syntax. Hash-prefixed player indexes preserve the original `Q_atof` then C-int truncation sequence. The compatible conversions are shared by the integrated host and server command paths.
