# BP-045 alias-model audit

Compared with `gl_mesh.c` and `gl_rmain.c`, BP-045 binds the sixteen shadedot
rows, resets multitexture state before alias/sprite drawing and computes the
projected alias shadow from the entity's world-space origin rather than from a
zero-origin compatibility shortcut. The integrated entity renderer uses the
same corrected path. Twenty-two asset-free fixtures and a strict C oracle bind
the observable calculations.
