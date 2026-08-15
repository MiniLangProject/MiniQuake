# BP-075–BP-079R3 result analysis

## Failure boundary

The BP-075–BP-079R2 Windows build produced all 81 native targets and completed every inherited runtime group through BP-035. The first failure was the inherited BP-036 view-state test:

```text
[12/22] cshift atoi
FAIL: hex atoi: expected 32., got 0
```

Result archive SHA-256:

```text
225397ce680774d4730f0b75929f52e05749c70a6ead246051e057a310b9916b
```

## Cause

BP-076 intentionally corrected `V_cshift_f` to use the C runtime `atoi` semantics of the original `view.c`. The current production source and the new BP-076 fixture therefore correctly map `0x20` and `'A` to zero. The inherited BP-036 runtime fixture still expected Quake `Q_atoi` values 32 and 65.

The R2 checker separated historical and downstream source markers, but did not also separate the inherited runtime expectations.

## R3 correction

The downstream BP-036 runtime fixture now expects:

```text
C atoi("0x20") = 0
C atoi("'A")   = 0
```

The shared checker now validates both source and runtime lineage:

- strict historical mode requires the old `Q_atoi` source marker and the historical 32/65 fixture values;
- downstream mode requires `common.cAtoi` and the 0/0 fixture values, and rejects stale historical expectations.

No file under `src/` or `native/` changed. The gameplay/presentation fingerprint remains `0xad91624c` and all fixture counts remain unchanged.
