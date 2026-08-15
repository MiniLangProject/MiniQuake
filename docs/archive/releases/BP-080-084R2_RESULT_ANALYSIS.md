# BP-080–BP-084R1 result analysis

## Observed Windows result

The R1 package passed every source-contract preflight and compiled MiniQuake,
all inherited targets and the BP-080 cvar source-surface test. Compilation then
stopped at the BP-081 entry:

```text
CompileError: Function check expects 2 args, got 1
  at src/miniquake/zone.ml:272

    return check(state)
           ^
```

No BP-080..084 runtime fixture and no real-game/corpus gate was reached.

Result archive SHA-256:

```text
2412022204edd7715efb30ede6aae6b7777be01e89a97f8150603e5eff7e3ca5
```

## Root cause

R1 correctly moved each executable `main(args)` into the global package. The
five entries still used generic global helpers such as:

```ml
function check(condition, label)
function equal(actual, expected, label)
```

MiniLang compiles an entry file together with its complete import closure.
Within the BP-081 closure, `miniquake.zone` defines and internally calls:

```ml
function check(state)
...
return check(state)
```

The package-free entry helper `check/2` was selected for that unqualified
package-internal call, so the compiler saw one supplied argument for a
2-argument function.

This is a test-entry symbol collision, not a defect in zone management, CD
audio or any accepted engine subsystem.

## R2 correction

All non-entry helpers and their global counters are now namespaced by step:

```text
BP-080: bp080Check, bp080Equal, bp080CommandExists, ...
BP-081: bp081Check, bp081Equal, ...
BP-082: bp082Check, bp082Equal, bp082Contains, ...
BP-083: bp083Check, bp083Equal, ...
BP-084: bp084Check, bp084Equal, ...
```

Two verifier gates were added:

1. `minilang_entry_helper_namespace` requires every helper in the five new
   global entry files to use its per-step prefix.
2. `minilang_entry_function_shadow_arity` traverses each package-free entry's
   import closure and rejects an entry function that changes the arity of an
   imported package function called unqualified inside that package.

## Classification

- Failure class: build/test-entry symbol collision
- Production semantics reached: no new BP-080..084 runtime semantics
- Parent engine baseline affected: no
- Production source changed in R2: no
- Native source changed in R2: no
- Contract or fixture counts changed: no
