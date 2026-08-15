# BP-066 input-device audit

Compared paths: `in_win.c::IN_ClearStates` and `IN_MouseMove`.
Device-only clear no longer resets gameplay command buttons. Filtered mouse movement averages the first sample with the zero-initialized previous sample, exactly as the C code does.
