# MiniQuake BP-085–BP-089R1

## Quake-v5 savegame roundtrip and evidence hotfix

- Replaces the invalid simultaneous dual-Host savegame evidence with three strictly sequential Host sessions.
- Preserves the Quake `sv.num_edicts` high-water mark, including trailing free savegame edict blocks, when rebuilding MiniQuake's derived server-edict table.
- Relinks restored non-free edicts without touching triggers, matching `Host_Loadgame_f` / `ED_ParseEdict` behavior.
- Restores the saved map name at the savegame apply boundary.
- Uses the parsed Quake-v5 save domain as the semantic boundary instead of treating all transient live VM globals as archived state.
- Requires exact A→B byte identity and semantic equality, then verifies exact B→C stability in a third independent Host session.
- Adds first-byte and first-semantic-difference diagnostics without collecting savegame or PAK payloads.
- Keeps complete live server/global hashes as diagnostics only.
- Extends the existing 24 BP-087 fixtures with save-domain comparison and byte-difference checks without changing the public fixture count.
- Preserves all existing compatibility statuses and fingerprints.
