# MiniQuake BP-045–BP-049

This cumulative block closes the GLQuake alias/sprite/2D-HUD handoff and adds a
reproducible framebuffer evidence channel.

- BP-045: alias lighting, shadedot rows, entity-origin shadows and texture-unit reset.
- BP-046: sprite synchronization and per-entity random sync bases.
- BP-047: 2D/HUD ordering, statusbar placement, viewmodel depth and TGA layout.
- BP-048: deterministic TGA/JSON capture and exact/SSIM comparison tooling.
- BP-049: frozen model/UI/render contract with fingerprint `0x0a62f5b1`.

The block adds 110 runtime fixtures. It does not yet claim an original-vs-
MiniQuake visual score because no original GLQuake reference images are bundled.
