/* BP-082 inventory runtime entry. main(args) must remain in the global package. */
import miniquake.source_profile_contract as profile

bp082Failures = 0
bp082Checks = 0

function bp082Check(condition, label)
  global bp082Failures, bp082Checks
  bp082Checks = bp082Checks + 1
  if not condition then bp082Failures = bp082Failures + 1; print "FAIL: " + label end if
end function

function bp082Equal(actual, expected, label)
  bp082Check(actual == expected, label + ": expected " + expected + ", got " + actual)
end function

function bp082Contains(values, wanted)
  for each value in values
    if value == wanted then return true end if
  end for
  return false
end function

function main(args)
  global bp082Failures, bp082Checks
  adapters = profile.contextAdapterNames()
  equivalents = profile.technicalEquivalentNames()

  print "[1/20] source units"
  bp082Equal(profile.SOURCE_UNIT_COUNT, 53, "source units")

  print "[2/20] header units"
  bp082Equal(profile.HEADER_UNIT_COUNT, 10, "header units")

  print "[3/20] discovered definitions"
  bp082Equal(profile.DEFINITIONS_DISCOVERED, 1120, "discovered")

  print "[4/20] profile exclusions"
  bp082Equal(profile.PROFILE_EXCLUDED, 26, "excluded")

  print "[5/20] target definitions"
  bp082Equal(profile.TARGET_DEFINITIONS, 1094, "target")

  print "[6/20] exact-name functions"
  bp082Equal(profile.EXACT_NAME, 1081, "exact")

  print "[7/20] context adapters"
  bp082Equal(profile.CONTEXT_ADAPTER, 9, "adapters")

  print "[8/20] technical equivalents"
  bp082Equal(profile.TECHNICAL_EQUIVALENT, 4, "equivalents")

  print "[9/20] no missing definitions"
  bp082Equal(profile.MISSING, 0, "missing")

  print "[10/20] full accounting"
  bp082Equal(profile.accountedDefinitions(), profile.TARGET_DEFINITIONS, "accounting")

  print "[11/20] coverage"
  bp082Equal(profile.COVERAGE_PERCENT, 100, "coverage")

  print "[12/20] adapter array length"
  bp082Equal(len(adapters), 9, "adapter length")

  print "[13/20] cvar find adapter"
  bp082Check(bp082Contains(adapters, "Cvar_FindVar"), "Cvar_FindVar adapter")

  print "[14/20] cvar command adapter"
  bp082Check(bp082Contains(adapters, "Cvar_Command"), "Cvar_Command adapter")

  print "[15/20] cvar archive adapter"
  bp082Check(bp082Contains(adapters, "Cvar_WriteVariables"), "Cvar_WriteVariables adapter")

  print "[16/20] equivalent array length"
  bp082Equal(len(equivalents), 4, "equivalent length")

  print "[17/20] eject equivalent"
  bp082Check(bp082Contains(equivalents, "CDAudio_Eject"), "eject equivalent")

  print "[18/20] message equivalent"
  bp082Check(bp082Contains(equivalents, "CDAudio_MessageHandler"), "message equivalent")

  print "[19/20] inventory digest"
  bp082Equal(len(bytes(profile.INVENTORY_SHA256)), 64, "digest length")

  print "[20/20] profile validation"
  bp082Check(profile.validate(), "profile validation")

  if bp082Failures > 0 then
    print "MiniQuake BP-082 source function inventory tests failed: " + bp082Failures + "/" + bp082Checks
    return 1
  end if
  print "MiniQuake BP-082 source function inventory tests passed: 20"
  return 0
end function
