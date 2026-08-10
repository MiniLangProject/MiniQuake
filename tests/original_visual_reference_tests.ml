import miniquake.external_reference_contract as reference

passed = 0
failed = 0

function bp093Check(condition, label)
  global passed, failed
  if condition then passed = passed + 1; print "[" + passed + "/20] " + label; return true end if
  failed = failed + 1
  print "FAIL: " + label
  return false
end function

function main(args)
  global passed, failed
  scenarios = reference.visualScenarios()
  bp093Check(len(scenarios) == 3, "scenario count")
  bp093Check(scenarios[0][0] == "demo1", "demo1 scenario")
  bp093Check(scenarios[1][0] == "demo2", "demo2 scenario")
  bp093Check(scenarios[2][0] == "demo3", "demo3 scenario")
  bp093Check(scenarios[0][1] == 256, "demo1 frame")
  bp093Check(scenarios[1][1] == 256, "demo2 frame")
  bp093Check(scenarios[2][1] == 256, "demo3 frame")
  bp093Check(reference.visualThreshold() == 0.95, "SSIM threshold")
  bp093Check(reference.ORIGINAL_CAPTURE_SEARCH_RADIUS == 2, "search radius")
  bp093Check(reference.ORIGINAL_CAPTURE_WIDTH == 640, "width")
  bp093Check(reference.ORIGINAL_CAPTURE_HEIGHT == 480, "height")
  bp093Check(reference.ORIGINAL_CAPTURE_MIN_SSIM > 0.94, "threshold lower bound")
  bp093Check(reference.ORIGINAL_CAPTURE_MIN_SSIM <= 1.0, "threshold upper bound")
  bp093Check(reference.ORIGINAL_REFERENCE_STATUS == "original_reference_109_candidate_v1", "reference status")
  bp093Check(reference.ORIGINAL_GLQUAKE_SHA256 != "", "reference digest")
  bp093Check(len(reference.requiredExternalGates()) == 2, "external gate count")
  bp093Check(reference.requiredExternalGates()[1] == "external_glquake_visual_reference", "visual gate")
  bp093Check(reference.COMPAT_FINAL_STATUS == "compat_109_final_candidate_v1", "final candidate")
  bp093Check(reference.COMPAT_FINAL_FINGERPRINT == 0xe04a7727, "final fingerprint")
  bp093Check(reference.validateReferenceContract(), "reference valid")
  if failed > 0 then print "MiniQuake BP-093 original visual reference tests failed: " + failed + "/20"; return 1 end if
  print "MiniQuake BP-093 original visual reference tests passed: 20"
  return 0
end function
