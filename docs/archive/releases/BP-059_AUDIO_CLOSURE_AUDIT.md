# BP-059 audio-closure audit

The candidate `audio_109_frozen_v1` contract binds constants and observable behavior across `snd_mem.c`, `snd_dma.c`, `snd_mix.c`, `snd_win.c` and `cd_win.c`. Physical CD hardware is represented by the modern OGG/device backend, while original play/loop/remap/pause/stop and Quake-`atoi` semantics remain authoritative. Two stock retail sounds form the non-bundled evidence gate.
