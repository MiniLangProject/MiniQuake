import miniquake.external_reference_contract as reference
import miniquake.build_info as buildInfo

passed = 0
failed = 0

function bp090Check(condition, label)
  global passed, failed
  if condition then passed = passed + 1; print "[" + passed + "/20] " + label; return true end if
  failed = failed + 1
  print "FAIL: " + label
  return false
end function

function main(args)
  global passed, failed
  values = reference.referenceValues()
  bp090Check(reference.ORIGINAL_GLQUAKE_SHA256 == "04862c835c399bc9184f62101ae0390c2a758c21656ec06dcc0384e0f373d588", "reference SHA-256")
  bp090Check(reference.ORIGINAL_GLQUAKE_BYTES == 435712, "reference byte count")
  bp090Check(reference.ORIGINAL_GLQUAKE_PE_MACHINE == 0x014c, "reference PE machine")
  bp090Check(reference.ORIGINAL_CONTROL_PROTOCOL == 3, "control protocol")
  bp090Check(reference.ORIGINAL_GAME_PROTOCOL == 15, "game protocol")
  bp090Check(reference.ORIGINAL_CAPTURE_WIDTH == 640, "capture width")
  bp090Check(reference.ORIGINAL_CAPTURE_HEIGHT == 480, "capture height")
  bp090Check(reference.ORIGINAL_CAPTURE_MIN_SSIM == 0.95, "visual threshold")
  bp090Check(reference.ORIGINAL_CAPTURE_SEARCH_RADIUS == 2, "temporal radius")
  bp090Check(reference.ORIGINAL_INTEROP_POST_FRAMES == 32, "post-signon frames")
  bp090Check(reference.ORIGINAL_INTEROP_MAX_FRAMES == 10000, "interop frame budget")
  bp090Check(reference.ORIGINAL_REFERENCE_STATUS == "original_reference_109_candidate_v1", "reference status")
  bp090Check(reference.ORIGINAL_REFERENCE_FINGERPRINT == 0xdc355175, "reference fingerprint")
  bp090Check(reference.COMPAT_FINAL_STATUS == "compat_109_final_candidate_v1", "final status")
  bp090Check(reference.COMPAT_FINAL_FINGERPRINT == 0xe04a7727, "final fingerprint")
  bp090Check(len(values) == 10, "reference value count")
  bp090Check(reference.referenceContractHasRequiredFields(), "reference contract fields")
  bp090Check(reference.finalContractHasRequiredFields(), "final contract fields")
  bp090Check(buildInfo.ORIGINAL_REFERENCE_STATUS == reference.ORIGINAL_REFERENCE_STATUS, "build reference status")
  bp090Check(reference.validateReferenceContract(), "complete reference contract")
  if failed > 0 then print "MiniQuake BP-090 original reference tests failed: " + failed + "/20"; return 1 end if
  print "MiniQuake BP-090 original reference tests passed: 20"
  return 0
end function
