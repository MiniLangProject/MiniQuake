# BP-071 Filesystem/PACK audit

This step binds the observable `COM_FindFile`, PACK directory, search-path,
registered/shareware, `-proghack`, file-handle and `COM_LoadFile` rules from
WinQuake `common.c`. Text reads and writes use the Quake one-byte ABI rather
than host UTF-8; binary parsers continue to consume raw `bytes` values.

## Shareware state boundary

`common.c` starts with `static_registered = 1` and changes it only when
`COM_CheckRegistered` runs. MiniQuake's `qfs.create` preserves that startup
state. A synthetic test that bypasses registration probing must therefore set
`system.staticRegistered = false` explicitly before asserting that a loose file
below a subdirectory is rejected. PACK files remain searchable in that state,
matching `COM_FindFile`.
