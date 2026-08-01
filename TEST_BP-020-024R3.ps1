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

  [ValidateSet("Release", "Debug")]
  [string]$Configuration = "Release",

  [switch]$SkipBuild,
  [switch]$SkipGameValidation,
  [switch]$SkipTraceValidation,
  [switch]$NetworkTests,
  [switch]$RebuildNative,
  [switch]$Listings,
  [switch]$ContinueIndependentTests = $true,
  [switch]$BisectOnFailure
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$PackageId = "BP-024R3"
$ParentPackageId = "BP-024R2"
$NativeTextAbi = "caller_owned_bytes_v1"
$ProtocolTextAbi = "quake_latin1_cstring_v1"
$BlockId = "BP-020-024"
$BlockParentPackageId = "BP-015-019R1"
$ProtocolStatus = "protocol15_frozen_v1"
$QuakeCStatus = "quakec_109_frozen_v1"
$DeliveryRevision = "BP-020-024R3"
$Root = $PSScriptRoot
$BuildDirectory = Join-Path $Root "build"
$TraceDirectory = Join-Path $BuildDirectory "bp020-024r3-traces"
$GameExe = Join-Path $BuildDirectory "MiniQuake.exe"
$Verifier = Join-Path $Root "tools\verify.py"
$TraceComparator = Join-Path $Root "tools\compare_traces.py"
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
$BuildScript = Join-Path $Root "build.ps1"
$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$TranscriptPath = Join-Path $BuildDirectory ("bp020-024r3-test-{0}.log" -f $Timestamp)
$SummaryPath = Join-Path $BuildDirectory "bp020-024r3-test-summary.json"
$StaticReportPath = Join-Path $BuildDirectory "bp020-024r3-static-verification.json"
$VersionPath = Join-Path $BuildDirectory "bp020-024r3-version.txt"
$BuildChildLogPath = Join-Path $BuildDirectory "bp020-024r3-build-child.log"
$TraceALogPath = Join-Path $BuildDirectory "bp020-024r3-trace-a.log"
$TraceBLogPath = Join-Path $BuildDirectory "bp020-024r3-trace-b.log"
$SnapshotCommandLogPath = Join-Path $BuildDirectory "bp020-024r3-snapshot-command.log"
$TraceComparisonPath = Join-Path $BuildDirectory "bp020-024r3-trace-comparison.json"
$TraceComparisonLogPath = Join-Path $BuildDirectory "bp020-024r3-trace-comparison.log"
$ProtocolVectorReportPath = Join-Path $BuildDirectory "bp020-024r3-protocol15-vectors.json"
$ProtocolVectorLogPath = Join-Path $BuildDirectory "bp020-024r3-protocol15-vectors.log"
$ProtocolCommandReportPath = Join-Path $BuildDirectory "bp020-024r3-protocol15-commands.json"
$ProtocolCommandLogPath = Join-Path $BuildDirectory "bp020-024r3-protocol15-commands.log"
$ProtocolServerDataReportPath = Join-Path $BuildDirectory "bp020-024r3-protocol15-serverdata.json"
$ProtocolServerDataLogPath = Join-Path $BuildDirectory "bp020-024r3-protocol15-serverdata.log"
$ProtocolEventReportPath = Join-Path $BuildDirectory "bp020-024r3-protocol15-events.json"
$ProtocolEventLogPath = Join-Path $BuildDirectory "bp020-024r3-protocol15-events.log"
$ProtocolRuntimeEventReportPath = Join-Path $BuildDirectory "bp020-024r3-protocol15-runtime-events.json"
$ProtocolRuntimeEventLogPath = Join-Path $BuildDirectory "bp020-024r3-protocol15-runtime-events.log"
$ProtocolSignonReportPath = Join-Path $BuildDirectory "bp020-024r3-protocol15-signon.json"
$ProtocolSignonLogPath = Join-Path $BuildDirectory "bp020-024r3-protocol15-signon.log"
$ProtocolDeliveryReportPath = Join-Path $BuildDirectory "bp020-024r3-protocol15-delivery.json"
$ProtocolDeliveryLogPath = Join-Path $BuildDirectory "bp020-024r3-protocol15-delivery.log"
$ProtocolDatagramReportPath = Join-Path $BuildDirectory "bp020-024r3-protocol15-datagram.json"
$ProtocolDatagramLogPath = Join-Path $BuildDirectory "bp020-024r3-protocol15-datagram.log"
$ProtocolDemoReportPath = Join-Path $BuildDirectory "bp020-024r3-protocol15-demo.json"
$ProtocolDemoLogPath = Join-Path $BuildDirectory "bp020-024r3-protocol15-demo.log"
$ProtocolClosureReportPath = Join-Path $BuildDirectory "bp020-024r3-protocol15-closure.json"
$ProtocolClosureLogPath = Join-Path $BuildDirectory "bp020-024r3-protocol15-closure.log"
$QuakeCProgsReportPath = Join-Path $BuildDirectory "bp020-024r3-quakec-progs.json"
$QuakeCProgsLogPath = Join-Path $BuildDirectory "bp020-024r3-quakec-progs.log"
$QuakeCVMReportPath = Join-Path $BuildDirectory "bp020-024r3-quakec-vm.json"
$QuakeCVMLogPath = Join-Path $BuildDirectory "bp020-024r3-quakec-vm.log"
$QuakeCEdictReportPath = Join-Path $BuildDirectory "bp020-024r3-quakec-edict.json"
$QuakeCEdictLogPath = Join-Path $BuildDirectory "bp020-024r3-quakec-edict.log"
$QuakeCBuiltinReportPath = Join-Path $BuildDirectory "bp020-024r3-quakec-builtins.json"
$QuakeCBuiltinLogPath = Join-Path $BuildDirectory "bp020-024r3-quakec-builtins.log"
$QuakeCClosureReportPath = Join-Path $BuildDirectory "bp020-024r3-quakec-closure.json"
$QuakeCClosureLogPath = Join-Path $BuildDirectory "bp020-024r3-quakec-closure.log"
$QuakeCStockLogPath = Join-Path $BuildDirectory "bp020-024r3-quakec-stock-tests.log"
$GameValidationLogPath = Join-Path $BuildDirectory "bp020-024r3-game-validation.log"
$RuntimeValidationLogPath = Join-Path $BuildDirectory "bp020-024r3-runtime-validation.log"
$BisectReportPath = Join-Path $BuildDirectory "bp020-024r3-bisect-report.json"
$IndependentFailures = New-Object System.Collections.ArrayList
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
  })
  Add-StepResult ("[" + $Package + "] " + $Name) "FAIL" $ExitCode ("log=" + [System.IO.Path]::GetFileName($LogPath))
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

  Write-Host "MiniQuake $DeliveryRevision cumulative QuakeC acceptance test"
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
    -Detail "manifest, packages, ABI, accepted BP-015-019R1 parent, frozen Protocol 15 and cumulative BP-020-024 QuakeC contracts"

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
    -Arguments @($PythonPrefix + @($QuakeCClosureChecker, "--root", $Root, "--json-output", $QuakeCClosureReportPath)) `
    -Detail "stock QuakeC 1.09 contract, required globals/fields/functions and frozen fingerprint" `
    -LogPath $QuakeCClosureLogPath

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
    "QuakeC status: $QuakeCStatus"
  )) {
    if ($VersionText -notmatch [regex]::Escape($Marker)) { throw "Executable identity marker missing: $Marker" }
  }
  Add-StepResult "executable identity" "PASS" 0 "Package: $PackageId; block: $BlockId; protocol: $ProtocolStatus; quakec: $QuakeCStatus"

  $IndependentGroups = @(
    [ordered]@{ package = "BASE"; name = "core tests"; exe = "MiniQuakeTests.exe"; log = "bp020-024r3-core-tests.log" },
    [ordered]@{ package = "BASE"; name = "milestone tests"; exe = "MiniQuakeMilestoneTests.exe"; log = "bp020-024r3-milestone-tests.log" },
    [ordered]@{ package = "BASE"; name = "deterministic diagnostics"; exe = "MiniQuakeCompatTraceTests.exe"; log = "bp020-024r3-diagnostics-tests.log" },
    [ordered]@{ package = "BP-010R1"; name = "Protocol 15 wire"; exe = "MiniQuakeProtocol15WireTests.exe"; log = "bp020-024r3-wire-tests.log" },
    [ordered]@{ package = "BP-011"; name = "Protocol 15 command/update"; exe = "MiniQuakeProtocol15CommandTests.exe"; log = "bp020-024r3-command-tests.log" },
    [ordered]@{ package = "BP-012R1"; name = "Protocol 15 server data"; exe = "MiniQuakeProtocol15ServerDataTests.exe"; log = "bp020-024r3-serverdata-tests.log" },
    [ordered]@{ package = "BP-013"; name = "Protocol 15 events"; exe = "MiniQuakeProtocol15EventTests.exe"; log = "bp020-024r3-event-tests.log" },
    [ordered]@{ package = "BP-014R1"; name = "Protocol 15 runtime events"; exe = "MiniQuakeProtocol15RuntimeEventTests.exe"; log = "bp020-024r3-runtime-event-tests.log" },
    [ordered]@{ package = "BP-015"; name = "signon queue and stages"; exe = "MiniQuakeProtocol15SignonTests.exe"; log = "bp020-024r3-signon-tests.log" },
    [ordered]@{ package = "BP-016"; name = "reliable delivery scheduling"; exe = "MiniQuakeProtocol15DeliveryTests.exe"; log = "bp020-024r3-delivery-tests.log" },
    [ordered]@{ package = "BP-017"; name = "datagram ACK and retransmission"; exe = "MiniQuakeProtocol15DatagramTests.exe"; log = "bp020-024r3-datagram-tests.log" },
    [ordered]@{ package = "BP-018"; name = "demo framing and playback"; exe = "MiniQuakeProtocol15DemoTests.exe"; log = "bp020-024r3-demo-tests.log" },
    [ordered]@{ package = "BP-019"; name = "cross-layer Protocol 15 closure and freeze"; exe = "MiniQuakeProtocol15ClosureTests.exe"; log = "bp020-024r3-protocol15-closure-tests.log" },
    [ordered]@{ package = "BP-020"; name = "QuakeC progs.dat ABI and CRC"; exe = "MiniQuakeQuakeCProgsTests.exe"; log = "bp020-024r3-quakec-progs-tests.log" },
    [ordered]@{ package = "BP-021"; name = "QuakeC VM byte and stack parity"; exe = "MiniQuakeQuakeCVMTests.exe"; log = "bp020-024r3-quakec-vm-tests.log" },
    [ordered]@{ package = "BP-022"; name = "QuakeC edict and save-text parity"; exe = "MiniQuakeQuakeCEdictTests.exe"; log = "bp020-024r3-quakec-edict-tests.log" },
    [ordered]@{ package = "BP-023"; name = "QuakeC builtin table and formatting"; exe = "MiniQuakeQuakeCBuiltinTests.exe"; log = "bp020-024r3-quakec-builtin-tests.log" },
    [ordered]@{ package = "BP-024"; name = "frozen QuakeC contract closure"; exe = "MiniQuakeQuakeCClosureTests.exe"; log = "bp020-024r3-quakec-closure-tests.log" }
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
    Add-StepResult "[BP-024R3] installed Quake data validation" "SKIPPED" 0 $Reason
    Add-StepResult "[BP-024R3] headless runtime validation" "SKIPPED" 0 $Reason
  } else {
    if (-not (Test-Path -LiteralPath $QuakeBase -PathType Container)) {
      throw "Quake base directory does not exist: $QuakeBase"
    }

    # Run the focused stock progs.dat gate first. All three user-data gates
    # are independent and retain complete native stdout/stderr logs even when
    # one of them fails.
    $StockExe = Join-Path $BuildDirectory "MiniQuakeQuakeCStockTests.exe"
    [void](Invoke-IndependentTest -Package "BP-024R3" -Name "stock progs.dat compatibility gate" -Executable $StockExe -LogName ([System.IO.Path]::GetFileName($QuakeCStockLogPath)) -Arguments @($QuakeBase, $Game))
    [void](Invoke-IndependentTest -Package "BP-024R3" -Name "installed Quake data validation" -Executable $GameExe -LogName ([System.IO.Path]::GetFileName($GameValidationLogPath)) -Arguments @("--validate-game", $QuakeBase, $Map, "-game", $Game))
    [void](Invoke-IndependentTest -Package "BP-024R3" -Name "headless runtime validation" -Executable $GameExe -LogName ([System.IO.Path]::GetFileName($RuntimeValidationLogPath)) -Arguments @("--validate-runtime", $QuakeBase, $Map, [string]$Frames, "-game", $Game))
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
      Require-File $Artifact "BP-024 trace artifact"
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
      throw "BP-024 deterministic traces differ. The first differing fields are recorded in $TraceComparisonPath."
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

  if ($IndependentFailures.Count -gt 0) {
    $First = $IndependentFailures[0]
    throw ("Independent test groups failed: " + $IndependentFailures.Count + "; first=" + $First.package + " " + $First.name)
  }

  $OverallStatus = "PASS"
} catch {
  $FailureMessage = $_.Exception.Message
  Write-Host "ERROR: $FailureMessage" -ForegroundColor Red
} finally {
  $BlockPackages = @("BP-020", "BP-021", "BP-022", "BP-023", "BP-024")
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
    } elseif ($FirstFailureIndex -eq 0 -and $FirstFailurePackage -notmatch "^BP-02[0-4]$") {
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
    suggested_patch = if ($FirstFailurePackage -match "^BP-02[0-4]$") { "patches/" + $FirstFailurePackage + ".diff" } else { "" }
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
      quakec_stock_log = [System.IO.Path]::GetFileName($QuakeCStockLogPath)
      game_validation_log = [System.IO.Path]::GetFileName($GameValidationLogPath)
      runtime_validation_log = [System.IO.Path]::GetFileName($RuntimeValidationLogPath)
      bisect_report = [System.IO.Path]::GetFileName($BisectReportPath)
      trace_directory = "bp020-024r3-traces"
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
