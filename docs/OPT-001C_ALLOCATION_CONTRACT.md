# OPT-001C allocation contract

## Fast-path invariant

When GL diagnostic tracing is disabled, renderer wrappers must not evaluate an array literal solely for `traceCommand`.

The accepted patterns are:

```ml
if diagnosticTraceEnabled and traceCommand("vertex", [x, y, z]) then
  return void
end if
```

and for calls outside `gl11.ml`:

```ml
if gl.traceEnabled() then
  gl.traceCommand("multitexcoord", [unit, s, t])
end if
```

Short-circuit `and` and the explicit `if` ensure the array literal and trace-only hash calculations are not evaluated on the normal production path.

## Compatibility invariant

With tracing enabled, command names, ordering, argument counts and argument values remain unchanged. Existing renderer differential fixtures remain authoritative.

## Performance comparison

The accepted OPT-001B baseline is stored in `audit/opt001b_performance_baseline.json`. OPT-001C compares e1m1/e1m2 in headless and render modes using identical 300-frame warm-up and 3000-frame measurement windows.

A regression is any median or P99 increase above 10% in an individual map/mode. The long-term target is:

- at least 35% lower average render median or at least 1.5x render throughput, and
- at least 30% lower average render P99.
