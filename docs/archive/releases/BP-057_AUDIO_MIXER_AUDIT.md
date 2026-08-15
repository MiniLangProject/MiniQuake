# BP-057 audio-mixer audit

Source oracle: `WinQuake/snd_mix.c`. MiniQuake uses signed wrapping 32-bit paint accumulation, original 8/16-bit source paths, clipping and loop-boundary advancement. Twenty-two fixtures cover the deterministic PCM core.
