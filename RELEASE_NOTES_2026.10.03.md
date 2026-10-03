# MiniQuake v2026.10.03 (Windows x64)

This Windows release rebuilds the existing BP-094 engine with MiniLang Compiler
1.2.16. The game source is unchanged. The native OpenGL, Direct3D 9, Vulkan,
audio, and text bridges are included with the EXE.

In a local E1M1 OpenGL 640×480 measurement, 500 active frames yielded 407 FPS
with Compiler 1.2.3 and 513 FPS with 1.2.16 (median of two runs per version).
The EXE became about 21% smaller. These values describe this one scene and
machine, not every game configuration.

The package does not contain Quake game data. Supply a legal installation with
`id1/pak0.pak`. The Linux x86-64 package remains available from v2026.09.04.
