# MiniQuake BP-090–BP-094R10 – Ergebnisanalyse des R9-Windows-Laufs

## Ergebnisarchiv

```text
MiniQuake_BP-090-094R9_RESULTS_20260804-090239.zip
SHA-256: 7ed83829da1d775fe33d72b794af92994faa7798a6934665f1752812ebf9616c
```

## Bestätigter Stand

Der vollständige kumulative Build und sämtliche internen Testgruppen bis einschließlich BP-094 waren erfolgreich. Die verifizierte Originaldatei `GLQUAKE.EXE` wurde korrekt vorbereitet, die temporären Loopback-Firewallregeln wurden eingerichtet und anschließend wieder entfernt.

Der Lauf brach beim ersten externen Prozesspaar in der Richtung

```text
Original-GLQuake-Server → MiniQuake-Client
```

ab.

## Exakte Fehlergrenze

Der Originalprozess blieb während der gesamten Prüfung aktiv und erzeugte weder Standardausgabe noch Standardfehler. Vier MiniQuake-Clientprozesse versuchten innerhalb des bisherigen 30-Sekunden-Fensters die Verbindung zu:

```text
127.0.0.1:35090
```

Alle vier meldeten zunächst:

```text
UDP connect timed out
```

Danach startete jeweils der normale lokale Demo-/Map-Fallback. R9 erkannte diesen Zustand korrekt und lehnte ihn ab:

```text
transport=loop
remote=localhost:0
local_server_active=true
local_authoritative=true
demo_playback=false
network_provenance=invalid
result=FAIL
```

Die vier Summarys waren semantisch identisch:

```text
success=false
connected=true
spawned=true
signon=4
view_entity=1
model_count=86
sound_count=86
error=original-server interop completed signon without target UDP provenance
```

Damit ist die R9-Provenienzkorrektur bestätigt: Ein lokaler Signon kann nicht mehr fälschlich als Original-Binary-Interop gelten.

## Ursachenklassifikation

Der vorhandene R9-Harness gab dem 1997er GLQuake-Prozess nur 750 ms Vorlauf und anschließend insgesamt 30 Sekunden für vier vollständige MiniQuake-Verbindungsversuche. Er prüfte vor diesen Versuchen nicht, ob der Originalprozess bereits

1. sein Fenster und den WGL-Kontext erstellt,
2. die Welttexturen hochgeladen,
3. den UDP-Accept-Socket auf dem angeforderten Port gebunden und
4. seine Protocol-3-Ereignisschleife erreicht hatte.

Aus dem R9-Archiv lässt sich nicht beweisen, in welcher dieser Startphasen der Originalprozess noch war, weil `-condebug` wegen des bestätigten 1024-Byte-Pufferüberlaufs nicht verwendet werden darf. Fest steht jedoch:

- der Prozess war noch aktiv,
- es gab keinen Exitcode und keinen Stderr-Fehler,
- innerhalb des kurzen Zeitfensters kam keine UDP-Control-Antwort,
- frühere R7-Läufe haben denselben verifizierten Original-Binary-Pfad erfolgreich verbunden.

Die belastbarste Klassifikation lautet daher: **zeitabhängige Cold-Start-/Readiness-Lücke im externen Test-Harness**, nicht nachgewiesener Protocol- oder Enginefehler.

## R10-Korrektur

R10 startet keinen vollständigen MiniQuake-Client mehr, bevor ein echter Quake-Control-Handshake die Bereitschaft des Originalservers bewiesen hat.

Der Harness sendet wiederholt das originale Protocol-3-Paket:

```text
NETFLAG_CTL | length 12
CCREQ_SERVER_INFO
"QUAKE\0"
NET_PROTOCOL_VERSION = 3
```

Akzeptiert wird ausschließlich eine Antwort vom exakten Zielendpunkt mit:

```text
CCREP_SERVER_INFO
control protocol = 3
nicht leerem Mapnamen
```

Erst danach beginnt der Protocol-15-Interopclient. Der Standard-Readiness-Timeout beträgt 180 Sekunden und kann über `-OriginalServerReadyTimeoutMs` angepasst werden.

Zusätzlich werden die zufälligen Interopports vor dem Prozessstart durch eine echte Loopback-Bindung auf Verfügbarkeit geprüft.

Für jedes Originalserver-Paar entsteht ein Bericht:

```text
build/bp090-094r10-original-server-<a|b>-readiness.json
```

Dieser enthält unter anderem:

- Probeanzahl und Laufzeit,
- Antwortendpunkt,
- Serveradresse, Hostname und Map,
- Spielerzahlen und Control-Protokoll,
- Originalprozess-ID und Prozessstatus,
- beobachtete UDP-Endpunkte,
- letzte Socketdiagnose.

Ein Readiness-Timeout wird als `INFRA_FAILURE` eingeordnet und nicht MiniQuakes Protocol-15-Code zugerechnet.

## Änderungsgrenze

R10 verändert weder `src/` noch `native/`. MiniQuake-Engine, Renderer, Netzwerkprotokolle und native Bridges bleiben gegenüber R9 byteidentisch. Geändert werden ausschließlich Abnahme-Harness, Liefermetadaten, Dokumentation und Verifier-Vertrag.
