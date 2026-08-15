# BP-016 – Delivery-Audit

## Originalpfade

- `cl_main.c:CL_SendCmd`
- `sv_main.c:SV_SendClientMessages`, `SV_SendNop`
- `host.c:SV_DropClient`
- `net_main.c`

## Zustände

`protocol_delivery.ml` unterscheidet:

```text
SEND_DROP   – fataler Sendefehler oder ungültige Verbindung
SEND_RETAIN – blockiert beziehungsweise temporär nicht committed
SEND_COMMIT – Wire-Send wurde übernommen; Puffer darf geleert werden
```

Die Prüfung bindet insbesondere:

- kein Leeren bei Sendresultat `0`,
- Overflow vor `dropasap`,
- blockierter Drop bleibt pending,
- Signon-Keepalive erst bei streng mehr als fünf Sekunden,
- normale Reliable-Nachricht, Signonanforderung und Keepalive bleiben getrennt,
- Client und Server verwenden denselben Commitvertrag.

14 Oraclefälle und 14 MiniLang-Fixtures bilden die Grenze ab.
