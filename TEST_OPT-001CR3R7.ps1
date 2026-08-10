[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string]$Compiler,
  [Parameter(Mandatory = $true)]
  [string]$StdLib,
  [Parameter(Mandatory = $true)]
  [string]$QuakeBase,
  [string]$Game = "id1",
  [int]$MatrixFrames = 64,
  [int]$WarmupFrames = 300,
  [int]$BenchmarkFrames = 3000,
  [int]$HandleWarmupFrames = 1200,
  [int]$HandleWindowFrames = 5000,
  [int]$HandleWindows = 3,
  [int]$HandleConfirmationWindows = 2,
  [int]$E1M2VisibleFrames = 1500,
  [int]$E1M2HeadlessFrames = 10000,
  [int]$TransitionFrames = 256,
  [int]$ListenPort = 0,
  [switch]$SkipBuild,
  [switch]$SkipTemporaryFirewallRules,
  [switch]$ContinueIndependentTests
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
$env:PYTHONUNBUFFERED = "1"

$Root = $PSScriptRoot
$Build = Join-Path $Root "build"
$GameExe = Join-Path $Build "MiniQuake.exe"
$ContractExe = Join-Path $Build "MiniQuakeOPT001CAllocationTests.exe"
$HotpathExe = Join-Path $Build "MiniQuakeOPT001CR3HotpathTests.exe"
$DeliveryRevision = "OPT-001CR3R7"
$DeliveryParent = "OPT-001CR3R6"
$SummaryPath = Join-Path $Build "opt001cr3r7-test-summary.json"
$LiveProcessRunner = Join-Path $Root "tools\run_process_live.py"
$EffectiveHandleWindows = $HandleWindows + $HandleConfirmationWindows
$Steps = @()
$Failures = 0
$FirewallRules = @()


function Get-FreeUdpPort {
  $Client = New-Object System.Net.Sockets.UdpClient
  try {
    $Client.Client.Bind((New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Loopback, 0)))
    return [int]([System.Net.IPEndPoint]$Client.Client.LocalEndPoint).Port
  }
  finally {
    $Client.Dispose()
  }
}

function Test-IsAdministrator {
  $Identity = [Security.Principal.WindowsIdentity]::GetCurrent()
  $Principal = New-Object Security.Principal.WindowsPrincipal($Identity)
  return $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Add-Step([string]$Name, [string]$Status, [int]$ExitCode, [string]$Log) {
  $script:Steps += [pscustomobject]@{ name=$Name; status=$Status; exit_code=$ExitCode; log=$Log }
  if ($Status -eq "FAIL") { $script:Failures += 1 }
  $Colour = "Gray"
  if ($Status -eq "PASS") { $Colour = "Green" }
  if ($Status -eq "FAIL") { $Colour = "Red" }
  if ($Status -eq "SKIPPED" -or $Status -eq "DIAGNOSTIC") { $Colour = "Yellow" }
  Write-Host ("[{0}] {1}" -f $Status, $Name) -ForegroundColor $Colour
}

function Show-LogTail([string]$LogPath, [int]$Lines = 80) {
  if (-not (Test-Path -LiteralPath $LogPath -PathType Leaf)) {
    Write-Host ("[MiniQuake/OPT-001CR3R7] log was not created: {0}" -f $LogPath) -ForegroundColor Red
    return
  }
  Write-Host ("[MiniQuake/OPT-001CR3R7] last {0} log lines:" -f $Lines) -ForegroundColor Yellow
  Get-Content -LiteralPath $LogPath -Tail $Lines | ForEach-Object {
    Write-Host $_ -ForegroundColor DarkYellow
  }
}

function Invoke-ExternalProcessLive(
  [string]$Name,
  [string]$Executable,
  [string[]]$Arguments,
  [string]$LogName,
  [switch]$AllowFailure
) {
  $LogPath = Join-Path $Build $LogName
  Write-Host ("[MiniQuake/OPT-001CR3R7] starting {0}" -f $Name) -ForegroundColor Cyan
  Write-Host ("  executable={0}" -f $Executable)
  Write-Host ("  arguments={0}" -f ($Arguments -join " "))
  Write-Host "  output_mode=python_binary_passthrough_named_build_binding"
  Write-Host ("  log={0}" -f $LogPath)

  $StatusPath = $LogPath + ".status.json"
  Remove-Item -Force -ErrorAction SilentlyContinue -LiteralPath $StatusPath
  $RunnerArguments = @(
    "-u", $LiveProcessRunner,
    "--log", $LogPath,
    "--status-json", $StatusPath,
    "--cwd", $Root,
    "--", $Executable
  )
  $RunnerArguments += $Arguments

  # Consume native output through Out-Host so the function return stream stays
  # scalar.  Temporarily relax ErrorActionPreference because Windows
  # PowerShell 5.1 otherwise turns a native stderr line into a terminating
  # NativeCommandError before the live runner can write its status JSON.
  $SavedErrorActionPreference = $ErrorActionPreference
  try {
    $ErrorActionPreference = "Continue"
    & $PythonExe @RunnerArguments 2>&1 | Out-Host
    $RunnerExitCode = [int]$LASTEXITCODE
  }
  finally {
    $ErrorActionPreference = $SavedErrorActionPreference
  }

  $Code = $RunnerExitCode
  if (Test-Path -LiteralPath $StatusPath -PathType Leaf) {
    $Status = Get-Content -Raw -LiteralPath $StatusPath | ConvertFrom-Json
    $Code = [int]$Status.exit_code
    if (-not [string]::IsNullOrWhiteSpace([string]$Status.error)) {
      Write-Host "[MiniQuake/OPT-001CR3R7] live-runner diagnostic:" -ForegroundColor Red
      Write-Host ([string]$Status.error) -ForegroundColor DarkRed
    }
  }
  elseif ($RunnerExitCode -eq 0) {
    $Code = 125
    Write-Host "[MiniQuake/OPT-001CR3R7] live runner returned 0 but did not create its status JSON." -ForegroundColor Red
  }
  if ($Code -eq 0) {
    Add-Step $Name "PASS" $Code $LogName
  } elseif ($AllowFailure) {
    Add-Step $Name "DIAGNOSTIC" $Code $LogName
  } else {
    Add-Step $Name "FAIL" $Code $LogName
    Show-LogTail $LogPath
    if (-not $ContinueIndependentTests) {
      throw ("{0} failed with exit code {1}" -f $Name, $Code)
    }
  }
  return [int]$Code
}

function Invoke-LiveBuild(
  [string]$Name,
  [string]$ScriptPath,
  [string]$LogName
) {
  # Pass each build parameter as a real named PowerShell -File argument.
  # Do not array-splat strings into build.ps1: array splatting is positional and
  # caused the StdLib path to be bound to Configuration in CR3R2.
  $Code = Invoke-ExternalProcessLive $Name $PowerShellExe @(
    "-NoLogo",
    "-NoProfile",
    "-NonInteractive",
    "-ExecutionPolicy", "Bypass",
    "-File", $ScriptPath,
    "-Compiler", $Compiler,
    "-StdLib", $StdLib,
    "-Configuration", "Release",
    "-NoRunTests",
    "-SkipPreflight"
  ) $LogName -AllowFailure
  return [int]$Code
}

function Invoke-Live(
  [string]$Name,
  [string]$Executable,
  [string[]]$Arguments,
  [string]$LogName,
  [switch]$AllowFailure
) {
  $Code = Invoke-ExternalProcessLive $Name $Executable $Arguments $LogName -AllowFailure:$AllowFailure
  return [int]$Code
}

function Install-LoopbackFirewallRules {
  if ($SkipTemporaryFirewallRules) {
    Write-Host "[MiniQuake/OPT-001CR3R7] temporary loopback firewall rules explicitly skipped" -ForegroundColor Yellow
    return
  }
  if (-not (Test-IsAdministrator)) {
    throw "OPT-001CR3R7 listen-server measurement requires elevated PowerShell for unattended temporary loopback firewall rules. Start PowerShell as Administrator or pass -SkipTemporaryFirewallRules."
  }
  foreach ($Command in @("New-NetFirewallRule", "Remove-NetFirewallRule")) {
    if ($null -eq (Get-Command $Command -ErrorAction SilentlyContinue)) {
      throw "Windows Defender Firewall cmdlet unavailable: $Command"
    }
  }
  $Prefix = "MiniQuake-OPT001C-$PID"
  foreach ($Direction in @("Inbound", "Outbound")) {
    $Name = "$Prefix-$Direction"
    New-NetFirewallRule `
      -Name $Name `
      -DisplayName $Name `
      -Direction $Direction `
      -Action Allow `
      -Program $GameExe `
      -Protocol UDP `
      -LocalAddress 127.0.0.1 `
      -RemoteAddress 127.0.0.1 `
      -Profile Any | Out-Null
    $script:FirewallRules += $Name
  }
  Write-Host "[MiniQuake/OPT-001CR3R7] temporary loopback firewall rules installed: 2" -ForegroundColor Green
}

function Remove-LoopbackFirewallRules {
  foreach ($Name in $script:FirewallRules) {
    Remove-NetFirewallRule -Name $Name -Confirm:$false -ErrorAction SilentlyContinue
  }
  if ($script:FirewallRules.Count -gt 0) {
    Write-Host "[MiniQuake/OPT-001CR3R7] temporary loopback firewall rules removed" -ForegroundColor Green
  }
}

function Write-Summary([string]$Overall, [string]$HandleClassification, [string]$PerformanceClassification) {
  [ordered]@{
    schema = "MiniQuakeOPT001CR3R6TestSummary/1"
    delivery_revision = $DeliveryRevision
    delivery_parent = $DeliveryParent
    overall = $Overall
    failures = $Failures
    handle_classification = $HandleClassification
    performance_classification = $PerformanceClassification
    matrix_frames = $MatrixFrames
    warmup_frames = $WarmupFrames
    benchmark_frames = $BenchmarkFrames
    handle_warmup_frames = $HandleWarmupFrames
    handle_window_frames = $HandleWindowFrames
    handle_windows_requested = $HandleWindows
    handle_confirmation_windows = $HandleConfirmationWindows
    handle_windows_effective = $EffectiveHandleWindows
    e1m2_visible_frames = $E1M2VisibleFrames
    e1m2_headless_frames = $E1M2HeadlessFrames
    transition_frames = $TransitionFrames
    maps = @("e1m1", "e1m2")
    steps = $Steps
  } | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $SummaryPath -Encoding UTF8
}

New-Item -ItemType Directory -Force -Path $Build | Out-Null
if (-not (Test-Path -LiteralPath $LiveProcessRunner -PathType Leaf)) { throw "live process runner missing: $LiveProcessRunner" }
$Compiler = [IO.Path]::GetFullPath($Compiler)
$StdLib = [IO.Path]::GetFullPath($StdLib)
$QuakeBase = [IO.Path]::GetFullPath($QuakeBase)

if ($HandleWindows -lt 3) { throw "HandleWindows must be at least 3" }
if ($HandleConfirmationWindows -lt 1) { throw "HandleConfirmationWindows must be at least 1" }

if (-not (Test-Path -LiteralPath $Compiler -PathType Leaf)) { throw "MiniLang compiler not found: $Compiler" }
if (-not (Test-Path -LiteralPath (Join-Path $StdLib "std\fs.ml") -PathType Leaf)) { throw "MiniLang stdlib root invalid: $StdLib" }
if (-not (Test-Path -LiteralPath (Join-Path $QuakeBase "$Game\pak0.pak") -PathType Leaf)) { throw "Quake pak0.pak not found below: $QuakeBase\$Game" }

$PythonExe = (Get-Command python -ErrorAction Stop | Select-Object -First 1).Path
$PowerShellExe = (Get-Process -Id $PID).Path
if ($ListenPort -le 0) { $ListenPort = Get-FreeUdpPort }

Write-Host "MiniQuake OPT-001CR3R7 acceptance test"
Write-Host "  parent: $DeliveryParent"
Write-Host "  root:   $Root"
Write-Host "  maps:   e1m1, e1m2"
Write-Host "  benchmark: warmup=$WarmupFrames measure=$BenchmarkFrames"
Write-Host "  handles: warmup=$HandleWarmupFrames requested=$HandleWindows confirmation=$HandleConfirmationWindows effective=$EffectiveHandleWindows x $HandleWindowFrames port=$ListenPort"
Write-Host "  inherited correctness e1m2: visible=$E1M2VisibleFrames headless=$E1M2HeadlessFrames transition=$TransitionFrames"

try {
  $PackageVerifyCode = Invoke-Live "OPT-001CR3R7 package verification" $PythonExe @(
    (Join-Path $Root "tools\verify.py"), "--root", $Root,
    "--json", (Join-Path $Build "opt001cr3r7-package-verification.json")
  ) "opt001cr3r7-package-verification.log"
  if ($PackageVerifyCode -is [array]) {
    throw "internal harness error: package verifier returned multiple pipeline objects"
  }
  $PackageVerifyCode = [int]$PackageVerifyCode
  if ($PackageVerifyCode -ne 0) {
    Write-Summary "FAIL" "UNKNOWN" "UNKNOWN"
    Write-Host "MiniQuake OPT-001CR3R7 acceptance test: FAIL" -ForegroundColor Red
    exit 2
  }

  if (-not $SkipBuild) {
    $BuildCode = Invoke-LiveBuild `
      "OPT-001CR3R7 game and contract build" `
      (Join-Path $Root "build.ps1") `
      "opt001cr3r7-build.log"
  } else {
    if (-not (Test-Path -LiteralPath $GameExe -PathType Leaf)) { throw "-SkipBuild requested but MiniQuake.exe is missing" }
    if (-not (Test-Path -LiteralPath $ContractExe -PathType Leaf)) { throw "-SkipBuild requested but contract test executable is missing" }
    Add-Step "OPT-001CR3R7 game and contract build" "SKIPPED" 0 "-SkipBuild"
  }

  if (-not $SkipBuild -and $BuildCode -ne 0) {
    Add-Step "OPT-001CR3R7 allocation contract tests" "SKIPPED" 0 "dependent tests skipped because build failed"
    Add-Step "OPT-001CR3R7 inline/array hotpath tests" "SKIPPED" 0 "dependent tests skipped because build failed"
    Write-Summary "FAIL" "UNKNOWN" "UNKNOWN"
    Write-Host "ERROR: build failed; all executable-dependent tests were skipped." -ForegroundColor Red
    Write-Host "MiniQuake OPT-001CR3R7 acceptance test: FAIL" -ForegroundColor Red
    exit 2
  }
  foreach ($RequiredExe in @($GameExe, $ContractExe, $HotpathExe)) {
    if (-not (Test-Path -LiteralPath $RequiredExe -PathType Leaf)) {
      Add-Step "OPT-001CR3R7 required executable" "FAIL" 1 $RequiredExe
      Write-Summary "FAIL" "UNKNOWN" "UNKNOWN"
      Write-Host ("ERROR: required executable missing after successful build: {0}" -f $RequiredExe) -ForegroundColor Red
      Write-Host "MiniQuake OPT-001CR3R7 acceptance test: FAIL" -ForegroundColor Red
      exit 2
    }
  }

  [void](Invoke-Live "OPT-001CR3R7 allocation contract tests" $ContractExe @() "opt001cr3r7-allocation-tests.log")
  [void](Invoke-Live "OPT-001CR3R7 inline/array hotpath tests" $HotpathExe @() "opt001cr3r7-hotpath-tests.log")
  Install-LoopbackFirewallRules

  foreach ($Map in @("e1m1", "e1m2")) {
    $MapPrefix = Join-Path $Build ("opt001cr3r7-{0}" -f $Map)
    [void](Invoke-Live "$Map BSP parse" $GameExe @(
      "--opt001a-map-parse", $QuakeBase, $Map, $MapPrefix, "-game", $Game
    ) ("opt001cr3r7-{0}-map-parse.log" -f $Map))
    [void](Invoke-Live "$Map runtime smoke" $GameExe @(
      "--runtime-smoke", $QuakeBase, $Map, [string]$MatrixFrames, "-game", $Game
    ) ("opt001cr3r7-{0}-runtime-smoke.log" -f $Map))
    [void](Invoke-Live "$Map render smoke" $GameExe @(
      "--render-smoke", $QuakeBase, $Map, [string]$MatrixFrames, "-game", $Game
    ) ("opt001cr3r7-{0}-render-smoke.log" -f $Map))

    $TraceA = Join-Path $Build ("opt001cr3r7-{0}-trace-a" -f $Map)
    $TraceB = Join-Path $Build ("opt001cr3r7-{0}-trace-b" -f $Map)
    [void](Invoke-Live "$Map trace A" $GameExe @(
      "--compat-trace", $QuakeBase, $Map, [string]$MatrixFrames, $TraceA, "-game", $Game
    ) ("opt001cr3r7-{0}-trace-a.log" -f $Map))
    [void](Invoke-Live "$Map trace B" $GameExe @(
      "--compat-trace", $QuakeBase, $Map, [string]$MatrixFrames, $TraceB, "-game", $Game
    ) ("opt001cr3r7-{0}-trace-b.log" -f $Map))
    [void](Invoke-Live "$Map trace comparison" $PythonExe @(
      (Join-Path $Root "tools\compare_traces.py"), ($TraceA + ".mqtrace"), ($TraceB + ".mqtrace"),
      "--json-output", (Join-Path $Build ("opt001cr3r7-{0}-trace-comparison.json" -f $Map))
    ) ("opt001cr3r7-{0}-trace-comparison.log" -f $Map))

    foreach ($Mode in @("headless", "render")) {
      $Prefix = Join-Path $Build ("opt001cr3r7-{0}-{1}" -f $Map, $Mode)
      [void](Invoke-Live "$Map $Mode frame baseline" $GameExe @(
        "--opt001a-frame-baseline", $QuakeBase, $Map, $Mode,
        [string]$WarmupFrames, [string]$BenchmarkFrames, $Prefix, "-game", $Game
      ) ("opt001cr3r7-{0}-{1}-baseline.log" -f $Map, $Mode))
    }
  }

  $VisiblePrefix = Join-Path $Build "opt001cr3r7-e1m2-visible"
  [void](Invoke-Live "OPT-001CR3R7 e1m2 visible validation" $GameExe @(
    "--render-evidence", $QuakeBase, "e1m2", [string]$E1M2VisibleFrames, $VisiblePrefix, "-game", $Game
  ) "opt001cr3r7-e1m2-visible.log")

  [void](Invoke-Live "OPT-001CR3R7 e1m2 headless validation" $GameExe @(
    "--runtime-smoke", $QuakeBase, "e1m2", [string]$E1M2HeadlessFrames, "-game", $Game
  ) "opt001cr3r7-e1m2-headless.log")

  $TransitionPrefix = Join-Path $Build "opt001cr3r7-transition"
  [void](Invoke-Live "OPT-001CR3R7 e1m1-e1m2-e1m1 transition" $GameExe @(
    "--opt001b-transition", $QuakeBase, [string]$TransitionFrames, $TransitionPrefix, "-game", $Game
  ) "opt001cr3r7-transition.log")

  $PlateauPrefix = Join-Path $Build "opt001cr3r7-listen-handle-plateau"
  [void](Invoke-Live "listen-server handle plateau" $GameExe @(
    "--opt001a-handle-plateau", $QuakeBase, "start",
    [string]$HandleWarmupFrames, [string]$HandleWindowFrames, [string]$EffectiveHandleWindows,
    $PlateauPrefix, "-game", $Game, "-port", [string]$ListenPort
  ) "opt001cr3r7-handle-plateau.log" -AllowFailure)

  [void](Invoke-Live "OPT-001CR3R7 aggregate analysis" $PythonExe @(
    (Join-Path $Root "tools\analyze_opt001a.py"), "--build", $Build,
    "--prefix", "opt001cr3r7", "--next-revision", "OPT-001D",
    "--json", (Join-Path $Build "opt001cr3r7-baseline-summary.json"),
    "--markdown", (Join-Path $Build "opt001cr3r7-baseline-summary.md")
  ) "opt001cr3r7-aggregate-analysis.log" -AllowFailure)

  $PerformanceJson = Join-Path $Build "opt001cr3r7-performance-comparison.json"
  [void](Invoke-Live "OPT-001CR3R7 performance comparison" $PythonExe @(
    (Join-Path $Root "tools\compare_opt001c_performance.py"),
    "--baseline", (Join-Path $Root "audit\opt001b_performance_baseline.json"),
    "--build", $Build,
    "--prefix", "opt001cr3r7",
    "--json", $PerformanceJson,
    "--markdown", (Join-Path $Build "opt001cr3r7-performance-comparison.md")
  ) "opt001cr3r7-performance-comparison.log")

  [void](Invoke-Live "OPT-001CR3R7 incremental performance comparison" $PythonExe @(
    (Join-Path $Root "tools\compare_opt001cr3_performance.py"),
    "--baseline", (Join-Path $Root "audit\opt001cr2_accepted_baseline.json"),
    "--build", $Build,
    "--prefix", "opt001cr3r7",
    "--json", (Join-Path $Build "opt001cr3r7-incremental-performance.json"),
    "--markdown", (Join-Path $Build "opt001cr3r7-incremental-performance.md")
  ) "opt001cr3r7-incremental-performance.log" -AllowFailure)

  [void](Invoke-Live "OPT-001CR3R7 audio cost analysis" $PythonExe @(
    (Join-Path $Root "tools\analyze_opt001cr3r7_audio.py"),
    "--build", $Build,
    "--prefix", "opt001cr3r7",
    "--json", (Join-Path $Build "opt001cr3r7-audio-analysis.json")
  ) "opt001cr3r7-audio-analysis.log" -AllowFailure)

  $HandleClassification = "UNKNOWN"
  $PlateauSummary = $PlateauPrefix + "-summary.json"
  if (Test-Path -LiteralPath $PlateauSummary -PathType Leaf) {
    $HandleClassification = [string]((Get-Content -Raw -LiteralPath $PlateauSummary | ConvertFrom-Json).classification)
  }
  $PerformanceClassification = "UNKNOWN"
  if (Test-Path -LiteralPath $PerformanceJson -PathType Leaf) {
    $PerformanceClassification = [string]((Get-Content -Raw -LiteralPath $PerformanceJson | ConvertFrom-Json).classification)
  }
  $Overall = "PASS"
  if ($Failures -gt 0) { $Overall = "FAIL" }
  if ($Overall -eq "PASS" -and $HandleClassification -eq "LEAK") { $Overall = "LEAK" }
  if ($Overall -eq "PASS" -and $HandleClassification -eq "INCONCLUSIVE") { $Overall = "INCONCLUSIVE" }
  if ($Overall -eq "PASS" -and $HandleClassification -eq "RESOURCE_GROWTH") { $Overall = "FAIL" }
  Write-Summary $Overall $HandleClassification $PerformanceClassification

  Write-Host ""
  Write-Host "MiniQuake OPT-001CR3R7 summary"
  Write-Host "  handle_classification=$HandleClassification"
  Write-Host "  performance_classification=$PerformanceClassification"
  Write-Host "  failures=$Failures"
  Write-Host "  summary=$SummaryPath"
  if ($Overall -eq "PASS") {
    Write-Host "MiniQuake OPT-001CR3R7 acceptance test: PASS" -ForegroundColor Green
    exit 0
  }
  Write-Host ("MiniQuake OPT-001CR3R7 acceptance test: {0}" -f $Overall) -ForegroundColor Red
  exit 2
}
catch {
  $HarnessDetail = ($_ | Out-String).Trim()
  if (-not [string]::IsNullOrWhiteSpace($_.ScriptStackTrace)) {
    $HarnessDetail = $HarnessDetail + "`nPowerShell stack:`n" + $_.ScriptStackTrace
  }
  Add-Step "OPT-001CR3R7 harness" "FAIL" 1 $HarnessDetail
  Write-Summary "FAIL" "UNKNOWN" "UNKNOWN"
  Write-Host "ERROR: OPT-001CR3R7 harness failure" -ForegroundColor Red
  Write-Host $HarnessDetail -ForegroundColor DarkRed
  Write-Host "MiniQuake OPT-001CR3R7 acceptance test: FAIL" -ForegroundColor Red
  exit 1
}
finally {
  Remove-LoopbackFirewallRules
}
