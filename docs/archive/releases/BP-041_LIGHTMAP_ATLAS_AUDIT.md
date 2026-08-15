# BP-041 audit – lightmap atlas and ownership

## Original reference

Primary source: `gl_rsurf.c`, especially `R_BuildLightMap`, `AllocBlock`,
`GL_CreateSurfaceLightmap` and `GL_BuildLightmaps`; lifecycle behavior from
`gl_rmisc.c`.

## Ported behavior

- Atlas geometry remains 128×128 with at most 64 pages.
- Surface extents determine exact lightmap width and height.
- One-byte luminance and four-byte RGBA destinations use their original row
  strides and channel packing.
- Fullbright/missing-lightdata surfaces use the expected maximum-light output.
- Cached lightstyle and dynamic-light state can invalidate an atlas region.
- Shared page texture IDs are deduplicated before deletion.

## Safe implementation differences

The MiniLang renderer owns explicit byte arrays and page records instead of C
pointer arithmetic. Bounds are checked before writes, so malformed dimensions
produce controlled errors rather than memory corruption.

## Evidence

The C oracle, golden file and 22 MiniLang fixtures cover required byte counts,
stride handling, luminance/RGBA output, fullbright behavior, cache state and
shared-page destruction.
