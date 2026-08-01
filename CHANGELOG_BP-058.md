# BP-058 — Win32 waveOut ring lifecycle

- binds 64 headers of 1024 bytes and the 65536-byte secondary ring;
- submits each wave header from its own ring region;
- covers pre-roll, painted/sound time, completed blocks, reset and repeated shutdown;
- retains a one-block convenience path without changing full-ring semantics;
- adds 20 MiniLang fixtures and an independent C oracle.
