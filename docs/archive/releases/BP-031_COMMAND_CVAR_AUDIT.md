# BP-031 command/cvar audit

Reference: `cmd.c` and `cvar.c` from WinQuake 1.09.

The contract covers the 8192-byte command buffer, 32-byte alias-name storage,
80 parsed arguments, head insertion, case-sensitive registration/completion,
case-insensitive execution, alias replacement rules, `wait`, archived-variable
order and the binary32 `cvar_t.value` field.
