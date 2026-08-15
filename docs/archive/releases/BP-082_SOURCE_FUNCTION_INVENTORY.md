# BP-082 source function inventory

The deterministic extractor scans 53 selected WinQuake/GLQuake C translation
units. Functions must begin in column zero, matching the released source style;
comments are removed while line numbers are preserved. Static helpers count.

Results for `compat_109`:

- 1,120 definitions discovered
- 26 definitions in positive `QUAKE2` regions excluded
- 1,094 target definitions
- 1,081 exact-name MiniLang functions
- 9 explicit-context adapters
- 4 technical equivalents
- 0 unclassified definitions

The inventory is stored in `audit/source_function_inventory.json`.
