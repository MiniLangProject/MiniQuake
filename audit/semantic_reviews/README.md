# Semantic port reviews

This directory contains the currently hash-valid review records for target
logical units from `audit/GLQUAKE_PORT_INVENTORY.json`. Historical reviews that
were invalidated by later source edits may be kept under `stale/` so their
notes remain available without polluting the active report set. The records are
deliberately separate from code-location coverage and automated differential
manifests:

- code-location coverage answers whether a MiniLang counterpart exists;
- differential manifests answer which pinned-reference fixtures pass;
- semantic reviews answer whether the original unit was inspected branch by
  branch and whether the fixtures exercise the behavior that is being claimed.

`tools/generate_semantic_review.py` validates the records and generates
`audit/SEMANTIC_PORT_REVIEW.json` plus `docs/SEMANTIC_PORT_REVIEW.md`.

Each `<unit>.json` file uses this shape:

```json
{
  "schema": "miniquake.semantic-port-review.v1",
  "unit": "cl_main",
  "reference_commit": "bf4ac424ce754894ac8f1dae6a3981954bc9852d",
  "reviewer": "agent-name",
  "original_files": ["cl_main.c", "client.h"],
  "minilang_modules": ["src/miniquake/client.ml"],
  "original_sha256": {
    "cl_main.c": "<sha256>",
    "client.h": "<sha256>"
  },
  "minilang_sha256": {
    "src/miniquake/client.ml": "<sha256>"
  },
  "function_review_scope": "all-target-functions",
  "features": [
    {
      "name": "entity relinking and effects",
      "status": "parity",
      "original": ["cl_main.c:442"],
      "minilang": ["src/miniquake/client.ml:185"],
      "evidence": [
        "py -3 tools/cl_main_differential.py",
        "tests/cl_main_port_tests.ml"
      ]
    }
  ],
  "commands": ["py -3 tools/cl_main_differential.py"],
  "open_findings": [],
  "limitations": []
}
```

Allowed feature statuses are `parity`, `documented-platform-bridge`, and
`documented-exclusion`.  A unit passes only when it has at least one feature,
all features have concrete original/MiniLang/evidence entries, the review
claims all target functions, and `open_findings` is empty.  Limitations remain
visible in the generated report and do not silently turn an external hardware
gate into a parity claim.  The stored hashes must match the current pinned
inventory.  Any later source change therefore invalidates the earlier review
until that unit is inspected again.
