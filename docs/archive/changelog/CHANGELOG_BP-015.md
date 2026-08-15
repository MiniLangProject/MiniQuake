# Changelog BP-015 – Protocol-15-Signon

Elternstand: **BP-014R1**

## Änderungen

- `CL_SignonReply` schreibt seine Antwort ausschließlich in den zuverlässigen
  Clientpuffer; der Transport erfolgt erst in `CL_SendCmd`.
- `Host_PreSpawn_f` hängt Server-Signon und `svc_signonnum 2` an
  `client_t.message` an und setzt `sendsignon`, statt im Commandparser zu senden.
- `Host_Spawn_f` beginnt mit einem frischen zuverlässigen Clientpuffer, erzeugt
  den Spawnpayload und überlässt das Senden `SV_SendClientMessages`.
- Stufe 4 bleibt ein lokaler Zustandsübergang durch das erste Fast-Entity-Update;
  es gibt weiterhin kein synthetisches `svc_signonnum 4`.
- Die Farbausgabe folgt der C-`int`-Konvertierung, bevor Top-/Bottomcolor
  aufgeteilt werden.

## Evidenz

- C-Oracle: `tools/oracle/protocol15_signon_oracle.c`
- Goldenmodell: `audit/protocol15_signon_golden.json`
- MiniLang-Laufzeitfixtures: **12**
- Teilpatch: `patches/BP-015.diff`
