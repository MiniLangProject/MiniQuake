# BP-056 audio-DMA audit

Source oracle: `WinQuake/snd_dma.c`. The contract binds channel limits, exact entity/channel replacement, ambient handling, local-sound behavior and Binary32 spatialization. Twenty-two fixtures cover allocation, combining, stopping and volume/pan boundaries.
