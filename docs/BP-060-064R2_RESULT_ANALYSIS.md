# BP-060–BP-064: Auswertung des ersten Windows-Laufs

Der ursprüngliche, noch gepufferte BP-060–BP-064-Lauf wurde nicht abgebrochen,
sondern lief bis zur ersten fehlerhaften BP-061-Runtimefixture weiter. R1 wurde
nicht separat ausgeführt; seine Live-Output-Korrektur ist vollständig in R2
enthalten.

## Ergebnisgrenze

- allgemeiner Preflight: PASS
- 65 Windows executables / MiniLang-Ziele: erfolgreich kompiliert
- sämtliche historischen Testgruppen bis einschließlich BP-059: PASS
- BP-060 NET-main: 20/20 PASS
- BP-061 Control: Abbruch nach Fixture 19/24
- BP-062 bis BP-064 und externe Evidenz: wegen des frühen Abbruchs nicht erreicht

Die konkrete Runtime-Diagnose lautet:

```text
[19/24] rule enumeration
Error occured: no=1200 message=Cannot index void
  at network_control_parity_tests.ml:63 in main
```

Ergebnisarchiv:

```text
MiniQuake_BP-060-064_RESULTS_20260728-184449.zip
SHA-256: bde52d9bcb2e7052c3dcac5ee62dbe49dd3acd6887cbeabfc54c1f8b4916c719
```

## Originalsemantik

`net_dgrm.c` unterscheidet zwei Fälle bei `CCREQ_RULE_INFO`:

1. Ist der angegebene Vorgängername unbekannt, wird die Anfrage still ignoriert.
2. Wurde der letzte bekannte Server-Cvar erreicht, wird ein
   `CCREP_RULE_INFO`-Paket ohne nachfolgende Strings gesendet.

MiniQuake hatte beide Fälle intern als `void` repräsentiert. Der Serveradapter
übersetzte jedes `void` in ein Terminatorpaket. Die Testfixture erwartete dagegen
für das reguläre Ende ein leeres Feldpaar und indexierte deshalb den tatsächlich
gelieferten `void`-Wert.

## R2-Korrektur

`nextServerRule` verwendet nun eine eindeutige Darstellung:

```text
gefundenes Element  -> [name, value]
reguläres Listenende -> ["", ""]
unbekannter Vorgänger -> interner error/no-reply-Sentinel
```

Der Listener wertet `nextServerRule` mit `try(...)` aus und sendet nur dann
eine Antwort, wenn kein interner Fehler-Sentinel vorliegt. Das leere Feldpaar
wird über `replyRuleInfo("", "")` zum originalen command-only
Terminatorpaket. Ein unbekannter Vorgänger bleibt ohne Antwort.

Die Runtimefixture prüft jetzt alle drei Ebenen zusammenhängend:

- normale Enumeration,
- internes leeres Endpaar und command-only Wirepaket,
- stilles Ignorieren eines unbekannten Vorgängers.

Der BP-061-Checker, das Golden-Dokument und das unabhängige C-Oracle binden diese
Unterscheidung nun ausdrücklich. Die Fixturezahl bleibt 24; der Block bleibt bei
113 neuen Runtimefixtures.

## Live-Ausgabe

Die nicht gepufferte Ausgabe aus R1 ist in R2 enthalten. Compiler-, Preflight-
und Testausgaben werden zeilenweise sofort auf der Konsole angezeigt und
gleichzeitig mit Flush in die Logdateien geschrieben.
