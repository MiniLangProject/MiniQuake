# BP-067 — Console and screen modal lifecycle

- Implements the original two-edge notify acknowledgement (`key_count=-2`) without blocking the host loop.
- Routes notify-box key down/up edges before normal key dispatch.
- Keeps `SCR_ModalMessage` yes/no/escape semantics explicitly covered.
- Adds 22 MiniLang fixtures, a C oracle, golden data and a static checker.
