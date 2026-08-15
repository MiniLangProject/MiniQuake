/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang parity and regression tests for tests/external_compat_closure_tests.ml.
*/
import miniquake.external_reference_contract as reference
import miniquake.build_info as buildInfo
import miniquake.compatibility_matrix as matrix

passed = 0
failed = 0

// Assert that the condition holds and identify a failing test.
function bp094Check(condition, label)
  global passed, failed
  if condition then passed = passed + 1; print "[" + passed + "/24] " + label; return true end if
  failed = failed + 1
  print "FAIL: " + label
  return false
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  global passed, failed
  bp094Check(buildInfo.PACKAGE_ID == "BP-094", "package identity")
  bp094Check(buildInfo.PARENT_PACKAGE_ID == "BP-093", "parent identity")
  bp094Check(buildInfo.BLOCK_ID == "BP-090-094", "block identity")
  bp094Check(buildInfo.BLOCK_PARENT_PACKAGE_ID == "BP-085-089R8", "block parent")
  bp094Check(buildInfo.COMPAT_RELEASE_STATUS == "compat_109_release_candidate_v1", "inherited release candidate")
  bp094Check(buildInfo.COMPAT_RELEASE_FINGERPRINT == 0x29b72a98, "inherited release fingerprint")
  bp094Check(buildInfo.ORIGINAL_REFERENCE_STATUS == reference.ORIGINAL_REFERENCE_STATUS, "reference status")
  bp094Check(buildInfo.ORIGINAL_REFERENCE_FINGERPRINT == reference.ORIGINAL_REFERENCE_FINGERPRINT, "reference fingerprint")
  bp094Check(buildInfo.COMPAT_FINAL_STATUS == reference.COMPAT_FINAL_STATUS, "final status")
  bp094Check(buildInfo.COMPAT_FINAL_FINGERPRINT == reference.COMPAT_FINAL_FINGERPRINT, "final fingerprint")
  bp094Check(reference.ORIGINAL_CONTROL_PROTOCOL == 3, "control protocol")
  bp094Check(reference.ORIGINAL_GAME_PROTOCOL == 15, "game protocol")
  bp094Check(reference.ORIGINAL_CAPTURE_MIN_SSIM == 0.95, "visual threshold")
  bp094Check(len(reference.visualScenarios()) == 3, "visual scenario count")
  bp094Check(len(reference.requiredExternalGates()) == 2, "external gate count")
  bp094Check(reference.requiredExternalGates()[0] == "original_binary_interop", "interop gate")
  bp094Check(reference.requiredExternalGates()[1] == "external_glquake_visual_reference", "visual gate")
  bp094Check(matrix.STATUS == "compat_109_release_candidate_v1", "matrix status")
  bp094Check(matrix.FINGERPRINT == 0x29b72a98, "matrix fingerprint")
  bp094Check(matrix.validate(), "matrix validation")
  bp094Check(reference.originalServerInteropComplete(true, true, 4, 2, 2), "client-to-original contract")
  bp094Check(reference.originalClientInteropComplete(1, true, 3), "original-to-server contract")
  bp094Check(reference.validateReferenceContract(), "reference validation")
  bp094Check(len(bytes(buildInfo.PACKAGE_PURPOSE)) > 64, "package purpose")
  if failed > 0 then print "MiniQuake BP-094 external compatibility closure tests failed: " + failed + "/24"; return 1 end if
  print "MiniQuake BP-094 external compatibility closure tests passed: 24"
  return 0
end function
