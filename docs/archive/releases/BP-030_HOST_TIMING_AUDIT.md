# BP-030 Host timing audit

Reference: `host.c::Host_FilterTime` and `_Host_Frame` from WinQuake 1.09.

The platform delta is rounded at the original C `float` argument boundary, while
`realtime`, `oldrealtime` and `host_frametime` remain double precision. Rejected
frames advance `realtime` but not `oldrealtime`; accepted frames clamp only when
`host_framerate` is zero. Timedemo skips the 72 Hz gate.
