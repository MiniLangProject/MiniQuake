# BP-070 Common/CRC audit

This step covers the observable WinQuake `common.c` and `crc.c` semantics used by the port: numeric conversions, byte-oriented `Q_str*`, path helpers, `COM_Parse`, endian narrowing and the CCITT CRC transition. MiniLang strings are bridged through `quake_latin1_cstring_v1` whenever the original C API operated on raw single-byte strings.
