/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang implementation of miniquake.format.progs.
*/
package miniquake.format.progs

import miniquake.types as t
import miniquake.constants as c
import miniquake.byteio as bio
import miniquake.array_util as arrayutil
import miniquake.protocol_text as protocolText
import miniquake.crc as crc16
import std.fs as fs

// Provide string at behavior for the active subsystem.
function stringAt(strings, offset)
  if offset < 0 or offset >= len(strings) then return "" end if
  endOffset = offset
  while endOffset < len(strings) and strings[endOffset] != 0
    endOffset = endOffset + 1
  end while
  return protocolText.decodeBytes(slice(strings, offset, endOffset - offset))
end function

// Return type size derived from the active module state.
function typeSize(valueType)
  baseType = valueType & 0x7fff
  if baseType == c.EV_VECTOR then return 3 end if
  return 1
end function

// Report whether valid type.
function validType(valueType)
  baseType = valueType & 0x7fff
  return baseType >= c.EV_VOID and baseType <= c.EV_POINTER
end function

// Validate definition and report any incompatibility.
function validateDefinition(definition, limit, sectionName)
  if not validType(definition.type) then
    return error(1910, "progs.dat " + sectionName + " has invalid type " + (definition.type & 0x7fff))
  end if
  if definition.offset < 0 or definition.offset + typeSize(definition.type) > limit then
    return error(1911, "progs.dat " + sectionName + " offset outside storage: " + definition.name)
  end if
  return true
end function

// Validate loadable program and report any incompatibility.
function validateLoadableProgram(program)
  // PR_LoadProgs performs only the loader-level checks that protect the
  // on-disk layout consumed by the engine.  Keep deeper diagnostics in the
  // explicit validateProgram audit so valid stock/mod qcc output is not
  // rejected during normal loading.
  if len(program.strings) <= 0 or program.strings[0] != 0 then
    return error(1912, program.filename + ": progs.dat string table does not begin with NUL")
  end if
  if program.entityFields <= 0 then
    return error(1913, program.filename + ": progs.dat entity field count is invalid")
  end if
  for each definition in program.fieldDefs
    if (definition.type & c.DEF_SAVEGLOBAL) != 0 then
      return error(1915, program.filename + ": field definition uses DEF_SAVEGLOBAL: " + definition.name)
    end if
  end for
  return true
end function

// Validate program and report any incompatibility.
function validateProgram(program)
  loadable = try(validateLoadableProgram(program))
  if loadable is error then return loadable end if

  index = 0
  while index < len(program.statements)
    statement = program.statements[index]
    if statement.op < 0 or statement.op > 65 then
      return error(1914, program.filename + ": invalid QuakeC opcode " + statement.op + " at statement " + index)
    end if
    index = index + 1
  end while

  for each definition in program.globalDefs
    checked = try(validateDefinition(definition, len(program.globals), "global definition"))
    if checked is error then return checked end if
  end for
  for each definition in program.fieldDefs
    checked = try(validateDefinition(definition, program.entityFields, "field definition"))
    if checked is error then return checked end if
  end for

  index = 0
  while index < len(program.functions)
    fn = program.functions[index]
    if fn.numParms < 0 or fn.numParms > c.QC_MAX_PARMS then
      return error(1916, program.filename + ": invalid parameter count in function " + fn.name)
    end if
    if fn.parmStart < 0 or fn.locals < 0 or fn.parmStart + fn.locals > len(program.globals) then
      return error(1917, program.filename + ": local storage outside globals in function " + fn.name)
    end if
    if fn.firstStatement >= len(program.statements) then
      return error(1918, program.filename + ": first statement outside program in function " + fn.name)
    end if
    executableBytecode = fn.firstStatement > 0 or (fn.firstStatement == 0 and (fn.parmStart != 0 or fn.locals != 0))
    parameterWords = 0
    parameter = 0
    while parameter < fn.numParms
      size = fn.parmSize[parameter]
      // dfunction_t carries one uniform parm_size array for bytecode and
      // builtin/import declarations. Stock qcc leaves sizes zero for both
      // negative builtin entries and zero-statement extension stubs (for
      // example makevectors/ex_bprint in rerelease progs.dat). Neither enters
      // PR_EnterFunction. Validate 1/3-word destinations only when the record
      // has a bytecode entry point or owns local/parameter storage.
      if executableBytecode and size != 1 and size != 3 then
        return error(1919, program.filename + ": invalid parameter size in function " + fn.name)
      end if
      if executableBytecode then parameterWords = parameterWords + size end if
      parameter = parameter + 1
    end while

    // qcc's dfunction_t.locals counts only the words that PR_EnterFunction
    // saves/restores.  Parameters are copied independently to parmStart, so a
    // bytecode function may legitimately declare parameters while locals is
    // zero (for example stock SUB_AttackFinished).  Audit the actual parameter
    // destination rather than imposing the false parameterWords <= locals rule.
    if executableBytecode and fn.parmStart + parameterWords > len(program.globals) then
      return error(1920, program.filename + ": parameter storage outside globals in function " + fn.name)
    end if
    index = index + 1
  end while
  return true
end function

// Return runtime crc derived from the active module state.
function runtimeCrc(program)
  if program is void then return 0 end if
  if typeof(program.data) != "bytes" or len(program.data) == 0 then return program.crc end if
  return crc16.CRC_Block(program.data, 0, len(program.data))
end function

// Validate section and report any incompatibility.
function checkSection(data, offset, count, stride, name)
  if offset < 0 or count < 0 or offset + count * stride > len(data) then return error(1900, "progs.dat section outside file: " + name) end if
  return true
end function

// Read and validate the requested value.
function parse(data, filename)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
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

  sectionCheck = checkSection(data, statementOffset, statementCount, 8, "statements")
  if sectionCheck is error then return sectionCheck end if
  sectionCheck = checkSection(data, globalDefOffset, globalDefCount, 8, "globaldefs")
  if sectionCheck is error then return sectionCheck end if
  sectionCheck = checkSection(data, fieldDefOffset, fieldDefCount, 8, "fielddefs")
  if sectionCheck is error then return sectionCheck end if
  sectionCheck = checkSection(data, functionOffset, functionCount, 36, "functions")
  if sectionCheck is error then return sectionCheck end if
  sectionCheck = checkSection(data, stringOffset, stringCount, 1, "strings")
  if sectionCheck is error then return sectionCheck end if
  sectionCheck = checkSection(data, globalsOffset, globalsCount, 4, "globals")
  if sectionCheck is error then return sectionCheck end if

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
    parmSize = arrayutil.makeEmptyArray(c.QC_MAX_PARMS)
    p = 0
    while p < c.QC_MAX_PARMS
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

  program = t.QuakeCProgram(filename, data, version, crc, statements, globalDefs, fieldDefs, functions, strings, globals, entityFields)
  validation = try(validateLoadableProgram(program))
  if validation is error then return validation end if
  return program
end function

// Read and validate the requested value.
function load(filename)
  data = fs.readAllBytes(filename)
  return parse(data, filename)
end function
