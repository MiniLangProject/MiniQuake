package miniquake.filesystem

import miniquake.types as t
import miniquake.pak as pak
import miniquake.byteio as bio
import miniquake.common as common
import miniquake.memory as memory
import miniquake.array_util as arrayutil
import std.fs as fs

extern function CreateDirectoryW(path as wstr, security as ptr) from "kernel32.dll" returns bool
extern function GetFileAttributesExW(path as wstr, infoLevel as i32, data as bytes) from "kernel32.dll" returns bool

function create(baseDirectory, gameDirectory)
  return t.FileSystem(baseDirectory, gameDirectory, [], "", false, false, true, false)
end function

function join(a, b)
  return fs.joinPath(a, b)
end function

function normalizeName(name)
  // COM_FindFile uses strcmp for PACK entries.  Windows itself supplies the
  // case-insensitive behavior for loose directory files.
  return name
end function

function addDirectory(system, directory)
  system.searchPaths = [t.SearchPath(directory, void)] + system.searchPaths
  return true
end function

function loadPackFile(filename)
  return pak.load(filename)
end function

function addPack(system, filename)
  archive = loadPackFile(filename)
  system.searchPaths = [t.SearchPath("", archive)] + system.searchPaths
  if not pak.isOriginalPak0Directory(archive) then system.modified = true end if
  return archive
end function

function addGameDirectory(system, directory)
  // Match COM_AddGameDirectory: pakN overrides the loose directory, higher N
  // overrides lower N, and the first missing sequential PAK terminates probing.
  addDirectory(system, directory)
  index = 0
  while index < 2048
    filename = fs.joinPath(directory, "pak" + index + ".pak")
    if not fs.exists(filename) then break end if
    addPack(system, filename)
    index = index + 1
  end while
  return system
end function

function standard(baseDirectory, gameName)
  system = create(baseDirectory, gameName)
  addGameDirectory(system, fs.joinPath(baseDirectory, "id1"))
  if gameName != "id1" then
    system.modified = true
    addGameDirectory(system, fs.joinPath(baseDirectory, gameName))
  end if
  checkRegistered(system)
  return system
end function

function initialize(baseDirectory, gameName)
  return standard(baseDirectory, gameName)
end function

function trimTrailingSeparator(path)
  source = bytes(path)
  if len(source) > 0 and (source[len(source) - 1] == 47 or source[len(source) - 1] == 92) then
    return common.substring(path, 0, len(source) - 1)
  end if
  return path
end function

function initializeArguments(suppliedBaseDirectory, commandLine)
  baseDirectory = common.parmValue(commandLine, "-basedir", suppliedBaseDirectory)
  baseDirectory = trimTrailingSeparator(baseDirectory)
  system = create(baseDirectory, "id1")

  cachePosition = common.checkParm(commandLine, "-cachedir")
  if cachePosition != 0 and cachePosition < len(commandLine.args) then
    cacheValue = commandLine.args[cachePosition]
    cacheBytes = bytes(cacheValue)
    if len(cacheBytes) > 0 and cacheBytes[0] == 45 then
      system.cacheDirectory = ""
    else
      system.cacheDirectory = cacheValue
    end if
  end if

  addGameDirectory(system, fs.joinPath(baseDirectory, "id1"))
  if common.hasParm(commandLine, "-rogue") then
    system.gameDirectory = "rogue"
    system.modified = true
    addGameDirectory(system, fs.joinPath(baseDirectory, "rogue"))
  end if
  if common.hasParm(commandLine, "-hipnotic") then
    system.gameDirectory = "hipnotic"
    system.modified = true
    addGameDirectory(system, fs.joinPath(baseDirectory, "hipnotic"))
  end if

  gamePosition = common.checkParm(commandLine, "-game")
  if gamePosition != 0 and gamePosition < len(commandLine.args) then
    system.gameDirectory = commandLine.args[gamePosition]
    system.modified = true
    addGameDirectory(system, fs.joinPath(baseDirectory, system.gameDirectory))
  end if

  pathPosition = common.checkParm(commandLine, "-path")
  if pathPosition != 0 then
    system.modified = true
    system.searchPaths = []
    index = pathPosition
    while index < len(commandLine.args)
      path = commandLine.args[index]
      pathBytes = bytes(path)
      if len(pathBytes) == 0 or pathBytes[0] == 43 or pathBytes[0] == 45 then break end if
      if common.fileExtension(path) == "pak" then
        loaded = try(addPack(system, path))
        if loaded is error then return error(1654, "Couldn't load packfile: " + path) end if
      else
        addDirectory(system, path)
      end if
      index = index + 1
    end while
  end if

  system.progsHack = common.hasParm(commandLine, "-proghack")
  checkRegistered(system)
  return system
end function

function initFilesystem(suppliedBaseDirectory, commandLine)
  return initializeArguments(suppliedBaseDirectory, commandLine)
end function

function registeredWords()
  return [
    0,0,0,0,0,0,0,0,0,0,26112,0,0,0,26112,0,
    0,102,0,0,0,0,103,0,0,26213,0,0,0,0,101,26112,
    99,25953,0,0,0,0,97,25955,100,25953,0,0,0,0,97,25956,
    100,25956,0,25705,26985,25600,100,25956,99,25960,25088,100,26724,0,25192,
    25955,0,25959,26979,100,26468,99,26983,25856,0,25190,26473,27240,26472,27241,
    26470,25088,0,98,25958,26214,26214,26214,25954,0,0,0,98,25444,26212,
    25442,0,0,0,0,0,98,26210,0,0,0,0,0,0,97,26209,
    0,0,0,0,0,0,0,25856,0,0,0,0,0,0,0,25600,0,0,0,
  ]
end function

function checkRegistered(system)
  opened = try(resolve(system, "gfx/pop.lmp"))
  system.staticRegistered = false
  system.registered = false
  if opened is error then
    if system.modified then return error(1652, "You must have the registered version to use modified games") end if
    return false
  end if

  data = opened[0]
  expected = registeredWords()
  if len(data) < len(expected) * 2 then return error(1653, "Corrupted data file.") end if
  index = 0
  while index < len(expected)
    word = (data[index * 2] << 8) | data[index * 2 + 1]
    if word != expected[index] then return error(1653, "Corrupted data file.") end if
    index = index + 1
  end while
  system.registered = true
  system.staticRegistered = true
  return true
end function

function containsDirectorySeparator(name)
  source = bytes(name)
  for each value in source
    if value == 47 or value == 92 then return true end if
  end for
  return false
end function

function createPath(path)
  source = bytes(path)
  index = 1
  while index < len(source)
    if source[index] == 47 or source[index] == 92 then
      prefix = common.substring(path, 0, index)
      if len(bytes(prefix)) > 2 then CreateDirectoryW(prefix, 0) end if
    end if
    index = index + 1
  end while
  return true
end function

function cachePath(system, netPath)
  if system.cacheDirectory == "" then return netPath end if
  suffix = netPath
  source = bytes(netPath)
  if len(source) >= 2 and source[1] == 58 then
    suffix = common.substring(netPath, 2, len(source) - 2)
  end if
  return system.cacheDirectory + suffix
end function

function copyFile(netPath, destination)
  createPath(destination)
  copied = fs.copyFile(netPath, destination, true)
  if copied is error then return copied end if
  return true
end function

function fileTime(path)
  data = bytes(36)
  if not GetFileAttributesExW(path, 0, data) then return -1 end if
  low = bio.u32(data, 20)
  high = bio.u32(data, 24)
  return high * 4294967296 + low
end function

function cachedLocation(system, netPath)
  if system.cacheDirectory == "" then return netPath end if
  destination = cachePath(system, netPath)
  if fileTime(destination) < fileTime(netPath) then
    copied = copyFile(netPath, destination)
    if copied is error then return copied end if
  end if
  return destination
end function

function resolve(system, name)
  normalized = normalizeName(name)
  searchIndex = 0
  if system.progsHack and normalized == "progs.dat" then searchIndex = 1 end if
  while searchIndex < len(system.searchPaths)
    searchPath = system.searchPaths[searchIndex]
    if searchPath.archive is not void then
      item = pak.find(searchPath.archive, normalized)
      if item is not void then
        // Keep both heap objects in named roots while the result array is
        // allocated; large retail PAK reads can trigger GC at this boundary.
        fileData = slice(searchPath.archive.data, item.offset, item.length)
        location = searchPath.archive.filename + ":" + normalized
        result = [fileData, location, true]
        return result
      end if
    else
      if not system.staticRegistered and containsDirectorySeparator(normalized) then
        searchIndex = searchIndex + 1
        continue
      end if
      filename = fs.joinPath(searchPath.directory, normalized)
      if fs.exists(filename) then
        actual = cachedLocation(system, filename)
        if actual is error then return actual end if
        data = fs.readAllBytes(actual)
        if data is error then return data end if
        result = [data, actual, false]
        return result
      end if
    end if
    searchIndex = searchIndex + 1
  end while
  return error(1650, "COM_FindFile: " + name + " not found")
end function

function readFile(system, name)
  found = resolve(system, name)
  if found is error then return found end if
  return found[0]
end function

function readText(system, name)
  return decode(readFile(system, name))
end function

function findFile(system, name)
  found = resolve(system, name)
  if found is error then return found end if
  return [found[0], len(found[0]), found[1]]
end function

function openFile(system, name)
  found = resolve(system, name)
  if found is error then return [-1, void] end if
  handle = t.CommonFileHandle(found[0], 0, len(found[0]), found[2], false, found[1])
  return [len(found[0]), handle]
end function

function fOpenFile(system, name)
  found = resolve(system, name)
  if found is error then return [-1, void] end if
  handle = t.CommonFileHandle(found[0], 0, len(found[0]), false, false, found[1])
  return [len(found[0]), handle]
end function

function handleSeek(handle, position)
  if handle is void or handle.closed then return error(1655, "COM file handle is closed") end if
  if position < 0 or position > handle.length then return error(1656, "COM file seek outside file") end if
  handle.position = position
  return position
end function

function handleRead(handle, count)
  if handle is void or handle.closed then return error(1655, "COM file handle is closed") end if
  if count < 0 then return error(1657, "COM file read has negative size") end if
  remaining = handle.length - handle.position
  if count > remaining then count = remaining end if
  data = slice(handle.data, handle.position, count)
  handle.position = handle.position + count
  return data
end function

function closeFile(handle)
  if handle is void then return false end if
  // COM_CloseFile deliberately leaves the shared PACK handle open.
  if not handle.persistent then handle.closed = true end if
  return true
end function

// COM_LoadFile always allocated one extra byte and NUL-terminated it.  Keep
// readFile as the raw COM_FindFile view used by binary parsers, and expose the
// load-family behavior explicitly.
function loadFile(system, name)
  source = readFile(system, name)
  destination = bytes(len(source) + 1)
  bio.copyInto(destination, 0, source, 0, len(source))
  destination[len(source)] = 0
  return destination
end function

function loadHunkFile(system, name)
  return loadFile(system, name)
end function

function loadTempFile(system, name)
  return loadFile(system, name)
end function

function loadCacheFile(system, name)
  return loadFile(system, name)
end function

function loadStackFile(system, name, buffer)
  source = readFile(system, name)
  required = len(source) + 1
  destination = buffer
  if len(destination) < required then destination = bytes(required) end if
  bio.copyInto(destination, 0, source, 0, len(source))
  destination[len(source)] = 0
  return destination
end function

function copyTerminated(destination, source)
  bio.copyInto(destination, 0, source, 0, len(source))
  destination[len(source)] = 0
  return destination
end function

function loadHunkAllocation(system, memoryState, name)
  source = readFile(system, name)
  if source is error then return source end if
  block = memory.hunkAllocName(memoryState, len(source) + 1, common.fileBase(name))
  copyTerminated(block.data, source)
  return block
end function

function loadTempAllocation(system, memoryState, name)
  source = readFile(system, name)
  if source is error then return source end if
  block = memory.hunkTempAlloc(memoryState, len(source) + 1, common.fileBase(name))
  copyTerminated(block.data, source)
  return block
end function

function loadZoneAllocation(system, memoryState, name)
  source = readFile(system, name)
  if source is error then return source end if
  block = memory.zoneMalloc(memoryState, len(source) + 1, common.fileBase(name))
  copyTerminated(block.data, source)
  return block
end function

function loadCacheAllocation(system, memoryState, name)
  source = readFile(system, name)
  if source is error then return source end if
  user = memory.cacheAlloc(memoryState, len(source) + 1, common.fileBase(name))
  copyTerminated(user.block.data, source)
  return user
end function

function loadStackAllocation(system, memoryState, name, buffer)
  source = readFile(system, name)
  if source is error then return source end if
  if len(buffer) >= len(source) + 1 then
    copyTerminated(buffer, source)
    return [buffer, void]
  end if
  block = memory.hunkTempAlloc(memoryState, len(source) + 1, common.fileBase(name))
  copyTerminated(block.data, source)
  return [block.data, block]
end function

function fileExists(system, name)
  found = try(resolve(system, name))
  return found is not error
end function

function exists(system, name)
  return fileExists(system, name)
end function

function findLocation(system, name)
  found = try(resolve(system, name))
  if found is error then return "" end if
  return found[1]
end function

function gamePath(system, name)
  return fs.joinPath(fs.joinPath(system.baseDirectory, system.gameDirectory), name)
end function

function writeFile(system, name, data)
  return fs.writeAllBytes(gamePath(system, name), data)
end function

function writeBytes(system, name, data)
  return writeFile(system, name, data)
end function

function writeText(system, name, text)
  return fs.writeAllText(gamePath(system, name), text)
end function

function musicTrackName(track)
  number = "" + track
  if track >= 0 and track < 10 then number = "0" + number end if
  return "track" + number + ".ogg"
end function

function readMusicTrack(system, track)
  filename = musicTrackName(track)
  classic = try(readFile(system, "music/" + filename))
  if classic is not error then return classic end if
  rerelease = fs.joinPath(
    fs.joinPath(
      fs.joinPath(
        fs.joinPath(system.baseDirectory, "rerelease"),
        system.gameDirectory
      ),
      "music"
    ),
    filename
  )
  if fs.exists(rerelease) then return fs.readAllBytes(rerelease) end if
  return error(1651, "music/" + filename + " not found")
end function

function describe(system)
  text = "basedir=" + system.baseDirectory + " game=" + system.gameDirectory
  for each searchPath in system.searchPaths
    if searchPath.archive is not void then
      text = text + "\n  pak " + searchPath.archive.filename + " (" + searchPath.archive.numFiles + " files)"
    else
      text = text + "\n  dir " + searchPath.directory
    end if
  end for
  return text
end function

function pathCommandText(system)
  text = "Current search path:"
  for each searchPath in system.searchPaths
    if searchPath.archive is not void then
      text = text + "\n" + searchPath.archive.filename + " (" + searchPath.archive.numFiles + " files)"
    else
      text = text + "\n" + searchPath.directory
    end if
  end for
  return text
end function

function searchPathSummary(system)
  result = arrayutil.makeEmptyArray(len(system.searchPaths))
  index = 0
  while index < len(system.searchPaths)
    searchPath = system.searchPaths[index]
    if searchPath.archive is not void then
      result[index] = searchPath.archive.filename + " (" + searchPath.archive.numFiles + " files)"
    else
      result[index] = searchPath.directory
    end if
    index = index + 1
  end while
  return result
end function


function release(system)
  if system is void then return false end if
  for each searchPath in system.searchPaths
    if searchPath.archive is not void then
      searchPath.archive.data = bytes()
      searchPath.archive.files = []
      searchPath.archive.numFiles = 0
      searchPath.archive = void
    end if
  end for
  system.searchPaths = []
  return true
end function

function packFileCount(system)
  count = 0
  for each searchPath in system.searchPaths
    if searchPath.archive is not void then count = count + searchPath.archive.numFiles end if
  end for
  return count
end function

function isModified(system)
  if system.modified or system.gameDirectory != "id1" then return true end if
  for each searchPath in system.searchPaths
    if searchPath.archive is not void and not pak.isOriginalPak0Directory(searchPath.archive) then
      return true
    end if
  end for
  return false
end function

// Original WinQuake/common.c filesystem entry points.  The state that was
// global in C is explicit in MiniLang, but the observable operations are the
// same and remain independently differential-testable.
function COM_CheckRegistered(system)
  return checkRegistered(system)
end function

function COM_Path_f(system)
  return pathCommandText(system)
end function

function COM_WriteFile(system, filename, data)
  return writeFile(system, filename, data)
end function

function COM_CreatePath(path)
  return createPath(path)
end function

function COM_CopyFile(netPath, cachePath)
  return copyFile(netPath, cachePath)
end function

function COM_FindFile(system, filename)
  return findFile(system, filename)
end function

function COM_OpenFile(system, filename)
  return openFile(system, filename)
end function

function COM_FOpenFile(system, filename)
  return fOpenFile(system, filename)
end function

function COM_CloseFile(handle)
  return closeFile(handle)
end function

function COM_LoadFile(system, path)
  return loadFile(system, path)
end function

function COM_LoadHunkFile(system, path)
  return loadHunkFile(system, path)
end function

function COM_LoadTempFile(system, path)
  return loadTempFile(system, path)
end function

function COM_LoadCacheFile(system, path)
  return loadCacheFile(system, path)
end function

function COM_LoadStackFile(system, path, buffer)
  return loadStackFile(system, path, buffer)
end function

function COM_LoadPackFile(filename)
  archive = loadPackFile(filename)
  return [archive, not pak.isOriginalPak0Directory(archive)]
end function

function COM_AddGameDirectory(system, directory)
  return addGameDirectory(system, directory)
end function

function COM_InitFilesystem(suppliedBaseDirectory, commandLine)
  return initFilesystem(suppliedBaseDirectory, commandLine)
end function
