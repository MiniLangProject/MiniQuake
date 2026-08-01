# BP-010 – Protocol-15- und SizeBuffer-Audit

## Referenz

Verglichen wurden die Releasepfade aus WinQuake/GLQuake 1.09:

| Original | MiniLang-Ziel | BP-010-Status |
|---|---|---|
| `common.c:SZ_Alloc/SZ_Free/SZ_Clear` | `sizebuf.ml` | direktes Pendant |
| `common.c:SZ_GetSpace/SZ_Write/SZ_Print` | `sizebuf.ml` | bytegenau auf definierten Pfaden, mit dokumentierter sicherer UB-Abweichung |
| `common.c:MSG_WriteChar/Byte/Short/Long/Float` | `message.ml` | bytegenau |
| `common.c:MSG_WriteString` | `message.ml` + `protocol_text.ml` | bytegenau für Quake-Einbyte-C-Strings |
| `common.c:MSG_WriteCoord/Angle` | `message.ml` | bytegenau |
| `common.c:MSG_ReadChar/Byte/Short/Long` | `message.ml` | semantisch gleich, `badRead` geprüft |
| `common.c:MSG_ReadFloat` | `message.ml` | gültige Daten exakt; Trunkierung speichersicher |
| `common.c:MSG_ReadString` | `message.ml` + `protocol_text.ml` | 2047-Limit und Signed-Char-Terminierung exakt |
| `common.c:MSG_ReadCoord/Angle` | `message.ml` | byte-/wertgleich |
| `protocol.h` relevante Konstanten | `constants.ml` | 18 Konstanten geprüft |
| `cl_input.c:CL_SendMove` Wirelayout | `protocol_write.ml`/`message.ml` | vollständiger Golden-Vektor |
| `sv_main.c:SV_CreateBaseline` Feldpayload | `protocol_write.ml`/`message.ml` | Golden-Vektor für eine Entity-Baseline |

## Wesentliche gefundene Lücke

Vor BP-010 verwendeten `MSG_WriteString` und `SZ_Print` direkt
`bytes(minilangString)`. Das ist UTF-8. Das originale Quake schreibt dagegen
`Q_strlen(s)+1` rohe Bytes. Schon ein einzelnes Zeichen mit Bytewert 0x80..0xFE
wurde deshalb in zwei UTF-8-Bytes umgewandelt und veränderte Paketlänge und
Inhalt.

BP-010 führt eine explizite Einbytegrenze ein:

```text
MiniLang Unicode U+0000..U+00FF <-> Quake byte 0x00..0xFF
```

Die Abbildung ist für alle nicht-NUL Bytes reversibel. Beim Schreiben endet die
Zeichenkette am ersten NUL wie beim C-`strlen`. Werte außerhalb U+00FF ergeben
einen Fehler, weil es dafür im originalen Wireformat keine eindeutige
Einbyteabbildung gibt. „Latin-1“ ist hier ausschließlich eine reversible
Trägerabbildung für Bytewerte; sie ersetzt nicht Quakes eigene Glyphentabelle.

## Golden-Vektoren

Die dreizehn Vektoren in `audit/protocol15_wire_golden.json` werden aus drei
unabhängigen Richtungen geprüft:

1. eigenständiges C-Oracle mit der Original-Reihenfolge der C-Operationen,
2. unabhängiges Pythonmodell,
3. MiniLang-Laufzeitfixtures.

| Vektor | Zweck | Hexbytes |
|---|---|---|
| `primitive_stream` | primitive MSG-Schreiboperationen | `fefe2efb78563412000048417175616b65009eff40` |
| `release_wrapping` | Release-Casts/Überläufe | `82ff4523feffffff` |
| `coord_angle_boundaries` | Truncation und Winkelquantisierung | `0000ffffff7f008000c0ff00` |
| `float_parameter_rounding` | C-float-Parameter vor Skalierung/Cast | `0000804b0100ffff1000f0ff01ff0000` |
| `raw_high_bit_string` | unveränderte Bytes >0x7f | `4180e9fe00` |
| `embedded_nul_string` | C-String-Abbruch | `4100` |
| `null_string` | `NULL`-String | `00` |
| `string_overflow_restart` | atomarer `MSG_WriteString`-Overflow | `787900` |
| `sz_print_concat` | NUL-Überschreiben | `6f6e6574776f00` |
| `sz_print_overflow_restart` | atomarer `SZ_Print`-Overflow ohne vorhandenen Terminator | `616200` |
| `sz_overflow_restart` | erlaubter Overflow/Clear | `0908` |
| `clc_move` | vollständiges Move-Paket | `03000048410880c0c80085ff00800307` |
| `baseline_payload` | Model/Frame/Colormap/Skin sowie Origin/Angles einer Entity-Baseline | `010203049eff400100c0ff7fff` |

## Reservierungs- und Overflow-Semantik

`MSG_WriteString` ruft im Original genau ein `SZ_Write` mit `Q_strlen(s)+1`
Bytes auf. Payload und Abschluss-NUL müssen daher gemeinsam reserviert werden.
Ist nur noch Platz für die Nutzbytes, leert ein erlaubter Overflow den gesamten
Puffer und die komplette Zeichenkette beginnt bei Offset 0. Der Vektor
`string_overflow_restart` sichert diese Grenze.

Der `SZ_Print`-Zweig ohne vorhandenen NUL reserviert aus demselben Grund
`strlen+1` Bytes in einem Schritt. `sz_print_overflow_restart` sichert diesen
Fall. Für `sz_print_concat` wird das C-Oracle zunächst mit einer gültigen
leeren C-Zeichenkette (`cursize=1`, Byte 0) initialisiert; dadurch misst das
Oracle nur definierte Originalsemantik und nicht den Zugriff auf `data[-1]`.

## Bewusste sichere Abweichungen

- Das Original liest in `MSG_ReadFloat` ohne Boundscheck. MiniQuake setzt bei
  weniger als vier Restbytes `badRead=true` und liefert `-1.0`.
- Das Original greift in `SZ_Print` bei `cursize==0` auf `data[-1]` zu.
  MiniQuake behandelt den leeren Puffer definiert und speichersicher.
- Beim originalen undefinierten `SZ_Print`-Sonderfall mit vorhandenem Abschluss-NUL und erlaubtem Overflow leert `SZ_GetSpace` den Buffer, worauf der C-Code einen Zeiger vor `data[0]` bildet. MiniQuake startet stattdessen sicher mit dem vollständigen neuen C-String neu und setzt `overflowed=true`.
- Originale `Sys_Error`-Abbrüche werden als MiniLang-`error(...)` propagiert,
  damit Tests und Hostfehler kontrolliert ausgewertet werden können.

Diese Abweichungen verändern keine gültigen Protocol-15-Bytefolgen.

## Abnahmegrenze

BP-010 gilt als angenommen, wenn unter Windows:

- alle bisherigen BP-001R3-Gates grün bleiben,
- die 15 MiniLang-Wirefixtures bestehen,
- das Python-/Golden-Modell besteht,
- die Paketkennung `Protocol text ABI: quake_latin1_cstring_v1` meldet,
- zwei `id1/start`-Traces weiterhin byteidentisch sind.
