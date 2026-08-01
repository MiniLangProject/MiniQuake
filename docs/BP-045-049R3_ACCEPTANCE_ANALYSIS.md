# BP-045-BP-049R3 Windows acceptance

The user-returned archive `MiniQuake_BP-045-049R3_RESULTS_20260728-000010.zip` completed the full Windows acceptance run.

- Status: PASS
- Steps: 112/112 PASS
- Installed `id1/start`: PASS
- Headless runtime: 300 frames PASS
- Compatibility traces: two independent 128-frame traces, byte-identical
- Trace SHA-256: `b2589f2712b0aed42f31b1a35ebb4837c211391ba3e8d8888c422242d051af28`
- Rolling hash: `d905b042`
- Visible framebuffer evidence: two independent 640x480 captures, byte-identical
- Evidence TGA SHA-256: `1325e6fd365c1e62fbf36c4fadcbe9110faa94778c4c14b43fa9efe56d35e154`
- Pixel hash: `55f9fc9c`
- Sample hash: `3ec42fe3`
- Evidence SSIM: `1.0`
- Capture stage: `after_ui_before_swap`
- UDP loopback: PASS
- Result archive SHA-256: `65bb521faf300fed61b7d03e15429896a31de27d934ee59459e251fac08bd2bf`

This accepts `model_ui_render_109_frozen_v1` with fingerprint `0x0a62f5b1` as the parent contract for BP-050-BP-054.
