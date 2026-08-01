[CmdletBinding()]
param(
  [string]$Compiler = "",

  [Alias("StdLibPath", "ImportRoot")]
  [string]$StdLib = "",

  [string]$Python = "",

  [string]$QuakeBase = "",
  [string]$Game = "id1",
  [string]$Map = "start",

  [ValidateRange(1, 1000000)]
  [int]$Frames = 300,

  [ValidateRange(1, 1000000)]
  [int]$TraceFrames = 128,

  [ValidateRange(1, 1000000)]
  [int]$RenderEvidenceFrame = 128,

  [ValidateSet("Release", "Debug")]
  [string]$Configuration = "Release",

  [switch]$SkipBuild,
  [switch]$SkipGameValidation,
  [switch]$SkipTraceValidation,
  [switch]$SkipRenderEvidence,
  [switch]$NetworkTests,
  [switch]$RebuildNative,
  [switch]$Listings,
  [switch]$ContinueIndependentTests = $true,
  [switch]$BisectOnFailure
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$PackageId = "BP-049"
$ParentPackageId = "BP-048"
$NativeTextAbi = "caller_owned_bytes_v1"
$ProtocolTextAbi = "quake_latin1_cstring_v1"
$BlockId = "BP-045-049"
$BlockParentPackageId = "BP-040-044R3"
$ProtocolStatus = "protocol15_frozen_v1"
$QuakeCStatus = "quakec_109_frozen_v1"
$WorldPhysicsStatus = "world_physics_109_frozen_v1"
$HostLifecycleStatus = "host_lifecycle_109_frozen_v1"
$ClientRenderStatus = "client_render_109_frozen_v1"
$WorldRenderStatus = "world_render_109_frozen_v1"
$ModelUiRenderStatus = "model_ui_render_109_frozen_v1"
$DeliveryRevision = "BP-045-049R2"
$Root = $PSScriptRoot
$BuildDirectory = Join-Path $Root "build"
$TraceDirectory = Join-Path $BuildDirectory "bp045-049r2-traces"
$GameExe = Join-Path $BuildDirectory "MiniQuake.exe"
$Verifier = Join-Path $Root "tools\verify.py"
$TraceComparator = Join-Path $Root "tools\compare_traces.py"
$RuntimeTestLogChecker = Join-Path $Root "tools\check_runtime_test_log.py"
$ProtocolVectorChecker = Join-Path $Root "tools\check_protocol15_vectors.py"
$ProtocolCommandChecker = Join-Path $Root "tools\check_protocol15_commands.py"
$ProtocolServerDataChecker = Join-Path $Root "tools\check_protocol15_serverdata.py"
$ProtocolEventChecker = Join-Path $Root "tools\check_protocol15_events.py"
$ProtocolRuntimeEventChecker = Join-Path $Root "tools\check_protocol15_runtime_events.py"
$ProtocolSignonChecker = Join-Path $Root "tools\check_protocol15_signon.py"
$ProtocolDeliveryChecker = Join-Path $Root "tools\check_protocol15_delivery.py"
$ProtocolDatagramChecker = Join-Path $Root "tools\check_protocol15_datagram.py"
$ProtocolDemoChecker = Join-Path $Root "tools\check_protocol15_demo.py"
$ProtocolClosureChecker = Join-Path $Root "tools\check_protocol15_closure.py"
$QuakeCProgsChecker = Join-Path $Root "tools\check_quakec_progs.py"
$QuakeCVMChecker = Join-Path $Root "tools\check_quakec_vm.py"
$QuakeCEdictChecker = Join-Path $Root "tools\check_quakec_edict.py"
$QuakeCBuiltinChecker = Join-Path $Root "tools\check_quakec_builtins.py"
$QuakeCClosureChecker = Join-Path $Root "tools\check_quakec_closure.py"
$WorldHullChecker = Join-Path $Root "tools\check_world_hull.py"
$WorldTraceChecker = Join-Path $Root "tools\check_world_trace.py"
$WorldLinkChecker = Join-Path $Root "tools\check_world_link.py"
$ServerMoveChecker = Join-Path $Root "tools\check_server_move.py"
$ServerPhysicsChecker = Join-Path $Root "tools\check_server_physics.py"
$SvUserMovementChecker = Join-Path $Root "tools\check_sv_user_movement.py"
$ServerUserChecker = Join-Path $Root "tools\check_server_user.py"
$WorldPhysicsClosureChecker = Join-Path $Root "tools\check_world_physics_closure.py"
$HostTimingChecker = Join-Path $Root "tools\check_host_timing.py"
$CommandCvarChecker = Join-Path $Root "tools\check_command_cvar.py"
$DemoLifecycleChecker = Join-Path $Root "tools\check_demo_lifecycle.py"
$SavegameV5Checker = Join-Path $Root "tools\check_savegame_v5.py"
$HostLifecycleClosureChecker = Join-Path $Root "tools\check_host_lifecycle_closure.py"
$ClientStateRenderChecker = Join-Path $Root "tools\check_client_render_035.py"
$ViewStateChecker = Join-Path $Root "tools\check_client_render_036.py"
$TemporaryBeamChecker = Join-Path $Root "tools\check_client_render_037.py"
$ParticleRuntimeChecker = Join-Path $Root "tools\check_client_render_038.py"
$ClientRenderClosureChecker = Join-Path $Root "tools\check_client_render_039.py"
$WorldSurfaceRenderChecker = Join-Path $Root "tools\check_world_render_040.py"
$LightmapAtlasChecker = Join-Path $Root "tools\check_world_render_041.py"
$DynamicLightRenderChecker = Join-Path $Root "tools\check_world_render_042.py"
$SkyWaterRenderChecker = Join-Path $Root "tools\check_world_render_043.py"
$WorldRenderClosureChecker = Join-Path $Root "tools\check_world_render_044.py"
$AliasModelChecker = Join-Path $Root "tools\bp045_alias_model_checker.py"
$SpriteSyncChecker = Join-Path $Root "tools\bp046_sprite_sync_checker.py"
$RenderUiHudChecker = Join-Path $Root "tools\bp047_render_ui_checker.py"
$RenderEvidenceChecker = Join-Path $Root "tools\bp048_render_evidence_checker.py"
$ModelUiRenderChecker = Join-Path $Root "tools\bp049_model_ui_render_checker.py"
$RenderEvidenceComparator = Join-Path $Root "tools\compare_render_evidence.py"
$BuildScript = Join-Path $Root "build.ps1"
$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$TranscriptPath = Join-Path $BuildDirectory ("bp045-049r2-test-{0}.log" -f $Timestamp)
$SummaryPath = Join-Path $BuildDirectory "bp045-049r2-test-summary.json"
$StaticReportPath = Join-Path $BuildDirectory "bp045-049r2-static-verification.json"
$VersionPath = Join-Path $BuildDirectory "bp045-049r2-version.txt"
$BuildChildLogPath = Join-Path $BuildDirectory "bp045-049r2-build-child.log"
$TraceALogPath = Join-Path $BuildDirectory "bp045-049r2-trace-a.log"
$TraceBLogPath = Join-Path $BuildDirectory "bp045-049r2-trace-b.log"
$SnapshotCommandLogPath = Join-Path $BuildDirectory "bp045-049r2-snapshot-command.log"
$TraceComparisonPath = Join-Path $BuildDirectory "bp045-049r2-trace-comparison.json"
$TraceComparisonLogPath = Join-Path $BuildDirectory "bp045-049r2-trace-comparison.log"
$ProtocolVectorReportPath = Join-Path $BuildDirectory "bp045-049r2-protocol15-vectors.json"
$ProtocolVectorLogPath = Join-Path $BuildDirectory "bp045-049r2-protocol15-vectors.log"
$ProtocolCommandReportPath = Join-Path $BuildDirectory "bp045-049r2-protocol15-commands.json"
$ProtocolCommandLogPath = Join-Path $BuildDirectory "bp045-049r2-protocol15-commands.log"
$ProtocolServerDataReportPath = Join-Path $BuildDirectory "bp045-049r2-protocol15-serverdata.json"
$ProtocolServerDataLogPath = Join-Path $BuildDirectory "bp045-049r2-protocol15-serverdata.log"
$ProtocolEventReportPath = Join-Path $BuildDirectory "bp045-049r2-protocol15-events.json"
$ProtocolEventLogPath = Join-Path $BuildDirectory "bp045-049r2-protocol15-events.log"
$ProtocolRuntimeEventReportPath = Join-Path $BuildDirectory "bp045-049r2-protocol15-runtime-events.json"
$ProtocolRuntimeEventLogPath = Join-Path $BuildDirectory "bp045-049r2-protocol15-runtime-events.log"
$ProtocolSignonReportPath = Join-Path $BuildDirectory "bp045-049r2-protocol15-signon.json"
$ProtocolSignonLogPath = Join-Path $BuildDirectory "bp045-049r2-protocol15-signon.log"
$ProtocolDeliveryReportPath = Join-Path $BuildDirectory "bp045-049r2-protocol15-delivery.json"
$ProtocolDeliveryLogPath = Join-Path $BuildDirectory "bp045-049r2-protocol15-delivery.log"
$ProtocolDatagramReportPath = Join-Path $BuildDirectory "bp045-049r2-protocol15-datagram.json"
$ProtocolDatagramLogPath = Join-Path $BuildDirectory "bp045-049r2-protocol15-datagram.log"
$ProtocolDemoReportPath = Join-Path $BuildDirectory "bp045-049r2-protocol15-demo.json"
$ProtocolDemoLogPath = Join-Path $BuildDirectory "bp045-049r2-protocol15-demo.log"
$ProtocolClosureReportPath = Join-Path $BuildDirectory "bp045-049r2-protocol15-closure.json"
$ProtocolClosureLogPath = Join-Path $BuildDirectory "bp045-049r2-protocol15-closure.log"
$QuakeCProgsReportPath = Join-Path $BuildDirectory "bp045-049r2-quakec-progs.json"
$QuakeCProgsLogPath = Join-Path $BuildDirectory "bp045-049r2-quakec-progs.log"
$QuakeCVMReportPath = Join-Path $BuildDirectory "bp045-049r2-quakec-vm.json"
$QuakeCVMLogPath = Join-Path $BuildDirectory "bp045-049r2-quakec-vm.log"
$QuakeCEdictReportPath = Join-Path $BuildDirectory "bp045-049r2-quakec-edict.json"
$QuakeCEdictLogPath = Join-Path $BuildDirectory "bp045-049r2-quakec-edict.log"
$QuakeCBuiltinReportPath = Join-Path $BuildDirectory "bp045-049r2-quakec-builtins.json"
$QuakeCBuiltinLogPath = Join-Path $BuildDirectory "bp045-049r2-quakec-builtins.log"
$QuakeCClosureReportPath = Join-Path $BuildDirectory "bp045-049r2-quakec-closure.json"
$QuakeCClosureLogPath = Join-Path $BuildDirectory "bp045-049r2-quakec-closure.log"
$WorldHullReportPath = Join-Path $BuildDirectory "bp045-049r2-world-hull.json"
$WorldHullLogPath = Join-Path $BuildDirectory "bp045-049r2-world-hull.log"
$WorldTraceReportPath = Join-Path $BuildDirectory "bp045-049r2-world-trace.json"
$WorldTraceLogPath = Join-Path $BuildDirectory "bp045-049r2-world-trace.log"
$WorldLinkReportPath = Join-Path $BuildDirectory "bp045-049r2-world-link.json"
$WorldLinkLogPath = Join-Path $BuildDirectory "bp045-049r2-world-link.log"
$ServerMoveReportPath = Join-Path $BuildDirectory "bp045-049r2-server-move.json"
$ServerMoveLogPath = Join-Path $BuildDirectory "bp045-049r2-server-move.log"
$ServerPhysicsReportPath = Join-Path $BuildDirectory "bp045-049r2-server-physics.json"
$ServerPhysicsLogPath = Join-Path $BuildDirectory "bp045-049r2-server-physics.log"
$SvUserMovementReportPath = Join-Path $BuildDirectory "bp045-049r2-sv-user-movement.json"
$SvUserMovementLogPath = Join-Path $BuildDirectory "bp045-049r2-sv-user-movement.log"
$ServerUserReportPath = Join-Path $BuildDirectory "bp045-049r2-server-user.json"
$ServerUserLogPath = Join-Path $BuildDirectory "bp045-049r2-server-user.log"
$WorldPhysicsClosureReportPath = Join-Path $BuildDirectory "bp045-049r2-world-physics-closure.json"
$WorldPhysicsClosureLogPath = Join-Path $BuildDirectory "bp045-049r2-world-physics-closure.log"
$HostTimingReportPath = Join-Path $BuildDirectory "bp045-049r2-host-timing.json"
$HostTimingLogPath = Join-Path $BuildDirectory "bp045-049r2-host-timing.log"
$CommandCvarReportPath = Join-Path $BuildDirectory "bp045-049r2-command-cvar.json"
$CommandCvarLogPath = Join-Path $BuildDirectory "bp045-049r2-command-cvar.log"
$DemoLifecycleReportPath = Join-Path $BuildDirectory "bp045-049r2-demo-lifecycle.json"
$DemoLifecycleLogPath = Join-Path $BuildDirectory "bp045-049r2-demo-lifecycle.log"
$SavegameV5ReportPath = Join-Path $BuildDirectory "bp045-049r2-savegame-v5.json"
$SavegameV5LogPath = Join-Path $BuildDirectory "bp045-049r2-savegame-v5.log"
$HostLifecycleClosureReportPath = Join-Path $BuildDirectory "bp045-049r2-host-lifecycle-closure.json"
$HostLifecycleClosureLogPath = Join-Path $BuildDirectory "bp045-049r2-host-lifecycle-closure.log"
$ClientStateRenderReportPath = Join-Path $BuildDirectory "bp045-049r2-client-state-render.json"
$ClientStateRenderLogPath = Join-Path $BuildDirectory "bp045-049r2-client-state-render.log"
$ViewStateReportPath = Join-Path $BuildDirectory "bp045-049r2-view-state.json"
$ViewStateLogPath = Join-Path $BuildDirectory "bp045-049r2-view-state.log"
$TemporaryBeamReportPath = Join-Path $BuildDirectory "bp045-049r2-temporary-beams.json"
$TemporaryBeamLogPath = Join-Path $BuildDirectory "bp045-049r2-temporary-beams.log"
$ParticleRuntimeReportPath = Join-Path $BuildDirectory "bp045-049r2-particle-runtime.json"
$ParticleRuntimeLogPath = Join-Path $BuildDirectory "bp045-049r2-particle-runtime.log"
$ClientRenderClosureReportPath = Join-Path $BuildDirectory "bp045-049r2-client-render-closure.json"
$ClientRenderClosureLogPath = Join-Path $BuildDirectory "bp045-049r2-client-render-closure.log"
$WorldSurfaceRenderReportPath = Join-Path $BuildDirectory "bp045-049r2-world-surfaces.json"
$WorldSurfaceRenderLogPath = Join-Path $BuildDirectory "bp045-049r2-world-surfaces.log"
$LightmapAtlasReportPath = Join-Path $BuildDirectory "bp045-049r2-lightmap-atlas.json"
$LightmapAtlasLogPath = Join-Path $BuildDirectory "bp045-049r2-lightmap-atlas.log"
$DynamicLightRenderReportPath = Join-Path $BuildDirectory "bp045-049r2-dynamic-lights.json"
$DynamicLightRenderLogPath = Join-Path $BuildDirectory "bp045-049r2-dynamic-lights.log"
$SkyWaterRenderReportPath = Join-Path $BuildDirectory "bp045-049r2-sky-water.json"
$SkyWaterRenderLogPath = Join-Path $BuildDirectory "bp045-049r2-sky-water.log"
$WorldRenderClosureReportPath = Join-Path $BuildDirectory "bp045-049r2-world-render-closure.json"
$WorldRenderClosureLogPath = Join-Path $BuildDirectory "bp045-049r2-world-render-closure.log"
$AliasModelReportPath = Join-Path $BuildDirectory "bp045-049r2-alias-model.json"
$AliasModelLogPath = Join-Path $BuildDirectory "bp045-049r2-alias-model.log"
$SpriteSyncReportPath = Join-Path $BuildDirectory "bp045-049r2-sprite-sync.json"
$SpriteSyncLogPath = Join-Path $BuildDirectory "bp045-049r2-sprite-sync.log"
$RenderUiHudReportPath = Join-Path $BuildDirectory "bp045-049r2-render-ui-hud.json"
$RenderUiHudLogPath = Join-Path $BuildDirectory "bp045-049r2-render-ui-hud.log"
$RenderEvidenceReportPath = Join-Path $BuildDirectory "bp045-049r2-render-evidence.json"
$RenderEvidenceLogPath = Join-Path $BuildDirectory "bp045-049r2-render-evidence.log"
$ModelUiRenderReportPath = Join-Path $BuildDirectory "bp045-049r2-model-ui-render.json"
$ModelUiRenderLogPath = Join-Path $BuildDirectory "bp045-049r2-model-ui-render.log"
$EvidenceDirectory = Join-Path $BuildDirectory "bp045-049r2-evidence"
$EvidenceALogPath = Join-Path $BuildDirectory "bp045-049r2-evidence-a.log"
$EvidenceBLogPath = Join-Path $BuildDirectory "bp045-049r2-evidence-b.log"
$EvidenceComparisonPath = Join-Path $BuildDirectory "bp045-049r2-evidence-comparison.json"
$EvidenceComparisonLogPath = Join-Path $BuildDirectory "bp045-049r2-evidence-comparison.log"
$QuakeCStockLogPath = Join-Path $BuildDirectory "bp045-049r2-quakec-stock-tests.log"
$GameValidationLogPath = Join-Path $BuildDirectory "bp045-049r2-game-validation.log"
$RuntimeValidationLogPath = Join-Path $BuildDirectory "bp045-049r2-runtime-validation.log"
$BisectReportPath = Join-Path $BuildDirectory "bp045-049r2-bisect-report.json"
$IndependentFailures = New-Object System.Collections.ArrayList
$Steps = New-Object System.Collections.ArrayList
$OverallStatus = "FAIL"
$FailureMessage = ""
$TranscriptStarted = $false
$TraceHash = ""
$TraceRollingHash = ""
$EvidenceHash = ""
$EvidencePixelHash = ""
$EvidenceSampleHash = ""
$EvidenceSsim = 0.0

New-Item -ItemType Directory -Force -Path $BuildDirectory | Out-Null

# A full acceptance run must exercise installed assets, deterministic traces and
# the real framebuffer capture. Asset-free runs remain possible only when all
# three corresponding gates are skipped explicitly.
$RequiresQuakeBase = (-not $SkipGameValidation) -or (-not $SkipTraceValidation) -or (-not $SkipRenderEvidence)
if ($RequiresQuakeBase) {
  if ([string]::IsNullOrWhiteSpace($QuakeBase)) {
    throw "A valid -QuakeBase is required for acceptance. Pass the directory containing id1\pak0.pak, or explicitly use -SkipGameValidation -SkipTraceValidation -SkipRenderEvidence for an asset-free diagnostic run."
  }
  if (-not (Test-Path -LiteralPath $QuakeBase -PathType Container)) {
    throw "Quake base directory does not exist: $QuakeBase"
  }
  $RequiredPak = Join-Path $QuakeBase "id1\pak0.pak"
  if (-not (Test-Path -LiteralPath $RequiredPak -PathType Leaf)) {
    throw "Quake base does not contain id1\pak0.pak: $QuakeBase"
  }
}

function Add-StepResult {
  param(
    [string]$Name,
    [string]$Status,
    [int]$ExitCode,
    [string]$Detail
  )

  [void]$Steps.Add([ordered]@{
    name = $Name
    status = $Status
    exit_code = $ExitCode
    detail = $Detail
  })
}

function Resolve-PythonCommand {
  if (-not [string]::IsNullOrWhiteSpace($Python)) {
    if (Test-Path -LiteralPath $Python -PathType Leaf) {
      $Resolved = [System.IO.Path]::GetFullPath($Python)
    } else {
      $Command = Get-Command $Python -ErrorAction SilentlyContinue | Select-Object -First 1
      if ($null -eq $Command) { throw "Python interpreter not found: $Python" }
      $Resolved = $Command.Path
    }
    if ([System.IO.Path]::GetFileNameWithoutExtension($Resolved) -ieq "py") {
      return [ordered]@{ executable = $Resolved; prefix = @("-3") }
    }
    return [ordered]@{ executable = $Resolved; prefix = @() }
  }

  $Launcher = Get-Command "py" -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($null -ne $Launcher) {
    return [ordered]@{ executable = $Launcher.Path; prefix = @("-3") }
  }

  $Command = Get-Command "python" -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($null -eq $Command) { throw "Python 3 was not found. Pass -Python PATH." }
  return [ordered]@{ executable = $Command.Path; prefix = @() }
}

function Invoke-ExternalStep {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Name,

    [Parameter(Mandatory = $true)]
    [string]$Executable,

    [Parameter(Mandatory = $true)]
    [string[]]$Arguments,

    [string]$Detail = "",
    [string]$LogPath = ""
  )

  Write-Host "[MiniQuake/$PackageId] $Name"
  if ([string]::IsNullOrWhiteSpace($LogPath)) {
    & $Executable @Arguments
  } else {
    if (Test-Path -LiteralPath $LogPath -PathType Leaf) { Remove-Item -Force -LiteralPath $LogPath }
    & $Executable @Arguments 2>&1 | Tee-Object -FilePath $LogPath
  }
  $ExitCode = [int]$LASTEXITCODE
  if ($ExitCode -ne 0) {
    $LogDetail = $Detail
    if (-not [string]::IsNullOrWhiteSpace($LogPath)) {
      $LogDetail = ($Detail + "; log=" + [System.IO.Path]::GetFileName($LogPath)).TrimStart([char[]]@(';', ' '))
    }
    Add-StepResult $Name "FAIL" $ExitCode $LogDetail
    throw "$Name failed with exit code $ExitCode."
  }
  Add-StepResult $Name "PASS" 0 $Detail
}

function Get-RuntimeTestFailureMarker {
  param([string]$Text)

  if ([string]::IsNullOrWhiteSpace($Text)) { return "" }
  $Patterns = @(
    '(?im)^\s*FAIL:\s+.*$',
    '(?im)^\s*MiniQuake\b.*\btests failed:\s*\d+/\d+\s*$',
    '(?im)^\s*BP-\d+.*\btests failed:\s*\d+/\d+\s*$'
  )
  foreach ($Pattern in $Patterns) {
    $Match = [regex]::Match($Text, $Pattern)
    if ($Match.Success) { return $Match.Value.Trim() }
  }
  return ""
}

function Invoke-IndependentTest {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Package,
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [Parameter(Mandatory = $true)]
    [string]$Executable,
    [Parameter(Mandatory = $true)]
    [string]$LogName,

    [string[]]$Arguments = @()
  )

  $LogPath = Join-Path $BuildDirectory $LogName
  Write-Host "[MiniQuake/$BlockId][$Package] $Name"
  if (Test-Path -LiteralPath $LogPath -PathType Leaf) { Remove-Item -Force -LiteralPath $LogPath }
  & $Executable @Arguments 2>&1 | Tee-Object -FilePath $LogPath
  $ExitCode = [int]$LASTEXITCODE
  $OutputText = ""
  if (Test-Path -LiteralPath $LogPath -PathType Leaf) {
    $OutputText = Get-Content -LiteralPath $LogPath -Raw
  }
  $FailureMarker = Get-RuntimeTestFailureMarker $OutputText
  $SyntheticFailure = $false
  if ($ExitCode -eq 0 -and -not [string]::IsNullOrWhiteSpace($FailureMarker)) {
    $ExitCode = 1
    $SyntheticFailure = $true
    Write-Host "ERROR: [$Package] $Name emitted a failure marker despite exit code 0: $FailureMarker" -ForegroundColor Red
  }
  if ($ExitCode -eq 0) {
    Add-StepResult ("[" + $Package + "] " + $Name) "PASS" 0 ("log=" + [System.IO.Path]::GetFileName($LogPath))
    return $true
  }

  [void]$IndependentFailures.Add([ordered]@{
    package = $Package
    name = $Name
    executable = [System.IO.Path]::GetFileName($Executable)
    exit_code = $ExitCode
    log = [System.IO.Path]::GetFileName($LogPath)
    failure_marker = $FailureMarker
    synthetic_failure = $SyntheticFailure
  })
  $FailureDetail = "log=" + [System.IO.Path]::GetFileName($LogPath)
  if (-not [string]::IsNullOrWhiteSpace($FailureMarker)) {
    $FailureDetail = $FailureDetail + "; marker=" + $FailureMarker
  }
  Add-StepResult ("[" + $Package + "] " + $Name) "FAIL" $ExitCode $FailureDetail
  Write-Host "ERROR: [$Package] $Name failed with exit code $ExitCode." -ForegroundColor Red
  if (-not $ContinueIndependentTests) { throw "[$Package] $Name failed with exit code $ExitCode." }
  return $false
}

function Require-File {
  param([string]$Path, [string]$Label)
  if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
    throw "$Label is missing: $Path"
  }
}

function Read-JsonFile {
  param([string]$Path)
  Require-File $Path "JSON artifact"
  return Get-Content -LiteralPath $Path -Raw -Encoding UTF8 | ConvertFrom-Json
}

try {
  try {
    Start-Transcript -LiteralPath $TranscriptPath -Force | Out-Null
    $TranscriptStarted = $true
  } catch {
    Write-Warning "PowerShell transcript could not be started: $($_.Exception.Message)"
  }

  Write-Host "MiniQuake $DeliveryRevision cumulative world/render acceptance test"
  Write-Host "  final package: $PackageId"
  Write-Host "  parent:        $ParentPackageId"
  Write-Host "  block parent:  $BlockParentPackageId"
  Write-Host "  root:          $Root"
  Write-Host "  configuration: $Configuration"

  $PythonCommand = Resolve-PythonCommand
  $PythonExe = $PythonCommand.executable
  $PythonPrefix = @($PythonCommand.prefix)

  Invoke-ExternalStep `
    -Name "static package and diagnostics verification" `
    -Executable $PythonExe `
    -Arguments @($PythonPrefix + @($Verifier, $Root, "--json-output", $StaticReportPath)) `
    -Detail "manifest, packages, ABI, accepted BP-029R3 parent, frozen Protocol 15/QuakeC/world-physics and cumulative BP-030-034 host/lifecycle contracts"

  Invoke-ExternalStep `
    -Name "trace comparator self-test" `
    -Executable $PythonExe `
    -Arguments @($PythonPrefix + @($TraceComparator, "--self-test")) `
    -Detail "field-level first-divergence reporter"

  Invoke-ExternalStep `
    -Name "runtime-test log checker self-test" `
    -Executable $PythonExe `
    -Arguments @($PythonPrefix + @($RuntimeTestLogChecker, "--self-test")) `
    -Detail "FAIL markers override an accidental zero process exit code"

  Invoke-ExternalStep `
    -Name "Protocol 15 C/Python golden-vector verification" `
    -Executable $PythonExe `
    -Arguments @($PythonPrefix + @($ProtocolVectorChecker, $Root, "--json-output", $ProtocolVectorReportPath)) `
    -Detail "13 inherited C-derived byte streams, 18 constants and MiniLang wire markers" `
    -LogPath $ProtocolVectorLogPath

  Invoke-ExternalStep `
    -Name "Protocol 15 signon, command-stream and fast-update verification" `
    -Executable $PythonExe `
    -Arguments @($PythonPrefix + @($ProtocolCommandChecker, $Root, "--json-output", $ProtocolCommandReportPath)) `
    -Detail "14 C-derived command/update byte streams, 57 constants and 34 SVC events" `
    -LogPath $ProtocolCommandLogPath

  Invoke-ExternalStep `
    -Name "Protocol 15 serverinfo, sound, clientdata, baseline and packet-planning verification" `
    -Executable $PythonExe `
    -Arguments @($PythonPrefix + @($ProtocolServerDataChecker, "--root", $Root, "--json-output", $ProtocolServerDataReportPath)) `
    -Detail "11 C-derived server payload vectors plus datagram, fast-update and client-delivery contracts" `
    -LogPath $ProtocolServerDataLogPath

  Invoke-ExternalStep `
    -Name "Protocol 15 static-event, particle, scoreboard and graceful-drop verification" `
    -Executable $PythonExe `
    -Arguments @($PythonPrefix + @($ProtocolEventChecker, "--root", $Root, "--json-output", $ProtocolEventReportPath)) `
    -Detail "15 C-derived event payload vectors, 13 semantic cases and 22 MiniLang runtime fixtures" `
    -LogPath $ProtocolEventLogPath

  Invoke-ExternalStep `
    -Name "Protocol 15 temporary-entity, dynamic-sound and delivery-boundary verification" `
    -Executable $PythonExe `
    -Arguments @($PythonPrefix + @($ProtocolRuntimeEventChecker, "--root", $Root, "--json-output", $ProtocolRuntimeEventReportPath)) `
    -Detail "10 C-derived runtime-event vectors, 49 semantic cases and 28 MiniLang runtime fixtures" `
    -LogPath $ProtocolRuntimeEventLogPath

  Invoke-ExternalStep `
    -Name "BP-015 signon queue and stage verification" `
    -Executable $PythonExe `
    -Arguments @($PythonPrefix + @($ProtocolSignonChecker, "--root", $Root, "--json-output", $ProtocolSignonReportPath)) `
    -Detail "source-guided signon stages 1-4 and queue boundaries" `
    -LogPath $ProtocolSignonLogPath

  Invoke-ExternalStep `
    -Name "BP-016 reliable delivery scheduling verification" `
    -Executable $PythonExe `
    -Arguments @($PythonPrefix + @($ProtocolDeliveryChecker, "--root", $Root, "--json-output", $ProtocolDeliveryReportPath)) `
    -Detail "blocked, retained, committed, keepalive and drop scheduling" `
    -LogPath $ProtocolDeliveryLogPath

  Invoke-ExternalStep `
    -Name "BP-017 datagram ACK and retransmission verification" `
    -Executable $PythonExe `
    -Arguments @($PythonPrefix + @($ProtocolDatagramChecker, "--root", $Root, "--json-output", $ProtocolDatagramReportPath)) `
    -Detail "fragmentation, deferred ACK flush, loss, duplicate and wrap cases" `
    -LogPath $ProtocolDatagramLogPath

  Invoke-ExternalStep `
    -Name "BP-018 demo framing and playback verification" `
    -Executable $PythonExe `
    -Arguments @($PythonPrefix + @($ProtocolDemoChecker, "--root", $Root, "--json-output", $ProtocolDemoReportPath)) `
    -Detail "recording atoi, frame ABI, keepalive filtering and timedemo semantics" `
    -LogPath $ProtocolDemoLogPath

  Invoke-ExternalStep `
    -Name "BP-019 cumulative Protocol 15 closure and freeze verification" `
    -Executable $PythonExe `
    -Arguments @($PythonPrefix + @($ProtocolClosureChecker, "--root", $Root, "--json-output", $ProtocolClosureReportPath)) `
    -Detail "nine component checkers, 15 authoritative files and frozen fingerprint" `
    -LogPath $ProtocolClosureLogPath

  Invoke-ExternalStep `
    -Name "BP-020 QuakeC progs.dat ABI and runtime CRC verification" `
    -Executable $PythonExe `
    -Arguments @($PythonPrefix + @($QuakeCProgsChecker, "--root", $Root, "--json-output", $QuakeCProgsReportPath)) `
    -Detail "dprograms_t ABI, semantic parser guards, Latin-1 string table and full-file CRC" `
    -LogPath $QuakeCProgsLogPath

  Invoke-ExternalStep `
    -Name "BP-021 QuakeC VM byte, stack and pointer verification" `
    -Executable $PythonExe `
    -Arguments @($PythonPrefix + @($QuakeCVMChecker, "--root", $Root, "--json-output", $QuakeCVMReportPath)) `
    -Detail "66 opcodes, Binary32 boundaries, stack/local limits and pointer validation" `
    -LogPath $QuakeCVMLogPath

  Invoke-ExternalStep `
    -Name "BP-022 QuakeC edict and save-text verification" `
    -Executable $PythonExe `
    -Arguments @($PythonPrefix + @($QuakeCEdictChecker, "--root", $Root, "--json-output", $QuakeCEdictReportPath)) `
    -Detail "Epair parsing, Latin-1 text, EV_VOID width and exact save formatting" `
    -LogPath $QuakeCEdictLogPath

  Invoke-ExternalStep `
    -Name "BP-023 QuakeC builtin-table and formatting verification" `
    -Executable $PythonExe `
    -Arguments @($PythonPrefix + @($QuakeCBuiltinChecker, "--root", $Root, "--json-output", $QuakeCBuiltinReportPath)) `
    -Detail "79 stock slots, 14 PF_Fixme entries, temp strings, random and numeric formatting" `
    -LogPath $QuakeCBuiltinLogPath

  Invoke-ExternalStep `
    -Name "BP-024 cumulative QuakeC closure and freeze verification" `
    -Executable $PythonExe `
    -Arguments @($PythonPrefix + @($QuakeCClosureChecker, "--root", $Root, "--allow-downstream-package", "--json-output", $QuakeCClosureReportPath)) `
    -Detail "stock QuakeC 1.09 contract, required globals/fields/functions and frozen fingerprint" `
    -LogPath $QuakeCClosureLogPath

  Invoke-ExternalStep `
    -Name "BP-025 box hull and recursive trace verification" `
    -Executable $PythonExe `
    -Arguments @($PythonPrefix + @($WorldHullChecker, $Root, "--json-output", $WorldHullReportPath)) `
    -Detail "six-node box hull, boundary classification and recursive trace parity" `
    -LogPath $WorldHullLogPath

  Invoke-ExternalStep `
    -Name "BP-025 world-space trace coordinate verification" `
    -Executable $PythonExe `
    -Arguments @($PythonPrefix + @($WorldTraceChecker, $Root, "--json-output", $WorldTraceReportPath)) `
    -Detail "translated brush traces, impact planes and exact clear endpoints" `
    -LogPath $WorldTraceLogPath

  Invoke-ExternalStep `
    -Name "BP-026 entity link and collision-filter verification" `
    -Executable $PythonExe `
    -Arguments @($PythonPrefix + @($WorldLinkChecker, $Root, "--json-output", $WorldLinkReportPath)) `
    -Detail "expanded absolute bounds, owner/point filters, trigger overlap and relinking" `
    -LogPath $WorldLinkLogPath

  Invoke-ExternalStep `
    -Name "BP-027 monster movement and relink verification" `
    -Executable $PythonExe `
    -Arguments @($PythonPrefix + @($ServerMoveChecker, $Root, "--json-output", $ServerMoveReportPath)) `
    -Detail "bottom checks, steps, partial ground, chase directions and MSVCRT random sequence" `
    -LogPath $ServerMoveLogPath

  Invoke-ExternalStep `
    -Name "BP-028 server physics verification" `
    -Executable $PythonExe `
    -Arguments @($PythonPrefix + @($ServerPhysicsChecker, $Root, "--json-output", $ServerPhysicsReportPath)) `
    -Detail "pushers, toss, gravity, relink order and strict WinQuake movetype dispatch" `
    -LogPath $ServerPhysicsLogPath

  Invoke-ExternalStep `
    -Name "BP-028 client movement and angle verification" `
    -Executable $PythonExe `
    -Arguments @($PythonPrefix + @($SvUserMovementChecker, $Root, "--json-output", $SvUserMovementReportPath)) `
    -Detail "frame clamp, acceleration, waterjump, ideal pitch and usercmd parsing" `
    -LogPath $SvUserMovementLogPath

  Invoke-ExternalStep `
    -Name "BP-029 server user and command-policy verification" `
    -Executable $PythonExe `
    -Arguments @($PythonPrefix + @($ServerUserChecker, $Root, "--json-output", $ServerUserReportPath)) `
    -Detail "client command privilege order, ping Binary32, movement gates and ideal pitch" `
    -LogPath $ServerUserLogPath

  Invoke-ExternalStep `
    -Name "BP-029 cumulative world/physics closure verification" `
    -Executable $PythonExe `
    -Arguments @($PythonPrefix + @($WorldPhysicsClosureChecker, $Root, "--json-output", $WorldPhysicsClosureReportPath)) `
    -Detail "seven component checkers and frozen world_physics_109_frozen_v1 fingerprint" `
    -LogPath $WorldPhysicsClosureLogPath

  Invoke-ExternalStep `
    -Name "BP-030 host timing and frame-clock verification" `
    -Executable $PythonExe `
    -Arguments @($PythonPrefix + @($HostTimingChecker, "--root", $Root, "--json-output", $HostTimingReportPath)) `
    -Detail "Host_FilterTime, realtime/oldrealtime, clamp and Binary32 boundaries" `
    -LogPath $HostTimingLogPath

  Invoke-ExternalStep `
    -Name "BP-031 command buffer, alias and cvar lifecycle verification" `
    -Executable $PythonExe `
    -Arguments @($PythonPrefix + @($CommandCvarChecker, "--root", $Root, "--json-output", $CommandCvarReportPath)) `
    -Detail "command ordering, aliases, Cvar_Command and Cvar_SetValue formatting" `
    -LogPath $CommandCvarLogPath

  Invoke-ExternalStep `
    -Name "BP-032 demo recording, playback and timedemo verification" `
    -Executable $PythonExe `
    -Arguments @($PythonPrefix + @($DemoLifecycleChecker, "--root", $Root, "--json-output", $DemoLifecycleReportPath)) `
    -Detail "demo frame ABI, track parsing, recording gates and Binary32 angles" `
    -LogPath $DemoLifecycleLogPath

  Invoke-ExternalStep `
    -Name "BP-033 savegame-v5 byte and parser verification" `
    -Executable $PythonExe `
    -Arguments @($PythonPrefix + @($SavegameV5Checker, "--root", $Root, "--json-output", $SavegameV5ReportPath)) `
    -Detail "version-5 layout, Quake one-byte text, comments, lightstyles and roundtrip" `
    -LogPath $SavegameV5LogPath

  Invoke-ExternalStep `
    -Name "BP-034 host lifecycle closure verification" `
    -Executable $PythonExe `
    -Arguments @($PythonPrefix + @($HostLifecycleClosureChecker, "--root", $Root, "--json-output", $HostLifecycleClosureReportPath)) `
    -Detail "map/changelevel/restart/disconnect/quit, shutdown and frozen lifecycle contract" `
    -LogPath $HostLifecycleClosureLogPath

  Invoke-ExternalStep `
    -Name "BP-035 client state and render-handoff verification" `
    -Executable $PythonExe `
    -Arguments @($PythonPrefix + @($ClientStateRenderChecker, "--root", $Root, "--json-output", $ClientStateRenderReportPath)) `
    -Detail "dlight pool, Binary32 interpolation, visible entity filtering and first-person handoff" `
    -LogPath $ClientStateRenderLogPath

  Invoke-ExternalStep `
    -Name "BP-036 view and chase-camera verification" `
    -Executable $PythonExe `
    -Arguments @($PythonPrefix + @($ViewStateChecker, "--root", $Root, "--json-output", $ViewStateReportPath)) `
    -Detail "cshift atoi semantics, view refdef and preserved chase yaw/roll" `
    -LogPath $ViewStateLogPath

  Invoke-ExternalStep `
    -Name "BP-037 temporary beam model verification" `
    -Executable $PythonExe `
    -Arguments @($PythonPrefix + @($TemporaryBeamChecker, "--root", $Root, "--json-output", $TemporaryBeamReportPath)) `
    -Detail "30-unit beam segments, Quake model mapping, random roll and temporary entity caps" `
    -LogPath $TemporaryBeamLogPath

  Invoke-ExternalStep `
    -Name "BP-038 particle runtime verification" `
    -Executable $PythonExe `
    -Arguments @($PythonPrefix + @($ParticleRuntimeChecker, "--root", $Root, "--json-output", $ParticleRuntimeReportPath)) `
    -Detail "sv_gravity handoff, Binary32 storage and particle-type integration" `
    -LogPath $ParticleRuntimeLogPath

  Invoke-ExternalStep `
    -Name "BP-039 cumulative client/render closure verification" `
    -Executable $PythonExe `
    -Arguments @($PythonPrefix + @($ClientRenderClosureChecker, "--root", $Root, "--json-output", $ClientRenderClosureReportPath)) `
    -Detail "efrag frame accumulation, renderer submission and client_render_109_frozen_v1" `
    -LogPath $ClientRenderClosureLogPath

  Invoke-ExternalStep `
    -Name "BP-040 world surface and texture-chain verification" `
    -Executable $PythonExe `
    -Arguments @($PythonPrefix + @($WorldSurfaceRenderChecker, "--root", $Root, "--json-output", $WorldSurfaceRenderReportPath)) `
    -Detail "world/brush culling, per-texture chains, sky classification and water deferral" `
    -LogPath $WorldSurfaceRenderLogPath

  Invoke-ExternalStep `
    -Name "BP-041 lightmap format and atlas verification" `
    -Executable $PythonExe `
    -Arguments @($PythonPrefix + @($LightmapAtlasChecker, "--root", $Root, "--json-output", $LightmapAtlasReportPath)) `
    -Detail "luminance/RGBA formats, row strides and shared atlas texture ownership" `
    -LogPath $LightmapAtlasLogPath

  Invoke-ExternalStep `
    -Name "BP-042 dynamic-light render verification" `
    -Executable $PythonExe `
    -Arguments @($PythonPrefix + @($DynamicLightRenderChecker, "--root", $Root, "--json-output", $DynamicLightRenderReportPath)) `
    -Detail "push-before-frame ordering, active-light boundaries and brush-model marking" `
    -LogPath $DynamicLightRenderLogPath

  Invoke-ExternalStep `
    -Name "BP-043 sky/water Binary32 verification" `
    -Executable $PythonExe `
    -Arguments @($PythonPrefix + @($SkyWaterRenderChecker, "--root", $Root, "--json-output", $SkyWaterRenderReportPath)) `
    -Detail "water warp, sky coordinates, speed wrapping and polygon subdivision" `
    -LogPath $SkyWaterRenderLogPath

  Invoke-ExternalStep `
    -Name "BP-044 cumulative world/render closure verification" `
    -Executable $PythonExe `
    -Arguments @($PythonPrefix + @($WorldRenderClosureChecker, "--root", $Root, "--json-output", $WorldRenderClosureReportPath)) `
    -Detail "viewport fudge, front-face culling, pass order and world_render_109_frozen_v1" `
    -LogPath $WorldRenderClosureLogPath


  foreach ($CurrentChecker in @(
    [ordered]@{ Name = "BP-045 alias model verification"; Path = $AliasModelChecker; Log = $AliasModelLogPath },
    [ordered]@{ Name = "BP-046 sprite synchronization verification"; Path = $SpriteSyncChecker; Log = $SpriteSyncLogPath },
    [ordered]@{ Name = "BP-047 2D/HUD integration verification"; Path = $RenderUiHudChecker; Log = $RenderUiHudLogPath },
    [ordered]@{ Name = "BP-048 render evidence verification"; Path = $RenderEvidenceChecker; Log = $RenderEvidenceLogPath },
    [ordered]@{ Name = "BP-049 model/UI/render closure verification"; Path = $ModelUiRenderChecker; Log = $ModelUiRenderLogPath }
  )) {
    Invoke-ExternalStep -Name $CurrentChecker.Name -Executable $PythonExe -Arguments @($PythonPrefix + @($CurrentChecker.Path)) -Detail "source-guided component contract" -LogPath $CurrentChecker.Log
  }
  Invoke-ExternalStep -Name "render evidence comparator self-test" -Executable $PythonExe -Arguments @($PythonPrefix + @($RenderEvidenceComparator, "--self-test")) -Detail "TGA parser, exact comparison and SSIM" -LogPath (Join-Path $BuildDirectory "bp045-049r2-evidence-comparator-selftest.log")

  if (-not $SkipBuild) {
    $BuildArguments = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $BuildScript)
    if (-not [string]::IsNullOrWhiteSpace($Compiler)) { $BuildArguments += @("-Compiler", $Compiler) }
    if (-not [string]::IsNullOrWhiteSpace($StdLib)) { $BuildArguments += @("-StdLib", $StdLib) }
    $BuildArguments += @("-Python", $PythonExe, "-Configuration", $Configuration, "-NoRunTests")
    if ($RebuildNative) { $BuildArguments += "-RebuildNative" }
    if ($Listings) { $BuildArguments += "-Listings" }

    $PowerShellExe = (Get-Process -Id $PID).Path
    Invoke-ExternalStep `
      -Name "single cumulative build of game and all block test executables" `
      -Executable $PowerShellExe `
      -Arguments $BuildArguments `
      -Detail "compile once with -NoRunTests; independent groups execute below" `
      -LogPath $BuildChildLogPath
  } else {
    Add-StepResult "single cumulative build of game and all block test executables" "SKIPPED" 0 "-SkipBuild"
  }

  Require-File $GameExe "MiniQuake executable"
  Require-File (Join-Path $BuildDirectory "MiniQuakeProtocol15WireTests.exe") "Protocol 15 wire test executable"
  Require-File (Join-Path $BuildDirectory "MiniQuakeProtocol15CommandTests.exe") "Protocol 15 command test executable"
  Require-File (Join-Path $BuildDirectory "MiniQuakeProtocol15ServerDataTests.exe") "Protocol 15 server-data test executable"
  Require-File (Join-Path $BuildDirectory "MiniQuakeProtocol15EventTests.exe") "Protocol 15 event test executable"
  Require-File (Join-Path $BuildDirectory "MiniQuakeProtocol15RuntimeEventTests.exe") "Protocol 15 runtime-event test executable"
  Require-File (Join-Path $BuildDirectory "MiniQuakeProtocol15SignonTests.exe") "Protocol 15 signon test executable"
  Require-File (Join-Path $BuildDirectory "MiniQuakeProtocol15DeliveryTests.exe") "Protocol 15 delivery test executable"
  Require-File (Join-Path $BuildDirectory "MiniQuakeProtocol15DatagramTests.exe") "Protocol 15 datagram test executable"
  Require-File (Join-Path $BuildDirectory "MiniQuakeProtocol15DemoTests.exe") "Protocol 15 demo test executable"
  Require-File (Join-Path $BuildDirectory "MiniQuakeProtocol15ClosureTests.exe") "Protocol 15 closure test executable"
  Require-File (Join-Path $BuildDirectory "MiniQuakeQuakeCProgsTests.exe") "BP-020 QuakeC progs.dat test executable"
  Require-File (Join-Path $BuildDirectory "MiniQuakeQuakeCVMTests.exe") "BP-021 QuakeC VM test executable"
  Require-File (Join-Path $BuildDirectory "MiniQuakeQuakeCEdictTests.exe") "BP-022 QuakeC edict test executable"
  Require-File (Join-Path $BuildDirectory "MiniQuakeQuakeCBuiltinTests.exe") "BP-023 QuakeC builtin test executable"
  Require-File (Join-Path $BuildDirectory "MiniQuakeQuakeCClosureTests.exe") "BP-024 QuakeC closure test executable"
  Require-File (Join-Path $BuildDirectory "MiniQuakeQuakeCStockTests.exe") "BP-024 stock progs.dat test executable"
  Require-File (Join-Path $BuildDirectory "MiniQuakeWorldHullTests.exe") "BP-025 world hull test executable"
  Require-File (Join-Path $BuildDirectory "MiniQuakeWorldTraceTests.exe") "BP-025 world trace test executable"
  Require-File (Join-Path $BuildDirectory "MiniQuakeWorldLinkTests.exe") "BP-026 world link test executable"
  Require-File (Join-Path $BuildDirectory "MiniQuakeServerMoveTests.exe") "BP-027 server movement test executable"
  Require-File (Join-Path $BuildDirectory "MiniQuakeServerPhysicsTests.exe") "BP-028 server physics test executable"
  Require-File (Join-Path $BuildDirectory "MiniQuakeSvUserMovementTests.exe") "BP-028 sv_user movement test executable"
  Require-File (Join-Path $BuildDirectory "MiniQuakeServerUserTests.exe") "BP-029 server user test executable"
  Require-File (Join-Path $BuildDirectory "MiniQuakeWorldPhysicsClosureTests.exe") "BP-029 world/physics closure test executable"
  Require-File (Join-Path $BuildDirectory "MiniQuakeHostTimingTests.exe") "BP-030 host timing test executable"
  Require-File (Join-Path $BuildDirectory "MiniQuakeCommandCvarTests.exe") "BP-031 command/cvar test executable"
  Require-File (Join-Path $BuildDirectory "MiniQuakeDemoLifecycleTests.exe") "BP-032 demo lifecycle test executable"
  Require-File (Join-Path $BuildDirectory "MiniQuakeSavegameV5Tests.exe") "BP-033 savegame v5 test executable"
  Require-File (Join-Path $BuildDirectory "MiniQuakeHostLifecycleClosureTests.exe") "BP-034 host lifecycle closure test executable"
  Require-File (Join-Path $BuildDirectory "MiniQuakeClientStateRenderTests.exe") "BP-035 client state/render test executable"
  Require-File (Join-Path $BuildDirectory "MiniQuakeViewStateTests.exe") "BP-036 view state test executable"
  Require-File (Join-Path $BuildDirectory "MiniQuakeTemporaryBeamTests.exe") "BP-037 temporary beam test executable"
  Require-File (Join-Path $BuildDirectory "MiniQuakeParticleRuntimeTests.exe") "BP-038 particle runtime test executable"
  Require-File (Join-Path $BuildDirectory "MiniQuakeClientRenderClosureTests.exe") "BP-039 client/render closure test executable"
  Require-File (Join-Path $BuildDirectory "MiniQuakeWorldSurfaceRenderTests.exe") "BP-040 world surface test executable"
  Require-File (Join-Path $BuildDirectory "MiniQuakeLightmapAtlasTests.exe") "BP-041 lightmap atlas test executable"
  Require-File (Join-Path $BuildDirectory "MiniQuakeDynamicLightRenderTests.exe") "BP-042 dynamic-light render test executable"
  Require-File (Join-Path $BuildDirectory "MiniQuakeSkyWaterRenderTests.exe") "BP-043 sky/water render test executable"
  Require-File (Join-Path $BuildDirectory "MiniQuakeWorldRenderClosureTests.exe") "BP-044 world/render closure test executable"
  Require-File (Join-Path $BuildDirectory "MiniQuakeAliasModelTests.exe") "BP-045 alias model test executable"
  Require-File (Join-Path $BuildDirectory "MiniQuakeSpriteSyncTests.exe") "BP-046 sprite sync test executable"
  Require-File (Join-Path $BuildDirectory "MiniQuakeRenderUiHudTests.exe") "BP-047 2D/HUD test executable"
  Require-File (Join-Path $BuildDirectory "MiniQuakeRenderEvidenceTests.exe") "BP-048 render evidence test executable"
  Require-File (Join-Path $BuildDirectory "MiniQuakeModelUiRenderClosureTests.exe") "BP-049 closure test executable"

  foreach ($BridgeName in @("miniquake_native.dll", "miniquake_text.dll")) {
    $SourceBridge = Join-Path (Join-Path $Root "native") $BridgeName
    $BuiltBridge = Join-Path $BuildDirectory $BridgeName
    Require-File $SourceBridge "Packaged native bridge"
    Require-File $BuiltBridge "Built native bridge"
    $SourceHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $SourceBridge).Hash
    $BuiltHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $BuiltBridge).Hash
    if ($SourceHash -ne $BuiltHash) { throw "Built native bridge hash mismatch: $BridgeName" }
  }
  Add-StepResult "native bridge deployment" "PASS" 0 "main and buffered-text DLL hashes match package"

  Write-Host "[MiniQuake/$PackageId] executable identity"
  $VersionOutput = @(& $GameExe "--version" 2>&1)
  $VersionExitCode = [int]$LASTEXITCODE
  $VersionOutput | Set-Content -LiteralPath $VersionPath -Encoding UTF8
  $VersionOutput | ForEach-Object { Write-Host $_ }
  if ($VersionExitCode -ne 0) { throw "MiniQuake --version failed with exit code $VersionExitCode." }
  $VersionText = $VersionOutput -join "`n"
  foreach ($Marker in @(
    "Package: $PackageId",
    "Parent package: $ParentPackageId",
    "Compatibility profile: compat_109",
    "Native text ABI: $NativeTextAbi",
    "Protocol text ABI: $ProtocolTextAbi",
    "Block: $BlockId",
    "Block parent package: $BlockParentPackageId",
    "Protocol status: $ProtocolStatus",
    "QuakeC status: $QuakeCStatus",
    "World/physics status: $WorldPhysicsStatus",
    "Host/lifecycle status: $HostLifecycleStatus",
    "Client/render status: $ClientRenderStatus",
    "World/render status: $WorldRenderStatus",
    "Model/UI/render status: $ModelUiRenderStatus",
    "Model/UI/render fingerprint: 0x0a62f5b1"
  )) {
    if ($VersionText -notmatch [regex]::Escape($Marker)) { throw "Executable identity marker missing: $Marker" }
  }
  Add-StepResult "executable identity" "PASS" 0 "Package: $PackageId; block: $BlockId; model/UI/render: $ModelUiRenderStatus"

  $IndependentGroups = @(
    [ordered]@{ package = "BASE"; name = "core tests"; exe = "MiniQuakeTests.exe"; log = "bp045-049r2-core-tests.log" },
    [ordered]@{ package = "BASE"; name = "milestone tests"; exe = "MiniQuakeMilestoneTests.exe"; log = "bp045-049r2-milestone-tests.log" },
    [ordered]@{ package = "BASE"; name = "deterministic diagnostics"; exe = "MiniQuakeCompatTraceTests.exe"; log = "bp045-049r2-diagnostics-tests.log" },
    [ordered]@{ package = "BP-010R1"; name = "Protocol 15 wire"; exe = "MiniQuakeProtocol15WireTests.exe"; log = "bp045-049r2-wire-tests.log" },
    [ordered]@{ package = "BP-011"; name = "Protocol 15 command/update"; exe = "MiniQuakeProtocol15CommandTests.exe"; log = "bp045-049r2-command-tests.log" },
    [ordered]@{ package = "BP-012R1"; name = "Protocol 15 server data"; exe = "MiniQuakeProtocol15ServerDataTests.exe"; log = "bp045-049r2-serverdata-tests.log" },
    [ordered]@{ package = "BP-013"; name = "Protocol 15 events"; exe = "MiniQuakeProtocol15EventTests.exe"; log = "bp045-049r2-event-tests.log" },
    [ordered]@{ package = "BP-014R1"; name = "Protocol 15 runtime events"; exe = "MiniQuakeProtocol15RuntimeEventTests.exe"; log = "bp045-049r2-runtime-event-tests.log" },
    [ordered]@{ package = "BP-015"; name = "signon queue and stages"; exe = "MiniQuakeProtocol15SignonTests.exe"; log = "bp045-049r2-signon-tests.log" },
    [ordered]@{ package = "BP-016"; name = "reliable delivery scheduling"; exe = "MiniQuakeProtocol15DeliveryTests.exe"; log = "bp045-049r2-delivery-tests.log" },
    [ordered]@{ package = "BP-017"; name = "datagram ACK and retransmission"; exe = "MiniQuakeProtocol15DatagramTests.exe"; log = "bp045-049r2-datagram-tests.log" },
    [ordered]@{ package = "BP-018"; name = "demo framing and playback"; exe = "MiniQuakeProtocol15DemoTests.exe"; log = "bp045-049r2-demo-tests.log" },
    [ordered]@{ package = "BP-019"; name = "cross-layer Protocol 15 closure and freeze"; exe = "MiniQuakeProtocol15ClosureTests.exe"; log = "bp045-049r2-protocol15-closure-tests.log" },
    [ordered]@{ package = "BP-020"; name = "QuakeC progs.dat ABI and CRC"; exe = "MiniQuakeQuakeCProgsTests.exe"; log = "bp045-049r2-quakec-progs-tests.log" },
    [ordered]@{ package = "BP-021"; name = "QuakeC VM byte and stack parity"; exe = "MiniQuakeQuakeCVMTests.exe"; log = "bp045-049r2-quakec-vm-tests.log" },
    [ordered]@{ package = "BP-022"; name = "QuakeC edict and save-text parity"; exe = "MiniQuakeQuakeCEdictTests.exe"; log = "bp045-049r2-quakec-edict-tests.log" },
    [ordered]@{ package = "BP-023"; name = "QuakeC builtin table and formatting"; exe = "MiniQuakeQuakeCBuiltinTests.exe"; log = "bp045-049r2-quakec-builtin-tests.log" },
    [ordered]@{ package = "BP-024"; name = "frozen QuakeC contract closure"; exe = "MiniQuakeQuakeCClosureTests.exe"; log = "bp045-049r2-quakec-closure-tests.log" },
    [ordered]@{ package = "BP-025"; name = "world hull parity"; exe = "MiniQuakeWorldHullTests.exe"; log = "bp045-049r2-world-hull-tests.log" },
    [ordered]@{ package = "BP-025"; name = "world trace parity"; exe = "MiniQuakeWorldTraceTests.exe"; log = "bp045-049r2-world-trace-tests.log" },
    [ordered]@{ package = "BP-026"; name = "world link and collision parity"; exe = "MiniQuakeWorldLinkTests.exe"; log = "bp045-049r2-world-link-tests.log" },
    [ordered]@{ package = "BP-027"; name = "monster movement parity"; exe = "MiniQuakeServerMoveTests.exe"; log = "bp045-049r2-server-move-tests.log" },
    [ordered]@{ package = "BP-028"; name = "server physics parity"; exe = "MiniQuakeServerPhysicsTests.exe"; log = "bp045-049r2-server-physics-tests.log" },
    [ordered]@{ package = "BP-028"; name = "sv_user movement parity"; exe = "MiniQuakeSvUserMovementTests.exe"; log = "bp045-049r2-sv-user-movement-tests.log" },
    [ordered]@{ package = "BP-029"; name = "server user parity"; exe = "MiniQuakeServerUserTests.exe"; log = "bp045-049r2-server-user-tests.log" },
    [ordered]@{ package = "BP-029"; name = "frozen world and physics closure"; exe = "MiniQuakeWorldPhysicsClosureTests.exe"; log = "bp045-049r2-world-physics-closure-tests.log" },
    [ordered]@{ package = "BP-030"; name = "host timing and frame clock"; exe = "MiniQuakeHostTimingTests.exe"; log = "bp045-049r2-host-timing-tests.log" },
    [ordered]@{ package = "BP-031"; name = "command buffer and cvar lifecycle"; exe = "MiniQuakeCommandCvarTests.exe"; log = "bp045-049r2-command-cvar-tests.log" },
    [ordered]@{ package = "BP-032"; name = "demo lifecycle"; exe = "MiniQuakeDemoLifecycleTests.exe"; log = "bp045-049r2-demo-lifecycle-tests.log" },
    [ordered]@{ package = "BP-033"; name = "savegame v5"; exe = "MiniQuakeSavegameV5Tests.exe"; log = "bp045-049r2-savegame-v5-tests.log" },
    [ordered]@{ package = "BP-034"; name = "host lifecycle closure"; exe = "MiniQuakeHostLifecycleClosureTests.exe"; log = "bp045-049r2-host-lifecycle-closure-tests.log" },
    [ordered]@{ package = "BP-035"; name = "client state and render handoff"; exe = "MiniQuakeClientStateRenderTests.exe"; log = "bp045-049r2-client-state-render-tests.log" },
    [ordered]@{ package = "BP-036"; name = "view state and chase camera"; exe = "MiniQuakeViewStateTests.exe"; log = "bp045-049r2-view-state-tests.log" },
    [ordered]@{ package = "BP-037"; name = "temporary beam model entities"; exe = "MiniQuakeTemporaryBeamTests.exe"; log = "bp045-049r2-temporary-beam-tests.log" },
    [ordered]@{ package = "BP-038"; name = "particle runtime parity"; exe = "MiniQuakeParticleRuntimeTests.exe"; log = "bp045-049r2-particle-runtime-tests.log" },
    [ordered]@{ package = "BP-039"; name = "frozen client/render closure"; exe = "MiniQuakeClientRenderClosureTests.exe"; log = "bp045-049r2-client-render-closure-tests.log" },
    [ordered]@{ package = "BP-040"; name = "world surfaces and texture chains"; exe = "MiniQuakeWorldSurfaceRenderTests.exe"; log = "bp045-049r2-world-surface-tests.log" },
    [ordered]@{ package = "BP-041"; name = "lightmap formats and atlas ownership"; exe = "MiniQuakeLightmapAtlasTests.exe"; log = "bp045-049r2-lightmap-atlas-tests.log" },
    [ordered]@{ package = "BP-042"; name = "dynamic-light frame and brush marking"; exe = "MiniQuakeDynamicLightRenderTests.exe"; log = "bp045-049r2-dynamic-light-render-tests.log" },
    [ordered]@{ package = "BP-043"; name = "sky and water Binary32 rendering"; exe = "MiniQuakeSkyWaterRenderTests.exe"; log = "bp045-049r2-sky-water-render-tests.log" },
    [ordered]@{ package = "BP-044"; name = "frozen world/render closure"; exe = "MiniQuakeWorldRenderClosureTests.exe"; log = "bp045-049r2-world-render-closure-tests.log" },
    [ordered]@{ package = "BP-045"; name = "alias model and shadow parity"; exe = "MiniQuakeAliasModelTests.exe"; log = "bp045-049r2-alias-model-tests.log" },
    [ordered]@{ package = "BP-046"; name = "sprite synchronization parity"; exe = "MiniQuakeSpriteSyncTests.exe"; log = "bp045-049r2-sprite-sync-tests.log" },
    [ordered]@{ package = "BP-047"; name = "2D and HUD integration parity"; exe = "MiniQuakeRenderUiHudTests.exe"; log = "bp045-049r2-render-ui-hud-tests.log" },
    [ordered]@{ package = "BP-048"; name = "deterministic render evidence"; exe = "MiniQuakeRenderEvidenceTests.exe"; log = "bp045-049r2-render-evidence-tests.log" },
    [ordered]@{ package = "BP-049"; name = "frozen model/UI/render closure"; exe = "MiniQuakeModelUiRenderClosureTests.exe"; log = "bp045-049r2-model-ui-render-closure-tests.log" }
  )
  foreach ($Group in $IndependentGroups) {
    $Path = Join-Path $BuildDirectory $Group.exe
    Require-File $Path ("test executable for " + $Group.package)
    [void](Invoke-IndependentTest -Package $Group.package -Name $Group.name -Executable $Path -LogName $Group.log)
  }

  $CanUseGameData = -not $SkipGameValidation -and -not [string]::IsNullOrWhiteSpace($QuakeBase)
  if (-not $CanUseGameData) {
    $Reason = if ($SkipGameValidation) { "-SkipGameValidation" } else { "no -QuakeBase supplied" }
    Add-StepResult "[BP-024R3] stock progs.dat compatibility gate" "SKIPPED" 0 $Reason
    Add-StepResult "[BP-029] installed Quake data validation" "SKIPPED" 0 $Reason
    Add-StepResult "[BP-029] headless runtime validation" "SKIPPED" 0 $Reason
  } else {
    if (-not (Test-Path -LiteralPath $QuakeBase -PathType Container)) {
      throw "Quake base directory does not exist: $QuakeBase"
    }

    # Run the focused stock progs.dat gate first. All three user-data gates
    # are independent and retain complete native stdout/stderr logs even when
    # one of them fails.
    $StockExe = Join-Path $BuildDirectory "MiniQuakeQuakeCStockTests.exe"
    [void](Invoke-IndependentTest -Package "BP-024R3" -Name "stock progs.dat compatibility gate" -Executable $StockExe -LogName ([System.IO.Path]::GetFileName($QuakeCStockLogPath)) -Arguments @($QuakeBase, $Game))
    [void](Invoke-IndependentTest -Package "BP-029" -Name "installed Quake data validation" -Executable $GameExe -LogName ([System.IO.Path]::GetFileName($GameValidationLogPath)) -Arguments @("--validate-game", $QuakeBase, $Map, "-game", $Game))
    [void](Invoke-IndependentTest -Package "BP-029" -Name "headless runtime validation" -Executable $GameExe -LogName ([System.IO.Path]::GetFileName($RuntimeValidationLogPath)) -Arguments @("--validate-runtime", $QuakeBase, $Map, [string]$Frames, "-game", $Game))
  }

  $CanTrace = -not $SkipTraceValidation -and -not [string]::IsNullOrWhiteSpace($QuakeBase)
  if (-not $CanTrace) {
    $Reason = if ($SkipTraceValidation) { "-SkipTraceValidation" } else { "no -QuakeBase supplied" }
    Add-StepResult "deterministic compatibility trace A" "SKIPPED" 0 $Reason
    Add-StepResult "deterministic compatibility trace B" "SKIPPED" 0 $Reason
    Add-StepResult "byte-identical trace comparison" "SKIPPED" 0 $Reason
    Add-StepResult "trace artifact schema validation" "SKIPPED" 0 $Reason
    Add-StepResult "compatibility snapshot command" "SKIPPED" 0 $Reason
  } else {
    if (Test-Path -LiteralPath $TraceDirectory) { Remove-Item -Recurse -Force -LiteralPath $TraceDirectory }
    New-Item -ItemType Directory -Force -Path $TraceDirectory | Out-Null
    $PrefixA = Join-Path $TraceDirectory "run-a"
    $PrefixB = Join-Path $TraceDirectory "run-b"

    Invoke-ExternalStep `
      -Name "deterministic compatibility trace A" `
      -Executable $GameExe `
      -Arguments @("--compat-trace", $QuakeBase, $Map, [string]$TraceFrames, $PrefixA, "-game", $Game) `
      -Detail "fixed 0.02 second steps; game=$Game map=$Map frames=$TraceFrames" `
      -LogPath $TraceALogPath
    Invoke-ExternalStep `
      -Name "deterministic compatibility trace B" `
      -Executable $GameExe `
      -Arguments @("--compat-trace", $QuakeBase, $Map, [string]$TraceFrames, $PrefixB, "-game", $Game) `
      -Detail "independent second process with identical arguments" `
      -LogPath $TraceBLogPath

    $TraceA = $PrefixA + ".mqtrace"
    $TraceB = $PrefixB + ".mqtrace"
    $SnapshotA = $PrefixA + "-snapshot.json"
    $ContextA = $PrefixA + "-context.json"
    $SummaryAPath = $PrefixA + "-summary.json"
    $SummaryBPath = $PrefixB + "-summary.json"
    foreach ($Artifact in @($TraceA, $TraceB, $SnapshotA, $ContextA, $SummaryAPath, $SummaryBPath)) {
      Require-File $Artifact "BP-029 trace artifact"
    }

    Write-Host "[MiniQuake/$PackageId] byte-identical trace comparison"
    if (Test-Path -LiteralPath $TraceComparisonPath -PathType Leaf) { Remove-Item -Force -LiteralPath $TraceComparisonPath }
    if (Test-Path -LiteralPath $TraceComparisonLogPath -PathType Leaf) { Remove-Item -Force -LiteralPath $TraceComparisonLogPath }
    $ComparisonArguments = @($PythonPrefix + @($TraceComparator, $TraceA, $TraceB, "--json-output", $TraceComparisonPath))
    & $PythonExe @ComparisonArguments 2>&1 | Tee-Object -FilePath $TraceComparisonLogPath
    $ComparisonExitCode = [int]$LASTEXITCODE
    $Comparison = Read-JsonFile $TraceComparisonPath
    if ($ComparisonExitCode -ne 0 -or -not [bool]$Comparison.equal) {
      $Detail = "run-a=$($Comparison.left.sha256) run-b=$($Comparison.right.sha256)"
      if ($null -ne $Comparison.first_difference) {
        $Detail = $Detail + " first_line=$($Comparison.first_difference.line_index)"
        if ($null -ne $Comparison.first_difference.frame) {
          $Detail = $Detail + " first_frame=$($Comparison.first_difference.frame)"
        }
      }
      $Detail = $Detail + "; report=" + [System.IO.Path]::GetFileName($TraceComparisonPath)
      Add-StepResult "byte-identical trace comparison" "FAIL" $ComparisonExitCode $Detail
      throw "BP-029 deterministic traces differ. The first differing fields are recorded in $TraceComparisonPath."
    }
    $TraceHash = [string]$Comparison.left.sha256
    $LineCount = [int]$Comparison.left.lines
    if ($LineCount -ne ($TraceFrames + 1)) {
      throw "Trace line count is $LineCount, expected $($TraceFrames + 1)."
    }
    Add-StepResult "byte-identical trace comparison" "PASS" 0 "sha256=$TraceHash lines=$LineCount report=$([System.IO.Path]::GetFileName($TraceComparisonPath))"

    $SummaryA = Read-JsonFile $SummaryAPath
    $SummaryB = Read-JsonFile $SummaryBPath
    $Snapshot = Read-JsonFile $SnapshotA
    $Context = Read-JsonFile $ContextA
    if ($SummaryA.schema -ne "MiniQuakeTraceSummary/1" -or $SummaryB.schema -ne "MiniQuakeTraceSummary/1") {
      throw "Unexpected trace summary schema."
    }
    if ($SummaryA.package -ne $PackageId -or $SummaryB.package -ne $PackageId) {
      throw "Trace summary package marker mismatch."
    }
    if (-not $SummaryA.ok -or -not $SummaryB.ok) { throw "A trace summary reports failure." }
    if ([int]$SummaryA.frames_written -ne $TraceFrames -or [int]$SummaryB.frames_written -ne $TraceFrames) {
      throw "Trace summary frame count mismatch."
    }
    if ($SummaryA.rolling_hash -ne $SummaryB.rolling_hash) {
      throw "Trace rolling hashes differ despite byte comparison."
    }
    if ($Snapshot.schema -ne "MiniQuakeSnapshot/1") { throw "Unexpected snapshot schema." }
    if ($Context.schema -ne "MiniQuakeCrashContext/1") { throw "Unexpected crash-context schema." }
    if ($Context.phase -ne "trace_complete") { throw "Final crash context phase is '$($Context.phase)', expected trace_complete." }
    $TraceRollingHash = [string]$SummaryA.rolling_hash

    foreach ($Artifact in @($TraceA, $SnapshotA, $ContextA, $SummaryAPath)) {
      Invoke-ExternalStep `
        -Name ("compatibility report " + [System.IO.Path]::GetFileName($Artifact)) `
        -Executable $GameExe `
        -Arguments @("--compat-report", $Artifact) `
        -Detail "schema recognition"
    }
    Add-StepResult "trace artifact schema validation" "PASS" 0 "rolling_hash=$TraceRollingHash"

    $SnapshotFrames = [int][Math]::Min($TraceFrames, 8)
    $SnapshotPrefix = Join-Path $TraceDirectory "snapshot-command"
    Invoke-ExternalStep `
      -Name "compatibility snapshot command" `
      -Executable $GameExe `
      -Arguments @("--compat-snapshot", $QuakeBase, $Map, [string]$SnapshotFrames, $SnapshotPrefix, "-game", $Game) `
      -Detail "direct --compat-snapshot CLI path; frames=$SnapshotFrames" `
      -LogPath $SnapshotCommandLogPath
    $SnapshotCommandPath = $SnapshotPrefix + "-snapshot.json"
    $SnapshotCommandSummaryPath = $SnapshotPrefix + "-summary.json"
    $SnapshotCommand = Read-JsonFile $SnapshotCommandPath
    $SnapshotCommandSummary = Read-JsonFile $SnapshotCommandSummaryPath
    if ($SnapshotCommand.schema -ne "MiniQuakeSnapshot/1") { throw "Direct snapshot command produced an unexpected schema." }
    if ([int]$SnapshotCommand.frame -ne ($SnapshotFrames - 1)) { throw "Direct snapshot command stopped at frame $($SnapshotCommand.frame), expected $($SnapshotFrames - 1)." }
    if (-not $SnapshotCommandSummary.ok -or [int]$SnapshotCommandSummary.frames_written -ne $SnapshotFrames) {
      throw "Direct snapshot command summary reports failure or the wrong frame count."
    }
  }

  $CanRenderEvidence = -not $SkipRenderEvidence -and $CanUseGameData
  if (-not $CanRenderEvidence) {
    $Reason = if ($SkipRenderEvidence) { "-SkipRenderEvidence" } else { "no usable -QuakeBase supplied" }
    Add-StepResult "deterministic render evidence A" "SKIPPED" 0 $Reason
    Add-StepResult "deterministic render evidence B" "SKIPPED" 0 $Reason
    Add-StepResult "byte-identical render evidence comparison" "SKIPPED" 0 $Reason
  } else {
    if (Test-Path -LiteralPath $EvidenceDirectory) { Remove-Item -Recurse -Force -LiteralPath $EvidenceDirectory }
    New-Item -ItemType Directory -Force -Path $EvidenceDirectory | Out-Null
    $EvidenceAPrefix = Join-Path $EvidenceDirectory "run-a"
    $EvidenceBPrefix = Join-Path $EvidenceDirectory "run-b"
    Invoke-ExternalStep -Name "deterministic render evidence A" -Executable $GameExe -Arguments @("--render-evidence", $QuakeBase, $Map, [string]$RenderEvidenceFrame, $EvidenceAPrefix, "-game", $Game) -Detail "after UI before swap" -LogPath $EvidenceALogPath
    Invoke-ExternalStep -Name "deterministic render evidence B" -Executable $GameExe -Arguments @("--render-evidence", $QuakeBase, $Map, [string]$RenderEvidenceFrame, $EvidenceBPrefix, "-game", $Game) -Detail "independent second process" -LogPath $EvidenceBLogPath
    Invoke-ExternalStep -Name "byte-identical render evidence comparison" -Executable $PythonExe -Arguments @($PythonPrefix + @($RenderEvidenceComparator, ($EvidenceAPrefix + ".tga"), ($EvidenceBPrefix + ".tga"), "--require-exact", "--min-ssim", "1.0", "--json-out", $EvidenceComparisonPath)) -Detail "exact deterministic 640x480 framebuffer identity" -LogPath $EvidenceComparisonLogPath
    $EvidenceA = Read-JsonFile ($EvidenceAPrefix + "-summary.json")
    $EvidenceB = Read-JsonFile ($EvidenceBPrefix + "-summary.json")
    if (-not $EvidenceA.ok -or -not $EvidenceB.ok) { throw "Render evidence summary reports failure or an all-black framebuffer." }
    if ([int]$EvidenceA.width -ne 640 -or [int]$EvidenceA.height -ne 480) { throw "Render evidence dimensions differ from 640x480." }
    if ($EvidenceA.pixel_hash -ne $EvidenceB.pixel_hash -or $EvidenceA.sample_hash -ne $EvidenceB.sample_hash) { throw "Render evidence hashes differ." }
    $EvidenceComparison = Read-JsonFile $EvidenceComparisonPath
    $EvidenceHash = (Get-FileHash -Algorithm SHA256 -LiteralPath ($EvidenceAPrefix + ".tga")).Hash.ToLowerInvariant()
    $EvidencePixelHash = [string]$EvidenceA.pixel_hash
    $EvidenceSampleHash = [string]$EvidenceA.sample_hash
    $EvidenceSsim = [double]$EvidenceComparison.ssim
  }

  if ($NetworkTests) {
    Invoke-ExternalStep `
      -Name "Winsock UDP loopback smoke" `
      -Executable $GameExe `
      -Arguments @("--udp-smoke", "2000") `
      -Detail "2 second timeout"
  } else {
    Add-StepResult "Winsock UDP loopback smoke" "SKIPPED" 0 "use -NetworkTests"
  }

  if ($IndependentFailures.Count -gt 0) {
    $First = $IndependentFailures[0]
    throw ("Independent test groups failed: " + $IndependentFailures.Count + "; first=" + $First.package + " " + $First.name)
  }

  $OverallStatus = "PASS"
} catch {
  $FailureMessage = $_.Exception.Message
  Write-Host "ERROR: $FailureMessage" -ForegroundColor Red
} finally {
  $BlockPackages = @("BP-045", "BP-046", "BP-047", "BP-048", "BP-049")
  $FirstFailureIndex = -1
  $FirstFailurePackage = ""
  if ($IndependentFailures.Count -gt 0) {
    $FirstFailurePackage = [string]$IndependentFailures[0].package
    $FirstFailureIndex = [array]::IndexOf($BlockPackages, $FirstFailurePackage)
    if ($FirstFailureIndex -lt 0) { $FirstFailureIndex = 0 }
  }
  $LogicalSteps = @()
  for ($LogicalIndex = 0; $LogicalIndex -lt $BlockPackages.Count; $LogicalIndex++) {
    $LogicalPackage = $BlockPackages[$LogicalIndex]
    $OwnFailure = @($IndependentFailures | Where-Object { $_.package -eq $LogicalPackage })
    $LogicalStatus = "PASS"
    if ($OwnFailure.Count -gt 0) {
      $LogicalStatus = "FAIL"
    } elseif ($FirstFailureIndex -ge 0 -and $LogicalIndex -gt $FirstFailureIndex) {
      # The independent fixture may have passed, but the cumulative dependency
      # chain is not accepted after an earlier block failure.
      $LogicalStatus = "BLOCKED"
    } elseif ($FirstFailureIndex -eq 0 -and $FirstFailurePackage -notmatch "^BP-04[5-9]$") {
      $LogicalStatus = "BLOCKED"
    }
    $LogicalSteps += [ordered]@{ package = $LogicalPackage; status = $LogicalStatus }
  }
  $Bisect = [ordered]@{
    schema = "MiniQuakeLogicalBlockBisect/1"
    block_id = $BlockId
    requested = [bool]$BisectOnFailure
    mode = "logical test-group checkpoint locator; no source rebuild is performed"
    failures = @($IndependentFailures)
    logical_steps = $LogicalSteps
    first_failing_package = $FirstFailurePackage
    suggested_patch = if ($FirstFailurePackage -match "^BP-04[0-9]$") { "patches/" + $FirstFailurePackage + ".diff" } else { "" }
  }
  $Bisect | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $BisectReportPath -Encoding UTF8

  $Summary = [ordered]@{
    schema_version = 1
    package_id = $PackageId
    parent_package_id = $ParentPackageId
    block_id = $BlockId
    delivery_revision = $DeliveryRevision
    block_parent_package_id = $BlockParentPackageId
    protocol_status = $ProtocolStatus
    quakec_status = $QuakeCStatus
    world_physics_status = $WorldPhysicsStatus
    host_lifecycle_status = $HostLifecycleStatus
    client_render_status = $ClientRenderStatus
    world_render_status = $WorldRenderStatus
    model_ui_render_status = $ModelUiRenderStatus
    created_utc = (Get-Date).ToUniversalTime().ToString("o")
    status = $OverallStatus
    failure = $FailureMessage
    configuration = $Configuration
    quake_validation = [ordered]@{
      base_supplied = -not [string]::IsNullOrWhiteSpace($QuakeBase)
      game = $Game
      map = $Map
      frames = $Frames
      trace_frames = $TraceFrames
      render_evidence_frame = $RenderEvidenceFrame
    }
    deterministic_trace = [ordered]@{
      sha256 = $TraceHash
      rolling_hash = $TraceRollingHash
    }
    render_evidence = [ordered]@{
      tga_sha256 = $EvidenceHash
      pixel_hash = $EvidencePixelHash
      sample_hash = $EvidenceSampleHash
      ssim = $EvidenceSsim
      capture_stage = "after_ui_before_swap"
    }
    artifacts = [ordered]@{
      transcript = [System.IO.Path]::GetFileName($TranscriptPath)
      static_report = [System.IO.Path]::GetFileName($StaticReportPath)
      version_output = [System.IO.Path]::GetFileName($VersionPath)
      build_child_log = [System.IO.Path]::GetFileName($BuildChildLogPath)
      trace_a_log = [System.IO.Path]::GetFileName($TraceALogPath)
      trace_b_log = [System.IO.Path]::GetFileName($TraceBLogPath)
      snapshot_command_log = [System.IO.Path]::GetFileName($SnapshotCommandLogPath)
      trace_comparison = [System.IO.Path]::GetFileName($TraceComparisonPath)
      trace_comparison_log = [System.IO.Path]::GetFileName($TraceComparisonLogPath)
      protocol15_vector_report = [System.IO.Path]::GetFileName($ProtocolVectorReportPath)
      protocol15_vector_log = [System.IO.Path]::GetFileName($ProtocolVectorLogPath)
      protocol15_command_report = [System.IO.Path]::GetFileName($ProtocolCommandReportPath)
      protocol15_command_log = [System.IO.Path]::GetFileName($ProtocolCommandLogPath)
      protocol15_serverdata_report = [System.IO.Path]::GetFileName($ProtocolServerDataReportPath)
      protocol15_serverdata_log = [System.IO.Path]::GetFileName($ProtocolServerDataLogPath)
      protocol15_event_report = [System.IO.Path]::GetFileName($ProtocolEventReportPath)
      protocol15_event_log = [System.IO.Path]::GetFileName($ProtocolEventLogPath)
      protocol15_runtime_event_report = [System.IO.Path]::GetFileName($ProtocolRuntimeEventReportPath)
      protocol15_runtime_event_log = [System.IO.Path]::GetFileName($ProtocolRuntimeEventLogPath)
      protocol15_signon_report = [System.IO.Path]::GetFileName($ProtocolSignonReportPath)
      protocol15_delivery_report = [System.IO.Path]::GetFileName($ProtocolDeliveryReportPath)
      protocol15_datagram_report = [System.IO.Path]::GetFileName($ProtocolDatagramReportPath)
      protocol15_demo_report = [System.IO.Path]::GetFileName($ProtocolDemoReportPath)
      protocol15_closure_report = [System.IO.Path]::GetFileName($ProtocolClosureReportPath)
      quakec_progs_report = [System.IO.Path]::GetFileName($QuakeCProgsReportPath)
      quakec_vm_report = [System.IO.Path]::GetFileName($QuakeCVMReportPath)
      quakec_edict_report = [System.IO.Path]::GetFileName($QuakeCEdictReportPath)
      quakec_builtin_report = [System.IO.Path]::GetFileName($QuakeCBuiltinReportPath)
      quakec_closure_report = [System.IO.Path]::GetFileName($QuakeCClosureReportPath)
      world_hull_report = [System.IO.Path]::GetFileName($WorldHullReportPath)
      world_trace_report = [System.IO.Path]::GetFileName($WorldTraceReportPath)
      world_link_report = [System.IO.Path]::GetFileName($WorldLinkReportPath)
      server_move_report = [System.IO.Path]::GetFileName($ServerMoveReportPath)
      server_physics_report = [System.IO.Path]::GetFileName($ServerPhysicsReportPath)
      sv_user_movement_report = [System.IO.Path]::GetFileName($SvUserMovementReportPath)
      server_user_report = [System.IO.Path]::GetFileName($ServerUserReportPath)
      world_physics_closure_report = [System.IO.Path]::GetFileName($WorldPhysicsClosureReportPath)
      host_timing_report = [System.IO.Path]::GetFileName($HostTimingReportPath)
      command_cvar_report = [System.IO.Path]::GetFileName($CommandCvarReportPath)
      demo_lifecycle_report = [System.IO.Path]::GetFileName($DemoLifecycleReportPath)
      savegame_v5_report = [System.IO.Path]::GetFileName($SavegameV5ReportPath)
      host_lifecycle_closure_report = [System.IO.Path]::GetFileName($HostLifecycleClosureReportPath)
      client_state_render_report = [System.IO.Path]::GetFileName($ClientStateRenderReportPath)
      view_state_report = [System.IO.Path]::GetFileName($ViewStateReportPath)
      temporary_beam_report = [System.IO.Path]::GetFileName($TemporaryBeamReportPath)
      particle_runtime_report = [System.IO.Path]::GetFileName($ParticleRuntimeReportPath)
      client_render_closure_report = [System.IO.Path]::GetFileName($ClientRenderClosureReportPath)
      world_surface_report = [System.IO.Path]::GetFileName($WorldSurfaceRenderReportPath)
      lightmap_atlas_report = [System.IO.Path]::GetFileName($LightmapAtlasReportPath)
      dynamic_light_render_report = [System.IO.Path]::GetFileName($DynamicLightRenderReportPath)
      sky_water_render_report = [System.IO.Path]::GetFileName($SkyWaterRenderReportPath)
      world_render_closure_report = [System.IO.Path]::GetFileName($WorldRenderClosureReportPath)
      alias_model_report = [System.IO.Path]::GetFileName($AliasModelReportPath)
      sprite_sync_report = [System.IO.Path]::GetFileName($SpriteSyncReportPath)
      render_ui_hud_report = [System.IO.Path]::GetFileName($RenderUiHudReportPath)
      render_evidence_report = [System.IO.Path]::GetFileName($RenderEvidenceReportPath)
      model_ui_render_report = [System.IO.Path]::GetFileName($ModelUiRenderReportPath)
      render_evidence_comparison = [System.IO.Path]::GetFileName($EvidenceComparisonPath)
      render_evidence_directory = "bp045-049r2-evidence"
      quakec_stock_log = [System.IO.Path]::GetFileName($QuakeCStockLogPath)
      game_validation_log = [System.IO.Path]::GetFileName($GameValidationLogPath)
      runtime_validation_log = [System.IO.Path]::GetFileName($RuntimeValidationLogPath)
      bisect_report = [System.IO.Path]::GetFileName($BisectReportPath)
      trace_directory = "bp045-049r2-traces"
      independent_failures = @($IndependentFailures)
    }
    steps = @($Steps)
  }
  $Summary | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $SummaryPath -Encoding UTF8

  if ($TranscriptStarted) {
    try { Stop-Transcript | Out-Null } catch { }
  }
}

if ($OverallStatus -ne "PASS") {
  Write-Host "MiniQuake $DeliveryRevision acceptance test: FAIL"
  Write-Host "Run .\COLLECT_RESULTS.ps1 and upload the generated result archive."
  exit 1
}

Write-Host "MiniQuake $DeliveryRevision acceptance test: PASS"
Write-Host "Result summary: $SummaryPath"
Write-Host "For feedback, run .\COLLECT_RESULTS.ps1 and upload the generated ZIP."
exit 0
