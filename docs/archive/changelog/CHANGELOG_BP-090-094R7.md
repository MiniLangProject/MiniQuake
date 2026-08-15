# MiniQuake BP-090–BP-094R7

- Originalclient verbindet nun mit `connect 127.0.0.1` und erhält den Zielport
  über die historische Option `-port`/`net_hostport`.
- Der nicht funktionierende Token `connect 127.0.0.1:PORT` wurde entfernt.
- Ursache ist die Originalkette `Cmd_TokenizeString -> COM_Parse ->
  Host_Connect_f/Cmd_Argv(1)`.
- Originalclient und MiniQuake-Server werden während des Signons parallel
  überwacht.
- Fehlerberichte enthalten Prozessstatus, Exitcode, Portquelle, Summarystatus
  und konkrete Fehlermeldung.
- Temporäre loopback-only Firewallregeln aus R6 bleiben erhalten und werden
  automatisch entfernt.
- Kein MiniLang-Enginecode und keine native DLL wurden verändert.
