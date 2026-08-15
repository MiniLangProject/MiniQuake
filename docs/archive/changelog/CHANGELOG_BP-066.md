# BP-066 — Win32 input-device parity

- Separates original `IN_ClearStates` device clearing from MiniQuake's full deterministic reset.
- Makes the first `m_filter` sample average against the zero-initialized previous sample.
- Keeps command buttons intact during focus/device-only clear operations.
- Adds 22 MiniLang fixtures, a C oracle, golden data and a static checker.
