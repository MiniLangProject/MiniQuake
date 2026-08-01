/* BP-083 corpus runtime entry. main(args) must remain in the global package. */
import miniquake.black_port_corpus as corpus

bp083Failures = 0
bp083Checks = 0

function bp083Check(condition, label)
  global bp083Failures, bp083Checks
  bp083Checks = bp083Checks + 1
  if not condition then bp083Failures = bp083Failures + 1; print "FAIL: " + label end if
end function

function bp083Equal(actual, expected, label)
  bp083Check(actual == expected, label + ": expected " + expected + ", got " + actual)
end function

function main(args)
  global bp083Failures, bp083Checks
  scenarios = corpus.scenarios()

  print "[1/18] schema"
  bp083Equal(corpus.SCHEMA_VERSION, 1, "schema")

  print "[2/18] frame count"
  bp083Equal(corpus.FRAMES_PER_SCENARIO, 64, "frames")

  print "[3/18] scenario count"
  bp083Equal(corpus.SCENARIO_COUNT, 4, "count")

  print "[4/18] actual count"
  bp083Equal(len(scenarios), 4, "actual count")

  print "[5/18] start name"
  bp083Equal(scenarios[0][0], "start-064", "start name")

  print "[6/18] start map"
  bp083Equal(scenarios[0][1], "start", "start map")

  print "[7/18] start frames"
  bp083Equal(scenarios[0][2], 64, "start frames")

  print "[8/18] e1m1 name"
  bp083Equal(scenarios[1][0], "e1m1-064", "e1m1 name")

  print "[9/18] e1m1 map"
  bp083Equal(scenarios[1][1], "e1m1", "e1m1 map")

  print "[10/18] e1m2 name"
  bp083Equal(scenarios[2][0], "e1m2-064", "e1m2 name")

  print "[11/18] e1m2 map"
  bp083Equal(scenarios[2][1], "e1m2", "e1m2 map")

  print "[12/18] e1m3 name"
  bp083Equal(scenarios[3][0], "e1m3-064", "e1m3 name")

  print "[13/18] e1m3 map"
  bp083Equal(scenarios[3][1], "e1m3", "e1m3 map")

  print "[14/18] scenarioAt"
  bp083Equal(corpus.scenarioAt(2)[1], "e1m2", "scenarioAt")

  print "[15/18] negative index"
  result = try(corpus.scenarioAt(-1))
  bp083Check(result is error, "negative index rejected")

  print "[16/18] upper index"
  result = try(corpus.scenarioAt(4))
  bp083Check(result is error, "upper index rejected")

  print "[17/18] unique names"
  bp083Check(scenarios[0][0] != scenarios[1][0] and scenarios[1][0] != scenarios[2][0] and scenarios[2][0] != scenarios[3][0], "unique names")

  print "[18/18] corpus validation"
  bp083Check(corpus.validate(), "corpus validation")

  if bp083Failures > 0 then
    print "MiniQuake BP-083 black-port corpus tests failed: " + bp083Failures + "/" + bp083Checks
    return 1
  end if
  print "MiniQuake BP-083 black-port corpus tests passed: 18"
  return 0
end function
