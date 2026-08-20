/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang parity and regression tests for tests/artifact_retail_evidence.ml.
*/
import miniquake.artifact_compat as artifacts
import miniquake.filesystem as qfs
import miniquake.demo as demo
import miniquake.demo_player as demoPlayer
import miniquake.host as host
import miniquake.savegame as savegame
import miniquake.savegame_runtime as saveRuntime
import miniquake.compat_trace as trace
import miniquake.compat_diagnostics as diagnostics
import miniquake.quakec.edict as qcedict
import miniquake.common as common
import miniquake.native as native

// Report the requested value and return the corresponding failure status.
function bp087Fail(message)
  print "error=" + message
  print "result=FAIL"
  return 1
end function

// Execute frames.
function bp087RunFrames(session, count)
  index = 0
  while index < count
    result = try(host.frame(session, 0.02))
    if result is error then return result end if
    index = index + 1
  end while
  return true
end function

// Release or remove state for the requested value.
function bp087Shutdown(session, label)
  result = try(host.shutdown(session))
  if result is error then return error(8790, label + " shutdown: " + result.message) end if
  if not result then return error(8791, label + " shutdown returned false") end if
  return true
end function

// Exercise the prepare loaded save test scenario and verify its expected result.
function bp087PrepareLoadedSave(session, saved)
  applied = try(savegame.apply(session.server, saved))
  if applied is error then return applied end if
  synchronizationResult = try(saveRuntime.synchronizeLoadedServer(session.server))
  if synchronizationResult is error then return synchronizationResult end if
  return true
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  if len(args) < 3 then
    print "usage: MiniQuakeArtifactRetailEvidence.exe BASE GAME MAP"
    return 2
  end if
  baseDirectory = args[0]
  gameDirectory = args[1]
  mapName = args[2]
  print "MiniQuake BP-087 retail artifact evidence"
  print "game=" + gameDirectory + " map=" + mapName
  print "save_float_format=4097:" + qcedict.fixedSixDecimals(4097.0) + " negative:" + qcedict.fixedSixDecimals(-4097.0)
  signedZeroBits = native.floatBits(common.cAtof("-0.000000")) & 0xffffffff
  print "save_float_parse=-0.000000:" + diagnostics.u32Hex(signedZeroBits)
  if signedZeroBits != 0x80000000 then return bp087Fail("C atof did not preserve negative zero") end if

  system = try(qfs.initialize(baseDirectory, gameDirectory))
  if system is error then return bp087Fail(system.message) end if
  for each demoName in artifacts.retailDemoNames()
    source = try(qfs.readFile(system, demoName))
    if source is error then qfs.release(system); return bp087Fail(demoName + ": " + source.message) end if
    recording = try(demo.parse(source))
    if recording is error then qfs.release(system); return bp087Fail(demoName + ": " + recording.message) end if
    report = demoPlayer.verify(recording)
    if not report.ok then qfs.release(system); return bp087Fail(demoName + ": protocol replay failed") end if
    summary = artifacts.demoSummary(recording, report, source)
    print "demo=" + demoName + " bytes=" + summary[7] + " crc=" + summary[8] + " messages=" + summary[1] + " events=" + summary[3] + " signon=" + summary[5] + " entities=" + summary[6]
  end for
  qfs.release(system)

  // Phase A: create the live source state and serialize the version-5 file.
  // Shut the complete host down before creating phase B.  NET/QSocket state is
  // process-global just like WinQuake's globals, so two simultaneous Host
  // sessions in one process are not a valid compatibility scenario.
  sessionA = host.create(["-basedir", baseDirectory, "-game", gameDirectory, "-headless", "-nosound", "+map", mapName])
  initializedA = try(host.initialize(sessionA))
  if initializedA is error then
    ignoredA = try(host.shutdown(sessionA))
    return bp087Fail("save source init: " + initializedA.message)
  end if
  ran = try(bp087RunFrames(sessionA, 64))
  if ran is error then
    ignoredA = try(host.shutdown(sessionA))
    return bp087Fail("save source frames: " + ran.message)
  end if
  saveA = try(savegame.serializeBytes(sessionA.server))
  if saveA is error then
    ignoredA = try(host.shutdown(sessionA))
    return bp087Fail("save serialize: " + saveA.message)
  end if
  parsedA = try(savegame.parseBytes(saveA))
  if parsedA is error then
    ignoredA = try(host.shutdown(sessionA))
    return bp087Fail("save parse: " + parsedA.message)
  end if
  sourceEdicts = trace.serverEdictsHash(sessionA)
  sourceGlobals = trace.globalsHash(sessionA)
  cleanA = try(bp087Shutdown(sessionA, "source"))
  if cleanA is error then return bp087Fail(cleanA.message) end if

  // Phase B: apply the source artifact to a freshly initialized server.  The
  // parsed version-5 save domain is the semantic comparison boundary.  Quake
  // archives only DEF_SAVEGLOBAL values and writes floats with six decimals;
  // complete live VM hashes include transient state which the format never
  // promises to preserve.
  sessionB = host.create(["-basedir", baseDirectory, "-game", gameDirectory, "-headless", "-nosound", "+map", mapName])
  initializedB = try(host.initialize(sessionB))
  if initializedB is error then
    ignoredB = try(host.shutdown(sessionB))
    return bp087Fail("save target init: " + initializedB.message)
  end if
  preparedB = try(bp087PrepareLoadedSave(sessionB, parsedA))
  if preparedB is error then
    ignoredB = try(host.shutdown(sessionB))
    return bp087Fail("save apply: " + preparedB.message)
  end if
  saveB = try(savegame.serializeBytes(sessionB.server))
  if saveB is error then
    ignoredB = try(host.shutdown(sessionB))
    return bp087Fail("save reserialize: " + saveB.message)
  end if
  parsedB = try(savegame.parseBytes(saveB))
  if parsedB is error then
    ignoredB = try(host.shutdown(sessionB))
    return bp087Fail("normalized save parse: " + parsedB.message)
  end if
  targetEdicts = trace.serverEdictsHash(sessionB)
  targetGlobals = trace.globalsHash(sessionB)
  semanticDifferenceAB = artifacts.saveSemanticDifference(parsedA, parsedB)
  byteDifferenceAB = artifacts.firstByteDifference(saveA, saveB)
  cleanB = try(bp087Shutdown(sessionB, "target"))
  if cleanB is error then return bp087Fail(cleanB.message) end if

  // Phase C: a second independent load must be byte-stable.  This catches a
  // parser/writer pair which keeps changing an already normalized save while
  // still allowing the first live-state serialization to cross Quake's
  // intentionally lossy six-decimal text boundary.
  sessionC = host.create(["-basedir", baseDirectory, "-game", gameDirectory, "-headless", "-nosound", "+map", mapName])
  initializedC = try(host.initialize(sessionC))
  if initializedC is error then
    ignoredC = try(host.shutdown(sessionC))
    return bp087Fail("save stability init: " + initializedC.message)
  end if
  preparedC = try(bp087PrepareLoadedSave(sessionC, parsedB))
  if preparedC is error then
    ignoredC = try(host.shutdown(sessionC))
    return bp087Fail("save stability apply: " + preparedC.message)
  end if
  saveC = try(savegame.serializeBytes(sessionC.server))
  if saveC is error then
    ignoredC = try(host.shutdown(sessionC))
    return bp087Fail("save stability serialize: " + saveC.message)
  end if
  parsedC = try(savegame.parseBytes(saveC))
  if parsedC is error then
    ignoredC = try(host.shutdown(sessionC))
    return bp087Fail("stable save parse: " + parsedC.message)
  end if
  semanticDifferenceBC = artifacts.saveSemanticDifference(parsedB, parsedC)
  byteDifferenceBC = artifacts.firstByteDifference(saveB, saveC)
  cleanC = try(bp087Shutdown(sessionC, "stability"))
  if cleanC is error then return bp087Fail(cleanC.message) end if

  exactFirstPass = artifacts.bytesEqual(saveA, saveB)
  semanticFirstPass = semanticDifferenceAB == ""
  stableExact = artifacts.bytesEqual(saveB, saveC)
  stableSemantic = semanticDifferenceBC == ""
  print "save=version5 source_bytes=" + len(saveA) + " source_crc=" + artifacts.bytesCrc(saveA) + " normalized_bytes=" + len(saveB) + " normalized_crc=" + artifacts.bytesCrc(saveB) + " first_pass_exact=" + exactFirstPass + " semantic=" + semanticFirstPass + " stable_exact=" + stableExact + " stable_semantic=" + stableSemantic
  print "save_first_diff=" + byteDifferenceAB[0] + " left=" + byteDifferenceAB[1] + " right=" + byteDifferenceAB[2] + " semantic_diff=" + semanticDifferenceAB
  print "save_stable_diff=" + byteDifferenceBC[0] + " left=" + byteDifferenceBC[1] + " right=" + byteDifferenceBC[2] + " semantic_diff=" + semanticDifferenceBC
  print "runtime_full_hashes source_edicts=" + sourceEdicts + " target_edicts=" + targetEdicts + " source_globals=" + sourceGlobals + " target_globals=" + targetGlobals
  if not exactFirstPass then return bp087Fail("save byte roundtrip mismatch at offset " + byteDifferenceAB[0]) end if
  if not semanticFirstPass then return bp087Fail("save semantic roundtrip mismatch: " + semanticDifferenceAB) end if
  if not stableExact then return bp087Fail("save normalized bytes are not stable at offset " + byteDifferenceBC[0]) end if
  if not stableSemantic then return bp087Fail("save normalized semantic state is not stable: " + semanticDifferenceBC) end if
  print "result=PASS"
  return 0
end function
