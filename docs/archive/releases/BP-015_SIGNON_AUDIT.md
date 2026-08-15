# BP-015 – Signon-Audit

## Originalpfade

- `cl_main.c:CL_SignonReply`
- `cl_parse.c` – Signonnum und erstes Fast Update
- `host_cmd.c:Host_PreSpawn_f`, `Host_Spawn_f`, `Host_Begin_f`
- `sv_main.c:SV_SendClientMessages`
- `protocol.h`

## Gebundene Semantik

1. Stufe 1 queueiert `prespawn`.
2. Stufe 2 queueiert `name`, `color` und `spawn`.
3. Stufe 3 queueiert `begin`.
4. Stufe 4 schreibt keine Nachricht; das erste Fast Update aktiviert den Client.
5. Client- und Server-Commandparser senden nicht selbst, sondern füllen den
   jeweiligen Reliable-Puffer.
6. Blockierte Verbindungen behalten die komplette Signon-Nachricht.
7. `Host_Spawn_f` startet mit einem frischen Clientmessage-Puffer.

Die sechs Goldenvektoren und sechs Semantikfälle stehen in
`audit/protocol15_signon_golden.json`; zwölf Laufzeitfixtures prüfen Writer,
Parser, Queuegrenzen und Transportphase.
