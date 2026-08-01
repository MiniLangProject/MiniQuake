# BP-055 — audio memory and resampling

- aligns RIFF/WAVE parsing and loop metadata with `snd_mem.c`;
- preserves the original source length during resampling;
- applies Binary32 boundaries to scale, output count, loop start and sample stepping;
- rejects malformed, truncated and stereo stock-SFX inputs deterministically;
- adds 20 MiniLang fixtures and an independent C oracle.
