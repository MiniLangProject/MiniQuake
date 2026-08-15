# BP-026 source audit – `world.c` entity linking and clipping

Compared original paths:

- `SV_UnlinkEdict`
- `SV_LinkEdict`
- `SV_TouchLinks`
- `SV_ClipToLinks`
- `SV_Move`
- `SV_TestEntityPosition`
- `SV_PushEntity`

MiniLang targets:

- `src/miniquake/world.ml`
- `src/miniquake/server_collision.ml`
- `src/miniquake/quakec/builtins.ml`

The block restores expanded absolute bounds, item expansion, area-node
membership, strict trigger overlap, owner filtering, point-entity filtering,
monster hull selection and relinking after movement. Fifteen runtime fixtures
and a standalone C oracle bind these decisions.
