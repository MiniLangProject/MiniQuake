# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: Apache-2.0
# Validate MiniQuake against locally installed retail Quake data.

[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string]$QuakeBase,
  [string]$Map = "start",
  [string]$Game = "id1",
  [int]$Frames = 300,
  [int]$RendererFrames = 120,
  [string]$Compiler = "",
  [string]$StdLib = "",
  [string]$Python = "",
  [switch]$SkipBuild,
  [switch]$NetworkTests,
  [switch]$RebuildNative,
  [switch]$FullSuite,
  [switch]$AllInstalledGames
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$Root = Split-Path -Parent $PSScriptRoot
$BuildDirectory = Join-Path $Root "build"
$GameExecutable = Join-Path $BuildDirectory "MiniQuake.exe"

# Run one executable, echo its purpose and turn every nonzero exit into a
# terminating suite failure.
function Invoke-CheckedExecutable {
  param(
    [Parameter(Mandatory = $true)][string]$Label,
    [Parameter(Mandatory = $true)][string]$Executable,
    [Parameter(Mandatory = $true)][object[]]$ArgumentList
  )

  if (-not (Test-Path -LiteralPath $Executable -PathType Leaf)) {
    throw "$Label executable does not exist: $Executable"
  }
  Write-Host "[MiniQuake retail] running $Label"
  & $Executable @ArgumentList
  if ($LASTEXITCODE -ne 0) {
    throw "$Label failed with exit code $LASTEXITCODE"
  }
  Write-Host "[MiniQuake retail] PASS $Label" -ForegroundColor Green
}

# Add one installed game profile exactly once while preserving caller order.
function Add-InstalledProfile {
  param(
    [Parameter(Mandatory = $true)][AllowEmptyCollection()][System.Collections.Generic.List[object]]$Profiles,
    [Parameter(Mandatory = $true)][AllowEmptyCollection()][System.Collections.Generic.HashSet[string]]$Seen,
    [Parameter(Mandatory = $true)][string]$Directory,
    [Parameter(Mandatory = $true)][string]$MapName
  )

  if (-not $Seen.Add($Directory)) { return }
  $GamePath = Join-Path $QuakeBase $Directory
  if (-not (Test-Path -LiteralPath $GamePath -PathType Container)) { return }
  $Profiles.Add([pscustomobject]@{ Game = $Directory; Map = $MapName })
}

# Resolve the requested profile plus all installed official game directories.
function Get-RetailProfiles {
  $Profiles = [System.Collections.Generic.List[object]]::new()
  $Seen = [System.Collections.Generic.HashSet[string]]::new(
    [System.StringComparer]::OrdinalIgnoreCase
  )
  Add-InstalledProfile $Profiles $Seen $Game $Map
  if ($AllInstalledGames) {
    Add-InstalledProfile $Profiles $Seen "id1" "start"
    Add-InstalledProfile $Profiles $Seen "hipnotic" "hip1m1"
    Add-InstalledProfile $Profiles $Seen "rogue" "r1m1"
  }
  if ($Profiles.Count -eq 0) {
    throw "No requested Quake game directory is installed below $QuakeBase"
  }
  return $Profiles.ToArray()
}

# Exercise the real independent-process UDP control handshake without opening
# extra console windows or leaving a background server alive after a failure.
function Invoke-TwoProcessNetworkEvidence {
  param([Parameter(Mandatory = $true)][string]$EvidenceExecutable)

  $Probe = [System.Net.Sockets.UdpClient]::new(0)
  try {
    $Port = ([System.Net.IPEndPoint]$Probe.Client.LocalEndPoint).Port
  } finally {
    $Probe.Dispose()
  }

  $StartInfo = [System.Diagnostics.ProcessStartInfo]::new()
  $StartInfo.FileName = $EvidenceExecutable
  $StartInfo.Arguments = "server $Port"
  $StartInfo.UseShellExecute = $false
  $StartInfo.CreateNoWindow = $true
  $StartInfo.RedirectStandardOutput = $true
  $StartInfo.RedirectStandardError = $true
  $ServerProcess = [System.Diagnostics.Process]::new()
  $ServerProcess.StartInfo = $StartInfo

  try {
    if (-not $ServerProcess.Start()) { throw "Could not start network evidence server." }
    [void]$ServerProcess.WaitForExit(250)
    if ($ServerProcess.HasExited) {
      throw "Network evidence server exited before the client connected."
    }

    Invoke-CheckedExecutable "two-process network client" $EvidenceExecutable @("client", "$Port")
    if (-not $ServerProcess.WaitForExit(7000)) {
      throw "Network evidence server did not finish within seven seconds."
    }
    $ServerOutput = $ServerProcess.StandardOutput.ReadToEnd()
    $ServerError = $ServerProcess.StandardError.ReadToEnd()
    if (-not [string]::IsNullOrWhiteSpace($ServerOutput)) { Write-Host $ServerOutput.TrimEnd() }
    if (-not [string]::IsNullOrWhiteSpace($ServerError)) { Write-Host $ServerError.TrimEnd() }
    if ($ServerProcess.ExitCode -ne 0) {
      throw "Network evidence server failed with exit code $($ServerProcess.ExitCode)"
    }
    Write-Host "[MiniQuake retail] PASS two-process network server" -ForegroundColor Green
  } finally {
    if (-not $ServerProcess.HasExited) {
      $ServerProcess.Kill()
      $ServerProcess.WaitForExit()
    }
    $ServerProcess.Dispose()
  }
}

if (-not (Test-Path -LiteralPath $QuakeBase -PathType Container)) {
  throw "Quake directory does not exist: $QuakeBase"
}

if (-not $SkipBuild) {
  $BuildParameters = @{}
  if (-not [string]::IsNullOrWhiteSpace($Compiler)) { $BuildParameters.Compiler = $Compiler }
  if (-not [string]::IsNullOrWhiteSpace($StdLib)) { $BuildParameters.StdLib = $StdLib }
  if (-not [string]::IsNullOrWhiteSpace($Python)) { $BuildParameters.Python = $Python }
  if ($NetworkTests) { $BuildParameters.NetworkTests = $true }
  if ($RebuildNative) { $BuildParameters.RebuildNative = $true }
  & (Join-Path $Root "build.ps1") @BuildParameters
}

$Profiles = @(Get-RetailProfiles)
foreach ($Profile in $Profiles) {
  $ProfileLabel = "$($Profile.Game)/$($Profile.Map)"
  Invoke-CheckedExecutable "asset validation $ProfileLabel" $GameExecutable @(
    "--validate-game", $QuakeBase, $Profile.Map, "-game", $Profile.Game
  )
  Invoke-CheckedExecutable "runtime validation $ProfileLabel" $GameExecutable @(
    "--validate-runtime", $QuakeBase, $Profile.Map, "$Frames", "-game", $Profile.Game
  )
  Invoke-CheckedExecutable "render smoke $ProfileLabel" $GameExecutable @(
    "--render-smoke", $QuakeBase, $Profile.Map, "$Frames", "-game", $Profile.Game
  )
}

if ($FullSuite) {
  foreach ($Profile in $Profiles) {
    $ProfileLabel = "$($Profile.Game)/$($Profile.Map)"
    Invoke-CheckedExecutable "stock QuakeC $($Profile.Game)" `
      (Join-Path $BuildDirectory "MiniQuakeQuakeCStockTests.exe") @($QuakeBase, $Profile.Game)
    Invoke-CheckedExecutable "retail audio $($Profile.Game)" `
      (Join-Path $BuildDirectory "MiniQuakeAudioRetailEvidence.exe") @($QuakeBase, $Profile.Game)
    Invoke-CheckedExecutable "core assets $($Profile.Game)" `
      (Join-Path $BuildDirectory "MiniQuakeCoreAssetRetailEvidence.exe") @($QuakeBase, $Profile.Game)
    Invoke-CheckedExecutable "renderer switch $ProfileLabel" $GameExecutable @(
      "--renderer-switch-smoke", $QuakeBase, $Profile.Map, "$RendererFrames",
      (Join-Path $BuildDirectory "full-suite-$($Profile.Game)-renderer"), "-game", $Profile.Game
    )
  }

  if (Test-Path -LiteralPath (Join-Path $QuakeBase "id1") -PathType Container) {
    Invoke-CheckedExecutable "backward movement retail" `
      (Join-Path $BuildDirectory "MiniQuakeBackwardMovementRetailTests.exe") @($QuakeBase, "id1")
    Invoke-CheckedExecutable "cheat retail" `
      (Join-Path $BuildDirectory "MiniQuakeCheatRetailTests.exe") @($QuakeBase, "id1")
    Invoke-CheckedExecutable "Chthon visibility retail" `
      (Join-Path $BuildDirectory "MiniQuakeBossVisibilityRetailTests.exe") @($QuakeBase)
    Invoke-CheckedExecutable "player collision and telefrag retail" `
      (Join-Path $BuildDirectory "MiniQuakePlayerCollisionTelefragRetailTests.exe") @($QuakeBase, "id1")
    Invoke-CheckedExecutable "artifact/save/demo retail" `
      (Join-Path $BuildDirectory "MiniQuakeArtifactRetailEvidence.exe") @($QuakeBase, "id1", "start")
  }

  Invoke-TwoProcessNetworkEvidence `
    (Join-Path $BuildDirectory "MiniQuakeNetworkPlatformEvidence.exe")
}

Write-Host "MiniQuake retail validation: PASS ($($Profiles.Count) game profile(s))" -ForegroundColor Green
