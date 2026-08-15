# BP-080 — cvar.c source-surface closure

- Adds exact-name MiniLang adapters for all nine original `Cvar_*` functions.
- Keeps MiniQuake's registry and command context explicit rather than restoring unsafe globals.
- Adds 20 runtime fixtures and a machine-readable audit.
