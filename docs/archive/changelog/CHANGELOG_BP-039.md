# BP-039 — Client/render closure

- Accumulates and deduplicates efrags across all visible leaves in one render frame.
- Separates prefiltered renderer submission from first-person entity filtering.
- Appends temporary beam model entities after regular visible entities.
- Binds the client/render contract as `client_render_109_frozen_v1`.
- Contract fingerprint: `0x95e2b295`.
- Adds 24 MiniLang closure fixtures and an independent C oracle.
