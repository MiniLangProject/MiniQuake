# BP-093 R7 visual diagnostic analysis

The uploaded `BP093_demo1_visual_diagnostics.zip` contains two byte-identical
original GLQuake screenshots and MiniQuake candidate frames 254 through 258.
No original screenshots are redistributed in the MiniQuake package; only the
measurements below are retained.

## Bound observations

```text
scenario=demo1-256
best_r7_frame=254
best_r7_ssim=0.5773750816123187
bottom_48_original_rgb=255,0,0
bottom_48_miniquake_rgb=0,0,0
platform_luminance_correlation=-0.547846
startup_palette_gamma=0.7_vs_1.0
brush_lightmap_inversion=confirmed
expected_original_backbuffer_offset=-2
```

The world and view-model edges are largely aligned.  The low raw SSIM is
dominated by three implementation mismatches rather than camera geometry:

1. The original process starts with command-line `-gamma 1`; MiniQuake R7 only
   set the unrelated runtime cvar `+gamma 1`, so uploaded textures used the
   non-3Dfx default startup gamma of `0.7`.
2. GLQuake keeps the red clear colour established by `GL_Init`; MiniQuake
   overwrote it with black before `gl_clear`.  This explains the complete
   48-row red-versus-black strip.
3. Brush entities used a simplified renderer with
   `GL_ZERO / GL_SRC_COLOR` even though the LUMINANCE lightmap bytes are
   inverted.  The strong negative platform correlation is the expected
   signature of that error.  The same path also ignored `entity.frame`, which
   selected the wrong alternate animation for the wall button.

The `-2` candidate offset is expected: the original `screenshot` command runs
before the next render and reads the double-buffered back buffer, so the frame
visible after 256 waits is the MiniQuake candidate numbered 254.

## R8 corrections

- pass startup `-gamma 1` to MiniQuake demo evidence;
- preserve GLQuake's `(1,0,0,0)` clear colour;
- route brush entities through the canonical `R_DrawBrushModel` path;
- reset per-bmodel lightmap chains;
- use `GL_ZERO / GL_ONE_MINUS_SRC_COLOR`;
- select alternate animated textures from `entity.frame`;
- retain the raw full-frame SSIM threshold of `0.95` with no image normalization.
