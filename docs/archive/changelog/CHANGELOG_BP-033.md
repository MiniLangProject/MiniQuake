# BP-033 – Savegame-v5 byte and load/store parity

- Makes raw Quake one-byte text the authoritative `.sav` file boundary.
- Uses `quake_latin1_cstring_v1` for comments, map names, lightstyles and entity/global text.
- Loads spawn parameters, the legacy skill temporary and saved server time through IEEE-754 binary32, matching `fscanf("%f")`.
- Routes host save/load and save-slot inspection through byte I/O instead of UTF-8 text I/O.
- Adds 24 asset-free runtime fixtures plus a strict C/Python oracle.
