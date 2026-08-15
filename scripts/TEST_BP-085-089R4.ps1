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
  [int]$BlackPortCorpusFrames = 64,
  [ValidateRange(1, 1000000)]
  [int]$RenderEvidenceFrame = 128,
  [ValidateRange(1, 2000000000)]
  [int]$SoakFrames = 5000,
  [ValidateRange(1, 2000000000)]
  [int]$ListenSoakFrames = 5000,
  [ValidateSet("Release", "Debug")]
  [string]$Configuration = "Release",
  [switch]$SkipBuild,
  [switch]$SkipGameValidation,
  [switch]$SkipTraceValidation,
  [switch]$SkipRenderEvidence,
  [switch]$SkipBlackPortCorpus,
  [switch]$SkipAudioEvidence,
  [switch]$SkipArtifactEvidence,
  [switch]$SkipMissionPackEvidence,
  [switch]$SkipSoak,
  [switch]$SkipNetworkEvidence,
  [switch]$NetworkTests,
  [switch]$RebuildNative,
  [switch]$Listings,
  [switch]$ContinueIndependentTests = $true,
  [switch]$BisectOnFailure
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# Force Python tools and the Python MiniLang compiler to flush every line.
# The PowerShell wrappers below also forward every received line immediately.
$env:PYTHONUNBUFFERED = "1"

$PackageId = "BP-089"
$ParentPackageId = "BP-088"
$BlockId = "BP-085-089"
$DeliveryRevision = "BP-085-089R4"
$DeliveryParent = "BP-085-089R3"
$BlockParentPackageId = "BP-080-084R2"
$Root = Split-Path -Parent $PSScriptRoot
$Build = Join-Path $Root "build"
$BuildScript = Join-Path $Root "build.ps1"
$GameExe = Join-Path $Build "MiniQuake.exe"
$EvidenceExe = Join-Path $Build "MiniQuakeNetworkPlatformEvidence.exe"
$CoreAssetEvidenceExe = Join-Path $Build "MiniQuakeCoreAssetRetailEvidence.exe"
$ArtifactEvidenceExe = Join-Path $Build "MiniQuakeArtifactRetailEvidence.exe"
$TraceComparator = Join-Path $Root "tools\compare_traces.py"
$RenderComparator = Join-Path $Root "tools\compare_render_evidence.py"
$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$TranscriptPath = Join-Path $Build ("bp085-089r4-test-{0}.log" -f $Timestamp)
$SummaryPath = Join-Path $Build "bp085-089r4-test-summary.json"
$Steps = New-Object System.Collections.Generic.List[object]

function Resolve-Tool([string]$Value, [string]$Label) {
  if (-not [string]::IsNullOrWhiteSpace($Value) -and (Test-Path -LiteralPath $Value -PathType Leaf)) {
    return [IO.Path]::GetFullPath($Value)
  }
  if (-not [string]::IsNullOrWhiteSpace($Value)) {
    $Command = Get-Command $Value -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($null -ne $Command) { return $Command.Path }
  }
  throw "$Label not found: $Value"
}

function Add-Step([string]$Name, [string]$Status, [int]$ExitCode, [string]$Detail) {
  $Steps.Add([ordered]@{ name = $Name; status = $Status; exit_code = $ExitCode; detail = $Detail })
  $Color = if ($Status -eq "PASS") { "Green" } elseif ($Status -eq "SKIPPED") { "Yellow" } else { "Red" }
  Write-Host ("[{0}] {1} - {2}" -f $Status, $Name, $Detail) -ForegroundColor $Color
}

function Failure-Marker([string]$Text) {
  if ([string]::IsNullOrWhiteSpace($Text)) { return "" }
  foreach ($Line in ($Text -split "`r?`n")) {
    if ($Line -match '^\s*FAIL:\s*' -or $Line -match 'tests failed:\s*[1-9]' -or $Line -match 'evidence:\s*FAIL') { return $Line.Trim() }
  }
  return ""
}

function Invoke-LiveProcess(
  [string]$Executable,
  [string[]]$Arguments,
  [string]$LogPath
) {
  $Lines = [System.Collections.Generic.List[string]]::new()
  $Encoding = [System.Text.UTF8Encoding]::new($false)
  $Writer = [System.IO.StreamWriter]::new($LogPath, $false, $Encoding)
  $Code = 1
  try {
    & $Executable @Arguments 2>&1 |
      ForEach-Object {
        $Line = [string]$_
        $Lines.Add($Line)
        $Writer.WriteLine($Line)
        $Writer.Flush()
        Write-Host $Line
      }
    $Code = [int]$LASTEXITCODE
  } finally {
    $Writer.Flush()
    $Writer.Dispose()
  }
  $Text = [string]::Join("`n", $Lines.ToArray())
  return [pscustomobject]@{
    exit_code = $Code
    text = $Text
  }
}

function Run-Logged([string]$Name, [string]$Executable, [string[]]$Arguments, [string]$LogName, [string]$RequiredMarker = "") {
  $LogPath = Join-Path $Build $LogName
  Write-Host ("[MiniQuake] starting {0}" -f $Name) -ForegroundColor Cyan
  $Result = Invoke-LiveProcess -Executable $Executable -Arguments $Arguments -LogPath $LogPath
  $Code = [int]$Result.exit_code
  $Text = [string]$Result.text
  $Marker = Failure-Marker $Text
  if ($Code -eq 0 -and -not [string]::IsNullOrWhiteSpace($Marker)) { $Code = 1 }
  if ($Code -eq 0 -and -not [string]::IsNullOrWhiteSpace($RequiredMarker) -and $Text -notmatch [regex]::Escape($RequiredMarker)) { $Code = 1; $Marker = "missing marker: $RequiredMarker" }
  if ($Code -ne 0) { Add-Step $Name "FAIL" $Code ("log=" + $LogName + " " + $Marker); throw "$Name failed with exit code $Code" }
  Add-Step $Name "PASS" 0 ("log=" + $LogName)
  return $Text
}

function Start-BackgroundCapturedProcess(
  [string]$Executable,
  [string]$ArgumentsText,
  [string]$Label
) {
  $StartInfo = New-Object System.Diagnostics.ProcessStartInfo
  $StartInfo.FileName = $Executable
  $StartInfo.Arguments = $ArgumentsText
  $StartInfo.WorkingDirectory = $Root
  $StartInfo.UseShellExecute = $false
  $StartInfo.CreateNoWindow = $true
  $StartInfo.RedirectStandardOutput = $true
  $StartInfo.RedirectStandardError = $true

  $Process = New-Object System.Diagnostics.Process
  $Process.StartInfo = $StartInfo
  try {
    if (-not $Process.Start()) {
      throw "process start returned false"
    }
  } catch {
    $Process.Dispose()
    throw ("INFRA_FAILURE: could not start {0}: {1}" -f $Label, $_.Exception.Message)
  }

  # Drain both redirected streams asynchronously while the server runs. This
  # avoids a pipe deadlock without buffering any foreground compiler/test job.
  $StdoutTask = $Process.StandardOutput.ReadToEndAsync()
  $StderrTask = $Process.StandardError.ReadToEndAsync()
  return [pscustomobject]@{
    process = $Process
    stdout_task = $StdoutTask
    stderr_task = $StderrTask
    label = $Label
  }
}

function Stop-BackgroundCapturedProcess([pscustomobject]$Handle) {
  if ($null -eq $Handle -or $null -eq $Handle.process) { return }
  $Process = [System.Diagnostics.Process]$Handle.process
  try {
    if (-not $Process.HasExited) { $Process.Kill() }
  } catch { }
  try { $Process.WaitForExit() } catch { }
}

function Complete-BackgroundCapturedProcess(
  [pscustomobject]$Handle,
  [int]$TimeoutMilliseconds,
  [string]$StdoutPath,
  [string]$StderrPath
) {
  $Process = [System.Diagnostics.Process]$Handle.process
  $Label = [string]$Handle.label
  $Exited = $false
  try {
    $Exited = $Process.WaitForExit($TimeoutMilliseconds)
  } catch {
    Stop-BackgroundCapturedProcess $Handle
    throw ("INFRA_FAILURE: waiting for {0} failed: {1}" -f $Label, $_.Exception.Message)
  }
  if (-not $Exited) {
    Stop-BackgroundCapturedProcess $Handle
    throw ("INFRA_FAILURE: {0} timed out after {1} ms" -f $Label, $TimeoutMilliseconds)
  }

  # The parameterless wait synchronizes redirected-stream completion on
  # Windows PowerShell 5.1. Refresh before reading ExitCode so the process
  # object cannot retain the blank/null status observed in R5.
  $Process.WaitForExit()
  $Process.Refresh()

  try {
    $Stdout = [string]$Handle.stdout_task.Result
    $Stderr = [string]$Handle.stderr_task.Result
  } catch {
    $Process.Dispose()
    throw ("INFRA_FAILURE: collecting {0} output failed: {1}" -f $Label, $_.Exception.Message)
  }

  $Encoding = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($StdoutPath, $Stdout, $Encoding)
  [System.IO.File]::WriteAllText($StderrPath, $Stderr, $Encoding)

  try {
    $Code = [int]$Process.ExitCode
  } catch {
    $Process.Dispose()
    throw ("INFRA_FAILURE: {0} exit code unavailable after process completion: {1}" -f $Label, $_.Exception.Message)
  }
  $Process.Dispose()

  return [pscustomobject]@{
    exit_code = $Code
    stdout = $Stdout
    stderr = $Stderr
    timed_out = $false
  }
}

function Write-NetworkEvidenceOutput([string]$Suffix, [string]$Stdout, [string]$Stderr) {
  if (-not [string]::IsNullOrWhiteSpace($Stdout)) {
    Write-Host ("[MiniQuake] network evidence server {0} stdout" -f $Suffix) -ForegroundColor Cyan
    foreach ($Line in ($Stdout -split "`r?`n")) {
      if (-not [string]::IsNullOrEmpty($Line)) { Write-Host $Line }
    }
  }
  if (-not [string]::IsNullOrWhiteSpace($Stderr)) {
    Write-Host ("[MiniQuake] network evidence server {0} stderr" -f $Suffix) -ForegroundColor Yellow
    foreach ($Line in ($Stderr -split "`r?`n")) {
      if (-not [string]::IsNullOrEmpty($Line)) { Write-Host $Line -ForegroundColor Yellow }
    }
  }
}

function Run-NetworkEvidencePair([string]$Suffix, [int]$Port) {
  $ServerOut = Join-Path $Build ("bp085-089r4-network-server-{0}.log" -f $Suffix)
  $ServerErr = Join-Path $Build ("bp085-089r4-network-server-{0}.err.log" -f $Suffix)
  $ClientLog = Join-Path $Build ("bp085-089r4-network-client-{0}.log" -f $Suffix)
  $PairJson = Join-Path $Build ("bp085-089r4-network-pair-{0}.json" -f $Suffix)
  Remove-Item -Force -ErrorAction SilentlyContinue $ServerOut, $ServerErr, $ClientLog, $PairJson

  Write-Host ("[MiniQuake] starting network evidence server {0} on UDP port {1}" -f $Suffix, $Port) -ForegroundColor Cyan
  $ServerHandle = Start-BackgroundCapturedProcess -Executable $EvidenceExe -ArgumentsText ("server {0}" -f $Port) -Label ("network evidence server {0}" -f $Suffix)
  $ClientResult = $null
  $ServerResult = $null
  try {
    Start-Sleep -Milliseconds 300
    Write-Host ("[MiniQuake] starting network evidence client {0}" -f $Suffix) -ForegroundColor Cyan
    $ClientResult = Invoke-LiveProcess -Executable $EvidenceExe -Arguments @("client", [string]$Port) -LogPath $ClientLog
    $ServerResult = Complete-BackgroundCapturedProcess -Handle $ServerHandle -TimeoutMilliseconds 7000 -StdoutPath $ServerOut -StderrPath $ServerErr
  } catch {
    Stop-BackgroundCapturedProcess $ServerHandle
    throw
  }

  $ClientCode = [int]$ClientResult.exit_code
  $ClientText = [string]$ClientResult.text
  $ServerCode = [int]$ServerResult.exit_code
  $ServerText = [string]$ServerResult.stdout
  $ServerErrorText = [string]$ServerResult.stderr
  Write-NetworkEvidenceOutput -Suffix $Suffix -Stdout $ServerText -Stderr $ServerErrorText

  $ServerPassed = $ServerText -match 'network platform evidence server: PASS'
  $ClientPassed = $ClientText -match 'network platform evidence: PASS'
  $PairSummary = [ordered]@{
    schema_version = 1
    suffix = $Suffix
    port = $Port
    server_exit_code = $ServerCode
    client_exit_code = $ClientCode
    server_pass_marker = [bool]$ServerPassed
    client_pass_marker = [bool]$ClientPassed
    server_stderr_empty = [string]::IsNullOrWhiteSpace($ServerErrorText)
    status = if ($ServerCode -eq 0 -and $ClientCode -eq 0 -and $ServerPassed -and $ClientPassed) { "PASS" } else { "FAIL" }
  }
  $PairSummary | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $PairJson -Encoding UTF8

  if ($ServerCode -ne 0 -or $ClientCode -ne 0) {
    throw "network evidence pair $Suffix failed: server=$ServerCode client=$ClientCode"
  }
  if (-not $ServerPassed) { throw "network evidence server $Suffix did not report PASS" }
  if (-not $ClientPassed) { throw "network evidence client $Suffix did not report PASS" }
  return $ClientLog
}

New-Item -ItemType Directory -Force -Path $Build | Out-Null
Start-Transcript -Path $TranscriptPath -Force | Out-Null
$Failure = ""
try {
  Write-Host "MiniQuake BP-085-089R4 acceptance test"
  Write-Host "  parent: $BlockParentPackageId"
  Write-Host "  root:   $Root"
  if ($BisectOnFailure) { Write-Host "  logical bisect markers enabled" }

  if ([string]::IsNullOrWhiteSpace($Python)) { $Python = "python" }
  $PythonExe = Resolve-Tool $Python "Python"

  if (-not $SkipBuild) {
    $PowerShellExe = (Get-Process -Id $PID).Path
    $Arguments = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $BuildScript)
    if (-not [string]::IsNullOrWhiteSpace($Compiler)) { $Arguments += @("-Compiler", $Compiler) }
    if (-not [string]::IsNullOrWhiteSpace($StdLib)) { $Arguments += @("-StdLib", $StdLib) }
    $Arguments += @("-Python", $PythonExe, "-Configuration", $Configuration)
    if ($NetworkTests) { $Arguments += "-NetworkTests" }
    if ($RebuildNative) { $Arguments += "-RebuildNative" }
    if ($Listings) { $Arguments += "-Listings" }
    [void](Run-Logged "single cumulative build and unit-test suite" $PowerShellExe $Arguments "bp085-089r4-build-child.log" "MiniQuake BP-089 compatibility release closure tests passed: 24")
  } else {
    Add-Step "single cumulative build and unit-test suite" "SKIPPED" 0 "-SkipBuild"
  }

  foreach ($Path in @($GameExe, $EvidenceExe, $CoreAssetEvidenceExe, $ArtifactEvidenceExe)) { if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { throw "required executable missing: $Path" } }

  $Version = Run-Logged "package identity" $GameExe @("--version") "bp085-089r4-version.txt" "Compatibility release status: compat_109_release_candidate_v1"
  if ($Version -notmatch 'Package: BP-089' -or $Version -notmatch 'Block: BP-085-089') { throw "compiled package identity mismatch" }
  if ($Version -notmatch 'Core assets/memory status: core_assets_memory_109_frozen_v1' -or $Version -notmatch 'Core assets/memory fingerprint: 0x6c8d974d') { throw "compiled core assets/memory identity mismatch" }
  if ($Version -notmatch 'Gameplay/presentation status: gameplay_presentation_109_frozen_v1' -or $Version -notmatch 'Gameplay/presentation fingerprint: 0xad91624c') { throw "compiled gameplay/presentation identity mismatch" }
  if ($Version -notmatch 'Black-port source status: black_port_source_109_frozen_v1' -or $Version -notmatch 'Black-port source fingerprint: 0x309b0737') { throw "compiled black-port source identity mismatch" }
  if ($Version -notmatch 'Game profile status: game_profile_109_frozen_v1' -or $Version -notmatch 'Game profile fingerprint: 0x7a03b68d') { throw "compiled game-profile identity mismatch" }
  if ($Version -notmatch 'Mod runtime status: mod_runtime_109_frozen_v1' -or $Version -notmatch 'Mod runtime fingerprint: 0x4649813d') { throw "compiled mod-runtime identity mismatch" }
  if ($Version -notmatch 'Artifact compatibility status: artifact_compat_109_frozen_v1' -or $Version -notmatch 'Artifact compatibility fingerprint: 0x59531091') { throw "compiled artifact identity mismatch" }
  if ($Version -notmatch 'Stability status: stability_109_frozen_v1' -or $Version -notmatch 'Stability fingerprint: 0x6c131501') { throw "compiled stability identity mismatch" }
  if ($Version -notmatch 'Compatibility release status: compat_109_release_candidate_v1' -or $Version -notmatch 'Compatibility release fingerprint: 0x29b72a98') { throw "compiled release-candidate identity mismatch" }

  $CanUseGame = -not $SkipGameValidation -and -not [string]::IsNullOrWhiteSpace($QuakeBase)
  if ($CanUseGame) {
    if (-not (Test-Path -LiteralPath (Join-Path $QuakeBase "id1\pak0.pak") -PathType Leaf)) { throw "Quake data not found: $QuakeBase\id1\pak0.pak" }
    [void](Run-Logged "installed Quake data validation" $GameExe @("--validate-game", $QuakeBase, $Map, "-game", $Game) "bp085-089r4-game-validation.log" "Validation result: PASS")
    [void](Run-Logged "headless runtime validation" $GameExe @("--validate-runtime", $QuakeBase, $Map, [string]$Frames, "-game", $Game) "bp085-089r4-runtime-validation.log")
  } else {
    Add-Step "installed Quake data validation" "SKIPPED" 0 "no usable -QuakeBase or skipped"
    Add-Step "headless runtime validation" "SKIPPED" 0 "no usable -QuakeBase or skipped"
  }

  if (-not $SkipMissionPackEvidence -and $CanUseGame) {
    foreach ($Mission in @("rogue", "hipnotic")) {
      $MissionDirectory = Join-Path $QuakeBase $Mission
      $MissionPak = Get-ChildItem -LiteralPath $MissionDirectory -File -Filter "pak*.pak" -ErrorAction SilentlyContinue | Select-Object -First 1
      if ($null -eq $MissionPak) {
        Add-Step ("optional mission-pack {0}" -f $Mission) "SKIPPED" 0 "directory or PAK not installed"
        continue
      }
      $MissionFlag = "-" + $Mission
      [void](Run-Logged ("mission-pack {0} game validation" -f $Mission) $GameExe @("--validate-game", $QuakeBase, "start", $MissionFlag) ("bp085-089r4-{0}-validation.log" -f $Mission) "Validation result: PASS")
      [void](Run-Logged ("mission-pack {0} headless runtime" -f $Mission) $GameExe @("-basedir", $QuakeBase, $MissionFlag, "-headless", "-nosound", "-maxframes", "128", "+map", "start") ("bp085-089r4-{0}-runtime.log" -f $Mission))
    }
  } else {
    Add-Step "optional mission-pack validation" "SKIPPED" 0 "skipped or no usable Quake data"
  }

  if ($CanUseGame) {
    $CoreA = Join-Path $Build "bp085-089r4-core-assets-a.log"
    $CoreB = Join-Path $Build "bp085-089r4-core-assets-b.log"
    [void](Run-Logged "retail core asset evidence A" $CoreAssetEvidenceExe @($QuakeBase, $Game) ([IO.Path]::GetFileName($CoreA)) "result=PASS")
    [void](Run-Logged "retail core asset evidence B" $CoreAssetEvidenceExe @($QuakeBase, $Game) ([IO.Path]::GetFileName($CoreB)) "result=PASS")
    $CoreHashA = (Get-FileHash -Algorithm SHA256 -LiteralPath $CoreA).Hash.ToLowerInvariant()
    $CoreHashB = (Get-FileHash -Algorithm SHA256 -LiteralPath $CoreB).Hash.ToLowerInvariant()
    if ($CoreHashA -ne $CoreHashB) { throw "retail core asset evidence differs: A=$CoreHashA B=$CoreHashB" }
    Add-Step "byte-identical retail core asset evidence" "PASS" 0 ("sha256=" + $CoreHashA)
  } else {
    Add-Step "retail core asset evidence" "SKIPPED" 0 "no usable -QuakeBase"
  }

  if (-not $SkipAudioEvidence -and $CanUseGame) {
    $AudioExe = Join-Path $Build "MiniQuakeAudioRetailEvidence.exe"
    $A = Join-Path $Build "bp085-089r4-audio-a.log"; $B = Join-Path $Build "bp085-089r4-audio-b.log"
    $TextA = Run-Logged "retail audio evidence A" $AudioExe @($QuakeBase, $Game) ([IO.Path]::GetFileName($A)) "MiniQuake BP-059 retail audio evidence: PASS"
    $TextB = Run-Logged "retail audio evidence B" $AudioExe @($QuakeBase, $Game) ([IO.Path]::GetFileName($B)) "MiniQuake BP-059 retail audio evidence: PASS"
    $HashA = (Get-FileHash -Algorithm SHA256 -LiteralPath $A).Hash.ToLowerInvariant(); $HashB = (Get-FileHash -Algorithm SHA256 -LiteralPath $B).Hash.ToLowerInvariant()
    if ($HashA -ne $HashB) { throw "retail audio evidence differs" }
    Add-Step "byte-identical retail audio evidence" "PASS" 0 ("sha256=" + $HashA)
  } else { Add-Step "retail audio evidence" "SKIPPED" 0 "skipped or no Quake data" }

  if (-not $SkipArtifactEvidence -and $CanUseGame) {
    $ArtifactA = Join-Path $Build "bp085-089r4-artifacts-a.log"
    $ArtifactB = Join-Path $Build "bp085-089r4-artifacts-b.log"
    $ArtifactTextA = Run-Logged "retail demo/save artifact evidence A" $ArtifactEvidenceExe @($QuakeBase, $Game, $Map) ([IO.Path]::GetFileName($ArtifactA)) "result=PASS"
    $ArtifactTextB = Run-Logged "retail demo/save artifact evidence B" $ArtifactEvidenceExe @($QuakeBase, $Game, $Map) ([IO.Path]::GetFileName($ArtifactB)) "result=PASS"
    foreach ($ArtifactText in @($ArtifactTextA, $ArtifactTextB)) {
      if ($ArtifactText -notmatch 'first_pass_exact=true' -or
          $ArtifactText -notmatch 'semantic=true' -or
          $ArtifactText -notmatch 'stable_exact=true' -or
          $ArtifactText -notmatch 'stable_semantic=true' -or
          $ArtifactText -notmatch 'save_float_format=4097:4097\.000000 negative:-4097\.000000') {
        throw "retail artifact evidence did not prove exact, semantic, stable and overflow-safe save roundtrip"
      }
    }
    $ArtifactHashA = (Get-FileHash -Algorithm SHA256 -LiteralPath $ArtifactA).Hash.ToLowerInvariant()
    $ArtifactHashB = (Get-FileHash -Algorithm SHA256 -LiteralPath $ArtifactB).Hash.ToLowerInvariant()
    if ($ArtifactHashA -ne $ArtifactHashB) { throw "retail artifact evidence differs: A=$ArtifactHashA B=$ArtifactHashB" }
    Add-Step "byte-identical retail demo/save evidence" "PASS" 0 ("sha256=" + $ArtifactHashA)
  } else {
    Add-Step "retail demo/save artifact evidence" "SKIPPED" 0 "skipped or no usable Quake data"
  }

  if (-not $SkipTraceValidation -and $CanUseGame) {
    $TraceDir = Join-Path $Build "bp085-089r4-traces"; Remove-Item -Recurse -Force -ErrorAction SilentlyContinue $TraceDir; New-Item -ItemType Directory -Force -Path $TraceDir | Out-Null
    $PrefixA = Join-Path $TraceDir "run-a"; $PrefixB = Join-Path $TraceDir "run-b"
    [void](Run-Logged "compatibility trace A" $GameExe @("--compat-trace", $QuakeBase, $Map, [string]$TraceFrames, $PrefixA, "-game", $Game) "bp085-089r4-trace-a.log")
    [void](Run-Logged "compatibility trace B" $GameExe @("--compat-trace", $QuakeBase, $Map, [string]$TraceFrames, $PrefixB, "-game", $Game) "bp085-089r4-trace-b.log")
    [void](Run-Logged "byte-identical trace comparison" $PythonExe @($TraceComparator, ("{0}.mqtrace" -f $PrefixA), ("{0}.mqtrace" -f $PrefixB), "--json-output", (Join-Path $Build "bp085-089r4-trace-comparison.json")) "bp085-089r4-trace-comparison.log")
  } else { Add-Step "deterministic compatibility traces" "SKIPPED" 0 "skipped or no Quake data" }

  if (-not $SkipBlackPortCorpus -and $CanUseGame) {
    $CorpusRoot = Join-Path $Build "bp085-089r4-black-port-corpus"
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue $CorpusRoot
    New-Item -ItemType Directory -Force -Path $CorpusRoot | Out-Null
    $CorpusScenarios = @(
      [ordered]@{ name = "start-064"; map = "start" },
      [ordered]@{ name = "e1m1-064"; map = "e1m1" },
      [ordered]@{ name = "e1m2-064"; map = "e1m2" },
      [ordered]@{ name = "e1m3-064"; map = "e1m3" }
    )
    $CorpusReport = @()
    foreach ($Scenario in $CorpusScenarios) {
      $ScenarioName = [string]$Scenario.name
      $ScenarioMap = [string]$Scenario.map
      $ScenarioDirectory = Join-Path $CorpusRoot $ScenarioName
      New-Item -ItemType Directory -Force -Path $ScenarioDirectory | Out-Null
      $PrefixA = Join-Path $ScenarioDirectory "run-a"
      $PrefixB = Join-Path $ScenarioDirectory "run-b"
      [void](Run-Logged ("black-port corpus {0} trace A" -f $ScenarioName) $GameExe @("--compat-trace", $QuakeBase, $ScenarioMap, [string]$BlackPortCorpusFrames, $PrefixA, "-game", $Game) ("bp085-089r4-corpus-{0}-a.log" -f $ScenarioName))
      [void](Run-Logged ("black-port corpus {0} trace B" -f $ScenarioName) $GameExe @("--compat-trace", $QuakeBase, $ScenarioMap, [string]$BlackPortCorpusFrames, $PrefixB, "-game", $Game) ("bp085-089r4-corpus-{0}-b.log" -f $ScenarioName))
      $ComparisonJson = Join-Path $Build ("bp085-089r4-corpus-{0}-comparison.json" -f $ScenarioName)
      [void](Run-Logged ("black-port corpus {0} comparison" -f $ScenarioName) $PythonExe @($TraceComparator, ("{0}.mqtrace" -f $PrefixA), ("{0}.mqtrace" -f $PrefixB), "--json-output", $ComparisonJson) ("bp085-089r4-corpus-{0}-comparison.log" -f $ScenarioName))
      $TraceHash = (Get-FileHash -Algorithm SHA256 -LiteralPath ("{0}.mqtrace" -f $PrefixA)).Hash.ToLowerInvariant()
      $CorpusReport += [ordered]@{
        name = $ScenarioName
        map = $ScenarioMap
        frames = $BlackPortCorpusFrames
        trace_sha256 = $TraceHash
        comparison = [IO.Path]::GetFileName($ComparisonJson)
      }
    }
    $CorpusSummaryPath = Join-Path $Build "bp085-089r4-black-port-corpus-summary.json"
    [ordered]@{
      schema_version = 1
      status = "PASS"
      frames_per_scenario = $BlackPortCorpusFrames
      scenario_count = $CorpusReport.Count
      scenarios = $CorpusReport
    } | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $CorpusSummaryPath -Encoding UTF8
    Add-Step "four-map deterministic black-port corpus" "PASS" 0 ("summary=" + [IO.Path]::GetFileName($CorpusSummaryPath))
  } else {
    Add-Step "four-map deterministic black-port corpus" "SKIPPED" 0 "skipped or no Quake data"
  }

  if (-not $SkipSoak -and $CanUseGame) {
    [void](Run-Logged "5000-frame host soak" $GameExe @("--soak", $QuakeBase, $Map, [string]$SoakFrames, "-game", $Game) "bp085-089r4-host-soak.log" "result=PASS")
    $SoakPort = Get-Random -Minimum 30000 -Maximum 60000
    [void](Run-Logged "5000-frame listen-server resource soak" $GameExe @("--long-soak", "listen", $QuakeBase, $Map, [string]$ListenSoakFrames, "-game", $Game, "-port", [string]$SoakPort) "bp085-089r4-listen-soak.log" "result=PASS")
  } else {
    Add-Step "resource stability soaks" "SKIPPED" 0 "skipped or no usable Quake data"
  }

  if (-not $SkipRenderEvidence -and $CanUseGame) {
    $EvidenceDir = Join-Path $Build "bp085-089r4-render"; Remove-Item -Recurse -Force -ErrorAction SilentlyContinue $EvidenceDir; New-Item -ItemType Directory -Force -Path $EvidenceDir | Out-Null
    $EA = Join-Path $EvidenceDir "a"; $EB = Join-Path $EvidenceDir "b"
    [void](Run-Logged "render evidence A" $GameExe @("--render-evidence", $QuakeBase, $Map, [string]$RenderEvidenceFrame, $EA, "-game", $Game) "bp085-089r4-render-a.log")
    [void](Run-Logged "render evidence B" $GameExe @("--render-evidence", $QuakeBase, $Map, [string]$RenderEvidenceFrame, $EB, "-game", $Game) "bp085-089r4-render-b.log")
    [void](Run-Logged "byte-identical render evidence" $PythonExe @($RenderComparator, ("{0}.tga" -f $EA), ("{0}.tga" -f $EB), "--require-exact", "--json-out", (Join-Path $Build "bp085-089r4-render-comparison.json")) "bp085-089r4-render-comparison.log")
  } else { Add-Step "deterministic framebuffer evidence" "SKIPPED" 0 "skipped or no Quake data" }

  if (-not $SkipNetworkEvidence) {
    $PortA = Get-Random -Minimum 30000 -Maximum 45000
    $PortB = Get-Random -Minimum 45001 -Maximum 60000
    $ClientA = Run-NetworkEvidencePair "a" $PortA
    $ClientB = Run-NetworkEvidencePair "b" $PortB
    $HashA = (Get-FileHash -Algorithm SHA256 -LiteralPath $ClientA).Hash.ToLowerInvariant(); $HashB = (Get-FileHash -Algorithm SHA256 -LiteralPath $ClientB).Hash.ToLowerInvariant()
    if ($HashA -ne $HashB) { throw "network evidence client reports differ: A=$HashA B=$HashB" }
    Add-Step "two independent UDP control handshakes" "PASS" 0 ("sha256=" + $HashA)
  } else { Add-Step "two independent UDP control handshakes" "SKIPPED" 0 "-SkipNetworkEvidence" }

  if ($NetworkTests) { [void](Run-Logged "Winsock UDP loopback smoke" $GameExe @("--udp-smoke", "2000") "bp085-089r4-udp-smoke.log" "result=PASS") }
  else { Add-Step "Winsock UDP loopback smoke" "SKIPPED" 0 "-NetworkTests not supplied" }

  $Failed = @($Steps | Where-Object { $_.status -eq "FAIL" })
  if ($Failed.Count -gt 0) { throw "independent test groups failed: $($Failed.Count)" }
  Add-Step "MiniQuake BP-085-089 acceptance" "PASS" 0 "all required gates passed"
} catch {
  $Failure = $_.Exception.Message
  Write-Host ("ERROR: " + $Failure) -ForegroundColor Red
} finally {
  $Status = if ([string]::IsNullOrWhiteSpace($Failure)) { "PASS" } else { "FAIL" }
  $Summary = [ordered]@{
    schema_version = 1
    package_id = $PackageId
    parent_package_id = $ParentPackageId
    block_id = $BlockId
    block_parent_package_id = $BlockParentPackageId
    delivery_revision = $DeliveryRevision
    delivery_parent = $DeliveryParent
    network_platform_status = "network_platform_109_frozen_v1"
    network_platform_fingerprint = "0xb3ec7589"
    frontend_status = "frontend_109_frozen_v1"
    frontend_fingerprint = "0x924251fa"
    core_assets_memory_status = "core_assets_memory_109_frozen_v1"
    core_assets_memory_fingerprint = "0x6c8d974d"
    gameplay_presentation_status = "gameplay_presentation_109_frozen_v1"
    gameplay_presentation_fingerprint = "0xad91624c"
    black_port_source_status = "black_port_source_109_frozen_v1"
    black_port_source_fingerprint = "0x309b0737"
    black_port_source_target_functions = 1094
    black_port_source_missing_functions = 0
    black_port_corpus_scenarios = 4
    game_profile_status = "game_profile_109_frozen_v1"
    game_profile_fingerprint = "0x7a03b68d"
    mod_runtime_status = "mod_runtime_109_frozen_v1"
    mod_runtime_fingerprint = "0x4649813d"
    artifact_compat_status = "artifact_compat_109_frozen_v1"
    artifact_compat_fingerprint = "0x59531091"
    stability_status = "stability_109_frozen_v1"
    stability_fingerprint = "0x6c131501"
    compat_release_status = "compat_109_release_candidate_v1"
    compat_release_fingerprint = "0x29b72a98"
    pending_external_gates = @("original_binary_interop", "external_glquake_visual_reference")
    status = $Status
    failure = $Failure
    created_utc = (Get-Date).ToUniversalTime().ToString("o")
    quake_base_supplied = -not [string]::IsNullOrWhiteSpace($QuakeBase)
    steps = $Steps
  }
  $Summary | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $SummaryPath -Encoding UTF8
  Stop-Transcript | Out-Null
}

if (-not [string]::IsNullOrWhiteSpace($Failure)) {
  Write-Host "MiniQuake BP-085-089R4 acceptance test: FAIL" -ForegroundColor Red
  Write-Host "Run .\scripts\COLLECT_RESULTS.ps1 and upload the generated ZIP."
  exit 1
}
Write-Host "MiniQuake BP-085-089R4 acceptance test: PASS" -ForegroundColor Green
Write-Host "Result summary: $SummaryPath"
Write-Host "For feedback, run .\scripts\COLLECT_RESULTS.ps1 and upload the generated ZIP."
exit 0
