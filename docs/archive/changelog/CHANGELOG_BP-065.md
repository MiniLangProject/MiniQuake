# BP-065 — Key routing and focus release parity

- Implements WinQuake `ClearAllStates` release generation for all 256 keys.
- Queues `-command keynum` for direct and shifted `+` bindings.
- Drains synthetic releases into the command buffer before new input events.
- Preserves release generation across focus and video-mode transitions.
- Adds 20 MiniLang fixtures, a C oracle, golden data and a static checker.
