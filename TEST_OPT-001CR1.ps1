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
  [int]$E1M2VisibleFrames = 1000,
  [int]$E1M2HeadlessFrames = 10000,
  [int]$TransitionFrames = 64,
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
$DeliveryRevision = "OPT-001CR1"
$DeliveryParent = "OPT-001C"
$SummaryPath = Join-Path $Build "opt001cr1-test-summary.json"
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

function Invoke-Live(
  [string]$Name,
  [string]$Executable,
  [string[]]$Arguments,
  [string]$LogName,
  [switch]$AllowFailure
) {
  $LogPath = Join-Path $Build $LogName
  Write-Host ("[MiniQuake/OPT-001CR1] starting {0}" -f $Name) -ForegroundColor Cyan
  Write-Host ("  executable={0}" -f $Executable)
  Write-Host ("  arguments={0}" -f ($Arguments -join " "))
  & $Executable @Arguments 2>&1 | Tee-Object -FilePath $LogPath
  $Code = [int]$LASTEXITCODE
  if ($Code -eq 0) {
    Add-Step $Name "PASS" $Code $LogName
  } else {
    if ($AllowFailure) {
      Add-Step $Name "DIAGNOSTIC" $Code $LogName
    } else {
      Add-Step $Name "FAIL" $Code $LogName
      if (-not $ContinueIndependentTests) {
        throw ("{0} failed with exit code {1}" -f $Name, $Code)
      }
    }
  }
  return $Code
}

function Install-LoopbackFirewallRules {
  if ($SkipTemporaryFirewallRules) {
    Write-Host "[MiniQuake/OPT-001CR1] temporary loopback firewall rules explicitly skipped" -ForegroundColor Yellow
    return
  }
  if (-not (Test-IsAdministrator)) {
    throw "OPT-001CR1 listen-server measurement requires elevated PowerShell for unattended temporary loopback firewall rules. Start PowerShell as Administrator or pass -SkipTemporaryFirewallRules."
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
  Write-Host "[MiniQuake/OPT-001CR1] temporary loopback firewall rules installed: 2" -ForegroundColor Green
}

function Remove-LoopbackFirewallRules {
  foreach ($Name in $script:FirewallRules) {
    Remove-NetFirewallRule -Name $Name -Confirm:$false -ErrorAction SilentlyContinue
  }
  if ($script:FirewallRules.Count -gt 0) {
    Write-Host "[MiniQuake/OPT-001CR1] temporary loopback firewall rules removed" -ForegroundColor Green
  }
}

function Write-Summary([string]$Overall, [string]$HandleClassification, [string]$PerformanceClassification) {
  [ordered]@{
    schema = "MiniQuakeOPT001CR1TestSummary/1"
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
    handle_windows = $HandleWindows
    e1m2_visible_frames = $E1M2VisibleFrames
    e1m2_headless_frames = $E1M2HeadlessFrames
    transition_frames = $TransitionFrames
    maps = @("e1m1", "e1m2")
    steps = $Steps
  } | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $SummaryPath -Encoding UTF8
}

New-Item -ItemType Directory -Force -Path $Build | Out-Null
$Compiler = [IO.Path]::GetFullPath($Compiler)
$StdLib = [IO.Path]::GetFullPath($StdLib)
$QuakeBase = [IO.Path]::GetFullPath($QuakeBase)

if (-not (Test-Path -LiteralPath $Compiler -PathType Leaf)) { throw "MiniLang compiler not found: $Compiler" }
if (-not (Test-Path -LiteralPath (Join-Path $StdLib "std\fs.ml") -PathType Leaf)) { throw "MiniLang stdlib root invalid: $StdLib" }
if (-not (Test-Path -LiteralPath (Join-Path $QuakeBase "$Game\pak0.pak") -PathType Leaf)) { throw "Quake pak0.pak not found below: $QuakeBase\$Game" }

$PythonExe = (Get-Command python -ErrorAction Stop | Select-Object -First 1).Path
$PowerShellExe = (Get-Process -Id $PID).Path
if ($ListenPort -le 0) { $ListenPort = Get-FreeUdpPort }

Write-Host "MiniQuake OPT-001CR1 acceptance test"
Write-Host "  parent: $DeliveryParent"
Write-Host "  root:   $Root"
Write-Host "  maps:   e1m1, e1m2"
Write-Host "  benchmark: warmup=$WarmupFrames measure=$BenchmarkFrames"
Write-Host "  handles: warmup=$HandleWarmupFrames windows=$HandleWindows x $HandleWindowFrames port=$ListenPort"
Write-Host "  inherited correctness e1m2: visible=$E1M2VisibleFrames headless=$E1M2HeadlessFrames transition=$TransitionFrames"

try {
  [void](Invoke-Live "OPT-001CR1 package verification" $PythonExe @(
    (Join-Path $Root "tools\verify.py"), "--root", $Root,
    "--json", (Join-Path $Build "opt001cr1-package-verification.json")
  ) "opt001cr1-package-verification.log")

  if (-not $SkipBuild) {
    $BuildArgs = @(
      "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", (Join-Path $Root "build.ps1"),
      "-Compiler", $Compiler, "-StdLib", $StdLib, "-Configuration", "Release",
      "-NoRunTests", "-SkipPreflight"
    )
    [void](Invoke-Live "OPT-001CR1 game and contract build" $PowerShellExe $BuildArgs "opt001cr1-build.log")
  } else {
    if (-not (Test-Path -LiteralPath $GameExe -PathType Leaf)) { throw "-SkipBuild requested but MiniQuake.exe is missing" }
    if (-not (Test-Path -LiteralPath $ContractExe -PathType Leaf)) { throw "-SkipBuild requested but contract test executable is missing" }
    Add-Step "OPT-001CR1 game and contract build" "SKIPPED" 0 "-SkipBuild"
  }

  [void](Invoke-Live "OPT-001CR1 allocation contract tests" $ContractExe @() "opt001cr1-allocation-tests.log")
  Install-LoopbackFirewallRules

  foreach ($Map in @("e1m1", "e1m2")) {
    $MapPrefix = Join-Path $Build ("opt001cr1-{0}" -f $Map)
    [void](Invoke-Live "$Map BSP parse" $GameExe @(
      "--opt001a-map-parse", $QuakeBase, $Map, $MapPrefix, "-game", $Game
    ) ("opt001cr1-{0}-map-parse.log" -f $Map))
    [void](Invoke-Live "$Map runtime smoke" $GameExe @(
      "--runtime-smoke", $QuakeBase, $Map, [string]$MatrixFrames, "-game", $Game
    ) ("opt001cr1-{0}-runtime-smoke.log" -f $Map))
    [void](Invoke-Live "$Map render smoke" $GameExe @(
      "--render-smoke", $QuakeBase, $Map, [string]$MatrixFrames, "-game", $Game
    ) ("opt001cr1-{0}-render-smoke.log" -f $Map))

    $TraceA = Join-Path $Build ("opt001cr1-{0}-trace-a" -f $Map)
    $TraceB = Join-Path $Build ("opt001cr1-{0}-trace-b" -f $Map)
    [void](Invoke-Live "$Map trace A" $GameExe @(
      "--compat-trace", $QuakeBase, $Map, [string]$MatrixFrames, $TraceA, "-game", $Game
    ) ("opt001cr1-{0}-trace-a.log" -f $Map))
    [void](Invoke-Live "$Map trace B" $GameExe @(
      "--compat-trace", $QuakeBase, $Map, [string]$MatrixFrames, $TraceB, "-game", $Game
    ) ("opt001cr1-{0}-trace-b.log" -f $Map))
    [void](Invoke-Live "$Map trace comparison" $PythonExe @(
      (Join-Path $Root "tools\compare_traces.py"), ($TraceA + ".mqtrace"), ($TraceB + ".mqtrace"),
      "--json-output", (Join-Path $Build ("opt001cr1-{0}-trace-comparison.json" -f $Map))
    ) ("opt001cr1-{0}-trace-comparison.log" -f $Map))

    foreach ($Mode in @("headless", "render")) {
      $Prefix = Join-Path $Build ("opt001cr1-{0}-{1}" -f $Map, $Mode)
      [void](Invoke-Live "$Map $Mode frame baseline" $GameExe @(
        "--opt001a-frame-baseline", $QuakeBase, $Map, $Mode,
        [string]$WarmupFrames, [string]$BenchmarkFrames, $Prefix, "-game", $Game
      ) ("opt001cr1-{0}-{1}-baseline.log" -f $Map, $Mode))
    }
  }

  $VisiblePrefix = Join-Path $Build "opt001cr1-e1m2-visible"
  [void](Invoke-Live "OPT-001CR1 e1m2 visible validation" $GameExe @(
    "--render-evidence", $QuakeBase, "e1m2", [string]$E1M2VisibleFrames, $VisiblePrefix, "-game", $Game
  ) "opt001cr1-e1m2-visible.log")

  [void](Invoke-Live "OPT-001CR1 e1m2 headless validation" $GameExe @(
    "--runtime-smoke", $QuakeBase, "e1m2", [string]$E1M2HeadlessFrames, "-game", $Game
  ) "opt001cr1-e1m2-headless.log")

  $TransitionPrefix = Join-Path $Build "opt001cr1-transition"
  [void](Invoke-Live "OPT-001CR1 e1m1-e1m2-e1m1 transition" $GameExe @(
    "--opt001b-transition", $QuakeBase, [string]$TransitionFrames, $TransitionPrefix, "-game", $Game
  ) "opt001cr1-transition.log")

  $PlateauPrefix = Join-Path $Build "opt001cr1-listen-handle-plateau"
  [void](Invoke-Live "listen-server handle plateau" $GameExe @(
    "--opt001a-handle-plateau", $QuakeBase, "start",
    [string]$HandleWarmupFrames, [string]$HandleWindowFrames, [string]$HandleWindows,
    $PlateauPrefix, "-game", $Game, "-port", [string]$ListenPort
  ) "opt001cr1-handle-plateau.log" -AllowFailure)

  [void](Invoke-Live "OPT-001CR1 aggregate analysis" $PythonExe @(
    (Join-Path $Root "tools\analyze_opt001a.py"), "--build", $Build,
    "--json", (Join-Path $Build "opt001cr1-baseline-summary.json"),
    "--markdown", (Join-Path $Build "opt001cr1-baseline-summary.md")
  ) "opt001cr1-aggregate-analysis.log" -AllowFailure)

  $PerformanceJson = Join-Path $Build "opt001cr1-performance-comparison.json"
  [void](Invoke-Live "OPT-001CR1 performance comparison" $PythonExe @(
    (Join-Path $Root "tools\compare_opt001c_performance.py"),
    "--baseline", (Join-Path $Root "audit\opt001b_performance_baseline.json"),
    "--build", $Build,
    "--json", $PerformanceJson,
    "--markdown", (Join-Path $Build "opt001cr1-performance-comparison.md")
  ) "opt001cr1-performance-comparison.log")

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
  Write-Host "MiniQuake OPT-001CR1 summary"
  Write-Host "  handle_classification=$HandleClassification"
  Write-Host "  performance_classification=$PerformanceClassification"
  Write-Host "  failures=$Failures"
  Write-Host "  summary=$SummaryPath"
  if ($Overall -eq "PASS") {
    Write-Host "MiniQuake OPT-001CR1 acceptance test: PASS" -ForegroundColor Green
    exit 0
  }
  Write-Host ("MiniQuake OPT-001CR1 acceptance test: {0}" -f $Overall) -ForegroundColor Red
  exit 2
}
catch {
  Add-Step "OPT-001CR1 harness" "FAIL" 1 $_.Exception.Message
  Write-Summary "FAIL" "UNKNOWN" "UNKNOWN"
  Write-Host ("ERROR: " + $_.Exception.Message) -ForegroundColor Red
  Write-Host "MiniQuake OPT-001CR1 acceptance test: FAIL" -ForegroundColor Red
  exit 1
}
finally {
  Remove-LoopbackFirewallRules
}
