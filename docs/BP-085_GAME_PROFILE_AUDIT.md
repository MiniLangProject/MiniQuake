# BP-085 game/search-path profile audit

The selected reference is `common.c::COM_InitFilesystem` with `QUAKE2`
undefined. MiniQuake now preserves the observable ordering:

```text
add id1
add rogue when -rogue is present
add hipnotic when -hipnotic is present
add explicit -game directory last
replace all generated search paths when -path is present
apply -proghack independently
```

Because each addition is inserted at the search-list head, the effective search
precedence is the reverse of the addition order. Validation and runtime launch
paths now carry the complete profile (`-rogue`, `-hipnotic`, `-game`,
`-cachedir`, `-proghack`, `-path`) instead of only the final game name.

Contract: `game_profile_109_frozen_v1`, fingerprint `0x7a03b68d`.
