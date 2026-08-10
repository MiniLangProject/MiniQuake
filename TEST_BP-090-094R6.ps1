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
  [string]$OriginalQuakeSourceArchive = "",
  [string]$OriginalGLQuakeExe = "",
  [ValidateRange(1, 1000000)]
  [int]$OriginalInteropFrames = 10000,
  [ValidateRange(1, 1000000)]
  [int]$OriginalVisualFrame = 256,
  [switch]$SkipOriginalInterop,
  [switch]$SkipOriginalVisualReference,
  [switch]$SkipTemporaryFirewallRules,
  [switch]$KeepTemporaryFirewallRules,
  [switch]$ElevatedRelaunch,
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

$PackageId = "BP-094"
$ParentPackageId = "BP-093"
$BlockId = "BP-090-094"
$DeliveryRevision = "BP-090-094R6"
$DeliveryParent = "BP-090-094R5"
$BlockParentPackageId = "BP-085-089R8"
$Root = $PSScriptRoot
$Build = Join-Path $Root "build"
$BuildScript = Join-Path $Root "build.ps1"
$GameExe = Join-Path $Build "MiniQuake.exe"
$EvidenceExe = Join-Path $Build "MiniQuakeNetworkPlatformEvidence.exe"
$CoreAssetEvidenceExe = Join-Path $Build "MiniQuakeCoreAssetRetailEvidence.exe"
$ArtifactEvidenceExe = Join-Path $Build "MiniQuakeArtifactRetailEvidence.exe"
$TraceComparator = Join-Path $Root "tools\compare_traces.py"
$RenderComparator = Join-Path $Root "tools\compare_render_evidence.py"
$OriginalPrepareTool = Join-Path $Root "tools\prepare_original_reference.py"
$OriginalVisualComparator = Join-Path $Root "tools\compare_original_reference.py"
$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$TranscriptPath = Join-Path $Build ("bp090-094r6-test-{0}.log" -f $Timestamp)
$SummaryPath = Join-Path $Build "bp090-094r6-test-summary.json"
$Steps = New-Object System.Collections.Generic.List[object]
$FirewallReportPath = Join-Path $Build "bp090-094r6-temporary-firewall-rules.json"
$FirewallRulePrefix = "MiniQuake-BP090094R6-Temporary"
$FirewallDisplayGroup = "MiniQuake BP-090-094R6 temporary loopback interop"
$FirewallRuleNames = @()
$FirewallRulesInstalled = $false
$FirewallCleanupStatus = "not_installed"
$FirewallSetupStatus = "not_requested"
$FirewallSetupError = ""
$ScriptInvocationParameters = @{}
foreach ($Entry in $PSBoundParameters.GetEnumerator()) {
  $InvocationKey = [string]$Entry.Key
  $ScriptInvocationParameters[$InvocationKey] = $Entry.Value
}

function Test-IsAdministrator() {
  $Identity = [Security.Principal.WindowsIdentity]::GetCurrent()
  $Principal = New-Object Security.Principal.WindowsPrincipal($Identity)
  return $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Quote-ElevationArgument([string]$Value) {
  if ($Value -notmatch '[\s"]') { return $Value }
  $Escaped = [regex]::Replace($Value, '(\\*)"', '$1$1\"')
  $Escaped = [regex]::Replace($Escaped, '(\\+)$', '$1$1')
  return '"' + $Escaped + '"'
}

function Join-ElevationArguments([string[]]$Values) {
  return (($Values | ForEach-Object { Quote-ElevationArgument ([string]$_) }) -join ' ')
}

function Relaunch-ElevatedForInteropIfNeeded() {
  if ($SkipOriginalInterop -or $SkipTemporaryFirewallRules) { return $false }
  if (Test-IsAdministrator) { return $false }
  if ($ElevatedRelaunch) {
    throw 'INFRA_FAILURE: elevated relaunch was requested, but the current PowerShell process is not running as administrator.'
  }

  Write-Host '[MiniQuake] requesting administrator rights before the long build so temporary loopback-only firewall rules can be installed unattended' -ForegroundColor Yellow
  $Arguments = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath, '-ElevatedRelaunch')
  foreach ($Entry in $script:ScriptInvocationParameters.GetEnumerator()) {
    $Name = [string]$Entry.Key
    if ($Name -eq 'ElevatedRelaunch') { continue }
    $Value = $Entry.Value
    if ($Value -is [System.Management.Automation.SwitchParameter]) {
      if ($Value.IsPresent) { $Arguments += ('-' + $Name) }
      continue
    }
    $Arguments += ('-' + $Name)
    $Arguments += [string]$Value
  }

  $PowerShellExe = (Get-Process -Id $PID).Path
  $ArgumentText = Join-ElevationArguments $Arguments
  try {
    $Child = Start-Process -FilePath $PowerShellExe -ArgumentList $ArgumentText -WorkingDirectory $Root -Verb RunAs -Wait -PassThru
  } catch {
    throw ('INFRA_FAILURE: administrator elevation was declined or failed: ' + $_.Exception.Message)
  }
  exit [int]$Child.ExitCode
}

function Write-TemporaryFirewallReport([string]$Status, [string]$ErrorText) {
  $Rules = @()
  foreach ($RuleName in $script:FirewallRuleNames) {
    $Rules += [ordered]@{ name = $RuleName }
  }
  [ordered]@{
    schema_version = 1
    delivery_revision = 'BP-090-094R6'
    status = $Status
    elevated = [bool](Test-IsAdministrator)
    setup_status = $script:FirewallSetupStatus
    cleanup_status = $script:FirewallCleanupStatus
    error = $ErrorText
    display_group = $FirewallDisplayGroup
    rule_prefix = $FirewallRulePrefix
    protocol = 'UDP'
    local_address = '127.0.0.1'
    remote_address = '127.0.0.1'
    programs = @($GameExe, $OriginalExe)
    persistent_rules_intended = $false
    rules = $Rules
  } | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $FirewallReportPath -Encoding UTF8
}

function Remove-StaleMiniQuakeFirewallRules() {
  $Existing = @(Get-NetFirewallRule -Name ($FirewallRulePrefix + '-*') -ErrorAction SilentlyContinue)
  if ($Existing.Count -gt 0) {
    $Existing | Remove-NetFirewallRule -Confirm:$false -ErrorAction Stop
  }
}

function Install-TemporaryLoopbackFirewallRules() {
  if ($SkipOriginalInterop) {
    $script:FirewallSetupStatus = 'not_required'
    $script:FirewallCleanupStatus = 'not_required'
    Write-TemporaryFirewallReport -Status 'SKIPPED' -ErrorText ''
    return
  }
  if ($SkipTemporaryFirewallRules) {
    $script:FirewallSetupStatus = 'explicitly_skipped'
    $script:FirewallCleanupStatus = 'not_installed'
    Write-TemporaryFirewallReport -Status 'SKIPPED' -ErrorText 'caller supplied -SkipTemporaryFirewallRules'
    Add-Step 'temporary loopback firewall rules' 'SKIPPED' 0 '-SkipTemporaryFirewallRules; existing host policy must permit both exact executables'
    return
  }
  if (-not (Test-IsAdministrator)) {
    throw 'INFRA_FAILURE: temporary loopback firewall rules require an elevated PowerShell process.'
  }
  foreach ($CommandName in @('Get-NetFirewallRule', 'New-NetFirewallRule', 'Remove-NetFirewallRule')) {
    if ($null -eq (Get-Command $CommandName -ErrorAction SilentlyContinue)) {
      throw ('INFRA_FAILURE: required Windows Defender Firewall cmdlet is unavailable: ' + $CommandName)
    }
  }
  if (-not (Test-Path -LiteralPath $GameExe -PathType Leaf)) { throw ('INFRA_FAILURE: MiniQuake executable missing before firewall setup: ' + $GameExe) }
  if (-not (Test-Path -LiteralPath $OriginalExe -PathType Leaf)) { throw ('INFRA_FAILURE: original GLQuake executable missing before firewall setup: ' + $OriginalExe) }

  try {
    Remove-StaleMiniQuakeFirewallRules
    $script:FirewallRuleNames = @()
    $Specs = @(
      [ordered]@{ suffix = 'MiniQuake-In'; program = $GameExe; direction = 'Inbound' },
      [ordered]@{ suffix = 'MiniQuake-Out'; program = $GameExe; direction = 'Outbound' },
      [ordered]@{ suffix = 'GLQuake-In'; program = $OriginalExe; direction = 'Inbound' },
      [ordered]@{ suffix = 'GLQuake-Out'; program = $OriginalExe; direction = 'Outbound' }
    )
    foreach ($Spec in $Specs) {
      $RuleName = ('{0}-{1}-{2}' -f $FirewallRulePrefix, $PID, $Spec.suffix)
      New-NetFirewallRule `
        -Name $RuleName `
        -DisplayName $RuleName `
        -Group $FirewallDisplayGroup `
        -Direction $Spec.direction `
        -Action Allow `
        -Enabled True `
        -Profile Any `
        -Program $Spec.program `
        -Protocol UDP `
        -LocalAddress '127.0.0.1' `
        -RemoteAddress '127.0.0.1' `
        -ErrorAction Stop | Out-Null
      $script:FirewallRuleNames += $RuleName
    }
    foreach ($RuleName in $script:FirewallRuleNames) {
      if ($null -eq (Get-NetFirewallRule -Name $RuleName -ErrorAction SilentlyContinue)) {
        throw ('created firewall rule could not be read back: ' + $RuleName)
      }
    }
    $script:FirewallRulesInstalled = $true
    $script:FirewallSetupStatus = 'installed'
    $script:FirewallCleanupStatus = 'pending'
    Write-TemporaryFirewallReport -Status 'INSTALLED' -ErrorText ''
    Add-Step 'temporary loopback firewall rules' 'PASS' 0 ('rules=' + $script:FirewallRuleNames.Count + ' programs=2 addresses=127.0.0.1/127.0.0.1')
    Write-Host '[MiniQuake] temporary Windows Defender Firewall rules installed for exact MiniQuake/GLQUAKE paths; UDP is limited to loopback and rules will be removed in finally' -ForegroundColor Cyan
  } catch {
    $script:FirewallSetupStatus = 'failed'
    $script:FirewallSetupError = $_.Exception.Message
    try { Remove-StaleMiniQuakeFirewallRules } catch { }
    Write-TemporaryFirewallReport -Status 'FAIL' -ErrorText $script:FirewallSetupError
    throw ('INFRA_FAILURE: temporary loopback firewall rule setup failed: ' + $script:FirewallSetupError)
  }
}

function Remove-TemporaryLoopbackFirewallRules() {
  if (-not $script:FirewallRulesInstalled) { return }
  if ($KeepTemporaryFirewallRules) {
    $script:FirewallCleanupStatus = 'kept_by_request'
    Write-TemporaryFirewallReport -Status 'KEPT' -ErrorText ''
    Write-Host '[MiniQuake] temporary firewall rules retained because -KeepTemporaryFirewallRules was supplied' -ForegroundColor Yellow
    return
  }
  try {
    foreach ($RuleName in $script:FirewallRuleNames) {
      $Rule = Get-NetFirewallRule -Name $RuleName -ErrorAction SilentlyContinue
      if ($null -ne $Rule) { $Rule | Remove-NetFirewallRule -Confirm:$false -ErrorAction Stop }
    }
    $Remaining = @(Get-NetFirewallRule -Name ($FirewallRulePrefix + '-*') -ErrorAction SilentlyContinue)
    if ($Remaining.Count -gt 0) { throw ('temporary firewall rules remain after cleanup: ' + $Remaining.Count) }
    $script:FirewallRulesInstalled = $false
    $script:FirewallCleanupStatus = 'removed'
    Write-TemporaryFirewallReport -Status 'REMOVED' -ErrorText ''
    Write-Host '[MiniQuake] temporary loopback-only firewall rules removed' -ForegroundColor Green
  } catch {
    $script:FirewallCleanupStatus = 'failed'
    Write-TemporaryFirewallReport -Status 'CLEANUP_FAIL' -ErrorText $_.Exception.Message
    throw ('INFRA_FAILURE: temporary firewall rule cleanup failed: ' + $_.Exception.Message)
  }
}

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
  $StartInfo.RedirectStandardInput = $true

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
    try { $Process.WaitForExit() } catch { }
    try {
      $TimedOutStdout = [string]$Handle.stdout_task.Result
      $TimedOutStderr = [string]$Handle.stderr_task.Result
      $TimedOutEncoding = New-Object System.Text.UTF8Encoding($false)
      [System.IO.File]::WriteAllText($StdoutPath, $TimedOutStdout, $TimedOutEncoding)
      [System.IO.File]::WriteAllText($StderrPath, $TimedOutStderr, $TimedOutEncoding)
    } catch { }
    throw ("INFRA_FAILURE: {0} timed out after {1} ms; captured logs: {2}, {3}" -f $Label, $TimeoutMilliseconds, [IO.Path]::GetFileName($StdoutPath), [IO.Path]::GetFileName($StderrPath))
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
  $ServerOut = Join-Path $Build ("bp090-094r6-network-server-{0}.log" -f $Suffix)
  $ServerErr = Join-Path $Build ("bp090-094r6-network-server-{0}.err.log" -f $Suffix)
  $ClientLog = Join-Path $Build ("bp090-094r6-network-client-{0}.log" -f $Suffix)
  $PairJson = Join-Path $Build ("bp090-094r6-network-pair-{0}.json" -f $Suffix)
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

function Quote-NativeArgument([string]$Value) {
  if ($Value -notmatch '[\s"]') { return $Value }
  return '"' + ($Value -replace '"', '\"') + '"'
}

function Join-NativeArguments([string[]]$Values) {
  return (($Values | ForEach-Object { Quote-NativeArgument ([string]$_) }) -join ' ')
}

function Start-GuiProcess([string]$Executable, [string[]]$Arguments, [string]$WorkingDirectory, [string]$Label) {
  $Info = New-Object System.Diagnostics.ProcessStartInfo
  $Info.FileName = $Executable
  $Info.Arguments = Join-NativeArguments $Arguments
  $Info.WorkingDirectory = $WorkingDirectory
  $Info.UseShellExecute = $false
  $Info.CreateNoWindow = $false
  $Process = New-Object System.Diagnostics.Process
  $Process.StartInfo = $Info
  try {
    if (-not $Process.Start()) { throw 'process start returned false' }
  } catch {
    $Process.Dispose()
    throw ("INFRA_FAILURE: could not start {0}: {1}" -f $Label, $_.Exception.Message)
  }
  return $Process
}

function Stop-GuiProcess([System.Diagnostics.Process]$Process) {
  if ($null -eq $Process) { return }
  try { if (-not $Process.HasExited) { $Process.Kill() } } catch { }
  try { $Process.WaitForExit() } catch { }
  try { $Process.Dispose() } catch { }
}

function Wait-ForFileText([string]$Path, [string]$Pattern, [int]$TimeoutMilliseconds) {
  $Deadline = [DateTime]::UtcNow.AddMilliseconds($TimeoutMilliseconds)
  while ([DateTime]::UtcNow -lt $Deadline) {
    if (Test-Path -LiteralPath $Path -PathType Leaf) {
      $Text = Get-Content -LiteralPath $Path -Raw -ErrorAction SilentlyContinue
      if ($null -ne $Text -and $Text -match $Pattern) { return $true }
    }
    Start-Sleep -Milliseconds 100
  }
  return $false
}

function Read-JsonFile([string]$Path) {
  if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { throw "missing JSON report: $Path" }
  return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Stop-OriginalServer([pscustomobject]$Handle, [string]$StdoutPath, [string]$StderrPath) {
  try {
    if (-not $Handle.process.HasExited) {
      $Handle.process.StandardInput.WriteLine('quit')
      $Handle.process.StandardInput.Flush()
    }
  } catch { }
  $Exited = $false
  try { $Exited = $Handle.process.WaitForExit(2500) } catch { }
  if (-not $Exited) { Stop-BackgroundCapturedProcess $Handle }
  else { $Handle.process.WaitForExit(); $Handle.process.Refresh() }
  try {
    $Stdout = [string]$Handle.stdout_task.Result
    $Stderr = [string]$Handle.stderr_task.Result
    [IO.File]::WriteAllText($StdoutPath, $Stdout, [Text.UTF8Encoding]::new($false))
    [IO.File]::WriteAllText($StderrPath, $Stderr, [Text.UTF8Encoding]::new($false))
  } catch { }
  try { $Handle.process.Dispose() } catch { }
}

function Write-OriginalVisualConfig([string]$Path, [string]$Demo, [int]$Frame) {
  $Lines = New-Object System.Collections.Generic.List[string]
  foreach ($Line in @(
    'unbindall',
    'viewsize 100',
    'fov 90',
    'gamma 1',
    'crosshair 0',
    'gl_picmip 0',
    'gl_polyblend 1',
    'gl_ztrick 0',
    'gl_clear 1',
    'gl_finish 1',
    ('timedemo ' + $Demo)
  )) { $Lines.Add($Line) }
  for ($Index = 0; $Index -lt $Frame; $Index++) { $Lines.Add('wait') }
  $Lines.Add('screenshot')
  $Lines.Add('wait')
  $Lines.Add('quit')
  [IO.File]::WriteAllLines($Path, $Lines.ToArray(), [Text.Encoding]::ASCII)
}

function New-OriginalGameDirectory([string]$Name) {
  $Path = Join-Path $OriginalBase $Name
  Remove-Item -LiteralPath $Path -Recurse -Force -ErrorAction SilentlyContinue
  New-Item -ItemType Directory -Force -Path $Path | Out-Null
  return $Path
}

function Copy-TextArtifact([string]$Source, [string]$Destination) {
  if (Test-Path -LiteralPath $Source -PathType Leaf) {
    Copy-Item -LiteralPath $Source -Destination $Destination -Force
  }
}

function Write-NormalizedInteropSummary([string]$InputPath, [string]$Direction, [string]$OutputPath) {
  $Value = Read-JsonFile $InputPath
  if ($Direction -eq 'original_server_mini_client') {
    $Normalized = [ordered]@{
      schema_version = 1
      direction = $Direction
      success = [bool]$Value.success
      map = [string]$Value.map
      connected = [bool]$Value.connected
      spawned = [bool]$Value.spawned
      signon = [int]$Value.signon
      view_entity = [int]$Value.view_entity
      model_count = [int]$Value.model_count
      sound_count = [int]$Value.sound_count
      protocol = [int]$Value.protocol
      control_protocol = [int]$Value.control_protocol
    }
  } else {
    $Normalized = [ordered]@{
      schema_version = 1
      direction = $Direction
      success = [bool]$Value.success
      map = [string]$Value.map
      connected = [bool]$Value.connected
      spawned = [bool]$Value.spawned
      signon = [int]$Value.signon
      model_count = [int]$Value.model_count
      sound_count = [int]$Value.sound_count
      active_clients = [int]$Value.active_clients
      protocol = [int]$Value.protocol
      control_protocol = [int]$Value.control_protocol
    }
  }
  $Normalized | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $OutputPath -Encoding UTF8
  return $OutputPath
}

function Run-OriginalServerMiniClientPair([string]$Suffix, [int]$Port) {
  $GameName = 'bp091_' + $Suffix
  $GameDirectory = New-OriginalGameDirectory $GameName
  $OriginalServerOut = Join-Path $Build ("bp090-094r6-original-server-{0}-stdout.log" -f $Suffix)
  $OriginalServerErr = Join-Path $Build ("bp090-094r6-original-server-{0}-stderr.log" -f $Suffix)
  $ProcessReportPath = Join-Path $Build ("bp090-094r6-original-server-{0}-process.json" -f $Suffix)

  # Never pass -condebug to the 1997 GLQUAKE.EXE on modern OpenGL drivers.
  # console.c::Con_DebugLog owns a fixed 1024-byte buffer and uses vsprintf.
  # Modern GL_EXTENSIONS strings are commonly much longer and corrupt memory
  # before map startup. Readiness and connection evidence therefore come from
  # process lifetime plus a real Protocol-3/Protocol-15 MiniQuake handshake.
  $OriginalServerArgs = Join-NativeArguments @(
    '-listen', '4', '-basedir', $OriginalBase, '-game', $GameName,
    '-window', '-width', '640', '-height', '480', '-heapsize', '32768',
    '-nosound', '-nocdaudio', '-nojoy', '-nomouse', '-noipx',
    '-ip', '127.0.0.1', '-port', [string]$Port,
    '+developer', '1', '+unbindall', '+map', 'start'
  )
  Write-Host ("[MiniQuake] starting original GLQuake loopback-only listen server {0} on 127.0.0.1:{1} without -condebug" -f $Suffix, $Port) -ForegroundColor Cyan
  $OriginalServer = Start-BackgroundCapturedProcess -Executable $OriginalExe -ArgumentsText $OriginalServerArgs -Label ("original GLQuake listen server {0}" -f $Suffix)

  $Attempt = 0
  $AttemptLogs = @()
  $SignonComplete = $false
  $SuccessfulSummaryPath = ""
  $LastClientCode = -1
  $LastClientText = ""
  $ProcessAliveAfterSignon = $false

  try {
    # Give the original window/WGL context a short head start. Each MiniQuake
    # attempt itself performs the original three Protocol-3 retries.
    Start-Sleep -Milliseconds 750
    $Deadline = [DateTime]::UtcNow.AddMilliseconds(30000)

    while ([DateTime]::UtcNow -lt $Deadline -and -not $SignonComplete) {
      if ($OriginalServer.process.HasExited) {
        $OriginalServer.process.WaitForExit()
        $OriginalServer.process.Refresh()
        throw ("original GLQuake listen server {0} exited before Protocol-15 signon: exit={1}" -f $Suffix, [int]$OriginalServer.process.ExitCode)
      }

      $Attempt = $Attempt + 1
      $AttemptPrefix = Join-Path $Build ("bp090-094r6-miniquake-client-original-server-{0}-attempt-{1}" -f $Suffix, $Attempt)
      $AttemptLogName = "bp090-094r6-miniquake-client-original-server-{0}-attempt-{1}.log" -f $Suffix, $Attempt
      $AttemptLogPath = Join-Path $Build $AttemptLogName
      $AttemptLogs += $AttemptLogName
      Remove-Item -Force -ErrorAction SilentlyContinue ($AttemptPrefix + '-summary.json'), $AttemptLogPath

      Write-Host ("[MiniQuake] starting MiniQuake client attempt {0} for original server {1}" -f $Attempt, $Suffix) -ForegroundColor Cyan
      $ClientResult = Invoke-LiveProcess -Executable $GameExe -Arguments @(
        '--original-interop-client', $QuakeBase, '127.0.0.1', [string]$Port,
        [string]$OriginalInteropFrames, $AttemptPrefix, '-game', $Game
      ) -LogPath $AttemptLogPath

      $LastClientCode = [int]$ClientResult.exit_code
      $LastClientText = [string]$ClientResult.text
      $AttemptSummaryPath = $AttemptPrefix + '-summary.json'
      if ($LastClientCode -eq 0 -and $LastClientText -match 'result=PASS' -and (Test-Path -LiteralPath $AttemptSummaryPath -PathType Leaf)) {
        $AttemptSummary = Read-JsonFile $AttemptSummaryPath
        if ($AttemptSummary.success -and $AttemptSummary.connected -and $AttemptSummary.spawned -and [int]$AttemptSummary.signon -eq 4 -and [int]$AttemptSummary.protocol -eq 15) {
          $SignonComplete = $true
          $SuccessfulSummaryPath = $AttemptSummaryPath
          break
        }
      }

      if ([DateTime]::UtcNow -lt $Deadline) { Start-Sleep -Milliseconds 250 }
    }

    if (-not $SignonComplete) {
      $LastLine = '<none>'
      $ClientLines = @($LastClientText -split "`r?`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
      if ($ClientLines.Count -gt 0) { $LastLine = [string]$ClientLines[$ClientLines.Count - 1] }
      throw ("MiniQuake client did not complete signon with original GLQuake server {0} after {1} attempts: exit={2} last={3}" -f $Suffix, $Attempt, $LastClientCode, $LastLine)
    }

    if ($OriginalServer.process.HasExited) {
      $OriginalServer.process.WaitForExit()
      $OriginalServer.process.Refresh()
      throw ("original GLQuake listen server {0} exited immediately after signon: exit={1}" -f $Suffix, [int]$OriginalServer.process.ExitCode)
    }
    $ProcessAliveAfterSignon = $true

    $Summary = Read-JsonFile $SuccessfulSummaryPath
    $Normalized = Join-Path $Build ("bp090-094r6-original-server-mini-client-{0}-normalized.json" -f $Suffix)
    [void](Write-NormalizedInteropSummary -InputPath $SuccessfulSummaryPath -Direction 'original_server_mini_client' -OutputPath $Normalized)
    return $Normalized
  } finally {
    $AliveBeforeStop = $false
    $ExitCodeBeforeStop = $null
    try {
      $AliveBeforeStop = -not $OriginalServer.process.HasExited
      if (-not $AliveBeforeStop) {
        $OriginalServer.process.WaitForExit()
        $OriginalServer.process.Refresh()
        $ExitCodeBeforeStop = [int]$OriginalServer.process.ExitCode
      }
    } catch { }
    try {
      [ordered]@{
        schema_version = 1
        suffix = $Suffix
        port = $Port
        process_mode = 'listen_with_video_context'
        condebug_enabled = $false
        network_scope = 'loopback_only'
        bind_address = '127.0.0.1'
        firewall_prompt_expected = $false
        readiness_evidence = 'miniquake_protocol3_retry_and_protocol15_signon4'
        attempts = $Attempt
        attempt_logs = $AttemptLogs
        signon_complete = [bool]$SignonComplete
        process_alive_after_signon = [bool]$ProcessAliveAfterSignon
        process_alive_before_stop = [bool]$AliveBeforeStop
        exit_code_before_stop = $ExitCodeBeforeStop
      } | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $ProcessReportPath -Encoding UTF8
    } catch { }
    Stop-OriginalServer -Handle $OriginalServer -StdoutPath $OriginalServerOut -StderrPath $OriginalServerErr
  }
}

function Run-MiniServerOriginalClientPair([string]$Suffix, [int]$Port) {
  $Prefix = Join-Path $Build ("bp090-094r6-miniquake-server-original-client-{0}" -f $Suffix)
  $ReadyPath = $Prefix + '-ready.json'
  $ServerOut = Join-Path $Build ("bp090-094r6-miniquake-server-original-client-{0}.log" -f $Suffix)
  $ServerErr = Join-Path $Build ("bp090-094r6-miniquake-server-original-client-{0}.err.log" -f $Suffix)
  $ProcessReportPath = Join-Path $Build ("bp090-094r6-original-client-{0}-process.json" -f $Suffix)
  Remove-Item -Force -ErrorAction SilentlyContinue $ReadyPath, ($Prefix + '-summary.json')
  $ServerArgs = Join-NativeArguments @(
    '--original-interop-server', $QuakeBase, 'start', [string]$Port,
    [string]$OriginalInteropFrames, $Prefix, '-game', $Game
  )
  Write-Host ("[MiniQuake] starting MiniQuake original-client server {0} on UDP port {1}" -f $Suffix, $Port) -ForegroundColor Cyan
  $Server = Start-BackgroundCapturedProcess -Executable $GameExe -ArgumentsText $ServerArgs -Label ("MiniQuake original-client server {0}" -f $Suffix)
  $OriginalClient = $null
  $GameName = 'bp092_' + $Suffix
  $GameDirectory = New-OriginalGameDirectory $GameName
  $ClientAliveAtSignon = $false
  try {
    if (-not (Wait-ForFileText -Path $ReadyPath -Pattern '"ready"\s*:\s*true' -TimeoutMilliseconds 15000)) {
      if ($Server.process.HasExited) { throw "MiniQuake interop server $Suffix exited before readiness" }
      throw "MiniQuake interop server $Suffix did not report readiness within 15 seconds"
    }
    $ConfigName = 'interop.cfg'
    [IO.File]::WriteAllLines(
      (Join-Path $GameDirectory $ConfigName),
      @('unbindall', 'developer 1', 'name original_ref', 'color 0 0', ("connect 127.0.0.1:{0}" -f $Port)),
      [Text.Encoding]::ASCII
    )

    # -condebug is intentionally omitted. The original Con_DebugLog uses an
    # unsafe 1024-byte vsprintf buffer which modern GL extension strings exceed.
    $OriginalClient = Start-GuiProcess -Executable $OriginalExe -Arguments @(
      '-basedir', $OriginalBase, '-game', $GameName,
      '-window', '-width', '640', '-height', '480',
      '-nosound', '-nocdaudio', '-nomouse', '-nojoy', '-noipx',
      '-ip', '127.0.0.1',
      '+exec', $ConfigName
    ) -WorkingDirectory (Join-Path $OriginalStage 'bin') -Label ("original GLQuake client {0}" -f $Suffix)

    $ServerResult = Complete-BackgroundCapturedProcess -Handle $Server -TimeoutMilliseconds 45000 -StdoutPath $ServerOut -StderrPath $ServerErr
    if ([int]$ServerResult.exit_code -ne 0 -or [string]$ServerResult.stdout -notmatch 'result=PASS') {
      throw "MiniQuake original-client server $Suffix failed: exit=$($ServerResult.exit_code)"
    }
    if ($OriginalClient.HasExited) {
      $OriginalClient.WaitForExit()
      $OriginalClient.Refresh()
      throw ("original GLQuake client {0} exited before completed signon: exit={1}" -f $Suffix, [int]$OriginalClient.ExitCode)
    }
    $ClientAliveAtSignon = $true

    $SummaryPath = $Prefix + '-summary.json'
    $Summary = Read-JsonFile $SummaryPath
    if (-not $Summary.success -or [int]$Summary.active_clients -lt 1 -or -not $Summary.spawned -or [int]$Summary.signon -lt 3 -or [int]$Summary.protocol -ne 15) {
      throw "original client/MiniQuake server pair $Suffix did not prove complete signon"
    }

    [ordered]@{
      schema_version = 1
      suffix = $Suffix
      port = $Port
      condebug_enabled = $false
      network_scope = 'loopback_only'
      bind_address = '127.0.0.1'
      firewall_prompt_expected = $false
      evidence_source = 'miniquake_server_protocol15_summary'
      process_alive_at_completed_signon = [bool]$ClientAliveAtSignon
      active_clients = [int]$Summary.active_clients
      spawned = [bool]$Summary.spawned
      signon = [int]$Summary.signon
      protocol = [int]$Summary.protocol
    } | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $ProcessReportPath -Encoding UTF8

    $Normalized = Join-Path $Build ("bp090-094r6-mini-server-original-client-{0}-normalized.json" -f $Suffix)
    [void](Write-NormalizedInteropSummary -InputPath $SummaryPath -Direction 'mini_server_original_client' -OutputPath $Normalized)
    return $Normalized
  } finally {
    Stop-GuiProcess $OriginalClient
    if ($null -ne $Server -and -not $Server.process.HasExited) { Stop-BackgroundCapturedProcess $Server }
  }
}

function Run-OriginalVisualCapture([string]$Demo, [int]$Frame, [string]$Suffix, [string]$ScenarioRoot) {
  $GameName = "bp093_{0}_{1}" -f $Demo, $Suffix
  $GameDirectory = New-OriginalGameDirectory $GameName
  $ConfigName = 'visual.cfg'
  $ProcessReportPath = Join-Path $Build ("bp090-094r6-original-visual-{0}-{1}-process.json" -f $Demo, $Suffix)
  Write-OriginalVisualConfig -Path (Join-Path $GameDirectory $ConfigName) -Demo $Demo -Frame $Frame

  # Screenshot production is the evidence channel. -condebug is omitted to
  # avoid the original fixed-size debug-log overflow on modern GL drivers.
  $Process = Start-GuiProcess -Executable $OriginalExe -Arguments @(
    '-basedir', $OriginalBase, '-game', $GameName,
    '-window', '-width', '640', '-height', '480', '-gamma', '1',
    '-nosound', '-nocdaudio', '-nomouse', '-nojoy', '-noudp', '-noipx',
    '+exec', $ConfigName
  ) -WorkingDirectory (Join-Path $OriginalStage 'bin') -Label ("original visual {0}-{1}" -f $Demo, $Suffix)

  $Screenshot = ''
  $ExitedBeforeCapture = $false
  $ExitCodeBeforeCapture = $null
  try {
    $Deadline = [DateTime]::UtcNow.AddSeconds(90)
    while ([DateTime]::UtcNow -lt $Deadline) {
      $Found = Get-ChildItem -LiteralPath $GameDirectory -Filter 'quake*.tga' -File -ErrorAction SilentlyContinue | Sort-Object Name | Select-Object -First 1
      if ($null -ne $Found) { $Screenshot = $Found.FullName; break }
      if ($Process.HasExited) {
        $Process.WaitForExit()
        $Process.Refresh()
        $ExitedBeforeCapture = $true
        $ExitCodeBeforeCapture = [int]$Process.ExitCode
        break
      }
      Start-Sleep -Milliseconds 100
    }
    if ([string]::IsNullOrWhiteSpace($Screenshot)) {
      throw ("original GLQuake screenshot was not produced for {0}/{1}; exited={2} exit={3}" -f $Demo, $Suffix, $ExitedBeforeCapture, $ExitCodeBeforeCapture)
    }
    $Target = Join-Path $ScenarioRoot ("original-{0}.tga" -f $Suffix)
    Copy-Item -LiteralPath $Screenshot -Destination $Target -Force
    [ordered]@{
      schema_version = 1
      demo = $Demo
      frame = $Frame
      suffix = $Suffix
      condebug_enabled = $false
      network_scope = 'disabled'
      bind_address = ''
      firewall_prompt_expected = $false
      evidence_source = 'original_tga_screenshot'
      screenshot_produced = $true
      screenshot_name = [IO.Path]::GetFileName($Screenshot)
      process_exited_before_capture = [bool]$ExitedBeforeCapture
      exit_code_before_capture = $ExitCodeBeforeCapture
    } | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $ProcessReportPath -Encoding UTF8
    return $Target
  } finally {
    Stop-GuiProcess $Process
  }
}

[void](Relaunch-ElevatedForInteropIfNeeded)

New-Item -ItemType Directory -Force -Path $Build | Out-Null
Start-Transcript -Path $TranscriptPath -Force | Out-Null
$Failure = ""
try {
  Write-Host "MiniQuake BP-090-094R6 acceptance test"
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
    [void](Run-Logged "single cumulative build and unit-test suite" $PowerShellExe $Arguments "bp090-094r6-build-child.log" "MiniQuake BP-094 external compatibility closure tests passed: 24")
  } else {
    Add-Step "single cumulative build and unit-test suite" "SKIPPED" 0 "-SkipBuild"
  }

  foreach ($Path in @($GameExe, $EvidenceExe, $CoreAssetEvidenceExe, $ArtifactEvidenceExe)) { if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { throw "required executable missing: $Path" } }

  $Version = Run-Logged "package identity" $GameExe @("--version") "bp090-094r6-version.txt" "Compatibility release status: compat_109_release_candidate_v1"
  if ($Version -notmatch 'Package: BP-094' -or $Version -notmatch 'Parent package: BP-093' -or $Version -notmatch 'Block: BP-090-094' -or $Version -notmatch 'Block parent package: BP-085-089R8') { throw "compiled package identity mismatch" }
  if ($Version -notmatch 'Core assets/memory status: core_assets_memory_109_frozen_v1' -or $Version -notmatch 'Core assets/memory fingerprint: 0x6c8d974d') { throw "compiled core assets/memory identity mismatch" }
  if ($Version -notmatch 'Gameplay/presentation status: gameplay_presentation_109_frozen_v1' -or $Version -notmatch 'Gameplay/presentation fingerprint: 0xad91624c') { throw "compiled gameplay/presentation identity mismatch" }
  if ($Version -notmatch 'Black-port source status: black_port_source_109_frozen_v1' -or $Version -notmatch 'Black-port source fingerprint: 0x309b0737') { throw "compiled black-port source identity mismatch" }
  if ($Version -notmatch 'Game profile status: game_profile_109_frozen_v1' -or $Version -notmatch 'Game profile fingerprint: 0x7a03b68d') { throw "compiled game-profile identity mismatch" }
  if ($Version -notmatch 'Mod runtime status: mod_runtime_109_frozen_v1' -or $Version -notmatch 'Mod runtime fingerprint: 0x4649813d') { throw "compiled mod-runtime identity mismatch" }
  if ($Version -notmatch 'Artifact compatibility status: artifact_compat_109_frozen_v1' -or $Version -notmatch 'Artifact compatibility fingerprint: 0x59531091') { throw "compiled artifact identity mismatch" }
  if ($Version -notmatch 'Stability status: stability_109_frozen_v1' -or $Version -notmatch 'Stability fingerprint: 0xd0e3c03f') { throw "compiled stability identity mismatch" }
  if ($Version -notmatch 'Compatibility release status: compat_109_release_candidate_v1' -or $Version -notmatch 'Compatibility release fingerprint: 0x29b72a98') { throw "compiled release-candidate identity mismatch" }
  if ($Version -notmatch 'Original reference status: original_reference_109_candidate_v1' -or $Version -notmatch 'Original reference fingerprint: 0xdc355175') { throw "compiled original-reference identity mismatch" }
  if ($Version -notmatch 'Final compatibility status: compat_109_final_candidate_v1' -or $Version -notmatch 'Final compatibility fingerprint: 0xe04a7727') { throw "compiled final-candidate identity mismatch" }

  $CanUseGame = -not $SkipGameValidation -and -not [string]::IsNullOrWhiteSpace($QuakeBase) -and (Test-Path -LiteralPath (Join-Path $QuakeBase 'id1\pak0.pak') -PathType Leaf)

  $NeedOriginalReference = -not $SkipOriginalInterop -or -not $SkipOriginalVisualReference
  $OriginalStage = Join-Path $Build 'bp090-094r6-original-reference'
  $OriginalExe = ''
  $OriginalBase = ''
  if ($NeedOriginalReference) {
    if (-not $CanUseGame) { throw 'original reference gates require a valid -QuakeBase' }
    if ($OriginalVisualFrame -ne 256 -and -not $SkipOriginalVisualReference) { throw 'BP-093 binds the original visual reference at frame 256' }
    if ([string]::IsNullOrWhiteSpace($OriginalQuakeSourceArchive) -and [string]::IsNullOrWhiteSpace($OriginalGLQuakeExe)) {
      if (-not [string]::IsNullOrWhiteSpace($env:MINIQUAKE_ORIGINAL_SOURCE)) {
        $OriginalQuakeSourceArchive = $env:MINIQUAKE_ORIGINAL_SOURCE
      } elseif (Test-Path -LiteralPath (Join-Path $Root 'OriginalQuakeSourceCode.zip') -PathType Leaf) {
        $OriginalQuakeSourceArchive = Join-Path $Root 'OriginalQuakeSourceCode.zip'
      } elseif (Test-Path -LiteralPath (Join-Path (Split-Path -Parent $Root) 'OriginalQuakeSourceCode.zip') -PathType Leaf) {
        $OriginalQuakeSourceArchive = Join-Path (Split-Path -Parent $Root) 'OriginalQuakeSourceCode.zip'
      }
    }
    if ([string]::IsNullOrWhiteSpace($OriginalQuakeSourceArchive) -and [string]::IsNullOrWhiteSpace($OriginalGLQuakeExe)) {
      throw 'Pass -OriginalQuakeSourceArchive PATH or -OriginalGLQuakeExe PATH for BP-090 through BP-094.'
    }
    $PrepareArguments = @($OriginalPrepareTool, '--quake-base', $QuakeBase, '--stage', $OriginalStage, '--json', (Join-Path $Build 'bp090-094r6-original-reference-provenance.json'))
    if (-not [string]::IsNullOrWhiteSpace($OriginalQuakeSourceArchive)) { $PrepareArguments += @('--archive', $OriginalQuakeSourceArchive) }
    else { $PrepareArguments += @('--exe', $OriginalGLQuakeExe) }
    [void](Run-Logged 'verified original GLQuake reference' $PythonExe $PrepareArguments 'bp090-094r6-original-reference.log' 'result=PASS')
    $OriginalExe = Join-Path $OriginalStage 'bin\GLQUAKE.EXE'
    $OriginalBase = Join-Path $OriginalStage 'basedir'
    if (-not (Test-Path -LiteralPath $OriginalExe -PathType Leaf)) { throw "staged original GLQuake executable missing: $OriginalExe" }
  } else { Add-Step 'verified original GLQuake reference' 'SKIPPED' 0 'both external gates explicitly skipped' }

  Install-TemporaryLoopbackFirewallRules

  if (-not $SkipOriginalInterop) {
    $A1 = Run-OriginalServerMiniClientPair -Suffix 'a' -Port (Get-Random -Minimum 30000 -Maximum 36000)
    $A2 = Run-OriginalServerMiniClientPair -Suffix 'b' -Port (Get-Random -Minimum 36001 -Maximum 42000)
    $AHash1 = (Get-FileHash -LiteralPath $A1 -Algorithm SHA256).Hash.ToLowerInvariant()
    $AHash2 = (Get-FileHash -LiteralPath $A2 -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($AHash1 -ne $AHash2) { throw "original-server/MiniQuake-client normalized reports differ: $AHash1 vs $AHash2" }
    Add-Step 'original GLQuake server to MiniQuake client interop' 'PASS' 0 ("mode=listen condebug=false pairs=2 sha256=" + $AHash1)

    $B1 = Run-MiniServerOriginalClientPair -Suffix 'a' -Port (Get-Random -Minimum 42001 -Maximum 50000)
    $B2 = Run-MiniServerOriginalClientPair -Suffix 'b' -Port (Get-Random -Minimum 50001 -Maximum 60000)
    $BHash1 = (Get-FileHash -LiteralPath $B1 -Algorithm SHA256).Hash.ToLowerInvariant()
    $BHash2 = (Get-FileHash -LiteralPath $B2 -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($BHash1 -ne $BHash2) { throw "MiniQuake-server/original-client normalized reports differ: $BHash1 vs $BHash2" }
    Add-Step 'MiniQuake server to original GLQuake client interop' 'PASS' 0 ("pairs=2 sha256=" + $BHash1)
    Add-Step 'bidirectional original binary interop' 'PASS' 0 'two deterministic pairs in each Protocol-15 direction'
  } else { Add-Step 'bidirectional original binary interop' 'SKIPPED' 0 '-SkipOriginalInterop' }

  if (-not $SkipOriginalVisualReference) {
    $VisualRoot = Join-Path $Build 'bp090-094r6-original-visual'
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue $VisualRoot
    New-Item -ItemType Directory -Force -Path $VisualRoot | Out-Null
    $VisualResults = @()
    foreach ($DemoName in @('demo1', 'demo2', 'demo3')) {
      $Scenario = $DemoName + '-256'
      $ScenarioRoot = Join-Path $VisualRoot $Scenario
      New-Item -ItemType Directory -Force -Path $ScenarioRoot | Out-Null
      $OriginalA = Run-OriginalVisualCapture -Demo $DemoName -Frame 256 -Suffix 'a' -ScenarioRoot $ScenarioRoot
      $OriginalB = Run-OriginalVisualCapture -Demo $DemoName -Frame 256 -Suffix 'b' -ScenarioRoot $ScenarioRoot
      $OriginalHashA = (Get-FileHash -LiteralPath $OriginalA -Algorithm SHA256).Hash.ToLowerInvariant()
      $OriginalHashB = (Get-FileHash -LiteralPath $OriginalB -Algorithm SHA256).Hash.ToLowerInvariant()
      if ($OriginalHashA -ne $OriginalHashB) { throw "original GLQuake captures differ for ${Scenario}: $OriginalHashA vs $OriginalHashB" }
      Add-Step ("original GLQuake deterministic capture {0}" -f $Scenario) 'PASS' 0 ("sha256=" + $OriginalHashA)

      $Candidates = @()
      for ($Offset = -2; $Offset -le 2; $Offset++) {
        $FrameNumber = 256 + $Offset
        $Prefix = Join-Path $ScenarioRoot ("miniquake-{0}" -f $FrameNumber)
        [void](Run-Logged ("MiniQuake demo capture {0} frame {1}" -f $DemoName, $FrameNumber) $GameExe @(
          '--render-demo-evidence', $QuakeBase, $DemoName, [string]$FrameNumber, $Prefix, '-game', $Game
        ) ("bp090-094r6-{0}-frame-{1}.log" -f $DemoName, $FrameNumber) 'MiniQuake render evidence: PASS')
        $Candidates += @('--candidate', ("{0}:{1}.tga" -f $FrameNumber, $Prefix))
      }
      $VisualJson = Join-Path $ScenarioRoot 'comparison.json'
      $CompareArgs = @($OriginalVisualComparator, $OriginalA, '--scenario', $Scenario, '--min-ssim', '0.95', '--json-out', $VisualJson) + $Candidates
      [void](Run-Logged ("raw original visual comparison {0}" -f $Scenario) $PythonExe $CompareArgs ("bp090-094r6-{0}-comparison.log" -f $Scenario) 'result=PASS')
      $Comparison = Read-JsonFile $VisualJson
      if ($Comparison.status -ne 'PASS' -or [double]$Comparison.best.ssim -lt 0.95 -or $Comparison.normalization -ne 'none') { throw "original visual reference failed for $Scenario" }
      $VisualResults += [ordered]@{ scenario=$Scenario; original_sha256=$OriginalHashA; best_frame=[int]$Comparison.best.frame; ssim=[double]$Comparison.best.ssim; mae=[double]$Comparison.best.mae; psnr=[double]$Comparison.best.psnr; report=$VisualJson }
    }
    $VisualSummary = Join-Path $Build 'bp090-094r6-original-visual-summary.json'
    [ordered]@{ schema_version=1; status='PASS'; minimum_ssim=0.95; normalization='none'; scenarios=$VisualResults } | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $VisualSummary -Encoding UTF8
    Add-Step 'external GLQuake visual reference corpus' 'PASS' 0 ("scenarios=" + $VisualResults.Count + " min_ssim=0.95")
  } else { Add-Step 'external GLQuake visual reference corpus' 'SKIPPED' 0 '-SkipOriginalVisualReference' }

  if ($CanUseGame) {
    if (-not (Test-Path -LiteralPath (Join-Path $QuakeBase "id1\pak0.pak") -PathType Leaf)) { throw "Quake data not found: $QuakeBase\id1\pak0.pak" }
    [void](Run-Logged "installed Quake data validation" $GameExe @("--validate-game", $QuakeBase, $Map, "-game", $Game) "bp090-094r6-game-validation.log" "Validation result: PASS")
    [void](Run-Logged "headless runtime validation" $GameExe @("--validate-runtime", $QuakeBase, $Map, [string]$Frames, "-game", $Game) "bp090-094r6-runtime-validation.log")
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
      [void](Run-Logged ("mission-pack {0} game validation" -f $Mission) $GameExe @("--validate-game", $QuakeBase, "start", $MissionFlag) ("bp090-094r6-{0}-validation.log" -f $Mission) "Validation result: PASS")
      [void](Run-Logged ("mission-pack {0} headless runtime" -f $Mission) $GameExe @("-basedir", $QuakeBase, $MissionFlag, "-headless", "-nosound", "-maxframes", "128", "+map", "start") ("bp090-094r6-{0}-runtime.log" -f $Mission))
    }
  } else {
    Add-Step "optional mission-pack validation" "SKIPPED" 0 "skipped or no usable Quake data"
  }

  if ($CanUseGame) {
    $CoreA = Join-Path $Build "bp090-094r6-core-assets-a.log"
    $CoreB = Join-Path $Build "bp090-094r6-core-assets-b.log"
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
    $A = Join-Path $Build "bp090-094r6-audio-a.log"; $B = Join-Path $Build "bp090-094r6-audio-b.log"
    $TextA = Run-Logged "retail audio evidence A" $AudioExe @($QuakeBase, $Game) ([IO.Path]::GetFileName($A)) "MiniQuake BP-059 retail audio evidence: PASS"
    $TextB = Run-Logged "retail audio evidence B" $AudioExe @($QuakeBase, $Game) ([IO.Path]::GetFileName($B)) "MiniQuake BP-059 retail audio evidence: PASS"
    $HashA = (Get-FileHash -Algorithm SHA256 -LiteralPath $A).Hash.ToLowerInvariant(); $HashB = (Get-FileHash -Algorithm SHA256 -LiteralPath $B).Hash.ToLowerInvariant()
    if ($HashA -ne $HashB) { throw "retail audio evidence differs" }
    Add-Step "byte-identical retail audio evidence" "PASS" 0 ("sha256=" + $HashA)
  } else { Add-Step "retail audio evidence" "SKIPPED" 0 "skipped or no Quake data" }

  if (-not $SkipArtifactEvidence -and $CanUseGame) {
    $ArtifactA = Join-Path $Build "bp090-094r6-artifacts-a.log"
    $ArtifactB = Join-Path $Build "bp090-094r6-artifacts-b.log"
    $ArtifactTextA = Run-Logged "retail demo/save artifact evidence A" $ArtifactEvidenceExe @($QuakeBase, $Game, $Map) ([IO.Path]::GetFileName($ArtifactA)) "result=PASS"
    $ArtifactTextB = Run-Logged "retail demo/save artifact evidence B" $ArtifactEvidenceExe @($QuakeBase, $Game, $Map) ([IO.Path]::GetFileName($ArtifactB)) "result=PASS"
    foreach ($ArtifactText in @($ArtifactTextA, $ArtifactTextB)) {
      if ($ArtifactText -notmatch 'first_pass_exact=true' -or
          $ArtifactText -notmatch 'semantic=true' -or
          $ArtifactText -notmatch 'stable_exact=true' -or
          $ArtifactText -notmatch 'stable_semantic=true' -or
          $ArtifactText -notmatch 'save_float_format=4097:4097\.000000 negative:-4097\.000000' -or
          $ArtifactText -notmatch 'save_float_parse=-0\.000000:80000000') {
        throw "retail artifact evidence did not prove exact, semantic, stable, signed-zero and overflow-safe save roundtrip"
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
    $TraceDir = Join-Path $Build "bp090-094r6-traces"; Remove-Item -Recurse -Force -ErrorAction SilentlyContinue $TraceDir; New-Item -ItemType Directory -Force -Path $TraceDir | Out-Null
    $PrefixA = Join-Path $TraceDir "run-a"; $PrefixB = Join-Path $TraceDir "run-b"
    [void](Run-Logged "compatibility trace A" $GameExe @("--compat-trace", $QuakeBase, $Map, [string]$TraceFrames, $PrefixA, "-game", $Game) "bp090-094r6-trace-a.log")
    [void](Run-Logged "compatibility trace B" $GameExe @("--compat-trace", $QuakeBase, $Map, [string]$TraceFrames, $PrefixB, "-game", $Game) "bp090-094r6-trace-b.log")
    [void](Run-Logged "byte-identical trace comparison" $PythonExe @($TraceComparator, ("{0}.mqtrace" -f $PrefixA), ("{0}.mqtrace" -f $PrefixB), "--json-output", (Join-Path $Build "bp090-094r6-trace-comparison.json")) "bp090-094r6-trace-comparison.log")
  } else { Add-Step "deterministic compatibility traces" "SKIPPED" 0 "skipped or no Quake data" }

  if (-not $SkipBlackPortCorpus -and $CanUseGame) {
    $CorpusRoot = Join-Path $Build "bp090-094r6-black-port-corpus"
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
      [void](Run-Logged ("black-port corpus {0} trace A" -f $ScenarioName) $GameExe @("--compat-trace", $QuakeBase, $ScenarioMap, [string]$BlackPortCorpusFrames, $PrefixA, "-game", $Game) ("bp090-094r6-corpus-{0}-a.log" -f $ScenarioName))
      [void](Run-Logged ("black-port corpus {0} trace B" -f $ScenarioName) $GameExe @("--compat-trace", $QuakeBase, $ScenarioMap, [string]$BlackPortCorpusFrames, $PrefixB, "-game", $Game) ("bp090-094r6-corpus-{0}-b.log" -f $ScenarioName))
      $ComparisonJson = Join-Path $Build ("bp090-094r6-corpus-{0}-comparison.json" -f $ScenarioName)
      [void](Run-Logged ("black-port corpus {0} comparison" -f $ScenarioName) $PythonExe @($TraceComparator, ("{0}.mqtrace" -f $PrefixA), ("{0}.mqtrace" -f $PrefixB), "--json-output", $ComparisonJson) ("bp090-094r6-corpus-{0}-comparison.log" -f $ScenarioName))
      $TraceHash = (Get-FileHash -Algorithm SHA256 -LiteralPath ("{0}.mqtrace" -f $PrefixA)).Hash.ToLowerInvariant()
      $CorpusReport += [ordered]@{
        name = $ScenarioName
        map = $ScenarioMap
        frames = $BlackPortCorpusFrames
        trace_sha256 = $TraceHash
        comparison = [IO.Path]::GetFileName($ComparisonJson)
      }
    }
    $CorpusSummaryPath = Join-Path $Build "bp090-094r6-black-port-corpus-summary.json"
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
    [void](Run-Logged "5000-frame host soak" $GameExe @("--soak", $QuakeBase, $Map, [string]$SoakFrames, "-game", $Game) "bp090-094r6-host-soak.log" "result=PASS")
    $SoakPort = Get-Random -Minimum 30000 -Maximum 60000
    [void](Run-Logged "5000-frame listen-server resource soak" $GameExe @("--long-soak", "listen", $QuakeBase, $Map, [string]$ListenSoakFrames, "-game", $Game, "-port", [string]$SoakPort) "bp090-094r6-listen-soak.log" "result=PASS")
  } else {
    Add-Step "resource stability soaks" "SKIPPED" 0 "skipped or no usable Quake data"
  }

  if (-not $SkipRenderEvidence -and $CanUseGame) {
    $EvidenceDir = Join-Path $Build "bp090-094r6-render"; Remove-Item -Recurse -Force -ErrorAction SilentlyContinue $EvidenceDir; New-Item -ItemType Directory -Force -Path $EvidenceDir | Out-Null
    $EA = Join-Path $EvidenceDir "a"; $EB = Join-Path $EvidenceDir "b"
    [void](Run-Logged "render evidence A" $GameExe @("--render-evidence", $QuakeBase, $Map, [string]$RenderEvidenceFrame, $EA, "-game", $Game) "bp090-094r6-render-a.log")
    [void](Run-Logged "render evidence B" $GameExe @("--render-evidence", $QuakeBase, $Map, [string]$RenderEvidenceFrame, $EB, "-game", $Game) "bp090-094r6-render-b.log")
    [void](Run-Logged "byte-identical render evidence" $PythonExe @($RenderComparator, ("{0}.tga" -f $EA), ("{0}.tga" -f $EB), "--require-exact", "--json-out", (Join-Path $Build "bp090-094r6-render-comparison.json")) "bp090-094r6-render-comparison.log")
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

  if ($NetworkTests) { [void](Run-Logged "Winsock UDP loopback smoke" $GameExe @("--udp-smoke", "2000") "bp090-094r6-udp-smoke.log" "result=PASS") }
  else { Add-Step "Winsock UDP loopback smoke" "SKIPPED" 0 "-NetworkTests not supplied" }

  $Failed = @($Steps | Where-Object { $_.status -eq "FAIL" })
  if ($Failed.Count -gt 0) { throw "independent test groups failed: $($Failed.Count)" }
  if ($SkipOriginalInterop -or $SkipOriginalVisualReference) {
    throw "final BP-090-094R6 acceptance requires original binary interop and external GLQuake visual-reference gates"
  }
  Add-Step "MiniQuake BP-090-094R6 acceptance" "PASS" 0 "all internal and external gates passed"
} catch {
  $Failure = $_.Exception.Message
  Write-Host ("ERROR: " + $Failure) -ForegroundColor Red
} finally {
  try {
    Remove-TemporaryLoopbackFirewallRules
  } catch {
    $CleanupFailure = $_.Exception.Message
    Write-Host ("ERROR: " + $CleanupFailure) -ForegroundColor Red
    if ([string]::IsNullOrWhiteSpace($Failure)) { $Failure = $CleanupFailure }
    else { $Failure = $Failure + "; " + $CleanupFailure }
  }
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
    stability_fingerprint = "0xd0e3c03f"
    compat_release_status = "compat_109_release_candidate_v1"
    compat_release_fingerprint = "0x29b72a98"
    original_reference_status = "original_reference_109_candidate_v1"
    original_reference_fingerprint = "0xdc355175"
    compat_final_status = "compat_109_final_candidate_v1"
    compat_final_fingerprint = "0xe04a7727"
    external_gates_required = @("original_binary_interop", "external_glquake_visual_reference")
    original_server_mode = "listen_with_video_context"
    original_network_scope = "loopback_only"
    original_bind_address = "127.0.0.1"
    original_visual_network = "disabled"
    unattended_firewall_prompt_expected = $false
    temporary_firewall_rules = if ($SkipTemporaryFirewallRules) { "skipped_by_request" } elseif ($SkipOriginalInterop) { "not_required" } else { "exact_program_loopback_udp" }
    temporary_firewall_rule_report = [IO.Path]::GetFileName($FirewallReportPath)
    temporary_firewall_setup_status = $FirewallSetupStatus
    temporary_firewall_cleanup_status = $FirewallCleanupStatus
    original_condebug_enabled = $false
    original_evidence_mode = "protocol_summaries_and_screenshot_files"
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
  Write-Host "MiniQuake BP-090-094R6 acceptance test: FAIL" -ForegroundColor Red
  Write-Host "Run .\COLLECT_RESULTS.ps1 and upload the generated ZIP."
  exit 1
}
Write-Host "MiniQuake BP-090-094R6 acceptance test: PASS" -ForegroundColor Green
Write-Host "Result summary: $SummaryPath"
Write-Host "For feedback, run .\COLLECT_RESULTS.ps1 and upload the generated ZIP."
exit 0
