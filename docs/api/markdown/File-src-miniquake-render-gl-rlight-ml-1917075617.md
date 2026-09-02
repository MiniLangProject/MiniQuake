# `src/miniquake/render/gl_rlight.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.render.gl_rlight`](Package-miniquake-render-gl-rlight-341311995.md)

Reachable from entry: **yes**

## Imports

- `miniquake/array_util.ml` as `arrayutil` → [src/miniquake/array_util.ml](File-src-miniquake-array-util-ml-1490619700.md)
- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/mathlib.ml` as `math` → [src/miniquake/mathlib.ml](File-src-miniquake-mathlib-ml-2131866431.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)

## Declarations

<a id="function-function-miniquake-render-gl-rlight-addlightblend-function-addlightblend-blend-red-green-blue-alpha2-src-miniquake-render-gl-rlight-ml-2094660669"></a>
### AddLightBlend

```ml
function AddLightBlend(blend, red, green, blue, alpha2)
```

Add state for add light blend.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `blend` | `dynamic` | — | The blend input consumed by `AddLightBlend`. |
| `red` | `dynamic` | — | The red input consumed by `AddLightBlend`. |
| `green` | `dynamic` | — | The green input consumed by `AddLightBlend`. |
| `blue` | `dynamic` | — | The blue input consumed by `AddLightBlend`. |
| `alpha2` | `dynamic` | — | The alpha2 input consumed by `AddLightBlend`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rlight.ml#L72)

<a id="global-global-miniquake-render-gl-rlight-animatedlightstylebytes-animatedlightstylebytes-src-miniquake-render-gl-rlight-ml-2110708774"></a>
### animatedLightStyleBytes

```ml
animatedLightStyleBytes
```

Tracks the module-level animated light style bytes state owned by `miniquake.render.gl_rlight`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rlight.ml#L25)

<a id="global-global-miniquake-render-gl-rlight-animatedlightstylesources-animatedlightstylesources-src-miniquake-render-gl-rlight-ml-1112934274"></a>
### animatedLightStyleSources

```ml
animatedLightStyleSources
```

Tracks the module-level animated light style sources state owned by `miniquake.render.gl_rlight`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rlight.ml#L23)

<a id="function-function-miniquake-render-gl-rlight-fastlighthit-function-fastlighthit-src-miniquake-render-gl-rlight-ml-1908350022"></a>
### FastLightHit

```ml
function FastLightHit()
```

Implements the `FastLightHit` operation for `miniquake.render.gl_rlight` (fast light hit).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rlight.ml#L444)

<a id="global-global-miniquake-render-gl-rlight-fastlighthit-fastlighthit-src-miniquake-render-gl-rlight-ml-169535820"></a>
### fastLightHit

```ml
fastLightHit
```

Tracks the module-level fast light hit state owned by `miniquake.render.gl_rlight`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rlight.ml#L332)

<a id="function-function-miniquake-render-gl-rlight-fastlightplane-function-fastlightplane-src-miniquake-render-gl-rlight-ml-1517155834"></a>
### FastLightPlane

```ml
function FastLightPlane()
```

Implements the `FastLightPlane` operation for `miniquake.render.gl_rlight` (fast light plane).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rlight.ml#L454)

<a id="global-global-miniquake-render-gl-rlight-fastlightplane-fastlightplane-src-miniquake-render-gl-rlight-ml-301863926"></a>
### fastLightPlane

```ml
fastLightPlane
```

Tracks the module-level fast light plane state owned by `miniquake.render.gl_rlight`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rlight.ml#L330)

<a id="function-function-miniquake-render-gl-rlight-fastlightspotz-function-fastlightspotz-src-miniquake-render-gl-rlight-ml-641044658"></a>
### FastLightSpotZ

```ml
function FastLightSpotZ()
```

Implements the `FastLightSpotZ` operation for `miniquake.render.gl_rlight` (fast light spot z).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rlight.ml#L449)

<a id="global-global-miniquake-render-gl-rlight-fastlightspotz-fastlightspotz-src-miniquake-render-gl-rlight-ml-214929670"></a>
### fastLightSpotZ

```ml
fastLightSpotZ
```

Allocation-free production variant.  Alias lighting traces a vertical ray, so x/y remain constant and only the z interval changes during BSP descent. Keeping the recursive result scalar avoids one Vec3 plus one three-element result array at every visited node for every visible alias entity.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rlight.ml#L328)

<a id="function-function-miniquake-render-gl-rlight-fastplanedistance-inline-function-fastplanedistance-plane-x-y-z-src-miniquake-render-gl-rlight-ml-1351476448"></a>
### fastPlaneDistance

```ml
inline function fastPlaneDistance(plane, x, y, z)
```

Implements the `fastPlaneDistance` operation for `miniquake.render.gl_rlight` (fast plane distance).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `plane` | `dynamic` | — | The plane input consumed by `fastPlaneDistance`. |
| `x` | `dynamic` | — | The x input consumed by `fastPlaneDistance`. |
| `y` | `dynamic` | — | The y input consumed by `fastPlaneDistance`. |
| `z` | `dynamic` | — | The z input consumed by `fastPlaneDistance`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rlight.ml#L339)

<a id="function-function-miniquake-render-gl-rlight-planedistance-function-planedistance-plane-point-src-miniquake-render-gl-rlight-ml-1729616964"></a>
### planeDistance

```ml
function planeDistance(plane, point)
```

Implements the `planeDistance` operation for `miniquake.render.gl_rlight` (plane distance).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `plane` | `dynamic` | — | The plane input consumed by `planeDistance`. |
| `point` | `dynamic` | — | The point input consumed by `planeDistance`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rlight.ml#L167)

<a id="function-function-miniquake-render-gl-rlight-r-animatelight-function-r-animatelight-lightstyles-currenttime-src-miniquake-render-gl-rlight-ml-100767928"></a>
### R_AnimateLight

```ml
function R_AnimateLight(lightStyles, currentTime)
```

Apply the Quake-compatible r animate light behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `lightStyles` | `dynamic` | — | The light styles input consumed by `R_AnimateLight`. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rlight.ml#L62)

<a id="function-function-miniquake-render-gl-rlight-r-animatelightinto-function-r-animatelightinto-lightstyles-currenttime-values-src-miniquake-render-gl-rlight-ml-395401990"></a>
### R_AnimateLightInto

```ml
function R_AnimateLightInto(lightStyles, currentTime, values)
```

Apply the Quake-compatible r animate light into behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `lightStyles` | `dynamic` | — | The light styles input consumed by `R_AnimateLightInto`. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |
| `values` | `dynamic` | — | The values input consumed by `R_AnimateLightInto`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rlight.ml#L31)

<a id="function-function-miniquake-render-gl-rlight-r-lightpoint-function-r-lightpoint-map-surfaces-lightstylevalues-rootnode-point-src-miniquake-render-gl-rlight-ml-2002062769"></a>
### R_LightPoint

```ml
function R_LightPoint(map, surfaces, lightStyleValues, rootNode, point)
```

Apply the Quake-compatible r light point behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `R_LightPoint`. |
| `surfaces` | `dynamic` | — | The surfaces input consumed by `R_LightPoint`. |
| `lightStyleValues` | `dynamic` | — | The light style values input consumed by `R_LightPoint`. |
| `rootNode` | `dynamic` | — | The root node input consumed by `R_LightPoint`. |
| `point` | `dynamic` | — | The point input consumed by `R_LightPoint`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rlight.ml#L316)

<a id="function-function-miniquake-render-gl-rlight-r-lightpointvalue-function-r-lightpointvalue-map-surfaces-lightstylevalues-rootnode-point-src-miniquake-render-gl-rlight-ml-1605396625"></a>
### R_LightPointValue

```ml
function R_LightPointValue(map, surfaces, lightStyleValues, rootNode, point)
```

Apply the Quake-compatible r light point value behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `R_LightPointValue`. |
| `surfaces` | `dynamic` | — | The surfaces input consumed by `R_LightPointValue`. |
| `lightStyleValues` | `dynamic` | — | The light style values input consumed by `R_LightPointValue`. |
| `rootNode` | `dynamic` | — | The root node input consumed by `R_LightPointValue`. |
| `point` | `dynamic` | — | The point input consumed by `R_LightPointValue`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rlight.ml#L433)

<a id="function-function-miniquake-render-gl-rlight-r-marklights-function-r-marklights-map-surfacebits-surfaceframes-framecount-light-bit-nodenumber-src-miniquake-render-gl-rlight-ml-1997491864"></a>
### R_MarkLights

```ml
function R_MarkLights(map, surfaceBits, surfaceFrames, frameCount, light, bit, nodeNumber)
```

Apply the Quake-compatible r mark lights behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `R_MarkLights`. |
| `surfaceBits` | `dynamic` | — | The surface bits input consumed by `R_MarkLights`. |
| `surfaceFrames` | `dynamic` | — | The surface frames input consumed by `R_MarkLights`. |
| `frameCount` | `dynamic` | — | Number of entries or units to process. |
| `light` | `dynamic` | — | The light input consumed by `R_MarkLights`. |
| `bit` | `dynamic` | — | The bit input consumed by `R_MarkLights`. |
| `nodeNumber` | `dynamic` | — | The node number input consumed by `R_MarkLights`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rlight.ml#L182)

<a id="function-function-miniquake-render-gl-rlight-r-pushdlights-function-r-pushdlights-map-surfacebits-surfaceframes-framecount-dynamiclights-currenttime-rootnode-src-miniquake-render-gl-rlight-ml-1762355050"></a>
### R_PushDlights

```ml
function R_PushDlights(map, surfaceBits, surfaceFrames, frameCount, dynamicLights, currentTime, rootNode)
```

Apply the Quake-compatible r push dlights behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `R_PushDlights`. |
| `surfaceBits` | `dynamic` | — | The surface bits input consumed by `R_PushDlights`. |
| `surfaceFrames` | `dynamic` | — | The surface frames input consumed by `R_PushDlights`. |
| `frameCount` | `dynamic` | — | Number of entries or units to process. |
| `dynamicLights` | `dynamic` | — | The dynamic lights input consumed by `R_PushDlights`. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |
| `rootNode` | `dynamic` | — | The root node input consumed by `R_PushDlights`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rlight.ml#L220)

<a id="function-function-miniquake-render-gl-rlight-r-renderdlight-function-r-renderdlight-light-currenttime-vieworigin-viewforward-viewright-viewup-blend-src-miniquake-render-gl-rlight-ml-770887737"></a>
### R_RenderDlight

```ml
function R_RenderDlight(light, currentTime, viewOrigin, viewForward, viewRight, viewUp, blend)
```

Apply the Quake-compatible r render dlight behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `light` | `dynamic` | — | The light input consumed by `R_RenderDlight`. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |
| `viewOrigin` | `dynamic` | — | The view origin input consumed by `R_RenderDlight`. |
| `viewForward` | `dynamic` | — | The view forward input consumed by `R_RenderDlight`. |
| `viewRight` | `dynamic` | — | The view right input consumed by `R_RenderDlight`. |
| `viewUp` | `dynamic` | — | The view up input consumed by `R_RenderDlight`. |
| `blend` | `dynamic` | — | The blend input consumed by `R_RenderDlight`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rlight.ml#L127)

<a id="function-function-miniquake-render-gl-rlight-r-renderdlights-function-r-renderdlights-dynamiclights-currenttime-vieworigin-viewforward-viewright-viewup-blend-src-miniquake-render-gl-rlight-ml-355615953"></a>
### R_RenderDlights

```ml
function R_RenderDlights(dynamicLights, currentTime, viewOrigin, viewForward, viewRight, viewUp, blend)
```

Apply the Quake-compatible r render dlights behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `dynamicLights` | `dynamic` | — | The dynamic lights input consumed by `R_RenderDlights`. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |
| `viewOrigin` | `dynamic` | — | The view origin input consumed by `R_RenderDlights`. |
| `viewForward` | `dynamic` | — | The view forward input consumed by `R_RenderDlights`. |
| `viewRight` | `dynamic` | — | The view right input consumed by `R_RenderDlights`. |
| `viewUp` | `dynamic` | — | The view up input consumed by `R_RenderDlights`. |
| `blend` | `dynamic` | — | The blend input consumed by `R_RenderDlights`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rlight.ml#L139)

<a id="function-function-miniquake-render-gl-rlight-r-renderdlighttrace-function-r-renderdlighttrace-light-currenttime-vieworigin-viewforward-viewright-viewup-blend-src-miniquake-render-gl-rlight-ml-1606759513"></a>
### R_RenderDlightTrace

```ml
function R_RenderDlightTrace(light, currentTime, viewOrigin, viewForward, viewRight, viewUp, blend)
```

Apply the Quake-compatible r render dlight trace behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `light` | `dynamic` | — | The light input consumed by `R_RenderDlightTrace`. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |
| `viewOrigin` | `dynamic` | — | The view origin input consumed by `R_RenderDlightTrace`. |
| `viewForward` | `dynamic` | — | The view forward input consumed by `R_RenderDlightTrace`. |
| `viewRight` | `dynamic` | — | The view right input consumed by `R_RenderDlightTrace`. |
| `viewUp` | `dynamic` | — | The view up input consumed by `R_RenderDlightTrace`. |
| `blend` | `dynamic` | — | The blend input consumed by `R_RenderDlightTrace`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rlight.ml#L94)

<a id="function-function-miniquake-render-gl-rlight-recursivelightpoint-function-recursivelightpoint-map-surfaces-lightstylevalues-nodenumber-start-finish-src-miniquake-render-gl-rlight-ml-1938632707"></a>
### RecursiveLightPoint

```ml
function RecursiveLightPoint(map, surfaces, lightStyleValues, nodeNumber, start, finish)
```

Implements the `RecursiveLightPoint` operation for `miniquake.render.gl_rlight` (recursive light point).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `RecursiveLightPoint`. |
| `surfaces` | `dynamic` | — | The surfaces input consumed by `RecursiveLightPoint`. |
| `lightStyleValues` | `dynamic` | — | The light style values input consumed by `RecursiveLightPoint`. |
| `nodeNumber` | `dynamic` | — | The node number input consumed by `RecursiveLightPoint`. |
| `start` | `dynamic` | — | The start input consumed by `RecursiveLightPoint`. |
| `finish` | `dynamic` | — | The finish input consumed by `RecursiveLightPoint`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rlight.ml#L240)

<a id="function-function-miniquake-render-gl-rlight-recursivelightpointvalue-function-recursivelightpointvalue-map-surfaces-lightstylevalues-nodenumber-x-y-startz-finishz-src-miniquake-render-gl-rlight-ml-1902253158"></a>
### RecursiveLightPointValue

```ml
function RecursiveLightPointValue(map, surfaces, lightStyleValues, nodeNumber, x, y, startZ, finishZ)
```

Return recursive light point value derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `RecursiveLightPointValue`. |
| `surfaces` | `dynamic` | — | The surfaces input consumed by `RecursiveLightPointValue`. |
| `lightStyleValues` | `dynamic` | — | The light style values input consumed by `RecursiveLightPointValue`. |
| `nodeNumber` | `dynamic` | — | The node number input consumed by `RecursiveLightPointValue`. |
| `x` | `dynamic` | — | The x input consumed by `RecursiveLightPointValue`. |
| `y` | `dynamic` | — | The y input consumed by `RecursiveLightPointValue`. |
| `startZ` | `dynamic` | — | The start z input consumed by `RecursiveLightPointValue`. |
| `finishZ` | `dynamic` | — | The finish z input consumed by `RecursiveLightPointValue`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rlight.ml#L355)

<a id="function-function-miniquake-render-gl-rlight-recursiveshadowray-function-recursiveshadowray-map-surfaces-nodenumber-startx-starty-startz-finishx-finishy-finishz-startfraction-finishfraction-src-miniquake-render-gl-rlight-ml-167054583"></a>
### RecursiveShadowRay

```ml
function RecursiveShadowRay(map, surfaces, nodeNumber, startX, startY, startZ, finishX, finishY, finishZ, startFraction, finishFraction)
```

Walk the render BSP from the ray origin toward its endpoint and retain the first actual world polygon.  Scalar coordinates keep thousands of shadow rays per frame free of temporary Vec3 and result-array allocations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `RecursiveShadowRay`. |
| `surfaces` | `dynamic` | — | The surfaces input consumed by `RecursiveShadowRay`. |
| `nodeNumber` | `dynamic` | — | The node number input consumed by `RecursiveShadowRay`. |
| `startX` | `dynamic` | — | The start x input consumed by `RecursiveShadowRay`. |
| `startY` | `dynamic` | — | The start y input consumed by `RecursiveShadowRay`. |
| `startZ` | `dynamic` | — | The start z input consumed by `RecursiveShadowRay`. |
| `finishX` | `dynamic` | — | The finish x input consumed by `RecursiveShadowRay`. |
| `finishY` | `dynamic` | — | The finish y input consumed by `RecursiveShadowRay`. |
| `finishZ` | `dynamic` | — | The finish z input consumed by `RecursiveShadowRay`. |
| `startFraction` | `dynamic` | — | The start fraction input consumed by `RecursiveShadowRay`. |
| `finishFraction` | `dynamic` | — | The finish fraction input consumed by `RecursiveShadowRay`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rlight.ml#L539)

<a id="function-function-miniquake-render-gl-rlight-shadowpointinsidesurface-function-shadowpointinsidesurface-surface-plane-x-y-z-src-miniquake-render-gl-rlight-ml-1672278786"></a>
### shadowPointInsideSurface

```ml
function shadowPointInsideSurface(surface, plane, x, y, z)
```

Test a BSP-plane intersection against the real convex render polygon rather than only its lightmap rectangle.  The latter can extend beyond sloped or clipped faces and would let a projected shadow jump through a nearby wall.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `surface` | `dynamic` | — | The surface input consumed by `shadowPointInsideSurface`. |
| `plane` | `dynamic` | — | The plane input consumed by `shadowPointInsideSurface`. |
| `x` | `dynamic` | — | The x input consumed by `shadowPointInsideSurface`. |
| `y` | `dynamic` | — | The y input consumed by `shadowPointInsideSurface`. |
| `z` | `dynamic` | — | The z input consumed by `shadowPointInsideSurface`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rlight.ml#L497)

<a id="function-function-miniquake-render-gl-rlight-shadowray-function-shadowray-map-surfaces-rootnode-startx-starty-startz-finishx-finishy-finishz-src-miniquake-render-gl-rlight-ml-1696764017"></a>
### ShadowRay

```ml
function ShadowRay(map, surfaces, rootNode, startX, startY, startZ, finishX, finishY, finishZ)
```

Trace one arbitrary segment against the rendered BSP surfaces.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `ShadowRay`. |
| `surfaces` | `dynamic` | — | The surfaces input consumed by `ShadowRay`. |
| `rootNode` | `dynamic` | — | The root node input consumed by `ShadowRay`. |
| `startX` | `dynamic` | — | The start x input consumed by `ShadowRay`. |
| `startY` | `dynamic` | — | The start y input consumed by `ShadowRay`. |
| `startZ` | `dynamic` | — | The start z input consumed by `ShadowRay`. |
| `finishX` | `dynamic` | — | The finish x input consumed by `ShadowRay`. |
| `finishY` | `dynamic` | — | The finish y input consumed by `ShadowRay`. |
| `finishZ` | `dynamic` | — | The finish z input consumed by `ShadowRay`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rlight.ml#L616)

<a id="global-global-miniquake-render-gl-rlight-shadowrayfinishx-shadowrayfinishx-src-miniquake-render-gl-rlight-ml-1819297984"></a>
### shadowRayFinishX

```ml
shadowRayFinishX
```

Tracks the module-level shadow ray finish x state owned by `miniquake.render.gl_rlight`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rlight.ml#L483)

<a id="global-global-miniquake-render-gl-rlight-shadowrayfinishy-shadowrayfinishy-src-miniquake-render-gl-rlight-ml-712486250"></a>
### shadowRayFinishY

```ml
shadowRayFinishY
```

Tracks the module-level shadow ray finish y state owned by `miniquake.render.gl_rlight`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rlight.ml#L485)

<a id="global-global-miniquake-render-gl-rlight-shadowrayfinishz-shadowrayfinishz-src-miniquake-render-gl-rlight-ml-460848448"></a>
### shadowRayFinishZ

```ml
shadowRayFinishZ
```

Tracks the module-level shadow ray finish z state owned by `miniquake.render.gl_rlight`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rlight.ml#L487)

<a id="function-function-miniquake-render-gl-rlight-shadowrayfraction-function-shadowrayfraction-src-miniquake-render-gl-rlight-ml-503529722"></a>
### ShadowRayFraction

```ml
function ShadowRayFraction()
```

Return the normalized fraction of the latest world-surface hit.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rlight.ml#L668)

<a id="global-global-miniquake-render-gl-rlight-shadowrayfraction-shadowrayfraction-src-miniquake-render-gl-rlight-ml-343449818"></a>
### shadowRayFraction

```ml
shadowRayFraction
```

Tracks the module-level shadow ray fraction state owned by `miniquake.render.gl_rlight`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rlight.ml#L475)

<a id="function-function-miniquake-render-gl-rlight-shadowrayhit-function-shadowrayhit-src-miniquake-render-gl-rlight-ml-952416574"></a>
### ShadowRayHit

```ml
function ShadowRayHit()
```

Report whether the latest arbitrary shadow segment reached a world polygon.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rlight.ml#L633)

<a id="global-global-miniquake-render-gl-rlight-shadowrayhit-shadowrayhit-src-miniquake-render-gl-rlight-ml-1049954840"></a>
### shadowRayHit

```ml
shadowRayHit
```

Allocation-free state for arbitrary world-surface shadow rays.  Unlike the vertical light sampler, this path records a complete 3-D receiver and the normalized fraction along the submitted segment.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rlight.ml#L461)

<a id="function-function-miniquake-render-gl-rlight-shadowraynormalx-function-shadowraynormalx-src-miniquake-render-gl-rlight-ml-752255414"></a>
### ShadowRayNormalX

```ml
function ShadowRayNormalX()
```

Return the oriented latest receiver normal x coordinate.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rlight.ml#L653)

<a id="global-global-miniquake-render-gl-rlight-shadowraynormalx-shadowraynormalx-src-miniquake-render-gl-rlight-ml-1625453852"></a>
### shadowRayNormalX

```ml
shadowRayNormalX
```

Tracks the module-level shadow ray normal x state owned by `miniquake.render.gl_rlight`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rlight.ml#L469)

<a id="function-function-miniquake-render-gl-rlight-shadowraynormaly-function-shadowraynormaly-src-miniquake-render-gl-rlight-ml-1042529950"></a>
### ShadowRayNormalY

```ml
function ShadowRayNormalY()
```

Return the oriented latest receiver normal y coordinate.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rlight.ml#L658)

<a id="global-global-miniquake-render-gl-rlight-shadowraynormaly-shadowraynormaly-src-miniquake-render-gl-rlight-ml-1537343698"></a>
### shadowRayNormalY

```ml
shadowRayNormalY
```

Tracks the module-level shadow ray normal y state owned by `miniquake.render.gl_rlight`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rlight.ml#L471)

<a id="function-function-miniquake-render-gl-rlight-shadowraynormalz-function-shadowraynormalz-src-miniquake-render-gl-rlight-ml-1719552898"></a>
### ShadowRayNormalZ

```ml
function ShadowRayNormalZ()
```

Return the oriented latest receiver normal z coordinate.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rlight.ml#L663)

<a id="global-global-miniquake-render-gl-rlight-shadowraynormalz-shadowraynormalz-src-miniquake-render-gl-rlight-ml-612249868"></a>
### shadowRayNormalZ

```ml
shadowRayNormalZ
```

Tracks the module-level shadow ray normal z state owned by `miniquake.render.gl_rlight`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rlight.ml#L473)

<a id="global-global-miniquake-render-gl-rlight-shadowraystartx-shadowraystartx-src-miniquake-render-gl-rlight-ml-1732829786"></a>
### shadowRayStartX

```ml
shadowRayStartX
```

Tracks the module-level shadow ray start x state owned by `miniquake.render.gl_rlight`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rlight.ml#L477)

<a id="global-global-miniquake-render-gl-rlight-shadowraystarty-shadowraystarty-src-miniquake-render-gl-rlight-ml-680684310"></a>
### shadowRayStartY

```ml
shadowRayStartY
```

Tracks the module-level shadow ray start y state owned by `miniquake.render.gl_rlight`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rlight.ml#L479)

<a id="global-global-miniquake-render-gl-rlight-shadowraystartz-shadowraystartz-src-miniquake-render-gl-rlight-ml-641808314"></a>
### shadowRayStartZ

```ml
shadowRayStartZ
```

Tracks the module-level shadow ray start z state owned by `miniquake.render.gl_rlight`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rlight.ml#L481)

<a id="function-function-miniquake-render-gl-rlight-shadowrayx-function-shadowrayx-src-miniquake-render-gl-rlight-ml-1349626082"></a>
### ShadowRayX

```ml
function ShadowRayX()
```

Return the latest shadow receiver x coordinate.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rlight.ml#L638)

<a id="global-global-miniquake-render-gl-rlight-shadowrayx-shadowrayx-src-miniquake-render-gl-rlight-ml-1681882230"></a>
### shadowRayX

```ml
shadowRayX
```

Tracks the module-level shadow ray x state owned by `miniquake.render.gl_rlight`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rlight.ml#L463)

<a id="function-function-miniquake-render-gl-rlight-shadowrayy-function-shadowrayy-src-miniquake-render-gl-rlight-ml-1240625814"></a>
### ShadowRayY

```ml
function ShadowRayY()
```

Return the latest shadow receiver y coordinate.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rlight.ml#L643)

<a id="global-global-miniquake-render-gl-rlight-shadowrayy-shadowrayy-src-miniquake-render-gl-rlight-ml-304135784"></a>
### shadowRayY

```ml
shadowRayY
```

Tracks the module-level shadow ray y state owned by `miniquake.render.gl_rlight`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rlight.ml#L465)

<a id="function-function-miniquake-render-gl-rlight-shadowrayz-function-shadowrayz-src-miniquake-render-gl-rlight-ml-573888750"></a>
### ShadowRayZ

```ml
function ShadowRayZ()
```

Return the latest shadow receiver z coordinate.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rlight.ml#L648)

<a id="global-global-miniquake-render-gl-rlight-shadowrayz-shadowrayz-src-miniquake-render-gl-rlight-ml-1345713362"></a>
### shadowRayZ

```ml
shadowRayZ
```

Tracks the module-level shadow ray z state owned by `miniquake.render.gl_rlight`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rlight.ml#L467)
