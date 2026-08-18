# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: Apache-2.0
# Validate MiniQuake against a caller-supplied retail Quake installation.

[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string]$QuakeBase,
  [string]$Map = "start",
  [string]$Game = "id1",
  [int]$Frames = 300,
  [string]$Compiler = "",
  [string]$StdLib = "",
  [string]$Python = "",
  [switch]$SkipBuild,
  [switch]$NetworkTests
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$Root = Split-Path -Parent $PSScriptRoot
$GameExecutable = Join-Path $Root "build\MiniQuake.exe"

if (-not $SkipBuild) {
  $BuildParameters = @{}
  if (-not [string]::IsNullOrWhiteSpace($Compiler)) { $BuildParameters.Compiler = $Compiler }
  if (-not [string]::IsNullOrWhiteSpace($StdLib)) { $BuildParameters.StdLib = $StdLib }
  if (-not [string]::IsNullOrWhiteSpace($Python)) { $BuildParameters.Python = $Python }
  if ($NetworkTests) { $BuildParameters.NetworkTests = $true }
  & (Join-Path $Root "build.ps1") @BuildParameters
}

if (-not (Test-Path -LiteralPath $GameExecutable -PathType Leaf)) {
  throw "MiniQuake executable does not exist: $GameExecutable"
}
if (-not (Test-Path -LiteralPath $QuakeBase -PathType Container)) {
  throw "Quake directory does not exist: $QuakeBase"
}

# Run asset validation, deterministic simulation, and a real renderer pass.
& $GameExecutable --validate-game $QuakeBase $Map -game $Game
if ($LASTEXITCODE -ne 0) { throw "Asset validation failed with exit code $LASTEXITCODE" }
& $GameExecutable --validate-runtime $QuakeBase $Map $Frames -game $Game
if ($LASTEXITCODE -ne 0) { throw "Runtime validation failed with exit code $LASTEXITCODE" }
& $GameExecutable --render-smoke $QuakeBase $Map $Frames -game $Game
if ($LASTEXITCODE -ne 0) { throw "Renderer validation failed with exit code $LASTEXITCODE" }

Write-Host "MiniQuake retail validation passed." -ForegroundColor Green
