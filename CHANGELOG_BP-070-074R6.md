# MiniQuake BP-070–BP-074R6

- Corrects BP-073 BSP-submodel bounds expectations to match `Mod_LoadSubmodels`: every minimum is reduced by one and every maximum increased by one.
- Binds the full synthetic submodel transformation `[-3,-4,0]..[2,1,12] -> [-4,-5,-1]..[3,2,13]`.
- Corrects the model-registry brush-bounds expectation to use the expanded bounds.
- Extends the model golden data, C oracle, component checker and audit with the one-pixel spread contract.
- Preserves the R5 Windows PowerShell 5.1 collector correction and live output.
- Changes no file below `src/` or `native/`; frozen contracts and fixture counts remain unchanged.
