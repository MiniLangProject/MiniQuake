# BP-081 cd_win.c audit

Physical MCI tray operations do not exist in the modern OGG-backed audio path.
The four remaining names are represented as technical equivalents that preserve
observable state: media validity, playback, looping, notification result and
failure invalidation. No physical drive operation is claimed.
