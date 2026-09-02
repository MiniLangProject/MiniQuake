# `src/miniquake/render/particles.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.render.particles`](Package-miniquake-render-particles-596966822.md)

Reachable from entry: **yes**

## Imports

- `miniquake/mathlib.ml` as `math` → [src/miniquake/mathlib.ml](File-src-miniquake-mathlib-ml-2131866431.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/render/gl11.ml` as `gl` → [src/miniquake/render/gl11.ml](File-src-miniquake-render-gl11-ml-805308144.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)

## Declarations

<a id="function-function-miniquake-render-particles-configureenhancedparticles-function-configureenhancedparticles-enabled-src-miniquake-render-particles-ml-753933449"></a>
### ConfigureEnhancedParticles

```ml
function ConfigureEnhancedParticles(enabled)
```

Switch particle presentation without changing the simulation particle list.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `enabled` | `dynamic` | — | Whether the optional behavior is enabled. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/particles.ml#L85)

<a id="global-global-miniquake-render-particles-dottexture-dottexture-src-miniquake-render-particles-ml-896935792"></a>
### dotTexture

```ml
dotTexture
```

Tracks the module-level dot texture state owned by `miniquake.render.particles`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/particles.ml#L28)

<a id="function-function-miniquake-render-particles-drawparticlebatch-function-drawparticlebatch-count-vieworigin-viewforward-viewup-viewright-src-miniquake-render-particles-ml-228935103"></a>
### drawParticleBatch

```ml
function drawParticleBatch(count, viewOrigin, viewForward, viewUp, viewRight)
```

Submit the populated prefix of the reusable particle staging buffer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `count` | `dynamic` | — | Number of entries or units to process. |
| `viewOrigin` | `dynamic` | — | The view origin input consumed by `drawParticleBatch`. |
| `viewForward` | `dynamic` | — | The view forward input consumed by `drawParticleBatch`. |
| `viewUp` | `dynamic` | — | The view up input consumed by `drawParticleBatch`. |
| `viewRight` | `dynamic` | — | The view right input consumed by `drawParticleBatch`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/particles.ml#L178)

<a id="global-global-miniquake-render-particles-enhancedparticles-enhancedparticles-src-miniquake-render-particles-ml-1474930488"></a>
### enhancedParticles

```ml
enhancedParticles
```

Tracks the module-level enhanced particles state owned by `miniquake.render.particles`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/particles.ml#L18)

<a id="function-function-miniquake-render-particles-ensureparticlebatch-function-ensureparticlebatch-src-miniquake-render-particles-ml-1704988814"></a>
### ensureParticleBatch

```ml
function ensureParticleBatch()
```

Allocate the reusable particle staging buffer before the first rendered effect.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/particles.ml#L165)

<a id="function-function-miniquake-render-particles-palettecolor-function-palettecolor-palette-index-src-miniquake-render-particles-ml-1206011089"></a>
### paletteColor

```ml
function paletteColor(palette, index)
```

Implements the `paletteColor` operation for `miniquake.render.particles` (palette color).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `palette` | `dynamic` | — | The palette input consumed by `paletteColor`. |
| `index` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/particles.ml#L138)

<a id="constant-constant-miniquake-render-particles-particle-batch-capacity-const-particle-batch-capacity-8192-src-miniquake-render-particles-ml-1721955269"></a>
### PARTICLE_BATCH_CAPACITY

```ml
const PARTICLE_BATCH_CAPACITY = 8192
```

Defines the particle batch capacity value used by `miniquake.render.particles`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/particles.ml#L22)

<a id="constant-constant-miniquake-render-particles-particle-batch-record-bytes-const-particle-batch-record-bytes-16-src-miniquake-render-particles-ml-606480134"></a>
### PARTICLE_BATCH_RECORD_BYTES

```ml
const PARTICLE_BATCH_RECORD_BYTES = 16
```

Defines the particle batch record bytes value used by `miniquake.render.particles`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/particles.ml#L20)

<a id="global-global-miniquake-render-particles-particlebatch-particlebatch-src-miniquake-render-particles-ml-1949644796"></a>
### particleBatch

```ml
particleBatch
```

Allocate this sizeable scratch buffer on first use.  Keeping it out of the module initializer also keeps command-line/file inspection tools lightweight.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/particles.ml#L25)

<a id="function-function-miniquake-render-particles-particlebatchfloatbits-inline-function-particlebatchfloatbits-value-src-miniquake-render-particles-ml-1695932786"></a>
### particleBatchFloatBits

```ml
inline function particleBatchFloatBits(value)
```

Return particle batch float bits derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `particleBatchFloatBits`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/particles.ml#L147)

<a id="function-function-miniquake-render-particles-particlegeometry-function-particlegeometry-particle-vieworigin-viewforward-viewup-viewright-src-miniquake-render-particles-ml-1492442684"></a>
### particleGeometry

```ml
function particleGeometry(particle, viewOrigin, viewForward, viewUp, viewRight)
```

Implements the `particleGeometry` operation for `miniquake.render.particles` (particle geometry).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `particle` | `dynamic` | — | The particle input consumed by `particleGeometry`. |
| `viewOrigin` | `dynamic` | — | The view origin input consumed by `particleGeometry`. |
| `viewForward` | `dynamic` | — | The view forward input consumed by `particleGeometry`. |
| `viewUp` | `dynamic` | — | The view up input consumed by `particleGeometry`. |
| `viewRight` | `dynamic` | — | The view right input consumed by `particleGeometry`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/particles.ml#L206)

<a id="global-global-miniquake-render-particles-particletexture-particletexture-src-miniquake-render-particles-ml-1943084288"></a>
### particleTexture

```ml
particleTexture
```

Tracks the module-level particle texture state owned by `miniquake.render.particles`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/particles.ml#L16)

<a id="function-function-miniquake-render-particles-particletexturepixels-function-particletexturepixels-src-miniquake-render-particles-ml-1413050514"></a>
### particleTexturePixels

```ml
function particleTexturePixels()
```

Implements the `particleTexturePixels` operation for `miniquake.render.particles` (particle texture pixels).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/particles.ml#L40)

<a id="function-function-miniquake-render-particles-prepareparticletexturestate-function-prepareparticletexturestate-src-miniquake-render-particles-ml-1704665048"></a>
### prepareParticleTextureState

```ml
function prepareParticleTextureState()
```

Restore the single-texture state assumed by GLQuake's particle pass.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/particles.ml#L94)

<a id="function-function-miniquake-render-particles-putparticlebatchword-inline-function-putparticlebatchword-offset-value-src-miniquake-render-particles-ml-1592016255"></a>
### putParticleBatchWord

```ml
inline function putParticleBatchWord(offset, value)
```

Encode and write particle batch word.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |
| `value` | `dynamic` | — | Value consumed by `putParticleBatchWord`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/particles.ml#L156)

<a id="function-function-miniquake-render-particles-r-drawparticlestrace-function-r-drawparticlestrace-particles-vieworigin-viewforward-viewup-viewright-src-miniquake-render-particles-ml-328586455"></a>
### R_DrawParticlesTrace

```ml
function R_DrawParticlesTrace(particles, viewOrigin, viewForward, viewUp, viewRight)
```

Apply the Quake-compatible r draw particles trace behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `particles` | `dynamic` | — | The particles input consumed by `R_DrawParticlesTrace`. |
| `viewOrigin` | `dynamic` | — | The view origin input consumed by `R_DrawParticlesTrace`. |
| `viewForward` | `dynamic` | — | The view forward input consumed by `R_DrawParticlesTrace`. |
| `viewUp` | `dynamic` | — | The view up input consumed by `R_DrawParticlesTrace`. |
| `viewRight` | `dynamic` | — | The view right input consumed by `R_DrawParticlesTrace`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/particles.ml#L227)

<a id="function-function-miniquake-render-particles-r-initparticletexture-function-r-initparticletexture-src-miniquake-render-particles-ml-85900202"></a>
### R_InitParticleTexture

```ml
function R_InitParticleTexture()
```

Implements the `R_InitParticleTexture` operation for `miniquake.render.particles` (r init particle texture).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/particles.ml#L110)

<a id="function-function-miniquake-render-particles-r-shutdownparticletexture-function-r-shutdownparticletexture-src-miniquake-render-particles-ml-577465282"></a>
### R_ShutdownParticleTexture

```ml
function R_ShutdownParticleTexture()
```

Release the particle texture before the active renderer context is replaced.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/particles.ml#L125)

<a id="function-function-miniquake-render-particles-render-function-render-particles-palette-src-miniquake-render-particles-ml-431834728"></a>
### render

```ml
function render(particles, palette)
```

Compatibility entry point used by the integrated renderer until its view vectors are passed explicitly.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `particles` | `dynamic` | — | The particles input consumed by `render`. |
| `palette` | `dynamic` | — | The palette input consumed by `render`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/particles.ml#L304)

<a id="function-function-miniquake-render-particles-rendertemporary-function-rendertemporary-effects-currenttime-palette-src-miniquake-render-particles-ml-1297561583"></a>
### renderTemporary

```ml
function renderTemporary(effects, currentTime, palette)
```

Render temporary.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `effects` | `dynamic` | — | The effects input consumed by `renderTemporary`. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |
| `palette` | `dynamic` | — | The palette input consumed by `renderTemporary`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/particles.ml#L319)

<a id="function-function-miniquake-render-particles-renderview-function-renderview-particles-palette-vieworigin-viewforward-viewup-viewright-src-miniquake-render-particles-ml-731325784"></a>
### renderView

```ml
function renderView(particles, palette, viewOrigin, viewForward, viewUp, viewRight)
```

Render view.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `particles` | `dynamic` | — | The particles input consumed by `renderView`. |
| `palette` | `dynamic` | — | The palette input consumed by `renderView`. |
| `viewOrigin` | `dynamic` | — | The view origin input consumed by `renderView`. |
| `viewForward` | `dynamic` | — | The view forward input consumed by `renderView`. |
| `viewUp` | `dynamic` | — | The view up input consumed by `renderView`. |
| `viewRight` | `dynamic` | — | The view right input consumed by `renderView`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/particles.ml#L258)

<a id="function-function-miniquake-render-particles-softparticletexturepixels-function-softparticletexturepixels-src-miniquake-render-particles-ml-1579902094"></a>
### softParticleTexturePixels

```ml
function softParticleTexturePixels()
```

Build a softly feathered circular sprite for the Enhanced particle pass.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/particles.ml#L59)
