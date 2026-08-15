# BP-055 audio-memory audit

Source oracle: `WinQuake/snd_mem.c`. The MiniLang path preserves RIFF chunk handling, mono 8/16-bit inputs, loop markers, source-length bounds and Binary32 resampling. Twenty fixtures cover valid and malformed payloads.
