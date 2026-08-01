# MiniQuake BP-025–BP-029R2

Parent delivery: BP-025–BP-029R1  
Engine package: BP-029  
Logical block: BP-025–BP-029  
World/physics status: `world_physics_109_frozen_v1` candidate

## Fixed

- Corrected the final closure fixture to call the exported six-node box-hull
  API `world_hull.pointContentsFromNode(box, 0, point)`.
- Removed the nonexistent `world_hull.pointContents(...)` reference that caused
  `MiniQuakeWorldPhysicsClosureTests.exe` to fail compilation.
- Expanded the test formatting so box creation, traversal and assertion are
  separate compiler-visible statements.
- Added `bp025029r2_world_hull_member_contract`, binding the actual exported
  package API and rejecting the invalid member spelling before Windows codegen.
- Added R2-specific acceptance, result collection, ledger and failure-analysis
  metadata.

## Evidence from R1

- All 34 static checks passed.
- 27 of 28 cumulative Windows targets compiled.
- The sole failure was the final world/physics closure target.
- Result archive SHA-256:
  `08f1dfb4ee1cd0e703b94177f02334a1a0a3f68cf152e6e8412b0b6ea02dd9af`.

## Unchanged

- No production source under `src/` changed.
- No native source or DLL changed.
- All 125 BP-025–BP-029 runtime fixture counts are unchanged.
- Protocol 15 and QuakeC frozen contracts are unchanged.
- The world/physics contract fingerprint remains `0x2235d77c`.
