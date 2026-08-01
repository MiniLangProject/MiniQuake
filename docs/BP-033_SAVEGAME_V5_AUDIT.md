# BP-033 savegame-v5 audit

Reference paths: `host_cmd.c::Host_Savegame_f`, `Host_Loadgame_f`, `Host_SavegameComment`, and `pr_edict.c::ED_Write*`.

The WinQuake v5 format is a byte-oriented line stream:

1. version `5`
2. fixed 39-byte comment
3. 16 `%f` spawn parameters
4. legacy float-compatible skill line
5. map name
6. `%f` server time
7. 64 lightstyle lines
8. global block
9. one block per edict

MiniQuake now writes and reads this stream through `bytes`, using the same reversible U+0000..U+00FF mapping as Protocol 15. This avoids UTF-8 expansion of bytes `0x80..0xff`. Numeric values read by original `fscanf("%f")` pass through a binary32 boundary before use.

Safety deviations remain deliberate: path traversal and directory separators are rejected, malformed files return controlled errors, and the fixed comment copy is bounded rather than reproducing the original unchecked `memcpy`.
