# OPT-001CR3R4 – Analyse des CR3R3-Buildfehlers

Der CR3R3-Paketverifier war grün, aber der erste MiniLang-Zielbuild brach ab:

```text
CompileError: Function check expects 2 args, got 1
  at src/miniquake/zone.ml:272
  return check(state)
```

Die package-freie Testdatei `tests/opt001cr3_hotpath_tests.ml` definierte einen globalen Helfer `check(condition, label)`. MiniLang führt den Programmeinstieg und seine Importclosure zu einem Programm zusammen. Der globale Testhelfer überschattete deshalb den internen unqualifizierten Aufruf `miniquake.zone.check(state)`.

CR3R4 benennt den Testhelfer und seine Zähler eindeutig mit `opt001cr3r4` vor. Zusätzlich prüft der Paketverifier alle package-freien Programmeinstiege gegen ihre transitive Importclosure auf Arity-Kollisionen. Der vormals ausgelieferte CR3R3-Baum wird von diesem neuen Check mit genau dem beobachteten Konflikt abgelehnt; CR3R4 enthält keinen solchen Konflikt.

Außerdem wurde eine zweite, bisher noch nicht erreichte Inkonsistenz korrigiert: Der Hotpath-Test erwartete Fingerprint `0x1c001c06`, während `build_info.ml` bereits `0x1c001c08` enthielt. CR3R4 bindet Test und Buildinfo konsistent an `0x1c001c09`.

Die produktiven Inline-, Array-, Builder-, Trace- und Live-Output-Optimierungen bleiben unverändert.
