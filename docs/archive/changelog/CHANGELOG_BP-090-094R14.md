# Changelog BP-090–BP-094R14

Parent: `BP-090-094R13`.

- Wait for complete stable Original GLQuake TGAs instead of copying on first filename visibility.
- Validate TGA header, dimensions, exact byte count and stable SHA-256.
- Add dual-reference support to the raw comparator.
- Require original-reference consistency SSIM >= 0.98 when hashes differ.
- Score each MiniQuake candidate by minimum SSIM across both references.
- Preserve the MiniQuake visual gate at 0.95 and normalization `none`.
- No MiniQuake engine or native bridge changes.
