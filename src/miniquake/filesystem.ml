package miniquake.filesystem

import miniquake.types as t
import miniquake.pak as pak
import miniquake.byteio as bio
import miniquake.array_util as arrayutil
import std.fs as fs

function create(baseDirectory, gameDirectory)
  return t.FileSystem(baseDirectory, gameDirectory, [])
end function

function join(a, b)
  return fs.joinPath(a, b)
end function

function normalizeName(name)
  source = bytes(name)
  output = bytes(len(source))
  index = 0
  while index < len(source)
    value = source[index]
    if value == 92 then value = 47 end if
    if value >= 65 and value <= 90 then value = value + 32 end if
    output[index] = value
    index = index + 1
  end while
  return decode(output)
end function

function addDirectory(system, directory)
  system.searchPaths = [t.SearchPath(directory, void)] + system.searchPaths
  return true
end function

function addPack(system, filename)
  archive = pak.load(filename)
  system.searchPaths = [t.SearchPath("", archive)] + system.searchPaths
  return archive
end function

function addGameDirectory(system, directory)
  // Match COM_AddGameDirectory: loose files override pakN, and a later game
  // directory overrides id1.  Prepending each path preserves that ordering.
  addDirectory(system, directory)
  index = 0
  while index < 100
    filename = fs.joinPath(directory, "pak" + index + ".pak")
    if fs.exists(filename) then addPack(system, filename) end if
    index = index + 1
  end while
  return system
end function

function standard(baseDirectory, gameName)
  system = create(baseDirectory, gameName)
  addGameDirectory(system, fs.joinPath(baseDirectory, "id1"))
  if not bio.equalInsensitive(gameName, "id1") then
    addGameDirectory(system, fs.joinPath(baseDirectory, gameName))
  end if
  return system
end function

function initialize(baseDirectory, gameName)
  return standard(baseDirectory, gameName)
end function

function readFile(system, name)
  normalized = normalizeName(name)
  for each searchPath in system.searchPaths
    if searchPath.archive is not void then
      item = pak.find(searchPath.archive, normalized)
      if item is not void then return slice(searchPath.archive.data, item.offset, item.length) end if
    else
      filename = fs.joinPath(searchPath.directory, normalized)
      if fs.exists(filename) then return fs.readAllBytes(filename) end if
    end if
  end for
  return error(1650, "COM_FindFile: " + name + " not found")
end function

function readText(system, name)
  return decode(readFile(system, name))
end function

function fileExists(system, name)
  normalized = normalizeName(name)
  for each searchPath in system.searchPaths
    if searchPath.archive is not void then
      if pak.hasFile(searchPath.archive, normalized) then return true end if
    else
      if fs.exists(fs.joinPath(searchPath.directory, normalized)) then return true end if
    end if
  end for
  return false
end function

function exists(system, name)
  return fileExists(system, name)
end function

function findLocation(system, name)
  normalized = normalizeName(name)
  for each searchPath in system.searchPaths
    if searchPath.archive is not void then
      if pak.hasFile(searchPath.archive, normalized) then return searchPath.archive.filename + ":" + normalized end if
    else
      filename = fs.joinPath(searchPath.directory, normalized)
      if fs.exists(filename) then return filename end if
    end if
  end for
  return ""
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
