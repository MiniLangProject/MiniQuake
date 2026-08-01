# Changelog BP-015–BP-019 – kumulativer Protocol-15-Abschlussblock

Elternbasis: **BP-014R1**, unter Windows vollständig angenommen.
Finales Paket: **BP-019**.

Der Block führt fünf logisch getrennte, aufeinander aufbauende Schritte in
nur einer Lieferung zusammen:

| Schritt | Thema | neue Fixtures |
|---|---|---:|
| BP-015 | Signon-Queue und Stufen 1–4 | 12 |
| BP-016 | Reliable-/Unreliable-Planung | 14 |
| BP-017 | Datagramm, ACK, Fragmentierung und Retransmission | 18 |
| BP-018 | Demo-Framing, Aufnahme und Wiedergabe | 19 |
| BP-019 | Cross-Layer-Abschluss und Protocol-Freeze | 15 |
| **Summe** |  | **78** |

Der kumulative Test baut den Endstand einmal, führt alle unabhängigen
Testprogramme weiter aus und erzeugt bei Fehlern eine logische Zuordnung zum
ersten betroffenen Teilpaket. Die fünf Teilpatches liegen unter `patches/`.

`protocol15_frozen_v1` bedeutet: Die anhand des vorliegenden Original-C-Codes
abgedeckte Protocol-15-Implementierung wird nach einer grünen Windows-Abnahme
als stabiler Contract behandelt. Das ist **kein** Claim einer bereits
abgeschlossenen Original-Binary-Interopmatrix; solche Mehrprozessläufe bleiben
ein späteres externes Gate.
