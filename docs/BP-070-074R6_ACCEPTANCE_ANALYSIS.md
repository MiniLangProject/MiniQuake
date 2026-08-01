# BP-070–BP-074R6 Windows acceptance

The Windows result archive `MiniQuake_BP-070-074R6_RESULTS_20260730-132228.zip` completed the full acceptance path successfully.

```text
result_archive_sha256=f3f3a15f52932699d744ea6691b6dcb6a4fdca5fe6b77cbc5d38cf114fd283a2
trace_sha256=80695b98a91b7d52f91b35dcd220c3cc0962edb6851b0411832746f6f94d3486
trace_rolling_hash=d905b042
retail_core_asset_evidence_sha256=06eac1012b97d36116a8f605cd428b09bf81f2881c474eda049c5e50183ec20e
retail_audio_evidence_sha256=896049a03f26b1db4ddc1550d35d1cacb5f7e0f0c900b0ee36393c8ab8bd0501
render_tga_sha256=734e965e17c9a20af7c42184d3d8a3d7f2997e1321342976799ec7f4670af945
network_client_report_sha256=50534266c750fa20058c82ce48baca953b0107106dc24fd69c5854fc3364ba96
```

Passed gates include all 76 Windows build targets, BP-070 through BP-074 runtime fixtures, installed `id1/start` validation, 300 headless frames, two byte-identical 128-frame traces, two byte-identical retail core-asset reports, inherited retail-audio and framebuffer evidence, two Protocol-3 UDP process pairs, and the Winsock UDP loopback smoke test.

The retail report observed `gfx.wad` with 163 lumps, `maps/start.bsp` with 5,556 faces, `progs/player.mdl` with 143 frames, and `progs.dat` with 2,091 functions. No copyrighted Quake payload was collected.

The contract is accepted as:

```text
core_assets_memory_109_frozen_v1
fingerprint=0x6c8d974d
```
