# MiniQuake BP-090–BP-094R6 – Ergebnisanalyse von R5

## Ergebnis des R5-Windows-Laufs

Der R5-Lauf bestätigte den vollständigen kumulativen Build, sämtliche internen
Tests, die Originalreferenz und beide Prozesspaare in der Richtung

```text
original GLQuake listen server -> MiniQuake client
```

Beide MiniQuake-Clients erreichten Protocol 15, Spawn und Signon 4. Die
normalisierten Berichte waren byteidentisch.

Der nächste Gate-Schritt startete einen MiniQuake-Server für den originalen
GLQuake-Client. Der Server schrieb erfolgreich:

```text
bp090-094r5-miniquake-server-original-client-a-ready.json
ready=true
port=47070
map=start
```

Danach endete der Runner mit:

```text
INFRA_FAILURE: MiniQuake original-client server a timed out after 45000 ms
```

Es entstand weder eine erfolgreiche Protocol-15-Summary noch ein
Originalclient-Prozessbericht. Der Benutzer beobachtete gleichzeitig die
interaktive Windows-Defender-Firewallabfrage. Da der Test unbeaufsichtigt lief,
wurde die Freigabe nicht bestätigt.

## Technische Einordnung

R5 band beide Programme bereits an `127.0.0.1`. Der Windows-Lauf zeigt jedoch,
dass eine reine Loopback-Bindung auf diesem Host die erstmalige
programmbezogene Windows-Defender-Firewallabfrage nicht zuverlässig
unterdrückt. Das ist ein Infrastrukturproblem, kein beobachteter Protocol-3-,
Protocol-15- oder MiniQuake-Gameplayfehler.

R6 behält die Loopback-Bindung bei und ergänzt vor den externen Interoptests
vier temporäre, exakte Programmregeln:

```text
MiniQuake.exe inbound UDP  127.0.0.1 -> 127.0.0.1
MiniQuake.exe outbound UDP 127.0.0.1 -> 127.0.0.1
GLQUAKE.EXE inbound UDP     127.0.0.1 -> 127.0.0.1
GLQUAKE.EXE outbound UDP    127.0.0.1 -> 127.0.0.1
```

Die Regeln gelten nur für die beiden exakt geprüften Executable-Pfade, nur für
UDP und nur für Loopback. Das Skript fordert Administratorrechte unmittelbar
vor dem langen Build an, sodass der Benutzer die UAC-Abfrage am Testanfang
bestätigt und den Rechner danach unbeaufsichtigt lassen kann. Die Regeln werden
in `finally` automatisch entfernt, auch nach einem späteren Testfehler.

R6 verändert keinen MiniQuake-Enginecode und keine native DLL.

## Bound infrastructure markers

R5 already removed the historical `INADDR_ANY` exposure by using loopback and
kept the visual original run at `-noudp -noipx`. The unattended Windows run
still encountered a **Windows Defender Firewall** approval dialog. R6 therefore
uses explicit loopback-only temporary rules rather than relying on interface
binding alone.
