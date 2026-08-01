[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string]$QuakeBase,

  [string]$Map = "start",
  [string]$Game = "id1",
  [int]$Frames = 300,
  [int]$TraceFrames = 128,
  [int]$RenderEvidenceFrame = 128,
  [string]$Compiler = "",
  [string]$StdLib = "",
  [string]$Python = "",
  [switch]$SkipBuild,
  [switch]$NetworkTests,
  [switch]$BisectOnFailure
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$Root = Split-Path -Parent $PSScriptRoot
$TestScript = Join-Path $Root "TEST_BP-045-049.ps1"
$PowerShellExecutable = (Get-Process -Id $PID).Path
$Arguments = @(
  "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $TestScript,
  "-QuakeBase", $QuakeBase,
  "-Map", $Map,
  "-Game", $Game,
  "-Frames", [string]$Frames,
  "-TraceFrames", [string]$TraceFrames,
  "-RenderEvidenceFrame", [string]$RenderEvidenceFrame
)
if (-not [string]::IsNullOrWhiteSpace($Compiler)) { $Arguments += @("-Compiler", $Compiler) }
if (-not [string]::IsNullOrWhiteSpace($StdLib)) { $Arguments += @("-StdLib", $StdLib) }
if (-not [string]::IsNullOrWhiteSpace($Python)) { $Arguments += @("-Python", $Python) }
if ($SkipBuild) { $Arguments += "-SkipBuild" }
if ($NetworkTests) { $Arguments += "-NetworkTests" }
if ($BisectOnFailure) { $Arguments += "-BisectOnFailure" }

& $PowerShellExecutable @Arguments
$ExitCode = [int]$LASTEXITCODE
exit $ExitCode
