import miniquake.types as t
import miniquake.common as common
import miniquake.message as msg
import miniquake.sizebuf as sz
import miniquake.filesystem as fsys
import miniquake.byteio as bio
import std.fs as fs

function boolText(value)
  if value then return "true" end if
  return "false"
end function

function byteFour(data)
  values = bytes(4)
  index = 0
  while index < 4
    if index < len(data) then values[index] = data[index] end if
    index = index + 1
  end while
  return "[" + values[0] + "," + values[1] + "," + values[2] + "," + values[3] + "]"
end function

function writeEvent(name, callbackValue)
  buffer = sz.alloc(512)
  callbackValue(buffer)
  print "{\"function\":\"" + name + "\",\"case\":\"encode\",\"size\":" + buffer.curSize + ",\"bytes\":" + byteFour(sz.dataSlice(buffer)) + "}"
end function

function writeCharEvent(buffer)
  msg.MSG_WriteChar(buffer, -2)
end function

function writeByteEvent(buffer)
  msg.MSG_WriteByte(buffer, 254)
end function

function writeShortEvent(buffer)
  msg.MSG_WriteShort(buffer, -1234)
end function

function writeLongEvent(buffer)
  msg.MSG_WriteLong(buffer, 305419896)
end function

function writeFloatEvent(buffer)
  msg.MSG_WriteFloat(buffer, 12.5)
end function

function writeStringEvent(buffer)
  msg.MSG_WriteString(buffer, "quake")
end function

function writeCoordEvent(buffer)
  msg.MSG_WriteCoord(buffer, -12.25)
end function

function writeAngleEvent(buffer)
  msg.MSG_WriteAngle(buffer, 90.75)
end function

function inline basePath()
  return "build/common_differential/mlfs"
end function

function fixtureGamePath()
  return fsys.join(basePath(), "id1")
end function

function looseSystem()
  target = fsys.join(fixtureGamePath(), "test.bin")
  fsys.COM_CreatePath(target)
  fs.writeAllBytes(target, bytes([1, 2, 3, 4]))
  system = fsys.create(basePath(), "id1")
  fsys.addDirectory(system, fixtureGamePath())
  system.staticRegistered = true
  return system
end function

function packImage()
  data = bytes(80)
  data[0] = 80
  data[1] = 65
  data[2] = 67
  data[3] = 75
  bio.putI32(data, 4, 16)
  bio.putI32(data, 8, 64)
  data[12] = 9
  data[13] = 8
  data[14] = 7
  data[15] = 6
  name = bytes("inside.bin")
  index = 0
  while index < len(name)
    data[16 + index] = name[index]
    index = index + 1
  end while
  bio.putI32(data, 72, 12)
  bio.putI32(data, 76, 4)
  return data
end function

function main(args)
  head = t.Link(void, void)
  common.ClearLink(head)
  print "{\"function\":\"ClearLink\",\"case\":\"self\",\"self\":" + boolText(head.next == head and head.previous == head) + "}"

  head = t.Link(void, void)
  first = t.Link(void, void)
  common.ClearLink(head)
  common.ClearLink(first)
  common.InsertLinkBefore(first, head)
  common.RemoveLink(first)
  print "{\"function\":\"RemoveLink\",\"case\":\"unlink\",\"empty\":" + boolText(head.next == head and head.previous == head) + "}"

  head = t.Link(void, void)
  first = t.Link(void, void)
  common.ClearLink(head)
  common.ClearLink(first)
  common.InsertLinkBefore(first, head)
  print "{\"function\":\"InsertLinkBefore\",\"case\":\"order\",\"ok\":" + boolText(head.next == first and head.previous == first) + "}"

  head = t.Link(void, void)
  first = t.Link(void, void)
  second = t.Link(void, void)
  common.ClearLink(head)
  common.ClearLink(first)
  common.ClearLink(second)
  common.InsertLinkAfter(first, head)
  common.InsertLinkAfter(second, head)
  print "{\"function\":\"InsertLinkAfter\",\"case\":\"order\",\"second_first\":" + boolText(head.next == second and second.next == first) + "}"

  filled = bytes(8)
  common.Q_memset(filled, 90, 8)
  fillSum = 0
  for each value in filled
    fillSum = fillSum + value
  end for
  print "{\"function\":\"Q_memset\",\"case\":\"fill\",\"sum\":" + fillSum + "}"

  source = bytes([1,2,3,4,5,6,7,8])
  copied = bytes(8)
  common.Q_memcpy(copied, source, 8)
  print "{\"function\":\"Q_memcpy\",\"case\":\"copy\",\"equal\":" + boolText(common.Q_memcmp(source, copied, 8) == 0) + "}"
  print "{\"function\":\"Q_memcmp\",\"case\":\"equal_mismatch\",\"equal\":" + common.Q_memcmp(source, source, 2) + ",\"different\":" + common.Q_memcmp(bytes([1,2]), bytes([1,3]), 2) + "}"

  copiedText = common.Q_strcpy("quake")
  print "{\"function\":\"Q_strcpy\",\"case\":\"copy\",\"text\":\"" + copiedText + "\"}"
  bounded = common.Q_strncpy("abcdef", 3)
  boundedBytes = bytes(bounded)
  print "{\"function\":\"Q_strncpy\",\"case\":\"bounded\",\"bytes\":[" + boundedBytes[0] + "," + boundedBytes[1] + "," + boundedBytes[2] + "]}"
  print "{\"function\":\"Q_strlen\",\"case\":\"length\",\"value\":" + common.Q_strlen("quake") + "}"
  slashText = "a/b/c"
  slashIndex = common.Q_strrchr(slashText, 47)
  print "{\"function\":\"Q_strrchr\",\"case\":\"last\",\"suffix\":\"" + common.substring(slashText, slashIndex, common.Q_strlen(slashText) - slashIndex) + "\"}"
  print "{\"function\":\"Q_strcat\",\"case\":\"append\",\"text\":\"" + common.Q_strcat("mini", "quake") + "\"}"
  print "{\"function\":\"Q_strcmp\",\"case\":\"equal_mismatch\",\"equal\":" + common.Q_strcmp("abc","abc") + ",\"different\":" + common.Q_strcmp("abc","abd") + "}"
  print "{\"function\":\"Q_strncmp\",\"case\":\"prefix\",\"two\":" + common.Q_strncmp("abc","abd",2) + ",\"three\":" + common.Q_strncmp("abc","abd",3) + "}"
  print "{\"function\":\"Q_strncasecmp\",\"case\":\"fold\",\"equal\":" + common.Q_strncasecmp("AbC","aBc",3) + ",\"different\":" + common.Q_strncasecmp("AbC","aBd",3) + "}"
  print "{\"function\":\"Q_strcasecmp\",\"case\":\"fold\",\"equal\":" + common.Q_strcasecmp("QuAkE","qUaKe") + ",\"different\":" + common.Q_strcasecmp("a","b") + "}"
  print "{\"function\":\"Q_atoi\",\"case\":\"forms\",\"decimal\":" + common.Q_atoi("-42x") + ",\"hex\":" + common.Q_atoi("0x2a") + ",\"character\":" + common.Q_atoi("'Z") + "}"
  print "{\"function\":\"Q_atof\",\"case\":\"forms\",\"decimal\":" + common.Q_atof("-12.5x") + ",\"hex\":" + common.Q_atof("0x2a") + ",\"character\":" + common.Q_atof("'Z") + "}"

  print "{\"function\":\"ShortSwap\",\"case\":\"swap\",\"value\":" + common.ShortSwap(4660) + "}"
  print "{\"function\":\"ShortNoSwap\",\"case\":\"identity\",\"value\":" + common.ShortNoSwap(-1234) + "}"
  print "{\"function\":\"LongSwap\",\"case\":\"swap\",\"value\":" + common.LongSwap(305419896) + "}"
  print "{\"function\":\"LongNoSwap\",\"case\":\"identity\",\"value\":" + common.LongNoSwap(-1234567) + "}"
  swappedFloat = common.FloatSwap(12.5)
  floatData = bytes(4)
  bio.putF32(floatData, 0, swappedFloat)
  print "{\"function\":\"FloatSwap\",\"case\":\"swap\",\"bits\":" + bio.i32(floatData, 0) + "}"
  print "{\"function\":\"FloatNoSwap\",\"case\":\"identity\",\"value\":" + common.FloatNoSwap(-12.5) + "}"

  writeEvent("MSG_WriteChar", writeCharEvent)
  writeEvent("MSG_WriteByte", writeByteEvent)
  writeEvent("MSG_WriteShort", writeShortEvent)
  writeEvent("MSG_WriteLong", writeLongEvent)
  writeEvent("MSG_WriteFloat", writeFloatEvent)
  writeEvent("MSG_WriteString", writeStringEvent)
  writeEvent("MSG_WriteCoord", writeCoordEvent)
  writeEvent("MSG_WriteAngle", writeAngleEvent)

  beginBuffer = sz.alloc(8)
  msg.MSG_WriteLong(beginBuffer, 1)
  beginReader = msg.MSG_BeginReading(beginBuffer)
  print "{\"function\":\"MSG_BeginReading\",\"case\":\"reset\",\"count\":" + beginReader.readCount + ",\"bad\":" + boolText(beginReader.badRead) + "}"

  reader = msg.beginReadingBytes(bytes([254]))
  readValue = msg.MSG_ReadChar(reader)
  print "{\"function\":\"MSG_ReadChar\",\"case\":\"decode\",\"value\":" + readValue + ",\"count\":" + reader.readCount + "}"
  reader = msg.beginReadingBytes(bytes([254]))
  readValue = msg.MSG_ReadByte(reader)
  print "{\"function\":\"MSG_ReadByte\",\"case\":\"decode\",\"value\":" + readValue + ",\"count\":" + reader.readCount + "}"
  reader = msg.beginReadingBytes(bytes([46,251]))
  readValue = msg.MSG_ReadShort(reader)
  print "{\"function\":\"MSG_ReadShort\",\"case\":\"decode\",\"value\":" + readValue + ",\"count\":" + reader.readCount + "}"
  reader = msg.beginReadingBytes(bytes([120,86,52,18]))
  readValue = msg.MSG_ReadLong(reader)
  print "{\"function\":\"MSG_ReadLong\",\"case\":\"decode\",\"value\":" + readValue + ",\"count\":" + reader.readCount + "}"
  floatBytes = bytes(4)
  bio.putF32(floatBytes, 0, 12.5)
  reader = msg.beginReadingBytes(floatBytes)
  readValue = msg.MSG_ReadFloat(reader)
  print "{\"function\":\"MSG_ReadFloat\",\"case\":\"decode\",\"value\":" + readValue + ",\"count\":" + reader.readCount + "}"
  reader = msg.beginReadingBytes(bytes([113,117,97,107,101,0]))
  readText = msg.MSG_ReadString(reader)
  print "{\"function\":\"MSG_ReadString\",\"case\":\"decode\",\"value\":\"" + readText + "\",\"count\":" + reader.readCount + "}"
  reader = msg.beginReadingBytes(bytes([158,255]))
  readValue = msg.MSG_ReadCoord(reader)
  print "{\"function\":\"MSG_ReadCoord\",\"case\":\"decode\",\"value\":" + readValue + ",\"count\":" + reader.readCount + "}"
  reader = msg.beginReadingBytes(bytes([192]))
  readValue = msg.MSG_ReadAngle(reader)
  print "{\"function\":\"MSG_ReadAngle\",\"case\":\"decode\",\"value\":" + readValue + ",\"count\":" + reader.readCount + "}"

  buffer = sz.SZ_Alloc(32)
  print "{\"function\":\"SZ_Alloc\",\"case\":\"minimum\",\"capacity\":" + buffer.maxSize + ",\"size\":" + buffer.curSize + "}"
  buffer.curSize = 9
  sz.SZ_Free(buffer)
  print "{\"function\":\"SZ_Free\",\"case\":\"logical\",\"size\":" + buffer.curSize + "}"
  buffer.curSize = 9
  sz.SZ_Clear(buffer)
  print "{\"function\":\"SZ_Clear\",\"case\":\"clear\",\"size\":" + buffer.curSize + "}"
  buffer = sz.allocOverflowing(8)
  buffer.curSize = 7
  sz.SZ_GetSpace(buffer, 2)
  print "{\"function\":\"SZ_GetSpace\",\"case\":\"overflow\",\"size\":" + buffer.curSize + ",\"overflowed\":" + boolText(buffer.overflowed) + "}"
  buffer = sz.alloc(16)
  sz.SZ_Write(buffer, bytes([1,2,3]), 0, 3)
  print "{\"function\":\"SZ_Write\",\"case\":\"copy\",\"size\":" + buffer.curSize + ",\"sum\":" + (buffer.data[0]+buffer.data[1]+buffer.data[2]) + "}"
  buffer = sz.alloc(16)
  buffer.curSize = 1
  buffer.data[0] = 0
  sz.SZ_Print(buffer, "abc")
  print "{\"function\":\"SZ_Print\",\"case\":\"replace_nul\",\"size\":" + buffer.curSize + ",\"text\":\"" + decode(slice(buffer.data,0,3)) + "\"}"

  print "{\"function\":\"COM_SkipPath\",\"case\":\"last\",\"value\":\"" + common.COM_SkipPath("maps/e1m1.bsp") + "\"}"
  print "{\"function\":\"COM_StripExtension\",\"case\":\"strip\",\"value\":\"" + common.COM_StripExtension("maps/e1m1.bsp") + "\"}"
  print "{\"function\":\"COM_FileExtension\",\"case\":\"extension\",\"value\":\"" + common.COM_FileExtension("maps/e1m1.bsp") + "\"}"
  print "{\"function\":\"COM_FileBase\",\"case\":\"base\",\"value\":\"" + common.COM_FileBase("maps/e1m1.bsp") + "\"}"
  print "{\"function\":\"COM_DefaultExtension\",\"case\":\"append\",\"value\":\"" + common.COM_DefaultExtension("maps/e1m1", ".bsp") + "\"}"
  parseSource = " // note\n \"two words\" tail"
  parsed = common.COM_Parse(parseSource, 0)
  print "{\"function\":\"COM_Parse\",\"case\":\"quoted\",\"token\":\"" + parsed[0] + "\",\"remaining\":\"" + common.substring(parseSource, parsed[1], len(bytes(parseSource)) - parsed[1]) + "\"}"

  commandLine = common.COM_InitArgv(["-safe","-rogue"])
  print "{\"function\":\"COM_CheckParm\",\"case\":\"found_missing\",\"found\":" + common.COM_CheckParm(commandLine,"-rogue") + ",\"missing\":" + common.COM_CheckParm(commandLine,"-none") + "}"
  print "{\"function\":\"COM_InitArgv\",\"case\":\"safe\",\"argc\":" + (len(commandLine.args) + 1) + ",\"rogue\":" + boolText(commandLine.rogue) + ",\"safe_tail\":\"" + commandLine.args[len(commandLine.args) - 1] + "\"}"
  initialized = common.COM_Init("ignored", ["-basedir","base"])
  print "{\"function\":\"COM_Init\",\"case\":\"little_endian\",\"bigendian\":" + boolText(initialized[2]) + ",\"cvars\":" + initialized[3] + ",\"commands\":" + initialized[4] + ",\"paths\":1}"
  print "{\"function\":\"va\",\"case\":\"literal\",\"value\":\"" + common.va("quake", []) + "\"}"
  searchData = bytes([3,9,7])
  print "{\"function\":\"memsearch\",\"case\":\"found_missing\",\"found\":" + common.memsearch(searchData,3,9) + ",\"missing\":" + common.memsearch(searchData,3,8) + "}"

  system = looseSystem()
  pathText = fsys.COM_Path_f(system)
  print "{\"function\":\"COM_Path_f\",\"case\":\"one_directory\",\"prints\":" + (len(system.searchPaths)+1) + "}"
  writeResult = fsys.COM_WriteFile(system, "out.bin", bytes([4,5]))
  written = fs.readAllBytes(fsys.join(fixtureGamePath(),"out.bin"))
  print "{\"function\":\"COM_WriteFile\",\"case\":\"write\",\"length\":" + len(written) + ",\"prints\":1}"

  createTarget = fsys.join(basePath(), "a/b/c.bin")
  fsys.COM_CreatePath(createTarget)
  print "{\"function\":\"COM_CreatePath\",\"case\":\"nested\",\"mkdirs\":2}"
  copySource = fsys.join(basePath(), "net.bin")
  fs.writeAllBytes(copySource, bytes([1,2,3]))
  copyTarget = fsys.join(basePath(), "cache/x.bin")
  fsys.COM_CopyFile(copySource, copyTarget)
  copyData = fs.readAllBytes(copyTarget)
  print "{\"function\":\"COM_CopyFile\",\"case\":\"copy\",\"length\":" + len(copyData) + ",\"mkdirs\":1}"

  found = fsys.COM_FindFile(system, "test.bin")
  print "{\"function\":\"COM_FindFile\",\"case\":\"loose\",\"length\":" + found[1] + ",\"opened\":" + boolText(found[0] is not void) + "}"
  opened = fsys.COM_OpenFile(system, "test.bin")
  print "{\"function\":\"COM_OpenFile\",\"case\":\"loose\",\"length\":" + opened[0] + ",\"opened\":" + boolText(opened[1] is not void) + "}"
  fopened = fsys.COM_FOpenFile(system, "test.bin")
  print "{\"function\":\"COM_FOpenFile\",\"case\":\"loose\",\"length\":" + fopened[0] + ",\"opened\":" + boolText(fopened[1] is not void) + "}"
  closed = fsys.COM_CloseFile(opened[1])
  print "{\"function\":\"COM_CloseFile\",\"case\":\"loose\",\"closed\":" + boolText(closed) + "}"

  loaded = fsys.COM_LoadFile(system, "test.bin")
  print "{\"function\":\"COM_LoadFile\",\"case\":\"zone\",\"terminated\":" + boolText(loaded[4]==0) + ",\"sum\":" + (loaded[0]+loaded[1]+loaded[2]+loaded[3]) + "}"
  loaded = fsys.COM_LoadHunkFile(system, "test.bin")
  print "{\"function\":\"COM_LoadHunkFile\",\"case\":\"hunk\",\"terminated\":" + boolText(loaded[4]==0) + ",\"sum\":" + (loaded[0]+loaded[1]+loaded[2]+loaded[3]) + "}"
  loaded = fsys.COM_LoadTempFile(system, "test.bin")
  print "{\"function\":\"COM_LoadTempFile\",\"case\":\"temp\",\"terminated\":" + boolText(loaded[4]==0) + "}"
  loaded = fsys.COM_LoadCacheFile(system, "test.bin")
  print "{\"function\":\"COM_LoadCacheFile\",\"case\":\"cache\",\"allocated\":" + boolText(loaded is not void) + ",\"terminated\":" + boolText(loaded[4]==0) + "}"
  stack = bytes(512)
  loaded = fsys.COM_LoadStackFile(system, "test.bin", stack)
  print "{\"function\":\"COM_LoadStackFile\",\"case\":\"stack\",\"same\":" + boolText(len(loaded)==len(stack)) + ",\"terminated\":" + boolText(loaded[4]==0) + "}"

  packPath = fsys.join(basePath(), "sample.pak")
  fs.writeAllBytes(packPath, packImage())
  packResult = fsys.COM_LoadPackFile(packPath)
  print "{\"function\":\"COM_LoadPackFile\",\"case\":\"one_entry\",\"loaded\":" + boolText(packResult[0] is not void) + ",\"files\":" + packResult[0].numFiles + ",\"modified\":" + boolText(packResult[1]) + "}"

  directorySystem = fsys.create("base", "id1")
  fsys.COM_AddGameDirectory(directorySystem, "base/id1")
  print "{\"function\":\"COM_AddGameDirectory\",\"case\":\"directory\",\"gamedir\":\"base/id1\",\"paths\":" + len(directorySystem.searchPaths) + "}"

  filesystemCommandLine = common.COM_InitArgv(["-basedir","base"])
  initializedSystem = fsys.COM_InitFilesystem("ignored", filesystemCommandLine)
  print "{\"function\":\"COM_InitFilesystem\",\"case\":\"basedir\",\"gamedir\":\"base/id1\",\"cachedir\":\"" + initializedSystem.cacheDirectory + "\",\"paths\":" + len(initializedSystem.searchPaths) + "}"

  sharewareSystem = fsys.create("base", "id1")
  registered = fsys.COM_CheckRegistered(sharewareSystem)
  print "{\"function\":\"COM_CheckRegistered\",\"case\":\"shareware\",\"registered\":0,\"prints\":1}"
end function
