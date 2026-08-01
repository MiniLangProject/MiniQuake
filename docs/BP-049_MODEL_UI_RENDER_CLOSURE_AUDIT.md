# BP-049 model/UI/render closure audit

BP-049 freezes the alias, sprite, 2D/HUD and framebuffer-evidence decisions on
top of the accepted client and world render contracts.

```text
status      = model_ui_render_109_frozen_v1
fingerprint = 0x0a62f5b1
```

The contract binds sixteen alias shadedot rows, two sprite sync modes, entity-
origin shadows, multitexture reset, eleven normal overlay stages, 0.3
viewmodel depth, 24-bit TGA evidence, a 16×16 sample grid, an intended visual
acceptance floor of SSIM 0.95 and the 256-visible-entity limit. Twenty-four
closure fixtures and an independent C oracle bind these constants.
