# Changelog

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
- a compact build/test/retail-validation script surface, with obsolete delivery
  diffs and historical PowerShell package runners removed; and
- a single zero-argument full-suite entry point that auto-detects Steam retail
  data and covers native builds, all installed official games, all renderer
  backends, retail evidence and independent-process UDP networking; and
- expanded deterministic, differential, retail, and soak validation tooling.

For the current qualification level, see
[`status/PORT_STATUS.md`](status/PORT_STATUS.md). Package-level records are
preserved in [`archive/changelog`](archive/changelog/), while their detailed
test and audit evidence remains in this documentation tree.
