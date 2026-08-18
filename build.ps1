# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: Apache-2.0
# Build MiniQuake and run the selected source and runtime verification gates.

[CmdletBinding()]
param(
  [string]$Compiler = "",

  [Alias("StdLibPath", "ImportRoot")]
  [string]$StdLib = "",

  [string]$Python = "",

  [ValidateSet("Release", "Debug")]
  [string]$Configuration = "Release",

  [switch]$SkipTests,
  [switch]$SkipMilestoneTests,
  [switch]$NoRunTests,
  [switch]$NetworkTests,
  [switch]$RebuildNative,
  [switch]$Listings,
  [switch]$SkipPreflight
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# Never let Python tools or the Python MiniLang compiler buffer their output.
$env:PYTHONUNBUFFERED = "1"

$Root = $PSScriptRoot
$Output = Join-Path $Root "build"
$Source = Join-Path $Root "src"
$Parent = Split-Path -Parent $Root
$PackageId = "BP-094"
$ParentPackageId = "BP-093"
$NativeTextAbi = "caller_owned_bytes_v1"
$ProtocolTextAbi = "quake_latin1_cstring_v1"
$BlockId = "BP-090-094"
$BlockParentPackageId = "BP-085-089R8"
$ProtocolStatus = "protocol15_frozen_v1"
$QuakeCStatus = "quakec_109_frozen_v1"
$WorldPhysicsStatus = "world_physics_109_frozen_v1"
$HostLifecycleStatus = "host_lifecycle_109_frozen_v1"
$ClientRenderStatus = "client_render_109_frozen_v1"
$WorldRenderStatus = "world_render_109_frozen_v1"
$ModelUiRenderStatus = "model_ui_render_109_frozen_v1"
$RenderSpecialStatus = "render_special_109_frozen_v1"
$AudioStatus = "audio_109_frozen_v1"
$NetworkPlatformStatus = "network_platform_109_frozen_v1"
$FrontendStatus = "frontend_109_frozen_v1"
$CoreAssetsMemoryStatus = "core_assets_memory_109_frozen_v1"
$GameplayPresentationStatus = "gameplay_presentation_109_frozen_v1"
$BlackPortSourceStatus = "black_port_source_109_frozen_v1"
$GameProfileStatus = "game_profile_109_frozen_v1"
$ModRuntimeStatus = "mod_runtime_109_frozen_v1"
$ArtifactCompatStatus = "artifact_compat_109_frozen_v1"
$StabilityStatus = "stability_109_frozen_v1"
$CompatReleaseStatus = "compat_109_release_candidate_v1"
$OriginalReferenceStatus = "original_reference_109_candidate_v1"
$CompatFinalStatus = "compat_109_final_candidate_v1"

# Resolve a configured executable from a path or command name.
function Resolve-CommandOrFile {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Value,

    [Parameter(Mandatory = $true)]
    [string]$Label
  )

  if (Test-Path -LiteralPath $Value -PathType Leaf) {
    return [System.IO.Path]::GetFullPath($Value)
  }

  $Command = Get-Command $Value -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($null -ne $Command -and -not [string]::IsNullOrWhiteSpace($Command.Path)) {
    return $Command.Path
  }

  throw "$Label not found: $Value"
}

# Normalize a standard-library candidate to its import root.
function Normalize-StdImportRoot {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Candidate
  )

  if ([string]::IsNullOrWhiteSpace($Candidate)) {
    return $null
  }

  $Full = [System.IO.Path]::GetFullPath($Candidate)

  if (Test-Path -LiteralPath $Full -PathType Leaf) {
    if ([System.IO.Path]::GetFileName($Full) -ieq "fs.ml") {
      $StdDirectory = Split-Path -Parent $Full
      if ((Split-Path -Leaf $StdDirectory) -ieq "std") {
        return Split-Path -Parent $StdDirectory
      }
    }
    return $null
  }

  if (-not (Test-Path -LiteralPath $Full -PathType Container)) {
    return $null
  }

  # Preferred form: the import root that contains std\fs.ml.
  if (Test-Path -LiteralPath (Join-Path $Full "std\fs.ml") -PathType Leaf) {
    return $Full
  }

  # Friendly form: the std directory itself.  The compiler still needs its parent
  # as -I root because `import std.fs` resolves to std/fs.ml below that root.
  if ((Split-Path -Leaf $Full) -ieq "std" -and
      (Test-Path -LiteralPath (Join-Path $Full "fs.ml") -PathType Leaf)) {
    return Split-Path -Parent $Full
  }

  return $null
}

# Locate a usable MiniLang standard-library import root.
function Find-StdImportRoot {
  param(
    [Parameter(Mandatory = $true)]
    [string]$CompilerPath,

    [string]$ExplicitPath
  )

  if (-not [string]::IsNullOrWhiteSpace($ExplicitPath)) {
    $Resolved = Normalize-StdImportRoot $ExplicitPath
    if ($null -eq $Resolved) {
      throw "MiniLang stdlib not found at '$ExplicitPath'. Pass either the compiler repository root containing std\fs.ml, the std directory itself, or std\fs.ml."
    }
    return $Resolved
  }

  $CompilerDirectory = Split-Path -Parent $CompilerPath
  $CompilerParent = Split-Path -Parent $CompilerDirectory
  $CompilerGrandParent = Split-Path -Parent $CompilerParent

  $Candidates = @()
  if (-not [string]::IsNullOrWhiteSpace($env:MINILANG_STDLIB)) {
    $Candidates += $env:MINILANG_STDLIB
  }
  if (-not [string]::IsNullOrWhiteSpace($env:MINILANG_HOME)) {
    $Candidates += $env:MINILANG_HOME
  }

  $Candidates += @(
    $CompilerDirectory,
    $CompilerParent,
    $CompilerGrandParent,
    (Join-Path $Parent "MiniLangCompilerPy"),
    (Join-Path $Parent "MiniLangCompilerML")
  )

  $Seen = @{}
  foreach ($Candidate in $Candidates) {
    if ([string]::IsNullOrWhiteSpace($Candidate)) {
      continue
    }

    $Key = [System.IO.Path]::GetFullPath($Candidate).ToLowerInvariant()
    if ($Seen.ContainsKey($Key)) {
      continue
    }
    $Seen[$Key] = $true

    $Resolved = Normalize-StdImportRoot $Candidate
    if ($null -ne $Resolved) {
      return $Resolved
    }
  }

  throw @"
MiniLang stdlib was not found.

MiniQuake imports std.fs, so the compiler needs an additional import root that
contains std\fs.ml. Pass it explicitly, for example:

  .\build.ps1 -Compiler C:\path\MiniLangCompilerPy\mlc_win64.py `
                -StdLib C:\path\MiniLangCompilerPy

or:

  .\build.ps1 -Compiler C:\path\MiniLangCompilerML\build\mlc_win64.exe `
                -StdLib C:\path\MiniLangCompilerML

-StdLib may also point directly at the std directory.
"@
}

# With no explicit path, prefer the Python reference compiler.  This gives the
# quickest diagnostics and mirrors the intended porting workflow.  The native
# self-hosted compiler remains fully supported.
if ([string]::IsNullOrWhiteSpace($Compiler)) {
  $CompilerCandidates = @(
    (Join-Path $Parent "MiniLangCompilerPy\mlc_win64.py"),
    (Join-Path $Parent "MiniLangCompilerML\build\mlc_win64.exe"),
    (Join-Path $Output "mlc_win64.exe")
  )

  foreach ($Candidate in $CompilerCandidates) {
    if (Test-Path -LiteralPath $Candidate -PathType Leaf) {
      $Compiler = $Candidate
      break
    }
  }

  if ([string]::IsNullOrWhiteSpace($Compiler)) {
    throw @"
No MiniLang compiler was found. Pass -Compiler explicitly.

Recommended reference compiler:
  .\build.ps1 -Compiler ..\MiniLangCompilerPy\mlc_win64.py

Self-hosted compiler:
  .\build.ps1 -Compiler ..\MiniLangCompilerML\build\mlc_win64.exe
"@
  }
}

$Compiler = Resolve-CommandOrFile $Compiler "MiniLang compiler"
$CompilerIsPython = [System.IO.Path]::GetExtension($Compiler) -ieq ".py"
$StdImportRoot = Find-StdImportRoot $Compiler $StdLib

$PythonExe = $null
$PythonPrefixArgs = @()
if ($CompilerIsPython -or $RebuildNative -or -not [string]::IsNullOrWhiteSpace($Python)) {
  if (-not [string]::IsNullOrWhiteSpace($Python)) {
    $PythonExe = Resolve-CommandOrFile $Python "Python interpreter"
    if ([System.IO.Path]::GetFileNameWithoutExtension($PythonExe) -ieq "py") {
      $PythonPrefixArgs = @("-3")
    }
  } else {
    $PyLauncher = Get-Command "py" -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($null -ne $PyLauncher) {
      $PythonExe = $PyLauncher.Path
      $PythonPrefixArgs = @("-3")
    } else {
      $PythonCommand = Get-Command "python" -ErrorAction SilentlyContinue | Select-Object -First 1
      if ($null -eq $PythonCommand) {
        throw "Python 3 is required for the Python MiniLang compiler or -RebuildNative. Pass -Python PATH if it is not on PATH."
      }
      $PythonExe = $PythonCommand.Path
    }
  }
}

# Run a process while streaming and retaining its diagnostic output.
function Invoke-LiveCapturedProcess {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Executable,

    [string[]]$Arguments = @(),

    [string]$LogPath = ""
  )

  $Lines = [System.Collections.Generic.List[string]]::new()
  $Writer = $null
  if (-not [string]::IsNullOrWhiteSpace($LogPath)) {
    $Encoding = [System.Text.UTF8Encoding]::new($false)
    $Writer = [System.IO.StreamWriter]::new($LogPath, $false, $Encoding)
  }

  $ExitCode = 1
  try {
    & $Executable @Arguments 2>&1 |
      ForEach-Object {
        $Line = [string]$_
        $Lines.Add($Line)
        if ($null -ne $Writer) {
          $Writer.WriteLine($Line)
          $Writer.Flush()
        }
        Write-Host $Line
      }
    $ExitCode = [int]$LASTEXITCODE
  } finally {
    if ($null -ne $Writer) {
      $Writer.Flush()
      $Writer.Dispose()
    }
  }

  return [pscustomobject]@{
    exit_code = $ExitCode
    lines = $Lines.ToArray()
    text = [string]::Join("`n", $Lines.ToArray())
  }
}

# Compile one MiniLang target with the selected compiler interface.
function Invoke-MiniLangCompile {
  param(
    [Parameter(Mandatory = $true)]
    [string]$InputFile,

    [Parameter(Mandatory = $true)]
    [string]$OutputFile,

    [Parameter(Mandatory = $true)]
    [string[]]$CompilerArguments,

    [Parameter(Mandatory = $true)]
    [string]$Label
  )

  $SafeLabel = ($Label -replace "[^A-Za-z0-9._-]", "-").Trim([char[]]@('-'))
  if ([string]::IsNullOrWhiteSpace($SafeLabel)) { $SafeLabel = "target" }
  $LogPath = Join-Path $Output ("compile-{0}.log" -f $SafeLabel)
  $PartialFile = $OutputFile + ".partial.exe"
  $EffectiveArguments = @($CompilerArguments)
  if ($Listings -and -not ($EffectiveArguments -contains "--asm-out")) {
    $ListingPath = [System.IO.Path]::ChangeExtension($OutputFile, ".asm")
    $EffectiveArguments += @("--asm-out", $ListingPath)
  }

  # Never leave an older executable looking like the result of a failed build.
  foreach ($StalePath in @($OutputFile, $PartialFile)) {
    if (Test-Path -LiteralPath $StalePath -PathType Leaf) {
      Remove-Item -Force -LiteralPath $StalePath
    }
  }

  @(
    "MiniQuake compile log",
    "package=$PackageId",
    "label=$Label",
    "input=$InputFile",
    "output=$OutputFile",
    "compiler=$Compiler",
    "started_utc=$([DateTime]::UtcNow.ToString('o'))",
    "--- compiler output ---"
  ) | Set-Content -LiteralPath $LogPath -Encoding UTF8

  if ($CompilerIsPython) {
    & $PythonExe @PythonPrefixArgs $Compiler $InputFile $PartialFile @EffectiveArguments 2>&1 |
      ForEach-Object {
        $CompilerLine = [string]$_
        Write-Host $CompilerLine
        Add-Content -LiteralPath $LogPath -Encoding UTF8 -Value $CompilerLine
      }
  } else {
    & $Compiler $InputFile $PartialFile @EffectiveArguments 2>&1 |
      ForEach-Object {
        $CompilerLine = [string]$_
        Write-Host $CompilerLine
        Add-Content -LiteralPath $LogPath -Encoding UTF8 -Value $CompilerLine
      }
  }
  $CompileExitCode = [int]$LASTEXITCODE
  Add-Content -LiteralPath $LogPath -Encoding UTF8 -Value @(
    "--- compiler result ---",
    "exit_code=$CompileExitCode",
    "finished_utc=$([DateTime]::UtcNow.ToString('o'))"
  )

  if ($CompileExitCode -ne 0) {
    if (Test-Path -LiteralPath $PartialFile -PathType Leaf) {
      Remove-Item -Force -LiteralPath $PartialFile
    }
    Write-Host "ERROR: MiniLang compilation failed for '$Label' with exit code $CompileExitCode. Compiler log: $LogPath" -ForegroundColor Red
    exit $CompileExitCode
  }
  if (-not (Test-Path -LiteralPath $PartialFile -PathType Leaf)) {
    Write-Host "ERROR: MiniLang compilation reported success for '$Label' but did not create $PartialFile. Compiler log: $LogPath" -ForegroundColor Red
    exit 1
  }

  Move-Item -Force -LiteralPath $PartialFile -Destination $OutputFile
}

New-Item -ItemType Directory -Force -Path $Output | Out-Null

# Remove all package targets before the first compile.  If the game target
# fails, executables and compile logs from the parent package cannot be mistaken
# for current BP-044 products by the result collector.
$PackageBuildArtifacts = @(
  "MiniQuake.exe",
  "MiniQuakeOPT001AContractTests.exe",
  "MiniQuakeOPT001BCorrectnessTests.exe",
  "MiniQuakeOPT001CAllocationTests.exe",
  "MiniQuakeOPT001CR3HotpathTests.exe",
  "MiniQuakeTests.exe",
  "MiniQuakeMilestoneTests.exe",
  "MiniQuakeCompatTraceTests.exe",
  "MiniQuakeProtocol15WireTests.exe",
  "MiniQuakeProtocol15CommandTests.exe",
  "MiniQuakeProtocol15ServerDataTests.exe",
  "MiniQuakeProtocol15EventTests.exe",
  "MiniQuakeProtocol15RuntimeEventTests.exe",
  "MiniQuakeProtocol15SignonTests.exe",
  "MiniQuakeProtocol15DeliveryTests.exe",
  "MiniQuakeProtocol15DatagramTests.exe",
  "MiniQuakeProtocol15DemoTests.exe",
  "MiniQuakeProtocol15ClosureTests.exe",
  "MiniQuakeQuakeCProgsTests.exe",
  "MiniQuakeQuakeCVMTests.exe",
  "MiniQuakeQuakeCEdictTests.exe",
  "MiniQuakeQuakeCBuiltinTests.exe",
  "MiniQuakeQuakeCClosureTests.exe",
  "MiniQuakeQuakeCStockTests.exe",
  "MiniQuakeWorldHullTests.exe",
  "MiniQuakeWorldTraceTests.exe",
  "MiniQuakeWorldLinkTests.exe",
  "MiniQuakeServerMoveTests.exe",
  "MiniQuakeServerPhysicsTests.exe",
  "MiniQuakeSvUserMovementTests.exe",
  "MiniQuakeBackwardMovementRetailTests.exe",
  "MiniQuakeCheatRetailTests.exe",
  "MiniQuakePlayerCollisionTelefragRetailTests.exe",
  "MiniQuakeServerUserTests.exe",
  "MiniQuakeWorldPhysicsClosureTests.exe",
  "MiniQuakeHostTimingTests.exe",
  "MiniQuakeCommandCvarTests.exe",
  "MiniQuakeHostCommandTests.exe",
  "MiniQuakeDemoLifecycleTests.exe",
  "MiniQuakeSavegameV5Tests.exe",
  "MiniQuakeHostLifecycleClosureTests.exe",
  "MiniQuakeClientStateRenderTests.exe",
  "MiniQuakeViewStateTests.exe",
  "MiniQuakeTemporaryBeamTests.exe",
  "MiniQuakeParticleRuntimeTests.exe",
  "MiniQuakeClientRenderClosureTests.exe",
  "MiniQuakeWorldSurfaceRenderTests.exe",
  "MiniQuakeLightmapAtlasTests.exe",
  "MiniQuakeDynamicLightRenderTests.exe",
  "MiniQuakeSkyWaterRenderTests.exe",
  "MiniQuakeWorldRenderClosureTests.exe",
  "MiniQuakeAliasModelTests.exe",
  "MiniQuakeSpriteSyncTests.exe",
  "MiniQuakeRenderUiHudTests.exe",
  "MiniQuakeRenderEvidenceTests.exe",
  "MiniQuakeModelUiRenderClosureTests.exe",
  "MiniQuakeMirrorSpecialRenderTests.exe",
  "MiniQuakeRenderClearSpecialTests.exe",
  "MiniQuakeEnvmapTimeRefreshTests.exe",
  "MiniQuakeRenderEvidenceCorpusTests.exe",
  "MiniQuakeRenderSpecialClosureTests.exe",
  "MiniQuakeAudioMemoryTests.exe",
  "MiniQuakeAudioDmaTests.exe",
  "MiniQuakeAudioMixerTests.exe",
  "MiniQuakeAudioWinTests.exe",
  "MiniQuakeAudioClosureTests.exe",
  "MiniQuakeAudioRetailEvidence.exe",
  "MiniQuakeNetworkMainTests.exe",
  "MiniQuakeNetworkControlTests.exe",
  "MiniQuakeNetworkWinsAddressTests.exe",
  "MiniQuakeSystemPlatformTests.exe",
  "MiniQuakeNetworkPlatformClosureTests.exe",
  "MiniQuakeNetworkPlatformEvidence.exe",
  "MiniQuakeKeyFocusTests.exe",
  "MiniQuakeInputDeviceTests.exe",
  "MiniQuakeConsoleScreenTests.exe",
  "MiniQuakeMenuLifecycleTests.exe",
  "MiniQuakeFrontendClosureTests.exe",
  "MiniQuakeCommonCoreTests.exe",
  "MiniQuakeFilesystemPackTests.exe",
  "MiniQuakeWadGraphicsTests.exe",
  "MiniQuakeModelAssetTests.exe",
  "MiniQuakeCoreAssetsMemoryTests.exe",
  "MiniQuakeCoreAssetRetailEvidence.exe",
  "MiniQuakeGameplayMathChaseTests.exe",
  "MiniQuakeGameplayViewTests.exe",
  "MiniQuakeGameplayScreenTests.exe",
  "MiniQuakeGameplayStatusbarTests.exe",
  "MiniQuakeGameplayPresentationClosureTests.exe",
  "MiniQuakeCvarSourceSurfaceTests.exe",
  "MiniQuakeCdAudioSourceSurfaceTests.exe",
  "MiniQuakeSourceFunctionInventoryTests.exe",
  "MiniQuakeBlackPortCorpusTests.exe",
  "MiniQuakeBlackPortSourceClosureTests.exe",
  "MiniQuakeGameProfileTests.exe",
  "MiniQuakeModRuntimeTests.exe",
  "MiniQuakeArtifactCompatTests.exe",
  "MiniQuakeStabilityTests.exe",
  "MiniQuakeCompatibilityReleaseTests.exe",
  "MiniQuakeOriginalReferenceTests.exe",
  "MiniQuakeOriginalServerInteropTests.exe",
  "MiniQuakeOriginalClientInteropTests.exe",
  "MiniQuakeOriginalVisualReferenceTests.exe",
  "MiniQuakeExternalCompatibilityClosureTests.exe",
  "MiniQuakeArtifactRetailEvidence.exe"
)
foreach ($ArtifactName in $PackageBuildArtifacts) {
  foreach ($Candidate in @(
    (Join-Path $Output $ArtifactName),
    ((Join-Path $Output $ArtifactName) + ".partial.exe")
  )) {
    if (Test-Path -LiteralPath $Candidate -PathType Leaf) {
      Remove-Item -Force -LiteralPath $Candidate
    }
  }
}
Get-ChildItem -LiteralPath $Output -File -Filter "compile-*.log" -ErrorAction SilentlyContinue |
  Remove-Item -Force -ErrorAction SilentlyContinue

Write-Host "[MiniQuake] package:         $PackageId"
Write-Host "[MiniQuake] compiler:        $Compiler"
if ($CompilerIsPython) {
  Write-Host "[MiniQuake] compiler kind:   Python reference compiler"
  Write-Host "[MiniQuake] python:          $PythonExe $($PythonPrefixArgs -join ' ')"
} else {
  Write-Host "[MiniQuake] compiler kind:   native self-hosted compiler"
}
Write-Host "[MiniQuake] source root:     $Source"
Write-Host "[MiniQuake] std import root: $StdImportRoot"

if (-not $SkipPreflight -and $null -ne $PythonExe) {
  Write-Host "[MiniQuake] running $PackageId diagnostics preflight"
  $Verifier = Join-Path $Root "tools\verify.py"
  if (-not (Test-Path -LiteralPath $Verifier -PathType Leaf)) {
    throw "Baseline verifier is missing: $Verifier"
  }

  & $PythonExe @PythonPrefixArgs $Verifier --root $Root
  if ($LASTEXITCODE -ne 0) {
    throw "$PackageId diagnostics preflight failed. The source tree or manifest is inconsistent."
  }

  # Guard the native renderer resource lifetimes and texture bounds that are
  # difficult to exercise deterministically on every build host.
  $NativeRendererSafetyChecker = Join-Path $Root "tools\check_native_renderer_safety.py"
  if (-not (Test-Path -LiteralPath $NativeRendererSafetyChecker -PathType Leaf)) {
    throw "Native renderer safety checker is missing: $NativeRendererSafetyChecker"
  }
  & $PythonExe @PythonPrefixArgs $NativeRendererSafetyChecker --root $Root
  if ($LASTEXITCODE -ne 0) {
    throw "$PackageId native renderer safety preflight failed."
  }

  $RuntimeTestLogChecker = Join-Path $Root "tools\check_runtime_test_log.py"
  if (-not (Test-Path -LiteralPath $RuntimeTestLogChecker -PathType Leaf)) {
    throw "Runtime-test log checker is missing: $RuntimeTestLogChecker"
  }
  & $PythonExe @PythonPrefixArgs $RuntimeTestLogChecker --self-test
  if ($LASTEXITCODE -ne 0) {
    throw "$PackageId runtime-test log checker self-test failed."
  }

  $ProtocolVectorChecker = Join-Path $Root "tools\check_protocol15_vectors.py"
  if (-not (Test-Path -LiteralPath $ProtocolVectorChecker -PathType Leaf)) {
    throw "Protocol 15 vector checker is missing: $ProtocolVectorChecker"
  }
  & $PythonExe @PythonPrefixArgs $ProtocolVectorChecker $Root
  if ($LASTEXITCODE -ne 0) {
    throw "$PackageId Protocol 15 vector preflight failed."
  }

  $ProtocolCommandChecker = Join-Path $Root "tools\check_protocol15_commands.py"
  if (-not (Test-Path -LiteralPath $ProtocolCommandChecker -PathType Leaf)) {
    throw "Protocol 15 command checker is missing: $ProtocolCommandChecker"
  }
  & $PythonExe @PythonPrefixArgs $ProtocolCommandChecker $Root
  if ($LASTEXITCODE -ne 0) {
    throw "$PackageId Protocol 15 command-stream preflight failed."
  }

  $ProtocolServerDataChecker = Join-Path $Root "tools\check_protocol15_serverdata.py"
  if (-not (Test-Path -LiteralPath $ProtocolServerDataChecker -PathType Leaf)) {
    throw "Protocol 15 server-data checker is missing: $ProtocolServerDataChecker"
  }
  & $PythonExe @PythonPrefixArgs $ProtocolServerDataChecker --root $Root
  if ($LASTEXITCODE -ne 0) {
    throw "$PackageId Protocol 15 server-data preflight failed."
  }

  $ProtocolEventChecker = Join-Path $Root "tools\check_protocol15_events.py"
  if (-not (Test-Path -LiteralPath $ProtocolEventChecker -PathType Leaf)) {
    throw "Protocol 15 event checker is missing: $ProtocolEventChecker"
  }
  & $PythonExe @PythonPrefixArgs $ProtocolEventChecker --root $Root
  if ($LASTEXITCODE -ne 0) {
    throw "$PackageId Protocol 15 static-event, particle, scoreboard and drop preflight failed."
  }

  $ProtocolRuntimeEventChecker = Join-Path $Root "tools\check_protocol15_runtime_events.py"
  if (-not (Test-Path -LiteralPath $ProtocolRuntimeEventChecker -PathType Leaf)) {
    throw "Protocol 15 runtime-event checker is missing: $ProtocolRuntimeEventChecker"
  }
  & $PythonExe @PythonPrefixArgs $ProtocolRuntimeEventChecker --root $Root
  if ($LASTEXITCODE -ne 0) {
    throw "$PackageId Protocol 15 temporary-entity, dynamic-sound and delivery-boundary preflight failed."
  }

  $ProtocolSignonChecker = Join-Path $Root "tools\check_protocol15_signon.py"
  if (-not (Test-Path -LiteralPath $ProtocolSignonChecker -PathType Leaf)) {
    throw "Protocol 15 signon checker is missing: $ProtocolSignonChecker"
  }
  & $PythonExe @PythonPrefixArgs $ProtocolSignonChecker --root $Root
  if ($LASTEXITCODE -ne 0) {
    throw "$PackageId Protocol 15 signon preflight failed."
  }

  $ProtocolDeliveryChecker = Join-Path $Root "tools\check_protocol15_delivery.py"
  if (-not (Test-Path -LiteralPath $ProtocolDeliveryChecker -PathType Leaf)) {
    throw "Protocol 15 delivery checker is missing: $ProtocolDeliveryChecker"
  }
  & $PythonExe @PythonPrefixArgs $ProtocolDeliveryChecker --root $Root
  if ($LASTEXITCODE -ne 0) {
    throw "$PackageId Protocol 15 reliable/unreliable delivery preflight failed."
  }

  $ProtocolDatagramChecker = Join-Path $Root "tools\check_protocol15_datagram.py"
  if (-not (Test-Path -LiteralPath $ProtocolDatagramChecker -PathType Leaf)) {
    throw "Protocol 15 datagram checker is missing: $ProtocolDatagramChecker"
  }
  & $PythonExe @PythonPrefixArgs $ProtocolDatagramChecker --root $Root
  if ($LASTEXITCODE -ne 0) {
    throw "$PackageId Protocol 15 datagram/ACK/retransmission preflight failed."
  }

  $ProtocolDemoChecker = Join-Path $Root "tools\check_protocol15_demo.py"
  if (-not (Test-Path -LiteralPath $ProtocolDemoChecker -PathType Leaf)) {
    throw "Protocol 15 demo checker is missing: $ProtocolDemoChecker"
  }
  & $PythonExe @PythonPrefixArgs $ProtocolDemoChecker --root $Root
  if ($LASTEXITCODE -ne 0) {
    throw "$PackageId Protocol 15 demo framing/recording/playback preflight failed."
  }

  $ProtocolClosureChecker = Join-Path $Root "tools\check_protocol15_closure.py"
  if (-not (Test-Path -LiteralPath $ProtocolClosureChecker -PathType Leaf)) {
    throw "Protocol 15 closure checker is missing: $ProtocolClosureChecker"
  }
  & $PythonExe @PythonPrefixArgs $ProtocolClosureChecker --root $Root
  if ($LASTEXITCODE -ne 0) {
    throw "$PackageId cumulative Protocol 15 closure/freeze preflight failed."
  }

  $QuakeCProgsChecker = Join-Path $Root "tools\check_quakec_progs.py"
  if (-not (Test-Path -LiteralPath $QuakeCProgsChecker -PathType Leaf)) {
    throw "BP-020 QuakeC progs.dat checker is missing: $QuakeCProgsChecker"
  }
  & $PythonExe @PythonPrefixArgs $QuakeCProgsChecker --root $Root
  if ($LASTEXITCODE -ne 0) { throw "$PackageId BP-020 QuakeC progs.dat preflight failed." }

  $QuakeCVMChecker = Join-Path $Root "tools\check_quakec_vm.py"
  if (-not (Test-Path -LiteralPath $QuakeCVMChecker -PathType Leaf)) {
    throw "BP-021 QuakeC VM checker is missing: $QuakeCVMChecker"
  }
  & $PythonExe @PythonPrefixArgs $QuakeCVMChecker --root $Root
  if ($LASTEXITCODE -ne 0) { throw "$PackageId BP-021 QuakeC VM preflight failed." }

  $QuakeCEdictChecker = Join-Path $Root "tools\check_quakec_edict.py"
  if (-not (Test-Path -LiteralPath $QuakeCEdictChecker -PathType Leaf)) {
    throw "BP-022 QuakeC edict checker is missing: $QuakeCEdictChecker"
  }
  & $PythonExe @PythonPrefixArgs $QuakeCEdictChecker --root $Root --allow-downstream-package
  if ($LASTEXITCODE -ne 0) { throw "$PackageId BP-022 QuakeC edict preflight failed." }

  $QuakeCBuiltinChecker = Join-Path $Root "tools\check_quakec_builtins.py"
  if (-not (Test-Path -LiteralPath $QuakeCBuiltinChecker -PathType Leaf)) {
    throw "BP-023 QuakeC builtin checker is missing: $QuakeCBuiltinChecker"
  }
  & $PythonExe @PythonPrefixArgs $QuakeCBuiltinChecker --root $Root
  if ($LASTEXITCODE -ne 0) { throw "$PackageId BP-023 QuakeC builtin preflight failed." }

  $QuakeCClosureChecker = Join-Path $Root "tools\check_quakec_closure.py"
  if (-not (Test-Path -LiteralPath $QuakeCClosureChecker -PathType Leaf)) {
    throw "BP-024R3 QuakeC closure checker is missing: $QuakeCClosureChecker"
  }
  & $PythonExe @PythonPrefixArgs $QuakeCClosureChecker --root $Root --allow-downstream-package
  if ($LASTEXITCODE -ne 0) { throw "$PackageId BP-024R3 frozen QuakeC contract preflight failed." }

  $WorldPhysicsCheckers = @(
    [ordered]@{ Name = "BP-025 world hull"; Path = "tools\check_world_hull.py" },
    [ordered]@{ Name = "BP-025 world trace"; Path = "tools\check_world_trace.py" },
    [ordered]@{ Name = "BP-026 world link/collision"; Path = "tools\check_world_link.py" },
    [ordered]@{ Name = "BP-027 server movement"; Path = "tools\check_server_move.py" },
    [ordered]@{ Name = "BP-028 server physics"; Path = "tools\check_server_physics.py" },
    [ordered]@{ Name = "BP-028 sv_user movement"; Path = "tools\check_sv_user_movement.py" },
    [ordered]@{ Name = "BP-029 server user"; Path = "tools\check_server_user.py" },
    [ordered]@{ Name = "BP-029 world/physics closure"; Path = "tools\check_world_physics_closure.py" }
  )
  foreach ($Checker in $WorldPhysicsCheckers) {
    $CheckerPath = Join-Path $Root $Checker.Path
    if (-not (Test-Path -LiteralPath $CheckerPath -PathType Leaf)) {
      throw ($Checker.Name + " checker is missing: " + $CheckerPath)
    }
    $CheckerArguments = @($Root)
    if ($Checker.Path -eq "tools\check_world_physics_closure.py") {
      $CheckerArguments += "--allow-downstream-package"
    }
    & $PythonExe @PythonPrefixArgs $CheckerPath @CheckerArguments
    if ($LASTEXITCODE -ne 0) { throw ($PackageId + " " + $Checker.Name + " preflight failed.") }
  }

  $HostLifecycleCheckers = @(
    [ordered]@{ Name = "BP-030 host timing"; Path = "tools\check_host_timing.py" },
    [ordered]@{ Name = "BP-031 command/cvar lifecycle"; Path = "tools\check_command_cvar.py" },
    [ordered]@{ Name = "BP-032 demo lifecycle"; Path = "tools\check_demo_lifecycle.py" },
    [ordered]@{ Name = "BP-033 savegame v5"; Path = "tools\check_savegame_v5.py" },
    [ordered]@{ Name = "BP-034 host lifecycle closure"; Path = "tools\check_host_lifecycle_closure.py" }
  )
  foreach ($Checker in $HostLifecycleCheckers) {
    $CheckerPath = Join-Path $Root $Checker.Path
    if (-not (Test-Path -LiteralPath $CheckerPath -PathType Leaf)) {
      throw ($Checker.Name + " checker is missing: " + $CheckerPath)
    }
    $CheckerArguments = @("--root", $Root)
    if ($Checker.Path -eq "tools\check_command_cvar.py" -or
        $Checker.Path -eq "tools\check_savegame_v5.py") {
      $CheckerArguments += "--allow-downstream-package"
    }
    & $PythonExe @PythonPrefixArgs $CheckerPath @CheckerArguments
    if ($LASTEXITCODE -ne 0) { throw ($PackageId + " " + $Checker.Name + " preflight failed.") }
  }

  $ClientRenderCheckers = @(
    [ordered]@{ Name = "BP-035 client state/render"; Path = "tools\check_client_render_035.py" },
    [ordered]@{ Name = "BP-036 view state"; Path = "tools\check_client_render_036.py" },
    [ordered]@{ Name = "BP-037 temporary beam render"; Path = "tools\check_client_render_037.py" },
    [ordered]@{ Name = "BP-038 particle runtime"; Path = "tools\check_client_render_038.py" },
    [ordered]@{ Name = "BP-039 client/render closure"; Path = "tools\check_client_render_039.py" }
  )
  foreach ($Checker in $ClientRenderCheckers) {
    $CheckerPath = Join-Path $Root $Checker.Path
    if (-not (Test-Path -LiteralPath $CheckerPath -PathType Leaf)) {
      throw ($Checker.Name + " checker is missing: " + $CheckerPath)
    }
    $CheckerArguments = @("--root", $Root)
    if ($Checker.Path -eq "tools\check_client_render_036.py") {
      $CheckerArguments += "--allow-downstream-package"
    }
    & $PythonExe @PythonPrefixArgs $CheckerPath @CheckerArguments
    if ($LASTEXITCODE -ne 0) { throw ($PackageId + " " + $Checker.Name + " preflight failed.") }
  }

  $WorldRenderCheckers = @(
    [ordered]@{ Name = "BP-040 world surfaces"; Path = "tools\check_world_render_040.py" },
    [ordered]@{ Name = "BP-041 lightmap atlas"; Path = "tools\check_world_render_041.py" },
    [ordered]@{ Name = "BP-042 dynamic lights"; Path = "tools\check_world_render_042.py" },
    [ordered]@{ Name = "BP-043 sky/water"; Path = "tools\check_world_render_043.py" },
    [ordered]@{ Name = "BP-044 world/render closure"; Path = "tools\check_world_render_044.py" }
  )
  foreach ($Checker in $WorldRenderCheckers) {
    $CheckerPath = Join-Path $Root $Checker.Path
    if (-not (Test-Path -LiteralPath $CheckerPath -PathType Leaf)) {
      throw ($Checker.Name + " checker is missing: " + $CheckerPath)
    }
    & $PythonExe @PythonPrefixArgs $CheckerPath --root $Root
    if ($LASTEXITCODE -ne 0) { throw ($PackageId + " " + $Checker.Name + " preflight failed.") }
  }

  $ModelUiRenderCheckers = @(
    [ordered]@{ Name = "BP-045 alias model"; Path = "tools\bp045_alias_model_checker.py" },
    [ordered]@{ Name = "BP-046 sprite sync"; Path = "tools\bp046_sprite_sync_checker.py" },
    [ordered]@{ Name = "BP-047 2D/HUD"; Path = "tools\bp047_render_ui_checker.py" },
    [ordered]@{ Name = "BP-048 render evidence"; Path = "tools\bp048_render_evidence_checker.py" },
    [ordered]@{ Name = "BP-049 model/UI/render closure"; Path = "tools\bp049_model_ui_render_checker.py" }
  )
  foreach ($Checker in $ModelUiRenderCheckers) {
    $CheckerPath = Join-Path $Root $Checker.Path
    if (-not (Test-Path -LiteralPath $CheckerPath -PathType Leaf)) {
      throw ($Checker.Name + " checker is missing: " + $CheckerPath)
    }
    & $PythonExe @PythonPrefixArgs $CheckerPath
    if ($LASTEXITCODE -ne 0) { throw ($PackageId + " " + $Checker.Name + " preflight failed.") }
  }
  & $PythonExe @PythonPrefixArgs (Join-Path $Root "tools\compare_render_evidence.py") --self-test
  if ($LASTEXITCODE -ne 0) { throw "$PackageId render evidence comparator self-test failed." }

  $RenderSpecialCheckers = @(
    [ordered]@{ Name = "BP-050 mirror special render"; Path = "tools\check_render_special_050.py" },
    [ordered]@{ Name = "BP-051 render clear special"; Path = "tools\check_render_special_051.py" },
    [ordered]@{ Name = "BP-052 envmap/timerefresh"; Path = "tools\check_render_special_052.py" },
    [ordered]@{ Name = "BP-053 render-evidence corpus"; Path = "tools\check_render_special_053.py" },
    [ordered]@{ Name = "BP-054 render-special closure"; Path = "tools\check_render_special_054.py" }
  )
  foreach ($Checker in $RenderSpecialCheckers) {
    $CheckerPath = Join-Path $Root $Checker.Path
    if (-not (Test-Path -LiteralPath $CheckerPath -PathType Leaf)) {
      throw ($Checker.Name + " checker is missing: " + $CheckerPath)
    }
    $CheckerArguments = @($CheckerPath, "--root", $Root)
    if ($Checker.Name -eq "BP-054 render-special closure") {
      $CheckerArguments += "--allow-downstream-package"
    }
    & $PythonExe @PythonPrefixArgs @CheckerArguments
    if ($LASTEXITCODE -ne 0) { throw ($PackageId + " " + $Checker.Name + " preflight failed.") }
  }
  & $PythonExe @PythonPrefixArgs (Join-Path $Root "tools\compare_render_corpus.py") --root $Root --self-test
  if ($LASTEXITCODE -ne 0) { throw "$PackageId render-evidence corpus comparator self-test failed." }

  $AudioCheckers = @(
    [ordered]@{ Name = "BP-055 audio memory"; Path = "tools\check_audio_055.py" },
    [ordered]@{ Name = "BP-056 audio DMA"; Path = "tools\check_audio_056.py" },
    [ordered]@{ Name = "BP-057 audio mixer"; Path = "tools\check_audio_057.py" },
    [ordered]@{ Name = "BP-058 audio Win32"; Path = "tools\check_audio_058.py" },
    [ordered]@{ Name = "BP-059 audio closure"; Path = "tools\check_audio_059.py" }
  )
  foreach ($Checker in $AudioCheckers) {
    $CheckerPath = Join-Path $Root $Checker.Path
    if (-not (Test-Path -LiteralPath $CheckerPath -PathType Leaf)) {
      throw ($Checker.Name + " checker is missing: " + $CheckerPath)
    }
    & $PythonExe @PythonPrefixArgs $CheckerPath --root $Root
    if ($LASTEXITCODE -ne 0) { throw ($PackageId + " " + $Checker.Name + " preflight failed.") }
  }

  $NetworkPlatformCheckers = @(
    [ordered]@{ Name = "BP-060 network main"; Path = "tools\check_network_060.py" },
    [ordered]@{ Name = "BP-061 network control"; Path = "tools\check_network_061.py" },
    [ordered]@{ Name = "BP-062 WinSock address"; Path = "tools\check_network_062.py" },
    [ordered]@{ Name = "BP-063 system/platform"; Path = "tools\check_network_063.py" },
    [ordered]@{ Name = "BP-064 network/platform closure"; Path = "tools\check_network_064.py" }
  )
  foreach ($Checker in $NetworkPlatformCheckers) {
    $CheckerPath = Join-Path $Root $Checker.Path
    if (-not (Test-Path -LiteralPath $CheckerPath -PathType Leaf)) {
      throw ($Checker.Name + " checker is missing: " + $CheckerPath)
    }
    & $PythonExe @PythonPrefixArgs $CheckerPath --root $Root
    if ($LASTEXITCODE -ne 0) { throw ($PackageId + " " + $Checker.Name + " preflight failed.") }
  }

  $FrontendCheckers = @(
    [ordered]@{ Name = "BP-065 key/focus"; Path = "tools\check_frontend_065.py"; Arguments = @() },
    [ordered]@{ Name = "BP-066 input device"; Path = "tools\check_frontend_066.py"; Arguments = @() },
    [ordered]@{ Name = "BP-067 console/screen"; Path = "tools\check_frontend_067.py"; Arguments = @() },
    [ordered]@{ Name = "BP-068 menu lifecycle"; Path = "tools\check_frontend_068.py"; Arguments = @() },
    [ordered]@{ Name = "BP-069 frontend closure"; Path = "tools\check_frontend_069.py"; Arguments = @("--allow-downstream-package") }
  )
  foreach ($Checker in $FrontendCheckers) {
    $CheckerPath = Join-Path $Root $Checker.Path
    if (-not (Test-Path -LiteralPath $CheckerPath -PathType Leaf)) {
      throw ($Checker.Name + " checker is missing: " + $CheckerPath)
    }
    $CheckerArguments = @($Checker.Arguments)
    & $PythonExe @PythonPrefixArgs $CheckerPath --root $Root @CheckerArguments
    if ($LASTEXITCODE -ne 0) { throw ($PackageId + " " + $Checker.Name + " preflight failed.") }
  }

  $CoreAssetCheckers = @(
    [ordered]@{ Name = "BP-070 common/CRC"; Path = "tools\check_core_070.py" },
    [ordered]@{ Name = "BP-071 filesystem/PACK"; Path = "tools\check_asset_071.py" },
    [ordered]@{ Name = "BP-072 WAD/graphics"; Path = "tools\check_core_072.py" },
    [ordered]@{ Name = "BP-073 model assets"; Path = "tools\check_core_073.py" },
    [ordered]@{ Name = "BP-074 core assets/memory closure"; Path = "tools\check_core_074.py" }
  )
  foreach ($Checker in $CoreAssetCheckers) {
    $CheckerPath = Join-Path $Root $Checker.Path
    if (-not (Test-Path -LiteralPath $CheckerPath -PathType Leaf)) {
      throw ($Checker.Name + " checker is missing: " + $CheckerPath)
    }
    & $PythonExe @PythonPrefixArgs $CheckerPath --root $Root
    if ($LASTEXITCODE -ne 0) { throw ($PackageId + " " + $Checker.Name + " preflight failed.") }
  }

  $GameplayPresentationCheckers = @(
    [ordered]@{ Name = "BP-075 math/chase"; Path = "tools\check_gameplay_075.py" },
    [ordered]@{ Name = "BP-076 view/palette"; Path = "tools\check_gameplay_076.py" },
    [ordered]@{ Name = "BP-077 screen/loading"; Path = "tools\check_gameplay_077.py" },
    [ordered]@{ Name = "BP-078 statusbar/scoreboard"; Path = "tools\check_gameplay_078.py" },
    [ordered]@{ Name = "BP-079 gameplay/presentation closure"; Path = "tools\check_gameplay_079.py" }
  )
  foreach ($Checker in $GameplayPresentationCheckers) {
    $CheckerPath = Join-Path $Root $Checker.Path
    if (-not (Test-Path -LiteralPath $CheckerPath -PathType Leaf)) {
      throw ($Checker.Name + " checker is missing: " + $CheckerPath)
    }
    & $PythonExe @PythonPrefixArgs $CheckerPath --root $Root
    if ($LASTEXITCODE -ne 0) { throw ($PackageId + " " + $Checker.Name + " preflight failed.") }
  }

  $SourceClosureCheckers = @(
    [ordered]@{ Name = "BP-080 cvar source surface"; Path = "tools\check_source_080.py" },
    [ordered]@{ Name = "BP-081 CD audio source surface"; Path = "tools\check_source_081.py" },
    [ordered]@{ Name = "BP-082 source function inventory"; Path = "tools\check_source_082.py" },
    [ordered]@{ Name = "BP-083 black-port corpus"; Path = "tools\check_source_083.py" },
    [ordered]@{ Name = "BP-084 source black-port closure"; Path = "tools\check_source_084.py" }
  )
  foreach ($Checker in $SourceClosureCheckers) {
    $CheckerPath = Join-Path $Root $Checker.Path
    if (-not (Test-Path -LiteralPath $CheckerPath -PathType Leaf)) {
      throw ($Checker.Name + " checker is missing: " + $CheckerPath)
    }
    $ReportName = ([IO.Path]::GetFileNameWithoutExtension($Checker.Path) + "-report.json")
    $ReportPath = Join-Path $Output $ReportName
    $CheckerArgs = @("--root", $Root, "--json", $ReportPath)
    if ($Checker.Path -eq "tools\check_source_084.py") { $CheckerArgs += "--allow-downstream-package" }
    & $PythonExe @PythonPrefixArgs $CheckerPath @CheckerArgs
    if ($LASTEXITCODE -ne 0) { throw ($PackageId + " " + $Checker.Name + " preflight failed.") }
  }

  $CompatibilityCheckers = @(
    [ordered]@{ Name = "BP-085 game profile"; Path = "tools\check_compat_085.py" },
    [ordered]@{ Name = "BP-086 mod runtime"; Path = "tools\check_compat_086.py" },
    [ordered]@{ Name = "BP-087 artifact compatibility"; Path = "tools\check_compat_087.py" },
    [ordered]@{ Name = "BP-088 stability"; Path = "tools\check_compat_088.py" },
    [ordered]@{ Name = "BP-089 compatibility release"; Path = "tools\check_compat_089.py" }
  )
  foreach ($Checker in $CompatibilityCheckers) {
    $CheckerPath = Join-Path $Root $Checker.Path
    if (-not (Test-Path -LiteralPath $CheckerPath -PathType Leaf)) { throw ($Checker.Name + " checker is missing: " + $CheckerPath) }
    $ReportName = ([IO.Path]::GetFileNameWithoutExtension($Checker.Path) + "-report.json")
    $ReportPath = Join-Path $Output $ReportName
    $CheckerArgs = @("--root", $Root, "--json", $ReportPath, "--allow-downstream-package")
    & $PythonExe @PythonPrefixArgs $CheckerPath @CheckerArgs
    if ($LASTEXITCODE -ne 0) { throw ($PackageId + " " + $Checker.Name + " preflight failed.") }
  }


  $ExternalReferenceCheckers = @(
    [ordered]@{ Name = "BP-090 original reference"; Path = "tools\check_external_090.py" },
    [ordered]@{ Name = "BP-091 original server interop"; Path = "tools\check_external_091.py" },
    [ordered]@{ Name = "BP-092 original client interop"; Path = "tools\check_external_092.py" },
    [ordered]@{ Name = "BP-093 original visual reference"; Path = "tools\check_external_093.py" },
    [ordered]@{ Name = "BP-094 external compatibility closure"; Path = "tools\check_external_094.py" }
  )
  foreach ($Checker in $ExternalReferenceCheckers) {
    $CheckerPath = Join-Path $Root $Checker.Path
    if (-not (Test-Path -LiteralPath $CheckerPath -PathType Leaf)) { throw ($Checker.Name + " checker is missing: " + $CheckerPath) }
    $ReportName = ([IO.Path]::GetFileNameWithoutExtension($Checker.Path) + "-report.json")
    $ReportPath = Join-Path $Output $ReportName
    & $PythonExe @PythonPrefixArgs $CheckerPath --root $Root --json $ReportPath
    if ($LASTEXITCODE -ne 0) { throw ($PackageId + " " + $Checker.Name + " preflight failed.") }
  }
} elseif ($SkipPreflight) {
  Write-Warning "$PackageId diagnostics preflight was explicitly skipped."
} else {
  Write-Warning "$PackageId static diagnostics preflight requires Python and is skipped for the native compiler. Pass -Python PATH or run 'python tools\verify.py --root .' separately."
}

if ($RebuildNative) {
  $VorbisSource = Join-Path $Root "third_party\stb\stb_vorbis.c"
  if (Test-Path -LiteralPath $VorbisSource -PathType Leaf) {
    Write-Host "[MiniQuake] rebuilding full native bridge"
    & $PythonExe @PythonPrefixArgs (Join-Path $Root "native\build_bridge.py") "--clean"
    if ($LASTEXITCODE -ne 0) {
      exit $LASTEXITCODE
    }
  } else {
    Write-Warning "The supplied baseline does not contain third_party\stb\stb_vorbis.c; retaining the verified prebuilt miniquake_native.dll."
  }

  Write-Host "[MiniQuake] rebuilding reproducible buffered text bridge"
  & $PythonExe @PythonPrefixArgs (Join-Path $Root "native\build_text_bridge.py") "--clean"
  if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
  }
}

# Copy a rebuilt native bridge only when its bytes changed.
function Copy-NativeBridgeIfChanged {
  param(
    [Parameter(Mandatory = $true)]
    [string]$FileName
  )

  $SourceBridge = Join-Path $Root ("native\" + $FileName)
  if (-not (Test-Path -LiteralPath $SourceBridge -PathType Leaf)) {
    throw "Native bridge is missing: $SourceBridge"
  }

  $OutputBridge = Join-Path $Output $FileName
  $CopyBridge = $true
  if (Test-Path -LiteralPath $OutputBridge -PathType Leaf) {
    $SourceBridgeHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $SourceBridge).Hash
    $OutputBridgeHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $OutputBridge).Hash
    $CopyBridge = $SourceBridgeHash -ne $OutputBridgeHash
  }
  if ($CopyBridge) {
    Copy-Item -Force -LiteralPath $SourceBridge -Destination $OutputBridge
  }
}

Copy-NativeBridgeIfChanged "miniquake_native.dll"
Copy-NativeBridgeIfChanged "miniquake_text.dll"

$CommonArgs = @(
  "-I", $Source,
  "-I", $StdImportRoot,
  "--keep-going", "--max-errors", "50",
  # Retail maps keep the BSP, alias frames and renderer command caches live at
  # once, so reserve a 2 GiB address range while committing only the 512 MiB
  # normally needed by one loaded game. The heap can grow in 64 MiB steps for
  # unusually large mods. Host_Init's bounded periodic collection prevents
  # per-frame temporaries from consuming the complete reservation; committing
  # all 2 GiB up front made two multiplayer windows exhaust the machine's
  # commit budget and appear frozen immediately after joining.
  "--heap-reserve", "2g",
  "--heap-commit", "512m",
  "--heap-grow", "64m",
  "--gc-limit", "256m"
)

if ($Configuration -ieq "Debug") {
  $CommonArgs += @("--trace-calls")
}
if ($Listings) {
  $CommonArgs += @("--asm", "--asm-pe", "--asm-data")
}

$Opt001CR3HotpathExe = Join-Path $Output "MiniQuakeOPT001CR3HotpathTests.exe"
Write-Host "[MiniQuake] compiling $Opt001CR3HotpathExe"
Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\opt001cr3_hotpath_tests.ml") -OutputFile $Opt001CR3HotpathExe -CompilerArguments $CommonArgs -Label "opt001cr3-hotpath-tests"

$GameExe = Join-Path $Output "MiniQuake.exe"
Write-Host "[MiniQuake] compiling $GameExe"
Invoke-MiniLangCompile -InputFile (Join-Path $Source "main.ml") -OutputFile $GameExe -CompilerArguments $CommonArgs -Label "game"

$Opt001AContractExe = Join-Path $Output "MiniQuakeOPT001AContractTests.exe"
Write-Host "[MiniQuake] compiling $Opt001AContractExe"
Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\opt001a_contract_tests.ml") -OutputFile $Opt001AContractExe -CompilerArguments $CommonArgs -Label "opt001a-contract-tests"

$Opt001BContractExe = Join-Path $Output "MiniQuakeOPT001BCorrectnessTests.exe"
Write-Host "[MiniQuake] compiling $Opt001BContractExe"
Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\opt001b_contract_tests.ml") -OutputFile $Opt001BContractExe -CompilerArguments $CommonArgs -Label "opt001b-correctness-tests"

$Opt001CContractExe = Join-Path $Output "MiniQuakeOPT001CAllocationTests.exe"
Write-Host "[MiniQuake] compiling $Opt001CContractExe"
Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\opt001c_contract_tests.ml") -OutputFile $Opt001CContractExe -CompilerArguments $CommonArgs -Label "opt001c-allocation-tests"


if (-not $NoRunTests) {
  Write-Host "[MiniQuake] checking executable package identity"
  $VersionResult = Invoke-LiveCapturedProcess -Executable $GameExe -Arguments @("--version") -LogPath (Join-Path $Output "bp090-094-build-version.txt")
  $VersionOutput = @($VersionResult.lines)
  $VersionExitCode = [int]$VersionResult.exit_code
  if ($VersionExitCode -ne 0) {
    throw "MiniQuake --version failed with exit code $VersionExitCode."
  }
  if (-not (($VersionOutput -join "`n") -match [regex]::Escape("Package: $PackageId"))) {
    throw "Compiled executable does not identify itself as $PackageId."
  }
  if (-not (($VersionOutput -join "`n") -match [regex]::Escape("Parent package: $ParentPackageId"))) {
    throw "Compiled executable does not identify parent package $ParentPackageId."
  }
  if (-not (($VersionOutput -join "`n") -match [regex]::Escape("Native text ABI: $NativeTextAbi"))) {
    throw "Compiled executable does not identify native text ABI $NativeTextAbi."
  }
  if (-not (($VersionOutput -join "`n") -match [regex]::Escape("Protocol text ABI: $ProtocolTextAbi"))) {
    throw "Compiled executable does not identify Protocol text ABI $ProtocolTextAbi."
  }
  if (-not (($VersionOutput -join "`n") -match [regex]::Escape("Block: $BlockId"))) {
    throw "Compiled executable does not identify block $BlockId."
  }
  if (-not (($VersionOutput -join "`n") -match [regex]::Escape("Block parent package: $BlockParentPackageId"))) {
    throw "Compiled executable does not identify block parent $BlockParentPackageId."
  }
  if (-not (($VersionOutput -join "`n") -match [regex]::Escape("Protocol status: $ProtocolStatus"))) {
    throw "Compiled executable does not identify Protocol status $ProtocolStatus."
  }
  if (-not (($VersionOutput -join "`n") -match [regex]::Escape("QuakeC status: $QuakeCStatus"))) {
    throw "Compiled executable does not identify QuakeC status $QuakeCStatus."
  }
  if (-not (($VersionOutput -join "`n") -match [regex]::Escape("World/physics status: $WorldPhysicsStatus"))) {
    throw "Compiled executable does not identify world/physics status $WorldPhysicsStatus."
  }
  if (-not (($VersionOutput -join "`n") -match [regex]::Escape("Host/lifecycle status: $HostLifecycleStatus"))) {
    throw "Compiled executable does not identify host/lifecycle status $HostLifecycleStatus."
  }
  if (-not (($VersionOutput -join "`n") -match [regex]::Escape("Client/render status: $ClientRenderStatus"))) {
    throw "Compiled executable does not identify client/render status $ClientRenderStatus."
  }
  if (-not (($VersionOutput -join "`n") -match [regex]::Escape("World/render status: $WorldRenderStatus"))) {
    throw "Compiled executable does not identify world/render status $WorldRenderStatus."
  }
  if (-not (($VersionOutput -join "`n") -match [regex]::Escape("Model/UI/render status: $ModelUiRenderStatus"))) {
    throw "Compiled executable does not identify model/UI/render status $ModelUiRenderStatus."
  }
  if (-not (($VersionOutput -join "`n") -match [regex]::Escape("Render-special status: $RenderSpecialStatus"))) {
    throw "Compiled executable does not identify render-special status $RenderSpecialStatus."
  }
  if (-not (($VersionOutput -join "`n") -match [regex]::Escape("Audio status: $AudioStatus"))) {
    throw "Compiled executable does not identify audio status $AudioStatus."
  }
  if (-not (($VersionOutput -join "`n") -match [regex]::Escape("Network/platform status: $NetworkPlatformStatus"))) {
    throw "Compiled executable does not identify network/platform status $NetworkPlatformStatus."
  }
  if (-not (($VersionOutput -join "`n") -match [regex]::Escape("Frontend status: $FrontendStatus"))) {
    throw "Compiled executable does not identify frontend status $FrontendStatus."
  }
  if (-not (($VersionOutput -join "`n") -match [regex]::Escape("Core assets/memory status: $CoreAssetsMemoryStatus"))) {
    throw "Compiled executable does not identify core assets/memory status $CoreAssetsMemoryStatus."
  }
  if (-not (($VersionOutput -join "`n") -match [regex]::Escape("Core assets/memory fingerprint: 0x6c8d974d"))) {
    throw "Compiled executable does not identify core assets/memory fingerprint 0x6c8d974d."
  }
  if (-not (($VersionOutput -join "`n") -match [regex]::Escape("Gameplay/presentation status: $GameplayPresentationStatus"))) {
    throw "Compiled executable does not identify gameplay/presentation status $GameplayPresentationStatus."
  }
  if (-not (($VersionOutput -join "`n") -match [regex]::Escape("Gameplay/presentation fingerprint: 0xad91624c"))) {
    throw "Compiled executable does not identify gameplay/presentation fingerprint 0xad91624c."
  }
  if (-not (($VersionOutput -join "`n") -match [regex]::Escape("Black-port source status: $BlackPortSourceStatus"))) {
    throw "Compiled executable does not identify black-port source status $BlackPortSourceStatus."
  }
  if (-not (($VersionOutput -join "`n") -match [regex]::Escape("Black-port source fingerprint: 0x309b0737"))) {
    throw "Compiled executable does not identify black-port source fingerprint 0x309b0737."
  }
  if (-not (($VersionOutput -join "`n") -match [regex]::Escape("Original reference status: $OriginalReferenceStatus"))) {
    throw "Compiled executable does not identify original reference status $OriginalReferenceStatus."
  }
  if (-not (($VersionOutput -join "`n") -match [regex]::Escape("Original reference fingerprint: 0xdc355175"))) {
    throw "Compiled executable does not identify original reference fingerprint 0xdc355175."
  }
  if (-not (($VersionOutput -join "`n") -match [regex]::Escape("Final compatibility status: $CompatFinalStatus"))) {
    throw "Compiled executable does not identify final compatibility status $CompatFinalStatus."
  }
  if (-not (($VersionOutput -join "`n") -match [regex]::Escape("Final compatibility fingerprint: 0xe04a7727"))) {
    throw "Compiled executable does not identify final compatibility fingerprint 0xe04a7727."
  }
}

# Extract the first actionable failure marker from a runtime log.
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

# Run a MiniQuake test binary and validate its process result.
function Invoke-MiniQuakeTestBinary {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Label,

    [Parameter(Mandatory = $true)]
    [string]$Executable,

    [Parameter(Mandatory = $true)]
    [string]$ProgressHint
  )

  Write-Host "[MiniQuake] running $Label"
  $SafeLabel = ($Label -replace "[^A-Za-z0-9._-]", "-").Trim([char[]]@('-'))
  if ([string]::IsNullOrWhiteSpace($SafeLabel)) { $SafeLabel = "runtime-test" }
  $RuntimeLogPath = Join-Path $Output ("run-{0}.log" -f $SafeLabel)
  $RuntimeResult = Invoke-LiveCapturedProcess -Executable $Executable -Arguments @() -LogPath $RuntimeLogPath
  $ExitCode = [int]$RuntimeResult.exit_code
  $OutputText = [string]$RuntimeResult.text
  $FailureMarker = Get-RuntimeTestFailureMarker $OutputText
  if ($ExitCode -eq 0 -and -not [string]::IsNullOrWhiteSpace($FailureMarker)) {
    $ExitCode = 1
    Write-Host "ERROR: MiniQuake $Label emitted a failure marker despite exit code 0: $FailureMarker" -ForegroundColor Red
  }
  $ExitUnsigned = [System.BitConverter]::ToUInt32(
    [System.BitConverter]::GetBytes($ExitCode),
    0
  )
  $ExitHex = "0x{0:X8}" -f $ExitUnsigned
  Write-Host "[MiniQuake] $Label exit code: $ExitCode ($ExitHex)"
  if ($ExitCode -ne 0) {
    Write-Host "ERROR: MiniQuake $Label did not complete successfully. $ProgressHint" -ForegroundColor Red
    exit $ExitCode
  }
}

$CoreTestStatus = "SKIPPED"
$MilestoneTestStatus = "SKIPPED"
$DiagnosticsTestStatus = "SKIPPED"
$ProtocolTestStatus = "SKIPPED"
$ProtocolCommandTestStatus = "SKIPPED"
$ProtocolServerDataTestStatus = "SKIPPED"
$ProtocolEventTestStatus = "SKIPPED"
$ProtocolRuntimeEventTestStatus = "SKIPPED"
$ProtocolSignonTestStatus = "SKIPPED"
$ProtocolDeliveryTestStatus = "SKIPPED"
$ProtocolDatagramTestStatus = "SKIPPED"
$ProtocolDemoTestStatus = "SKIPPED"
$ProtocolClosureTestStatus = "SKIPPED"
$QuakeCProgsTestStatus = "SKIPPED"
$QuakeCVMTestStatus = "SKIPPED"
$QuakeCEdictTestStatus = "SKIPPED"
$QuakeCBuiltinTestStatus = "SKIPPED"
$QuakeCClosureTestStatus = "SKIPPED"
$QuakeCStockTestStatus = "SKIPPED"
$WorldHullTestStatus = "SKIPPED"
$WorldTraceTestStatus = "SKIPPED"
$WorldLinkTestStatus = "SKIPPED"
$ServerMoveTestStatus = "SKIPPED"
$ServerPhysicsTestStatus = "SKIPPED"
$SvUserMovementTestStatus = "SKIPPED"
$BackwardMovementRetailTestStatus = "SKIPPED"
$CheatRetailTestStatus = "SKIPPED"
$BossVisibilityRetailTestStatus = "SKIPPED"
$PlayerCollisionTelefragRetailTestStatus = "SKIPPED"
$ServerUserTestStatus = "SKIPPED"
$WorldPhysicsClosureTestStatus = "SKIPPED"
$HostTimingTestStatus = "SKIPPED"
$CommandCvarTestStatus = "SKIPPED"
$HostCommandTestStatus = "SKIPPED"
$DemoLifecycleTestStatus = "SKIPPED"
$SavegameV5TestStatus = "SKIPPED"
$HostLifecycleClosureTestStatus = "SKIPPED"
$ClientStateRenderTestStatus = "SKIPPED"
$ViewStateTestStatus = "SKIPPED"
$TemporaryBeamTestStatus = "SKIPPED"
$ParticleRuntimeTestStatus = "SKIPPED"
$ClientRenderClosureTestStatus = "SKIPPED"
$WorldSurfaceRenderTestStatus = "SKIPPED"
$LightmapAtlasTestStatus = "SKIPPED"
$DynamicLightRenderTestStatus = "SKIPPED"
$SkyWaterRenderTestStatus = "SKIPPED"
$WorldRenderClosureTestStatus = "SKIPPED"
$AliasModelTestStatus = "SKIPPED"
$SpriteSyncTestStatus = "SKIPPED"
$RenderUiHudTestStatus = "SKIPPED"
$RenderEvidenceTestStatus = "SKIPPED"
$ModelUiRenderClosureTestStatus = "SKIPPED"
$MirrorSpecialTestStatus = "SKIPPED"
$RenderClearSpecialTestStatus = "SKIPPED"
$EnvmapTimeRefreshTestStatus = "SKIPPED"
$RenderEvidenceCorpusTestStatus = "SKIPPED"
$RenderSpecialClosureTestStatus = "SKIPPED"
$AudioMemoryTestStatus = "SKIPPED"
$AudioDmaTestStatus = "SKIPPED"
$AudioMixerTestStatus = "SKIPPED"
$AudioWinTestStatus = "SKIPPED"
$AudioClosureTestStatus = "SKIPPED"
$AudioRetailEvidenceStatus = "SKIPPED"
$NetworkMainTestStatus = "SKIPPED"
$NetworkControlTestStatus = "SKIPPED"
$NetworkWinsAddressTestStatus = "SKIPPED"
$SystemPlatformTestStatus = "SKIPPED"
$NetworkPlatformClosureTestStatus = "SKIPPED"
$NetworkPlatformEvidenceStatus = "SKIPPED"
$KeyFocusTestStatus = "SKIPPED"
$InputDeviceTestStatus = "SKIPPED"
$ConsoleScreenTestStatus = "SKIPPED"
$MenuLifecycleTestStatus = "SKIPPED"
$FrontendClosureTestStatus = "SKIPPED"
$CommonCoreTestStatus = "SKIPPED"
$FilesystemPackTestStatus = "SKIPPED"
$WadGraphicsTestStatus = "SKIPPED"
$ModelAssetTestStatus = "SKIPPED"
$CoreAssetsMemoryTestStatus = "SKIPPED"
$CoreAssetRetailEvidenceStatus = "SKIPPED"
$GameplayMathChaseTestStatus = "SKIPPED"
$GameplayViewTestStatus = "SKIPPED"
$GameplayScreenTestStatus = "SKIPPED"
$GameplayStatusbarTestStatus = "SKIPPED"
$GameplayPresentationClosureTestStatus = "SKIPPED"
$CvarSourceSurfaceTestStatus = "SKIPPED"
$CdAudioSourceSurfaceTestStatus = "SKIPPED"
$SourceFunctionInventoryTestStatus = "SKIPPED"
$BlackPortCorpusTestStatus = "SKIPPED"
$BlackPortSourceClosureTestStatus = "SKIPPED"
$GameProfileTestStatus = "SKIPPED"
$ModRuntimeTestStatus = "SKIPPED"
$ArtifactCompatTestStatus = "SKIPPED"
$StabilityTestStatus = "SKIPPED"
$CompatibilityReleaseTestStatus = "SKIPPED"
$OriginalReferenceTestStatus = "SKIPPED"
$OriginalServerInteropTestStatus = "SKIPPED"
$OriginalClientInteropTestStatus = "SKIPPED"
$OriginalVisualReferenceTestStatus = "SKIPPED"
$ExternalCompatibilityClosureTestStatus = "SKIPPED"
$ArtifactRetailEvidenceStatus = "SKIPPED"
$NetworkTestStatus = "SKIPPED"

if (-not $SkipTests) {
  $TestExe = Join-Path $Output "MiniQuakeTests.exe"
  Write-Host "[MiniQuake] compiling $TestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\core_tests.ml") -OutputFile $TestExe -CompilerArguments $CommonArgs -Label "core-tests"
  $CoreTestStatus = "COMPILED"

  $MilestoneTestExe = $null
  if (-not $SkipMilestoneTests) {
    $MilestoneTestExe = Join-Path $Output "MiniQuakeMilestoneTests.exe"
    Write-Host "[MiniQuake] compiling $MilestoneTestExe"
    Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\milestone_tests.ml") -OutputFile $MilestoneTestExe -CompilerArguments $CommonArgs -Label "milestone-tests"
    $MilestoneTestStatus = "COMPILED"
  }

  $DiagnosticsTestExe = Join-Path $Output "MiniQuakeCompatTraceTests.exe"
  Write-Host "[MiniQuake] compiling $DiagnosticsTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\compat_trace_tests.ml") -OutputFile $DiagnosticsTestExe -CompilerArguments $CommonArgs -Label "diagnostics-tests"
  $DiagnosticsTestStatus = "COMPILED"

  $ProtocolTestExe = Join-Path $Output "MiniQuakeProtocol15WireTests.exe"
  Write-Host "[MiniQuake] compiling $ProtocolTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\protocol15_wire_tests.ml") -OutputFile $ProtocolTestExe -CompilerArguments $CommonArgs -Label "protocol15-wire-tests"
  $ProtocolTestStatus = "COMPILED"

  $ProtocolCommandTestExe = Join-Path $Output "MiniQuakeProtocol15CommandTests.exe"
  Write-Host "[MiniQuake] compiling $ProtocolCommandTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\protocol15_command_tests.ml") -OutputFile $ProtocolCommandTestExe -CompilerArguments $CommonArgs -Label "protocol15-command-tests"
  $ProtocolCommandTestStatus = "COMPILED"

  $ProtocolServerDataTestExe = Join-Path $Output "MiniQuakeProtocol15ServerDataTests.exe"
  Write-Host "[MiniQuake] compiling $ProtocolServerDataTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\protocol15_serverdata_tests.ml") -OutputFile $ProtocolServerDataTestExe -CompilerArguments $CommonArgs -Label "protocol15-serverdata-tests"
  $ProtocolServerDataTestStatus = "COMPILED"

  $ProtocolEventTestExe = Join-Path $Output "MiniQuakeProtocol15EventTests.exe"
  Write-Host "[MiniQuake] compiling $ProtocolEventTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\protocol15_event_tests.ml") -OutputFile $ProtocolEventTestExe -CompilerArguments $CommonArgs -Label "protocol15-event-tests"
  $ProtocolEventTestStatus = "COMPILED"

  $ProtocolRuntimeEventTestExe = Join-Path $Output "MiniQuakeProtocol15RuntimeEventTests.exe"
  Write-Host "[MiniQuake] compiling $ProtocolRuntimeEventTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\protocol15_runtime_event_tests.ml") -OutputFile $ProtocolRuntimeEventTestExe -CompilerArguments $CommonArgs -Label "protocol15-runtime-event-tests"
  $ProtocolRuntimeEventTestStatus = "COMPILED"

  $ProtocolSignonTestExe = Join-Path $Output "MiniQuakeProtocol15SignonTests.exe"
  Write-Host "[MiniQuake] compiling $ProtocolSignonTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\protocol15_signon_e2e_tests.ml") -OutputFile $ProtocolSignonTestExe -CompilerArguments $CommonArgs -Label "protocol15-signon-tests"
  $ProtocolSignonTestStatus = "COMPILED"

  $ProtocolDeliveryTestExe = Join-Path $Output "MiniQuakeProtocol15DeliveryTests.exe"
  Write-Host "[MiniQuake] compiling $ProtocolDeliveryTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\protocol15_delivery_tests.ml") -OutputFile $ProtocolDeliveryTestExe -CompilerArguments $CommonArgs -Label "protocol15-delivery-tests"
  $ProtocolDeliveryTestStatus = "COMPILED"

  $ProtocolDatagramTestExe = Join-Path $Output "MiniQuakeProtocol15DatagramTests.exe"
  Write-Host "[MiniQuake] compiling $ProtocolDatagramTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\protocol15_datagram_tests.ml") -OutputFile $ProtocolDatagramTestExe -CompilerArguments $CommonArgs -Label "protocol15-datagram-tests"
  $ProtocolDatagramTestStatus = "COMPILED"

  $ProtocolDemoTestExe = Join-Path $Output "MiniQuakeProtocol15DemoTests.exe"
  Write-Host "[MiniQuake] compiling $ProtocolDemoTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\protocol15_demo_tests.ml") -OutputFile $ProtocolDemoTestExe -CompilerArguments $CommonArgs -Label "protocol15-demo-tests"
  $ProtocolDemoTestStatus = "COMPILED"

  $ProtocolClosureTestExe = Join-Path $Output "MiniQuakeProtocol15ClosureTests.exe"
  Write-Host "[MiniQuake] compiling $ProtocolClosureTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\protocol15_closure_tests.ml") -OutputFile $ProtocolClosureTestExe -CompilerArguments $CommonArgs -Label "protocol15-closure-tests"
  $ProtocolClosureTestStatus = "COMPILED"

  $QuakeCProgsTestExe = Join-Path $Output "MiniQuakeQuakeCProgsTests.exe"
  Write-Host "[MiniQuake] compiling $QuakeCProgsTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\quakec_progs_tests.ml") -OutputFile $QuakeCProgsTestExe -CompilerArguments $CommonArgs -Label "quakec-progs-tests"
  $QuakeCProgsTestStatus = "COMPILED"

  $QuakeCVMTestExe = Join-Path $Output "MiniQuakeQuakeCVMTests.exe"
  Write-Host "[MiniQuake] compiling $QuakeCVMTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\quakec_vm_tests.ml") -OutputFile $QuakeCVMTestExe -CompilerArguments $CommonArgs -Label "quakec-vm-tests"
  $QuakeCVMTestStatus = "COMPILED"

  $QuakeCEdictTestExe = Join-Path $Output "MiniQuakeQuakeCEdictTests.exe"
  Write-Host "[MiniQuake] compiling $QuakeCEdictTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\quakec_edict_tests.ml") -OutputFile $QuakeCEdictTestExe -CompilerArguments $CommonArgs -Label "quakec-edict-tests"
  $QuakeCEdictTestStatus = "COMPILED"

  $QuakeCBuiltinTestExe = Join-Path $Output "MiniQuakeQuakeCBuiltinTests.exe"
  Write-Host "[MiniQuake] compiling $QuakeCBuiltinTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\quakec_builtin_tests.ml") -OutputFile $QuakeCBuiltinTestExe -CompilerArguments $CommonArgs -Label "quakec-builtin-tests"
  $QuakeCBuiltinTestStatus = "COMPILED"

  $QuakeCClosureTestExe = Join-Path $Output "MiniQuakeQuakeCClosureTests.exe"
  Write-Host "[MiniQuake] compiling $QuakeCClosureTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\quakec_closure_tests.ml") -OutputFile $QuakeCClosureTestExe -CompilerArguments $CommonArgs -Label "quakec-closure-tests"
  $QuakeCClosureTestStatus = "COMPILED"

  $QuakeCStockTestExe = Join-Path $Output "MiniQuakeQuakeCStockTests.exe"
  Write-Host "[MiniQuake] compiling $QuakeCStockTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\quakec_stock_tests.ml") -OutputFile $QuakeCStockTestExe -CompilerArguments $CommonArgs -Label "quakec-stock-tests"
  $QuakeCStockTestStatus = "COMPILED"

  $WorldHullTestExe = Join-Path $Output "MiniQuakeWorldHullTests.exe"
  Write-Host "[MiniQuake] compiling $WorldHullTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\world_hull_parity_tests.ml") -OutputFile $WorldHullTestExe -CompilerArguments $CommonArgs -Label "world-hull-tests"
  $WorldHullTestStatus = "COMPILED"

  $WorldTraceTestExe = Join-Path $Output "MiniQuakeWorldTraceTests.exe"
  Write-Host "[MiniQuake] compiling $WorldTraceTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\world_trace_parity_tests.ml") -OutputFile $WorldTraceTestExe -CompilerArguments $CommonArgs -Label "world-trace-tests"
  $WorldTraceTestStatus = "COMPILED"

  $WorldLinkTestExe = Join-Path $Output "MiniQuakeWorldLinkTests.exe"
  Write-Host "[MiniQuake] compiling $WorldLinkTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\world_link_collision_tests.ml") -OutputFile $WorldLinkTestExe -CompilerArguments $CommonArgs -Label "world-link-tests"
  $WorldLinkTestStatus = "COMPILED"

  $ServerMoveTestExe = Join-Path $Output "MiniQuakeServerMoveTests.exe"
  Write-Host "[MiniQuake] compiling $ServerMoveTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\server_move_parity_tests.ml") -OutputFile $ServerMoveTestExe -CompilerArguments $CommonArgs -Label "server-move-tests"
  $ServerMoveTestStatus = "COMPILED"

  $ServerPhysicsTestExe = Join-Path $Output "MiniQuakeServerPhysicsTests.exe"
  Write-Host "[MiniQuake] compiling $ServerPhysicsTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\server_physics_parity_tests.ml") -OutputFile $ServerPhysicsTestExe -CompilerArguments $CommonArgs -Label "server-physics-tests"
  $ServerPhysicsTestStatus = "COMPILED"

  $SvUserMovementTestExe = Join-Path $Output "MiniQuakeSvUserMovementTests.exe"
  Write-Host "[MiniQuake] compiling $SvUserMovementTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\sv_user_movement_parity_tests.ml") -OutputFile $SvUserMovementTestExe -CompilerArguments $CommonArgs -Label "sv-user-movement-tests"
  $SvUserMovementTestStatus = "COMPILED"

  # This retail-data executable is compiled by every test build and can be run
  # against a local Quake installation to exercise a real e1m1 -> e1m2 change.
  $BackwardMovementRetailTestExe = Join-Path $Output "MiniQuakeBackwardMovementRetailTests.exe"
  Write-Host "[MiniQuake] compiling $BackwardMovementRetailTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\backward_movement_retail_tests.ml") -OutputFile $BackwardMovementRetailTestExe -CompilerArguments $CommonArgs -Label "backward-movement-retail-tests"
  $BackwardMovementRetailTestStatus = "COMPILED"

  # Compile the retail stock-progs gate for god, give, impulse and the custom
  # AI-invisibility command. Acceptance jobs run it with local PAK data.
  $CheatRetailTestExe = Join-Path $Output "MiniQuakeCheatRetailTests.exe"
  Write-Host "[MiniQuake] compiling $CheatRetailTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\cheat_retail_tests.ml") -OutputFile $CheatRetailTestExe -CompilerArguments $CommonArgs -Label "cheat-retail-tests"
  $CheatRetailTestStatus = "COMPILED"

  # Compile the stock e1m7 activation gate that verifies boss_awake runtime
  # bounds reach PVS snapshot culling together with Chthon's model.
  $BossVisibilityRetailTestExe = Join-Path $Output "MiniQuakeBossVisibilityRetailTests.exe"
  Write-Host "[MiniQuake] compiling $BossVisibilityRetailTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\boss_visibility_retail_tests.ml") -OutputFile $BossVisibilityRetailTestExe -CompilerArguments $CommonArgs -Label "boss-visibility-retail-tests"
  $BossVisibilityRetailTestStatus = "COMPILED"

  # Compile the retail QuakeC gate that covers solid actor overlap recovery
  # and the stock spawn_tdeath/force_retouch telefrag path.
  $PlayerCollisionTelefragRetailTestExe = Join-Path $Output "MiniQuakePlayerCollisionTelefragRetailTests.exe"
  Write-Host "[MiniQuake] compiling $PlayerCollisionTelefragRetailTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\player_collision_telefrag_retail_tests.ml") -OutputFile $PlayerCollisionTelefragRetailTestExe -CompilerArguments $CommonArgs -Label "player-collision-telefrag-retail-tests"
  $PlayerCollisionTelefragRetailTestStatus = "COMPILED"

  $ServerUserTestExe = Join-Path $Output "MiniQuakeServerUserTests.exe"
  Write-Host "[MiniQuake] compiling $ServerUserTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\server_user_parity_tests.ml") -OutputFile $ServerUserTestExe -CompilerArguments $CommonArgs -Label "server-user-tests"
  $ServerUserTestStatus = "COMPILED"

  $WorldPhysicsClosureTestExe = Join-Path $Output "MiniQuakeWorldPhysicsClosureTests.exe"
  Write-Host "[MiniQuake] compiling $WorldPhysicsClosureTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\world_physics_closure_tests.ml") -OutputFile $WorldPhysicsClosureTestExe -CompilerArguments $CommonArgs -Label "world-physics-closure-tests"
  $WorldPhysicsClosureTestStatus = "COMPILED"

  $HostTimingTestExe = Join-Path $Output "MiniQuakeHostTimingTests.exe"
  Write-Host "[MiniQuake] compiling $HostTimingTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\host_timing_parity_tests.ml") -OutputFile $HostTimingTestExe -CompilerArguments $CommonArgs -Label "host-timing-tests"
  $HostTimingTestStatus = "COMPILED"

  $CommandCvarTestExe = Join-Path $Output "MiniQuakeCommandCvarTests.exe"
  Write-Host "[MiniQuake] compiling $CommandCvarTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\command_cvar_lifecycle_tests.ml") -OutputFile $CommandCvarTestExe -CompilerArguments $CommonArgs -Label "command-cvar-tests"
  $CommandCvarTestStatus = "COMPILED"

  $HostCommandTestExe = Join-Path $Output "MiniQuakeHostCommandTests.exe"
  Write-Host "[MiniQuake] compiling $HostCommandTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\host_cmd_tests.ml") -OutputFile $HostCommandTestExe -CompilerArguments $CommonArgs -Label "host-command-tests"
  $HostCommandTestStatus = "COMPILED"

  $DemoLifecycleTestExe = Join-Path $Output "MiniQuakeDemoLifecycleTests.exe"
  Write-Host "[MiniQuake] compiling $DemoLifecycleTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\demo_lifecycle_parity_tests.ml") -OutputFile $DemoLifecycleTestExe -CompilerArguments $CommonArgs -Label "demo-lifecycle-tests"
  $DemoLifecycleTestStatus = "COMPILED"

  $SavegameV5TestExe = Join-Path $Output "MiniQuakeSavegameV5Tests.exe"
  Write-Host "[MiniQuake] compiling $SavegameV5TestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\savegame_v5_parity_tests.ml") -OutputFile $SavegameV5TestExe -CompilerArguments $CommonArgs -Label "savegame-v5-tests"
  $SavegameV5TestStatus = "COMPILED"

  $HostLifecycleClosureTestExe = Join-Path $Output "MiniQuakeHostLifecycleClosureTests.exe"
  Write-Host "[MiniQuake] compiling $HostLifecycleClosureTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\host_lifecycle_closure_tests.ml") -OutputFile $HostLifecycleClosureTestExe -CompilerArguments $CommonArgs -Label "host-lifecycle-closure-tests"
  $HostLifecycleClosureTestStatus = "COMPILED"

  $ClientStateRenderTestExe = Join-Path $Output "MiniQuakeClientStateRenderTests.exe"
  Write-Host "[MiniQuake] compiling $ClientStateRenderTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\client_state_render_tests.ml") -OutputFile $ClientStateRenderTestExe -CompilerArguments $CommonArgs -Label "client-state-render-tests"
  $ClientStateRenderTestStatus = "COMPILED"

  $ViewStateTestExe = Join-Path $Output "MiniQuakeViewStateTests.exe"
  Write-Host "[MiniQuake] compiling $ViewStateTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\view_state_parity_tests.ml") -OutputFile $ViewStateTestExe -CompilerArguments $CommonArgs -Label "view-state-tests"
  $ViewStateTestStatus = "COMPILED"

  $TemporaryBeamTestExe = Join-Path $Output "MiniQuakeTemporaryBeamTests.exe"
  Write-Host "[MiniQuake] compiling $TemporaryBeamTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\temp_beam_render_tests.ml") -OutputFile $TemporaryBeamTestExe -CompilerArguments $CommonArgs -Label "temporary-beam-tests"
  $TemporaryBeamTestStatus = "COMPILED"

  $ParticleRuntimeTestExe = Join-Path $Output "MiniQuakeParticleRuntimeTests.exe"
  Write-Host "[MiniQuake] compiling $ParticleRuntimeTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\particle_runtime_parity_tests.ml") -OutputFile $ParticleRuntimeTestExe -CompilerArguments $CommonArgs -Label "particle-runtime-tests"
  $ParticleRuntimeTestStatus = "COMPILED"

  $ClientRenderClosureTestExe = Join-Path $Output "MiniQuakeClientRenderClosureTests.exe"
  Write-Host "[MiniQuake] compiling $ClientRenderClosureTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\client_render_closure_tests.ml") -OutputFile $ClientRenderClosureTestExe -CompilerArguments $CommonArgs -Label "client-render-closure-tests"
  $ClientRenderClosureTestStatus = "COMPILED"

  $WorldSurfaceRenderTestExe = Join-Path $Output "MiniQuakeWorldSurfaceRenderTests.exe"
  Write-Host "[MiniQuake] compiling $WorldSurfaceRenderTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\world_surface_render_tests.ml") -OutputFile $WorldSurfaceRenderTestExe -CompilerArguments $CommonArgs -Label "world-surface-render-tests"
  $WorldSurfaceRenderTestStatus = "COMPILED"

  $LightmapAtlasTestExe = Join-Path $Output "MiniQuakeLightmapAtlasTests.exe"
  Write-Host "[MiniQuake] compiling $LightmapAtlasTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\lightmap_atlas_tests.ml") -OutputFile $LightmapAtlasTestExe -CompilerArguments $CommonArgs -Label "lightmap-atlas-tests"
  $LightmapAtlasTestStatus = "COMPILED"

  $DynamicLightRenderTestExe = Join-Path $Output "MiniQuakeDynamicLightRenderTests.exe"
  Write-Host "[MiniQuake] compiling $DynamicLightRenderTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\dynamic_light_render_tests.ml") -OutputFile $DynamicLightRenderTestExe -CompilerArguments $CommonArgs -Label "dynamic-light-render-tests"
  $DynamicLightRenderTestStatus = "COMPILED"

  $SkyWaterRenderTestExe = Join-Path $Output "MiniQuakeSkyWaterRenderTests.exe"
  Write-Host "[MiniQuake] compiling $SkyWaterRenderTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\sky_water_render_tests.ml") -OutputFile $SkyWaterRenderTestExe -CompilerArguments $CommonArgs -Label "sky-water-render-tests"
  $SkyWaterRenderTestStatus = "COMPILED"

  $WorldRenderClosureTestExe = Join-Path $Output "MiniQuakeWorldRenderClosureTests.exe"
  Write-Host "[MiniQuake] compiling $WorldRenderClosureTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\world_render_closure_tests.ml") -OutputFile $WorldRenderClosureTestExe -CompilerArguments $CommonArgs -Label "world-render-closure-tests"
  $WorldRenderClosureTestStatus = "COMPILED"

  $AliasModelTestExe = Join-Path $Output "MiniQuakeAliasModelTests.exe"
  Write-Host "[MiniQuake] compiling $AliasModelTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\alias_model_parity_tests.ml") -OutputFile $AliasModelTestExe -CompilerArguments $CommonArgs -Label "alias-model-tests"
  $AliasModelTestStatus = "COMPILED"

  $SpriteSyncTestExe = Join-Path $Output "MiniQuakeSpriteSyncTests.exe"
  Write-Host "[MiniQuake] compiling $SpriteSyncTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\sprite_sync_parity_tests.ml") -OutputFile $SpriteSyncTestExe -CompilerArguments $CommonArgs -Label "sprite-sync-tests"
  $SpriteSyncTestStatus = "COMPILED"

  $RenderUiHudTestExe = Join-Path $Output "MiniQuakeRenderUiHudTests.exe"
  Write-Host "[MiniQuake] compiling $RenderUiHudTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\render_ui_hud_parity_tests.ml") -OutputFile $RenderUiHudTestExe -CompilerArguments $CommonArgs -Label "render-ui-hud-tests"
  $RenderUiHudTestStatus = "COMPILED"

  $RenderEvidenceTestExe = Join-Path $Output "MiniQuakeRenderEvidenceTests.exe"
  Write-Host "[MiniQuake] compiling $RenderEvidenceTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\render_evidence_tests.ml") -OutputFile $RenderEvidenceTestExe -CompilerArguments $CommonArgs -Label "render-evidence-tests"
  $RenderEvidenceTestStatus = "COMPILED"

  $ModelUiRenderClosureTestExe = Join-Path $Output "MiniQuakeModelUiRenderClosureTests.exe"
  Write-Host "[MiniQuake] compiling $ModelUiRenderClosureTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\model_ui_render_closure_tests.ml") -OutputFile $ModelUiRenderClosureTestExe -CompilerArguments $CommonArgs -Label "model-ui-render-closure-tests"
  $ModelUiRenderClosureTestStatus = "COMPILED"

  $MirrorSpecialTestExe = Join-Path $Output "MiniQuakeMirrorSpecialRenderTests.exe"
  Write-Host "[MiniQuake] compiling $MirrorSpecialTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\mirror_special_render_tests.ml") -OutputFile $MirrorSpecialTestExe -CompilerArguments $CommonArgs -Label "mirror-special-render-tests"
  $MirrorSpecialTestStatus = "COMPILED"

  $RenderClearSpecialTestExe = Join-Path $Output "MiniQuakeRenderClearSpecialTests.exe"
  Write-Host "[MiniQuake] compiling $RenderClearSpecialTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\render_clear_special_tests.ml") -OutputFile $RenderClearSpecialTestExe -CompilerArguments $CommonArgs -Label "render-clear-special-tests"
  $RenderClearSpecialTestStatus = "COMPILED"

  $EnvmapTimeRefreshTestExe = Join-Path $Output "MiniQuakeEnvmapTimeRefreshTests.exe"
  Write-Host "[MiniQuake] compiling $EnvmapTimeRefreshTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\envmap_timerefresh_tests.ml") -OutputFile $EnvmapTimeRefreshTestExe -CompilerArguments $CommonArgs -Label "envmap-timerefresh-tests"
  $EnvmapTimeRefreshTestStatus = "COMPILED"

  $RenderEvidenceCorpusTestExe = Join-Path $Output "MiniQuakeRenderEvidenceCorpusTests.exe"
  Write-Host "[MiniQuake] compiling $RenderEvidenceCorpusTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\render_evidence_corpus_tests.ml") -OutputFile $RenderEvidenceCorpusTestExe -CompilerArguments $CommonArgs -Label "render-evidence-corpus-tests"
  $RenderEvidenceCorpusTestStatus = "COMPILED"

  $RenderSpecialClosureTestExe = Join-Path $Output "MiniQuakeRenderSpecialClosureTests.exe"
  Write-Host "[MiniQuake] compiling $RenderSpecialClosureTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\render_special_closure_tests.ml") -OutputFile $RenderSpecialClosureTestExe -CompilerArguments $CommonArgs -Label "render-special-closure-tests"
  $RenderSpecialClosureTestStatus = "COMPILED"

  $AudioMemoryTestExe = Join-Path $Output "MiniQuakeAudioMemoryTests.exe"
  Write-Host "[MiniQuake] compiling $AudioMemoryTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\audio_memory_parity_tests.ml") -OutputFile $AudioMemoryTestExe -CompilerArguments $CommonArgs -Label "audio-memory-tests"
  $AudioMemoryTestStatus = "COMPILED"

  $AudioDmaTestExe = Join-Path $Output "MiniQuakeAudioDmaTests.exe"
  Write-Host "[MiniQuake] compiling $AudioDmaTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\audio_dma_parity_tests.ml") -OutputFile $AudioDmaTestExe -CompilerArguments $CommonArgs -Label "audio-dma-tests"
  $AudioDmaTestStatus = "COMPILED"

  $AudioMixerTestExe = Join-Path $Output "MiniQuakeAudioMixerTests.exe"
  Write-Host "[MiniQuake] compiling $AudioMixerTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\audio_mixer_parity_tests.ml") -OutputFile $AudioMixerTestExe -CompilerArguments $CommonArgs -Label "audio-mixer-tests"
  $AudioMixerTestStatus = "COMPILED"

  $AudioWinTestExe = Join-Path $Output "MiniQuakeAudioWinTests.exe"
  Write-Host "[MiniQuake] compiling $AudioWinTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\audio_win_parity_tests.ml") -OutputFile $AudioWinTestExe -CompilerArguments $CommonArgs -Label "audio-win-tests"
  $AudioWinTestStatus = "COMPILED"

  $AudioClosureTestExe = Join-Path $Output "MiniQuakeAudioClosureTests.exe"
  Write-Host "[MiniQuake] compiling $AudioClosureTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\audio_closure_tests.ml") -OutputFile $AudioClosureTestExe -CompilerArguments $CommonArgs -Label "audio-closure-tests"
  $AudioClosureTestStatus = "COMPILED"

  $AudioRetailEvidenceExe = Join-Path $Output "MiniQuakeAudioRetailEvidence.exe"
  Write-Host "[MiniQuake] compiling $AudioRetailEvidenceExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\audio_retail_evidence.ml") -OutputFile $AudioRetailEvidenceExe -CompilerArguments $CommonArgs -Label "audio-retail-evidence"
  $AudioRetailEvidenceStatus = "COMPILED"

  $NetworkMainTestExe = Join-Path $Output "MiniQuakeNetworkMainTests.exe"
  Write-Host "[MiniQuake] compiling $NetworkMainTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\network_main_parity_tests.ml") -OutputFile $NetworkMainTestExe -CompilerArguments $CommonArgs -Label "network-main-tests"
  $NetworkMainTestStatus = "COMPILED"

  $NetworkControlTestExe = Join-Path $Output "MiniQuakeNetworkControlTests.exe"
  Write-Host "[MiniQuake] compiling $NetworkControlTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\network_control_parity_tests.ml") -OutputFile $NetworkControlTestExe -CompilerArguments $CommonArgs -Label "network-control-tests"
  $NetworkControlTestStatus = "COMPILED"

  $NetworkWinsAddressTestExe = Join-Path $Output "MiniQuakeNetworkWinsAddressTests.exe"
  Write-Host "[MiniQuake] compiling $NetworkWinsAddressTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\network_wins_address_tests.ml") -OutputFile $NetworkWinsAddressTestExe -CompilerArguments $CommonArgs -Label "network-wins-address-tests"
  $NetworkWinsAddressTestStatus = "COMPILED"

  $SystemPlatformTestExe = Join-Path $Output "MiniQuakeSystemPlatformTests.exe"
  Write-Host "[MiniQuake] compiling $SystemPlatformTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\system_platform_lifecycle_tests.ml") -OutputFile $SystemPlatformTestExe -CompilerArguments $CommonArgs -Label "system-platform-tests"
  $SystemPlatformTestStatus = "COMPILED"

  $NetworkPlatformClosureTestExe = Join-Path $Output "MiniQuakeNetworkPlatformClosureTests.exe"
  Write-Host "[MiniQuake] compiling $NetworkPlatformClosureTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\network_platform_closure_tests.ml") -OutputFile $NetworkPlatformClosureTestExe -CompilerArguments $CommonArgs -Label "network-platform-closure-tests"
  $NetworkPlatformClosureTestStatus = "COMPILED"

  $NetworkPlatformEvidenceExe = Join-Path $Output "MiniQuakeNetworkPlatformEvidence.exe"
  Write-Host "[MiniQuake] compiling $NetworkPlatformEvidenceExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\network_platform_evidence.ml") -OutputFile $NetworkPlatformEvidenceExe -CompilerArguments $CommonArgs -Label "network-platform-evidence"
  $NetworkPlatformEvidenceStatus = "COMPILED"

  $KeyFocusTestExe = Join-Path $Output "MiniQuakeKeyFocusTests.exe"
  Write-Host "[MiniQuake] compiling $KeyFocusTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\key_focus_parity_tests.ml") -OutputFile $KeyFocusTestExe -CompilerArguments $CommonArgs -Label "key-focus-tests"
  $KeyFocusTestStatus = "COMPILED"

  $InputDeviceTestExe = Join-Path $Output "MiniQuakeInputDeviceTests.exe"
  Write-Host "[MiniQuake] compiling $InputDeviceTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\input_device_parity_tests.ml") -OutputFile $InputDeviceTestExe -CompilerArguments $CommonArgs -Label "input-device-tests"
  $InputDeviceTestStatus = "COMPILED"

  $ConsoleScreenTestExe = Join-Path $Output "MiniQuakeConsoleScreenTests.exe"
  Write-Host "[MiniQuake] compiling $ConsoleScreenTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\console_screen_lifecycle_tests.ml") -OutputFile $ConsoleScreenTestExe -CompilerArguments $CommonArgs -Label "console-screen-tests"
  $ConsoleScreenTestStatus = "COMPILED"

  $MenuLifecycleTestExe = Join-Path $Output "MiniQuakeMenuLifecycleTests.exe"
  Write-Host "[MiniQuake] compiling $MenuLifecycleTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\menu_lifecycle_parity_tests.ml") -OutputFile $MenuLifecycleTestExe -CompilerArguments $CommonArgs -Label "menu-lifecycle-tests"
  $MenuLifecycleTestStatus = "COMPILED"

  $FrontendClosureTestExe = Join-Path $Output "MiniQuakeFrontendClosureTests.exe"
  Write-Host "[MiniQuake] compiling $FrontendClosureTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\video_frontend_closure_tests.ml") -OutputFile $FrontendClosureTestExe -CompilerArguments $CommonArgs -Label "frontend-closure-tests"
  $FrontendClosureTestStatus = "COMPILED"

  $CommonCoreTestExe = Join-Path $Output "MiniQuakeCommonCoreTests.exe"
  Write-Host "[MiniQuake] compiling $CommonCoreTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\common_asset_parity_tests.ml") -OutputFile $CommonCoreTestExe -CompilerArguments $CommonArgs -Label "common-core-tests"
  $CommonCoreTestStatus = "COMPILED"

  $FilesystemPackTestExe = Join-Path $Output "MiniQuakeFilesystemPackTests.exe"
  Write-Host "[MiniQuake] compiling $FilesystemPackTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\filesystem_pack_parity_tests.ml") -OutputFile $FilesystemPackTestExe -CompilerArguments $CommonArgs -Label "filesystem-pack-tests"
  $FilesystemPackTestStatus = "COMPILED"

  $WadGraphicsTestExe = Join-Path $Output "MiniQuakeWadGraphicsTests.exe"
  Write-Host "[MiniQuake] compiling $WadGraphicsTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\wad_graphics_parity_tests.ml") -OutputFile $WadGraphicsTestExe -CompilerArguments $CommonArgs -Label "wad-graphics-tests"
  $WadGraphicsTestStatus = "COMPILED"

  $ModelAssetTestExe = Join-Path $Output "MiniQuakeModelAssetTests.exe"
  Write-Host "[MiniQuake] compiling $ModelAssetTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\model_asset_parity_tests.ml") -OutputFile $ModelAssetTestExe -CompilerArguments $CommonArgs -Label "model-asset-tests"
  $ModelAssetTestStatus = "COMPILED"

  $CoreAssetsMemoryTestExe = Join-Path $Output "MiniQuakeCoreAssetsMemoryTests.exe"
  Write-Host "[MiniQuake] compiling $CoreAssetsMemoryTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\core_assets_memory_closure_tests.ml") -OutputFile $CoreAssetsMemoryTestExe -CompilerArguments $CommonArgs -Label "core-assets-memory-tests"
  $CoreAssetsMemoryTestStatus = "COMPILED"

  $CoreAssetRetailEvidenceExe = Join-Path $Output "MiniQuakeCoreAssetRetailEvidence.exe"
  Write-Host "[MiniQuake] compiling $CoreAssetRetailEvidenceExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\core_asset_retail_evidence.ml") -OutputFile $CoreAssetRetailEvidenceExe -CompilerArguments $CommonArgs -Label "core-asset-retail-evidence"
  $CoreAssetRetailEvidenceStatus = "COMPILED"

  $GameplayMathChaseTestExe = Join-Path $Output "MiniQuakeGameplayMathChaseTests.exe"
  Write-Host "[MiniQuake] compiling $GameplayMathChaseTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\gameplay_math_chase_tests.ml") -OutputFile $GameplayMathChaseTestExe -CompilerArguments $CommonArgs -Label "gameplay-math-chase-tests"
  $GameplayMathChaseTestStatus = "COMPILED"

  $GameplayViewTestExe = Join-Path $Output "MiniQuakeGameplayViewTests.exe"
  Write-Host "[MiniQuake] compiling $GameplayViewTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\gameplay_view_tests.ml") -OutputFile $GameplayViewTestExe -CompilerArguments $CommonArgs -Label "gameplay-view-tests"
  $GameplayViewTestStatus = "COMPILED"

  $GameplayScreenTestExe = Join-Path $Output "MiniQuakeGameplayScreenTests.exe"
  Write-Host "[MiniQuake] compiling $GameplayScreenTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\gameplay_screen_tests.ml") -OutputFile $GameplayScreenTestExe -CompilerArguments $CommonArgs -Label "gameplay-screen-tests"
  $GameplayScreenTestStatus = "COMPILED"

  $GameplayStatusbarTestExe = Join-Path $Output "MiniQuakeGameplayStatusbarTests.exe"
  Write-Host "[MiniQuake] compiling $GameplayStatusbarTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\gameplay_statusbar_tests.ml") -OutputFile $GameplayStatusbarTestExe -CompilerArguments $CommonArgs -Label "gameplay-statusbar-tests"
  $GameplayStatusbarTestStatus = "COMPILED"

  $GameplayPresentationClosureTestExe = Join-Path $Output "MiniQuakeGameplayPresentationClosureTests.exe"
  Write-Host "[MiniQuake] compiling $GameplayPresentationClosureTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\gameplay_presentation_closure_tests.ml") -OutputFile $GameplayPresentationClosureTestExe -CompilerArguments $CommonArgs -Label "gameplay-presentation-closure-tests"
  $GameplayPresentationClosureTestStatus = "COMPILED"

  $CvarSourceSurfaceTestExe = Join-Path $Output "MiniQuakeCvarSourceSurfaceTests.exe"
  Write-Host "[MiniQuake] compiling $CvarSourceSurfaceTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\cvar_source_surface_tests.ml") -OutputFile $CvarSourceSurfaceTestExe -CompilerArguments $CommonArgs -Label "cvar-source-surface-tests"
  $CvarSourceSurfaceTestStatus = "COMPILED"

  $CdAudioSourceSurfaceTestExe = Join-Path $Output "MiniQuakeCdAudioSourceSurfaceTests.exe"
  Write-Host "[MiniQuake] compiling $CdAudioSourceSurfaceTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\cd_audio_source_surface_tests.ml") -OutputFile $CdAudioSourceSurfaceTestExe -CompilerArguments $CommonArgs -Label "cd-audio-source-surface-tests"
  $CdAudioSourceSurfaceTestStatus = "COMPILED"

  $SourceFunctionInventoryTestExe = Join-Path $Output "MiniQuakeSourceFunctionInventoryTests.exe"
  Write-Host "[MiniQuake] compiling $SourceFunctionInventoryTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\source_function_inventory_tests.ml") -OutputFile $SourceFunctionInventoryTestExe -CompilerArguments $CommonArgs -Label "source-function-inventory-tests"
  $SourceFunctionInventoryTestStatus = "COMPILED"

  $BlackPortCorpusTestExe = Join-Path $Output "MiniQuakeBlackPortCorpusTests.exe"
  Write-Host "[MiniQuake] compiling $BlackPortCorpusTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\black_port_corpus_tests.ml") -OutputFile $BlackPortCorpusTestExe -CompilerArguments $CommonArgs -Label "black-port-corpus-tests"
  $BlackPortCorpusTestStatus = "COMPILED"

  $BlackPortSourceClosureTestExe = Join-Path $Output "MiniQuakeBlackPortSourceClosureTests.exe"
  Write-Host "[MiniQuake] compiling $BlackPortSourceClosureTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\black_port_source_closure_tests.ml") -OutputFile $BlackPortSourceClosureTestExe -CompilerArguments $CommonArgs -Label "black-port-source-closure-tests"
  $BlackPortSourceClosureTestStatus = "COMPILED"

  $GameProfileTestExe = Join-Path $Output "MiniQuakeGameProfileTests.exe"
  Write-Host "[MiniQuake] compiling $GameProfileTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\game_profile_compat_tests.ml") -OutputFile $GameProfileTestExe -CompilerArguments $CommonArgs -Label "game-profile-tests"
  $GameProfileTestStatus = "COMPILED"

  $ModRuntimeTestExe = Join-Path $Output "MiniQuakeModRuntimeTests.exe"
  Write-Host "[MiniQuake] compiling $ModRuntimeTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\mod_runtime_compat_tests.ml") -OutputFile $ModRuntimeTestExe -CompilerArguments $CommonArgs -Label "mod-runtime-tests"
  $ModRuntimeTestStatus = "COMPILED"

  $ArtifactCompatTestExe = Join-Path $Output "MiniQuakeArtifactCompatTests.exe"
  Write-Host "[MiniQuake] compiling $ArtifactCompatTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\artifact_compat_tests.ml") -OutputFile $ArtifactCompatTestExe -CompilerArguments $CommonArgs -Label "artifact-compat-tests"
  $ArtifactCompatTestStatus = "COMPILED"

  $StabilityTestExe = Join-Path $Output "MiniQuakeStabilityTests.exe"
  Write-Host "[MiniQuake] compiling $StabilityTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\stability_contract_tests.ml") -OutputFile $StabilityTestExe -CompilerArguments $CommonArgs -Label "stability-tests"
  $StabilityTestStatus = "COMPILED"

  $CompatibilityReleaseTestExe = Join-Path $Output "MiniQuakeCompatibilityReleaseTests.exe"
  Write-Host "[MiniQuake] compiling $CompatibilityReleaseTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\compatibility_release_closure_tests.ml") -OutputFile $CompatibilityReleaseTestExe -CompilerArguments $CommonArgs -Label "compatibility-release-tests"
  $CompatibilityReleaseTestStatus = "COMPILED"


  $OriginalReferenceTestExe = Join-Path $Output "MiniQuakeOriginalReferenceTests.exe"
  Write-Host "[MiniQuake] compiling $OriginalReferenceTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\original_reference_provenance_tests.ml") -OutputFile $OriginalReferenceTestExe -CompilerArguments $CommonArgs -Label "original-reference-tests"
  $OriginalReferenceTestStatus = "COMPILED"

  $OriginalServerInteropTestExe = Join-Path $Output "MiniQuakeOriginalServerInteropTests.exe"
  Write-Host "[MiniQuake] compiling $OriginalServerInteropTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\original_server_interop_tests.ml") -OutputFile $OriginalServerInteropTestExe -CompilerArguments $CommonArgs -Label "original-server-interop-tests"
  $OriginalServerInteropTestStatus = "COMPILED"

  $OriginalClientInteropTestExe = Join-Path $Output "MiniQuakeOriginalClientInteropTests.exe"
  Write-Host "[MiniQuake] compiling $OriginalClientInteropTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\original_client_interop_tests.ml") -OutputFile $OriginalClientInteropTestExe -CompilerArguments $CommonArgs -Label "original-client-interop-tests"
  $OriginalClientInteropTestStatus = "COMPILED"

  $OriginalVisualReferenceTestExe = Join-Path $Output "MiniQuakeOriginalVisualReferenceTests.exe"
  Write-Host "[MiniQuake] compiling $OriginalVisualReferenceTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\original_visual_reference_tests.ml") -OutputFile $OriginalVisualReferenceTestExe -CompilerArguments $CommonArgs -Label "original-visual-reference-tests"
  $OriginalVisualReferenceTestStatus = "COMPILED"

  $ExternalCompatibilityClosureTestExe = Join-Path $Output "MiniQuakeExternalCompatibilityClosureTests.exe"
  Write-Host "[MiniQuake] compiling $ExternalCompatibilityClosureTestExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\external_compat_closure_tests.ml") -OutputFile $ExternalCompatibilityClosureTestExe -CompilerArguments $CommonArgs -Label "external-compatibility-closure-tests"
  $ExternalCompatibilityClosureTestStatus = "COMPILED"

  $ArtifactRetailEvidenceExe = Join-Path $Output "MiniQuakeArtifactRetailEvidence.exe"
  Write-Host "[MiniQuake] compiling $ArtifactRetailEvidenceExe"
  Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\artifact_retail_evidence.ml") -OutputFile $ArtifactRetailEvidenceExe -CompilerArguments $CommonArgs -Label "artifact-retail-evidence"
  $ArtifactRetailEvidenceStatus = "COMPILED"

  if (-not $NoRunTests) {
    Invoke-MiniQuakeTestBinary `
      -Label "core tests" `
      -Executable $TestExe `
      -ProgressHint "The last printed [NN/17] line identifies the active test; if no test line appeared, the process failed during image loading or module initialization."
    $CoreTestStatus = "PASS"

    if ($null -ne $MilestoneTestExe) {
      Invoke-MiniQuakeTestBinary `
      -Label "milestone tests" `
      -Executable $MilestoneTestExe `
      -ProgressHint "The last printed [NN/24] line identifies the active subsystem."
      $MilestoneTestStatus = "PASS"
    }

    Invoke-MiniQuakeTestBinary `
      -Label "BP-001R3 diagnostics regression tests" `
      -Executable $DiagnosticsTestExe `
      -ProgressHint "The last printed [NN/10] line identifies the active deterministic-diagnostics fixture."
    $DiagnosticsTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-010R1 Protocol 15 wire regression tests" `
      -Executable $ProtocolTestExe `
      -ProgressHint "The last printed [NN/15] line identifies the active byte-exact protocol fixture."
    $ProtocolTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-011 Protocol 15 command-stream tests" `
      -Executable $ProtocolCommandTestExe `
      -ProgressHint "The last printed [NN/14] line identifies the active signon, CLC, SVC or fast-update fixture."
    $ProtocolCommandTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-012R1 Protocol 15 server-data regression tests" `
      -Executable $ProtocolServerDataTestExe `
      -ProgressHint "The last printed [NN/17] line identifies the active serverinfo, sound, clientdata, baseline, packet-planning or PlayerState-adapter fixture."
    $ProtocolServerDataTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-013 Protocol 15 event tests" `
      -Executable $ProtocolEventTestExe `
      -ProgressHint "The last printed [NN/22] line identifies the active static-entity, static-sound, particle, scoreboard, reliable-delivery or graceful-drop fixture."
    $ProtocolEventTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-014R1 Protocol 15 runtime-event tests" `
      -Executable $ProtocolRuntimeEventTestExe `
      -ProgressHint "The last printed [NN/28] line identifies the active temporary-entity, dynamic-sound, beam-pool, reconnect or delivery-boundary fixture."
    $ProtocolRuntimeEventTestStatus = "PASS"


    Invoke-MiniQuakeTestBinary `
      -Label "BP-015 Protocol 15 signon tests" `
      -Executable $ProtocolSignonTestExe `
      -ProgressHint "The last printed [NN/12] line identifies the active signon queue or stage-transition fixture."
    $ProtocolSignonTestStatus = "PASS"


    Invoke-MiniQuakeTestBinary `
      -Label "BP-016 Protocol 15 delivery tests" `
      -Executable $ProtocolDeliveryTestExe `
      -ProgressHint "The last printed [NN/14] line identifies the active reliable/unreliable scheduling fixture."
    $ProtocolDeliveryTestStatus = "PASS"


    Invoke-MiniQuakeTestBinary `
      -Label "BP-017 Protocol 15 datagram tests" `
      -Executable $ProtocolDatagramTestExe `
      -ProgressHint "The last printed [NN/18] line identifies the active fragmentation, ACK, retransmission or loss fixture."
    $ProtocolDatagramTestStatus = "PASS"


    Invoke-MiniQuakeTestBinary `
      -Label "BP-018 Protocol 15 demo tests" `
      -Executable $ProtocolDemoTestExe `
      -ProgressHint "The last printed [NN/19] line identifies the active demo framing, recording, keepalive or timedemo fixture."
    $ProtocolDemoTestStatus = "PASS"


    Invoke-MiniQuakeTestBinary `
      -Label "BP-019 Protocol 15 closure tests" `
      -Executable $ProtocolClosureTestExe `
      -ProgressHint "The last printed [NN/15] line identifies the active cross-layer Protocol 15 closure fixture."
    $ProtocolClosureTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-020 QuakeC progs.dat tests" `
      -Executable $QuakeCProgsTestExe `
      -ProgressHint "The last printed [NN/18] line identifies the active progs.dat ABI, string-table or semantic validation fixture."
    $QuakeCProgsTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-021 QuakeC VM tests" `
      -Executable $QuakeCVMTestExe `
      -ProgressHint "The last printed [NN/16] line identifies the active opcode, stack, pointer or Binary32 fixture."
    $QuakeCVMTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-022 QuakeC edict tests" `
      -Executable $QuakeCEdictTestExe `
      -ProgressHint "The last printed [NN/22] line identifies the active edict, epair, save-text or formatting fixture."
    $QuakeCEdictTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-023 QuakeC builtin tests" `
      -Executable $QuakeCBuiltinTestExe `
      -ProgressHint "The last printed [NN/22] line identifies the active builtin-table, temporary-string, formatting or random fixture."
    $QuakeCBuiltinTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-024 QuakeC closure tests" `
      -Executable $QuakeCClosureTestExe `
      -ProgressHint "The last printed [NN/20] line identifies the active frozen QuakeC contract fixture."
    $QuakeCClosureTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-025 world hull tests" `
      -Executable $WorldHullTestExe `
      -ProgressHint "The last printed [NN/14] line identifies the active box-hull or recursive trace fixture."
    $WorldHullTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-025 world trace tests" `
      -Executable $WorldTraceTestExe `
      -ProgressHint "The last printed world trace fixture identifies the active coordinate or plane case."
    $WorldTraceTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-026 world link/collision tests" `
      -Executable $WorldLinkTestExe `
      -ProgressHint "The last printed [NN/15] line identifies the active link, bounds or collision-filter fixture."
    $WorldLinkTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-027 server movement tests" `
      -Executable $ServerMoveTestExe `
      -ProgressHint "The last printed [NN/14] line identifies the active monster-movement or relink fixture."
    $ServerMoveTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-028 server physics tests" `
      -Executable $ServerPhysicsTestExe `
      -ProgressHint "The last printed [NN/18] line identifies the active pusher, toss, client or dispatch fixture."
    $ServerPhysicsTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-028 sv_user movement tests" `
      -Executable $SvUserMovementTestExe `
      -ProgressHint "The last printed [NN/16] line identifies the active client-movement, angle or acceleration fixture."
    $SvUserMovementTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-029 server user tests" `
      -Executable $ServerUserTestExe `
      -ProgressHint "The last printed [NN/18] line identifies the active command, ping, movement-gate or ideal-pitch fixture."
    $ServerUserTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-029 world/physics closure tests" `
      -Executable $WorldPhysicsClosureTestExe `
      -ProgressHint "The last printed [NN/20] line identifies the active frozen world/physics contract fixture."
    $WorldPhysicsClosureTestStatus = "PASS"


    Invoke-MiniQuakeTestBinary `
      -Label "BP-030 host timing tests" `
      -Executable $HostTimingTestExe `
      -ProgressHint "The last printed [NN/18] line identifies the active frame-filter or clock-boundary fixture."
    $HostTimingTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-031 command/cvar lifecycle tests" `
      -Executable $CommandCvarTestExe `
      -ProgressHint "The last printed [NN/20] line identifies the active command-buffer, alias or cvar fixture."
    $CommandCvarTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "host command and cheat synchronization tests" `
      -Executable $HostCommandTestExe `
      -ProgressHint "The last printed [N/4] line identifies the active host command, cheat or save fixture."
    $HostCommandTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-032 demo lifecycle tests" `
      -Executable $DemoLifecycleTestExe `
      -ProgressHint "The last printed [NN/20] line identifies the active demo framing, recording or timedemo fixture."
    $DemoLifecycleTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-033 savegame v5 tests" `
      -Executable $SavegameV5TestExe `
      -ProgressHint "The last printed [NN/24] line identifies the active savegame byte, parser or v5 layout fixture."
    $SavegameV5TestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-034 host lifecycle closure tests" `
      -Executable $HostLifecycleClosureTestExe `
      -ProgressHint "The last printed [NN/24] line identifies the active host transition, shutdown or frozen-contract fixture."
    $HostLifecycleClosureTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-035 client state/render tests" `
      -Executable $ClientStateRenderTestExe `
      -ProgressHint "The last printed [NN/20] line identifies the active interpolation, dlight or visible-entity fixture."
    $ClientStateRenderTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-036 view state tests" `
      -Executable $ViewStateTestExe `
      -ProgressHint "The last printed [NN/22] line identifies the active view, cshift or chase-camera fixture."
    $ViewStateTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-037 temporary beam render tests" `
      -Executable $TemporaryBeamTestExe `
      -ProgressHint "The last printed [NN/22] line identifies the active beam geometry, model or temporary-entity fixture."
    $TemporaryBeamTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-038 particle runtime tests" `
      -Executable $ParticleRuntimeTestExe `
      -ProgressHint "The last printed [NN/22] line identifies the active particle gravity, ramp or Binary32 fixture."
    $ParticleRuntimeTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-039 client/render closure tests" `
      -Executable $ClientRenderClosureTestExe `
      -ProgressHint "The last printed [NN/24] line identifies the active efrag, submission or frozen-contract fixture."
    $ClientRenderClosureTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-040 world surface tests" `
      -Executable $WorldSurfaceRenderTestExe `
      -ProgressHint "The last printed [NN/20] line identifies the active world-surface, chain, sky or water fixture."
    $WorldSurfaceRenderTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-041 lightmap atlas tests" `
      -Executable $LightmapAtlasTestExe `
      -ProgressHint "The last printed [NN/22] line identifies the active lightmap format, stride or ownership fixture."
    $LightmapAtlasTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-042 dynamic-light render tests" `
      -Executable $DynamicLightRenderTestExe `
      -ProgressHint "The last printed [NN/20] line identifies the active dynamic-light frame or brush marking fixture."
    $DynamicLightRenderTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-043 sky/water render tests" `
      -Executable $SkyWaterRenderTestExe `
      -ProgressHint "The last printed [NN/22] line identifies the active warp, sky or subdivision fixture."
    $SkyWaterRenderTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-044 world/render closure tests" `
      -Executable $WorldRenderClosureTestExe `
      -ProgressHint "The last printed [NN/24] line identifies the active viewport, culling, pass-order or frozen-contract fixture."
    $WorldRenderClosureTestStatus = "PASS"


    Invoke-MiniQuakeTestBinary `
      -Label "BP-045 alias model tests" `
      -Executable $AliasModelTestExe `
      -ProgressHint "The last printed [NN/22] line identifies the active alias lighting or shadow fixture."
    $AliasModelTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-046 sprite sync tests" `
      -Executable $SpriteSyncTestExe `
      -ProgressHint "The last printed [NN/22] line identifies the active sprite synchronization fixture."
    $SpriteSyncTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-047 2D/HUD tests" `
      -Executable $RenderUiHudTestExe `
      -ProgressHint "The last printed [NN/24] line identifies the active 2D, HUD or TGA fixture."
    $RenderUiHudTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-048 render evidence tests" `
      -Executable $RenderEvidenceTestExe `
      -ProgressHint "The last printed [NN/18] line identifies the active framebuffer evidence fixture."
    $RenderEvidenceTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-049 model/UI/render closure tests" `
      -Executable $ModelUiRenderClosureTestExe `
      -ProgressHint "The last printed [NN/24] line identifies the active frozen model/UI/render fixture."
    $ModelUiRenderClosureTestStatus = "PASS"


    Invoke-MiniQuakeTestBinary `
      -Label "BP-050 mirror special-render tests" `
      -Executable $MirrorSpecialTestExe `
      -ProgressHint "The last printed [NN/22] line identifies the active mirror reflection or entity-handoff fixture."
    $MirrorSpecialTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-051 render-clear special tests" `
      -Executable $RenderClearSpecialTestExe `
      -ProgressHint "The last printed [NN/20] line identifies the active clear, z-trick, finish or norefresh fixture."
    $RenderClearSpecialTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-052 envmap/timerefresh tests" `
      -Executable $EnvmapTimeRefreshTestExe `
      -ProgressHint "The last printed [NN/20] line identifies the active envmap or timerefresh fixture."
    $EnvmapTimeRefreshTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-053 render-evidence corpus tests" `
      -Executable $RenderEvidenceCorpusTestExe `
      -ProgressHint "The last printed [NN/18] line identifies the active corpus schema or threshold fixture."
    $RenderEvidenceCorpusTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-054 render-special closure tests" `
      -Executable $RenderSpecialClosureTestExe `
      -ProgressHint "The last printed [NN/24] line identifies the active frozen special-render fixture."
    $RenderSpecialClosureTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-055 audio memory tests" `
      -Executable $AudioMemoryTestExe `
      -ProgressHint "The last printed [NN/20] line identifies the active WAVE parsing or resampling fixture."
    $AudioMemoryTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-056 audio DMA tests" `
      -Executable $AudioDmaTestExe `
      -ProgressHint "The last printed [NN/22] line identifies the active channel or spatialization fixture."
    $AudioDmaTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-057 audio mixer tests" `
      -Executable $AudioMixerTestExe `
      -ProgressHint "The last printed [NN/22] line identifies the active software-mixer fixture."
    $AudioMixerTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-058 audio Win32 tests" `
      -Executable $AudioWinTestExe `
      -ProgressHint "The last printed [NN/20] line identifies the active waveOut ring or lifecycle fixture."
    $AudioWinTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-059 audio closure tests" `
      -Executable $AudioClosureTestExe `
      -ProgressHint "The last printed [NN/24] line identifies the active frozen audio-contract fixture."
    $AudioClosureTestStatus = "PASS"


    Invoke-MiniQuakeTestBinary `
      -Label "BP-060 network main tests" `
      -Executable $NetworkMainTestExe `
      -ProgressHint "The last printed [NN/20] line identifies the active NET lifecycle fixture."
    $NetworkMainTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-061 network control tests" `
      -Executable $NetworkControlTestExe `
      -ProgressHint "The last printed [NN/24] line identifies the active control/discovery fixture."
    $NetworkControlTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-062 WinSock address tests" `
      -Executable $NetworkWinsAddressTestExe `
      -ProgressHint "The last printed [NN/24] line identifies the active address/landriver fixture."
    $NetworkWinsAddressTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-063 system/platform tests" `
      -Executable $SystemPlatformTestExe `
      -ProgressHint "The last printed [NN/21] line identifies the active sys_win/conproc fixture."
    $SystemPlatformTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-064 network/platform closure tests" `
      -Executable $NetworkPlatformClosureTestExe `
      -ProgressHint "The last printed [NN/24] line identifies the active frozen network/platform fixture."
    $NetworkPlatformClosureTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-065 key/focus tests" `
      -Executable $KeyFocusTestExe `
      -ProgressHint "The last printed [NN/28] line identifies the active key, binding or focus-release fixture."
    $KeyFocusTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-066 input device tests" `
      -Executable $InputDeviceTestExe `
      -ProgressHint "The last printed [NN/35] line identifies the active mouse filtering or device-clear fixture."
    $InputDeviceTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-067 console/screen tests" `
      -Executable $ConsoleScreenTestExe `
      -ProgressHint "The last printed [NN/22] line identifies the active notify-box or modal-screen fixture."
    $ConsoleScreenTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-068 menu lifecycle tests" `
      -Executable $MenuLifecycleTestExe `
      -ProgressHint "The last printed [NN/24] line identifies the active menu toggle, save or options fixture."
    $MenuLifecycleTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-069 frontend closure tests" `
      -Executable $FrontendClosureTestExe `
      -ProgressHint "The last printed [NN/24] line identifies the active video, focus or frozen frontend fixture."
    $FrontendClosureTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-070 common core tests" `
      -Executable $CommonCoreTestExe `
      -ProgressHint "The last printed [NN/24] line identifies the active common, byte-order or CRC fixture."
    $CommonCoreTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-071 filesystem PACK tests" `
      -Executable $FilesystemPackTestExe `
      -ProgressHint "The last printed [NN/24] line identifies the active PACK or search-path fixture."
    $FilesystemPackTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-072 WAD graphics tests" `
      -Executable $WadGraphicsTestExe `
      -ProgressHint "The last printed [NN/20] line identifies the active WAD or qpic fixture."
    $WadGraphicsTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-073 model asset tests" `
      -Executable $ModelAssetTestExe `
      -ProgressHint "The last printed [NN/24] line identifies the active BSP, MDL, sprite or model-registry fixture."
    $ModelAssetTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-074 core assets memory closure tests" `
      -Executable $CoreAssetsMemoryTestExe `
      -ProgressHint "The last printed [NN/24] line identifies the active zone, hunk, cache or frozen core-assets fixture."
    $CoreAssetsMemoryTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-075 math/chase tests" `
      -Executable $GameplayMathChaseTestExe `
      -ProgressHint "The last printed [NN/22] line identifies the active mathlib or chase-camera fixture."
    $GameplayMathChaseTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-076 view/palette tests" `
      -Executable $GameplayViewTestExe `
      -ProgressHint "The last printed [NN/22] line identifies the active view, gamma, cshift or refdef fixture."
    $GameplayViewTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-077 screen/loading tests" `
      -Executable $GameplayScreenTestExe `
      -ProgressHint "The last printed [NN/22] line identifies the active centerprint, loading, screenshot or screen-layout fixture."
    $GameplayScreenTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-078 statusbar/scoreboard tests" `
      -Executable $GameplayStatusbarTestExe `
      -ProgressHint "The last printed [NN/22] line identifies the active statusbar, scoreboard, face, armor or ammo fixture."
    $GameplayStatusbarTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-079 gameplay/presentation closure tests" `
      -Executable $GameplayPresentationClosureTestExe `
      -ProgressHint "The last printed [NN/24] line identifies the active host-command parser or frozen gameplay/presentation fixture."
    $GameplayPresentationClosureTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-080 cvar source-surface tests" `
      -Executable $CvarSourceSurfaceTestExe `
      -ProgressHint "The last printed [NN/20] line identifies the active cvar.c adapter fixture."
    $CvarSourceSurfaceTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-081 CD audio source-surface tests" `
      -Executable $CdAudioSourceSurfaceTestExe `
      -ProgressHint "The last printed [NN/20] line identifies the active cd_win.c technical-equivalent fixture."
    $CdAudioSourceSurfaceTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-082 source function inventory tests" `
      -Executable $SourceFunctionInventoryTestExe `
      -ProgressHint "The last printed [NN/20] line identifies the active source-accounting fixture."
    $SourceFunctionInventoryTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-083 black-port corpus tests" `
      -Executable $BlackPortCorpusTestExe `
      -ProgressHint "The last printed [NN/18] line identifies the active corpus-contract fixture."
    $BlackPortCorpusTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-084 source black-port closure tests" `
      -Executable $BlackPortSourceClosureTestExe `
      -ProgressHint "The last printed [NN/24] line identifies the active source-closure fixture."
    $BlackPortSourceClosureTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-085 game-profile tests" `
      -Executable $GameProfileTestExe `
      -ProgressHint "The last printed [NN/22] line identifies the active game-directory or mission-pack fixture."
    $GameProfileTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-086 mod runtime tests" `
      -Executable $ModRuntimeTestExe `
      -ProgressHint "The last printed [NN/22] line identifies the active mod/profile ABI fixture."
    $ModRuntimeTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-087 artifact compatibility tests" `
      -Executable $ArtifactCompatTestExe `
      -ProgressHint "The last printed [NN/24] line identifies the active demo or savegame fixture."
    $ArtifactCompatTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-088 stability tests" `
      -Executable $StabilityTestExe `
      -ProgressHint "The last printed [NN/20] line identifies the active resource-stability fixture."
    $StabilityTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-089 compatibility release closure tests" `
      -Executable $CompatibilityReleaseTestExe `
      -ProgressHint "The last printed [NN/24] line identifies the active release-matrix fixture."
    $CompatibilityReleaseTestStatus = "PASS"


    Invoke-MiniQuakeTestBinary `
      -Label "BP-090 original reference tests" `
      -Executable $OriginalReferenceTestExe `
      -ProgressHint "The last printed [NN/20] line identifies the active original-reference provenance fixture."
    $OriginalReferenceTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-091 original server interop tests" `
      -Executable $OriginalServerInteropTestExe `
      -ProgressHint "The last printed [NN/20] line identifies the active MiniQuake-client/original-server fixture."
    $OriginalServerInteropTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-092 original client interop tests" `
      -Executable $OriginalClientInteropTestExe `
      -ProgressHint "The last printed [NN/20] line identifies the active original-client/MiniQuake-server fixture."
    $OriginalClientInteropTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-093 original visual reference tests" `
      -Executable $OriginalVisualReferenceTestExe `
      -ProgressHint "The last printed [NN/20] line identifies the active raw full-frame visual-reference fixture."
    $OriginalVisualReferenceTestStatus = "PASS"

    Invoke-MiniQuakeTestBinary `
      -Label "BP-094 external compatibility closure tests" `
      -Executable $ExternalCompatibilityClosureTestExe `
      -ProgressHint "The last printed [NN/24] line identifies the active external compatibility-closure fixture."
    $ExternalCompatibilityClosureTestStatus = "PASS"
  }
}

if ($NetworkTests -and -not $NoRunTests) {
  Write-Host "[MiniQuake] running UDP loopback smoke"
  & $GameExe "--udp-smoke" "2000"
  $NetworkExitCode = [int]$LASTEXITCODE
  if ($NetworkExitCode -ne 0) {
    Write-Host "ERROR: MiniQuake UDP loopback smoke failed with exit code $NetworkExitCode." -ForegroundColor Red
    exit $NetworkExitCode
  }
  $NetworkTestStatus = "PASS"
} elseif ($NetworkTests) {
  $NetworkTestStatus = "COMPILED-NOT-RUN"
}

Write-Host "[MiniQuake] supplemental tests: host_commands=$HostCommandTestStatus cheat_retail=$CheatRetailTestStatus boss_visibility_retail=$BossVisibilityRetailTestStatus"
Write-Host "[MiniQuake] test summary: core=$CoreTestStatus milestone=$MilestoneTestStatus diagnostics=$DiagnosticsTestStatus protocol15=$ProtocolTestStatus protocol15_commands=$ProtocolCommandTestStatus protocol15_serverdata=$ProtocolServerDataTestStatus protocol15_events=$ProtocolEventTestStatus protocol15_runtime_events=$ProtocolRuntimeEventTestStatus protocol15_signon=$ProtocolSignonTestStatus protocol15_delivery=$ProtocolDeliveryTestStatus protocol15_datagram=$ProtocolDatagramTestStatus protocol15_demo=$ProtocolDemoTestStatus protocol15_closure=$ProtocolClosureTestStatus quakec_progs=$QuakeCProgsTestStatus quakec_vm=$QuakeCVMTestStatus quakec_edicts=$QuakeCEdictTestStatus quakec_builtins=$QuakeCBuiltinTestStatus quakec_closure=$QuakeCClosureTestStatus quakec_stock=$QuakeCStockTestStatus world_hull=$WorldHullTestStatus world_trace=$WorldTraceTestStatus world_link=$WorldLinkTestStatus server_move=$ServerMoveTestStatus server_physics=$ServerPhysicsTestStatus sv_user_movement=$SvUserMovementTestStatus backward_movement_retail=$BackwardMovementRetailTestStatus boss_visibility_retail=$BossVisibilityRetailTestStatus player_collision_telefrag_retail=$PlayerCollisionTelefragRetailTestStatus server_user=$ServerUserTestStatus world_physics_closure=$WorldPhysicsClosureTestStatus host_timing=$HostTimingTestStatus command_cvar=$CommandCvarTestStatus demo_lifecycle=$DemoLifecycleTestStatus savegame_v5=$SavegameV5TestStatus host_lifecycle_closure=$HostLifecycleClosureTestStatus client_state_render=$ClientStateRenderTestStatus view_state=$ViewStateTestStatus temporary_beams=$TemporaryBeamTestStatus particle_runtime=$ParticleRuntimeTestStatus client_render_closure=$ClientRenderClosureTestStatus world_surfaces=$WorldSurfaceRenderTestStatus lightmap_atlas=$LightmapAtlasTestStatus dynamic_light_render=$DynamicLightRenderTestStatus sky_water=$SkyWaterRenderTestStatus world_render_closure=$WorldRenderClosureTestStatus alias_model=$AliasModelTestStatus sprite_sync=$SpriteSyncTestStatus render_ui_hud=$RenderUiHudTestStatus render_evidence=$RenderEvidenceTestStatus model_ui_render_closure=$ModelUiRenderClosureTestStatus mirror_special=$MirrorSpecialTestStatus render_clear_special=$RenderClearSpecialTestStatus envmap_timerefresh=$EnvmapTimeRefreshTestStatus render_evidence_corpus=$RenderEvidenceCorpusTestStatus render_special_closure=$RenderSpecialClosureTestStatus audio_memory=$AudioMemoryTestStatus audio_dma=$AudioDmaTestStatus audio_mixer=$AudioMixerTestStatus audio_win=$AudioWinTestStatus audio_closure=$AudioClosureTestStatus audio_retail_evidence=$AudioRetailEvidenceStatus network_main=$NetworkMainTestStatus network_control=$NetworkControlTestStatus network_wins=$NetworkWinsAddressTestStatus system_platform=$SystemPlatformTestStatus network_platform_closure=$NetworkPlatformClosureTestStatus network_platform_evidence=$NetworkPlatformEvidenceStatus key_focus=$KeyFocusTestStatus input_device=$InputDeviceTestStatus console_screen=$ConsoleScreenTestStatus menu_lifecycle=$MenuLifecycleTestStatus frontend_closure=$FrontendClosureTestStatus common_core=$CommonCoreTestStatus filesystem_pack=$FilesystemPackTestStatus wad_graphics=$WadGraphicsTestStatus model_assets=$ModelAssetTestStatus core_assets_memory=$CoreAssetsMemoryTestStatus core_asset_retail_evidence=$CoreAssetRetailEvidenceStatus gameplay_math_chase=$GameplayMathChaseTestStatus gameplay_view=$GameplayViewTestStatus gameplay_screen=$GameplayScreenTestStatus gameplay_statusbar=$GameplayStatusbarTestStatus gameplay_presentation_closure=$GameplayPresentationClosureTestStatus cvar_source_surface=$CvarSourceSurfaceTestStatus cd_audio_source_surface=$CdAudioSourceSurfaceTestStatus source_inventory=$SourceFunctionInventoryTestStatus black_port_corpus=$BlackPortCorpusTestStatus black_port_source_closure=$BlackPortSourceClosureTestStatus game_profile=$GameProfileTestStatus mod_runtime=$ModRuntimeTestStatus artifact_compat=$ArtifactCompatTestStatus stability=$StabilityTestStatus compat_release=$CompatibilityReleaseTestStatus original_reference=$OriginalReferenceTestStatus original_server_interop=$OriginalServerInteropTestStatus original_client_interop=$OriginalClientInteropTestStatus original_visual_reference=$OriginalVisualReferenceTestStatus external_compat_closure=$ExternalCompatibilityClosureTestStatus artifact_retail_evidence=$ArtifactRetailEvidenceStatus network=$NetworkTestStatus"
Write-Host "[MiniQuake] build completed: $GameExe"
exit 0
