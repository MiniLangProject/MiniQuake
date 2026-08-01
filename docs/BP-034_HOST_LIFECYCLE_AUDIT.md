# BP-034 host lifecycle audit

Reference paths: `host.c`, `host_cmd.c`, and `cl_main.c` from WinQuake 1.09.

The frozen contract covers:

- frame-rate gating and accepted host-frame order;
- server-frame order and single-player pause gating;
- map replacement, changelevel and restart semantics;
- demo stop/start interactions;
- savegame-v5 layout and byte boundaries;
- normal disconnect, host error and end-game unwinding;
- server shutdown ordering, including the three-second pending-reliable flush and five-second disconnect broadcast;
- shutdown recursion protection and configuration writing.

A crucial production correction is that lifecycle entry points no longer call `server.shutdown` directly while a server is active. They pass through `Host_ShutdownServer`, preserving reliable-message flushing, final disconnect delivery and client-drop ordering.

Status: `host_lifecycle_109_frozen_v1`  
Fingerprint: `0x8cbb709f`
