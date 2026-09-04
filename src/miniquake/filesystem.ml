/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.filesystem.
*/
package miniquake.filesystem

import miniquake.types as t
import miniquake.pak as pak
import miniquake.byteio as bio
import miniquake.common as common
import miniquake.memory as memory
import miniquake.array_util as arrayutil
import miniquake.protocol_text as quakeText
import std.fs as fs

#if TARGET_OS == "windows"
/// Create a directory through the Win32 wide-character filesystem API.
/// @param path Filesystem path to create.
/// @param security Optional Win32 security attributes pointer.
/// @returns True when Windows creates the directory.
extern function CreateDirectoryW(path as wstr, security as ptr) from "kernel32.dll" returns bool
/// Read file metadata through the Win32 wide-character filesystem API.
/// @param path Filesystem path to inspect.
/// @param infoLevel Win32 attribute-information level.
/// @param data Caller-owned output buffer for the attribute record.
/// @returns True when Windows reads the metadata successfully.
extern function GetFileAttributesExW(path as wstr, infoLevel as i32, data as bytes) from "kernel32.dll" returns bool
#else
/// Create a directory through the POSIX filesystem API.
/// @param path Filesystem path to create.
/// @param mode POSIX permission bits filtered by the process umask.
/// @returns Zero on success or a negative failure result.
extern function PosixMkdir(path as cstr, mode as u32) from "libc.so.6" symbol "mkdir" returns i32
/// Read Linux x86-64 file metadata into a caller-owned `struct stat` buffer.
/// @param path Filesystem path to inspect.
/// @param data Caller-owned output buffer for the native stat record.
/// @returns Zero on success or a negative failure result.
extern function PosixStat(path as cstr, data as bytes) from "libc.so.6" symbol "stat" returns i32
#endif

/// Create one directory component on the active host platform and report
/// whether it exists after the operation.
/// @param path Filesystem path to create.
function createDirectory(path)
  if fs.isDir(path) then return true end if
#if TARGET_OS == "windows"
  return CreateDirectoryW(path, 0)
#else
  // 0777 is filtered by the process umask, matching conventional mkdir behavior.
  return PosixMkdir(path, 0x1ff) == 0 or fs.isDir(path)
#endif
end function

/// Implements the `create` operation for `miniquake.filesystem` (create).
/// @param baseDirectory Root directory containing the Quake installation.
/// @param gameDirectory Selected Quake game-data directory.
function create(baseDirectory, gameDirectory)
  return t.FileSystem(baseDirectory, gameDirectory, [], "", false, false, true, false)
end function

/// Implements the `join` operation for `miniquake.filesystem` (join).
/// @param a The a input consumed by `join`.
/// @param b The b input consumed by `join`.
function join(a, b)
  return fs.joinPath(a, b)
end function

/// Convert name into its canonical representation.
/// @param name Stable name that identifies the requested object or option.
function normalizeName(name)
  // COM_FindFile uses strcmp for PACK entries.  Windows itself supplies the
  // case-insensitive behavior for loose directory files.
  return name
end function

/// Add state for add directory.
/// @param system The system input consumed by `addDirectory`.
/// @param directory The directory input consumed by `addDirectory`.
function addDirectory(system, directory)
  system.searchPaths = [t.SearchPath(directory, void)] + system.searchPaths
  return true
end function

/// Read and validate pack file.
/// @param filename Path of the file to process.
function loadPackFile(filename)
  return pak.load(filename)
end function

/// Add state for add pack.
/// @param system The system input consumed by `addPack`.
/// @param filename Path of the file to process.
function addPack(system, filename)
  archive = loadPackFile(filename)
  system.searchPaths = [t.SearchPath("", archive)] + system.searchPaths
  if not pak.isOriginalPak0Directory(archive) then system.modified = true end if
  return archive
end function

/// Add state for add game directory.
/// @param system The system input consumed by `addGameDirectory`.
/// @param directory The directory input consumed by `addGameDirectory`.
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

/// Implements the `standard` operation for `miniquake.filesystem` (standard).
/// @param baseDirectory Root directory containing the Quake installation.
/// @param gameName Name that identifies the requested value or resource.
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

/// Initializes ialize for `miniquake.filesystem`.
/// @param baseDirectory Root directory containing the Quake installation.
/// @param gameName Name that identifies the requested value or resource.
function initialize(baseDirectory, gameName)
  return standard(baseDirectory, gameName)
end function

/// Implements the `trimTrailingSeparator` operation for `miniquake.filesystem` (trim trailing separator).
/// @param path Filesystem path to process.
function trimTrailingSeparator(path)
  source = bytes(path)
  if len(source) > 0 and (source[len(source) - 1] == 47 or source[len(source) - 1] == 92) then
    return common.substring(path, 0, len(source) - 1)
  end if
  return path
end function

/// Initialize state for initialize arguments.
/// @param suppliedBaseDirectory The supplied base directory input consumed by `initializeArguments`.
/// @param commandLine The command line input consumed by `initializeArguments`.
function initializeArguments(suppliedBaseDirectory, commandLine)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
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

/// Initialize state for init filesystem.
/// @param suppliedBaseDirectory The supplied base directory input consumed by `initFilesystem`.
/// @param commandLine The command line input consumed by `initFilesystem`.
function initFilesystem(suppliedBaseDirectory, commandLine)
  return initializeArguments(suppliedBaseDirectory, commandLine)
end function

/// Registers ed words for `miniquake.filesystem`.
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

/// Validate registered and report any incompatibility.
/// @param system The system input consumed by `checkRegistered`.
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

/// Implements the `containsDirectorySeparator` operation for `miniquake.filesystem` (contains directory separator).
/// @param name Stable name that identifies the requested object or option.
function containsDirectorySeparator(name)
  source = bytes(name)
  for each value in source
    if value == 47 or value == 92 then return true end if
  end for
  return false
end function

/// Create and initialize path.
/// @param path Filesystem path to process.
function createPath(path)
  source = bytes(path)
  index = 1
  while index < len(source)
    if source[index] == 47 or source[index] == 92 then
      prefix = common.substring(path, 0, index)
      if len(bytes(prefix)) > 2 then createDirectory(prefix) end if
    end if
    index = index + 1
  end while
  return true
end function

/// Return cache path derived from the active module state.
/// @param system The system input consumed by `cachePath`.
/// @param netPath Filesystem path used by the operation.
function cachePath(system, netPath)
  if system.cacheDirectory == "" then return netPath end if
  suffix = netPath
  source = bytes(netPath)
  if len(source) >= 2 and source[1] == 58 then
    suffix = common.substring(netPath, 2, len(source) - 2)
  end if
  return system.cacheDirectory + suffix
end function

/// Transfer data for copy file.
/// @param netPath Filesystem path used by the operation.
/// @param destination Destination value or collection to update.
function copyFile(netPath, destination)
  createPath(destination)
  copied = fs.copyFile(netPath, destination, true)
  if copied is error then return copied end if
  return true
end function

/// Implements the `fileTime` operation for `miniquake.filesystem` (file time).
/// @param path Filesystem path to process.
function fileTime(path)
#if TARGET_OS == "windows"
  data = bytes(36)
  if not GetFileAttributesExW(path, 0, data) then return -1 end if
  low = bio.u32(data, 20)
  high = bio.u32(data, 24)
  return high * 4294967296 + low
#else
  // Linux x86-64 glibc stores st_mtim.tv_sec at byte offset 88.  Seconds are
  // sufficient here because the value is used only to decide whether the
  // optional Quake cache copy is older than its source.
  data = bytes(144)
  if PosixStat(path, data) != 0 then return -1 end if
  low = bio.u32(data, 88)
  high = bio.u32(data, 92)
  return high * 4294967296 + low
#endif
end function

/// Return cached location derived from the active module state.
/// @param system The system input consumed by `cachedLocation`.
/// @param netPath Filesystem path used by the operation.
function cachedLocation(system, netPath)
  if system.cacheDirectory == "" then return netPath end if
  destination = cachePath(system, netPath)
  if fileTime(destination) < fileTime(netPath) then
    copied = copyFile(netPath, destination)
    if copied is error then return copied end if
  end if
  return destination
end function

/// Implements the `resolve` operation for `miniquake.filesystem` (resolve).
/// @param system The system input consumed by `resolve`.
/// @param name Stable name that identifies the requested object or option.
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

/// Read and validate file.
/// @param system The system input consumed by `readFile`.
/// @param name Stable name that identifies the requested object or option.
function readFile(system, name)
  found = resolve(system, name)
  if found is error then return found end if
  return found[0]
end function

/// Reads text for `miniquake.filesystem`.
/// @param system The system input consumed by `readText`.
/// @param name Stable name that identifies the requested object or option.
function readText(system, name)
  data = readFile(system, name)
  if data is error then return data end if
  return quakeText.decodeBytes(data)
end function

/// Return file.
/// @param system The system input consumed by `findFile`.
/// @param name Stable name that identifies the requested object or option.
function findFile(system, name)
  found = resolve(system, name)
  if found is error then return found end if
  return [found[0], len(found[0]), found[1]]
end function

/// Initialize state for open file.
/// @param system The system input consumed by `openFile`.
/// @param name Stable name that identifies the requested object or option.
function openFile(system, name)
  found = resolve(system, name)
  if found is error then return [-1, void] end if
  handle = t.CommonFileHandle(found[0], 0, len(found[0]), found[2], false, found[1])
  return [len(found[0]), handle]
end function

/// Implements the `fOpenFile` operation for `miniquake.filesystem` (f open file).
/// @param system The system input consumed by `fOpenFile`.
/// @param name Stable name that identifies the requested object or option.
function fOpenFile(system, name)
  found = resolve(system, name)
  if found is error then return [-1, void] end if
  handle = t.CommonFileHandle(found[0], 0, len(found[0]), false, false, found[1])
  return [len(found[0]), handle]
end function

/// Handle seek and update the associated state.
/// @param handle The handle input consumed by `handleSeek`.
/// @param position Position used by the operation.
function handleSeek(handle, position)
  if handle is void or handle.closed then return error(1655, "COM file handle is closed") end if
  if position < 0 or position > handle.length then return error(1656, "COM file seek outside file") end if
  handle.position = position
  return position
end function

/// Handle read and update the associated state.
/// @param handle The handle input consumed by `handleRead`.
/// @param count Number of entries or units to process.
function handleRead(handle, count)
  if handle is void or handle.closed then return error(1655, "COM file handle is closed") end if
  if count < 0 then return error(1657, "COM file read has negative size") end if
  remaining = handle.length - handle.position
  if count > remaining then count = remaining end if
  data = slice(handle.data, handle.position, count)
  handle.position = handle.position + count
  return data
end function

/// Release state for close file.
/// @param handle The handle input consumed by `closeFile`.
function closeFile(handle)
  if handle is void then return false end if
  // COM_CloseFile deliberately leaves the shared PACK handle open.
  if not handle.persistent then handle.closed = true end if
  return true
end function

/// COM_LoadFile always allocated one extra byte and NUL-terminated it.  Keep
/// readFile as the raw COM_FindFile view used by binary parsers, and expose the
/// load-family behavior explicitly.
/// @param system The system input consumed by `loadFile`.
/// @param name Stable name that identifies the requested object or option.
function loadFile(system, name)
  source = readFile(system, name)
  destination = bytes(len(source) + 1)
  bio.copyInto(destination, 0, source, 0, len(source))
  destination[len(source)] = 0
  return destination
end function

/// Read and validate hunk file.
/// @param system The system input consumed by `loadHunkFile`.
/// @param name Stable name that identifies the requested object or option.
function loadHunkFile(system, name)
  return loadFile(system, name)
end function

/// Read and validate temp file.
/// @param system The system input consumed by `loadTempFile`.
/// @param name Stable name that identifies the requested object or option.
function loadTempFile(system, name)
  return loadFile(system, name)
end function

/// Read and validate cache file.
/// @param system The system input consumed by `loadCacheFile`.
/// @param name Stable name that identifies the requested object or option.
function loadCacheFile(system, name)
  return loadFile(system, name)
end function

/// Read and validate stack file.
/// @param system The system input consumed by `loadStackFile`.
/// @param name Stable name that identifies the requested object or option.
/// @param buffer The buffer input consumed by `loadStackFile`.
function loadStackFile(system, name, buffer)
  source = readFile(system, name)
  required = len(source) + 1
  destination = buffer
  if len(destination) < required then destination = bytes(required) end if
  bio.copyInto(destination, 0, source, 0, len(source))
  destination[len(source)] = 0
  return destination
end function

/// Transfer data for copy terminated.
/// @param destination Destination value or collection to update.
/// @param source Source value or collection to read.
function copyTerminated(destination, source)
  bio.copyInto(destination, 0, source, 0, len(source))
  destination[len(source)] = 0
  return destination
end function

/// Read and validate hunk allocation.
/// @param system The system input consumed by `loadHunkAllocation`.
/// @param memoryState Mutable state used by `loadHunkAllocation`.
/// @param name Stable name that identifies the requested object or option.
function loadHunkAllocation(system, memoryState, name)
  source = readFile(system, name)
  if source is error then return source end if
  block = memory.hunkAllocName(memoryState, len(source) + 1, common.fileBase(name))
  copyTerminated(block.data, source)
  return block
end function

/// Read and validate temp allocation.
/// @param system The system input consumed by `loadTempAllocation`.
/// @param memoryState Mutable state used by `loadTempAllocation`.
/// @param name Stable name that identifies the requested object or option.
function loadTempAllocation(system, memoryState, name)
  source = readFile(system, name)
  if source is error then return source end if
  block = memory.hunkTempAlloc(memoryState, len(source) + 1, common.fileBase(name))
  copyTerminated(block.data, source)
  return block
end function

/// Read and validate zone allocation.
/// @param system The system input consumed by `loadZoneAllocation`.
/// @param memoryState Mutable state used by `loadZoneAllocation`.
/// @param name Stable name that identifies the requested object or option.
function loadZoneAllocation(system, memoryState, name)
  source = readFile(system, name)
  if source is error then return source end if
  block = memory.zoneMalloc(memoryState, len(source) + 1, common.fileBase(name))
  copyTerminated(block.data, source)
  return block
end function

/// Read and validate cache allocation.
/// @param system The system input consumed by `loadCacheAllocation`.
/// @param memoryState Mutable state used by `loadCacheAllocation`.
/// @param name Stable name that identifies the requested object or option.
function loadCacheAllocation(system, memoryState, name)
  source = readFile(system, name)
  if source is error then return source end if
  user = memory.cacheAlloc(memoryState, len(source) + 1, common.fileBase(name))
  copyTerminated(user.block.data, source)
  return user
end function

/// Read and validate stack allocation.
/// @param system The system input consumed by `loadStackAllocation`.
/// @param memoryState Mutable state used by `loadStackAllocation`.
/// @param name Stable name that identifies the requested object or option.
/// @param buffer The buffer input consumed by `loadStackAllocation`.
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

/// Report whether file exists holds for the active state.
/// @param system The system input consumed by `fileExists`.
/// @param name Stable name that identifies the requested object or option.
function fileExists(system, name)
  // Existence checks must not materialize an entire PAK entry.  In particular,
  // Host_Map_f probes multi-megabyte BSP files before it changes any running
  // game state; resolve() would otherwise copy the complete map merely to
  // answer this boolean question.
  normalized = normalizeName(name)
  searchIndex = 0
  if system.progsHack and normalized == "progs.dat" then searchIndex = 1 end if
  while searchIndex < len(system.searchPaths)
    searchPath = system.searchPaths[searchIndex]
    if searchPath.archive is not void then
      if pak.find(searchPath.archive, normalized) is not void then return true end if
    else
      if system.staticRegistered or not containsDirectorySeparator(normalized) then
        if fs.exists(fs.joinPath(searchPath.directory, normalized)) then return true end if
      end if
    end if
    searchIndex = searchIndex + 1
  end while
  return false
end function

/// Report whether exists holds for the active state.
/// @param system The system input consumed by `exists`.
/// @param name Stable name that identifies the requested object or option.
function exists(system, name)
  return fileExists(system, name)
end function

/// Return location.
/// @param system The system input consumed by `findLocation`.
/// @param name Stable name that identifies the requested object or option.
function findLocation(system, name)
  found = try(resolve(system, name))
  if found is error then return "" end if
  return found[1]
end function

/// Return game path derived from the active module state.
/// @param system The system input consumed by `gamePath`.
/// @param name Stable name that identifies the requested object or option.
function gamePath(system, name)
  return fs.joinPath(fs.joinPath(system.baseDirectory, system.gameDirectory), name)
end function

/// Encode and write file.
/// @param system The system input consumed by `writeFile`.
/// @param name Stable name that identifies the requested object or option.
/// @param data Input data consumed by the operation.
function writeFile(system, name, data)
  return fs.writeAllBytes(gamePath(system, name), data)
end function

/// Writes bytes for `miniquake.filesystem`.
/// @param system The system input consumed by `writeBytes`.
/// @param name Stable name that identifies the requested object or option.
/// @param data Input data consumed by the operation.
function writeBytes(system, name, data)
  return writeFile(system, name, data)
end function

/// Writes text for `miniquake.filesystem`.
/// @param system The system input consumed by `writeText`.
/// @param name Stable name that identifies the requested object or option.
/// @param text Text to parse or process.
function writeText(system, name, text)
  data = quakeText.encodeBytes(text)
  if data is error then return data end if
  return fs.writeAllBytes(gamePath(system, name), data)
end function

/// Return music track name derived from the active module state.
/// @param track The track input consumed by `musicTrackName`.
function musicTrackName(track)
  number = "" + track
  if track >= 0 and track < 10 then number = "0" + number end if
  return "track" + number + ".ogg"
end function

/// Read and validate loose music track.
/// @param directory The directory input consumed by `readLooseMusicTrack`.
/// @param filename Path of the file to process.
function readLooseMusicTrack(directory, filename)
  candidate = fs.joinPath(fs.joinPath(directory, "music"), filename)
  if fs.exists(candidate) then return fs.readAllBytes(candidate) end if
  return error(1651, candidate + " not found")
end function

/// Implements the `rereleaseMusicDirectory` operation for `miniquake.filesystem` (rerelease music directory).
/// @param system The system input consumed by `rereleaseMusicDirectory`.
/// @param gameDirectory Selected Quake game-data directory.
function rereleaseMusicDirectory(system, gameDirectory)
  return fs.joinPath(
    fs.joinPath(
      fs.joinPath(system.baseDirectory, "rerelease"),
      gameDirectory
    ),
    "music"
  )
end function

/// Return music track path derived from the active module state.
/// @param system The system input consumed by `musicTrackPath`.
/// @param track The track input consumed by `musicTrackPath`.
function musicTrackPath(system, track)
  filename = musicTrackName(track)
  // Return an OS path only for loose files.  PAK-contained or otherwise
  // virtualized music still uses readMusicTrack's byte-backed fallback.
  gameLoose = fs.joinPath(fs.joinPath(system.baseDirectory, system.gameDirectory), "music")
  candidate = fs.joinPath(gameLoose, filename)
  if fs.exists(candidate) then return candidate end if
  candidate = fs.joinPath(rereleaseMusicDirectory(system, system.gameDirectory), filename)
  if fs.exists(candidate) then return candidate end if
  if system.gameDirectory != "id1" then
    candidate = fs.joinPath(rereleaseMusicDirectory(system, "id1"), filename)
    if fs.exists(candidate) then return candidate end if
  end if
  return ""
end function

/// Read and validate music track.
/// @param system The system input consumed by `readMusicTrack`.
/// @param track The track input consumed by `readMusicTrack`.
function readMusicTrack(system, track)
  filename = musicTrackName(track)
  classic = try(readFile(system, "music/" + filename))
  if classic is not error then return classic end if
  rereleaseRoot = fs.joinPath(system.baseDirectory, "rerelease")
  rereleaseGame = try(readLooseMusicTrack(fs.joinPath(rereleaseRoot, system.gameDirectory), filename))
  if rereleaseGame is not error then return rereleaseGame end if
  // The Steam rerelease keeps the original soundtrack in rerelease/id1 even
  // when a legacy -game directory supplies only code/maps.  Mission packs do
  // have their own directories and are preferred by the lookup above.
  if system.gameDirectory != "id1" then
    rereleaseId1 = try(readLooseMusicTrack(fs.joinPath(rereleaseRoot, "id1"), filename))
    if rereleaseId1 is not error then return rereleaseId1 end if
  end if
  return error(1651, "music/" + filename + " not found below " + system.gameDirectory + " or rerelease")
end function

/// Implements the `describe` operation for `miniquake.filesystem` (describe).
/// @param system The system input consumed by `describe`.
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

/// Return path command text for the active module state.
/// @param system The system input consumed by `pathCommandText`.
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

/// Return search path summary derived from the active module state.
/// @param system The system input consumed by `searchPathSummary`.
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


/// Release or remove state for the requested value.
/// @param system The system input consumed by `release`.
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

/// Return pack file count derived from the active module state.
/// @param system The system input consumed by `packFileCount`.
function packFileCount(system)
  count = 0
  for each searchPath in system.searchPaths
    if searchPath.archive is not void then count = count + searchPath.archive.numFiles end if
  end for
  return count
end function

/// Report whether is modified.
/// @param system The system input consumed by `isModified`.
function isModified(system)
  if system.modified or system.gameDirectory != "id1" then return true end if
  for each searchPath in system.searchPaths
    if searchPath.archive is not void and not pak.isOriginalPak0Directory(searchPath.archive) then
      return true
    end if
  end for
  return false
end function

/// Original WinQuake/common.c filesystem entry points.  The state that was
/// global in C is explicit in MiniLang, but the observable operations are the
/// same and remain independently differential-testable.
/// @param system The system input consumed by `COM_CheckRegistered`.
function COM_CheckRegistered(system)
  return checkRegistered(system)
end function

/// Mirror Quake's COM_Path_f routine and its observable state changes.
/// @param system The system input consumed by `COM_Path_f`.
function COM_Path_f(system)
  return pathCommandText(system)
end function

/// Mirror Quake's COM_WriteFile routine and its observable state changes.
/// @param system The system input consumed by `COM_WriteFile`.
/// @param filename Path of the file to process.
/// @param data Input data consumed by the operation.
function COM_WriteFile(system, filename, data)
  return writeFile(system, filename, data)
end function

/// Mirror Quake's COM_CreatePath routine and its observable state changes.
/// @param path Filesystem path to process.
function COM_CreatePath(path)
  return createPath(path)
end function

/// Mirror Quake's COM_CopyFile routine and its observable state changes.
/// @param netPath Filesystem path used by the operation.
/// @param cachePath Filesystem path used by the operation.
function COM_CopyFile(netPath, cachePath)
  return copyFile(netPath, cachePath)
end function

/// Mirror Quake's COM_FindFile routine and its observable state changes.
/// @param system The system input consumed by `COM_FindFile`.
/// @param filename Path of the file to process.
function COM_FindFile(system, filename)
  return findFile(system, filename)
end function

/// Mirror Quake's COM_OpenFile routine and its observable state changes.
/// @param system The system input consumed by `COM_OpenFile`.
/// @param filename Path of the file to process.
function COM_OpenFile(system, filename)
  return openFile(system, filename)
end function

/// Mirror Quake's COM_FOpenFile routine and its observable state changes.
/// @param system The system input consumed by `COM_FOpenFile`.
/// @param filename Path of the file to process.
function COM_FOpenFile(system, filename)
  return fOpenFile(system, filename)
end function

/// Mirror Quake's COM_CloseFile routine and its observable state changes.
/// @param handle The handle input consumed by `COM_CloseFile`.
function COM_CloseFile(handle)
  return closeFile(handle)
end function

/// Mirror Quake's COM_LoadFile routine and its observable state changes.
/// @param system The system input consumed by `COM_LoadFile`.
/// @param path Filesystem path to process.
function COM_LoadFile(system, path)
  return loadFile(system, path)
end function

/// Mirror Quake's COM_LoadHunkFile routine and its observable state changes.
/// @param system The system input consumed by `COM_LoadHunkFile`.
/// @param path Filesystem path to process.
function COM_LoadHunkFile(system, path)
  return loadHunkFile(system, path)
end function

/// Mirror Quake's COM_LoadTempFile routine and its observable state changes.
/// @param system The system input consumed by `COM_LoadTempFile`.
/// @param path Filesystem path to process.
function COM_LoadTempFile(system, path)
  return loadTempFile(system, path)
end function

/// Mirror Quake's COM_LoadCacheFile routine and its observable state changes.
/// @param system The system input consumed by `COM_LoadCacheFile`.
/// @param path Filesystem path to process.
function COM_LoadCacheFile(system, path)
  return loadCacheFile(system, path)
end function

/// Mirror Quake's COM_LoadStackFile routine and its observable state changes.
/// @param system The system input consumed by `COM_LoadStackFile`.
/// @param path Filesystem path to process.
/// @param buffer The buffer input consumed by `COM_LoadStackFile`.
function COM_LoadStackFile(system, path, buffer)
  return loadStackFile(system, path, buffer)
end function

/// Mirror Quake's COM_LoadPackFile routine and its observable state changes.
/// @param filename Path of the file to process.
function COM_LoadPackFile(filename)
  archive = loadPackFile(filename)
  return [archive, not pak.isOriginalPak0Directory(archive)]
end function

/// Mirror Quake's COM_AddGameDirectory routine and its observable state changes.
/// @param system The system input consumed by `COM_AddGameDirectory`.
/// @param directory The directory input consumed by `COM_AddGameDirectory`.
function COM_AddGameDirectory(system, directory)
  return addGameDirectory(system, directory)
end function

/// Mirror Quake's COM_InitFilesystem routine and its observable state changes.
/// @param suppliedBaseDirectory The supplied base directory input consumed by `COM_InitFilesystem`.
/// @param commandLine The command line input consumed by `COM_InitFilesystem`.
function COM_InitFilesystem(suppliedBaseDirectory, commandLine)
  return initFilesystem(suppliedBaseDirectory, commandLine)
end function
