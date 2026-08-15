# MiniQuake BP-090--BP-094R3

## External original-server launch correction

- Replaced the invalid `GLQUAKE.EXE -dedicated` BP-091 launch with the original
  GLQuake listen-server path.
- Added a 640x480 windowed WGL context, 32 MiB Quake heap, disabled sound/CD,
  mouse, joystick and IPX, and removed all key bindings before `map start`.
- Kept real UDP Protocol 3/15 traffic for the external MiniQuake client.
- Required a remote `127.0.0.1:<port>` connection log in addition to the
  MiniQuake signon-4 summary.
- Increased original-server startup timeout from 20 to 30 seconds.
- Added exit-code and last-qconsole-line diagnostics for early process exits.
- Added `original_glquake_server_mode` static verification and golden metadata.
- Updated test, collector, package ledger and delivery documentation to R3.

No MiniQuake engine source or native DLL was changed.
