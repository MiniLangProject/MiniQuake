# BP-030 – Host timing and frame clock parity

- Moves the authoritative `Host_FilterTime` decision into `host_timing.ml`.
- Preserves the original `_Host_Frame(float time)` binary32 input boundary.
- Retains double-precision `realtime`/`oldrealtime` accumulation.
- Preserves 72 Hz filtering, timedemo bypass, 1 ms/100 ms clamping and unclamped `host_framerate`.
- Adds 18 MiniLang fixtures and an independent C oracle.
