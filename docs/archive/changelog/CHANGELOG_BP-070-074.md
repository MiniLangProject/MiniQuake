# MiniQuake BP-070–BP-074

Cumulative source-guided black-port block for WinQuake common/CRC, filesystem/PACK, WAD graphics, BSP/MDL/SPR model assets, and zone/hunk/cache observable semantics.

- BP-070: binary32/int32 common parsing, endian helpers, COM path helpers and CRC.
- BP-071: search-path order, registered/shareware checks, PACK bounds and Quake byte names.
- BP-072: WAD2 directory/lump parsing and qpic/conchars handling.
- BP-073: BSP v29, alias MDL v6, sprite v1 and model registry lifecycle.
- BP-074: zone, hunk and cache semantics plus frozen core asset/memory contract.

Candidate contract: `core_assets_memory_109_frozen_v1`, fingerprint `0x6c8d974d`.
