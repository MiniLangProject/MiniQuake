# MiniQuake native bridges

## `miniquake_native.dll`

`miniquake_native.c` ist die schmale Windows-x64-Hauptbridge für Funktionen,
die MiniLang nicht direkt abbilden kann. IEEE-754-Single-Werte laufen als
32-Bit-Bitmuster über die ABI. Die Bridge umfasst Win32/WGL, Eingabe, Timing,
`waveOut`, Winsock, OpenGL 1.1, Mathematik und OGG-Dekodierung.

Der historische Builder lautet:

```powershell
python .\native\build_bridge.py --clean
```

Er bevorzugt `clang-cl`/`lld-link` und kann auf eine installierte x64-MSVC-
Toolchain zurückfallen. Der in dieser Baseline gelieferte Quellbaum enthält
allerdings nicht `third_party/stb/stb_vorbis.c`, obwohl `miniquake_ogg.c` diese
Datei einbindet. Die mitgelieferte Haupt-DLL wird deshalb statisch geprüft und
vorerst als vorgefertigtes Artefakt beibehalten.

## `miniquake_text.dll`

BP-000R1 ergänzt eine kleine, vollständig reproduzierbare Textbridge. Direkte
MiniLang-Externrückgaben vom Typ `cstr` können im verwendeten Win64-Compilerpfad
einen hoch adressierten DLL-Zeiger beschädigen. Die Textbridge ruft die
Legacy-Stringexporte innerhalb nativen 64-Bit-C-Codes auf und kopiert das
Ergebnis in einen von MiniLang übergebenen `bytes`-Puffer.

Build:

```powershell
python .\native\build_text_bridge.py --clean
```

Benötigt werden `clang-cl` und `lld-link`. Die DLL importiert lediglich
`GetModuleHandleW`, `LoadLibraryW` und `GetProcAddress` aus `kernel32.dll`.
Sie exportiert elf Funktionen für Floattext, ASCII, ConProc, UDP-/Hostnamen und
`glGetString`.

## Float-Rohwertpfad

`mq_f32_from_ml_raw` und `mq_f32_to_ml_raw` bleiben der kanonische Weg zwischen
MiniLang-Zahlen und Quakes 32-Bit-IEEE-754-Wörtern. Sie arbeiten mit
`nativeRawValue`/`nativeValueFromRaw` und vermeiden localeabhängige
Textkonvertierung im Enginepfad.

## Eingabe- und waveOut-Stabilität

Beim Aktivieren der Mausaufnahme wird der Cursor in die Clientmitte gesetzt;
der erste Sample nach Capture oder Fokuswechsel wird verworfen.
`mq_audio_submit` prüft alle acht `waveOut`-Header, damit ein aktiver Ringslot
keinen bereits abgeschlossenen Slot blockiert. Misch-, Loop- und
Spatializerlogik bleiben in MiniLang.

## Caller-owned text bridge (BP-000R1)

The MiniLang v1.0 Win64 backend can pass `bytes` payloads reliably, but the
first Windows acceptance run crashed at the first direct DLL `returns cstr`
conversion. `miniquake_text.dll` therefore resolves the twelve text
producers inside native 64-bit code, copies their NUL-terminated result into a
MiniLang-owned byte buffer and returns only the copied byte count as `u32`.

Build the small bridge independently with:

```powershell
python .\native\build_text_bridge.py --clean
```

The final link uses `/Brepro`; repeated builds from identical source and tool
versions are expected to produce the same DLL bytes. The main
`miniquake_native.dll` remains unchanged in BP-000R1.

The supplied baseline does not include `third_party/stb/stb_vorbis.c`, which is
needed for a complete rebuild of the main bridge. For that reason the verified
prebuilt main DLL remains part of this package, while the text bridge is fully
rebuildable from the included source.

### Fixed-six float formatting

`mqt_f32_to_fixed6` formats an IEEE-754 binary32 word through MSVCRT
`sprintf("%.6f", ...)` into caller-owned MiniLang bytes.  It is the authoritative
boundary for `Cvar_SetValue`, `ED_Write` and Quake-v5 savegame floats and avoids
the former signed-i32 overflow at values such as the stock item mask `4097`.
