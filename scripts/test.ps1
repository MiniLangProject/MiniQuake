# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: Apache-2.0
# Run the complete MiniQuake source, native, runtime, retail and interop suite.

[CmdletBinding()]
param(
  [string]$Compiler = "",
  [string]$StdLib = "",
  [string]$Python = "",
  [ValidateSet("Release", "Debug")]
  [string]$Configuration = "Release",
  [string]$QuakeBase = "",
  [string]$Game = "id1",
  [string]$Map = "start",
  [int]$Frames = 300,
  [int]$RendererFrames = 120,
  [switch]$RebuildNative = $true,
  [switch]$NetworkTests = $true,
  [switch]$AllInstalledGames = $true,
  [switch]$SkipTests,
  [switch]$SkipMilestoneTests,
  [switch]$NoRunTests,
  [switch]$Listings,
  [switch]$SkipPreflight
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$Root = Split-Path -Parent $PSScriptRoot

# Resolve retail data from an explicit argument, an environment override or
# the standard Steam installations so the default command needs no arguments.
function Resolve-QuakeDirectory {
  param([string]$RequestedPath)

  $Candidates = [System.Collections.Generic.List[string]]::new()
  if (-not [string]::IsNullOrWhiteSpace($RequestedPath)) {
    $Candidates.Add($RequestedPath)
  }
  if (-not [string]::IsNullOrWhiteSpace($env:MINIQUAKE_QUAKE_BASE)) {
    $Candidates.Add($env:MINIQUAKE_QUAKE_BASE)
  }
  if (-not [string]::IsNullOrWhiteSpace(${env:ProgramFiles(x86)})) {
    $Candidates.Add((Join-Path ${env:ProgramFiles(x86)} "Steam\steamapps\common\Quake"))
  }
  if (-not [string]::IsNullOrWhiteSpace($env:ProgramFiles)) {
    $Candidates.Add((Join-Path $env:ProgramFiles "Steam\steamapps\common\Quake"))
  }

  foreach ($Candidate in $Candidates) {
    if ([string]::IsNullOrWhiteSpace($Candidate)) { continue }
    $FullPath = [System.IO.Path]::GetFullPath($Candidate)
    if (Test-Path -LiteralPath (Join-Path $FullPath "id1\pak0.pak") -PathType Leaf) {
      return $FullPath
    }
  }
  throw "Quake retail data was not found. Pass -QuakeBase or set MINIQUAKE_QUAKE_BASE."
}

$ResolvedQuakeBase = Resolve-QuakeDirectory $QuakeBase
Write-Host "[MiniQuake full suite] retail data: $ResolvedQuakeBase"

$BuildParameters = @{
  Configuration = $Configuration
}
if (-not [string]::IsNullOrWhiteSpace($Compiler)) { $BuildParameters.Compiler = $Compiler }
if (-not [string]::IsNullOrWhiteSpace($StdLib)) { $BuildParameters.StdLib = $StdLib }
if (-not [string]::IsNullOrWhiteSpace($Python)) { $BuildParameters.Python = $Python }
if ($RebuildNative) { $BuildParameters.RebuildNative = $true }
if ($NetworkTests) { $BuildParameters.NetworkTests = $true }
if ($SkipTests) { $BuildParameters.SkipTests = $true }
if ($SkipMilestoneTests) { $BuildParameters.SkipMilestoneTests = $true }
if ($NoRunTests) { $BuildParameters.NoRunTests = $true }
if ($Listings) { $BuildParameters.Listings = $true }
if ($SkipPreflight) { $BuildParameters.SkipPreflight = $true }

$NativeSnapshots = @{}
if ($RebuildNative) {
  foreach ($NativeName in @("miniquake_native.dll", "miniquake_text.dll")) {
    $NativePath = Join-Path $Root "native\$NativeName"
    if (Test-Path -LiteralPath $NativePath -PathType Leaf) {
      $NativeSnapshots[$NativePath] = [System.IO.File]::ReadAllBytes($NativePath)
    }
  }
}

try {
  & (Join-Path $Root "build.ps1") @BuildParameters

  $ValidationParameters = @{
    QuakeBase = $ResolvedQuakeBase
    Game = $Game
    Map = $Map
    Frames = $Frames
    RendererFrames = $RendererFrames
    SkipBuild = $true
    FullSuite = $true
    AllInstalledGames = [bool]$AllInstalledGames
  }
  & (Join-Path $PSScriptRoot "validate_real_game.ps1") @ValidationParameters
} finally {
  # The rebuilt copies remain in build/ for the tests, while tracked reference
  # artifacts return to their exact pre-test bytes even if a test fails.
  foreach ($NativePath in $NativeSnapshots.Keys) {
    [System.IO.File]::WriteAllBytes($NativePath, $NativeSnapshots[$NativePath])
  }
}

Write-Host "MiniQuake complete one-script test suite: PASS" -ForegroundColor Green
