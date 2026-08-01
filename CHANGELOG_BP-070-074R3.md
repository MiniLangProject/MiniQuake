# MiniQuake BP-070–BP-074R3

R3 corrects the BP-071 synthetic shareware-state fixture exposed by the R2 Windows run.

- `qfs.create` intentionally retains the original startup state `staticRegistered=true`.
- The shareware loose-subdirectory fixture now explicitly models the state after a failed `COM_CheckRegistered` by setting `system.staticRegistered=false`.
- The BP-071 checker binds this exact setup and rejects a fixture that leaves registered access enabled.
- The BP-071 golden metadata and C oracle now include `shareware_loose_subdirectory_block`.
- Acceptance, collector, manifest, ledgers and documentation advance to BP-070–BP-074R3.

No production source or native source changes. The block remains 116 fixtures with contract fingerprint `0x6c8d974d`.
