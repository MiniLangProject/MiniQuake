# CHANGELOG BP-060–BP-064R5

- Correct the render-evidence comparator CLI mismatch that stopped R4 after both
  visible framebuffer captures had already succeeded.
- Make `tools/compare_render_evidence.py` accept both the canonical
  `--json-out` option and the historical `--json-output` spelling.
- Use the canonical `--json-out` option in the current R5 acceptance runner.
- Preserve live, unbuffered foreground output and per-line log flushing.
- Preserve all 65 compiled targets, 113 network/platform fixtures, native ABI,
  engine sources and frozen compatibility fingerprints.
- Add a static contract and negative tests for the comparator CLI so this wrapper
  mismatch cannot recur in later blocks.
- No engine or native source changes are part of this delivery-only hotfix.
