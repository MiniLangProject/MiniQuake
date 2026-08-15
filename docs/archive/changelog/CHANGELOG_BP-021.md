# BP-021 – QuakeC VM execution parity

BP-021 audits `pr_exec.c` against `src/miniquake/quakec/vm.ml`.

- resets `pr_trace` at the start of every `PR_ExecuteProgram` invocation;
- preserves the original conditional `OP_STATE` frame assignment, including
  signed-zero and NaN behavior;
- routes invalid LOAD/ADDRESS/STOREP accesses through `PR_RunError` and resets
  the VM stack;
- validates abstract MiniLang edict pointers without allowing vector stores to
  cross an edict boundary;
- preserves Quake's one-byte string comparison semantics through the Latin-1
  Quake string ABI;
- keeps the original 32-entry call stack and 2048-word local stack limits;
- adds 16 independent MiniLang fixtures and a strict C oracle.
