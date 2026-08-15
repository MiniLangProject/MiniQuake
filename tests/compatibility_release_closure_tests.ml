/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang parity and regression tests for tests/compatibility_release_closure_tests.ml.
*/
import miniquake.compatibility_matrix as matrix
import miniquake.game_profile as profile
import miniquake.mod_compat as modcompat
import miniquake.artifact_compat as artifacts
import miniquake.stability_contract as stability

passed = 0
failed = 0

// Assert that the condition holds and identify a failing test.
function bp089Check(condition, label)
  global passed, failed
  if condition then passed = passed + 1; return true end if
  print "FAIL: " + label
  failed = failed + 1
  return false
end function

// Assert exact equality and report both values on failure.
function bp089Equal(actual, expected, label)
  return bp089Check(actual == expected, label + ": expected " + expected + ", got " + actual)
end function

// Exercise the contains test scenario and verify its expected result.
function bp089Contains(values, wanted)
  for each value in values
    if value == wanted then return true end if
  end for
  return false
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  global passed, failed
  print "[1/24] status"
  bp089Equal(matrix.STATUS, "compat_109_release_candidate_v1", "status")
  print "[2/24] fingerprint"
  bp089Equal(matrix.FINGERPRINT, 0x29b72a98, "fingerprint")
  print "[3/24] contract count"
  bp089Equal(matrix.CONTRACT_COUNT, 18, "contract count")
  print "[4/24] source functions"
  bp089Equal(matrix.SOURCE_FUNCTION_COUNT, 1094, "source functions")
  print "[5/24] black-port maps"
  bp089Equal(matrix.BLACK_PORT_MAP_COUNT, 4, "map count")
  print "[6/24] retail demos"
  bp089Equal(matrix.RETAIL_DEMO_COUNT, 3, "demo count")
  print "[7/24] soak modes"
  bp089Equal(matrix.SOAK_MODE_COUNT, 2, "soak count")
  contracts = matrix.acceptedContracts()
  print "[8/24] accepted length"
  bp089Equal(len(contracts), 18, "accepted length")
  print "[9/24] protocol contract"
  bp089Check(bp089Contains(contracts, "protocol15_frozen_v1"), "protocol")
  print "[10/24] QuakeC contract"
  bp089Check(bp089Contains(contracts, "quakec_109_frozen_v1"), "quakec")
  print "[11/24] physics contract"
  bp089Check(bp089Contains(contracts, "world_physics_109_frozen_v1"), "physics")
  print "[12/24] renderer contract"
  bp089Check(bp089Contains(contracts, "world_render_109_frozen_v1"), "renderer")
  print "[13/24] audio contract"
  bp089Check(bp089Contains(contracts, "audio_109_frozen_v1"), "audio")
  print "[14/24] network contract"
  bp089Check(bp089Contains(contracts, "network_platform_109_frozen_v1"), "network")
  print "[15/24] source contract"
  bp089Check(bp089Contains(contracts, "black_port_source_109_frozen_v1"), "source")
  print "[16/24] game profile contract"
  bp089Check(bp089Contains(contracts, profile.STATUS), "game profile")
  print "[17/24] mod runtime contract"
  bp089Check(bp089Contains(contracts, modcompat.STATUS), "mod runtime")
  print "[18/24] artifact contract"
  bp089Check(bp089Contains(contracts, artifacts.STATUS), "artifact")
  print "[19/24] stability contract"
  bp089Check(bp089Contains(contracts, stability.STATUS), "stability")
  pending = matrix.pendingExternalGates()
  print "[20/24] pending count"
  bp089Equal(len(pending), 2, "pending count")
  print "[21/24] binary interop pending"
  bp089Check(bp089Contains(pending, "original_binary_interop"), "binary pending")
  print "[22/24] visual reference pending"
  bp089Check(bp089Contains(pending, "external_glquake_visual_reference"), "visual pending")
  print "[23/24] matrix validation"
  bp089Check(matrix.validate(), "matrix validate")
  print "[24/24] contract text"
  bp089Check(len(bytes(matrix.CONTRACT_TEXT)) > 64, "contract text")

  if failed > 0 then print "MiniQuake BP-089 compatibility release closure tests failed: " + failed + "/24"; return 1 end if
  print "MiniQuake BP-089 compatibility release closure tests passed: 24"
  return 0
end function
