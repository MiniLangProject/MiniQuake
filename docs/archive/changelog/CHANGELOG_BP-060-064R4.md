# CHANGELOG BP-060–BP-064R4

- Accept both `Vec3` and the package-qualified `miniquake.types.Vec3` from MiniLang `typeName`.
- Route deterministic trace and crash-context vector guards through the shared
  concrete-type matcher.
- Update the forced-GC diagnostics fixture so it validates concrete type identity
  without assuming an unqualified runtime name.
- Remove the same short-name-only comparison from the direct Efrag and
  single-surface sky-chain compatibility paths.
- Preserve the R3 GC-rooting changes, live output, all fixture counts, native ABI
  and frozen engine fingerprints.
- Add R4 acceptance, collector, result-analysis and verifier contracts.
