# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: Apache-2.0
# Run the current MiniQuake build and acceptance suite without legacy package runners.

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
  [switch]$RebuildNative,
  [switch]$NetworkTests,
  [switch]$SkipTests,
  [switch]$SkipMilestoneTests,
  [switch]$NoRunTests,
  [switch]$Listings,
  [switch]$SkipPreflight
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$Root = Split-Path -Parent $PSScriptRoot
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

& (Join-Path $Root "build.ps1") @BuildParameters

if (-not [string]::IsNullOrWhiteSpace($QuakeBase)) {
  & (Join-Path $PSScriptRoot "validate_real_game.ps1") `
    -QuakeBase $QuakeBase -Game $Game -Map $Map -SkipBuild
}
