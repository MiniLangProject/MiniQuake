# MiniQuake native bridge

`miniquake_native.c` is the narrow Windows x64 ABI used where MiniLang cannot
call APIs with floating-point parameters directly. IEEE-754 single-precision
values cross the ABI as 32-bit integer bit patterns.

The bridge covers Win32/WGL window creation, input, timing, `waveOut` audio,
OpenGL 1.1 calls, basic math and float-bit conversion. It intentionally uses
local type declarations instead of Windows SDK headers.

Build with:

```powershell
python .\native\build_bridge.py --clean
```

Required tools are `clang-cl` and `lld-link`. The script synthesizes the small
COFF import libraries it needs from `.def` files.

## MiniLang float raw-value bridge

`mq_f32_from_ml_raw` and `mq_f32_to_ml_raw` are the canonical conversion path
between MiniLang numbers and Quake's 32-bit IEEE-754 words.  They are paired
with MiniLang's documented `nativeRawValue` / `nativeValueFromRaw` builtins.
This avoids locale-sensitive decimal formatting and parsing at every network,
BSP, QuakeC, renderer, and sound conversion.  The bridge accepts MiniLang v1's
immediate-f32, integer, and boxed-f64 representations and emits the compact
immediate-f32 representation.  The older text conversion exports remain for
ABI compatibility and diagnostics but are not used by the engine path.

## Eingabe- und waveOut-Stabilität

Beim Aktivieren der Mausaufnahme wird der Cursor in die Clientmitte gesetzt;
der erste Sample nach Capture oder Fokuswechsel wird verworfen. Dadurch wird
eine Desktop-zu-Fenstermitte-Differenz nicht als riesige Blickbewegung
interpretiert.

`mq_audio_submit` prüft alle acht `waveOut`-Header, statt nur den nächsten
Ringplatz zu betrachten. Ein noch aktiver Slot blockiert damit keinen anderen,
bereits abgeschlossenen Buffer. Die eigentliche Misch-, Loop- und
Spatializerlogik bleibt in MiniLang.
