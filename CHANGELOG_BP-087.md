# BP-087 — demo and savegame artifact compatibility

- Binds the three retail demo names and Quake savegame version 5 as explicit compatibility artifacts.
- Provides 24 asset-free fixtures for demo framing, replay verification, CRCs and save-domain comparison helpers.
- Uses strictly sequential Host sessions because the original NET/QSocket state is process-global.
- Preserves the saved `sv.num_edicts` high-water mark, including trailing free edict blocks, when rebuilding MiniQuake's derived server state.
- Compares parsed Quake-v5 save semantics rather than transient complete VM hashes.
- Requires exact A→B byte and semantic identity and verifies exact B→C stability in a third independent Host session.
- Never collects retail demo, save, PAK or other game-data bytes.
