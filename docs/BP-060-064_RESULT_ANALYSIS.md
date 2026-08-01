# BP-060–BP-064 initial Windows result analysis

Result archive: `MiniQuake_BP-060-064_RESULTS_20260728-184449.zip`  
SHA-256: `bde52d9bcb2e7052c3dcac5ee62dbe49dd3acd6887cbeabfc54c1f8b4916c719`

## Result boundary

The original buffered acceptance runner continued in the background and produced a complete diagnostic archive.

- static source/package verification: PASS;
- all 65 Windows executables compiled successfully;
- all inherited runtime groups through BP-059 passed;
- BP-060 network-main tests: 20/20 PASS;
- BP-061 passed fixture 19 and stopped before fixture 20;
- BP-062 through BP-064, installed-game validation, traces, render/audio evidence and UDP evidence were not reached.

The exact diagnostic was:

```text
[19/24] rule enumeration
Error occured: no=1200 message=Cannot index void
  at network_control_parity_tests.ml:63 in main
```

## Root cause

`nextServerRule(rules, "fraglimit")` returned `void` at the end of the list, while the fixture indexed the result as an empty rule/value pair.

A direct comparison with `net_dgrm.c` exposed a second distinction that the old helper could not represent:

1. after the final valid server cvar, Quake emits a command-only `CCREP_RULE_INFO` packet; this is the normal enumeration terminator;
2. when the requested previous cvar does not exist, Quake returns without sending any packet.

The old MiniQuake helper returned `void` for both outcomes. The fixture crashed on the first case, and the production listener would have incorrectly replied in the second case.

## R2 correction

R2 represents the two outcomes separately:

- end of list: `["", ""]`, serialized as a command-only `CCREP_RULE_INFO` packet;
- unknown previous rule: an internal no-reply error sentinel, caught by the listener and silently ignored.

The BP-061 fixture now verifies both semantics and parses the generated command-only terminator.

R2 also carries forward the live-output runner from the unexecuted R1 delivery. Compiler and test output is displayed immediately and flushed to logs.
