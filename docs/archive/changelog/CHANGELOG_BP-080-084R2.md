# BP-080–BP-084R2 changelog

- Renamed every package-free BP-080..084 test helper and test-global with an
  explicit per-step prefix (`bp080*` through `bp084*`).
- Fixed the observed native-compiler collision where the global BP-081
  `check(condition, label)` helper shadowed `miniquake.zone.check(state)` inside
  the imported package closure.
- Added a package-wide import-closure/arity verifier for package-free MiniLang
  entry functions.
- Added a stricter helper-namespace contract for the five new global entry
  files, so generic names such as `check`, `equal`, `contains` or
  `commandExists` cannot be reintroduced.
- Added R2 acceptance, result-collection, analysis and ledger metadata.
- Preserved all production sources, native bridges, source-inventory counts,
  contract fingerprints and fixture counts.
