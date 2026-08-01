# BP-023 – QuakeC builtin parity

BP-023 audits the stock non-Quake2 builtin table in `pr_cmds.c`.

- binds all 79 stock builtin slots and all 14 intentional `PF_Fixme` positions;
- exposes the canonical builtin-name table and a deterministic fingerprint;
- models `pr_string_temp` as one shared temporary QuakeC string handle, so
  `PF_ftos` and `PF_vtos` overwrite the same buffer as the C engine;
- reproduces `%5.1f` one-decimal round-to-nearest/even behavior, including
  binary32 values immediately below a decimal tie and negative values that
  round to `-0.0`;
- preserves the original misspelled `unimplemented bulitin` run error;
- keeps the MSVC 15-bit `rand()` stream synchronized between VM and host
  context;
- makes `PF_fabs(-0.0)` produce positive zero;
- adds 22 MiniLang runtime fixtures and a strict C/Python oracle.
