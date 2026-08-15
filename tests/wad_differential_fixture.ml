/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang parity and regression tests for tests/wad_differential_fixture.ml.
*/
import miniquake.wad as wadPort

// Exercise cleanup event as part of this deterministic regression fixture.
function cleanupEvent()
  cleaned = wadPort.W_CleanupName(bytes("MiXeD_NAME_123456789"))
  print "{\"function\":\"W_CleanupName\",\"case\":\"mixed\",\"values\":[" +
    cleaned[0] + "," + cleaned[1] + "," + cleaned[2] + "," + cleaned[3] + "," +
    cleaned[4] + "," + cleaned[5] + "," + cleaned[6] + "," + cleaned[7] + "," +
    cleaned[8] + "," + cleaned[9] + "," + cleaned[10] + "," + cleaned[11] + "," +
    cleaned[12] + "," + cleaned[13] + "," + cleaned[14] + "," + cleaned[15] + "]}"
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  cleanupEvent()
  archive = wadPort.W_LoadWadFile(args[0])
  print "{\"function\":\"W_LoadWadFile\",\"case\":\"fixture\",\"count\":" +
    archive.numLumps + ",\"first\":\"" + archive.lumps[0].name +
    "\",\"second\":\"" + archive.lumps[1].name + "\"}"

  info = wadPort.W_GetLumpinfo(archive, "FIRST")
  print "{\"function\":\"W_GetLumpinfo\",\"case\":\"first\",\"filepos\":" +
    info.filePosition + ",\"disksize\":" + info.diskSize + ",\"size\":" +
    info.size + ",\"type\":" + info.type + ",\"name\":\"" + info.name + "\"}"

  first = wadPort.W_GetLumpName(archive, "FiRsT")
  print "{\"function\":\"W_GetLumpName\",\"case\":\"first\",\"values\":[" +
    first[0] + "," + first[1] + "," + first[2] + "," + first[3] + "]}"

  second = wadPort.W_GetLumpNum(archive, 1)
  print "{\"function\":\"W_GetLumpNum\",\"case\":\"picture\",\"values\":[" +
    second[0] + "," + second[1] + "," + second[2] + "," + second[3] + "," +
    second[4] + "," + second[5] + "," + second[6] + "," + second[7] + "]}"

  picture = bytes(8)
  picture[0] = 64
  picture[4] = 32
  dimensions = wadPort.SwapPic(picture, 0)
  print "{\"function\":\"SwapPic\",\"case\":\"header\",\"width\":" +
    dimensions[0] + ",\"height\":" + dimensions[1] + "}"
  return 0
end function
