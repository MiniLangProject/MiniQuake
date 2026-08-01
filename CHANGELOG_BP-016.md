# Changelog BP-016 – Reliable-/Unreliable-Planung

Elternstand: **BP-015**

## Änderungen

- Neue gemeinsame Entscheidungsschicht `protocol_delivery.ml`.
- Negative Sendresultate trennen den Client, `0` behält den Puffer für einen
  späteren Versuch, nur ein positiver Commit leert die zuverlässige Nachricht.
- Client und Server verwenden dieselbe Commit-/Retain-/Drop-Semantik.
- Der Signon-Keepalive bleibt bei exakt fünf Sekunden aus und wird erst für
  `elapsed > 5.0` erzeugt.
- Overflow, `dropasap`, blockierte Sockets, Signonanforderung und normale
  Reliable-Nachrichten besitzen getrennte Planungsfälle.

## Evidenz

- C-Oracle: `tools/oracle/protocol15_delivery_oracle.c`
- Goldenmodell: `audit/protocol15_delivery_golden.json`
- MiniLang-Laufzeitfixtures: **14**
- Teilpatch: `patches/BP-016.diff`
