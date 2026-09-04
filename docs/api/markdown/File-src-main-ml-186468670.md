# `src/main.ml`

[Home](README.md) · [Files](Files.md)

Package: [`(global)`](Package-global-1952375359.md)

Reachable from entry: **yes**

## Imports

- `miniquake/build_info.ml` as `buildInfo` → [src/miniquake/build_info.ml](File-src-miniquake-build-info-ml-1156326101.md)
- `miniquake/byteio.ml` as `bio` → [src/miniquake/byteio.ml](File-src-miniquake-byteio-ml-1921171264.md)
- `miniquake/client_protocol.ml` as `protocol` → [src/miniquake/client_protocol.ml](File-src-miniquake-client-protocol-ml-948659732.md)
- `miniquake/compat_trace.ml` as `compatTrace` → [src/miniquake/compat_trace.ml](File-src-miniquake-compat-trace-ml-702455550.md)
- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/crc.ml` as `crc` → [src/miniquake/crc.ml](File-src-miniquake-crc-ml-699476266.md)
- `miniquake/demo.ml` as `demo` → [src/miniquake/demo.ml](File-src-miniquake-demo-ml-103505867.md)
- `miniquake/demo_player.ml` as `demoPlayer` → [src/miniquake/demo_player.ml](File-src-miniquake-demo-player-ml-1504569459.md)
- `miniquake/external_reference_contract.ml` as `externalReference` → [src/miniquake/external_reference_contract.ml](File-src-miniquake-external-reference-contract-ml-1714794236.md)
- `miniquake/filesystem.ml` as `qfs` → [src/miniquake/filesystem.ml](File-src-miniquake-filesystem-ml-1964591079.md)
- `miniquake/format/bsp.ml` as `bsp` → [src/miniquake/format/bsp.ml](File-src-miniquake-format-bsp-ml-22292029.md)
- `miniquake/format/mdl.ml` as `mdl` → [src/miniquake/format/mdl.ml](File-src-miniquake-format-mdl-ml-1455458127.md)
- `miniquake/format/progs.ml` as `progs` → [src/miniquake/format/progs.ml](File-src-miniquake-format-progs-ml-1508573313.md)
- `miniquake/format/sprite.ml` as `sprite` → [src/miniquake/format/sprite.ml](File-src-miniquake-format-sprite-ml-531278995.md)
- `miniquake/game_validation.ml` as `gameValidation` → [src/miniquake/game_validation.ml](File-src-miniquake-game-validation-ml-659223540.md)
- `miniquake/gl_smoke.ml` as `smoke` → [src/miniquake/gl_smoke.ml](File-src-miniquake-gl-smoke-ml-367199401.md)
- `miniquake/host.ml` as `host` → [src/miniquake/host.ml](File-src-miniquake-host-ml-652298408.md)
- `miniquake/launch.ml` as `launch` → [src/miniquake/launch.ml](File-src-miniquake-launch-ml-1123847567.md)
- `miniquake/map_viewer.ml` as `viewer` → [src/miniquake/map_viewer.ml](File-src-miniquake-map-viewer-ml-135597961.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/net_udp.ml` as `udp` → [src/miniquake/net_udp.ml](File-src-miniquake-net-udp-ml-1891257481.md)
- `miniquake/pak.ml` as `pak` → [src/miniquake/pak.ml](File-src-miniquake-pak-ml-44503636.md)
- `miniquake/runtime_validation.ml` as `runtimeValidation` → [src/miniquake/runtime_validation.ml](File-src-miniquake-runtime-validation-ml-1833083800.md)
- `miniquake/sound/mixer.ml` as `mixer` → [src/miniquake/sound/mixer.ml](File-src-miniquake-sound-mixer-ml-2037667391.md)
- `miniquake/sound/wav.ml` as `wav` → [src/miniquake/sound/wav.ml](File-src-miniquake-sound-wav-ml-1458929962.md)
- `miniquake/sys_win.ml` as `sysWin` → [src/miniquake/sys_win.ml](File-src-miniquake-sys-win-ml-1437273508.md)
- `miniquake/wad.ml` as `wad` → [src/miniquake/wad.ml](File-src-miniquake-wad-ml-1195240084.md)
- `std/fs.ml` as `fs` → `../MiniLangCompilerOptimization/MiniLangCompilerPy/std/fs.ml` — external dependency

## Declarations

<a id="function-function-boundedinteger-function-boundedinteger-text-fallback-minimum-maximum-src-main-ml-2078565130"></a>
### boundedInteger

```ml
function boundedInteger(text, fallback, minimum, maximum)
```

Return a validated bounded integer value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |
| `fallback` | `dynamic` | — | Value to use when the requested input is unavailable or invalid. |
| `minimum` | `dynamic` | — | Smallest accepted value. |
| `maximum` | `dynamic` | — | Largest accepted value. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/main.ml#L305)

<a id="function-function-fail-function-fail-result-src-main-ml-71615752"></a>
### fail

```ml
function fail(result)
```

Report the requested value and return the corresponding failure status.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `result` | `dynamic` | — | Result value to report or translate into a status code. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/main.ml#L113)

<a id="function-function-gameoption-function-gameoption-arguments-src-main-ml-1705094857"></a>
### gameOption

```ml
function gameOption(arguments)
```

Implements the `gameOption` operation for `MiniQuake` (game option).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/main.ml#L315)

<a id="function-function-hasnamedoption-function-hasnamedoption-arguments-name-src-main-ml-1986810892"></a>
### hasNamedOption

```ml
function hasNamedOption(arguments, name)
```

Report whether named option.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/main.ml#L349)

<a id="function-function-headlessarguments-function-headlessarguments-basedirectory-mapname-gamedirectory-src-main-ml-368446601"></a>
### headlessArguments

```ml
function headlessArguments(baseDirectory, mapName, gameDirectory)
```

Implements the `headlessArguments` operation for `MiniQuake` (headless arguments).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `baseDirectory` | `dynamic` | — | Root directory containing the Quake installation. |
| `mapName` | `dynamic` | — | Name of the map to load or inspect. |
| `gameDirectory` | `dynamic` | — | Selected Quake game-data directory. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/main.ml#L387)

<a id="function-function-inspectbsp-function-inspectbsp-filename-src-main-ml-732316692"></a>
### inspectBsp

```ml
function inspectBsp(filename)
```

Inspect bsp and emit its decoded metadata.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `filename` | `dynamic` | — | Path of the file to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/main.ml#L198)

<a id="function-function-inspectdemo-function-inspectdemo-filename-src-main-ml-1044511482"></a>
### inspectDemo

```ml
function inspectDemo(filename)
```

Inspect demo and emit its decoded metadata.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `filename` | `dynamic` | — | Path of the file to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/main.ml#L253)

<a id="function-function-inspectmdl-function-inspectmdl-filename-src-main-ml-258041300"></a>
### inspectMdl

```ml
function inspectMdl(filename)
```

Inspect mdl and emit its decoded metadata.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `filename` | `dynamic` | — | Path of the file to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/main.ml#L210)

<a id="function-function-inspectmessage-function-inspectmessage-filename-src-main-ml-237146764"></a>
### inspectMessage

```ml
function inspectMessage(filename)
```

Inspect message and emit its decoded metadata.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `filename` | `dynamic` | — | Path of the file to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/main.ml#L278)

<a id="function-function-inspectogg-function-inspectogg-filename-src-main-ml-1840528328"></a>
### inspectOgg

```ml
function inspectOgg(filename)
```

Inspect ogg and emit its decoded metadata.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `filename` | `dynamic` | — | Path of the file to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/main.ml#L120)

<a id="function-function-inspectpack-function-inspectpack-filename-src-main-ml-1648359382"></a>
### inspectPack

```ml
function inspectPack(filename)
```

Inspect pack and emit its decoded metadata.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `filename` | `dynamic` | — | Path of the file to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/main.ml#L180)

<a id="function-function-inspectprogs-function-inspectprogs-filename-src-main-ml-1036085912"></a>
### inspectProgs

```ml
function inspectProgs(filename)
```

Inspect progs and emit its decoded metadata.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `filename` | `dynamic` | — | Path of the file to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/main.ml#L231)

<a id="function-function-inspectsprite-function-inspectsprite-filename-src-main-ml-391850106"></a>
### inspectSprite

```ml
function inspectSprite(filename)
```

Inspect sprite and emit its decoded metadata.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `filename` | `dynamic` | — | Path of the file to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/main.ml#L221)

<a id="function-function-inspectwad-function-inspectwad-filename-src-main-ml-286910952"></a>
### inspectWad

```ml
function inspectWad(filename)
```

Inspect wad and emit its decoded metadata.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `filename` | `dynamic` | — | Path of the file to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/main.ml#L189)

<a id="function-function-inspectwav-function-inspectwav-filename-src-main-ml-456530276"></a>
### inspectWav

```ml
function inspectWav(filename)
```

Inspect wav and emit its decoded metadata.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `filename` | `dynamic` | — | Path of the file to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/main.ml#L242)

<a id="function-function-integernamedoption-function-integernamedoption-arguments-name-fallback-minimum-maximum-src-main-ml-822775468"></a>
### integerNamedOption

```ml
function integerNamedOption(arguments, name, fallback, minimum, maximum)
```

Implements the `integerNamedOption` operation for `MiniQuake` (integer named option).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `fallback` | `dynamic` | — | Value to use when the requested input is unavailable or invalid. |
| `minimum` | `dynamic` | — | Smallest accepted value. |
| `maximum` | `dynamic` | — | Largest accepted value. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/main.ml#L335)

<a id="function-function-main-function-main-args-src-main-ml-776500952"></a>
### main

```ml
function main(args)
```

Parse command-line arguments and run the selected operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `args` | `dynamic` | — | Command-line arguments supplied by the host process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/main.ml#L756)

<a id="function-function-musicsmoke-function-musicsmoke-basedirectory-gamedirectory-tracktext-src-main-ml-1331115584"></a>
### musicSmoke

```ml
function musicSmoke(baseDirectory, gameDirectory, trackText)
```

Implements the `musicSmoke` operation for `MiniQuake` (music smoke).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `baseDirectory` | `dynamic` | — | Root directory containing the Quake installation. |
| `gameDirectory` | `dynamic` | — | Selected Quake game-data directory. |
| `trackText` | `dynamic` | — | Text containing the requested music-track number. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/main.ml#L142)

<a id="function-function-namedoption-function-namedoption-arguments-name-fallback-src-main-ml-1849042526"></a>
### namedOption

```ml
function namedOption(arguments, name, fallback)
```

Implements the `namedOption` operation for `MiniQuake` (named option).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `fallback` | `dynamic` | — | Value to use when the requested input is unavailable or invalid. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/main.ml#L361)

<a id="function-function-optionalframecount-function-optionalframecount-arguments-index-fallback-maximum-src-main-ml-515677029"></a>
### optionalFrameCount

```ml
function optionalFrameCount(arguments, index, fallback, maximum)
```

Return optional frame count derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |
| `index` | `dynamic` | — | Zero-based index of the requested entry. |
| `fallback` | `dynamic` | — | Value to use when the requested input is unavailable or invalid. |
| `maximum` | `dynamic` | — | Largest accepted value. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/main.ml#L376)

<a id="function-function-printusage-function-printusage-src-main-ml-954114287"></a>
### printUsage

```ml
function printUsage()
```

Format and emit usage.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/main.ml#L38)

<a id="function-function-rendersmoke-function-rendersmoke-arguments-src-main-ml-403001679"></a>
### renderSmoke

```ml
function renderSmoke(arguments)
```

Render smoke.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/main.ml#L457)

<a id="function-function-runcompatibilityreportcommand-function-runcompatibilityreportcommand-path-src-main-ml-715333854"></a>
### runCompatibilityReportCommand

```ml
function runCompatibilityReportCommand(path)
```

Execute compatibility report command.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Filesystem path to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/main.ml#L429)

<a id="function-function-runcompatibilitysnapshotcommand-function-runcompatibilitysnapshotcommand-arguments-src-main-ml-88264393"></a>
### runCompatibilitySnapshotCommand

```ml
function runCompatibilitySnapshotCommand(arguments)
```

Execute compatibility snapshot command.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/main.ml#L419)

<a id="function-function-runcompatibilitytracecommand-function-runcompatibilitytracecommand-arguments-src-main-ml-75474749"></a>
### runCompatibilityTraceCommand

```ml
function runCompatibilityTraceCommand(arguments)
```

Execute compatibility trace command.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/main.ml#L409)

<a id="function-function-runendscreenevidencecommand-function-runendscreenevidencecommand-arguments-src-main-ml-2066113193"></a>
### runEndscreenEvidenceCommand

```ml
function runEndscreenEvidenceCommand(arguments)
```

Execute endscreen evidence command.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/main.ml#L513)

<a id="function-function-runlongsoakcommand-function-runlongsoakcommand-arguments-src-main-ml-1959801089"></a>
### runLongSoakCommand

```ml
function runLongSoakCommand(arguments)
```

Execute long soak command.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/main.ml#L443)

<a id="function-function-runopt001aframebaselinecommand-function-runopt001aframebaselinecommand-arguments-src-main-ml-611798729"></a>
### runOpt001AFrameBaselineCommand

```ml
function runOpt001AFrameBaselineCommand(arguments)
```

Execute opt001 aframe baseline command.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/main.ml#L626)

<a id="function-function-runopt001ahandleplateaucommand-function-runopt001ahandleplateaucommand-arguments-src-main-ml-1265449173"></a>
### runOpt001AHandlePlateauCommand

```ml
function runOpt001AHandlePlateauCommand(arguments)
```

Execute opt001 ahandle plateau command.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/main.ml#L641)

<a id="function-function-runopt001amapparsecommand-function-runopt001amapparsecommand-arguments-src-main-ml-369029297"></a>
### runOpt001AMapParseCommand

```ml
function runOpt001AMapParseCommand(arguments)
```

Execute opt001 amap parse command.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/main.ml#L618)

<a id="function-function-runopt001btransitioncommand-function-runopt001btransitioncommand-arguments-src-main-ml-463590751"></a>
### runOpt001BTransitionCommand

```ml
function runOpt001BTransitionCommand(arguments)
```

Execute opt001 btransition command.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/main.ml#L656)

<a id="function-function-runoriginalinteropclientcommand-function-runoriginalinteropclientcommand-arguments-src-main-ml-1121821335"></a>
### runOriginalInteropClientCommand

```ml
function runOriginalInteropClientCommand(arguments)
```

Execute original interop client command.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/main.ml#L596)

<a id="function-function-runoriginalinteropservercommand-function-runoriginalinteropservercommand-arguments-src-main-ml-14330479"></a>
### runOriginalInteropServerCommand

```ml
function runOriginalInteropServerCommand(arguments)
```

Execute original interop server command.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/main.ml#L580)

<a id="function-function-runrenderdemoevidencecommand-function-runrenderdemoevidencecommand-arguments-src-main-ml-1800903437"></a>
### runRenderDemoEvidenceCommand

```ml
function runRenderDemoEvidenceCommand(arguments)
```

Execute render demo evidence command.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/main.ml#L531)

<a id="function-function-runrendererswitchsmokecommand-function-runrendererswitchsmokecommand-arguments-src-main-ml-1161638825"></a>
### runRendererSwitchSmokeCommand

```ml
function runRendererSwitchSmokeCommand(arguments)
```

Execute renderer switch smoke command.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/main.ml#L665)

<a id="function-function-runrenderevidencecommand-function-runrenderevidencecommand-arguments-src-main-ml-1986677453"></a>
### runRenderEvidenceCommand

```ml
function runRenderEvidenceCommand(arguments)
```

Execute render evidence command.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/main.ml#L471)

<a id="function-function-runruntimevalidationcommand-function-runruntimevalidationcommand-arguments-src-main-ml-516148123"></a>
### runRuntimeValidationCommand

```ml
function runRuntimeValidationCommand(arguments)
```

Execute runtime validation command.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/main.ml#L400)

<a id="function-function-runselfcheck-function-runselfcheck-src-main-ml-1827546063"></a>
### runSelfCheck

```ml
function runSelfCheck()
```

Runs self check for `MiniQuake`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/main.ml#L693)

<a id="function-function-runsoakcommand-function-runsoakcommand-arguments-src-main-ml-1448491269"></a>
### runSoakCommand

```ml
function runSoakCommand(arguments)
```

Execute soak command.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/main.ml#L436)

<a id="function-function-runtimesmoke-function-runtimesmoke-arguments-src-main-ml-2040364269"></a>
### runtimeSmoke

```ml
function runtimeSmoke(arguments)
```

Runs time smoke for `MiniQuake`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/main.ml#L393)

<a id="function-function-runudpsmoke-function-runudpsmoke-arguments-src-main-ml-823947991"></a>
### runUdpSmoke

```ml
function runUdpSmoke(arguments)
```

Execute udp smoke.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/main.ml#L674)

<a id="function-function-runuiresolutionmatrixcommand-function-runuiresolutionmatrixcommand-arguments-src-main-ml-1405362493"></a>
### runUiResolutionMatrixCommand

```ml
function runUiResolutionMatrixCommand(arguments)
```

Execute ui resolution matrix command.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/main.ml#L523)

<a id="function-function-validategame-function-validategame-arguments-src-main-ml-1511345085"></a>
### validateGame

```ml
function validateGame(arguments)
```

Validate game and report any incompatibility.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/main.ml#L292)

<a id="function-function-verifydemo-function-verifydemo-filename-src-main-ml-732804788"></a>
### verifyDemo

```ml
function verifyDemo(filename)
```

Validate demo and report any invalid state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `filename` | `dynamic` | — | Path of the file to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/main.ml#L267)
