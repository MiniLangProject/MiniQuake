# MiniQuake BP-090–BP-094R7 – Ergebnisanalyse von R6

## Ergebnisgrenze

Der Windows-Lauf `MiniQuake_BP-090-094R6_RESULTS_20260803-083905.zip`
(SHA-256 `e1988837c2599e81f4e73236308fd3f776a94461b5ccc8c4cffd46505d53cb04`)
bestand den vollständigen Build und alle 91 internen Laufzeitgruppen. Auch die erste
externe Richtung war zweimal erfolgreich:

```text
Original-GLQuake-Server -> MiniQuake-Client
connected=true spawned=true protocol=15 signon=4
```

Die Gegenrichtung blieb dagegen beim ersten Paar stehen:

```text
MiniQuake-Server ready=true port=42773 map=start
INFRA_FAILURE: MiniQuake original-client server a timed out after 45000 ms
```

Die temporären Windows Defender Firewall-Regeln waren installiert, exakt auf beide
Programme und UDP-Loopback `127.0.0.1` beschränkt und wurden anschließend wieder
entfernt. Der MiniQuake-Server war laut `ready.json` vollständig betriebsbereit.

## Exakte Ursache

R6 schrieb in `interop.cfg`:

```text
connect 127.0.0.1:42773
```

Das sieht modern und korrekt aus, entspricht aber nicht der historischen
Kommando-Tokenisierung von Quake 1.09:

1. `Cmd_TokenizeString` liest jedes Argument über `COM_Parse`.
2. `COM_Parse` behandelt `:` ausdrücklich als einzelnes Satzzeichen-Token.
3. Die Zeile wird daher in `connect`, `127.0.0.1`, `:`, `42773` zerlegt.
4. `Host_Connect_f` kopiert ausschließlich `Cmd_Argv(1)`.
5. Der Originalclient verbindet sich deshalb zu `127.0.0.1` mit dem bestehenden
   `net_hostport`.
6. Ohne eine passende `-port`-Option ist dieser Port weiterhin der Standardwert
   `26000`.

Der R6-Server lauschte dagegen auf dem zufällig gewählten Port `42773`. Der
Originalclient lief weiter, sendete seine Anfrage aber an Port `26000`. Deshalb
sah der MiniQuake-Server innerhalb von 45000 ms keine Verbindung.

Der Fehler war somit weder ein Firewall-, Protocol-3-, Protocol-15- noch ein
MiniQuake-Serverfehler. Er lag im Test-Harness und in der Annahme, dass die
Originalkonsole einen modernen `host:port`-Token unverändert an `Host_Connect_f`
weitergibt.

## R7-Korrektur

R7 nutzt die historische Portübergabe:

```text
Programmargument: -port 42773
Konsolenkommando: connect 127.0.0.1
```

`NET_Init` übernimmt `-port` in `DEFAULTnet_hostport` und `net_hostport`.
`Host_Connect_f` erhält über `Cmd_Argv(1)` nur den unveränderten Hosttoken
`127.0.0.1`; der Datagramm-Treiber ergänzt den Port aus `net_hostport`.

Zusätzlich überwacht R7 Originalclient und MiniQuake-Server parallel. Bei einem
weiteren Fehler enthält der Prozessbericht:

- gestarteter Clientprozess,
- Prozessstatus und Exitcode,
- verwendeter Connect-Token,
- Portquelle `-port`,
- Vorhandensein der Protocol-15-Summary,
- Serverprozessstatus und konkrete Fehlermeldung.

## Unveränderte Sicherheitsmaßnahmen

Die in R6 eingeführten temporären Regeln bleiben erhalten:

- Windows Defender Firewall wird nicht deaktiviert.
- Vier temporäre Regeln erlauben ausschließlich UDP für die exakten Pfade von
  `MiniQuake.exe` und dem verifizierten `GLQUAKE.EXE`.
- Lokale und entfernte Adresse sind jeweils `127.0.0.1`.
- Die Regeln werden in einem `finally`-Block automatisch entfernt.
- Originale visuelle Läufe verwenden weiterhin `-noudp -noipx`.
- `INADDR_ANY` wird in den Interopprozessen nicht verwendet.
- Der Lauf bleibt nach einer einmaligen UAC-Bestätigung unattended ausführbar.

## Änderungsumfang

R7 verändert keinen MiniQuake-Enginecode und keine native DLL. Geändert werden
nur PowerShell-Harness, statische Vertragsprüfung, Dokumentation, Manifest und
Liefermetadaten.

The inherited firewall setup remains loopback-only; the four temporary rules are removed during cleanup.
