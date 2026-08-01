# BP-071 Filesystem/PAK audit

This step covers `COM_LoadPackFile`, `COM_AddGameDirectory`, `COM_FindFile`, the `COM_LoadFile` family and PACK directory lookup. Search order remains newest-first, higher numbered sequential PAKs override lower PAKs and PAK names remain case-sensitive like `strcmp` in the original.
