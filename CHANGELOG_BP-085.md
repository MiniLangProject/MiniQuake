# BP-085 — game/search-path profile closure

- Binds `COM_InitFilesystem` precedence for `id1`, `-rogue`, `-hipnotic`, `-game`, `-path`, `-cachedir` and `-proghack`.
- Preserves the full filesystem profile in validation and runtime launch paths instead of reducing it to one final game directory.
- Removes a duplicate cache-path lookup in the filesystem read path.
- Adds 22 asset-free runtime fixtures and optional Windows mission-pack validation when matching PAK files are installed.
