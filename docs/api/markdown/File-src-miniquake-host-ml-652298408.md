# `src/miniquake/host.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.host`](Package-miniquake-host-82073057.md)

Reachable from entry: **yes**

## Imports

- `miniquake/array_util.ml` as `arrayutil` → [src/miniquake/array_util.ml](File-src-miniquake-array-util-ml-1490619700.md)
- `miniquake/byteio.ml` as `bio` → [src/miniquake/byteio.ml](File-src-miniquake-byteio-ml-1921171264.md)
- `miniquake/chase.ml` as `chase` → [src/miniquake/chase.ml](File-src-miniquake-chase-ml-313461938.md)
- `miniquake/client.ml` as `client` → [src/miniquake/client.ml](File-src-miniquake-client-ml-1164576599.md)
- `miniquake/client_effects.ml` as `clientEffects` → [src/miniquake/client_effects.ml](File-src-miniquake-client-effects-ml-1600404620.md)
- `miniquake/client_render_handoff.ml` as `renderHandoff` → [src/miniquake/client_render_handoff.ml](File-src-miniquake-client-render-handoff-ml-1626758503.md)
- `miniquake/cmd.ml` as `cmd` → [src/miniquake/cmd.ml](File-src-miniquake-cmd-ml-1014778996.md)
- `miniquake/common.ml` as `common` → [src/miniquake/common.ml](File-src-miniquake-common-ml-466436205.md)
- `miniquake/compat_diagnostics.ml` as `compatDiagnostics` → [src/miniquake/compat_diagnostics.ml](File-src-miniquake-compat-diagnostics-ml-1440740289.md)
- `miniquake/console.ml` as `console` → [src/miniquake/console.ml](File-src-miniquake-console-ml-296415787.md)
- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/cvar.ml` as `cvar` → [src/miniquake/cvar.ml](File-src-miniquake-cvar-ml-171521436.md)
- `miniquake/demo.ml` as `demo` → [src/miniquake/demo.ml](File-src-miniquake-demo-ml-103505867.md)
- `miniquake/demo_player.ml` as `demoPlayer` → [src/miniquake/demo_player.ml](File-src-miniquake-demo-player-ml-1504569459.md)
- `miniquake/external_reference_contract.ml` as `externalReference` → [src/miniquake/external_reference_contract.ml](File-src-miniquake-external-reference-contract-ml-1714794236.md)
- `miniquake/filesystem.ml` as `qfs` → [src/miniquake/filesystem.ml](File-src-miniquake-filesystem-ml-1964591079.md)
- `miniquake/format/bsp.ml` as `bsp` → [src/miniquake/format/bsp.ml](File-src-miniquake-format-bsp-ml-22292029.md)
- `miniquake/gl_vidnt.ml` as `glvid` → [src/miniquake/gl_vidnt.ml](File-src-miniquake-gl-vidnt-ml-1573847321.md)
- `miniquake/host_command_numbers.ml` as `hostNumbers` → [src/miniquake/host_command_numbers.ml](File-src-miniquake-host-command-numbers-ml-2052828249.md)
- `miniquake/host_timing.ml` as `hostTiming` → [src/miniquake/host_timing.ml](File-src-miniquake-host-timing-ml-1327397435.md)
- `miniquake/input.ml` as `input` → [src/miniquake/input.ml](File-src-miniquake-input-ml-1422374844.md)
- `miniquake/keys.ml` as `keys` → [src/miniquake/keys.ml](File-src-miniquake-keys-ml-299795526.md)
- `miniquake/launch.ml` as `launch` → [src/miniquake/launch.ml](File-src-miniquake-launch-ml-1123847567.md)
- `miniquake/mathlib.ml` as `math` → [src/miniquake/mathlib.ml](File-src-miniquake-mathlib-ml-2131866431.md)
- `miniquake/menu.ml` as `menu` → [src/miniquake/menu.ml](File-src-miniquake-menu-ml-537231111.md)
- `miniquake/message.ml` as `msg` → [src/miniquake/message.ml](File-src-miniquake-message-ml-238261765.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/net_datagram.ml` as `netDatagram` → [src/miniquake/net_datagram.ml](File-src-miniquake-net-datagram-ml-84886599.md)
- `miniquake/net_loop.ml` as `netloop` → [src/miniquake/net_loop.ml](File-src-miniquake-net-loop-ml-170267060.md)
- `miniquake/net_main.ml` as `netmain` → [src/miniquake/net_main.ml](File-src-miniquake-net-main-ml-940970693.md)
- `miniquake/net_wins.ml` as `netwins` → [src/miniquake/net_wins.ml](File-src-miniquake-net-wins-ml-1861208059.md)
- `miniquake/optimization_baseline.ml` as `optBaseline` → [src/miniquake/optimization_baseline.ml](File-src-miniquake-optimization-baseline-ml-636998107.md)
- `miniquake/particles.ml` as `particles` → [src/miniquake/particles.ml](File-src-miniquake-particles-ml-1296519509.md)
- `miniquake/platform/win32.ml` as `win` → [src/miniquake/platform/win32.ml](File-src-miniquake-platform-win32-ml-1233303091.md)
- `miniquake/player_move.ml` as `movement` → [src/miniquake/player_move.ml](File-src-miniquake-player-move-ml-856575161.md)
- `miniquake/quakec/edict.ml` as `qcedict` → [src/miniquake/quakec/edict.ml](File-src-miniquake-quakec-edict-ml-1018045152.md)
- `miniquake/quakec/vm.ml` as `qcvm` → [src/miniquake/quakec/vm.ml](File-src-miniquake-quakec-vm-ml-1211659018.md)
- `miniquake/render/colored_lightmaps.ml` as `coloredLightmaps` → [src/miniquake/render/colored_lightmaps.ml](File-src-miniquake-render-colored-lightmaps-ml-2051146857.md)
- `miniquake/render/draw2d.ml` as `draw2d` → [src/miniquake/render/draw2d.ml](File-src-miniquake-render-draw2d-ml-1547120567.md)
- `miniquake/render/enhanced.ml` as `enhancedRenderer` → [src/miniquake/render/enhanced.ml](File-src-miniquake-render-enhanced-ml-802793533.md)
- `miniquake/render/entities.ml` as `entityRenderer` → [src/miniquake/render/entities.ml](File-src-miniquake-render-entities-ml-1187973086.md)
- `miniquake/render/gl11.ml` as `gl` → [src/miniquake/render/gl11.ml](File-src-miniquake-render-gl11-ml-805308144.md)
- `miniquake/render/gl_refrag.ml` as `glRefrag` → [src/miniquake/render/gl_refrag.ml](File-src-miniquake-render-gl-refrag-ml-1270523792.md)
- `miniquake/render/particles.ml` as `particleRenderer` → [src/miniquake/render/particles.ml](File-src-miniquake-render-particles-ml-1835375214.md)
- `miniquake/render/world.ml` as `worldRenderer` → [src/miniquake/render/world.ml](File-src-miniquake-render-world-ml-1647521183.md)
- `miniquake/render_evidence.ml` as `renderEvidence` → [src/miniquake/render_evidence.ml](File-src-miniquake-render-evidence-ml-1521230616.md)
- `miniquake/savegame.ml` as `savegame` → [src/miniquake/savegame.ml](File-src-miniquake-savegame-ml-965358839.md)
- `miniquake/savegame_runtime.ml` as `saveRuntime` → [src/miniquake/savegame_runtime.ml](File-src-miniquake-savegame-runtime-ml-743583186.md)
- `miniquake/screen.ml` as `screen` → [src/miniquake/screen.ml](File-src-miniquake-screen-ml-587247802.md)
- `miniquake/server.ml` as `server` → [src/miniquake/server.ml](File-src-miniquake-server-ml-699591299.md)
- `miniquake/sizebuf.ml` as `sz` → [src/miniquake/sizebuf.ml](File-src-miniquake-sizebuf-ml-252484438.md)
- `miniquake/sound/cd_audio.ml` as `cdAudio` → [src/miniquake/sound/cd_audio.ml](File-src-miniquake-sound-cd-audio-ml-1325947348.md)
- `miniquake/sound/mixer.ml` as `mixer` → [src/miniquake/sound/mixer.ml](File-src-miniquake-sound-mixer-ml-2037667391.md)
- `miniquake/stability_contract.ml` as `stability` → [src/miniquake/stability_contract.ml](File-src-miniquake-stability-contract-ml-312141268.md)
- `miniquake/statusbar.ml` as `statusbar` → [src/miniquake/statusbar.ml](File-src-miniquake-statusbar-ml-945138613.md)
- `miniquake/sys_win.ml` as `sysWin` → [src/miniquake/sys_win.ml](File-src-miniquake-sys-win-ml-1437273508.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)
- `miniquake/view.ml` as `view` → [src/miniquake/view.ml](File-src-miniquake-view-ml-709264737.md)
- `miniquake/world_bsp.ml` as `worldBsp` → [src/miniquake/world_bsp.ml](File-src-miniquake-world-bsp-ml-1111600182.md)
- `std/fs.ml` as `fs` → `../MiniLangCompilerOptimization/MiniLangCompilerML/std/fs.ml` — external dependency

## Declarations

<a id="function-function-miniquake-host-host-frame-function-host-frame-session-elapsedseconds-src-miniquake-host-ml-1349980298"></a>
### _Host_Frame

```ml
function _Host_Frame(session, elapsedSeconds)
```

Apply the Quake-compatible host frame behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `_Host_Frame`. |
| `elapsedSeconds` | `dynamic` | — | The elapsed seconds input consumed by `_Host_Frame`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L3850)

<a id="function-function-miniquake-host-host-serverframe-function-host-serverframe-session-src-miniquake-host-ml-720403375"></a>
### _Host_ServerFrame

```ml
function _Host_ServerFrame(session)
```

Apply the Quake-compatible host server frame behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `_Host_ServerFrame`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L3843)

<a id="function-function-miniquake-host-activeserverclients-function-activeserverclients-session-src-miniquake-host-ml-1142391209"></a>
### activeServerClients

```ml
function activeServerClients(session)
```

Report whether active server clients holds for the active state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `activeServerClients`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1446)

<a id="function-function-miniquake-host-adjustmenuoption-function-adjustmenuoption-session-direction-src-miniquake-host-ml-584856842"></a>
### adjustMenuOption

```ml
function adjustMenuOption(session, direction)
```

Implements the `adjustMenuOption` operation for `miniquake.host` (adjust menu option).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `adjustMenuOption`. |
| `direction` | `dynamic` | — | The direction input consumed by `adjustMenuOption`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L3266)

<a id="function-function-miniquake-host-appendvisiblestaticentities-function-appendvisiblestaticentities-session-dynamicentities-src-miniquake-host-ml-1846102217"></a>
### appendVisibleStaticEntities

```ml
function appendVisibleStaticEntities(session, dynamicEntities)
```

Append only static entities linked into leaves visible from the current world PVS. CL_RelinkEntities intentionally contains dynamic entities only; this is the production counterpart of GLQuake's R_StoreEfrags calls made while traversing visible world leaves.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `appendVisibleStaticEntities`. |
| `dynamicEntities` | `dynamic` | — | The dynamic entities input consumed by `appendVisibleStaticEntities`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L86)

<a id="function-function-miniquake-host-begindemorecording-function-begindemorecording-session-arguments-src-miniquake-host-ml-1899095125"></a>
### beginDemoRecording

```ml
function beginDemoRecording(session, arguments)
```

Initialize state for begin demo recording.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `beginDemoRecording`. |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1237)

<a id="function-function-miniquake-host-captureuiresolutionscene-function-captureuiresolutionscene-session-outputprefix-expectedwidth-expectedheight-src-miniquake-host-ml-594411757"></a>
### captureUiResolutionScene

```ml
function captureUiResolutionScene(session, outputPrefix, expectedWidth, expectedHeight)
```

Implements the `captureUiResolutionScene` operation for `miniquake.host` (capture ui resolution scene).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `captureUiResolutionScene`. |
| `outputPrefix` | `dynamic` | — | The output prefix input consumed by `captureUiResolutionScene`. |
| `expectedWidth` | `dynamic` | — | The expected width input consumed by `captureUiResolutionScene`. |
| `expectedHeight` | `dynamic` | — | The expected height input consumed by `captureUiResolutionScene`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L5299)

<a id="function-function-miniquake-host-changelevel-function-changelevel-session-mapname-src-miniquake-host-ml-1438352254"></a>
### changeLevel

```ml
function changeLevel(session, mapName)
```

Update subsystem configuration for change level.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `changeLevel`. |
| `mapName` | `dynamic` | — | Name of the map to load or inspect. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L477)

<a id="function-function-miniquake-host-clearinactivepresentationworld-function-clearinactivepresentationworld-session-src-miniquake-host-ml-754272215"></a>
### clearInactivePresentationWorld

```ml
function clearInactivePresentationWorld(session)
```

Clear the non-authoritative world retained solely for demo or remote presentation. A live local server owns these fields and must keep them across renderer rebuilds; an inactive server must not let an old demo BSP suppress preparation of the next remote server's world.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `clearInactivePresentationWorld`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1272)

<a id="function-function-miniquake-host-commandneverexists-function-commandneverexists-name-src-miniquake-host-ml-1723289740"></a>
### commandNeverExists

```ml
function commandNeverExists(name)
```

Report whether command never exists holds for the active state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L95)

<a id="function-function-miniquake-host-configurenetworkqueries-function-configurenetworkqueries-session-src-miniquake-host-ml-1148536675"></a>
### configureNetworkQueries

```ml
function configureNetworkQueries(session)
```

Update subsystem configuration for configure network queries.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `configureNetworkQueries`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1456)

<a id="function-function-miniquake-host-connectremotehost-function-connectremotehost-session-hostname-src-miniquake-host-ml-1698810720"></a>
### connectRemoteHost

```ml
function connectRemoteHost(session, hostName)
```

Establish remote host using the active network transport.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `connectRemoteHost`. |
| `hostName` | `dynamic` | — | Name that identifies the requested value or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1392)

<a id="function-function-miniquake-host-connectremotehostinterop-function-connectremotehostinterop-session-hostname-timeoutmilliseconds-resendmilliseconds-src-miniquake-host-ml-215181532"></a>
### connectRemoteHostInterop

```ml
function connectRemoteHostInterop(session, hostName, timeoutMilliseconds, resendMilliseconds)
```

Establish remote host interop using the active network transport.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `connectRemoteHostInterop`. |
| `hostName` | `dynamic` | — | Name that identifies the requested value or resource. |
| `timeoutMilliseconds` | `dynamic` | — | The timeout milliseconds input consumed by `connectRemoteHostInterop`. |
| `resendMilliseconds` | `dynamic` | — | The resend milliseconds input consumed by `connectRemoteHostInterop`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1423)

<a id="function-function-miniquake-host-consumeclientevents-function-consumeclientevents-session-src-miniquake-host-ml-260364639"></a>
### consumeClientEvents

```ml
function consumeClientEvents(session)
```

Consume pending state for consume client events.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `consumeClientEvents`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L2981)

<a id="function-function-miniquake-host-consumeconsolesideeffects-function-consumeconsolesideeffects-session-src-miniquake-host-ml-756339415"></a>
### consumeConsoleSideEffects

```ml
function consumeConsoleSideEffects(session)
```

console.c performs these two effects synchronously from Con_Print/Con_Printf. MiniLang records them on ConsoleState so the host can invoke the production audio and screen paths without creating a console<->host import cycle.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `consumeConsoleSideEffects`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L3162)

<a id="function-function-miniquake-host-consumequakeccontrol-function-consumequakeccontrol-session-src-miniquake-host-ml-1202910303"></a>
### consumeQuakeCControl

```ml
function consumeQuakeCControl(session)
```

Consume pending state for consume quake ccontrol.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `consumeQuakeCControl`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L3106)

<a id="function-function-miniquake-host-consumerelinkparticleeffects-function-consumerelinkparticleeffects-session-src-miniquake-host-ml-1199720955"></a>
### consumeRelinkParticleEffects

```ml
function consumeRelinkParticleEffects(session)
```

Consume pending state for consume relink particle effects.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `consumeRelinkParticleEffects`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L3086)

<a id="function-function-miniquake-host-create-function-create-args-src-miniquake-host-ml-2009098110"></a>
### create

```ml
function create(args)
```

Implements the `create` operation for `miniquake.host` (create).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `args` | `dynamic` | — | Command-line arguments supplied by the host process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L300)

<a id="function-function-miniquake-host-createcvars-function-createcvars-commandline-registered-src-miniquake-host-ml-1364208704"></a>
### createCvars

```ml
function createCvars(commandLine, registered)
```

Create and initialize cvars.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `commandLine` | `dynamic` | — | The command line input consumed by `createCvars`. |
| `registered` | `dynamic` | — | The registered input consumed by `createCvars`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L112)

<a id="function-function-miniquake-host-cvarcommand-function-cvarcommand-session-arguments-src-miniquake-host-ml-1283609155"></a>
### cvarCommand

```ml
function cvarCommand(session, arguments)
```

Implements the `cvarCommand` operation for `miniquake.host` (cvar command).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `cvarCommand`. |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L436)

<a id="function-function-miniquake-host-destroyscene-function-destroyscene-session-src-miniquake-host-ml-1714214207"></a>
### destroyScene

```ml
function destroyScene(session)
```

Release resources owned by scene.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `destroyScene`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1260)

<a id="function-function-miniquake-host-deterministicinputrequested-function-deterministicinputrequested-session-src-miniquake-host-ml-1089790291"></a>
### deterministicInputRequested

```ml
function deterministicInputRequested(session)
```

Implements the `deterministicInputRequested` operation for `miniquake.host` (deterministic input requested).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `deterministicInputRequested`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L3766)

<a id="function-function-miniquake-host-discardtextinput-function-discardtextinput-src-miniquake-host-ml-51915065"></a>
### discardTextInput

```ml
function discardTextInput()
```

Release or consume state for discard text input.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L3561)

<a id="function-function-miniquake-host-executecommand-function-executecommand-session-text-src-miniquake-host-ml-1008544078"></a>
### executeCommand

```ml
function executeCommand(session, text)
```

Execute command.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `executeCommand`. |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L2319)

<a id="function-function-miniquake-host-executecommandbuffer-function-executecommandbuffer-session-maximumcommands-src-miniquake-host-ml-1400295225"></a>
### executeCommandBuffer

```ml
function executeCommandBuffer(session, maximumCommands)
```

Execute command buffer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `executeCommandBuffer`. |
| `maximumCommands` | `dynamic` | — | The maximum commands input consumed by `executeCommandBuffer`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L2758)

<a id="function-function-miniquake-host-executemenuselection-function-executemenuselection-session-src-miniquake-host-ml-100408591"></a>
### executeMenuSelection

```ml
function executeMenuSelection(session)
```

Execute menu selection.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `executeMenuSelection`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L3317)

<a id="function-function-miniquake-host-failedmaptransition-function-failedmaptransition-session-result-src-miniquake-host-ml-645980024"></a>
### failedMapTransition

```ml
function failedMapTransition(session, result)
```

Implements the `failedMapTransition` operation for `miniquake.host` (failed map transition).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `failedMapTransition`. |
| `result` | `dynamic` | — | Result value to report or translate into a status code. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L676)

<a id="function-function-miniquake-host-filtertime-function-filtertime-timing-newrealtime-maxfps-forcedframerate-timedemo-src-miniquake-host-ml-1336808243"></a>
### filterTime

```ml
function filterTime(timing, newRealtime, maxFps, forcedFrameRate, timedemo)
```

Implements the `filterTime` operation for `miniquake.host` (filter time).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `timing` | `dynamic` | — | The timing input consumed by `filterTime`. |
| `newRealtime` | `dynamic` | — | Time value used by the operation. |
| `maxFps` | `dynamic` | — | The max fps input consumed by `filterTime`. |
| `forcedFrameRate` | `dynamic` | — | The forced frame rate input consumed by `filterTime`. |
| `timedemo` | `dynamic` | — | The timedemo input consumed by `filterTime`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L429)

<a id="function-function-miniquake-host-findalias-function-findalias-system-name-src-miniquake-host-ml-1695780245"></a>
### findAlias

```ml
function findAlias(system, name)
```

Return alias.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `findAlias`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L459)

<a id="function-function-miniquake-host-findviewthing-function-findviewthing-session-src-miniquake-host-ml-1830836335"></a>
### FindViewthing

```ml
function FindViewthing(session)
```

Return viewthing.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `FindViewthing`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1988)

<a id="function-function-miniquake-host-finishdemoplayback-function-finishdemoplayback-session-src-miniquake-host-ml-976591003"></a>
### finishDemoPlayback

```ml
function finishDemoPlayback(session)
```

Finalize state for finish demo playback.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `finishDemoPlayback`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1511)

<a id="function-function-miniquake-host-finishloadingpresentation-function-finishloadingpresentation-session-src-miniquake-host-ml-1564119641"></a>
### finishLoadingPresentation

```ml
function finishLoadingPresentation(session)
```

Present one non-simulating loading frame after the new renderer and all level assets exist.  This moves the driver's one-time first SwapBuffers cost out of the first ordinary Host_Frame while retaining four stock-order warmup updates under the loading plaque.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `finishLoadingPresentation`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L565)

<a id="function-function-miniquake-host-finishlocalmapconnection-function-finishlocalmapconnection-session-preserveclients-src-miniquake-host-ml-1923071445"></a>
### finishLocalMapConnection

```ml
function finishLocalMapConnection(session, preserveClients)
```

Finalize state for finish local map connection.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `finishLocalMapConnection`. |
| `preserveClients` | `dynamic` | — | The preserve clients input consumed by `finishLocalMapConnection`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L605)

<a id="function-function-miniquake-host-firstremoteserverclient-function-firstremoteserverclient-session-src-miniquake-host-ml-151248143"></a>
### firstRemoteServerClient

```ml
function firstRemoteServerClient(session)
```

Return first remote server client for the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `firstRemoteServerClient`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L5841)

<a id="function-function-miniquake-host-flushservercvarchanges-function-flushservercvarchanges-session-src-miniquake-host-ml-2130581943"></a>
### flushServerCvarChanges

```ml
function flushServerCvarChanges(session)
```

Implements the `flushServerCvarChanges` operation for `miniquake.host` (flush server cvar changes).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `flushServerCvarChanges`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L445)

<a id="function-function-miniquake-host-frame-function-frame-session-elapsedseconds-src-miniquake-host-ml-1337151842"></a>
### frame

```ml
function frame(session, elapsedSeconds)
```

Implements the `frame` operation for `miniquake.host` (frame).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `frame`. |
| `elapsedSeconds` | `dynamic` | — | The elapsed seconds input consumed by `frame`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L4326)

<a id="function-function-miniquake-host-gameplaymouseenabled-function-gameplaymouseenabled-session-src-miniquake-host-ml-610950823"></a>
### gameplayMouseEnabled

```ml
function gameplayMouseEnabled(session)
```

Report whether gameplay mouse enabled holds for the active state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `gameplayMouseEnabled`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L406)

<a id="function-function-miniquake-host-handleexactmenuaction-function-handleexactmenuaction-session-result-src-miniquake-host-ml-617216840"></a>
### handleExactMenuAction

```ml
function handleExactMenuAction(session, result)
```

Handle exact menu action and update the associated state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `handleExactMenuAction`. |
| `result` | `dynamic` | — | Result value to report or translate into a status code. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L3413)

<a id="function-function-miniquake-host-handlekeyresult-function-handlekeyresult-session-result-src-miniquake-host-ml-1461281312"></a>
### handleKeyResult

```ml
function handleKeyResult(session, result)
```

Handle key result and update the associated state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `handleKeyResult`. |
| `result` | `dynamic` | — | Result value to report or translate into a status code. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L3629)

<a id="function-function-miniquake-host-handlemenukey-function-handlemenukey-session-key-src-miniquake-host-ml-373122880"></a>
### handleMenuKey

```ml
function handleMenuKey(session, key)
```

Handle menu key and update the associated state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `handleMenuKey`. |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L3574)

<a id="function-function-miniquake-host-host-begin-f-function-host-begin-f-src-miniquake-host-ml-1019337093"></a>
### Host_Begin_f

```ml
function Host_Begin_f()
```

Apply the Quake-compatible host begin f behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1966)

<a id="function-function-miniquake-host-host-changelevel2-f-function-host-changelevel2-f-session-arguments-src-miniquake-host-ml-330311969"></a>
### Host_Changelevel2_f

```ml
function Host_Changelevel2_f(session, arguments)
```

Apply the Quake-compatible host changelevel2 f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_Changelevel2_f`. |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1828)

<a id="function-function-miniquake-host-host-changelevel-f-function-host-changelevel-f-session-arguments-src-miniquake-host-ml-2057997969"></a>
### Host_Changelevel_f

```ml
function Host_Changelevel_f(session, arguments)
```

Apply the Quake-compatible host changelevel f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_Changelevel_f`. |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1754)

<a id="function-function-miniquake-host-host-cheathelplines-function-host-cheathelplines-src-miniquake-host-ml-102586813"></a>
### Host_CheatHelpLines

```ml
function Host_CheatHelpLines()
```

Return the console help shown for MiniQuake's supported cheat commands.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1676)

<a id="function-function-miniquake-host-host-cheats-f-function-host-cheats-f-session-src-miniquake-host-ml-2138698923"></a>
### Host_Cheats_f

```ml
function Host_Cheats_f(session)
```

Print the complete cheat reference from either accepted help alias.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_Cheats_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1697)

<a id="function-function-miniquake-host-host-clearmemory-function-host-clearmemory-session-src-miniquake-host-ml-2137249279"></a>
### Host_ClearMemory

```ml
function Host_ClearMemory(session)
```

Apply the Quake-compatible host clear memory behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_ClearMemory`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1005)

<a id="function-function-miniquake-host-host-clientcommands-function-host-clientcommands-clientvalue-text-src-miniquake-host-ml-1962208894"></a>
### Host_ClientCommands

```ml
function Host_ClientCommands(clientValue, text)
```

Apply the Quake-compatible host client commands behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `clientValue` | `dynamic` | — | The client value input consumed by `Host_ClientCommands`. |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L931)

<a id="function-function-miniquake-host-host-color-f-function-host-color-f-session-arguments-src-miniquake-host-ml-814717817"></a>
### Host_Color_f

```ml
function Host_Color_f(session, arguments)
```

Apply the Quake-compatible host color f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_Color_f`. |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1924)

<a id="function-function-miniquake-host-host-connect-f-function-host-connect-f-session-arguments-src-miniquake-host-ml-1714561969"></a>
### Host_Connect_f

```ml
function Host_Connect_f(session, arguments)
```

Apply the Quake-compatible host connect f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_Connect_f`. |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1786)

<a id="function-function-miniquake-host-host-demos-f-function-host-demos-f-session-src-miniquake-host-ml-1101695023"></a>
### Host_Demos_f

```ml
function Host_Demos_f(session)
```

Apply the Quake-compatible host demos f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_Demos_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L2149)

<a id="function-function-miniquake-host-host-disconnect-f-function-host-disconnect-f-session-src-miniquake-host-ml-126041943"></a>
### Host_Disconnect_f

```ml
function Host_Disconnect_f(session)
```

Apply the Quake-compatible host disconnect f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_Disconnect_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1600)

<a id="function-function-miniquake-host-host-dispatchcommand-function-host-dispatchcommand-session-text-arguments-src-miniquake-host-ml-308187978"></a>
### Host_DispatchCommand

```ml
function Host_DispatchCommand(session, text, arguments)
```

Apply the Quake-compatible host dispatch command behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_DispatchCommand`. |
| `text` | `dynamic` | — | Text to parse or process. |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L2265)

<a id="function-function-miniquake-host-host-edict-f-function-host-edict-f-session-arguments-src-miniquake-host-ml-588146077"></a>
### Host_Edict_f

```ml
function Host_Edict_f(session, arguments)
```

Apply the Quake-compatible host edict f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_Edict_f`. |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L2172)

<a id="function-function-miniquake-host-host-edictcount-f-function-host-edictcount-f-session-src-miniquake-host-ml-2091671103"></a>
### Host_EdictCount_f

```ml
function Host_EdictCount_f(session)
```

Apply the Quake-compatible host edict count f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_EdictCount_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L2196)

<a id="function-function-miniquake-host-host-edicts-f-function-host-edicts-f-session-src-miniquake-host-ml-767011403"></a>
### Host_Edicts_f

```ml
function Host_Edicts_f(session)
```

Apply the Quake-compatible host edicts f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_Edicts_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L2184)

<a id="function-function-miniquake-host-host-endgame-function-host-endgame-session-message-src-miniquake-host-ml-729847040"></a>
### Host_EndGame

```ml
function Host_EndGame(session, message)
```

Apply the Quake-compatible host end game behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_EndGame`. |
| `message` | `dynamic` | — | Diagnostic message that explains a failure or event. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1060)

<a id="function-function-miniquake-host-host-error-function-host-error-session-message-src-miniquake-host-ml-2042068628"></a>
### Host_Error

```ml
function Host_Error(session, message)
```

Apply the Quake-compatible host error behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_Error`. |
| `message` | `dynamic` | — | Diagnostic message that explains a failure or event. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1074)

<a id="function-function-miniquake-host-host-filtertime-function-host-filtertime-session-elapsedseconds-src-miniquake-host-ml-381262940"></a>
### Host_FilterTime

```ml
function Host_FilterTime(session, elapsedSeconds)
```

Apply the Quake-compatible host filter time behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_FilterTime`. |
| `elapsedSeconds` | `dynamic` | — | The elapsed seconds input consumed by `Host_FilterTime`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1023)

<a id="function-function-miniquake-host-host-findmaxclients-function-host-findmaxclients-arguments-src-miniquake-host-ml-560394495"></a>
### Host_FindMaxClients

```ml
function Host_FindMaxClients(arguments)
```

Apply the Quake-compatible host find max clients behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L286)

<a id="function-function-miniquake-host-host-flushcache-f-function-host-flushcache-f-session-src-miniquake-host-ml-489943507"></a>
### Host_FlushCache_f

```ml
function Host_FlushCache_f(session)
```

Apply the Quake-compatible host flush cache f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_FlushCache_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L2235)

<a id="function-function-miniquake-host-host-flushpendingclientmessages-function-host-flushpendingclientmessages-session-timeoutseconds-src-miniquake-host-ml-1466780893"></a>
### Host_FlushPendingClientMessages

```ml
function Host_FlushPendingClientMessages(session, timeoutSeconds)
```

Apply the Quake-compatible host flush pending client messages behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_FlushPendingClientMessages`. |
| `timeoutSeconds` | `dynamic` | — | The timeout seconds input consumed by `Host_FlushPendingClientMessages`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L950)

<a id="function-function-miniquake-host-host-fly-f-function-host-fly-f-session-src-miniquake-host-ml-1178317271"></a>
### Host_Fly_f

```ml
function Host_Fly_f(session)
```

Apply the Quake-compatible host fly f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_Fly_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1713)

<a id="function-function-miniquake-host-host-forwardtoserver-function-host-forwardtoserver-session-text-src-miniquake-host-ml-1308805770"></a>
### Host_ForwardToServer

```ml
function Host_ForwardToServer(session, text)
```

Apply the Quake-compatible host forward to server behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_ForwardToServer`. |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1593)

<a id="function-function-miniquake-host-host-frame-function-host-frame-session-elapsedseconds-src-miniquake-host-ml-58358740"></a>
### Host_Frame

```ml
function Host_Frame(session, elapsedSeconds)
```

Apply the Quake-compatible host frame behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_Frame`. |
| `elapsedSeconds` | `dynamic` | — | The elapsed seconds input consumed by `Host_Frame`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L4308)

<a id="function-function-miniquake-host-host-getconsolecommands-function-host-getconsolecommands-session-inputlines-src-miniquake-host-ml-1038543798"></a>
### Host_GetConsoleCommands

```ml
function Host_GetConsoleCommands(session, inputLines)
```

Apply the Quake-compatible host get console commands behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_GetConsoleCommands`. |
| `inputLines` | `dynamic` | — | The input lines input consumed by `Host_GetConsoleCommands`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1034)

<a id="function-function-miniquake-host-host-give-f-function-host-give-f-session-arguments-src-miniquake-host-ml-571699307"></a>
### Host_Give_f

```ml
function Host_Give_f(session, arguments)
```

Apply the Quake-compatible host give f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_Give_f`. |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1982)

<a id="function-function-miniquake-host-host-god-f-function-host-god-f-session-src-miniquake-host-ml-652797967"></a>
### Host_God_f

```ml
function Host_God_f(session)
```

Apply the Quake-compatible host god f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_God_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1659)

<a id="function-function-miniquake-host-host-init-function-host-init-session-src-miniquake-host-ml-1595737621"></a>
### Host_Init

```ml
function Host_Init(session)
```

Apply the Quake-compatible host init behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_Init`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L2811)

<a id="function-function-miniquake-host-host-initcommands-function-host-initcommands-src-miniquake-host-ml-1284807355"></a>
### Host_InitCommands

```ml
function Host_InitCommands()
```

Apply the Quake-compatible host init commands behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L2250)

<a id="function-function-miniquake-host-host-initlocal-function-host-initlocal-session-src-miniquake-host-ml-1326499723"></a>
### Host_InitLocal

```ml
function Host_InitLocal(session)
```

Apply the Quake-compatible host init local behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_InitLocal`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L896)

<a id="function-function-miniquake-host-host-initvcr-function-host-initvcr-session-src-miniquake-host-ml-264849983"></a>
### Host_InitVCR

```ml
function Host_InitVCR(session)
```

Apply the Quake-compatible host init vcr behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_InitVCR`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1047)

<a id="function-function-miniquake-host-host-invisible-f-function-host-invisible-f-session-src-miniquake-host-ml-831997339"></a>
### Host_Invisible_f

```ml
function Host_Invisible_f(session)
```

Forward the MiniQuake AI-invisibility cheat to the authoritative server.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_Invisible_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1671)

<a id="function-function-miniquake-host-host-kick-f-function-host-kick-f-session-arguments-src-miniquake-host-ml-1824955121"></a>
### Host_Kick_f

```ml
function Host_Kick_f(session, arguments)
```

Apply the Quake-compatible host kick f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_Kick_f`. |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1974)

<a id="function-function-miniquake-host-host-kill-f-function-host-kill-f-session-src-miniquake-host-ml-1393262303"></a>
### Host_Kill_f

```ml
function Host_Kill_f(session)
```

Apply the Quake-compatible host kill f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_Kill_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1943)

<a id="function-function-miniquake-host-host-loadgame-f-function-host-loadgame-f-session-arguments-src-miniquake-host-ml-208147825"></a>
### Host_Loadgame_f

```ml
function Host_Loadgame_f(session, arguments)
```

Apply the Quake-compatible host loadgame f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_Loadgame_f`. |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1817)

<a id="function-function-miniquake-host-host-map-f-function-host-map-f-session-arguments-src-miniquake-host-ml-139159185"></a>
### Host_Map_f

```ml
function Host_Map_f(session, arguments)
```

Apply the Quake-compatible host map f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_Map_f`. |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1726)

<a id="function-function-miniquake-host-host-mod-print-function-host-mod-print-session-src-miniquake-host-ml-1600688791"></a>
### Host_Mod_Print

```ml
function Host_Mod_Print(session)
```

Apply the Quake-compatible host mod print behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_Mod_Print`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L2219)

<a id="function-function-miniquake-host-host-name-f-function-host-name-f-session-arguments-src-miniquake-host-ml-601167411"></a>
### Host_Name_f

```ml
function Host_Name_f(session, arguments)
```

Apply the Quake-compatible host name f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_Name_f`. |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1837)

<a id="function-function-miniquake-host-host-noclip-f-function-host-noclip-f-session-src-miniquake-host-ml-1857947453"></a>
### Host_Noclip_f

```ml
function Host_Noclip_f(session)
```

Apply the Quake-compatible host noclip f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_Noclip_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1707)

<a id="function-function-miniquake-host-host-notarget-f-function-host-notarget-f-session-src-miniquake-host-ml-843458375"></a>
### Host_Notarget_f

```ml
function Host_Notarget_f(session)
```

Apply the Quake-compatible host notarget f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_Notarget_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1665)

<a id="function-function-miniquake-host-host-pause-f-function-host-pause-f-session-src-miniquake-host-ml-2034251535"></a>
### Host_Pause_f

```ml
function Host_Pause_f(session)
```

Apply the Quake-compatible host pause f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_Pause_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1949)

<a id="function-function-miniquake-host-host-ping-f-function-host-ping-f-session-src-miniquake-host-ml-2053130211"></a>
### Host_Ping_f

```ml
function Host_Ping_f(session)
```

Apply the Quake-compatible host ping f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_Ping_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1719)

<a id="function-function-miniquake-host-host-please-f-function-host-please-f-session-arguments-src-miniquake-host-ml-1038326577"></a>
### Host_Please_f

```ml
function Host_Please_f(session, arguments)
```

Apply the Quake-compatible host please f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_Please_f`. |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1857)

<a id="function-function-miniquake-host-host-prespawn-f-function-host-prespawn-f-src-miniquake-host-ml-1143359177"></a>
### Host_PreSpawn_f

```ml
function Host_PreSpawn_f()
```

Apply the Quake-compatible host pre spawn f behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1954)

<a id="function-function-miniquake-host-host-profile-f-function-host-profile-f-session-src-miniquake-host-ml-1841494103"></a>
### Host_Profile_f

```ml
function Host_Profile_f(session)
```

Apply the Quake-compatible host profile f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_Profile_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L2209)

<a id="function-function-miniquake-host-host-quit-f-function-host-quit-f-session-src-miniquake-host-ml-2071954549"></a>
### Host_Quit_f

```ml
function Host_Quit_f(session)
```

Apply the Quake-compatible host quit f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_Quit_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1611)

<a id="function-function-miniquake-host-host-reconnect-f-function-host-reconnect-f-session-src-miniquake-host-ml-259835751"></a>
### Host_Reconnect_f

```ml
function Host_Reconnect_f(session)
```

Apply the Quake-compatible host reconnect f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_Reconnect_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1769)

<a id="function-function-miniquake-host-host-restart-f-function-host-restart-f-session-src-miniquake-host-ml-906488635"></a>
### Host_Restart_f

```ml
function Host_Restart_f(session)
```

Apply the Quake-compatible host restart f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_Restart_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1762)

<a id="function-function-miniquake-host-host-savegame-f-function-host-savegame-f-session-arguments-src-miniquake-host-ml-165985219"></a>
### Host_Savegame_f

```ml
function Host_Savegame_f(session, arguments)
```

Apply the Quake-compatible host savegame f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_Savegame_f`. |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1807)

<a id="function-function-miniquake-host-host-say-function-host-say-session-arguments-teamonly-src-miniquake-host-ml-1589231948"></a>
### Host_Say

```ml
function Host_Say(session, arguments, teamOnly)
```

Apply the Quake-compatible host say behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_Say`. |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |
| `teamOnly` | `dynamic` | — | The team only input consumed by `Host_Say`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1885)

<a id="function-function-miniquake-host-host-say-f-function-host-say-f-session-arguments-src-miniquake-host-ml-672447921"></a>
### Host_Say_f

```ml
function Host_Say_f(session, arguments)
```

Apply the Quake-compatible host say f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_Say_f`. |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1902)

<a id="function-function-miniquake-host-host-say-team-f-function-host-say-team-f-session-arguments-src-miniquake-host-ml-1566210655"></a>
### Host_Say_Team_f

```ml
function Host_Say_Team_f(session, arguments)
```

Apply the Quake-compatible host say team f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_Say_Team_f`. |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1909)

<a id="function-function-miniquake-host-host-serverframe-function-host-serverframe-session-src-miniquake-host-ml-992735499"></a>
### Host_ServerFrame

```ml
function Host_ServerFrame(session)
```

Apply the Quake-compatible host server frame behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_ServerFrame`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L3825)

<a id="function-function-miniquake-host-host-shutdown-function-host-shutdown-session-src-miniquake-host-ml-1010433761"></a>
### Host_Shutdown

```ml
function Host_Shutdown(session)
```

Apply the Quake-compatible host shutdown behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_Shutdown`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L4332)

<a id="function-function-miniquake-host-host-shutdownserver-function-host-shutdownserver-session-crash-src-miniquake-host-ml-1457785488"></a>
### Host_ShutdownServer

```ml
function Host_ShutdownServer(session, crash)
```

Apply the Quake-compatible host shutdown server behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_ShutdownServer`. |
| `crash` | `dynamic` | — | The crash input consumed by `Host_ShutdownServer`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L981)

<a id="function-function-miniquake-host-host-spawn-f-function-host-spawn-f-src-miniquake-host-ml-1729182561"></a>
### Host_Spawn_f

```ml
function Host_Spawn_f()
```

Apply the Quake-compatible host spawn f behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1960)

<a id="function-function-miniquake-host-host-startdemos-f-function-host-startdemos-f-session-arguments-src-miniquake-host-ml-535998157"></a>
### Host_Startdemos_f

```ml
function Host_Startdemos_f(session, arguments)
```

Apply the Quake-compatible host startdemos f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_Startdemos_f`. |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L2111)

<a id="function-function-miniquake-host-host-status-f-function-host-status-f-session-src-miniquake-host-ml-618398799"></a>
### Host_Status_f

```ml
function Host_Status_f(session)
```

Apply the Quake-compatible host status f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_Status_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1625)

<a id="function-function-miniquake-host-host-stopdemo-f-function-host-stopdemo-f-session-src-miniquake-host-ml-1763029089"></a>
### Host_Stopdemo_f

```ml
function Host_Stopdemo_f(session)
```

Apply the Quake-compatible host stopdemo f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_Stopdemo_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L2161)

<a id="function-function-miniquake-host-host-tell-f-function-host-tell-f-session-arguments-src-miniquake-host-ml-686785083"></a>
### Host_Tell_f

```ml
function Host_Tell_f(session, arguments)
```

Apply the Quake-compatible host tell f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_Tell_f`. |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1916)

<a id="function-function-miniquake-host-host-version-f-function-host-version-f-src-miniquake-host-ml-892203889"></a>
### Host_Version_f

```ml
function Host_Version_f()
```

Apply the Quake-compatible host version f behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1849)

<a id="function-function-miniquake-host-host-viewframe-f-function-host-viewframe-f-session-arguments-src-miniquake-host-ml-2043954209"></a>
### Host_Viewframe_f

```ml
function Host_Viewframe_f(session, arguments)
```

Apply the Quake-compatible host viewframe f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_Viewframe_f`. |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L2026)

<a id="function-function-miniquake-host-host-viewmodel-f-function-host-viewmodel-f-session-arguments-src-miniquake-host-ml-1138240209"></a>
### Host_Viewmodel_f

```ml
function Host_Viewmodel_f(session, arguments)
```

Apply the Quake-compatible host viewmodel f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_Viewmodel_f`. |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L2001)

<a id="function-function-miniquake-host-host-viewnext-f-function-host-viewnext-f-session-src-miniquake-host-ml-1067696839"></a>
### Host_Viewnext_f

```ml
function Host_Viewnext_f(session)
```

Apply the Quake-compatible host viewnext f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_Viewnext_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L2054)

<a id="function-function-miniquake-host-host-viewprev-f-function-host-viewprev-f-session-src-miniquake-host-ml-1747846171"></a>
### Host_Viewprev_f

```ml
function Host_Viewprev_f(session)
```

Apply the Quake-compatible host viewprev f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_Viewprev_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L2068)

<a id="function-function-miniquake-host-host-writeconfiguration-function-host-writeconfiguration-session-src-miniquake-host-ml-895079775"></a>
### Host_WriteConfiguration

```ml
function Host_WriteConfiguration(session)
```

Apply the Quake-compatible host write configuration behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `Host_WriteConfiguration`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L909)

<a id="function-function-miniquake-host-initialize-function-initialize-session-src-miniquake-host-ml-122383607"></a>
### initialize

```ml
function initialize(session)
```

Initializes ialize for `miniquake.host`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `initialize`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L2975)

<a id="function-function-miniquake-host-interopbool-function-interopbool-value-src-miniquake-host-ml-1057124890"></a>
### interopBool

```ml
function interopBool(value)
```

Implements the `interopBool` operation for `miniquake.host` (interop bool).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `interopBool`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L5756)

<a id="function-function-miniquake-host-interopwriteready-function-interopwriteready-outputprefix-port-mapname-src-miniquake-host-ml-1270986324"></a>
### interopWriteReady

```ml
function interopWriteReady(outputPrefix, port, mapName)
```

Implements the `interopWriteReady` operation for `miniquake.host` (interop write ready).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `outputPrefix` | `dynamic` | — | The output prefix input consumed by `interopWriteReady`. |
| `port` | `dynamic` | — | The port input consumed by `interopWriteReady`. |
| `mapName` | `dynamic` | — | Name of the map to load or inspect. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L5826)

<a id="function-function-miniquake-host-interopwritesummary-function-interopwritesummary-outputprefix-mode-success-frames-address-port-mapname-connected-spawned-signon-clientname-viewentity-modelcount-soundcount-activeclients-errortext-src-miniquake-host-ml-1432999650"></a>
### interopWriteSummary

```ml
function interopWriteSummary(outputPrefix, mode, success, frames, address, port, mapName, connected, spawned, signon, clientName, viewEntity, modelCount, soundCount, activeClients, errorText)
```

Return interop write summary derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `outputPrefix` | `dynamic` | — | The output prefix input consumed by `interopWriteSummary`. |
| `mode` | `dynamic` | — | The mode input consumed by `interopWriteSummary`. |
| `success` | `dynamic` | — | The success input consumed by `interopWriteSummary`. |
| `frames` | `dynamic` | — | The frames input consumed by `interopWriteSummary`. |
| `address` | `dynamic` | — | Network address of the peer. |
| `port` | `dynamic` | — | The port input consumed by `interopWriteSummary`. |
| `mapName` | `dynamic` | — | Name of the map to load or inspect. |
| `connected` | `dynamic` | — | The connected input consumed by `interopWriteSummary`. |
| `spawned` | `dynamic` | — | The spawned input consumed by `interopWriteSummary`. |
| `signon` | `dynamic` | — | The signon input consumed by `interopWriteSummary`. |
| `clientName` | `dynamic` | — | Name that identifies the requested value or resource. |
| `viewEntity` | `dynamic` | — | The view entity input consumed by `interopWriteSummary`. |
| `modelCount` | `dynamic` | — | Number of entries or units to process. |
| `soundCount` | `dynamic` | — | Number of entries or units to process. |
| `activeClients` | `dynamic` | — | The active clients input consumed by `interopWriteSummary`. |
| `errorText` | `dynamic` | — | The error text input consumed by `interopWriteSummary`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L5778)

<a id="function-function-miniquake-host-loadgame-function-loadgame-session-requestedname-src-miniquake-host-ml-1719141316"></a>
### loadGame

```ml
function loadGame(session, requestedName)
```

Read and validate game.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `loadGame`. |
| `requestedName` | `dynamic` | — | Name that identifies the requested value or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1145)

<a id="function-function-miniquake-host-migratemoderninputconfiguration-function-migratemoderninputconfiguration-session-src-miniquake-host-ml-34065087"></a>
### migrateModernInputConfiguration

```ml
function migrateModernInputConfiguration(session)
```

Upgrade legacy retail/default.cfg controls once, after every startup script has run.  This repairs existing installations without overriding bindings that the player customizes after the migrated configuration is saved.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `migrateModernInputConfiguration`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L2799)

<a id="function-function-miniquake-host-networkcommandaddress-function-networkcommandaddress-arguments-src-miniquake-host-ml-85098965"></a>
### networkCommandAddress

```ml
function networkCommandAddress(arguments)
```

Implements the `networkCommandAddress` operation for `miniquake.host` (network command address).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1584)

<a id="function-function-miniquake-host-nextdemo-function-nextdemo-session-src-miniquake-host-ml-1846048223"></a>
### nextDemo

```ml
function nextDemo(session)
```

Return next demo for the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `nextDemo`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L2082)

<a id="function-function-miniquake-host-opt001amapparse-function-opt001amapparse-basedirectory-gamedirectory-mapname-outputprefix-src-miniquake-host-ml-824504714"></a>
### opt001aMapParse

```ml
function opt001aMapParse(baseDirectory, gameDirectory, mapName, outputPrefix)
```

Implements the `opt001aMapParse` operation for `miniquake.host` (opt001a map parse).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `baseDirectory` | `dynamic` | — | Root directory containing the Quake installation. |
| `gameDirectory` | `dynamic` | — | Selected Quake game-data directory. |
| `mapName` | `dynamic` | — | Name of the map to load or inspect. |
| `outputPrefix` | `dynamic` | — | The output prefix input consumed by `opt001aMapParse`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L4817)

<a id="function-function-miniquake-host-opt001anonhandlestable-function-opt001anonhandlestable-before-after-src-miniquake-host-ml-678390154"></a>
### opt001aNonHandleStable

```ml
function opt001aNonHandleStable(before, after)
```

Implements the `opt001aNonHandleStable` operation for `miniquake.host` (opt001a non handle stable).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `before` | `dynamic` | — | The before input consumed by `opt001aNonHandleStable`. |
| `after` | `dynamic` | — | The after input consumed by `opt001aNonHandleStable`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L4802)

<a id="function-function-miniquake-host-opt001aresourceheader-function-opt001aresourceheader-src-miniquake-host-ml-691694305"></a>
### opt001aResourceHeader

```ml
function opt001aResourceHeader()
```

Implements the `opt001aResourceHeader` operation for `miniquake.host` (opt001a resource header).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L4768)

<a id="function-function-miniquake-host-opt001aresourcejson-function-opt001aresourcejson-values-src-miniquake-host-ml-466952041"></a>
### opt001aResourceJson

```ml
function opt001aResourceJson(values)
```

Implements the `opt001aResourceJson` operation for `miniquake.host` (opt001a resource json).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — | The values input consumed by `opt001aResourceJson`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L4788)

<a id="function-function-miniquake-host-opt001aresourcerow-function-opt001aresourcerow-samplename-frameindex-values-src-miniquake-host-ml-1417157341"></a>
### opt001aResourceRow

```ml
function opt001aResourceRow(sampleName, frameIndex, values)
```

Implements the `opt001aResourceRow` operation for `miniquake.host` (opt001a resource row).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `sampleName` | `dynamic` | — | Name that identifies the requested value or resource. |
| `frameIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `values` | `dynamic` | — | The values input consumed by `opt001aResourceRow`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L4776)

<a id="function-function-miniquake-host-opt001arunframes-function-opt001arunframes-session-framecount-phase-src-miniquake-host-ml-771610172"></a>
### opt001aRunFrames

```ml
function opt001aRunFrames(session, frameCount, phase)
```

Implements the `opt001aRunFrames` operation for `miniquake.host` (opt001a run frames).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `opt001aRunFrames`. |
| `frameCount` | `dynamic` | — | Number of entries or units to process. |
| `phase` | `dynamic` | — | The phase input consumed by `opt001aRunFrames`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L4942)

<a id="function-function-miniquake-host-opt001asessionarguments-function-opt001asessionarguments-basedirectory-gamedirectory-mapname-mode-port-width-height-src-miniquake-host-ml-1288006532"></a>
### opt001aSessionArguments

```ml
function opt001aSessionArguments(baseDirectory, gameDirectory, mapName, mode, port, width, height)
```

Implements the `opt001aSessionArguments` operation for `miniquake.host` (opt001a session arguments).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `baseDirectory` | `dynamic` | — | Root directory containing the Quake installation. |
| `gameDirectory` | `dynamic` | — | Selected Quake game-data directory. |
| `mapName` | `dynamic` | — | Name of the map to load or inspect. |
| `mode` | `dynamic` | — | The mode input consumed by `opt001aSessionArguments`. |
| `port` | `dynamic` | — | The port input consumed by `opt001aSessionArguments`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L4876)

<a id="function-function-miniquake-host-opt001bchangeleveltrigger-function-opt001bchangeleveltrigger-session-destination-src-miniquake-host-ml-570240777"></a>
### opt001bChangeLevelTrigger

```ml
function opt001bChangeLevelTrigger(session, destination)
```

Implements the `opt001bChangeLevelTrigger` operation for `miniquake.host` (opt001b change level trigger).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `opt001bChangeLevelTrigger`. |
| `destination` | `dynamic` | — | Destination value or collection to update. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L5025)

<a id="function-function-miniquake-host-originalinteropclientnetworkprovenance-function-originalinteropclientnetworkprovenance-session-controladdress-src-miniquake-host-ml-889478918"></a>
### originalInteropClientNetworkProvenance

```ml
function originalInteropClientNetworkProvenance(session, controlAddress)
```

Implements the `originalInteropClientNetworkProvenance` operation for `miniquake.host` (original interop client network provenance).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `originalInteropClientNetworkProvenance`. |
| `controlAddress` | `dynamic` | — | The control address input consumed by `originalInteropClientNetworkProvenance`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L5977)

<a id="function-function-miniquake-host-playdemo-function-playdemo-session-requestedname-timed-src-miniquake-host-ml-2093947877"></a>
### playDemo

```ml
function playDemo(session, requestedName, timed)
```

Play demo through the active media subsystem.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `playDemo`. |
| `requestedName` | `dynamic` | — | Name that identifies the requested value or resource. |
| `timed` | `dynamic` | — | The timed input consumed by `playDemo`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1544)

<a id="function-function-miniquake-host-playerflagenabled-function-playerflagenabled-session-flag-src-miniquake-host-ml-990277669"></a>
### playerFlagEnabled

```ml
function playerFlagEnabled(session, flag)
```

Report whether player flag enabled holds for the active state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `playerFlagEnabled`. |
| `flag` | `dynamic` | — | The flag input consumed by `playerFlagEnabled`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1207)

<a id="function-function-miniquake-host-playlocalsound-function-playlocalsound-session-name-src-miniquake-host-ml-2097226542"></a>
### playLocalSound

```ml
function playLocalSound(session, name)
```

Play local sound through the active media subsystem.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `playLocalSound`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L3141)

<a id="function-function-miniquake-host-playmenusound-function-playmenusound-session-name-src-miniquake-host-ml-1528481510"></a>
### playMenuSound

```ml
function playMenuSound(session, name)
```

Play menu sound through the active media subsystem.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `playMenuSound`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L3151)

<a id="function-function-miniquake-host-precacheplayablelevel-function-precacheplayablelevel-session-developervalue-src-miniquake-host-ml-1113089396"></a>
### precachePlayableLevel

```ml
function precachePlayableLevel(session, developerValue)
```

Complete every deterministic client-side first-use cache before gameplay is exposed. This corresponds to the original CL_InitTEnts/S_BeginPrecaching and renderer cache work, with the modern OGG/audio queue included as well.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `precachePlayableLevel`. |
| `developerValue` | `dynamic` | — | The developer value input consumed by `precachePlayableLevel`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L495)

<a id="function-function-miniquake-host-preparedemoscene-function-preparedemoscene-session-src-miniquake-host-ml-1199982011"></a>
### prepareDemoScene

```ml
function prepareDemoScene(session)
```

Implements the `prepareDemoScene` operation for `miniquake.host` (prepare demo scene).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `prepareDemoScene`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1336)

<a id="function-function-miniquake-host-printframename-function-printframename-model-frame-src-miniquake-host-ml-1696187147"></a>
### PrintFrameName

```ml
function PrintFrameName(model, frame)
```

Format and emit frame name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `model` | `dynamic` | — | Model resource processed by the operation. |
| `frame` | `dynamic` | — | The frame input consumed by `PrintFrameName`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L2042)

<a id="function-function-miniquake-host-printresourcedelta-function-printresourcedelta-label-before-after-high-src-miniquake-host-ml-1758032646"></a>
### printResourceDelta

```ml
function printResourceDelta(label, before, after, high)
```

Format and emit resource delta.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `dynamic` | — | The label input consumed by `printResourceDelta`. |
| `before` | `dynamic` | — | The before input consumed by `printResourceDelta`. |
| `after` | `dynamic` | — | The after input consumed by `printResourceDelta`. |
| `high` | `dynamic` | — | The high input consumed by `printResourceDelta`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L4551)

<a id="function-function-miniquake-host-printresourcesoak-function-printresourcesoak-mode-target-framecount-before-after-high-cycles-demomessages-stable-src-miniquake-host-ml-706185031"></a>
### printResourceSoak

```ml
function printResourceSoak(mode, target, frameCount, before, after, high, cycles, demoMessages, stable)
```

Format and emit resource soak.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mode` | `dynamic` | — | The mode input consumed by `printResourceSoak`. |
| `target` | `dynamic` | — | The target input consumed by `printResourceSoak`. |
| `frameCount` | `dynamic` | — | Number of entries or units to process. |
| `before` | `dynamic` | — | The before input consumed by `printResourceSoak`. |
| `after` | `dynamic` | — | The after input consumed by `printResourceSoak`. |
| `high` | `dynamic` | — | The high input consumed by `printResourceSoak`. |
| `cycles` | `dynamic` | — | The cycles input consumed by `printResourceSoak`. |
| `demoMessages` | `dynamic` | — | The demo messages input consumed by `printResourceSoak`. |
| `stable` | `dynamic` | — | The stable input consumed by `printResourceSoak`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L4566)

<a id="function-function-miniquake-host-processconsoleinput-function-processconsoleinput-session-src-miniquake-host-ml-438462491"></a>
### processConsoleInput

```ml
function processConsoleInput(session)
```

Execute console input.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `processConsoleInput`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L3649)

<a id="function-function-miniquake-host-protocolqueuesnapshot-function-protocolqueuesnapshot-session-src-miniquake-host-ml-1580884889"></a>
### protocolQueueSnapshot

```ml
function protocolQueueSnapshot(session)
```

Implements the `protocolQueueSnapshot` operation for `miniquake.host` (protocol queue snapshot).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `protocolQueueSnapshot`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L4456)

<a id="function-function-miniquake-host-pumpclient-function-pumpclient-session-src-miniquake-host-ml-131250483"></a>
### pumpClient

```ml
function pumpClient(session)
```

Advance client by one processing step.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `pumpClient`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1213)

<a id="function-function-miniquake-host-pumpnewconnections-function-pumpnewconnections-session-src-miniquake-host-ml-1702903419"></a>
### pumpNewConnections

```ml
function pumpNewConnections(session)
```

Advance new connections by one processing step.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `pumpNewConnections`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1482)

<a id="function-function-miniquake-host-queuestartupcommands-function-queuestartupcommands-session-src-miniquake-host-ml-532596767"></a>
### queueStartupCommands

```ml
function queueStartupCommands(session)
```

Add state for queue startup commands.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `queueStartupCommands`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L2782)

<a id="function-function-miniquake-host-rebuildrendererresources-function-rebuildrendererresources-session-src-miniquake-host-ml-1051990971"></a>
### rebuildRendererResources

```ml
function rebuildRendererResources(session)
```

Implements the `rebuildRendererResources` operation for `miniquake.host` (rebuild renderer resources).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `rebuildRendererResources`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1284)

<a id="function-function-miniquake-host-refreshsaveslots-function-refreshsaveslots-session-src-miniquake-host-ml-953546243"></a>
### refreshSaveSlots

```ml
function refreshSaveSlots(session)
```

Implements the `refreshSaveSlots` operation for `miniquake.host` (refresh save slots).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `refreshSaveSlots`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1092)

<a id="function-function-miniquake-host-registercvar-function-registercvar-registry-name-value-archive-serverflag-src-miniquake-host-ml-1138783577"></a>
### registerCvar

```ml
function registerCvar(registry, name, value, archive, serverFlag)
```

Update subsystem configuration for register cvar.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `registry` | `dynamic` | — | The registry input consumed by `registerCvar`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `value` | `dynamic` | — | Value consumed by `registerCvar`. |
| `archive` | `dynamic` | — | The archive input consumed by `registerCvar`. |
| `serverFlag` | `dynamic` | — | The server flag input consumed by `registerCvar`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L105)

<a id="function-function-miniquake-host-resourcehighwater-function-resourcehighwater-high-value-src-miniquake-host-ml-933835622"></a>
### resourceHighWater

```ml
function resourceHighWater(high, value)
```

Implements the `resourceHighWater` operation for `miniquake.host` (resource high water).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `high` | `dynamic` | — | The high input consumed by `resourceHighWater`. |
| `value` | `dynamic` | — | Value consumed by `resourceHighWater`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L4527)

<a id="function-function-miniquake-host-resourcesnapshot-function-resourcesnapshot-session-src-miniquake-host-ml-349282359"></a>
### resourceSnapshot

```ml
function resourceSnapshot(session)
```

Implements the `resourceSnapshot` operation for `miniquake.host` (resource snapshot).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `resourceSnapshot`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L4493)

<a id="function-function-miniquake-host-resourcestable-function-resourcestable-before-after-src-miniquake-host-ml-1889311098"></a>
### resourceStable

```ml
function resourceStable(before, after)
```

Implements the `resourceStable` operation for `miniquake.host` (resource stable).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `before` | `dynamic` | — | The before input consumed by `resourceStable`. |
| `after` | `dynamic` | — | The after input consumed by `resourceStable`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L4542)

<a id="function-function-miniquake-host-restartlevel-function-restartlevel-session-mapname-src-miniquake-host-ml-499059226"></a>
### restartLevel

```ml
function restartLevel(session, mapName)
```

Implements the `restartLevel` operation for `miniquake.host` (restart level).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `restartLevel`. |
| `mapName` | `dynamic` | — | Name of the map to load or inspect. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L484)

<a id="function-function-miniquake-host-restartrenderer-function-restartrenderer-session-backend-src-miniquake-host-ml-1924489665"></a>
### restartRenderer

```ml
function restartRenderer(session, backend)
```

Implements the `restartRenderer` operation for `miniquake.host` (restart renderer).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `restartRenderer`. |
| `backend` | `dynamic` | — | The backend input consumed by `restartRenderer`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1321)

<a id="function-function-miniquake-host-restartsoakdemo-function-restartsoakdemo-session-demoname-src-miniquake-host-ml-2110982727"></a>
### restartSoakDemo

```ml
function restartSoakDemo(session, demoName)
```

Implements the `restartSoakDemo` operation for `miniquake.host` (restart soak demo).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `restartSoakDemo`. |
| `demoName` | `dynamic` | — | Name that identifies the requested value or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L4675)

<a id="function-function-miniquake-host-run-function-run-args-src-miniquake-host-ml-1094055920"></a>
### run

```ml
function run(args)
```

Implements the `run` operation for `miniquake.host` (run).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `args` | `dynamic` | — | Command-line arguments supplied by the host process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L4377)

<a id="function-function-miniquake-host-rundemomodesoak-function-rundemomodesoak-args-demoname-framecount-src-miniquake-host-ml-1696817036"></a>
### runDemoModeSoak

```ml
function runDemoModeSoak(args, demoName, frameCount)
```

Execute demo mode soak.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `args` | `dynamic` | — | Command-line arguments supplied by the host process. |
| `demoName` | `dynamic` | — | Name that identifies the requested value or resource. |
| `frameCount` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L4684)

<a id="function-function-miniquake-host-runendscreenevidence-function-runendscreenevidence-basedirectory-gamedirectory-width-height-outputprefix-src-miniquake-host-ml-292927532"></a>
### runEndscreenEvidence

```ml
function runEndscreenEvidence(baseDirectory, gameDirectory, width, height, outputPrefix)
```

Execute endscreen evidence.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `baseDirectory` | `dynamic` | — | Root directory containing the Quake installation. |
| `gameDirectory` | `dynamic` | — | Selected Quake game-data directory. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `outputPrefix` | `dynamic` | — | The output prefix input consumed by `runEndscreenEvidence`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L5204)

<a id="function-function-miniquake-host-runheadlessframes-function-runheadlessframes-args-framecount-src-miniquake-host-ml-124848346"></a>
### runHeadlessFrames

```ml
function runHeadlessFrames(args, frameCount)
```

Execute headless frames.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `args` | `dynamic` | — | Command-line arguments supplied by the host process. |
| `frameCount` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L6140)

<a id="function-function-miniquake-host-runlongsoak-function-runlongsoak-basedirectory-gamedirectory-mode-target-framecount-port-src-miniquake-host-ml-2019113095"></a>
### runLongSoak

```ml
function runLongSoak(baseDirectory, gameDirectory, mode, target, frameCount, port)
```

Execute long soak.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `baseDirectory` | `dynamic` | — | Root directory containing the Quake installation. |
| `gameDirectory` | `dynamic` | — | Selected Quake game-data directory. |
| `mode` | `dynamic` | — | The mode input consumed by `runLongSoak`. |
| `target` | `dynamic` | — | The target input consumed by `runLongSoak`. |
| `frameCount` | `dynamic` | — | Number of entries or units to process. |
| `port` | `dynamic` | — | The port input consumed by `runLongSoak`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L5590)

<a id="function-function-miniquake-host-runmeasuredframes-function-runmeasuredframes-session-framecount-src-miniquake-host-ml-604185869"></a>
### runMeasuredFrames

```ml
function runMeasuredFrames(session, frameCount)
```

Execute measured frames.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `runMeasuredFrames`. |
| `frameCount` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L4618)

<a id="function-function-miniquake-host-runopt001aframebaseline-function-runopt001aframebaseline-basedirectory-gamedirectory-mapname-mode-warmupframes-measureframes-outputprefix-renderername-width-height-src-miniquake-host-ml-1285750272"></a>
### runOpt001AFrameBaseline

```ml
function runOpt001AFrameBaseline(baseDirectory, gameDirectory, mapName, mode, warmupFrames, measureFrames, outputPrefix, rendererName, width, height)
```

Execute opt001 aframe baseline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `baseDirectory` | `dynamic` | — | Root directory containing the Quake installation. |
| `gameDirectory` | `dynamic` | — | Selected Quake game-data directory. |
| `mapName` | `dynamic` | — | Name of the map to load or inspect. |
| `mode` | `dynamic` | — | The mode input consumed by `runOpt001AFrameBaseline`. |
| `warmupFrames` | `dynamic` | — | The warmup frames input consumed by `runOpt001AFrameBaseline`. |
| `measureFrames` | `dynamic` | — | The measure frames input consumed by `runOpt001AFrameBaseline`. |
| `outputPrefix` | `dynamic` | — | The output prefix input consumed by `runOpt001AFrameBaseline`. |
| `rendererName` | `dynamic` | — | Name that identifies the requested value or resource. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L4968)

<a id="function-function-miniquake-host-runopt001ahandleplateau-function-runopt001ahandleplateau-basedirectory-gamedirectory-mapname-warmupframes-windowframes-windowcount-port-outputprefix-renderername-src-miniquake-host-ml-15718952"></a>
### runOpt001AHandlePlateau

```ml
function runOpt001AHandlePlateau(baseDirectory, gameDirectory, mapName, warmupFrames, windowFrames, windowCount, port, outputPrefix, rendererName)
```

Execute opt001 ahandle plateau.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `baseDirectory` | `dynamic` | — | Root directory containing the Quake installation. |
| `gameDirectory` | `dynamic` | — | Selected Quake game-data directory. |
| `mapName` | `dynamic` | — | Name of the map to load or inspect. |
| `warmupFrames` | `dynamic` | — | The warmup frames input consumed by `runOpt001AHandlePlateau`. |
| `windowFrames` | `dynamic` | — | The window frames input consumed by `runOpt001AHandlePlateau`. |
| `windowCount` | `dynamic` | — | Number of entries or units to process. |
| `port` | `dynamic` | — | The port input consumed by `runOpt001AHandlePlateau`. |
| `outputPrefix` | `dynamic` | — | The output prefix input consumed by `runOpt001AHandlePlateau`. |
| `rendererName` | `dynamic` | — | Name that identifies the requested value or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L5491)

<a id="function-function-miniquake-host-runopt001bquakecexit-function-runopt001bquakecexit-session-destination-maximumframes-src-miniquake-host-ml-834722479"></a>
### runOpt001BQuakeCExit

```ml
function runOpt001BQuakeCExit(session, destination, maximumFrames)
```

Execute opt001 bquake cexit.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `runOpt001BQuakeCExit`. |
| `destination` | `dynamic` | — | Destination value or collection to update. |
| `maximumFrames` | `dynamic` | — | The maximum frames input consumed by `runOpt001BQuakeCExit`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L5048)

<a id="function-function-miniquake-host-runopt001btransition-function-runopt001btransition-basedirectory-gamedirectory-framecount-outputprefix-renderername-src-miniquake-host-ml-600417033"></a>
### runOpt001BTransition

```ml
function runOpt001BTransition(baseDirectory, gameDirectory, frameCount, outputPrefix, rendererName)
```

Execute opt001 btransition.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `baseDirectory` | `dynamic` | — | Root directory containing the Quake installation. |
| `gameDirectory` | `dynamic` | — | Selected Quake game-data directory. |
| `frameCount` | `dynamic` | — | Number of entries or units to process. |
| `outputPrefix` | `dynamic` | — | The output prefix input consumed by `runOpt001BTransition`. |
| `rendererName` | `dynamic` | — | Name that identifies the requested value or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L5094)

<a id="function-function-miniquake-host-runoriginalinteropclient-function-runoriginalinteropclient-args-maximumframes-outputprefix-controladdress-controlport-src-miniquake-host-ml-1650287062"></a>
### runOriginalInteropClient

```ml
function runOriginalInteropClient(args, maximumFrames, outputPrefix, controlAddress, controlPort)
```

Execute original interop client.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `args` | `dynamic` | — | Command-line arguments supplied by the host process. |
| `maximumFrames` | `dynamic` | — | The maximum frames input consumed by `runOriginalInteropClient`. |
| `outputPrefix` | `dynamic` | — | The output prefix input consumed by `runOriginalInteropClient`. |
| `controlAddress` | `dynamic` | — | The control address input consumed by `runOriginalInteropClient`. |
| `controlPort` | `dynamic` | — | The control port input consumed by `runOriginalInteropClient`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L6000)

<a id="function-function-miniquake-host-runoriginalinteropserver-function-runoriginalinteropserver-args-maximumframes-outputprefix-src-miniquake-host-ml-1901559977"></a>
### runOriginalInteropServer

```ml
function runOriginalInteropServer(args, maximumFrames, outputPrefix)
```

Execute original interop server.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `args` | `dynamic` | — | Command-line arguments supplied by the host process. |
| `maximumFrames` | `dynamic` | — | The maximum frames input consumed by `runOriginalInteropServer`. |
| `outputPrefix` | `dynamic` | — | The output prefix input consumed by `runOriginalInteropServer`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L5854)

<a id="function-function-miniquake-host-runrendererswitchsmoke-function-runrendererswitchsmoke-basedirectory-gamedirectory-mapname-framecount-outputprefix-src-miniquake-host-ml-1445881694"></a>
### runRendererSwitchSmoke

```ml
function runRendererSwitchSmoke(baseDirectory, gameDirectory, mapName, frameCount, outputPrefix)
```

Execute renderer switch smoke.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `baseDirectory` | `dynamic` | — | Root directory containing the Quake installation. |
| `gameDirectory` | `dynamic` | — | Selected Quake game-data directory. |
| `mapName` | `dynamic` | — | Name of the map to load or inspect. |
| `frameCount` | `dynamic` | — | Number of entries or units to process. |
| `outputPrefix` | `dynamic` | — | The output prefix input consumed by `runRendererSwitchSmoke`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L5164)

<a id="function-function-miniquake-host-runrenderevidence-function-runrenderevidence-args-framecount-outputprefix-src-miniquake-host-ml-1324740689"></a>
### runRenderEvidence

```ml
function runRenderEvidence(args, frameCount, outputPrefix)
```

Execute render evidence.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `args` | `dynamic` | — | Command-line arguments supplied by the host process. |
| `frameCount` | `dynamic` | — | Number of entries or units to process. |
| `outputPrefix` | `dynamic` | — | The output prefix input consumed by `runRenderEvidence`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L5682)

<a id="function-function-miniquake-host-runservermodesoak-function-runservermodesoak-args-mode-target-framecount-src-miniquake-host-ml-979159034"></a>
### runServerModeSoak

```ml
function runServerModeSoak(args, mode, target, frameCount)
```

Execute server mode soak.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `args` | `dynamic` | — | Command-line arguments supplied by the host process. |
| `mode` | `dynamic` | — | The mode input consumed by `runServerModeSoak`. |
| `target` | `dynamic` | — | The target input consumed by `runServerModeSoak`. |
| `frameCount` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L4645)

<a id="function-function-miniquake-host-runsoak-function-runsoak-args-framecount-src-miniquake-host-ml-1300103756"></a>
### runSoak

```ml
function runSoak(args, frameCount)
```

Execute soak.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `args` | `dynamic` | — | Command-line arguments supplied by the host process. |
| `frameCount` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L5647)

<a id="function-function-miniquake-host-runuiresolutionmatrix-function-runuiresolutionmatrix-basedirectory-gamedirectory-outputprefix-src-miniquake-host-ml-1757268877"></a>
### runUiResolutionMatrix

```ml
function runUiResolutionMatrix(baseDirectory, gameDirectory, outputPrefix)
```

Execute ui resolution matrix.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `baseDirectory` | `dynamic` | — | Root directory containing the Quake installation. |
| `gameDirectory` | `dynamic` | — | Selected Quake game-data directory. |
| `outputPrefix` | `dynamic` | — | The output prefix input consumed by `runUiResolutionMatrix`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L5340)

<a id="function-function-miniquake-host-savegame-function-savegame-session-requestedname-src-miniquake-host-ml-1417616380"></a>
### saveGame

```ml
function saveGame(session, requestedName)
```

Encode and write game.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `saveGame`. |
| `requestedName` | `dynamic` | — | Name that identifies the requested value or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1117)

<a id="function-function-miniquake-host-sendclientintentions-function-sendclientintentions-session-src-miniquake-host-ml-1785789583"></a>
### sendClientIntentions

```ml
function sendClientIntentions(session)
```

Send client intentions through the active connection.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `sendClientIntentions`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L3772)

<a id="function-function-miniquake-host-setconsoleactive-function-setconsoleactive-session-active-src-miniquake-host-ml-38130385"></a>
### setConsoleActive

```ml
function setConsoleActive(session, active)
```

Update module state for console active.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `setConsoleActive`. |
| `active` | `dynamic` | — | The active input consumed by `setConsoleActive`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L3235)

<a id="function-function-miniquake-host-setmenuactive-function-setmenuactive-session-active-src-miniquake-host-ml-180123799"></a>
### setMenuActive

```ml
function setMenuActive(session, active)
```

Update module state for menu active.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `setMenuActive`. |
| `active` | `dynamic` | — | The active input consumed by `setMenuActive`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L3179)

<a id="function-function-miniquake-host-setplayerflag-function-setplayerflag-session-flag-enabled-src-miniquake-host-ml-169228734"></a>
### setPlayerFlag

```ml
function setPlayerFlag(session, flag, enabled)
```

Update module state for player flag.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `setPlayerFlag`. |
| `flag` | `dynamic` | — | The flag input consumed by `setPlayerFlag`. |
| `enabled` | `dynamic` | — | Whether the optional behavior is enabled. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1196)

<a id="function-function-miniquake-host-shouldpolllivebuttonbindings-inline-function-shouldpolllivebuttonbindings-headless-destinationisgame-consoleactive-menuactive-src-miniquake-host-ml-617352107"></a>
### shouldPollLiveButtonBindings

```ml
inline function shouldPollLiveButtonBindings(headless, destinationIsGame, consoleActive, menuActive)
```

Live Win32 button polling is a convenience layer for the interactive port. It must never participate in a headless/deterministic run: unlike original WinQuake's window-message input, GetAsyncKeyState-style polling can observe keys pressed in another application and make two identical traces diverge.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `headless` | `dynamic` | — | The headless input consumed by `shouldPollLiveButtonBindings`. |
| `destinationIsGame` | `dynamic` | — | The destination is game input consumed by `shouldPollLiveButtonBindings`. |
| `consoleActive` | `dynamic` | — | The console active input consumed by `shouldPollLiveButtonBindings`. |
| `menuActive` | `dynamic` | — | The menu active input consumed by `shouldPollLiveButtonBindings`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L3748)

<a id="function-function-miniquake-host-shouldrenderwindowframe-inline-function-shouldrenderwindowframe-windowcreated-minimized-width-height-src-miniquake-host-ml-1298084341"></a>
### shouldRenderWindowFrame

```ml
inline function shouldRenderWindowFrame(windowCreated, minimized, width, height)
```

Report whether the current Win32 client area can accept a complete render frame. Minimizing a window makes GetClientRect transiently return 0x0; the original WinQuake loop skips that frame instead of feeding invalid dimensions into the screen and status-bar layout code.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `windowCreated` | `dynamic` | — | The window created input consumed by `shouldRenderWindowFrame`. |
| `minimized` | `dynamic` | — | The minimized input consumed by `shouldRenderWindowFrame`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L3760)

<a id="function-function-miniquake-host-shutdown-function-shutdown-session-src-miniquake-host-ml-464972823"></a>
### shutdown

```ml
function shutdown(session)
```

Implements the `shutdown` operation for `miniquake.host` (shutdown).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `shutdown`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L4371)

<a id="function-function-miniquake-host-soak-function-soak-session-framecount-frametime-src-miniquake-host-ml-296882441"></a>
### soak

```ml
function soak(session, frameCount, frameTime)
```

Implements the `soak` operation for `miniquake.host` (soak).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `soak`. |
| `frameCount` | `dynamic` | — | Number of entries or units to process. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L5628)

<a id="function-function-miniquake-host-soakframeerror-function-soakframeerror-session-phase-frameindex-frameerror-src-miniquake-host-ml-1945720058"></a>
### soakFrameError

```ml
function soakFrameError(session, phase, frameIndex, frameError)
```

Implements the `soakFrameError` operation for `miniquake.host` (soak frame error).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `soakFrameError`. |
| `phase` | `dynamic` | — | The phase input consumed by `soakFrameError`. |
| `frameIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `frameError` | `dynamic` | — | The frame error input consumed by `soakFrameError`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L4609)

<a id="function-function-miniquake-host-startmap-function-startmap-session-mapname-src-miniquake-host-ml-364852894"></a>
### startMap

```ml
function startMap(session, mapName)
```

Initialize state for start map.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `startMap`. |
| `mapName` | `dynamic` | — | Name of the map to load or inspect. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L470)

<a id="function-function-miniquake-host-stepdemoplayback-function-stepdemoplayback-session-src-miniquake-host-ml-136290471"></a>
### stepDemoPlayback

```ml
function stepDemoPlayback(session)
```

Advance demo playback by one processing step.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `stepDemoPlayback`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1530)

<a id="function-function-miniquake-host-stopattractmode-function-stopattractmode-session-src-miniquake-host-ml-1071724915"></a>
### stopAttractMode

```ml
function stopAttractMode(session)
```

Stop attract playback before a user-selected game action. This also removes a next-demo command queued at the end of the preceding host frame.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `stopAttractMode`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L2093)

<a id="function-function-miniquake-host-stopdemorecording-function-stopdemorecording-session-src-miniquake-host-ml-125481259"></a>
### stopDemoRecording

```ml
function stopDemoRecording(session)
```

Finalize state for stop demo recording.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `stopDemoRecording`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L1222)

<a id="function-function-miniquake-host-sv-broadcastprintf-function-sv-broadcastprintf-session-text-src-miniquake-host-ml-212754866"></a>
### SV_BroadcastPrintf

```ml
function SV_BroadcastPrintf(session, text)
```

Apply the Quake-compatible sv broadcast printf behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `SV_BroadcastPrintf`. |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L924)

<a id="function-function-miniquake-host-sv-clientprintf-function-sv-clientprintf-clientvalue-text-src-miniquake-host-ml-802770194"></a>
### SV_ClientPrintf

```ml
function SV_ClientPrintf(clientValue, text)
```

Apply the Quake-compatible sv client printf behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `clientValue` | `dynamic` | — | The client value input consumed by `SV_ClientPrintf`. |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L917)

<a id="function-function-miniquake-host-sv-dropclient-function-sv-dropclient-session-clientvalue-crash-src-miniquake-host-ml-1859798362"></a>
### SV_DropClient

```ml
function SV_DropClient(session, clientValue, crash)
```

Apply the Quake-compatible sv drop client behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `SV_DropClient`. |
| `clientValue` | `dynamic` | — | The client value input consumed by `SV_DropClient`. |
| `crash` | `dynamic` | — | The crash input consumed by `SV_DropClient`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L942)

<a id="function-function-miniquake-host-synchronizeclientrelinkmodels-function-synchronizeclientrelinkmodels-session-src-miniquake-host-ml-195042759"></a>
### synchronizeClientRelinkModels

```ml
function synchronizeClientRelinkModels(session)
```

Update module state for client relink models.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `synchronizeClientRelinkModels`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L3046)

<a id="global-global-miniquake-host-titlefpsinitialized-titlefpsinitialized-src-miniquake-host-ml-1570218445"></a>
### titleFpsInitialized

```ml
titleFpsInitialized
```

Tracks the module-level title fps initialized state owned by `miniquake.host`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L72)

<a id="global-global-miniquake-host-titlefpslastframe-titlefpslastframe-src-miniquake-host-ml-1508338721"></a>
### titleFpsLastFrame

```ml
titleFpsLastFrame
```

Tracks the module-level title fps last frame state owned by `miniquake.host`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L74)

<a id="global-global-miniquake-host-titlefpslastrealtime-titlefpslastrealtime-src-miniquake-host-ml-1290800309"></a>
### titleFpsLastRealtime

```ml
titleFpsLastRealtime
```

Tracks the module-level title fps last realtime state owned by `miniquake.host`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L76)

<a id="global-global-miniquake-host-titlefpslastvalue-titlefpslastvalue-src-miniquake-host-ml-1747365321"></a>
### titleFpsLastValue

```ml
titleFpsLastValue
```

Tracks the module-level title fps last value state owned by `miniquake.host`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L78)

<a id="function-function-miniquake-host-togglemenu-function-togglemenu-session-src-miniquake-host-ml-55185195"></a>
### toggleMenu

```ml
function toggleMenu(session)
```

menu.c::M_ToggleMenu_f returns from a submenu to the main menu before it closes the menu. Keep this distinct from explicit action-driven closes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `toggleMenu`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L3222)

<a id="function-function-miniquake-host-transitionmap-function-transitionmap-session-mapname-preserveclients-savechangeparms-deferlocalconnection-src-miniquake-host-ml-1844387905"></a>
### transitionMap

```ml
function transitionMap(session, mapName, preserveClients, saveChangeParms, deferLocalConnection)
```

Implements the `transitionMap` operation for `miniquake.host` (transition map).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `transitionMap`. |
| `mapName` | `dynamic` | — | Name of the map to load or inspect. |
| `preserveClients` | `dynamic` | — | The preserve clients input consumed by `transitionMap`. |
| `saveChangeParms` | `dynamic` | — | The save change parms input consumed by `transitionMap`. |
| `deferLocalConnection` | `dynamic` | — | The defer local connection input consumed by `transitionMap`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L715)

<a id="function-function-miniquake-host-udpendpointcount-function-udpendpointcount-session-src-miniquake-host-ml-560314815"></a>
### udpEndpointCount

```ml
function udpEndpointCount(session)
```

Return udp endpoint count derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `udpEndpointCount`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L4482)

<a id="function-function-miniquake-host-updatemousecapture-function-updatemousecapture-session-src-miniquake-host-ml-1827630783"></a>
### updateMouseCapture

```ml
function updateMouseCapture(session)
```

Update module state for mouse capture.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `updateMouseCapture`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L415)

<a id="function-function-miniquake-host-updatetitle-function-updatetitle-session-src-miniquake-host-ml-375847609"></a>
### updateTitle

```ml
function updateTitle(session)
```

Update module state for title.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `updateTitle`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L3709)

<a id="function-function-miniquake-host-viewthingmodel-function-viewthingmodel-session-item-src-miniquake-host-ml-838435706"></a>
### viewthingModel

```ml
function viewthingModel(session, item)
```

Implements the `viewthingModel` operation for `miniquake.host` (viewthing model).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `viewthingModel`. |
| `item` | `dynamic` | — | The item input consumed by `viewthingModel`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L2017)

<a id="function-function-miniquake-host-warmuiresolutionscene-function-warmuiresolutionscene-session-src-miniquake-host-ml-1458973469"></a>
### warmUiResolutionScene

```ml
function warmUiResolutionScene(session)
```

Implements the `warmUiResolutionScene` operation for `miniquake.host` (warm ui resolution scene).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `warmUiResolutionScene`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L5326)

<a id="function-function-miniquake-host-writeconfiguration-function-writeconfiguration-session-src-miniquake-host-ml-635561435"></a>
### writeConfiguration

```ml
function writeConfiguration(session)
```

Encode and write configuration.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `writeConfiguration`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host.ml#L878)
