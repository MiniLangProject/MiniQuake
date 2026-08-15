# BP-014 Protocol-15 runtime-event audit

## Reference scope

| Original source | Audited behavior | MiniLang implementation |
|---|---|---|
| `cl_tent.c` | `CL_ParseTEnt`, `CL_ParseBeam`, 24 beam slots, expiry | `protocol_transients.ml`, `temp_entities.ml`, `client_effects.ml` |
| `cl_parse.c` | start/stop/static sound decoding and limits | `client_protocol.ml`, `client_effects.ml` |
| `sv_main.c` | `SV_StartSound`, `SV_SendNop`, client-message lifecycle | `protocol_serverdata.ml`, `protocol_transients.ml`, `server.ml`, `sv_main.ml` |
| `pr_cmds.c` | `PF_sound` argument conversion | `quakec/builtins.ml`, `protocol_transients.ml` |
| `host.c` / `host_cmd.c` | drop/reconnect boundaries | `server.ml`, `sv_main.ml`, `protocol_transients.ml` |
| `protocol.h` | TE, sound and service command constants | `constants.ml` |

## Temporary-entity wire formats

BP-014 covers all 14 valid Quake temporary-entity types.

| Family | Types | Wire payload after `svc_temp_entity` |
|---|---|---|
| Point | spike, superspike, gunshot, explosion, tar explosion, wiz spike, knight spike, lava splash, teleport | type + 3 coords |
| Beam | lightning1/2/3, beam | type + short entity + start coords + end coords |
| Explosion2 | `TE_EXPLOSION2` | type + 3 coords + color start + color length |

The shared writer sizes are 8, 16 and 10 bytes including the leading service
command. Unknown types return a controlled error rather than reading an
undefined payload.

## Beam allocation parity

The original `cl_beams[MAX_BEAMS]` uses two passes:

1. replace the first slot whose `entity` matches,
2. otherwise use the first slot with no model or `endtime < cl.time`.

BP-014 stores compact records as `[payload, endTime, slot]`, normalizes them by
slot and performs the same two-pass decision. It intentionally does **not**
prune expired records before the same-entity pass. Equality is alive because
the C condition is strictly `< cl.time`. The pool limit is 24.

## Sound scalar and packet parity

### Server writer

- channel and volume are converted through C `int` semantics,
- attenuation is converted to Binary32 before validation and optional-bit
  selection,
- attenuation byte is `(int)(attenuation_float * 64.0f)`,
- packed channel is `(entity << 3) | (channel & 7)`,
- sound center is computed with C-float intermediate boundaries,
- `cursize == MAX_DATAGRAM-16` remains accepted.

### Client parser

- absent volume defaults to 255,
- absent attenuation defaults to `1.0f`,
- present attenuation is `byte / 64.0` converted to Binary32,
- entity values up to and including `MAX_EDICTS` are accepted,
- mixer volume is `volume / 255.0` converted to Binary32,
- `svc_stopsound` uses the same packed-channel decoder,
- static-sound attenuation remains the raw byte magnitude until the mixer
  applies the original `/64` distance conversion; volume is normalized by 255
  at the MiniQuake mixer-adapter boundary because `MixerChannel.volume` is a
  normalized field and `channelVolumes` reconstructs the original master byte.

## Delivery and lifecycle boundaries

| Case | Original-compatible result |
|---|---|
| new/reused client message buffer | size 0, overflow allowed, overflow flag false |
| reliable buffer already overflowed | drop-overflow before `dropasap` |
| `dropasap`, socket blocked | wait |
| `dropasap`, socket sendable | drop |
| unspawned elapsed exactly 5 seconds | wait |
| unspawned elapsed greater than 5 seconds | send NOP |
| reconnect request | `svc_stufftext`, `"reconnect\n\0"` |
| NOP send failure | drop, then update `last_message` in original control order |

## Oracle evidence

The bundled C oracle is
`tools/oracle/protocol15_runtime_events_oracle.c`. It is compiled with:

```text
-std=c11 -Wall -Wextra -Werror -O2
```

The independent Python model lives in
`tools/check_protocol15_runtime_events.py`. Both models must match the golden
document `audit/protocol15_runtime_events_golden.json`.

Expected evidence counts:

| Evidence | Count |
|---|---:|
| Complete wire vectors | 10 |
| TE kind cases | 14 |
| TE size cases | 14 |
| Sound scalar cases | 9 |
| Timing cases | 4 |
| Delivery cases | 8 |
| Total semantic cases | 49 |
| MiniLang runtime fixtures | 27 |

## Safe implementation differences

MiniQuake reports invalid/truncated messages and fatal C errors as controlled
error values. The integrated renderer uses compact beam records rather than the
original static C array, but retains the slot number and the exact externally
observable replacement/free-slot order. Valid Protocol-15 packets are not
changed by either difference.
