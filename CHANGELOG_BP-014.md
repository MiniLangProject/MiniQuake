# MiniQuake BP-014 changelog

Parent package: **BP-013**  
Compatibility profile: **WinQuake/GLQuake 1.09, Protocol 15**

## Purpose

BP-014 ports and consolidates the remaining runtime event paths that are shared
between `cl_tent.c`, `cl_parse.c`, `sv_main.c`, `host.c` and `pr_cmds.c`:

- all 14 Protocol-15 temporary-entity types,
- dynamic and stopped sound packet semantics,
- the fixed 24-slot beam pool and its lifetime rules,
- Binary32 timing and sound-scalar boundaries,
- dynamic-sound datagram margins,
- reusable client reliable-buffer reset,
- keepalive, reconnect, overflow and `dropasap` ordering.

## Production changes

### Shared transient protocol module

Added `src/miniquake/protocol_transients.ml`. It supplies the common writer,
parser and scalar helpers used by the integrated client/server, the direct
`sv_main` pendant and QuakeC builtins. It replaces duplicated calculations for:

- `svc_temp_entity` point, beam and `TE_EXPLOSION2` payloads,
- `svc_stopsound`, packed entity/channel fields and dynamic `svc_sound`,
- sound center coordinates,
- optional volume/attenuation bits,
- QuakeC sound argument conversion,
- client mixer conversion,
- beam/dlight expiry and beam-slot reuse,
- `svc_stufftext "reconnect\n"`.

### Temporary entities and beams

The temporary-entity parser now classifies all valid types through one shared
mapping. The compact integrated beam representation preserves the original
fixed-slot behavior:

1. replace a beam with the same entity before considering expiry,
2. otherwise choose the lowest empty or strictly expired slot,
3. treat `endtime == cl.time` as still alive,
4. reject a twenty-fifth simultaneously active beam,
5. preserve the original `beam list overflow!` diagnostic in the full
   `cl_tent` pendant.

Beam end times and explosion dynamic-light die times are explicitly stored at
IEEE-754 Binary32 boundaries, matching the C fields.

### Dynamic sound

The server-side sound center follows
`origin + 0.5f * (mins + maxs)` with explicit C-float boundaries. Optional
attenuation bytes use the original float multiplication and truncation order.
The conservative `MAX_DATAGRAM-16` gate accepts equality and rejects only a
larger current size.

The client parser retains the original `ent > MAX_EDICTS` boundary and converts
volume and attenuation to mixer floats at Binary32 precision. Stop-sound
entity/channel unpacking is shared with the writer. Static-sound volume and
attenuation remain raw byte values converted to float, as in
`CL_ParseStaticSound` and `S_StaticSound`.

### Delivery lifecycle

Reusing a local client now restores the complete `SV_ConnectClient` message
state: size zero, overflow allowed and the sticky overflow flag cleared.
Reliable overflow continues to take priority over `dropasap`; a blocked
`dropasap` client waits until sendable. Keepalive NOPs use the strict
`elapsed > 5` rule. `SV_SendNop` updates `last_message` after the send/drop
attempt, matching original control flow.

## Evidence

- 10 complete runtime-event wire vectors,
- 49 independent semantic cases,
- strict C11 oracle built with GCC and Clang,
- independent Python model,
- 27 MiniLang runtime fixtures,
- inherited BP-010R1, BP-011, BP-012R1 and BP-013 regression suites,
- deterministic trace and real-game acceptance retained as release gates.

## Deliberate safe behavior

Fatal and memory-unsafe C failures remain controlled MiniLang errors. This does
not alter valid Protocol-15 payloads. The compact integrated beam representation
stores an explicit original slot number because MiniLang does not expose a
fixed C array of `beam_t`; observable allocation and lifetime behavior remains
the same.
