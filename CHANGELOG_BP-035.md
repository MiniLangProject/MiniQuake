# BP-035 — Client state and renderer handoff

- Aligns dynamic-light allocation, expiry and decay with `cl_main.c`.
- Applies explicit Binary32 storage at client interpolation boundaries.
- Preserves first-person/chase visibility rules and the `MAX_VISEDICTS` cap.
- Adds a defensive active-visible view and explicit view-entity origin handoff.
- Adds 20 MiniLang runtime fixtures and an independent C oracle.
