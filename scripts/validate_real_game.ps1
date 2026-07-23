[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string]$QuakeBase,

  [string]$Game = "id1",
  [string]$Map = "start",
  [string]$Compiler = "",
  [string]$StdLib = "",

  [ValidateRange(1, 1000000)]
  [int]$RuntimeFrames = 720,

  [ValidateRange(1, 1000000)]
  [int]$VisualFrames = 240,

  [ValidateRange(1, 2000000000)]
  [int]$SoakFrames = 10000,

  [switch]$SkipBuild,
  [switch]$SkipOpenGL,
  [switch]$SkipVisualHost,
  [switch]$SkipSoak,
  [switch]$SkipUdp
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$Root = Split-Path -Parent $PSScriptRoot
$Build = Join-Path $Root "build"
$Exe = Join-Path $Build "MiniQuake.exe"
$GameRoot = Join-Path $QuakeBase $Game
$Pak0 = Join-Path $GameRoot "pak0.pak"

if (-not (Test-Path -LiteralPath $QuakeBase -PathType Container)) {
  throw "Quake base directory not found: $QuakeBase"
}
if (-not (Test-Path -LiteralPath $Pak0 -PathType Leaf)) {
  throw "Required game archive not found: $Pak0. QuakeBase must be the directory that contains '$Game'."
}

function Invoke-Checked {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Label,

    [Parameter(Mandatory = $true)]
    [string]$Program,

    [string[]]$Arguments = @()
  )

  Write-Host ""
  Write-Host "=== $Label ==="
  Write-Host "> $Program $($Arguments -join ' ')"
  & $Program @Arguments
  $Code = [int]$LASTEXITCODE
  $Unsigned = [BitConverter]::ToUInt32([BitConverter]::GetBytes($Code), 0)
  Write-Host ("[$Label] exit={0}, hex=0x{1:X8}" -f $Code, $Unsigned)
  if ($Code -ne 0) {
    throw "$Label failed with exit code $Code (0x$('{0:X8}' -f $Unsigned))."
  }
}

if (-not $SkipBuild) {
  $BuildArguments = @()
  if (-not [string]::IsNullOrWhiteSpace($Compiler)) {
    $BuildArguments += @("-Compiler", $Compiler)
  }
  if (-not [string]::IsNullOrWhiteSpace($StdLib)) {
    $BuildArguments += @("-StdLib", $StdLib)
  }
  if (-not $SkipUdp) {
    $BuildArguments += "-NetworkTests"
  }
  & (Join-Path $Root "build.ps1") @BuildArguments
  if ($LASTEXITCODE -ne 0) {
    throw "MiniQuake build failed with exit code $LASTEXITCODE."
  }
}

if (-not (Test-Path -LiteralPath $Exe -PathType Leaf)) {
  throw "MiniQuake executable not found after build: $Exe"
}

Invoke-Checked "version/self-check" $Exe @("--version")
Invoke-Checked "real game-data validation" $Exe @("--validate-game", $QuakeBase, $Map, "-game", $Game)
Invoke-Checked "integrated runtime validation" $Exe @("--validate-runtime", $QuakeBase, $Map, "$RuntimeFrames", "-game", $Game)
Invoke-Checked "headless Host_Frame smoke" $Exe @("--runtime-smoke", $QuakeBase, $Map, "$RuntimeFrames", "-game", $Game)

if (-not $SkipUdp) {
  Invoke-Checked "Winsock UDP loopback" $Exe @("--udp-smoke", "2000")
}

if (-not $SkipOpenGL) {
  Invoke-Checked "Win32/WGL/OpenGL smoke" $Exe @("--gl-smoke-frames", "120")
}

if (-not $SkipVisualHost) {
  Invoke-Checked "textured integrated host" $Exe @(
    "-basedir", $QuakeBase,
    "-game", $Game,
    "-width", "1280",
    "-height", "720",
    "-maxframes", "$VisualFrames",
    "+map", $Map
  )
}

if (-not $SkipSoak) {
  Invoke-Checked "host/GC soak" $Exe @("--soak", $QuakeBase, $Map, "$SoakFrames", "-game", $Game)
}

$Report = [ordered]@{
  status = "passed"
  timestamp_utc = [DateTime]::UtcNow.ToString("o")
  executable = $Exe
  quake_base = [IO.Path]::GetFullPath($QuakeBase)
  game = $Game
  map = $Map
  runtime_frames = $RuntimeFrames
  visual_frames = if ($SkipVisualHost) { 0 } else { $VisualFrames }
  soak_frames = if ($SkipSoak) { 0 } else { $SoakFrames }
  opengl_checked = -not $SkipOpenGL
  udp_checked = -not $SkipUdp
}
$ReportPath = Join-Path $Build "real-game-validation.json"
$Report | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $ReportPath -Encoding UTF8
Write-Host ""
Write-Host "MiniQuake real-game validation: PASS"
Write-Host "Report: $ReportPath"
