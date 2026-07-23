# Originaldatei-Abdeckung

Diese maschinenunterstützte Liste umfasst jede C-/Headerdatei des bereitgestellten WinQuake-Baums. Die Einstufung ist bewusst konservativ; `TEILPORTIERT` ist keine 1:1-Abnahme.

## Zusammenfassung

- **NICHT ZIELRELEVANT:** 44 Dateien
- **OFFEN:** 50 Dateien
- **PLATTFORMBRÜCKE:** 3 Dateien
- **PORTIERT:** 11 Dateien
- **TEILPORTIERT:** 87 Dateien

| Originaldatei | Status | MiniQuake-Ziel/Begründung |
|---|---:|---|
| `adivtab.h` | OFFEN | Software-Renderer/Assembler ist im GL-Zielpfad nicht portiert |
| `anorm_dots.h` | OFFEN | Software-Renderer/Assembler ist im GL-Zielpfad nicht portiert |
| `anorms.h` | OFFEN | Software-Renderer/Assembler ist im GL-Zielpfad nicht portiert |
| `asm_draw.h` | OFFEN | Software-Renderer/Assembler ist im GL-Zielpfad nicht portiert |
| `asm_i386.h` | OFFEN | Software-Renderer/Assembler ist im GL-Zielpfad nicht portiert |
| `block16.h` | OFFEN | Software-Renderer/Assembler ist im GL-Zielpfad nicht portiert |
| `block8.h` | OFFEN | Software-Renderer/Assembler ist im GL-Zielpfad nicht portiert |
| `bspfile.h` | PORTIERT | types.ml, format/bsp.ml |
| `cd_audio.c` | OFFEN | CD-/Musiksteuerung fehlt |
| `cd_linux.c` | NICHT ZIELRELEVANT | Windows-x64-Ziel; historischer Fremdplattformpfad |
| `cd_null.c` | NICHT ZIELRELEVANT | Windows-x64-Ziel; historischer Fremdplattformpfad |
| `cd_win.c` | OFFEN | CD-/Musiksteuerung fehlt |
| `cdaudio.h` | OFFEN | CD-/Musiksteuerung fehlt |
| `chase.c` | TEILPORTIERT | chase.ml |
| `cl_demo.c` | TEILPORTIERT | demo.ml, demo_player.ml |
| `cl_input.c` | TEILPORTIERT | input.ml, protocol_write.ml |
| `cl_main.c` | TEILPORTIERT | client.ml, client_state.ml |
| `cl_parse.c` | TEILPORTIERT | client_protocol.ml, client.ml |
| `cl_tent.c` | TEILPORTIERT | temp_entities.ml, particles.ml, client_effects.ml |
| `client.h` | TEILPORTIERT | types.ml, client*.ml |
| `cmd.c` | TEILPORTIERT | cmd.ml, host.ml |
| `cmd.h` | TEILPORTIERT | cmd.ml, host.ml |
| `common.c` | TEILPORTIERT | common.ml, byteio.ml, message.ml, sizebuf.ml, filesystem.ml |
| `common.h` | TEILPORTIERT | common.ml, byteio.ml, message.ml, sizebuf.ml, filesystem.ml |
| `conproc.c` | OFFEN | Dedicated-console IPC fehlt |
| `conproc.h` | OFFEN | Dedicated-console IPC fehlt |
| `console.c` | TEILPORTIERT | console.ml, screen.ml |
| `console.h` | TEILPORTIERT | console.ml, screen.ml |
| `crc.c` | PORTIERT | crc.ml |
| `crc.h` | PORTIERT | crc.ml |
| `cvar.c` | TEILPORTIERT | cvar.ml |
| `cvar.h` | TEILPORTIERT | cvar.ml |
| `d_edge.c` | OFFEN | Software-Renderer/Assembler ist im GL-Zielpfad nicht portiert |
| `d_fill.c` | OFFEN | Software-Renderer/Assembler ist im GL-Zielpfad nicht portiert |
| `d_iface.h` | OFFEN | Software-Renderer/Assembler ist im GL-Zielpfad nicht portiert |
| `d_ifacea.h` | OFFEN | Software-Renderer/Assembler ist im GL-Zielpfad nicht portiert |
| `d_init.c` | OFFEN | Software-Renderer/Assembler ist im GL-Zielpfad nicht portiert |
| `d_local.h` | OFFEN | Software-Renderer/Assembler ist im GL-Zielpfad nicht portiert |
| `d_modech.c` | OFFEN | Software-Renderer/Assembler ist im GL-Zielpfad nicht portiert |
| `d_part.c` | OFFEN | Software-Renderer/Assembler ist im GL-Zielpfad nicht portiert |
| `d_polyse.c` | OFFEN | Software-Renderer/Assembler ist im GL-Zielpfad nicht portiert |
| `d_scan.c` | OFFEN | Software-Renderer/Assembler ist im GL-Zielpfad nicht portiert |
| `d_sky.c` | OFFEN | Software-Renderer/Assembler ist im GL-Zielpfad nicht portiert |
| `d_sprite.c` | OFFEN | Software-Renderer/Assembler ist im GL-Zielpfad nicht portiert |
| `d_surf.c` | OFFEN | Software-Renderer/Assembler ist im GL-Zielpfad nicht portiert |
| `d_vars.c` | OFFEN | Software-Renderer/Assembler ist im GL-Zielpfad nicht portiert |
| `d_zpoint.c` | OFFEN | Software-Renderer/Assembler ist im GL-Zielpfad nicht portiert |
| `dos_v2.c` | NICHT ZIELRELEVANT | Windows-x64-Ziel; historischer Fremdplattformpfad |
| `dosisms.h` | OFFEN | Software-Renderer/Assembler ist im GL-Zielpfad nicht portiert |
| `draw.c` | TEILPORTIERT | render/draw2d.ml |
| `draw.h` | TEILPORTIERT | render/draw2d.ml |
| `gl_draw.c` | TEILPORTIERT | render/world.ml, render/entities.ml, render/draw2d.ml, render/particles.ml, native OpenGL-Bridge |
| `gl_mesh.c` | TEILPORTIERT | render/world.ml, render/entities.ml, render/draw2d.ml, render/particles.ml, native OpenGL-Bridge |
| `gl_model.c` | TEILPORTIERT | render/world.ml, render/entities.ml, render/draw2d.ml, render/particles.ml, native OpenGL-Bridge |
| `gl_model.h` | TEILPORTIERT | render/world.ml, render/entities.ml, render/draw2d.ml, render/particles.ml, native OpenGL-Bridge |
| `gl_refrag.c` | TEILPORTIERT | render/world.ml, render/entities.ml, render/draw2d.ml, render/particles.ml, native OpenGL-Bridge |
| `gl_rlight.c` | TEILPORTIERT | render/world.ml, render/entities.ml, render/draw2d.ml, render/particles.ml, native OpenGL-Bridge |
| `gl_rmain.c` | TEILPORTIERT | render/world.ml, render/entities.ml, render/draw2d.ml, render/particles.ml, native OpenGL-Bridge |
| `gl_rmisc.c` | TEILPORTIERT | render/world.ml, render/entities.ml, render/draw2d.ml, render/particles.ml, native OpenGL-Bridge |
| `gl_rsurf.c` | TEILPORTIERT | render/world.ml, render/entities.ml, render/draw2d.ml, render/particles.ml, native OpenGL-Bridge |
| `gl_screen.c` | TEILPORTIERT | render/world.ml, render/entities.ml, render/draw2d.ml, render/particles.ml, native OpenGL-Bridge |
| `gl_test.c` | TEILPORTIERT | render/world.ml, render/entities.ml, render/draw2d.ml, render/particles.ml, native OpenGL-Bridge |
| `gl_vidlinux.c` | NICHT ZIELRELEVANT | Windows-x64-Ziel; historischer Fremdplattformpfad |
| `gl_vidlinuxglx.c` | NICHT ZIELRELEVANT | Windows-x64-Ziel; historischer Fremdplattformpfad |
| `gl_vidnt.c` | TEILPORTIERT | render/world.ml, render/entities.ml, render/draw2d.ml, render/particles.ml, native OpenGL-Bridge |
| `gl_warp.c` | TEILPORTIERT | render/world.ml, render/entities.ml, render/draw2d.ml, render/particles.ml, native OpenGL-Bridge |
| `gl_warp_sin.h` | TEILPORTIERT | render/world.ml, render/entities.ml, render/draw2d.ml, render/particles.ml, native OpenGL-Bridge |
| `glquake.h` | TEILPORTIERT | render/world.ml, render/entities.ml, render/draw2d.ml, render/particles.ml, native OpenGL-Bridge |
| `glquake2.h` | TEILPORTIERT | render/world.ml, render/entities.ml, render/draw2d.ml, render/particles.ml, native OpenGL-Bridge |
| `host.c` | TEILPORTIERT | host.ml, host_timing.ml |
| `host_cmd.c` | TEILPORTIERT | host.ml |
| `in_dos.c` | NICHT ZIELRELEVANT | Windows-x64-Ziel; historischer Fremdplattformpfad |
| `in_null.c` | NICHT ZIELRELEVANT | Windows-x64-Ziel; historischer Fremdplattformpfad |
| `in_sun.c` | NICHT ZIELRELEVANT | Windows-x64-Ziel; historischer Fremdplattformpfad |
| `in_win.c` | TEILPORTIERT | im Paket-Audit der zugehörigen Subsystemfamilie enthalten |
| `input.h` | TEILPORTIERT | input.ml |
| `keys.c` | TEILPORTIERT | input.ml, host.ml, menu.ml |
| `keys.h` | TEILPORTIERT | input.ml, host.ml, menu.ml |
| `mathlib.c` | PORTIERT | mathlib.ml, native math helpers |
| `mathlib.h` | PORTIERT | mathlib.ml, native math helpers |
| `menu.c` | TEILPORTIERT | menu.ml, host.ml |
| `menu.h` | TEILPORTIERT | menu.ml, host.ml |
| `model.c` | TEILPORTIERT | format/bsp.ml, format/mdl.ml, format/sprite.ml, model_registry.ml |
| `model.h` | TEILPORTIERT | format/bsp.ml, format/mdl.ml, format/sprite.ml, model_registry.ml |
| `modelgen.h` | PORTIERT | types.ml, format/mdl.ml |
| `mpdosock.h` | TEILPORTIERT | im Paket-Audit der zugehörigen Subsystemfamilie enthalten |
| `mplib.c` | NICHT ZIELRELEVANT | Windows-x64-Ziel; historischer Fremdplattformpfad |
| `mplpc.c` | NICHT ZIELRELEVANT | Windows-x64-Ziel; historischer Fremdplattformpfad |
| `net.h` | TEILPORTIERT | types.ml, net_*.ml |
| `net_bsd.c` | NICHT ZIELRELEVANT | Windows-x64-Ziel; historischer Fremdplattformpfad |
| `net_bw.c` | NICHT ZIELRELEVANT | Windows-x64-Ziel; historischer Fremdplattformpfad |
| `net_bw.h` | NICHT ZIELRELEVANT | Windows-x64-Ziel; historischer Fremdplattformpfad |
| `net_comx.c` | NICHT ZIELRELEVANT | Windows-x64-Ziel; historischer Fremdplattformpfad |
| `net_dgrm.c` | TEILPORTIERT | net_datagram.ml |
| `net_dgrm.h` | TEILPORTIERT | net_datagram.ml |
| `net_dos.c` | NICHT ZIELRELEVANT | Windows-x64-Ziel; historischer Fremdplattformpfad |
| `net_ipx.c` | OFFEN | historischer IPX-Pfad fehlt |
| `net_ipx.h` | OFFEN | historischer IPX-Pfad fehlt |
| `net_loop.c` | PORTIERT | net_loop.ml |
| `net_loop.h` | PORTIERT | net_loop.ml |
| `net_main.c` | TEILPORTIERT | host/client/server + net modules |
| `net_mp.c` | NICHT ZIELRELEVANT | Windows-x64-Ziel; historischer Fremdplattformpfad |
| `net_mp.h` | NICHT ZIELRELEVANT | Windows-x64-Ziel; historischer Fremdplattformpfad |
| `net_none.c` | NICHT ZIELRELEVANT | Windows-x64-Ziel; historischer Fremdplattformpfad |
| `net_ser.c` | NICHT ZIELRELEVANT | Windows-x64-Ziel; historischer Fremdplattformpfad |
| `net_ser.h` | NICHT ZIELRELEVANT | Windows-x64-Ziel; historischer Fremdplattformpfad |
| `net_udp.c` | TEILPORTIERT | net_udp.ml + native Winsock |
| `net_udp.h` | TEILPORTIERT | net_udp.ml + native Winsock |
| `net_vcr.c` | OFFEN | VCR-Netzwerkpfad fehlt |
| `net_vcr.h` | OFFEN | VCR-Netzwerkpfad fehlt |
| `net_win.c` | TEILPORTIERT | net_udp.ml + native Winsock |
| `net_wins.c` | TEILPORTIERT | net_udp.ml + native Winsock |
| `net_wins.h` | TEILPORTIERT | net_udp.ml + native Winsock |
| `net_wipx.c` | NICHT ZIELRELEVANT | Windows-x64-Ziel; historischer Fremdplattformpfad |
| `net_wipx.h` | NICHT ZIELRELEVANT | Windows-x64-Ziel; historischer Fremdplattformpfad |
| `net_wso.c` | NICHT ZIELRELEVANT | Windows-x64-Ziel; historischer Fremdplattformpfad |
| `nonintel.c` | NICHT ZIELRELEVANT | Windows-x64-Ziel; historischer Fremdplattformpfad |
| `pr_cmds.c` | TEILPORTIERT | quakec/builtins.ml |
| `pr_comp.h` | TEILPORTIERT | quakec/opcodes.ml, format/progs.ml |
| `pr_edict.c` | TEILPORTIERT | quakec/edict.ml, edict.ml, server.ml |
| `pr_exec.c` | TEILPORTIERT | quakec/vm.ml, quakec/opcodes.ml |
| `progdefs.h` | TEILPORTIERT | constants.ml, types.ml |
| `progs.h` | TEILPORTIERT | format/progs.ml, quakec/vm.ml |
| `protocol.h` | TEILPORTIERT | constants.ml, client_protocol.ml, protocol_write.ml, server.ml |
| `quakeasm.h` | OFFEN | Software-Renderer/Assembler ist im GL-Zielpfad nicht portiert |
| `quakedef.h` | TEILPORTIERT | constants.ml, types.ml |
| `r_aclip.c` | OFFEN | Software-Renderer/Assembler ist im GL-Zielpfad nicht portiert |
| `r_alias.c` | OFFEN | Software-Renderer/Assembler ist im GL-Zielpfad nicht portiert |
| `r_bsp.c` | OFFEN | Software-Renderer/Assembler ist im GL-Zielpfad nicht portiert |
| `r_draw.c` | OFFEN | Software-Renderer/Assembler ist im GL-Zielpfad nicht portiert |
| `r_edge.c` | OFFEN | Software-Renderer/Assembler ist im GL-Zielpfad nicht portiert |
| `r_efrag.c` | OFFEN | Software-Renderer/Assembler ist im GL-Zielpfad nicht portiert |
| `r_light.c` | OFFEN | Software-Renderer/Assembler ist im GL-Zielpfad nicht portiert |
| `r_local.h` | OFFEN | Software-Renderer/Assembler ist im GL-Zielpfad nicht portiert |
| `r_main.c` | OFFEN | Software-Renderer/Assembler ist im GL-Zielpfad nicht portiert |
| `r_misc.c` | OFFEN | Software-Renderer/Assembler ist im GL-Zielpfad nicht portiert |
| `r_part.c` | OFFEN | Software-Renderer/Assembler ist im GL-Zielpfad nicht portiert |
| `r_shared.h` | OFFEN | Software-Renderer/Assembler ist im GL-Zielpfad nicht portiert |
| `r_sky.c` | OFFEN | Software-Renderer/Assembler ist im GL-Zielpfad nicht portiert |
| `r_sprite.c` | OFFEN | Software-Renderer/Assembler ist im GL-Zielpfad nicht portiert |
| `r_surf.c` | OFFEN | Software-Renderer/Assembler ist im GL-Zielpfad nicht portiert |
| `r_vars.c` | OFFEN | Software-Renderer/Assembler ist im GL-Zielpfad nicht portiert |
| `render.h` | TEILPORTIERT | entsprechende MiniLang-Module |
| `resource.h` | TEILPORTIERT | native Windows-Ressourcen werden nicht 1:1 verwendet |
| `sbar.c` | TEILPORTIERT | statusbar.ml |
| `sbar.h` | TEILPORTIERT | statusbar.ml |
| `screen.c` | TEILPORTIERT | screen.ml |
| `screen.h` | TEILPORTIERT | screen.ml |
| `server.h` | TEILPORTIERT | types.ml, server.ml |
| `snd_dma.c` | TEILPORTIERT | sound/mixer.ml, audio.ml |
| `snd_dos.c` | NICHT ZIELRELEVANT | Windows-x64-Ziel; historischer Fremdplattformpfad |
| `snd_gus.c` | NICHT ZIELRELEVANT | Windows-x64-Ziel; historischer Fremdplattformpfad |
| `snd_linux.c` | NICHT ZIELRELEVANT | Windows-x64-Ziel; historischer Fremdplattformpfad |
| `snd_mem.c` | TEILPORTIERT | sound/wav.ml, sound/mixer.ml |
| `snd_mix.c` | TEILPORTIERT | sound/mixer.ml |
| `snd_next.c` | NICHT ZIELRELEVANT | Windows-x64-Ziel; historischer Fremdplattformpfad |
| `snd_null.c` | NICHT ZIELRELEVANT | Windows-x64-Ziel; historischer Fremdplattformpfad |
| `snd_sun.c` | NICHT ZIELRELEVANT | Windows-x64-Ziel; historischer Fremdplattformpfad |
| `snd_win.c` | PLATTFORMBRÜCKE | native waveOut Bridge |
| `sound.h` | TEILPORTIERT | sound/*.ml, audio.ml |
| `spritegn.h` | PORTIERT | types.ml, format/sprite.ml |
| `sv_main.c` | TEILPORTIERT | server.ml |
| `sv_move.c` | TEILPORTIERT | server_move.ml |
| `sv_phys.c` | TEILPORTIERT | physics.ml, server.ml, server_collision.ml |
| `sv_user.c` | TEILPORTIERT | player_move.ml, physics.ml, server.ml |
| `sys.h` | TEILPORTIERT | host.ml, platform/win32.ml |
| `sys_dos.c` | NICHT ZIELRELEVANT | Windows-x64-Ziel; historischer Fremdplattformpfad |
| `sys_linux.c` | NICHT ZIELRELEVANT | Windows-x64-Ziel; historischer Fremdplattformpfad |
| `sys_null.c` | NICHT ZIELRELEVANT | Windows-x64-Ziel; historischer Fremdplattformpfad |
| `sys_sun.c` | NICHT ZIELRELEVANT | Windows-x64-Ziel; historischer Fremdplattformpfad |
| `sys_win.c` | PLATTFORMBRÜCKE | platform/win32.ml, native DLL |
| `sys_wind.c` | PLATTFORMBRÜCKE | platform/win32.ml, native DLL |
| `vgamodes.h` | OFFEN | Software-Renderer/Assembler ist im GL-Zielpfad nicht portiert |
| `vid.h` | TEILPORTIERT | render/gl11.ml, native Bridge |
| `vid_dos.c` | NICHT ZIELRELEVANT | Windows-x64-Ziel; historischer Fremdplattformpfad |
| `vid_dos.h` | NICHT ZIELRELEVANT | Windows-x64-Ziel; historischer Fremdplattformpfad |
| `vid_ext.c` | TEILPORTIERT | native Bridge |
| `vid_null.c` | NICHT ZIELRELEVANT | Windows-x64-Ziel; historischer Fremdplattformpfad |
| `vid_sunx.c` | NICHT ZIELRELEVANT | Windows-x64-Ziel; historischer Fremdplattformpfad |
| `vid_sunxil.c` | NICHT ZIELRELEVANT | Windows-x64-Ziel; historischer Fremdplattformpfad |
| `vid_svgalib.c` | NICHT ZIELRELEVANT | Windows-x64-Ziel; historischer Fremdplattformpfad |
| `vid_vga.c` | NICHT ZIELRELEVANT | Windows-x64-Ziel; historischer Fremdplattformpfad |
| `vid_win.c` | TEILPORTIERT | platform/win32.ml, native Bridge |
| `vid_x.c` | NICHT ZIELRELEVANT | Windows-x64-Ziel; historischer Fremdplattformpfad |
| `view.c` | TEILPORTIERT | view.ml |
| `view.h` | TEILPORTIERT | view.ml |
| `vregset.c` | NICHT ZIELRELEVANT | Windows-x64-Ziel; historischer Fremdplattformpfad |
| `vregset.h` | NICHT ZIELRELEVANT | Windows-x64-Ziel; historischer Fremdplattformpfad |
| `wad.c` | PORTIERT | wad.ml |
| `wad.h` | PORTIERT | wad.ml |
| `winquake.h` | TEILPORTIERT | constants.ml, native Bridge |
| `world.c` | TEILPORTIERT | world_bsp.ml, world_hull.ml, server_collision.ml |
| `world.h` | TEILPORTIERT | world_bsp.ml, world_hull.ml, server_collision.ml |
| `zone.c` | TEILPORTIERT | memory.ml + MiniLang-GC |
| `zone.h` | TEILPORTIERT | memory.ml + MiniLang-GC |
