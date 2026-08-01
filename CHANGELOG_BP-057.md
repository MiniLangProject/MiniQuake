# BP-057 — signed software mixer

- models the WinQuake paintbuffer as signed wrapping 32-bit accumulators;
- covers 8/16-bit source widths and mono/stereo output;
- preserves loop-boundary and channel-position semantics;
- applies clipping and transfer scaling in the original order;
- adds 22 MiniLang fixtures and an independent C oracle.
