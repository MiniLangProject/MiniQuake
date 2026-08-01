# BP-017 – Datagramm-Audit

## Originalpfade

- `net_dgrm.c`
- `net.h`
- `net_main.c`

## Wesentliche Korrektur

Ein ACK für ein Reliable-Fragment darf im reinen Kanalmodell nicht sofort ein
Folgepaket erzeugen, das der Transport unbemerkt verliert. Es setzt `sendNext`.
Der Socketbesitzer verarbeitet zunächst den Receive-Loop und flusht danach mit
`Datagram_FlushSendNext` das nächste Fragment.

## Gebundene Grenzen

- 32-Bit-Sequenz-Wrap,
- 1024-Byte-Fragmentgrenze und End-of-message-Bit,
- maximal acht Fragmente für `NET_MAXMESSAGE`,
- ACK, Duplikat-ACK und erneutes ACK bei doppelten Daten,
- Retransmission erst bei streng mehr als einer Sekunde,
- Unreliable-Paketlücken,
- Receive-Overflow,
- nebenwirkungsfreie `CanSendMessage`-Abfrage.

Das Goldenmodell enthält 18 Fälle; die MiniLang-Suite ebenfalls 18 Fixtures.
