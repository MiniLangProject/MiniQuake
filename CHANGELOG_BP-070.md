# BP-070 — Common and CRC parity

- Enforces WinQuake binary32 return semantics for `Q_atof` and signed 32-bit wrapping for `Q_atoi`.
- Corrects `COM_FileBase` one-character names and the original leading-dot behavior in `COM_DefaultExtension`.
- Makes Quake C-string helpers, `COM_Parse`, fixed strings and endian helpers byte-faithful for bytes `0x00..0xff`.
- Adds 24 MiniLang runtime fixtures, an independent C oracle and a static contract checker.
