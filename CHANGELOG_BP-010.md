# MiniQuake BP-010 – Protocol 15 Wire Primitives

Datum: 2026-07-24  
Elternpaket: `BP-001R3`  
Zielprofil: `compat_109`

## Ausgangspunkt

BP-001R3 wurde unter Windows vollständig angenommen: Build, 16 Core-, 24
Milestone- und 10 Diagnosefixtures, `id1/start`, 120 Headless-Frames, zwei
byteidentische 64-Frame-Traces, Snapshot/Context/Summary und UDP-Loopback sind
grün. BP-010 ist das erste eigentliche Funktionsparitätspaket nach dieser
Diagnosebaseline.

## Portierte beziehungsweise gehärtete Originalsemantik

### `common.c`: `MSG_*`

- Release-Wrapping für Char, Byte, Short und Long bleibt bytegenau.
- Floatwerte für die integerbasierten Writer werden wie an der C-`int`-Aufrufgrenze gegen null abgeschnitten.
- `qboolean` wird wie das originale C-`int` als `0/1` akzeptiert.
- `MSG_WriteCoord` und die besondere Cast-Reihenfolge von `MSG_WriteAngle`
  werden durch Golden-Vektoren gesichert.
- Die C-`float`-Parametergrenze wird vor Skalierung und Cast explizit
  nachgebildet; das gilt auch für MiniLang-Integer-Aufrufer über `2^24`.
- Raw-Byte-Helfer für `MSG_WriteString` und `MSG_ReadString` wurden ergänzt.
- `MSG_WriteString` reserviert Payload und Abschluss-NUL wie das originale
  `SZ_Write(..., Q_strlen(s)+1)` atomar. Das behebt den bisher abweichenden
  Overflow-Neustart, wenn nur der Terminator nicht mehr in den Puffer passt.
- `MSG_WriteString` reserviert Payload und Abschluss-NUL in einem einzigen `SZ_GetSpace`-Schritt; dadurch stimmt auch der Overflow-Clear-Fall, in dem nur der Terminator nicht mehr in den Restpuffer passt.
- `MSG_ReadString` behält das 2047-Byte-Limit sowie die originale
  Signed-Char-`0xff`-Terminierung.
- Ein abgeschnittener Floatread bleibt eine dokumentierte sichere Abweichung:
  MiniQuake setzt `badRead` und liefert `-1.0`, statt außerhalb des Puffers zu
  lesen.

### Quake-C-Strings

MiniLang-Strings sind UTF-8; Quake-Protokollstrings sind rohe Einbyte-C-Strings.
`src/miniquake/protocol_text.ml` definiert daher die explizite ABI
`quake_latin1_cstring_v1`:

- U+0000..U+00FF werden reversibel auf 0x00..0xFF abgebildet.
- Das erste NUL beendet die zu sendende C-Zeichenkette wie `Q_strlen`.
- Zeichen außerhalb U+00FF werden abgelehnt, statt den Wire-Stream still als
  UTF-8 zu verändern.

Diese Adaptersemantik wird jetzt sowohl von `MSG_WriteString` als auch von
`SZ_Print` verwendet.

### `common.c`: `SZ_*`

- Exaktes Vollschreiben, erlaubtes Overflow-Clear und `overflowed`-Flag werden
  geprüft.
- `SZ_Print` überschreibt einen vorhandenen Abschluss-NUL und hängt sonst einen
  Abschluss-NUL an. Der Pfad ohne vorhandenen Terminator reserviert den vollständigen C-String atomar, wie `common.c`.
- Der originale undefinierte Sonderfall „vorhandener Abschluss-NUL plus erlaubter Overflow“ wird speichersicher als vollständiger String-Neustart definiert; das C-Original würde nach dem Buffer-Clear vor `data[0]` schreiben.
- Ein leerer Puffer wird speichersicher behandelt; der originale Zugriff auf
  `data[-1]` wird nicht nachgebildet.

### Komplette Referenznachrichten

Golden-Vektoren sichern zusätzlich:

- `cl_input.c:CL_SendMove`
- `sv_main.c:SV_CreateBaseline`-Payload
- ausgewählte Protocol-15-Konstanten aus `protocol.h`

## Neue Evidenz

- `tools/oracle/protocol15_common_oracle.c`: eigenständiges C-Oracle der
  relevanten Release-Semantik.
- `audit/protocol15_wire_golden.json`: dreizehn kanonische Bytefolgen.
- `tools/check_protocol15_vectors.py`: unabhängiges Pythonmodell, optionaler
  C-Compile/Run und Quellvertragsprüfung.
- `tests/protocol15_wire_tests.ml`: 15 MiniLang-Laufzeitfixtures.
- `MiniQuakeProtocol15WireTests.exe`: eigenes Buildziel.

## Nicht Teil von BP-010

BP-010 behauptet noch keine vollständige Protocol-15-Parität für alle
`svc_*`-/`clc_*`-Kommandos, Fast Entity Updates, Signon 1–4 oder Datagramm-
Fehlerpfade. Diese folgen in BP-011 bis BP-019. Renderer, QuakeC, Physik,
Savegames und Audio werden durch dieses Paket nicht absichtlich verändert.
