# BP-073 model asset audit

BP-073 checks the observable `gl_model.c` model-loading surface:

- BSP version 29, 15 lumps, entity text, textures, visibility, lighting, geometry and submodels;
- alias MDL version 6, grouped skins and frames, texture coordinates, triangles and flood fill;
- sprite version 1, grouped frames, positive intervals and computed bounds;
- model registry dispatch, case-sensitive names, alias cache retention, touch/extradata and brush submodels.

The test data is synthetic and contains no Quake retail assets.

- `Mod_LoadSubmodels` expands every BSP submodel minimum by -1 and maximum by +1, matching the original one-pixel safety spread.
