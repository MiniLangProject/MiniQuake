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
  [switch]$Listings
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$Root = $PSScriptRoot
$Output = Join-Path $Root "build"
$Source = Join-Path $Root "src"
$Parent = Split-Path -Parent $Root

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
if ($CompilerIsPython -or $RebuildNative) {
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

function Invoke-MiniLangCompile {
  param(
    [Parameter(Mandatory = $true)]
    [string]$InputFile,

    [Parameter(Mandatory = $true)]
    [string]$OutputFile,

    [Parameter(Mandatory = $true)]
    [string[]]$CompilerArguments
  )

  if ($CompilerIsPython) {
    & $PythonExe @PythonPrefixArgs $Compiler $InputFile $OutputFile @CompilerArguments
  } else {
    & $Compiler $InputFile $OutputFile @CompilerArguments
  }

  if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
  }
}

New-Item -ItemType Directory -Force -Path $Output | Out-Null

Write-Host "[MiniQuake] compiler:        $Compiler"
if ($CompilerIsPython) {
  Write-Host "[MiniQuake] compiler kind:   Python reference compiler"
  Write-Host "[MiniQuake] python:          $PythonExe $($PythonPrefixArgs -join ' ')"
} else {
  Write-Host "[MiniQuake] compiler kind:   native self-hosted compiler"
}
Write-Host "[MiniQuake] source root:     $Source"
Write-Host "[MiniQuake] std import root: $StdImportRoot"

if ($CompilerIsPython) {
  Write-Host "[MiniQuake] running MiniLang source preflight"

  $StructuralLint = Join-Path $Root "tools\ml_lint.py"
  & $PythonExe @PythonPrefixArgs $StructuralLint $Root
  if ($LASTEXITCODE -ne 0) {
    throw "MiniQuake structural source preflight failed."
  }

  $ScopeLint = Join-Path $Root "tools\ml_scope_lint.py"
  & $PythonExe @PythonPrefixArgs $ScopeLint $Root "--compiler-root" $StdImportRoot
  if ($LASTEXITCODE -ne 0) {
    throw "MiniQuake lexical-scope source preflight failed."
  }
}

if ($RebuildNative) {
  Write-Host "[MiniQuake] rebuilding native bridge"
  & $PythonExe @PythonPrefixArgs (Join-Path $Root "native\build_bridge.py") "--clean"
  if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
  }
}

$Bridge = Join-Path $Root "native\miniquake_native.dll"
if (-not (Test-Path -LiteralPath $Bridge -PathType Leaf)) {
  throw "Native bridge is missing: $Bridge"
}
Copy-Item -Force -LiteralPath $Bridge -Destination (Join-Path $Output "miniquake_native.dll")

$CommonArgs = @(
  "-I", $Source,
  "-I", $StdImportRoot,
  "--keep-going", "--max-errors", "50",
  "--heap-reserve", "512m",
  "--heap-commit", "32m",
  "--heap-grow", "4m"
)

if ($Configuration -ieq "Debug") {
  $CommonArgs += @("--trace-calls")
}
if ($Listings) {
  $CommonArgs += @("--asm", "--asm-pe", "--asm-data")
}

$GameExe = Join-Path $Output "MiniQuake.exe"
Write-Host "[MiniQuake] compiling $GameExe"
Invoke-MiniLangCompile (Join-Path $Source "main.ml") $GameExe $CommonArgs

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
  & $Executable
  $ExitCode = [int]$LASTEXITCODE
  $ExitUnsigned = [System.BitConverter]::ToUInt32(
    [System.BitConverter]::GetBytes($ExitCode),
    0
  )
  $ExitHex = "0x{0:X8}" -f $ExitUnsigned
  Write-Host "[MiniQuake] $Label exit code: $ExitCode ($ExitHex)"
  if ($ExitCode -ne 0) {
    Write-Error "MiniQuake $Label did not complete successfully. $ProgressHint"
    exit $ExitCode
  }
}

if (-not $SkipTests) {
  $TestExe = Join-Path $Output "MiniQuakeTests.exe"
  Write-Host "[MiniQuake] compiling $TestExe"
  Invoke-MiniLangCompile (Join-Path $Root "tests\core_tests.ml") $TestExe $CommonArgs

  $MilestoneTestExe = $null
  if (-not $SkipMilestoneTests) {
    $MilestoneTestExe = Join-Path $Output "MiniQuakeMilestoneTests.exe"
    Write-Host "[MiniQuake] compiling $MilestoneTestExe"
    Invoke-MiniLangCompile (Join-Path $Root "tests\milestone_tests.ml") $MilestoneTestExe $CommonArgs
  }

  if (-not $NoRunTests) {
    Invoke-MiniQuakeTestBinary `
      -Label "core tests" `
      -Executable $TestExe `
      -ProgressHint "The last printed [NN/15] line identifies the active test; if no test line appeared, the process failed during image loading or module initialization."

    if ($null -ne $MilestoneTestExe) {
      Invoke-MiniQuakeTestBinary `
        -Label "milestone tests" `
        -Executable $MilestoneTestExe `
        -ProgressHint "The last printed [NN/20] line identifies the active subsystem."
    }
  }
}

if ($NetworkTests -and -not $NoRunTests) {
  Write-Host "[MiniQuake] running UDP loopback smoke"
  & $GameExe "--udp-smoke" "2000"
  $NetworkExitCode = [int]$LASTEXITCODE
  if ($NetworkExitCode -ne 0) {
    Write-Error "MiniQuake UDP loopback smoke failed with exit code $NetworkExitCode."
    exit $NetworkExitCode
  }
}

Write-Host "[MiniQuake] build completed: $GameExe"
exit 0
