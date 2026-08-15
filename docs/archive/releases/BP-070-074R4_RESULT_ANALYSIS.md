# BP-070–BP-074R4 result-collector analysis

## Observed failure

The R3 collector stopped before creating the feedback archive:

```text
refusing to collect id1 content: build\bp071_fs\id1\latin.txt
```

`bp071_fs` is an intentionally synthetic filesystem fixture created by
`MiniQuakeFilesystemPackTests.exe`. It contains tiny generated files and PACK
archives used to test shareware and registered search-path behavior. It is not
an installed Quake data directory.

## Root cause

The collector correctly rejected any source/document path containing `id1`, but
it applied the same fatal rule while recursively scanning `build`. Runtime tests
are allowed to create disposable directory trees that resemble Quake layouts.
The strict rule therefore turned a safe exclusion into a collection failure.

## R4 behavior

Build artifacts are now classified before copying. The collector skips and
records:

- `bp071_fs`, `bp071-filesystem`, `bp072-wad` and `sys_win_differential` test workspaces;
- any build path containing `id1`, `hipnotic` or `rogue`;
- forbidden Quake filenames such as `pak0.pak`, `progs.dat` and `gfx.wad`.

Source and documentation files still use the strict copy path and cause an
immediate failure if game data is ever requested there. Every skipped build
artifact is written to `collection.json` with its relative path and reason.

No MiniQuake source, native bridge, fixture expectation or frozen contract is
changed by R4.
