# MiniQuake BP-090--BP-094R3 result analysis

## R2 Windows result

The R2 package completed the full cumulative build and every MiniLang runtime
fixture through BP-094.  The original reference was then extracted and verified
successfully:

- `kit/GLQUAKE.EXE`
- 435,712 bytes
- PE machine `0x014c` / i386
- SHA-256 `04862c835c399bc9184f62101ae0390c2a758c21656ec06dcc0384e0f373d588`

The first external process gate failed while starting the original server.  Its
last console lines were:

```text
SpawnServer: start
Clearing memory
Programs occupy 403K.
PackFile: .../id1/pak0.pak : maps/start.bsp
```

The process exited before the expected `Server spawned.` marker.  MiniQuake's
client had not been started yet.  The uploaded R2 result archive has SHA-256:

```text
b7bd3030a7c27ada2c318452c2d8b85027c2c3ef0589e8ec8d545ed5aa43dd3e
```

## Source-guided cause

The supplied executable is **GLQuake**, not the software WinQuake server.
Using it with `-dedicated` creates a contradictory initialization path. In exact source terms, **Host_Init skips VID_Init** for `ca_dedicated`, while the GL model loader still needs OpenGL during BSP loading.


1. `Host_Init` sees `ca_dedicated` and skips `VID_Init`, so no WGL/OpenGL
   context exists.
2. `SV_SpawnServer` loads `maps/start.bsp` through the GL model loader.
3. `gl_model.c::Mod_LoadTextures` calls `GL_LoadTexture` for BSP textures.
4. `GL_LoadTexture` performs OpenGL texture binding/upload work.

Thus a true dedicated GLQuake process reaches the BSP load without the graphics
context required by its own GL-specific model loader.  The observed exit point
immediately after opening `maps/start.bsp` matches that source path.

This is not a MiniQuake Protocol 3 or Protocol 15 failure.  The test harness
selected an unsuitable launch mode for the verified original binary.

## R3 correction

BP-091 now launches the verified original executable as an original **listen server**:

```text
-listen 4
-window -width 640 -height 480
-heapsize 32768
-nosound -nocdaudio -nojoy -nomouse -noipx
-condebug -port <random-port>
+developer 1 +unbindall +map start
```

The listen-server path initializes WGL before the command-buffered map start,
while the external MiniQuake client still connects over real UDP and completes
the original Protocol 3/Protocol 15 handshake.  The local loopback client is an
expected property of the original listen-server path and does not satisfy the
external-client assertion: the harness separately requires a
`Client 127.0.0.1:<port> connected` line and a complete MiniQuake signon-4
summary.

R3 also records the original process exit code and last `qconsole.log` line if
startup fails again.  The startup deadline is increased from 20 to 30 seconds
to include creation of the original GL window and texture uploads.

## Scope

No MiniQuake engine source or native bridge was changed.  R3 modifies only the
external original-binary harness, its source-guided checker, golden metadata,
collector metadata and documentation.
