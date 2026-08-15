# Changelog

MiniQuake was developed through a large series of source-porting and
optimization packages. The current tree includes:

- broad GLQuake/WinQuake 1.09 source-surface coverage in MiniLang;
- Protocol 15, QuakeC, savegame, demo, physics, client, server, and frontend
  compatibility work;
- OpenGL 1.1, Direct3D 9, and Vulkan renderer backends;
- OGG soundtrack playback using classic Quake CD-track semantics;
- resolution-aware menus, console, HUD, and window/fullscreen controls;
- startup attract demos when `--play` receives only the Quake directory;
- input transition fixes, retail gameplay corrections, and frame-time
  optimizations; and
- expanded deterministic, differential, retail, and soak validation tooling.

For the current qualification level, see
[`status/PORT_STATUS.md`](status/PORT_STATUS.md). Package-level records are
preserved in [`archive/changelog`](archive/changelog/), while their detailed
test and audit evidence remains in this documentation tree.
