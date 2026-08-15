# BP-031 – Command and cvar lifecycle parity

- Stores `cvar_t.value` at the original binary32 boundary.
- Implements `%f`-style six-decimal `Cvar_SetValue`, including negative zero.
- Centralizes `Cvar_Command` query/set semantics and uses it from the host.
- Binds command-buffer, alias, completion, archive and `wait` limits with 20 fixtures.
