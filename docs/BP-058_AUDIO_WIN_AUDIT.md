# BP-058 Win32-audio audit

Source oracle: `WinQuake/snd_win.c`. The x64-safe bridge retains the observable 64×1024-byte waveOut ring, cursor accounting, pre-roll, reset and shutdown semantics. Twenty fixtures cover region identity and lifecycle boundaries.
