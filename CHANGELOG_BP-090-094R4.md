# MiniQuake BP-090--BP-094R4

## Original GLQuake modern-driver debug-log compatibility fix

- Removed `-condebug` from every original `GLQUAKE.EXE` GUI launch used by
  BP-091, BP-092 and BP-093.
- The supplied 1997 binary writes `GL_EXTENSIONS` through
  `console.c::Con_DebugLog`, whose fixed 1024-byte buffer is filled with unsafe
  `vsprintf`.  The observed modern NVIDIA extension line was 2580 bytes and
  the process terminated with access violation `0xC0000005` immediately after
  GL initialization.
- Replaced qconsole-based original-server readiness with bounded retries of the
  real MiniQuake Protocol-3/Protocol-15 client.  Acceptance still requires a
  full connected, spawned, signon-4 summary from the verified original server.
- Replaced original-client qconsole assertions with MiniQuake server-side
  Protocol-15 state plus proof that the verified original client process is
  still alive at completed signon.
- Kept original visual evidence bound to the produced TGA screenshot itself;
  no debug log is required.
- Added per-process JSON evidence for original server, client and visual runs,
  including process mode, retry count, evidence source and
  `condebug_enabled=false`.
- Added static checks preventing reintroduction of `-condebug` or qconsole as a
  mandatory external-evidence channel.
- Updated test, collector, audit, checker, ledger and delivery metadata to R4.

No MiniQuake engine source or native DLL was changed.
