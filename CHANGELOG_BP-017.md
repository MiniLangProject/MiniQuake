# Changelog BP-017 – Datagramm, ACK und Retransmission

Elternstand: **BP-016**

## Änderungen

- Ein passendes ACK markiert `sendNext`, erzeugt aber nicht mehr innerhalb der
  reinen Kanalroutine sofort das nächste Wirepaket.
- `Datagram_FlushSendNext` sendet den nächsten Fragmentblock nach dem
  vollständig abgearbeiteten Receive-Loop, wie `net_dgrm.c`.
- `Datagram_CanSendMessage` ist im reinen MiniLang-Kanal jetzt frei von
  versteckten Seiteneffekten.
- `net_loop.pumpRemote` verarbeitet alle bereits anstehenden Pakete und flusht
  anschließend genau ein markiertes Folgefragment.
- Sequenz-Wrap, exakte Fragmentgrenzen, Duplikat-ACK, Paketlücken,
  Retransmission nach `> 1s` und Receive-Overflow sind gebunden.

## Evidenz

- C-Oracle: `tools/oracle/protocol15_datagram_oracle.c`
- Goldenmodell: `audit/protocol15_datagram_golden.json`
- MiniLang-Laufzeitfixtures: **18**
- Teilpatch: `patches/BP-017.diff`
