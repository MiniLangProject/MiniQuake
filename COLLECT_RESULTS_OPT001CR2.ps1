[CmdletBinding()]
param([switch]$IncludeAllCurrentDocs)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
$Root = $PSScriptRoot
$Build = Join-Path $Root "build"
$PackageId = "BP-094"
$BlockId = "BP-090-094"
$DeliveryRevision = "OPT-001CR2"
$DeliveryParent = "OPT-001CR1"
$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
# original_reference_binary_in_result_archive=$false
# historical external staging marker retained for contract verification: bp090-094-original-reference
# quake_game_data_in_result_archive=$false
$Staging = Join-Path $Build (".opt001cr2-results-{0}" -f $Timestamp)
$Archive = Join-Path $Build ("MiniQuake_OPT-001CR2_RESULTS_{0}.zip" -f $Timestamp)

if (-not (Test-Path -LiteralPath $Build -PathType Container)) { throw "build directory does not exist: $Build" }
if (Test-Path -LiteralPath $Staging) { Remove-Item -Recurse -Force -LiteralPath $Staging }
New-Item -ItemType Directory -Force -Path $Staging | Out-Null

$AllowedBuildExtensions = @(".log", ".json", ".txt", ".csv", ".mqtrace", ".md")
$ForbiddenNames = @("pak0.pak", "pak1.pak", "progs.dat", "config.cfg", "autoexec.cfg", "gfx.wad", "glquake.exe", "opengl32.dll")
$SyntheticBuildRoots = @("bp071_fs", "bp071-filesystem", "bp072-wad", "sys_win_differential")
$SkippedBuildArtifacts = @()

function Get-BuildArtifactExclusionReason([string]$Relative) {
  $Normalized = $Relative.Replace('/', '\').TrimStart('\')
  $Leaf = [IO.Path]::GetFileName($Normalized).ToLowerInvariant()

  if ($Normalized -match '(?i)^bp090-094(?:r[0-9]+)?-original-reference(?:\\|$)') {
    return "build-only original GLQuake/Quake-data staging area"
  }
  if (($Normalized -match '(?i)^bp090-094(?:r[0-9]+)?-original-visual(?:\\|$)') -and
      $Leaf.EndsWith(".tga")) {
    return "external framebuffer image"
  }

  foreach ($Prefix in $SyntheticBuildRoots) {
    if ($Normalized.Equals($Prefix, [StringComparison]::OrdinalIgnoreCase) -or
        $Normalized.StartsWith(($Prefix + "\"), [StringComparison]::OrdinalIgnoreCase)) {
      return "synthetic test workspace"
    }
  }
  if ($ForbiddenNames -contains $Leaf) { return "forbidden Quake filename" }
  if ($Normalized -match '(?i)(^|\\)(id1|hipnotic|rogue)(\\|$)') { return "Quake game-directory path" }
  return ""
}

function Copy-SafeFile([string]$Source, [string]$Relative) {
  if (-not (Test-Path -LiteralPath $Source -PathType Leaf)) { return }
  $Leaf = [IO.Path]::GetFileName($Source).ToLowerInvariant()
  if ($ForbiddenNames -contains $Leaf) { throw "refusing to collect Quake game data: $Source" }
  $Normalized = $Relative.Replace('/', '\')
  if ($Normalized -match '(?i)(^|\\)(id1|hipnotic|rogue)(\\|$)') { throw "refusing to collect Quake game-directory content: $Relative" }
  $Destination = Join-Path $Staging $Normalized
  $Parent = Split-Path -Parent $Destination
  if (-not [string]::IsNullOrWhiteSpace($Parent)) { New-Item -ItemType Directory -Force -Path $Parent | Out-Null }
  Copy-Item -Force -LiteralPath $Source -Destination $Destination
}

Get-ChildItem -LiteralPath $Build -Recurse -File | ForEach-Object {
  if ($_.FullName.StartsWith($Staging, [StringComparison]::OrdinalIgnoreCase)) { return }
  if ($_.FullName -eq $Archive) { return }
  if ($AllowedBuildExtensions -contains $_.Extension.ToLowerInvariant()) {
    $Relative = $_.FullName.Substring($Build.Length).TrimStart('\', '/')
    $Reason = Get-BuildArtifactExclusionReason $Relative
    if (-not [string]::IsNullOrWhiteSpace($Reason)) {
      $SkippedBuildArtifacts += [pscustomobject]@{
        path = (Join-Path "build" $Relative)
        reason = $Reason
      }
      return
    }
    Copy-SafeFile $_.FullName (Join-Path "build" $Relative)
  }
}

$RootFiles = @(
  "TEST_OPT-001CR2.ps1",
  "CHANGELOG_OPT-001CR2.md",
  "docs\OPT-001CR2_TESTING.md",
  "docs\OPT-001CR2_RESULT_ANALYSIS.md",
  "docs\OPT-001CR2_HOTFIX_REPORT.json",
  "docs\OPT-001CR2_DELIVERY_REPORT.json",
  "tools\check_opt001cr2.py",
  "audit\opt001cr2_harness_golden.json",
  "patches\OPT-001CR2.diff",
  "TEST_OPT-001CR1.ps1",
  "CHANGELOG_OPT-001CR1.md",
  "docs\OPT-001CR1_TESTING.md",
  "docs\OPT-001CR1_RESULT_ANALYSIS.md",
  "docs\OPT-001CR1_HOTFIX_REPORT.json",
  "docs\OPT-001CR1_DELIVERY_REPORT.json",
  "tools\check_opt001cr1.py",
  "tools\check_minilang_delimiters.py",
  "audit\opt001cr1_syntax_golden.json",
  "patches\OPT-001CR1.diff",
  "TEST_OPT-001C.ps1",
  "CHANGELOG_OPT-001C.md",
  "docs\OPT-001C_TESTING.md",
  "docs\OPT-001C_ALLOCATION_CONTRACT.md",
  "docs\OPT-001C_DELIVERY_REPORT.json",
  "tests\opt001c_contract_tests.ml",
  "tools\check_opt001c.py",
  "tools\compare_opt001c_performance.py",
  "audit\opt001c_allocation_golden.json",
  "audit\opt001b_performance_baseline.json",
  "patches\OPT-001C.diff",
  "TEST_OPT-001B.ps1",
  "CHANGELOG_OPT-001B.md",
  "docs\OPT-001B_TESTING.md",
  "docs\OPT-001B_CORRECTNESS_CONTRACT.md",
  "docs\OPT-001B_DELIVERY_REPORT.json",
  "tests\opt001b_contract_tests.ml",
  "tools\check_opt001b.py",
  "audit\opt001b_correctness_golden.json",
  "patches\OPT-001B.diff",
  "TEST_OPT-001A.ps1",
  "CHANGELOG_OPT-001A.md",
  "docs\OPT-001A_TESTING.md",
  "docs\OPT-001A_BASELINE_CONTRACT.md",
  "docs\OPT-001A_DELIVERY_REPORT.json",
  "src\miniquake\optimization_baseline.ml",
  "tests\opt001a_contract_tests.ml",
  "tools\check_opt001a.py",
  "tools\analyze_opt001a.py",
  "audit\opt001a_baseline_golden.json",
  "patches\OPT-001A.diff",
  "TEST_BP-085-089.ps1",
  "CHANGELOG_BP-085.md",
  "CHANGELOG_BP-086.md",
  "CHANGELOG_BP-087.md",
  "CHANGELOG_BP-088.md",
  "CHANGELOG_BP-089.md",
  "CHANGELOG_BP-085-089.md",
  "docs\BP-085_GAME_PROFILE_AUDIT.md",
  "docs\BP-086_MOD_RUNTIME_AUDIT.md",
  "docs\BP-087_ARTIFACT_COMPAT_AUDIT.md",
  "docs\BP-088_STABILITY_AUDIT.md",
  "docs\BP-089_COMPAT_RELEASE_CANDIDATE.md",
  "docs\BP-085-089_TESTING.md",
  "TEST_BP-085-089R8.ps1",
  "CHANGELOG_BP-085-089R8.md",
  "docs\BP-085-089R8_TESTING.md",
  "docs\BP-085-089R8_RESULT_ANALYSIS.md",
  "docs\BP-085-089R8_HOTFIX_REPORT.json",
  "docs\BP-085-089R8_BLOCK_LEDGER.json",
  "patches\BP-089R8.diff",
  "TEST_BP-085-089R7.ps1",
  "CHANGELOG_BP-085-089R7.md",
  "docs\BP-085-089R7_TESTING.md",
  "docs\BP-085-089R7_RESULT_ANALYSIS.md",
  "docs\BP-085-089R7_HOTFIX_REPORT.json",
  "docs\BP-085-089R7_BLOCK_LEDGER.json",
  "patches\BP-089R7.diff",
  "TEST_BP-085-089R6.ps1",
  "CHANGELOG_BP-085-089R6.md",
  "docs\BP-085-089R6_TESTING.md",
  "docs\BP-085-089R6_RESULT_ANALYSIS.md",
  "docs\BP-085-089R6_HOTFIX_REPORT.json",
  "docs\BP-085-089R6_BLOCK_LEDGER.json",
  "patches\BP-089R6.diff",
  "TEST_BP-085-089R5.ps1",
  "CHANGELOG_BP-085-089R5.md",
  "docs\BP-085-089R5_TESTING.md",
  "docs\BP-085-089R5_RESULT_ANALYSIS.md",
  "docs\BP-085-089R5_HOTFIX_REPORT.json",
  "docs\BP-085-089R5_BLOCK_LEDGER.json",
  "patches\BP-089R5.diff",
  "TEST_BP-085-089R4.ps1",
  "CHANGELOG_BP-085-089R4.md",
  "docs\BP-085-089R4_TESTING.md",
  "docs\BP-085-089R4_RESULT_ANALYSIS.md",
  "docs\BP-085-089R4_HOTFIX_REPORT.json",
  "docs\BP-085-089R4_BLOCK_LEDGER.json",
  "TEST_BP-085-089R3.ps1",
  "CHANGELOG_BP-085-089R3.md",
  "docs\BP-085-089R3_TESTING.md",
  "docs\BP-085-089R3_RESULT_ANALYSIS.md",
  "docs\BP-085-089R3_HOTFIX_REPORT.json",
  "docs\BP-085-089R3_BLOCK_LEDGER.json",
  "TEST_BP-085-089R2.ps1",
  "CHANGELOG_BP-085-089R2.md",
  "docs\BP-085-089R2_TESTING.md",
  "docs\BP-085-089R2_RESULT_ANALYSIS.md",
  "docs\BP-085-089R2_HOTFIX_REPORT.json",
  "docs\BP-085-089R2_BLOCK_LEDGER.json",
  "TEST_BP-085-089R1.ps1",
  "CHANGELOG_BP-085-089R1.md",
  "docs\BP-085-089R1_TESTING.md",
  "docs\BP-085-089R1_RESULT_ANALYSIS.md",
  "docs\BP-085-089R1_HOTFIX_REPORT.json",
  "docs\BP-085-089R1_BLOCK_LEDGER.json",
  "docs\BP-080-084R2_ACCEPTANCE_ANALYSIS.md",
  "docs\BP-085-089_BLOCK_LEDGER.json",
  "audit\game_profile_golden.json",
  "audit\mod_runtime_golden.json",
  "audit\artifact_compat_golden.json",
  "audit\savegame_v5_golden.json",
  "audit\savegame_fixed6_golden.json",
  "audit\stability_golden.json",
  "audit\compat_release_golden.json",
  "src\miniquake\game_profile.ml",
  "src\miniquake\mod_compat.ml",
  "src\miniquake\artifact_compat.ml",
  "src\miniquake\common.ml",
  "src\miniquake\format\bsp.ml",
  "src\miniquake\native.ml",
  "src\miniquake\quakec\edict.ml",
  "src\miniquake\cvar.ml",
  "src\miniquake\savegame.ml",
  "src\miniquake\savegame_runtime.ml",
  "src\miniquake\host.ml",
  "src\miniquake\server.ml",
  "src\miniquake\types.ml",
  "tests\compat_trace_tests.ml",
  "tools\check_world_physics_closure.py",
  "tools\check_protocol15_serverdata.py",
  "src\miniquake\stability_contract.ml",
  "src\miniquake\compatibility_matrix.ml",
  "tests\game_profile_compat_tests.ml",
  "tests\mod_runtime_compat_tests.ml",
  "tests\artifact_compat_tests.ml",
  "tests\quakec_edict_tests.ml",
  "tests\command_cvar_lifecycle_tests.ml",
  "tests\savegame_v5_parity_tests.ml",
  "tests\stability_contract_tests.ml",
  "tests\compatibility_release_closure_tests.ml",
  "tests\artifact_retail_evidence.ml",
  "tools\check_compat_085.py",
  "tools\check_compat_086.py",
  "tools\check_compat_087.py",
  "tools\check_savegame_v5.py",
  "tools\oracle\savegame_v5_oracle.c",
  "tools\oracle\savegame_fixed6_oracle.c",
  "native\miniquake_text.c",
  "native\miniquake_text.def",
  "native\README.md",
  "tools\check_compat_088.py",
  "tools\check_compat_089.py",
  "patches\BP-085.diff",
  "patches\BP-086.diff",
  "patches\BP-087.diff",
  "patches\BP-088.diff",
  "patches\BP-089.diff",
  "patches\BP-089R1.diff",
  "patches\BP-089R3.diff",
  "patches\BP-089R4.diff",
  "patches\BP-089R2.diff",
  # BP-090--BP-094 external-reference closure. Original binary/game data are not included.
  "TEST_BP-090-094R15.ps1",
  "CHANGELOG_BP-090-094R15.md",
  "docs\BP-090-094R15_TESTING.md",
  "docs\BP-090-094R15_RESULT_ANALYSIS.md",
  "docs\BP-090-094R15_HOTFIX_REPORT.json",
  "patches\BP-094R15.diff",
  "TEST_BP-090-094R14.ps1",
  "CHANGELOG_BP-090-094R14.md",
  "docs\BP-090-094R14_TESTING.md",
  "docs\BP-090-094R14_RESULT_ANALYSIS.md",
  "docs\BP-090-094R14_HOTFIX_REPORT.json",
  "patches\BP-094R14.diff",
  "TEST_BP-090-094R13.ps1",
  "CHANGELOG_BP-090-094R13.md",
  "docs\BP-090-094R13_TESTING.md",
  "docs\BP-090-094R13_RESULT_ANALYSIS.md",
  "docs\BP-090-094R13_HOTFIX_REPORT.json",
  "patches\BP-094R13.diff",
  "TEST_BP-090-094R12.ps1",
  "CHANGELOG_BP-090-094R12.md",
  "docs\BP-090-094R12_TESTING.md",
  "docs\BP-090-094R12_RESULT_ANALYSIS.md",
  "docs\BP-090-094R12_HOTFIX_REPORT.json",
  "patches\BP-094R12.diff",
  "patches\BP-094R11.diff",
  "TEST_BP-090-094R11.ps1",
  "CHANGELOG_BP-090-094R11.md",
  "docs\BP-090-094R11_TESTING.md",
  "docs\BP-090-094R11_RESULT_ANALYSIS.md",
  "docs\BP-090-094R11_HOTFIX_REPORT.json",
  "patches\BP-094R10.diff",
  "TEST_BP-090-094R8.ps1",
  "TEST_BP-090-094R9.ps1",
  "CHANGELOG_BP-090-094R8.md",
  "CHANGELOG_BP-090-094R9.md",
  "docs\BP-090-094R8_TESTING.md",
  "docs\BP-090-094R9_TESTING.md",
  "docs\BP-090-094R9_RESULT_ANALYSIS.md",
  "docs\BP-090-094R9_HOTFIX_REPORT.json",
  "docs\BP-090-094R8_RESULT_ANALYSIS.md",
  "docs\BP-090-094R8_HOTFIX_REPORT.json",
  "docs\BP-093_R7_VISUAL_DIAGNOSTIC_ANALYSIS.md",
  "docs\BP-093_R7_VISUAL_DIAGNOSTIC_ANALYSIS.json",
  "patches\BP-094R8.diff",
  "TEST_BP-090-094R7.ps1",
  "CHANGELOG_BP-090-094R7.md",
  "docs\BP-090-094R7_TESTING.md",
  "docs\BP-090-094R7_RESULT_ANALYSIS.md",
  "docs\BP-090-094R7_HOTFIX_REPORT.json",
  "patches\BP-094R7.diff",
  "TEST_BP-090-094R6.ps1",
  "CHANGELOG_BP-090-094R6.md",
  "docs\BP-090-094R6_TESTING.md",
  "docs\BP-090-094R6_RESULT_ANALYSIS.md",
  "docs\BP-090-094R6_HOTFIX_REPORT.json",
  "patches\BP-094R6.diff",
  "TEST_BP-090-094R5.ps1",
  "CHANGELOG_BP-090-094R5.md",
  "docs\BP-090-094R5_TESTING.md",
  "docs\BP-090-094R5_RESULT_ANALYSIS.md",
  "docs\BP-090-094R5_HOTFIX_REPORT.json",
  "patches\BP-094R5.diff",
  "TEST_BP-090-094R4.ps1",
  "CHANGELOG_BP-090-094R4.md",
  "docs\BP-090-094R4_TESTING.md",
  "docs\BP-090-094R4_RESULT_ANALYSIS.md",
  "docs\BP-090-094R4_HOTFIX_REPORT.json",
  "patches\BP-094R4.diff",
  "TEST_BP-090-094R3.ps1",
  "CHANGELOG_BP-090-094R3.md",
  "docs\BP-090-094R3_TESTING.md",
  "docs\BP-090-094R3_RESULT_ANALYSIS.md",
  "docs\BP-090-094R3_HOTFIX_REPORT.json",
  "patches\BP-094R3.diff",
  "TEST_BP-090-094R2.ps1",
  "CHANGELOG_BP-090-094R2.md",
  "docs\BP-090-094R2_TESTING.md",
  "docs\BP-090-094R2_RESULT_ANALYSIS.md",
  "docs\BP-090-094R2_HOTFIX_REPORT.json",
  "patches\BP-094R2.diff",
  "TEST_BP-090-094R1.ps1",
  "CHANGELOG_BP-090-094R1.md",
  "docs\BP-090-094R1_TESTING.md",
  "docs\BP-090-094R1_RESULT_ANALYSIS.md",
  "docs\BP-090-094R1_HOTFIX_REPORT.json",
  "patches\BP-094R1.diff",
  "TEST_BP-090-094.ps1",
  "CHANGELOG_BP-090-094.md",
  "docs\BP-090-094_TESTING.md",
  "docs\BP-085-089R8_ACCEPTANCE_ANALYSIS.md",
  "src\miniquake\external_reference_contract.ml",
  "tests\original_reference_provenance_tests.ml",
  "tests\original_server_interop_tests.ml",
  "tests\original_client_interop_tests.ml",
  "tests\original_visual_reference_tests.ml",
  "tests\external_compat_closure_tests.ml",
  "tools\prepare_original_reference.py",
  "tools\compare_original_reference.py",
  "tools\check_external_090.py",
  "tools\check_external_091.py",
  "tools\check_external_092.py",
  "tools\check_external_093.py",
  "tools\check_external_094.py",
  "audit\original_reference_golden.json",
  "audit\original_server_interop_golden.json",
  "audit\original_client_interop_golden.json",
  "audit\original_visual_reference_golden.json",
  "audit\external_compat_closure_golden.json",
  "patches\BP-090.diff",
  "patches\BP-091.diff",
  "patches\BP-092.diff",
  "patches\BP-093.diff",
  "patches\BP-094.diff",
  "SOURCE_MANIFEST.sha256",
  "BLOCK_LEDGER.json",
  "PORT_LEDGER.json",
  "PORT_STATUS.md",
  "README.md",
  "build.ps1",
  "COLLECT_RESULTS.ps1",
  "test.ps1",
  "TEST_BP-080-084.ps1",
  "TEST_BP-080-084R1.ps1",
  "TEST_BP-080-084R2.ps1",
  "CHANGELOG_BP-080.md",
  "CHANGELOG_BP-081.md",
  "CHANGELOG_BP-082.md",
  "CHANGELOG_BP-083.md",
  "CHANGELOG_BP-084.md",
  "CHANGELOG_BP-080-084.md",
  "CHANGELOG_BP-080-084R1.md",
  "CHANGELOG_BP-080-084R2.md",
  "docs\BP-080_CVAR_SOURCE_SURFACE_AUDIT.md",
  "docs\BP-081_CD_AUDIO_SOURCE_SURFACE_AUDIT.md",
  "docs\BP-082_SOURCE_FUNCTION_INVENTORY.md",
  "docs\BP-083_BLACK_PORT_CORPUS.md",
  "docs\BP-084_SOURCE_BLACK_PORT_CLOSURE.md",
  "docs\BP-080-084_TESTING.md",
  "docs\BP-080-084R1_TESTING.md",
  "docs\BP-080-084R1_RESULT_ANALYSIS.md",
  "docs\BP-080-084R1_HOTFIX_REPORT.json",
  "docs\BP-080-084R1_BLOCK_LEDGER.json",
  "docs\BP-080-084R2_TESTING.md",
  "docs\BP-080-084R2_RESULT_ANALYSIS.md",
  "docs\BP-080-084R2_HOTFIX_REPORT.json",
  "docs\BP-080-084R2_BLOCK_LEDGER.json",
  "docs\BP-075-079R3_ACCEPTANCE_ANALYSIS.md",
  "audit\cvar_source_surface_golden.json",
  "audit\cd_audio_source_surface_golden.json",
  "audit\source_function_inventory.json",
  "audit\black_port_corpus_golden.json",
  "audit\black_port_source_closure_golden.json",
  "tests\cvar_source_surface_tests.ml",
  "tests\cd_audio_source_surface_tests.ml",
  "tests\source_function_inventory_tests.ml",
  "tests\black_port_corpus_tests.ml",
  "tests\black_port_source_closure_tests.ml",
  "src\miniquake\source_profile_contract.ml",
  "src\miniquake\black_port_corpus.ml",
  "src\miniquake\black_port_source_contract.ml",
  "tools\generate_source_inventory.py",
  "tools\check_source_080.py",
  "tools\check_source_081.py",
  "tools\check_source_082.py",
  "tools\check_source_083.py",
  "tools\check_source_084.py",
  "patches\BP-080.diff",
  "patches\BP-081.diff",
  "patches\BP-082.diff",
  "patches\BP-083.diff",
  "patches\BP-084.diff",
  "patches\BP-084R1.diff",
  "patches\BP-084R2.diff",
  "TEST_BP-075-079.ps1",
  "TEST_BP-075-079R3.ps1",
  "CHANGELOG_BP-075-079R3.md",
  "docs\BP-075-079R3_TESTING.md",
  "docs\BP-075-079R3_RESULT_ANALYSIS.md",
  "docs\BP-075-079R3_HOTFIX_REPORT.json",
  "docs\BP-075-079R3_BLOCK_LEDGER.json",
  "patches\BP-079R3.diff",
  "TEST_BP-075-079R2.ps1",
  "CHANGELOG_BP-075-079R2.md",
  "docs\BP-075-079R2_TESTING.md",
  "docs\BP-075-079R2_RESULT_ANALYSIS.md",
  "docs\BP-075-079R2_HOTFIX_REPORT.json",
  "docs\BP-075-079R2_BLOCK_LEDGER.json",
  "patches\BP-079R2.diff",
  "TEST_BP-075-079R1.ps1",
  "CHANGELOG_BP-075-079R1.md",
  "docs\BP-075-079R1_TESTING.md",
  "docs\BP-075-079R1_RESULT_ANALYSIS.md",
  "docs\BP-075-079R1_HOTFIX_REPORT.json",
  "docs\BP-075-079R1_BLOCK_LEDGER.json",
  "patches\BP-079R1.diff",
  "CHANGELOG_BP-075.md",
  "CHANGELOG_BP-076.md",
  "CHANGELOG_BP-077.md",
  "CHANGELOG_BP-078.md",
  "CHANGELOG_BP-079.md",
  "CHANGELOG_BP-075-079.md",
  "docs\BP-075-079_TESTING.md",
  "docs\BP-070-074R6_ACCEPTANCE_ANALYSIS.md",
  "docs\BP-075_MATH_CHASE_AUDIT.md",
  "docs\BP-076_VIEW_PALETTE_AUDIT.md",
  "docs\BP-077_SCREEN_LOADING_AUDIT.md",
  "docs\BP-078_STATUSBAR_SCOREBOARD_AUDIT.md",
  "docs\BP-079_GAMEPLAY_PRESENTATION_AUDIT.md",
  "docs\BP-075-079_BLOCK_LEDGER.json",
  "patches\BP-075.diff",
  "patches\BP-076.diff",
  "patches\BP-077.diff",
  "patches\BP-078.diff",
  "patches\BP-079.diff",
  "tools\check_gameplay_075.py",
  "tools\check_gameplay_076.py",
  "tools\check_gameplay_077.py",
  "tools\check_gameplay_078.py",
  "tools\check_gameplay_079.py",
  "tools\oracle\gameplay_math_chase_oracle.c",
  "tools\oracle\gameplay_view_oracle.c",
  "tools\oracle\gameplay_screen_oracle.c",
  "tools\oracle\gameplay_statusbar_oracle.c",
  "tools\oracle\gameplay_presentation_oracle.c",
  "audit\gameplay_math_chase_golden.json",
  "audit\gameplay_view_golden.json",
  "audit\gameplay_screen_golden.json",
  "audit\gameplay_statusbar_golden.json",
  "audit\gameplay_presentation_golden.json",
  "tests\gameplay_math_chase_tests.ml",
  "tests\gameplay_view_tests.ml",
  "tests\gameplay_screen_tests.ml",
  "tests\gameplay_statusbar_tests.ml",
  "tests\gameplay_presentation_closure_tests.ml",
  "src\miniquake\host_command_numbers.ml",
  "src\miniquake\gameplay_presentation_contract.ml",
  "TEST_BP-070-074.ps1",
  "TEST_BP-070-074R6.ps1",
  "CHANGELOG_BP-070-074R6.md",
  "docs\BP-070-074R6_RESULT_ANALYSIS.md",
  "docs\BP-070-074R6_BLOCK_LEDGER.json",
  "docs\BP-070-074R6_TESTING.md",
  "docs\BP-070-074R6_HOTFIX_REPORT.json",
  "patches\BP-074R6.diff",
  "TEST_BP-070-074R5.ps1",
  "CHANGELOG_BP-070-074R5.md",
  "docs\BP-070-074R5_RESULT_ANALYSIS.md",
  "docs\BP-070-074R5_BLOCK_LEDGER.json",
  "docs\BP-070-074R5_TESTING.md",
  "docs\BP-070-074R5_HOTFIX_REPORT.json",
  "patches\BP-074R5.diff",
  "TEST_BP-070-074R4.ps1",
  "CHANGELOG_BP-070-074R4.md",
  "docs\BP-070-074R4_RESULT_ANALYSIS.md",
  "docs\BP-070-074R4_BLOCK_LEDGER.json",
  "docs\BP-070-074R4_TESTING.md",
  "docs\BP-070-074R4_HOTFIX_REPORT.json",
  "patches\BP-074R4.diff",
  "TEST_BP-070-074R3.ps1",
  "CHANGELOG_BP-070-074R3.md",
  "docs\BP-070-074R3_RESULT_ANALYSIS.md",
  "docs\BP-070-074R3_BLOCK_LEDGER.json",
  "docs\BP-070-074R3_TESTING.md",
  "docs\BP-070-074R3_HOTFIX_REPORT.json",
  "patches\BP-074R3.diff",
  "TEST_BP-070-074R2.ps1",
  "CHANGELOG_BP-070-074R2.md",
  "docs\BP-070-074R2_RESULT_ANALYSIS.md",
  "docs\BP-070-074R2_BLOCK_LEDGER.json",
  "docs\BP-070-074R2_TESTING.md",
  "docs\BP-070-074R2_HOTFIX_REPORT.json",
  "patches\BP-074R2.diff",
  "TEST_BP-070-074R1.ps1",
  "CHANGELOG_BP-070-074R1.md",
  "docs\BP-070-074_RESULT_ANALYSIS.md",
  "docs\BP-070-074R1_RESULT_ANALYSIS.md",
  "docs\BP-070-074R1_BLOCK_LEDGER.json",
  "docs\BP-070-074R1_TESTING.md",
  "docs\BP-070-074R1_HOTFIX_REPORT.json",
  "patches\BP-074R1.diff",
  "CHANGELOG_BP-070.md",
  "CHANGELOG_BP-071.md",
  "CHANGELOG_BP-072.md",
  "CHANGELOG_BP-073.md",
  "CHANGELOG_BP-074.md",
  "CHANGELOG_BP-070-074.md",
  "docs\BP-065-069R1_ACCEPTANCE_ANALYSIS.md",
  "docs\BP-070_COMMON_CRC_AUDIT.md",
  "docs\BP-071_FILESYSTEM_PACK_AUDIT.md",
  "docs\BP-072_WAD_GRAPHICS_AUDIT.md",
  "docs\BP-073_MODEL_ASSET_AUDIT.md",
  "docs\BP-074_CORE_ASSETS_MEMORY_AUDIT.md",
  "docs\BP-070-074_TESTING.md",
  "docs\BP-070-074_BLOCK_LEDGER.json",
  "patches\BP-070.diff",
  "patches\BP-071.diff",
  "patches\BP-072.diff",
  "patches\BP-073.diff",
  "patches\BP-074.diff",
  "tools\verify.py",
  "tools\check_core_070.py",
  "tools\check_asset_071.py",
  "tools\check_core_072.py",
  "tools\check_core_073.py",
  "tools\check_core_074.py",
  "tools\oracle\common_crc_oracle.c",
  "tools\oracle\filesystem_pack_oracle.c",
  "tools\oracle\wad_graphics_oracle.c",
  "tools\oracle\model_asset_oracle.c",
  "tools\oracle\core_assets_memory_oracle.c",
  "audit\common_crc_golden.json",
  "audit\filesystem_pack_golden.json",
  "audit\wad_graphics_golden.json",
  "audit\model_asset_golden.json",
  "audit\core_assets_memory_golden.json",
  "tests\common_asset_parity_tests.ml",
  "tests\filesystem_pack_parity_tests.ml",
  "tests\wad_graphics_parity_tests.ml",
  "tests\model_asset_parity_tests.ml",
  "tests\core_assets_memory_closure_tests.ml",
  "tests\core_asset_retail_evidence.ml",
  "src\miniquake\core_assets_memory_contract.ml",
  # Historical BP-012 source-contract evidence: keep these exact markers.
  "tests\protocol15_serverdata_tests.ml",
  "docs\BP-012_PROTOCOL15_SERVERDATA_AUDIT.md",
  "audit\protocol15_serverdata_golden.json",
  "TEST_BP-065-069R1.ps1",
  "docs\BP-065-069R1_BLOCK_LEDGER.json",
  "patches\BP-069R1.diff"
)
foreach ($Relative in $RootFiles) { Copy-SafeFile (Join-Path $Root $Relative) $Relative }

if ($IncludeAllCurrentDocs) {
  Get-ChildItem -LiteralPath (Join-Path $Root "docs") -File | ForEach-Object {
    Copy-SafeFile $_.FullName (Join-Path "docs" $_.Name)
  }
}

$BinaryNames = @(
  "MiniQuakeOriginalReferenceTests.exe",
  "MiniQuakeOriginalServerInteropTests.exe",
  "MiniQuakeOriginalClientInteropTests.exe",
  "MiniQuakeOriginalVisualReferenceTests.exe",
  "MiniQuakeExternalCompatibilityClosureTests.exe",
  "MiniQuake.exe",
  "MiniQuakeOPT001AContractTests.exe",
  "MiniQuakeOPT001BCorrectnessTests.exe",
  "MiniQuakeOPT001CAllocationTests.exe",
  "MiniQuakeProtocol15ServerDataTests.exe",
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
  "MiniQuakeArtifactRetailEvidence.exe",
  "MiniQuakeAudioRetailEvidence.exe",
  "MiniQuakeNetworkPlatformEvidence.exe",
  "miniquake_native.dll",
  "miniquake_text.dll"
)
$BinaryState = @()
foreach ($Name in $BinaryNames) {
  $Path = Join-Path $Build $Name
  $Entry = [ordered]@{
    name = $Name
    present = (Test-Path -LiteralPath $Path -PathType Leaf)
    sha256 = ""
    bytes = 0
  }
  if ($Entry.present) {
    $Entry.sha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash.ToLowerInvariant()
    $Entry.bytes = (Get-Item -LiteralPath $Path).Length
  }
  $BinaryState += $Entry
}

$Meta = [ordered]@{
  schema = "MiniQuakeResultCollection/1"
  package_id = $PackageId
  block_id = $BlockId
  delivery_revision = $DeliveryRevision
  delivery_parent = $DeliveryParent
  created_utc = (Get-Date).ToUniversalTime().ToString("o")
  machine = $env:COMPUTERNAME
  user = $env:USERNAME
  source_root = $Root
  binaries = $BinaryState
  skipped_build_artifacts = $SkippedBuildArtifacts
  original_reference_binary_in_result_archive = $false
  quake_game_data_in_result_archive = $false
  framebuffer_images_in_result_archive = $false
}
$Meta | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $Staging "collection.json") -Encoding UTF8

if (Test-Path -LiteralPath $Archive) { Remove-Item -Force -LiteralPath $Archive }
Compress-Archive -Path (Join-Path $Staging "*") -DestinationPath $Archive -CompressionLevel Optimal
Remove-Item -Recurse -Force -LiteralPath $Staging
$Hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $Archive).Hash.ToLowerInvariant()
Write-Host "MiniQuake $DeliveryRevision result archive"
Write-Host "  path=$Archive"
Write-Host "  sha256=$Hash"
Write-Host ("  skipped_unsafe_build_artifacts={0}" -f $SkippedBuildArtifacts.Count)
Write-Host "  Original GLQuake binary, Quake PAK/model/map/audio data, TGAs, synthetic asset workspaces and compiled binaries were not included."
