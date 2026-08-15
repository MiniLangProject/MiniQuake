# MiniQuake BP-090–BP-094R14 – R13 result analysis

R13 completed the full build, all internal tests and both bidirectional Original GLQuake Protocol-15 interoperability directions. `demo1-256` passed with SSIM `0.992568209519`; `demo2-256` passed with SSIM `0.988163116802`.

The first current failure was a differing pair of Original GLQuake `demo3-256` screenshot hashes. R13 copied `quake*.tga` immediately when the filename appeared and then stopped the original process. This is a real collection race because file existence does not prove that `COM_WriteFile` has closed the complete TGA. The excluded TGA images are not present in the result archive, so the archive alone cannot distinguish that race from bounded client-side randomness in the unmodified original binary.

R14 waits for a complete stable TGA: valid 24-bit type-2 header, exact expected byte count and stable SHA-256 across at least three polls, followed by a final re-read. It keeps two independent original captures. Exact pairs remain accepted. Non-identical pairs must have raw full-frame SSIM at least `0.98`. Every MiniQuake candidate is compared against both originals and scored by the minimum SSIM. The MiniQuake gate remains `0.95`; no crop, shift, resize, gamma correction, colour normalization or geometric alignment is allowed.
