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
  [int]$Frames = 120,

  [ValidateRange(1, 1000000)]
  [int]$TraceFrames = 64,

  [ValidateSet("Release", "Debug")]
  [string]$Configuration = "Release",

  [switch]$SkipBuild,
  [switch]$SkipGameValidation,
  [switch]$SkipTraceValidation,
  [switch]$NetworkTests,
  [switch]$RebuildNative,
  [switch]$Listings
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$PackageId = "BP-012R1"
$ParentPackageId = "BP-012"
$NativeTextAbi = "caller_owned_bytes_v1"
$ProtocolTextAbi = "quake_latin1_cstring_v1"
$Root = Split-Path -Parent $PSScriptRoot
$BuildDirectory = Join-Path $Root "build"
$TraceDirectory = Join-Path $BuildDirectory "bp012r1-traces"
$GameExe = Join-Path $BuildDirectory "MiniQuake.exe"
$Verifier = Join-Path $Root "tools\verify.py"
$TraceComparator = Join-Path $Root "tools\compare_traces.py"
$ProtocolVectorChecker = Join-Path $Root "tools\check_protocol15_vectors.py"
$ProtocolCommandChecker = Join-Path $Root "tools\check_protocol15_commands.py"
$ProtocolServerDataChecker = Join-Path $Root "tools\check_protocol15_serverdata.py"
$BuildScript = Join-Path $Root "build.ps1"
$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$TranscriptPath = Join-Path $BuildDirectory ("bp012r1-test-{0}.log" -f $Timestamp)
$SummaryPath = Join-Path $BuildDirectory "bp012r1-test-summary.json"
$StaticReportPath = Join-Path $BuildDirectory "bp012r1-static-verification.json"
$VersionPath = Join-Path $BuildDirectory "bp012r1-version.txt"
$BuildChildLogPath = Join-Path $BuildDirectory "bp012r1-build-child.log"
$TraceALogPath = Join-Path $BuildDirectory "bp012r1-trace-a.log"
$TraceBLogPath = Join-Path $BuildDirectory "bp012r1-trace-b.log"
$SnapshotCommandLogPath = Join-Path $BuildDirectory "bp012r1-snapshot-command.log"
$TraceComparisonPath = Join-Path $BuildDirectory "bp012r1-trace-comparison.json"
$TraceComparisonLogPath = Join-Path $BuildDirectory "bp012r1-trace-comparison.log"
$ProtocolVectorReportPath = Join-Path $BuildDirectory "bp012r1-protocol15-vectors.json"
$ProtocolVectorLogPath = Join-Path $BuildDirectory "bp012r1-protocol15-vectors.log"
$ProtocolCommandReportPath = Join-Path $BuildDirectory "bp012r1-protocol15-commands.json"
$ProtocolCommandLogPath = Join-Path $BuildDirectory "bp012r1-protocol15-commands.log"
$ProtocolServerDataReportPath = Join-Path $BuildDirectory "bp012r1-protocol15-serverdata.json"
$ProtocolServerDataLogPath = Join-Path $BuildDirectory "bp012r1-protocol15-serverdata.log"
$Steps = New-Object System.Collections.ArrayList
$OverallStatus = "FAIL"
$FailureMessage = ""
$TranscriptStarted = $false
$TraceHash = ""
$TraceRollingHash = ""

New-Item -ItemType Directory -Force -Path $BuildDirectory | Out-Null

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

  Write-Host "MiniQuake $PackageId acceptance test"
  Write-Host "  parent:        $ParentPackageId"
  Write-Host "  root:          $Root"
  Write-Host "  configuration: $Configuration"

  $PythonCommand = Resolve-PythonCommand
  $PythonExe = $PythonCommand.executable
  $PythonPrefix = @($PythonCommand.prefix)

  Invoke-ExternalStep `
    -Name "static package and diagnostics verification" `
    -Executable $PythonExe `
    -Arguments @($PythonPrefix + @($Verifier, $Root, "--json-output", $StaticReportPath)) `
    -Detail "manifest, packages, ABI, accepted BP-011 runtime baseline, diagnosed BP-012 result and BP-012R1 ground-flag adapter contract"

  Invoke-ExternalStep `
    -Name "trace comparator self-test" `
    -Executable $PythonExe `
    -Arguments @($PythonPrefix + @($TraceComparator, "--self-test")) `
    -Detail "field-level first-divergence reporter"

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

  if (-not $SkipBuild) {
    $BuildArguments = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $BuildScript)
    if (-not [string]::IsNullOrWhiteSpace($Compiler)) { $BuildArguments += @("-Compiler", $Compiler) }
    if (-not [string]::IsNullOrWhiteSpace($StdLib)) { $BuildArguments += @("-StdLib", $StdLib) }
    $BuildArguments += @("-Python", $PythonExe, "-Configuration", $Configuration)
    if ($NetworkTests) { $BuildArguments += "-NetworkTests" }
    if ($RebuildNative) { $BuildArguments += "-RebuildNative" }
    if ($Listings) { $BuildArguments += "-Listings" }

    $PowerShellExe = (Get-Process -Id $PID).Path
    Invoke-ExternalStep `
      -Name "build plus core, milestone, diagnostics and Protocol 15 regression/command/server-data tests" `
      -Executable $PowerShellExe `
      -Arguments $BuildArguments `
      -Detail "MiniQuake.exe plus 16 core, 24 milestone, 10 diagnostics, 15 wire, 14 command/update and 17 server-data fixtures" `
      -LogPath $BuildChildLogPath
  } else {
    Add-StepResult "build plus core, milestone, diagnostics and Protocol 15 regression/command/server-data tests" "SKIPPED" 0 "-SkipBuild"
  }

  Require-File $GameExe "MiniQuake executable"
  Require-File (Join-Path $BuildDirectory "MiniQuakeProtocol15WireTests.exe") "Protocol 15 wire test executable"
  Require-File (Join-Path $BuildDirectory "MiniQuakeProtocol15CommandTests.exe") "Protocol 15 command test executable"
  Require-File (Join-Path $BuildDirectory "MiniQuakeProtocol15ServerDataTests.exe") "Protocol 15 server-data test executable"

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
    "Protocol text ABI: $ProtocolTextAbi"
  )) {
    if ($VersionText -notmatch [regex]::Escape($Marker)) { throw "Executable identity marker missing: $Marker" }
  }
  Add-StepResult "executable identity" "PASS" 0 "Package: $PackageId; parent: $ParentPackageId"

  $CanUseGameData = -not $SkipGameValidation -and -not [string]::IsNullOrWhiteSpace($QuakeBase)
  if (-not $CanUseGameData) {
    $Reason = if ($SkipGameValidation) { "-SkipGameValidation" } else { "no -QuakeBase supplied" }
    Add-StepResult "installed Quake data validation" "SKIPPED" 0 $Reason
    Add-StepResult "headless runtime validation" "SKIPPED" 0 $Reason
  } else {
    if (-not (Test-Path -LiteralPath $QuakeBase -PathType Container)) {
      throw "Quake base directory does not exist: $QuakeBase"
    }
    Invoke-ExternalStep `
      -Name "installed Quake data validation" `
      -Executable $GameExe `
      -Arguments @("--validate-game", $QuakeBase, $Map, "-game", $Game) `
      -Detail "game=$Game map=$Map"
    Invoke-ExternalStep `
      -Name "headless runtime validation" `
      -Executable $GameExe `
      -Arguments @("--validate-runtime", $QuakeBase, $Map, [string]$Frames, "-game", $Game) `
      -Detail "game=$Game map=$Map frames=$Frames"
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
      Require-File $Artifact "BP-012R1 trace artifact"
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
      throw "BP-012R1 deterministic traces differ. The first differing fields are recorded in $TraceComparisonPath."
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

  if ($NetworkTests) {
    Invoke-ExternalStep `
      -Name "Winsock UDP loopback smoke" `
      -Executable $GameExe `
      -Arguments @("--udp-smoke", "2000") `
      -Detail "2 second timeout"
  } else {
    Add-StepResult "Winsock UDP loopback smoke" "SKIPPED" 0 "use -NetworkTests"
  }

  $OverallStatus = "PASS"
} catch {
  $FailureMessage = $_.Exception.Message
  Write-Host "ERROR: $FailureMessage" -ForegroundColor Red
} finally {
  $Summary = [ordered]@{
    schema_version = 1
    package_id = $PackageId
    parent_package_id = $ParentPackageId
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
    }
    deterministic_trace = [ordered]@{
      sha256 = $TraceHash
      rolling_hash = $TraceRollingHash
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
      trace_directory = "bp012r1-traces"
    }
    steps = @($Steps)
  }
  $Summary | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $SummaryPath -Encoding UTF8

  if ($TranscriptStarted) {
    try { Stop-Transcript | Out-Null } catch { }
  }
}

if ($OverallStatus -ne "PASS") {
  Write-Host "MiniQuake $PackageId acceptance test: FAIL"
  Write-Host "Run .\scripts\COLLECT_RESULTS.ps1 and upload the generated result archive."
  exit 1
}

Write-Host "MiniQuake $PackageId acceptance test: PASS"
Write-Host "Result summary: $SummaryPath"
Write-Host "For feedback, run .\scripts\COLLECT_RESULTS.ps1 and upload the generated ZIP."
exit 0
