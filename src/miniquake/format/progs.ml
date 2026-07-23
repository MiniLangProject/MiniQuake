package miniquake.format.progs

import miniquake.types as t
import miniquake.constants as c
import miniquake.byteio as bio
import miniquake.array_util as arrayutil
import std.fs as fs

function stringAt(strings, offset)
  if offset < 0 or offset >= len(strings) then return "" end if
  return bio.cString(strings, offset)
end function

function checkSection(data, offset, count, stride, name)
  if offset < 0 or count < 0 or offset + count * stride > len(data) then return error(1900, "progs.dat section outside file: " + name) end if
  return true
end function

function parse(data, filename)
  if len(data) < 60 then return error(1901, filename + ": progs.dat header is truncated") end if
  version = bio.i32(data, 0)
  crc = bio.i32(data, 4)
  if version != c.PROG_VERSION then return error(1902, filename + ": unsupported progs.dat version " + version) end if
  statementOffset = bio.i32(data, 8)
  statementCount = bio.i32(data, 12)
  globalDefOffset = bio.i32(data, 16)
  globalDefCount = bio.i32(data, 20)
  fieldDefOffset = bio.i32(data, 24)
  fieldDefCount = bio.i32(data, 28)
  functionOffset = bio.i32(data, 32)
  functionCount = bio.i32(data, 36)
  stringOffset = bio.i32(data, 40)
  stringCount = bio.i32(data, 44)
  globalsOffset = bio.i32(data, 48)
  globalsCount = bio.i32(data, 52)
  entityFields = bio.i32(data, 56)

  checkSection(data, statementOffset, statementCount, 8, "statements")
  checkSection(data, globalDefOffset, globalDefCount, 8, "globaldefs")
  checkSection(data, fieldDefOffset, fieldDefCount, 8, "fielddefs")
  checkSection(data, functionOffset, functionCount, 36, "functions")
  checkSection(data, stringOffset, stringCount, 1, "strings")
  checkSection(data, globalsOffset, globalsCount, 4, "globals")

  strings = slice(data, stringOffset, stringCount)
  statements = arrayutil.makeEmptyArray(statementCount)
  i = 0
  while i < statementCount
    offset = statementOffset + i * 8
    statements[i] = t.QuakeCStatement(bio.u16(data, offset), bio.i16(data, offset + 2), bio.i16(data, offset + 4), bio.i16(data, offset + 6))
    i = i + 1
  end while

  globalDefs = arrayutil.makeEmptyArray(globalDefCount)
  i = 0
  while i < globalDefCount
    offset = globalDefOffset + i * 8
    nameOffset = bio.i32(data, offset + 4)
    globalDefs[i] = t.QuakeCDef(bio.u16(data, offset), bio.u16(data, offset + 2), nameOffset, stringAt(strings, nameOffset))
    i = i + 1
  end while

  fieldDefs = arrayutil.makeEmptyArray(fieldDefCount)
  i = 0
  while i < fieldDefCount
    offset = fieldDefOffset + i * 8
    nameOffset = bio.i32(data, offset + 4)
    fieldDefs[i] = t.QuakeCDef(bio.u16(data, offset), bio.u16(data, offset + 2), nameOffset, stringAt(strings, nameOffset))
    i = i + 1
  end while

  functions = arrayutil.makeEmptyArray(functionCount)
  i = 0
  while i < functionCount
    offset = functionOffset + i * 36
    nameOffset = bio.i32(data, offset + 16)
    fileOffset = bio.i32(data, offset + 20)
    parmSize = arrayutil.makeEmptyArray(8)
    p = 0
    while p < 8
      parmSize[p] = bio.u8(data, offset + 28 + p)
      p = p + 1
    end while
    functions[i] = t.QuakeCFunction(
      bio.i32(data, offset),
      bio.i32(data, offset + 4),
      bio.i32(data, offset + 8),
      bio.i32(data, offset + 12),
      stringAt(strings, nameOffset),
      stringAt(strings, fileOffset),
      bio.i32(data, offset + 24),
      parmSize,
    )
    i = i + 1
  end while

  globals = arrayutil.makeEmptyArray(globalsCount)
  i = 0
  while i < globalsCount
    globals[i] = bio.u32(data, globalsOffset + i * 4)
    i = i + 1
  end while

  return t.QuakeCProgram(filename, data, version, crc, statements, globalDefs, fieldDefs, functions, strings, globals, entityFields)
end function

function load(filename)
  data = fs.readAllBytes(filename)
  return parse(data, filename)
end function
