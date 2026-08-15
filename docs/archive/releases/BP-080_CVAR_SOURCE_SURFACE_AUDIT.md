# BP-080 cvar.c audit

The original C module exposes nine `Cvar_*` functions over global `cvar_vars`
and global `Cmd_Argv` state. MiniQuake retains the exact source names but passes
the registry and command context explicitly. This is classified as a context
adapter rather than a technical deviation.
