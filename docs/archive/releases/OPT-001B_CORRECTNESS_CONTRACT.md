# OPT-001B Korrektheitsvertrag

- aktiver Viewmodel-Tiefenbereich: `min .. min + 0.3 * (max-min)`
- Wiederherstellung des exakten vorherigen Tiefenbereichs
- keine `void`-Zuweisung über einen BSP-Texturarrayindex
- lineare Unterwasser-Markierung über Leafs und Marksurfaces
- `e1m2`: 1.000 sichtbare und 10.000 Headless-Frames
- Kartenfolge: `e1m1 -> e1m2 -> e1m1`
- Handlefolge mit einmaligem `+1` und anschließend stabilen Fenstern: `PLATEAU`
