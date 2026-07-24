# Originaldatei-Abdeckung

Diese maschinenunterstützte Liste umfasst jede C-/Headerdatei des gepinnten offiziellen `WinQuake`-Baums. `PORTIERT` bedeutet hier, dass die Datei in einer vollständig zugeordneten logischen C/H-Einheit mit bestehendem MiniLang-Pendant liegt. Das ist kein eigenständiger End-to-End-Paritätsnachweis.

Referenz: `bf4ac424ce754894ac8f1dae6a3981954bc9852d` (`ff4a31bc2a3ae18eb8fa5bbca9a9bab90f0d11ab`), 213 Dateien.

## Zusammenfassung

- Ziel-C/H-Einheiten mit MiniLang-Pendant: **63/63**
- Ziel-C-Funktionsdefinitionen mit Codeort: **1069/1069**
- Ziel-Assemblerexporte mit Codeort: **9/9**
- Strikte Funktionsparität steht getrennt in `audit/BEHAVIORAL_PARITY.json` und `docs/BEHAVIORAL_PARITY.md`.

Dateiklassifikation des vollständigen gepinnten Baums:

- **PORTIERT:** 88 Dateien
- **TEILPORTIERT:** 0 Dateien
- **PLATTFORMBRÜCKE:** 10 Dateien
- **OFFEN:** 0 Dateien
- **NICHT ZIELRELEVANT:** 115 Dateien

## Dateien

| Pfad | Originaldatei | Status | MiniQuake / Begründung |
|---|---|---|---|
| `adivtab.h` | `adivtab.h` | NICHT ZIELRELEVANT | vom Win32-GL-Release-Ziel nicht transitiv eingebunden |
| `anorm_dots.h` | `anorm_dots.h` | PORTIERT | logische Einheit alias_tables: src/miniquake/render/alias_normals.ml, src/miniquake/render/alias_mesh.ml |
| `anorms.h` | `anorms.h` | PORTIERT | logische Einheit alias_tables: src/miniquake/render/alias_normals.ml, src/miniquake/render/alias_mesh.ml |
| `asm_draw.h` | `asm_draw.h` | NICHT ZIELRELEVANT | vom Win32-GL-Release-Ziel nicht transitiv eingebunden |
| `asm_i386.h` | `asm_i386.h` | NICHT ZIELRELEVANT | vom Win32-GL-Release-Ziel nicht transitiv eingebunden |
| `block16.h` | `block16.h` | NICHT ZIELRELEVANT | vom Win32-GL-Release-Ziel nicht transitiv eingebunden |
| `block8.h` | `block8.h` | NICHT ZIELRELEVANT | vom Win32-GL-Release-Ziel nicht transitiv eingebunden |
| `bspfile.h` | `bspfile.h` | PORTIERT | logische Einheit bsp_format: src/miniquake/format/bsp.ml, src/miniquake/constants.ml, src/miniquake/types.ml |
| `cd_audio.c` | `cd_audio.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `cd_linux.c` | `cd_linux.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `cd_null.c` | `cd_null.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `cd_win.c` | `cd_win.c` | PORTIERT | logische Einheit cd_audio: src/miniquake/sound/cd_audio.ml, src/miniquake/sound/mixer.ml, src/miniquake/filesystem.ml, src/miniquake/host.ml, src/miniquake/native.ml; physische CD-/MCI-Steuerung ist ausgeschlossen und durch OGG-Streaming ersetzt |
| `cdaudio.h` | `cdaudio.h` | PORTIERT | logische Einheit cd_audio: src/miniquake/sound/cd_audio.ml, src/miniquake/sound/mixer.ml, src/miniquake/filesystem.ml, src/miniquake/host.ml, src/miniquake/native.ml; physische CD-/MCI-Steuerung ist ausgeschlossen und durch OGG-Streaming ersetzt |
| `chase.c` | `chase.c` | PORTIERT | logische Einheit chase: src/miniquake/chase.ml |
| `cl_demo.c` | `cl_demo.c` | PORTIERT | logische Einheit cl_demo: src/miniquake/demo.ml, src/miniquake/demo_player.ml, src/miniquake/client.ml |
| `cl_input.c` | `cl_input.c` | PORTIERT | logische Einheit cl_input: src/miniquake/input.ml, src/miniquake/protocol_write.ml, src/miniquake/client.ml |
| `cl_main.c` | `cl_main.c` | PORTIERT | logische Einheit cl_main: src/miniquake/client.ml, src/miniquake/client_state.ml, src/miniquake/client_protocol.ml, src/miniquake/client_effects.ml, src/miniquake/demo.ml, src/miniquake/demo_player.ml, src/miniquake/input.ml, src/miniquake/protocol_write.ml, src/miniquake/temp_entities.ml, src/miniquake/particles.ml, src/miniquake/types.ml |
| `cl_parse.c` | `cl_parse.c` | PORTIERT | logische Einheit cl_parse: src/miniquake/client_protocol.ml, src/miniquake/client.ml, src/miniquake/client_effects.ml |
| `cl_tent.c` | `cl_tent.c` | PORTIERT | logische Einheit cl_tent: src/miniquake/temp_entities.ml, src/miniquake/client_effects.ml, src/miniquake/particles.ml |
| `client.h` | `client.h` | PORTIERT | logische Einheit cl_main: src/miniquake/client.ml, src/miniquake/client_state.ml, src/miniquake/client_protocol.ml, src/miniquake/client_effects.ml, src/miniquake/demo.ml, src/miniquake/demo_player.ml, src/miniquake/input.ml, src/miniquake/protocol_write.ml, src/miniquake/temp_entities.ml, src/miniquake/particles.ml, src/miniquake/types.ml |
| `cmd.c` | `cmd.c` | PORTIERT | logische Einheit cmd: src/miniquake/cmd.ml, src/miniquake/host.ml |
| `cmd.h` | `cmd.h` | PORTIERT | logische Einheit cmd: src/miniquake/cmd.ml, src/miniquake/host.ml |
| `common.c` | `common.c` | PORTIERT | logische Einheit common: src/miniquake/common.ml, src/miniquake/filesystem.ml, src/miniquake/byteio.ml, src/miniquake/message.ml, src/miniquake/sizebuf.ml, src/miniquake/pak.ml, src/miniquake/launch.ml |
| `common.h` | `common.h` | PORTIERT | logische Einheit common: src/miniquake/common.ml, src/miniquake/filesystem.ml, src/miniquake/byteio.ml, src/miniquake/message.ml, src/miniquake/sizebuf.ml, src/miniquake/pak.ml, src/miniquake/launch.ml |
| `conproc.c` | `conproc.c` | PORTIERT | logische Einheit conproc: src/miniquake/conproc.ml, src/miniquake/platform/win32.ml, src/miniquake/native.ml |
| `conproc.h` | `conproc.h` | PORTIERT | logische Einheit conproc: src/miniquake/conproc.ml, src/miniquake/platform/win32.ml, src/miniquake/native.ml |
| `console.c` | `console.c` | PORTIERT | logische Einheit console: src/miniquake/console.ml, src/miniquake/screen.ml |
| `console.h` | `console.h` | PORTIERT | logische Einheit console: src/miniquake/console.ml, src/miniquake/screen.ml |
| `crc.c` | `crc.c` | PORTIERT | logische Einheit crc: src/miniquake/crc.ml |
| `crc.h` | `crc.h` | PORTIERT | logische Einheit crc: src/miniquake/crc.ml |
| `cvar.c` | `cvar.c` | PORTIERT | logische Einheit cvar: src/miniquake/cvar.ml |
| `cvar.h` | `cvar.h` | PORTIERT | logische Einheit cvar: src/miniquake/cvar.ml |
| `d_edge.c` | `d_edge.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `d_fill.c` | `d_fill.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `d_iface.h` | `d_iface.h` | NICHT ZIELRELEVANT | reine Software-Renderer-Schnittstelle; GLQuake-Zielpfad |
| `d_ifacea.h` | `d_ifacea.h` | NICHT ZIELRELEVANT | vom Win32-GL-Release-Ziel nicht transitiv eingebunden |
| `d_init.c` | `d_init.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `d_local.h` | `d_local.h` | NICHT ZIELRELEVANT | vom Win32-GL-Release-Ziel nicht transitiv eingebunden |
| `d_modech.c` | `d_modech.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `d_part.c` | `d_part.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `d_polyse.c` | `d_polyse.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `d_scan.c` | `d_scan.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `d_sky.c` | `d_sky.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `d_sprite.c` | `d_sprite.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `d_surf.c` | `d_surf.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `d_vars.c` | `d_vars.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `d_zpoint.c` | `d_zpoint.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `dos_v2.c` | `dos_v2.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `dosisms.h` | `dosisms.h` | NICHT ZIELRELEVANT | reine DOS-/Software-Renderer-Schnittstelle; GLQuake-Zielpfad |
| `draw.c` | `draw.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `draw.h` | `draw.h` | PORTIERT | logische Einheit gl_draw: src/miniquake/render/draw2d.ml, src/miniquake/render/gl11.ml, src/miniquake/menu.ml, src/miniquake/statusbar.ml |
| `dxsdk/SDK/INC/D3D.H` | `D3D.H` | NICHT ZIELRELEVANT | mitgelieferter DirectX-SDK-Header; nicht Teil des OpenGL-/Windows-x64-Zielpfads |
| `dxsdk/SDK/INC/D3DCAPS.H` | `D3DCAPS.H` | NICHT ZIELRELEVANT | mitgelieferter DirectX-SDK-Header; nicht Teil des OpenGL-/Windows-x64-Zielpfads |
| `dxsdk/SDK/INC/D3DRM.H` | `D3DRM.H` | NICHT ZIELRELEVANT | mitgelieferter DirectX-SDK-Header; nicht Teil des OpenGL-/Windows-x64-Zielpfads |
| `dxsdk/SDK/INC/D3DRMDEF.H` | `D3DRMDEF.H` | NICHT ZIELRELEVANT | mitgelieferter DirectX-SDK-Header; nicht Teil des OpenGL-/Windows-x64-Zielpfads |
| `dxsdk/SDK/INC/D3DRMOBJ.H` | `D3DRMOBJ.H` | NICHT ZIELRELEVANT | mitgelieferter DirectX-SDK-Header; nicht Teil des OpenGL-/Windows-x64-Zielpfads |
| `dxsdk/SDK/INC/D3DRMWIN.H` | `D3DRMWIN.H` | NICHT ZIELRELEVANT | mitgelieferter DirectX-SDK-Header; nicht Teil des OpenGL-/Windows-x64-Zielpfads |
| `dxsdk/SDK/INC/D3DTYPES.H` | `D3DTYPES.H` | NICHT ZIELRELEVANT | mitgelieferter DirectX-SDK-Header; nicht Teil des OpenGL-/Windows-x64-Zielpfads |
| `dxsdk/SDK/INC/DDRAW.H` | `DDRAW.H` | NICHT ZIELRELEVANT | mitgelieferter DirectX-SDK-Header; nicht Teil des OpenGL-/Windows-x64-Zielpfads |
| `dxsdk/SDK/INC/DINPUT.H` | `DINPUT.H` | NICHT ZIELRELEVANT | mitgelieferter DirectX-SDK-Header; nicht Teil des OpenGL-/Windows-x64-Zielpfads |
| `dxsdk/SDK/INC/DPLAY.H` | `DPLAY.H` | NICHT ZIELRELEVANT | mitgelieferter DirectX-SDK-Header; nicht Teil des OpenGL-/Windows-x64-Zielpfads |
| `dxsdk/SDK/INC/DSETUP.H` | `DSETUP.H` | NICHT ZIELRELEVANT | mitgelieferter DirectX-SDK-Header; nicht Teil des OpenGL-/Windows-x64-Zielpfads |
| `dxsdk/SDK/INC/DSOUND.H` | `DSOUND.H` | NICHT ZIELRELEVANT | mitgelieferter DirectX-SDK-Header; nicht Teil des OpenGL-/Windows-x64-Zielpfads |
| `dxsdk/SDK/INC/FASTFILE.H` | `FASTFILE.H` | NICHT ZIELRELEVANT | mitgelieferter DirectX-SDK-Header; nicht Teil des OpenGL-/Windows-x64-Zielpfads |
| `gas2masm/gas2masm.c` | `gas2masm.c` | NICHT ZIELRELEVANT | historisches Assembler-Konvertierungswerkzeug; nicht Teil der Engine-Laufzeit |
| `gl_draw.c` | `gl_draw.c` | PORTIERT | logische Einheit gl_draw: src/miniquake/render/draw2d.ml, src/miniquake/render/gl11.ml, src/miniquake/menu.ml, src/miniquake/statusbar.ml |
| `gl_mesh.c` | `gl_mesh.c` | PORTIERT | logische Einheit gl_mesh: src/miniquake/render/alias_mesh.ml, src/miniquake/render/entities.ml |
| `gl_model.c` | `gl_model.c` | PORTIERT | logische Einheit gl_model: src/miniquake/format/bsp.ml, src/miniquake/format/mdl.ml, src/miniquake/format/sprite.ml, src/miniquake/model_registry.ml, src/miniquake/world_bsp.ml, src/miniquake/types.ml |
| `gl_model.h` | `gl_model.h` | PORTIERT | logische Einheit gl_model: src/miniquake/format/bsp.ml, src/miniquake/format/mdl.ml, src/miniquake/format/sprite.ml, src/miniquake/model_registry.ml, src/miniquake/world_bsp.ml, src/miniquake/types.ml |
| `gl_refrag.c` | `gl_refrag.c` | PORTIERT | logische Einheit gl_refrag: src/miniquake/render/gl_refrag.ml, src/miniquake/render/original.ml, src/miniquake/render/entities.ml |
| `gl_rlight.c` | `gl_rlight.c` | PORTIERT | logische Einheit gl_rlight: src/miniquake/render/gl_rlight.ml, src/miniquake/render/world.ml |
| `gl_rmain.c` | `gl_rmain.c` | PORTIERT | logische Einheit gl_rmain: src/miniquake/render/gl_rmain.ml, src/miniquake/render/original.ml, src/miniquake/render/alias_mesh.ml, src/miniquake/render/gl_rlight.ml, src/miniquake/render/gl_warp.ml, src/miniquake/render/gl11.ml, src/miniquake/render/draw2d.ml, src/miniquake/render/world.ml, src/miniquake/render/entities.ml, src/miniquake/render/particles.ml, src/miniquake/view.ml, src/miniquake/types.ml |
| `gl_rmisc.c` | `gl_rmisc.c` | PORTIERT | logische Einheit gl_rmisc: src/miniquake/render/gl_rmisc.ml, src/miniquake/render/original.ml, src/miniquake/render/world.ml, src/miniquake/render/entities.ml, src/miniquake/render/particles.ml |
| `gl_rsurf.c` | `gl_rsurf.c` | PORTIERT | logische Einheit gl_rsurf: src/miniquake/render/world.ml |
| `gl_screen.c` | `gl_screen.c` | PORTIERT | logische Einheit gl_screen: src/miniquake/screen.ml, src/miniquake/console.ml, src/miniquake/menu.ml, src/miniquake/statusbar.ml |
| `gl_test.c` | `gl_test.c` | PORTIERT | logische Einheit gl_test: src/miniquake/render/gl_test.ml, src/miniquake/gl_smoke.ml |
| `gl_vidlinux.c` | `gl_vidlinux.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `gl_vidlinuxglx.c` | `gl_vidlinuxglx.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `gl_vidnt.c` | `gl_vidnt.c` | PLATTFORMBRÜCKE | logische Einheit gl_vidnt: src/miniquake/gl_vidnt.ml, src/miniquake/platform/win32.ml, src/miniquake/render/gl11.ml, src/miniquake/native.ml; OS-/ABI-Anteil liegt in der nativen Windows-Brücke |
| `gl_warp.c` | `gl_warp.c` | PORTIERT | logische Einheit gl_warp: src/miniquake/render/gl_warp.ml, src/miniquake/render/world.ml |
| `gl_warp_sin.h` | `gl_warp_sin.h` | PORTIERT | logische Einheit gl_warp: src/miniquake/render/gl_warp.ml, src/miniquake/render/world.ml |
| `glquake.h` | `glquake.h` | PORTIERT | logische Einheit gl_rmain: src/miniquake/render/gl_rmain.ml, src/miniquake/render/original.ml, src/miniquake/render/alias_mesh.ml, src/miniquake/render/gl_rlight.ml, src/miniquake/render/gl_warp.ml, src/miniquake/render/gl11.ml, src/miniquake/render/draw2d.ml, src/miniquake/render/world.ml, src/miniquake/render/entities.ml, src/miniquake/render/particles.ml, src/miniquake/view.ml, src/miniquake/types.ml |
| `glquake2.h` | `glquake2.h` | NICHT ZIELRELEVANT | vom Win32-GL-Release-Ziel nicht transitiv eingebunden |
| `host.c` | `host.c` | PORTIERT | logische Einheit host: src/miniquake/host.ml, src/miniquake/host_timing.ml |
| `host_cmd.c` | `host_cmd.c` | PORTIERT | logische Einheit host_cmd: src/miniquake/host.ml, src/miniquake/savegame.ml, src/miniquake/server.ml |
| `in_dos.c` | `in_dos.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `in_null.c` | `in_null.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `in_sun.c` | `in_sun.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `in_win.c` | `in_win.c` | PLATTFORMBRÜCKE | logische Einheit in_win: src/miniquake/input.ml, src/miniquake/platform/win32.ml, src/miniquake/native.ml; OS-/ABI-Anteil liegt in der nativen Windows-Brücke |
| `input.h` | `input.h` | PLATTFORMBRÜCKE | logische Einheit in_win: src/miniquake/input.ml, src/miniquake/platform/win32.ml, src/miniquake/native.ml; OS-/ABI-Anteil liegt in der nativen Windows-Brücke |
| `keys.c` | `keys.c` | PORTIERT | logische Einheit keys: src/miniquake/keys.ml, src/miniquake/input.ml, src/miniquake/host.ml, src/miniquake/menu.ml, src/miniquake/console.ml |
| `keys.h` | `keys.h` | PORTIERT | logische Einheit keys: src/miniquake/keys.ml, src/miniquake/input.ml, src/miniquake/host.ml, src/miniquake/menu.ml, src/miniquake/console.ml |
| `mathlib.c` | `mathlib.c` | PORTIERT | logische Einheit mathlib: src/miniquake/mathlib.ml |
| `mathlib.h` | `mathlib.h` | PORTIERT | logische Einheit mathlib: src/miniquake/mathlib.ml |
| `menu.c` | `menu.c` | PORTIERT | logische Einheit menu: src/miniquake/menu.ml, src/miniquake/host.ml |
| `menu.h` | `menu.h` | PORTIERT | logische Einheit menu: src/miniquake/menu.ml, src/miniquake/host.ml |
| `model.c` | `model.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `model.h` | `model.h` | PORTIERT | logische Einheit gl_model: src/miniquake/format/bsp.ml, src/miniquake/format/mdl.ml, src/miniquake/format/sprite.ml, src/miniquake/model_registry.ml, src/miniquake/world_bsp.ml, src/miniquake/types.ml |
| `modelgen.h` | `modelgen.h` | PORTIERT | logische Einheit model_format: src/miniquake/format/mdl.ml, src/miniquake/model_registry.ml, src/miniquake/constants.ml, src/miniquake/types.ml |
| `mpdosock.h` | `mpdosock.h` | NICHT ZIELRELEVANT | vom Win32-GL-Release-Ziel nicht transitiv eingebunden |
| `mplib.c` | `mplib.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `mplpc.c` | `mplpc.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `net.h` | `net.h` | PORTIERT | logische Einheit net_main: src/miniquake/net_main.ml, src/miniquake/net_wins.ml, src/miniquake/net_loop.ml, src/miniquake/net_datagram.ml, src/miniquake/net_udp.ml, src/miniquake/net_control.ml, src/miniquake/client.ml, src/miniquake/server.ml |
| `net_bsd.c` | `net_bsd.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `net_bw.c` | `net_bw.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `net_bw.h` | `net_bw.h` | NICHT ZIELRELEVANT | vom Win32-GL-Release-Ziel nicht transitiv eingebunden |
| `net_comx.c` | `net_comx.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `net_dgrm.c` | `net_dgrm.c` | PORTIERT | logische Einheit net_dgrm: src/miniquake/net_loop.ml, src/miniquake/net_datagram.ml, src/miniquake/net_udp.ml, src/miniquake/net_control.ml |
| `net_dgrm.h` | `net_dgrm.h` | PORTIERT | logische Einheit net_dgrm: src/miniquake/net_loop.ml, src/miniquake/net_datagram.ml, src/miniquake/net_udp.ml, src/miniquake/net_control.ml |
| `net_dos.c` | `net_dos.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `net_ipx.c` | `net_ipx.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `net_ipx.h` | `net_ipx.h` | NICHT ZIELRELEVANT | vom Win32-GL-Release-Ziel nicht transitiv eingebunden |
| `net_loop.c` | `net_loop.c` | PORTIERT | logische Einheit net_loop: src/miniquake/net_loop.ml |
| `net_loop.h` | `net_loop.h` | PORTIERT | logische Einheit net_loop: src/miniquake/net_loop.ml |
| `net_main.c` | `net_main.c` | PORTIERT | logische Einheit net_main: src/miniquake/net_main.ml, src/miniquake/net_wins.ml, src/miniquake/net_loop.ml, src/miniquake/net_datagram.ml, src/miniquake/net_udp.ml, src/miniquake/net_control.ml, src/miniquake/client.ml, src/miniquake/server.ml |
| `net_mp.c` | `net_mp.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `net_mp.h` | `net_mp.h` | NICHT ZIELRELEVANT | vom Win32-GL-Release-Ziel nicht transitiv eingebunden |
| `net_none.c` | `net_none.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `net_ser.c` | `net_ser.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `net_ser.h` | `net_ser.h` | NICHT ZIELRELEVANT | Serial-/Modem-Netzwerk ist ausgeschlossen |
| `net_udp.c` | `net_udp.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `net_udp.h` | `net_udp.h` | NICHT ZIELRELEVANT | vom Win32-GL-Release-Ziel nicht transitiv eingebunden |
| `net_vcr.c` | `net_vcr.c` | NICHT ZIELRELEVANT | VCR-Netzwerk ist laut Zieldefinition ausgeschlossen |
| `net_vcr.h` | `net_vcr.h` | NICHT ZIELRELEVANT | VCR-Netzwerk ist ausgeschlossen |
| `net_win.c` | `net_win.c` | PORTIERT | logische Einheit net_win: src/miniquake/net_loop.ml, src/miniquake/net_datagram.ml, src/miniquake/net_udp.ml, src/miniquake/native.ml |
| `net_wins.c` | `net_wins.c` | PLATTFORMBRÜCKE | logische Einheit net_wins: src/miniquake/net_wins.ml, src/miniquake/net_udp.ml, src/miniquake/native.ml; OS-/ABI-Anteil liegt in der nativen Windows-Brücke |
| `net_wins.h` | `net_wins.h` | PLATTFORMBRÜCKE | logische Einheit net_wins: src/miniquake/net_wins.ml, src/miniquake/net_udp.ml, src/miniquake/native.ml; OS-/ABI-Anteil liegt in der nativen Windows-Brücke |
| `net_wipx.c` | `net_wipx.c` | NICHT ZIELRELEVANT | IPX ist laut Zieldefinition ausgeschlossen |
| `net_wipx.h` | `net_wipx.h` | NICHT ZIELRELEVANT | IPX ist ausgeschlossen |
| `net_wso.c` | `net_wso.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `nonintel.c` | `nonintel.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `pr_cmds.c` | `pr_cmds.c` | PORTIERT | logische Einheit pr_cmds: src/miniquake/quakec/builtins.ml |
| `pr_comp.h` | `pr_comp.h` | PORTIERT | logische Einheit quakec_abi: src/miniquake/format/progs.ml, src/miniquake/constants.ml, src/miniquake/quakec/opcodes.ml, src/miniquake/quakec/vm.ml, src/miniquake/quakec/edict.ml, src/miniquake/types.ml |
| `pr_edict.c` | `pr_edict.c` | PORTIERT | logische Einheit pr_edict: src/miniquake/quakec/edict.ml, src/miniquake/savegame.ml, src/miniquake/server.ml |
| `pr_exec.c` | `pr_exec.c` | PORTIERT | logische Einheit pr_exec: src/miniquake/quakec/vm.ml, src/miniquake/quakec/opcodes.ml |
| `progdefs.h` | `progdefs.h` | PORTIERT | logische Einheit quakec_abi: src/miniquake/format/progs.ml, src/miniquake/constants.ml, src/miniquake/quakec/opcodes.ml, src/miniquake/quakec/vm.ml, src/miniquake/quakec/edict.ml, src/miniquake/types.ml |
| `progs.h` | `progs.h` | PORTIERT | logische Einheit quakec_abi: src/miniquake/format/progs.ml, src/miniquake/constants.ml, src/miniquake/quakec/opcodes.ml, src/miniquake/quakec/vm.ml, src/miniquake/quakec/edict.ml, src/miniquake/types.ml |
| `protocol.h` | `protocol.h` | PORTIERT | logische Einheit protocol: src/miniquake/constants.ml, src/miniquake/client_protocol.ml, src/miniquake/protocol_write.ml, src/miniquake/message.ml |
| `quakeasm.h` | `quakeasm.h` | NICHT ZIELRELEVANT | vom Win32-GL-Release-Ziel nicht transitiv eingebunden |
| `quakedef.h` | `quakedef.h` | PORTIERT | logische Einheit quakedef: src/miniquake/types.ml, src/miniquake/constants.ml, src/miniquake/host.ml, src/miniquake/server.ml, src/miniquake/client.ml, src/miniquake/input.ml, src/miniquake/console.ml, src/miniquake/screen.ml, src/miniquake/view.ml, src/miniquake/filesystem.ml, src/miniquake/cvar.ml, src/miniquake/cmd.ml, src/miniquake/memory.ml, src/miniquake/audio.ml |
| `r_aclip.c` | `r_aclip.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `r_alias.c` | `r_alias.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `r_bsp.c` | `r_bsp.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `r_draw.c` | `r_draw.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `r_edge.c` | `r_edge.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `r_efrag.c` | `r_efrag.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `r_light.c` | `r_light.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `r_local.h` | `r_local.h` | NICHT ZIELRELEVANT | reine Software-Renderer-Schnittstelle; GLQuake-Zielpfad |
| `r_main.c` | `r_main.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `r_misc.c` | `r_misc.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `r_part.c` | `r_part.c` | PORTIERT | logische Einheit r_part: src/miniquake/particles.ml, src/miniquake/render/particles.ml |
| `r_shared.h` | `r_shared.h` | NICHT ZIELRELEVANT | reine Software-Renderer-Schnittstelle; GLQuake-Zielpfad |
| `r_sky.c` | `r_sky.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `r_sprite.c` | `r_sprite.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `r_surf.c` | `r_surf.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `r_vars.c` | `r_vars.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `render.h` | `render.h` | PORTIERT | logische Einheit render_types: src/miniquake/types.ml, src/miniquake/render/world.ml, src/miniquake/render/entities.ml |
| `resource.h` | `resource.h` | PORTIERT | logische Einheit resource: src/miniquake/platform/win32.ml |
| `sbar.c` | `sbar.c` | PORTIERT | logische Einheit sbar: src/miniquake/statusbar.ml |
| `sbar.h` | `sbar.h` | PORTIERT | logische Einheit sbar: src/miniquake/statusbar.ml |
| `scitech/INCLUDE/DEBUG.H` | `DEBUG.H` | NICHT ZIELRELEVANT | mitgelieferter SciTech-MGL-Header; nicht Teil des OpenGL-/Windows-x64-Zielpfads |
| `scitech/INCLUDE/MGLDOS.H` | `MGLDOS.H` | NICHT ZIELRELEVANT | mitgelieferter SciTech-MGL-Header; nicht Teil des OpenGL-/Windows-x64-Zielpfads |
| `scitech/INCLUDE/MGLWIN.H` | `MGLWIN.H` | NICHT ZIELRELEVANT | mitgelieferter SciTech-MGL-Header; nicht Teil des OpenGL-/Windows-x64-Zielpfads |
| `scitech/INCLUDE/MGRAPH.H` | `MGRAPH.H` | NICHT ZIELRELEVANT | mitgelieferter SciTech-MGL-Header; nicht Teil des OpenGL-/Windows-x64-Zielpfads |
| `screen.c` | `screen.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `screen.h` | `screen.h` | PORTIERT | logische Einheit gl_screen: src/miniquake/screen.ml, src/miniquake/console.ml, src/miniquake/menu.ml, src/miniquake/statusbar.ml |
| `server.h` | `server.h` | PORTIERT | logische Einheit sv_main: src/miniquake/sv_main.ml, src/miniquake/sv_user.ml, src/miniquake/server.ml, src/miniquake/server_move.ml, src/miniquake/physics.ml, src/miniquake/server_collision.ml, src/miniquake/world.ml, src/miniquake/types.ml |
| `snd_dma.c` | `snd_dma.c` | PORTIERT | logische Einheit snd_dma: src/miniquake/sound/snd_dma.ml, src/miniquake/sound/mixer.ml, src/miniquake/audio.ml, src/miniquake/types.ml |
| `snd_dos.c` | `snd_dos.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `snd_gus.c` | `snd_gus.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `snd_linux.c` | `snd_linux.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `snd_mem.c` | `snd_mem.c` | PORTIERT | logische Einheit snd_mem: src/miniquake/sound/snd_mem.ml, src/miniquake/sound/wav.ml, src/miniquake/sound/mixer.ml |
| `snd_mix.c` | `snd_mix.c` | PORTIERT | logische Einheit snd_mix: src/miniquake/sound/snd_mix.ml, src/miniquake/sound/mixer.ml |
| `snd_next.c` | `snd_next.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `snd_null.c` | `snd_null.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `snd_sun.c` | `snd_sun.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `snd_win.c` | `snd_win.c` | PLATTFORMBRÜCKE | logische Einheit snd_win: src/miniquake/sound/snd_win.ml, src/miniquake/audio.ml, src/miniquake/native.ml; OS-/ABI-Anteil liegt in der nativen Windows-Brücke |
| `sound.h` | `sound.h` | PORTIERT | logische Einheit snd_dma: src/miniquake/sound/snd_dma.ml, src/miniquake/sound/mixer.ml, src/miniquake/audio.ml, src/miniquake/types.ml |
| `spritegn.h` | `spritegn.h` | PORTIERT | logische Einheit sprite_format: src/miniquake/format/sprite.ml, src/miniquake/constants.ml, src/miniquake/types.ml |
| `sv_main.c` | `sv_main.c` | PORTIERT | logische Einheit sv_main: src/miniquake/sv_main.ml, src/miniquake/sv_user.ml, src/miniquake/server.ml, src/miniquake/server_move.ml, src/miniquake/physics.ml, src/miniquake/server_collision.ml, src/miniquake/world.ml, src/miniquake/types.ml |
| `sv_move.c` | `sv_move.c` | PORTIERT | logische Einheit sv_move: src/miniquake/server_move.ml |
| `sv_phys.c` | `sv_phys.c` | PORTIERT | logische Einheit sv_phys: src/miniquake/physics.ml, src/miniquake/server.ml, src/miniquake/server_collision.ml |
| `sv_user.c` | `sv_user.c` | PORTIERT | logische Einheit sv_user: src/miniquake/sv_user.ml, src/miniquake/player_move.ml, src/miniquake/physics.ml, src/miniquake/server.ml |
| `sys.h` | `sys.h` | PLATTFORMBRÜCKE | logische Einheit sys_win: src/miniquake/sys_win.ml, src/miniquake/host.ml, src/miniquake/platform/win32.ml, src/miniquake/native.ml; OS-/ABI-Anteil liegt in der nativen Windows-Brücke |
| `sys_dos.c` | `sys_dos.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `sys_linux.c` | `sys_linux.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `sys_null.c` | `sys_null.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `sys_sun.c` | `sys_sun.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `sys_win.c` | `sys_win.c` | PLATTFORMBRÜCKE | logische Einheit sys_win: src/miniquake/sys_win.ml, src/miniquake/host.ml, src/miniquake/platform/win32.ml, src/miniquake/native.ml; OS-/ABI-Anteil liegt in der nativen Windows-Brücke |
| `sys_wind.c` | `sys_wind.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `vgamodes.h` | `vgamodes.h` | NICHT ZIELRELEVANT | vom Win32-GL-Release-Ziel nicht transitiv eingebunden |
| `vid.h` | `vid.h` | PLATTFORMBRÜCKE | logische Einheit gl_vidnt: src/miniquake/gl_vidnt.ml, src/miniquake/platform/win32.ml, src/miniquake/render/gl11.ml, src/miniquake/native.ml; OS-/ABI-Anteil liegt in der nativen Windows-Brücke |
| `vid_dos.c` | `vid_dos.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `vid_dos.h` | `vid_dos.h` | NICHT ZIELRELEVANT | vom Win32-GL-Release-Ziel nicht transitiv eingebunden |
| `vid_ext.c` | `vid_ext.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `vid_null.c` | `vid_null.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `vid_sunx.c` | `vid_sunx.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `vid_sunxil.c` | `vid_sunxil.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `vid_svgalib.c` | `vid_svgalib.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `vid_vga.c` | `vid_vga.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `vid_win.c` | `vid_win.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `vid_x.c` | `vid_x.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `view.c` | `view.c` | PORTIERT | logische Einheit view: src/miniquake/view.ml |
| `view.h` | `view.h` | PORTIERT | logische Einheit view: src/miniquake/view.ml |
| `vregset.c` | `vregset.c` | NICHT ZIELRELEVANT | von der Win32-GL-Release-Konfiguration nicht gebaut |
| `vregset.h` | `vregset.h` | NICHT ZIELRELEVANT | vom Win32-GL-Release-Ziel nicht transitiv eingebunden |
| `wad.c` | `wad.c` | PORTIERT | logische Einheit wad: src/miniquake/wad.ml |
| `wad.h` | `wad.h` | PORTIERT | logische Einheit wad: src/miniquake/wad.ml |
| `winquake.h` | `winquake.h` | PLATTFORMBRÜCKE | logische Einheit sys_win: src/miniquake/sys_win.ml, src/miniquake/host.ml, src/miniquake/platform/win32.ml, src/miniquake/native.ml; OS-/ABI-Anteil liegt in der nativen Windows-Brücke |
| `world.c` | `world.c` | PORTIERT | logische Einheit world: src/miniquake/world.ml, src/miniquake/server_collision.ml, src/miniquake/world_bsp.ml, src/miniquake/world_hull.ml |
| `world.h` | `world.h` | PORTIERT | logische Einheit world: src/miniquake/world.ml, src/miniquake/server_collision.ml, src/miniquake/world_bsp.ml, src/miniquake/world_hull.ml |
| `zone.c` | `zone.c` | PORTIERT | logische Einheit zone: src/miniquake/memory.ml, src/miniquake/zone.ml, src/miniquake/sizebuf.ml |
| `zone.h` | `zone.h` | PORTIERT | logische Einheit zone: src/miniquake/memory.ml, src/miniquake/zone.ml, src/miniquake/sizebuf.ml |
