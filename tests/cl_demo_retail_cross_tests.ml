/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang parity and regression tests for tests/cl_demo_retail_cross_tests.ml.
*/
import miniquake.filesystem as qfs
import miniquake.demo as demo
import miniquake.demo_player as player

// Parse command-line arguments and run the selected operation.
function main(args)
  if len(args) != 3 then
    print "usage: ClDemoRetailCrossTests BASE GAME DEMO"
    return 2
  end if
  filesystem = qfs.initialize(args[0], args[1])
  source = try(qfs.readFile(filesystem, args[2]))
  if source is error then print "FAIL read: " + source.message; qfs.release(filesystem); return 1 end if
  recording = try(demo.CL_PlayDemo_f(source))
  if recording is error then print "FAIL parse: " + recording.message; qfs.release(filesystem); return 1 end if
  roundtrip = demo.serialize(recording)
  if len(roundtrip) != len(source) then
    print "FAIL roundtrip length: " + len(source) + " -> " + len(roundtrip)
    qfs.release(filesystem)
    return 1
  end if
  index = 0
  while index < len(source)
    if source[index] != roundtrip[index] then
      print "FAIL byte " + index + ": " + source[index] + " -> " + roundtrip[index]
      qfs.release(filesystem)
      return 1
    end if
    index = index + 1
  end while
  report = player.verify(recording)
  if not report.ok then
    player.printReport(report)
    qfs.release(filesystem)
    return 1
  end if
  print "PASS " + args[1] + "/" + args[2] + ": " + len(recording.messages) + " messages, " + len(source) + " exact bytes"
  qfs.release(filesystem)
  return 0
end function
