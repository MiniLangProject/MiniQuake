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
  [int]$Frames = 120,

  [ValidateRange(1, 1000000)]
  [int]$TraceFrames = 64,

  [ValidateSet("Release", "Debug")]
  [string]$Configuration = "Release",

  [switch]$SkipBuild,
  [switch]$SkipGameValidation,
  [switch]$SkipTraceValidation,
  [switch]$NetworkTests,
  [switch]$RebuildNative,
  [switch]$Listings
)

$ErrorActionPreference = "Stop"
$Target = Join-Path $PSScriptRoot "TEST_BP-010R1.ps1"
Write-Warning "BP-001R3 is superseded by BP-010R1; forwarding to TEST_BP-010R1.ps1."
& $Target @PSBoundParameters
exit [int]$LASTEXITCODE
