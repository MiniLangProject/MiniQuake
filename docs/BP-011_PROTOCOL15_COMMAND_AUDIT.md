# BP-011 – Protocol-15-Kommando- und Fast-Update-Audit

## Referenz

Verglichen wurden die Stock-Quake-1.09-Pfade:

- `cl_main.c:CL_SignonReply`,
- `cl_parse.c:CL_ParseUpdate` und `CL_ParseServerMessage`,
- `host_cmd.c:Host_PreSpawn_f`, `Host_Spawn_f`, `Host_Begin_f`,
- `sv_main.c:SV_WriteEntitiesToClient`,
- `sv_user.c:SV_ReadClientMessage`,
- `protocol.h`.

## Signon

| Stufe | Clientantwort | Servermarker |
|---:|---|---:|
| 1 | `clc_stringcmd "prespawn"` | `svc_signonnum 1` |
| 2 | `name`, `color`, `spawn` | `svc_signonnum 2` |
| 3 | `begin` | `svc_signonnum 3` |
| 4 | kein Wireoutput | kein Marker; erstes Fast Update schließt Signon ab |

## Clientkommandos

Der Server liest den Kommandobytewert mit `MSG_ReadChar`. Daher ist `0xff`
`-1` und beendet die aktuelle Nachricht. Unterstützt und geordnet sind
`clc_nop`, `clc_disconnect`, `clc_move` und `clc_stringcmd`; Badread und
unbekannte Werte führen im Produktionspump zur Trennung des Clients.

## Fast Entity Updates

Die Bitwahl ist baseline-relativ und folgt dem Original in dieser Reihenfolge:
Origin 1–3, Angle 1–3, `MOVETYPE_STEP/U_NOLERP`, Colormap, Skin, Frame,
Effects, Model, Long Entity und schließlich MoreBits. Die Wirefelder werden in
exakt derselben Reihenfolge geschrieben wie in `sv_main.c`.

`EntityBaseline.effects` ist Bestandteil des Laufzeittyps. Stock Quake setzt es
beim Baselineaufbau nicht explizit und erhält daher null; MiniQuake speichert
denselben Wert explizit.

## Goldenkorpus

`audit/protocol15_commands_golden.json` bindet 14 Bytefolgen:

- vier Client-Signonantworten,
- drei Server-Signonmarker in einem Stream,
- zusammengesetzter CLC-Stream, Disconnect und signiertes EOM,
- unverändertes, effects-geändertes und Step-Fast-Update,
- vollständiges Short-/Long-Entity-Update,
- Katalog aller 33 gültigen SVC-Kommandos plus Fast Update.

Das C-Oracle liegt in `tools/oracle/protocol15_commands_oracle.c`; der
unabhängige Prüfer in `tools/check_protocol15_commands.py`.

## Sichere Abgrenzung

Dieses Paket behauptet noch keine vollständige Paket-Scheduling-Parität. Es
bindet Kommandoformate, Signonübergänge und Entity-Delta-Encoding. Reliable-
und Unreliable-Scheduling, Soundmasken, Clientdata-Seiteneffekte und sämtliche
Overflowpfade werden in den folgenden Protocol-Paketen weiter geschlossen.
