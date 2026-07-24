# Long-running resource soak

`tools/long_soak_matrix.py` runs three fixed-timestep engine modes against a
locally installed retail game:

- a headless listen server with its loopback client and a live UDP listener;
- a headless dedicated server with a live UDP listener;
- continuous Protocol-15 playback of a retail demo.

Each mode runs 100,000 measured `Host_Frame` iterations by default. The demo
path first completes eight full warm-up cycles (enough to fill bounded console
history) and normalizes both measured
endpoints to the same post-signon phase. This prevents ordinary differences
between the middle and beginning of a recording from looking like a leak.

```powershell
py -3 tools\long_soak_matrix.py `
  --basedir "C:\Program Files (x86)\Steam\steamapps\common\Quake" `
  --game id1 --map e1m1 --demo demo1 --frames 100000
```

The generated `build/long_soak_matrix.json` contains only aggregate counts; it
does not extract or copy proprietary assets. At forced-GC checkpoints the
engine records:

- live heap blocks, live heap bytes, allocator high-water and free bytes;
- server Edicts and client demo entities;
- active/free QSockets, reliable fragments, protocol queues, poll procedures,
  and open UDP endpoints;
- queued waveOut buffers and mixer channels;
- the Win32 process handle count;
- particles and temporary entities.

The listen, dedicated, and demo soaks use `-headless -nosound`, so the expected
audio queue/channel counts are zero. Audio mixing and waveOut queue behavior
remain covered by their dedicated differential and native tests.

A pass requires bounded live heap state and no endpoint growth in Edicts,
client entities, clients, QSockets, network queues, UDP endpoints, audio
queues/channels, or Win32 handles. Demo playback must also complete at least
one full measured cycle and consume protocol messages. The heap gate permits
at most 64 KiB of final live-byte growth; the reported live-block count has a
512-block corruption guard because the measurement arrays and final loop-local
objects are themselves visible to the tracing collector.
