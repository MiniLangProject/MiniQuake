/* BP-084 closure runtime entry. main(args) must remain in the global package. */
import miniquake.black_port_source_contract as closure
import miniquake.source_profile_contract as profile
import miniquake.black_port_corpus as corpus

bp084Failures = 0
bp084Checks = 0

function bp084Check(condition, label)
  global bp084Failures, bp084Checks
  bp084Checks = bp084Checks + 1
  if not condition then bp084Failures = bp084Failures + 1; print "FAIL: " + label end if
end function

function bp084Equal(actual, expected, label)
  bp084Check(actual == expected, label + ": expected " + expected + ", got " + actual)
end function

function main(args)
  global bp084Failures, bp084Checks
  vector = closure.contractVector()

  print "[1/24] status"
  bp084Equal(closure.STATUS, "black_port_source_109_frozen_v1", "status")

  print "[2/24] fingerprint"
  bp084Equal(closure.FINGERPRINT, 0x309b0737, "fingerprint")

  print "[3/24] schema"
  bp084Equal(closure.SCHEMA_VERSION, 1, "schema")

  print "[4/24] source units"
  bp084Equal(closure.SOURCE_UNIT_COUNT, 53, "source units")

  print "[5/24] header units"
  bp084Equal(closure.HEADER_UNIT_COUNT, 10, "header units")

  print "[6/24] target functions"
  bp084Equal(closure.TARGET_FUNCTION_COUNT, 1094, "target functions")

  print "[7/24] exact names"
  bp084Equal(profile.EXACT_NAME, 1081, "exact names")

  print "[8/24] adapters"
  bp084Equal(profile.CONTEXT_ADAPTER, 9, "adapters")

  print "[9/24] equivalents"
  bp084Equal(profile.TECHNICAL_EQUIVALENT, 4, "equivalents")

  print "[10/24] unclassified"
  bp084Equal(closure.UNCLASSIFIED_FUNCTION_COUNT, 0, "unclassified")

  print "[11/24] profile excluded"
  bp084Equal(profile.PROFILE_EXCLUDED, 26, "profile excluded")

  print "[12/24] definitions discovered"
  bp084Equal(profile.DEFINITIONS_DISCOVERED, 1120, "discovered")

  print "[13/24] corpus scenarios"
  bp084Equal(closure.CORPUS_SCENARIO_COUNT, 4, "corpus scenarios")

  print "[14/24] corpus frames"
  bp084Equal(closure.CORPUS_FRAMES_PER_SCENARIO, 64, "corpus frames")

  print "[15/24] vector length"
  bp084Equal(len(vector), 10, "vector length")

  print "[16/24] vector schema"
  bp084Equal(vector[0], 1, "vector schema")

  print "[17/24] vector target"
  bp084Equal(vector[3], 1094, "vector target")

  print "[18/24] vector exact"
  bp084Equal(vector[4], 1081, "vector exact")

  print "[19/24] vector adapter"
  bp084Equal(vector[5], 9, "vector adapters")

  print "[20/24] vector equivalent"
  bp084Equal(vector[6], 4, "vector equivalents")

  print "[21/24] vector missing"
  bp084Equal(vector[7], 0, "vector missing")

  print "[22/24] source profile validation"
  bp084Check(profile.validate(), "profile validation")

  print "[23/24] corpus validation"
  bp084Check(corpus.validate(), "corpus validation")

  print "[24/24] closure validation"
  bp084Check(closure.validate(), "closure validation")

  if bp084Failures > 0 then
    print "MiniQuake BP-084 source black-port closure tests failed: " + bp084Failures + "/" + bp084Checks
    return 1
  end if
  print "MiniQuake BP-084 source black-port closure tests passed: 24"
  return 0
end function
