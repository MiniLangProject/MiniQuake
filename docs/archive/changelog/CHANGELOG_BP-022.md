# BP-022 – QuakeC-Edicts und Entity-/Save-Text

- `type_size[ev_void]` entspricht wieder dem Originalwert 1.
- Freigabe- und Wiederverwendungsgrenzen, High-Water-Mark und Feldreset werden
  explizit abgesichert.
- Unbekannte Entityfelder und Globals werden wie im Original protokolliert und
  anschließend übersprungen.
- Negative Null wird bei `%f`-ähnlicher Savegame-Ausgabe als `-0.000000`
  erhalten.
- BSP-Entitylumps und `ED_NewString` verwenden die Quake-Einbyte-ABI.
- `ED_PrintEdict_f` behandelt ungültige Nummern als nichtfatalen Kommandohinweis.
- 22 MiniLang-Fixtures und ein unabhängiges C-Oracle decken die Pfade ab.
