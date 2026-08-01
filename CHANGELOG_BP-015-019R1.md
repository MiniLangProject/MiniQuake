# Changelog BP-015–BP-019R1 – Signon-Phasentest-Hotfix

Datum: 2026-07-25

Engine-Endstand: **BP-019**
Liefer-/Abnahmerevision: **BP-015-019R1**
Elternlieferung: **BP-015-019**

## Anlass

Die erste Windows-Abnahme des kumulativen Blocks kompilierte alle Ziele und
bestand sämtliche neuen BP-015- bis BP-019-Testprogramme, Echtdatenvalidierung,
300 Headless-Frames, zwei byteidentische 128-Frame-Traces sowie den UDP-Loopback.
Nur der historische Meilensteintest 20 schlug fehl:

```text
[20/24] complete loopback signon
FAIL: server consumes prespawn: expected 1, got 0
```

## Ursache

BP-015 korrigierte `CL_SignonReply` und die Server-Signonhandler nach dem
Original-C-Code: Parser und Commandhandler stellen Reliable-Daten lediglich in
die jeweiligen Buffer ein. Die Übertragung erfolgt erst in `CL_SendCmd` bzw.
`SV_SendClientMessages`/`sendReliableMessages` auf der regulären Host-Frame-
Phase. Der ältere Meilensteintest erwartete noch die zuvor vorhandene, nicht
originalgetreue Sofortübertragung innerhalb des Parsers.

## Änderung

`testLoopbackSignonHandshake` treibt nun jede Signonstufe über die korrekten
Phasengrenzen:

1. Parser stellt Clientantwort in `client.outgoing` ein.
2. Vor `CL_SendCmd` ist serverseitig noch keine Nachricht verfügbar.
3. `CL_SendCmd` überträgt die Clientantwort zuverlässig.
4. Der Serverhandler stellt die nächste Signonstufe in `client_t.message` ein.
5. Vor der Server-Reliable-Phase ist clientseitig noch keine Nachricht verfügbar.
6. `sendReliableMessages` überträgt die nächste Serverstufe.

Dies wird für `prespawn`, `name/color/spawn` und `begin` geprüft. Die
Produktionsimplementierung und sämtliche Protocol-15-Goldenwerte bleiben
unverändert.

## Diagnoseverbesserung

Der statische Verifier enthält den neuen Vertrag
`milestone_signon_phase_contract`. Er verhindert, dass der Basistest erneut die
alte Sofortübertragung voraussetzt.
