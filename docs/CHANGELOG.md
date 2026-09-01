# Changelog

## v2026.09.01

- Migrated safe, non-overlapping MiniLang array transfers to the native
  `copyArray` primitive across synchronized edict storage, render snapshots,
  particles, savegames, sound mixing, console lines, memory tables and other
  fixed-array hot paths.
- Corrected growable-array expansion so only the populated prefix is copied
  into empty enlarged storage instead of duplicating the previous capacity.
- Added regression coverage for prefix and growth copies and refreshed the
  frozen world/physics implementation fingerprint for the reviewed server
  resize path.
- Confirmed deterministic parity with byte-identical 300-frame traces and the
  same final state hash between loop-copy and native-copy builds made with the
  same MiniLangPy compiler revision.
- Measured a conservative paired-median OpenGL improvement of 18% in the
  5,000-frame workload. Headless throughput and map-loading time remained
  neutral within run-to-run noise, so no unsupported general speedup is
  claimed.
- Revalidated all 59 optimization and hot-path checks, the complete source
  inventory and the standard build acceptance matrix before release. The
  separately selectable live network run was not part of this
  compiler-focused measurement pass.

## v2026.08.24

- Made source-manifest verification reproducible across Windows and Unix by
  hashing text with canonical LF line endings while retaining byte-exact binary
  hashes. The manifest now also covers the latest native renderer artifacts.
- Added a production-path regression test for minimized and zero-sized screen
  updates plus numerical enhanced-particle geometry checks, increasing native
  renderer safety coverage from 31 to 35 invariants.
- Added Win32 raw-mouse input and completed the Quake II MD2 rendering path with
  optimized shared pose interpolation plus planar and softened model shadows.
- Corrected enhanced particle sizing so effects retain a compact world-space
  size and become naturally smaller with distance under perspective projection,
  while preserving GLQuake's original distance compensation in classic mode.
- Prevented rendering while the Win32 client area is minimized or transiently
  reports a zero width or height, fixing the `Draw_TransPic: bad coordinates`
  crash during Alt-Tab and fullscreen display suspension.
- Added a second invalid-size guard to loading-plaque and map-transition screen
  updates so automatic level changes remain safe while the game is in the
  background.
- Extended native renderer safety coverage to 31 invariants and compatibility
  diagnostics to 11 cases, including minimized and zero-size window states.
- Revalidated the source manifest, core tests, all three renderer backends and
  a real fullscreen minimize/background transition before publication.

## v2026.08.23

- Rebuilt the Windows x64 release with MiniLangPy compiler revision `d7e143a`,
  retaining the BP-094 package identity and Protocol 15 compatibility profile.
- Added smooth alias-model pose interpolation, renderer-wide anisotropic
  filtering, optional QLIT v1 colored lightmaps, soft enhanced particles and
  smoothly sampled canonical water warp behavior.
- Added an original square MiniQuake application icon, a repository-local
  MiniLang PE resource injector and automatic build-time branding for Explorer,
  Alt-Tab, the taskbar and the game window.
- Revalidated source integrity, native renderer safety, executable identity,
  PE icon resources and retail renderer switching across OpenGL, Direct3D 9
  and Vulkan.
- Published the engine and its required native runtime bridges without any
  proprietary Quake data.

MiniQuake was developed through a large series of source-porting and
optimization packages. The current tree includes:

- broad GLQuake/WinQuake 1.09 source-surface coverage in MiniLang;
- Protocol 15, QuakeC, savegame, demo, physics, client, server, and frontend
  compatibility work;
- OpenGL 1.1, Direct3D 9, and Vulkan renderer backends;
- optional load-time Nearest, ScaleNx, HQ2x, and xBR texture upscaling shared
  by all rendering backends;
- OGG soundtrack playback using classic Quake CD-track semantics;
- resolution-aware menus, console, HUD, and window/fullscreen controls;
- startup attract demos when `--play` receives only the Quake directory;
- input transition fixes, retail gameplay corrections, and frame-time
  optimizations;
- persistent stock cheat state, the `invisible` AI-invisibility command, and
  the `cheats`/`cheatcodes` in-game command reference;
- runtime QuakeC bounds synchronization so dynamically activated large
  entities such as Chthon remain present in Protocol-15 PVS snapshots;
- receiver-surface-aware projected shadows that cannot bridge disconnected
  BSP wall, floor, ledge, or doorway polygons;
- persistent modern free-look, configurable mouse-Y inversion and sensitivity,
  plus a one-time migration from retail keyboard-look bindings to W/A/S/D
  movement;
- measured hot-path refinements for QuakeC vector synchronization and snapshot
  mirrors, byte I/O, input polling and mouse capture, loopback queues, BSP
  visibility traversal, HUD/console/view construction, animated lightstyles,
  and exact-key projected-shadow ray reuse;
- a compact build/test/retail-validation script surface, with obsolete delivery
  diffs and historical PowerShell package runners removed;
- a single zero-argument full-suite entry point that auto-detects Steam retail
  data and covers native builds, all installed official games, all renderer
  backends, retail evidence and independent-process UDP networking; and
- expanded deterministic, differential, retail, and soak validation tooling.

For the current qualification level, see
[`status/PORT_STATUS.md`](status/PORT_STATUS.md). Package-level records are
preserved in [`archive/changelog`](archive/changelog/), while their detailed
test and audit evidence remains in this documentation tree.
