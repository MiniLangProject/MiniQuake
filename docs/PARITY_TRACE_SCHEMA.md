# MiniQuake parity trace schema

Parity traces use UTF-8 JSON Lines.  Every line is an independently parseable
event with these mandatory fields:

```json
{"schema":1,"kind":"frame","frame":120,"time":1.666667}
```

Events are emitted in deterministic engine order.  Platform pointers, wall
clock values, process identifiers, native handles, and absolute filesystem
paths are forbidden.

## Event kinds

- `frame`: host frame number, logical time, map, signon state, pause state.
- `client`: view entity, origin, angles, velocity, stats and active effects.
- `server`: active client count, edict count, datagram sizes and server flags.
- `edict`: index, free flag and named QuakeC fields in declaration order.
- `global`: named QuakeC globals in declaration order.
- `network`: direction, reliable flag and complete Protocol-15 payload as hex.
- `render`: normalized fixed-function draw operation and its arguments.
- `audio`: channel operation, entity, sample, volume, attenuation and timing.
- `console`: command execution or console output.

Floats are serialized with enough precision to round-trip their 32-bit value.
The comparison default is an absolute tolerance of `1e-5`; integer protocol
values, strings, event ordering and collection lengths remain exact.

## Commands

```powershell
python .\tools\parity_oracle.py verify-reference
python .\tools\parity_oracle.py compare-traces ref.jsonl mini.jsonl
python .\tools\parity_oracle.py compare-wav ref.wav mini.wav
python .\tools\parity_oracle.py compare-images ref.png mini.png
```

Image acceptance defaults to SSIM 0.99.  PCM comparison permits one integer
LSB and at most one 512-frame block of length difference.
