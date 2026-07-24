# Third-party source

`stb` is pinned as a Git submodule solely for `stb_vorbis.c`. MiniQuake builds
that decoder into `miniquake_native.dll`; users do not need to install an OGG
codec or another runtime library.

The exact revision and decoder checksum are recorded in `stb.lock.json`.
Licensing terms are contained in the pinned upstream source.
