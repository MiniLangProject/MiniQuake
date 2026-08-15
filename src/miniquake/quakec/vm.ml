/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.quakec.vm.
*/
package miniquake.quakec.vm

import miniquake.types as t
import miniquake.constants as c
import miniquake.native as native
import miniquake.quakec.opcodes as op
import miniquake.array_util as arrayutil
import miniquake.protocol_text as protocolText

const MAX_STACK_DEPTH = 32
const LOCALSTACK_SIZE = 2048
const TEMP_STRING_HANDLE = 0xffffffff
const LOOKUP_CACHE_SIZE = 512

lookupMachine = void
fieldLookupKeys = array(LOOKUP_CACHE_SIZE)
fieldLookupRawKeys = array(LOOKUP_CACHE_SIZE, 0)
fieldLookupValues = array(LOOKUP_CACHE_SIZE, -2)
globalLookupKeys = array(LOOKUP_CACHE_SIZE)
globalLookupRawKeys = array(LOOKUP_CACHE_SIZE, 0)
globalLookupValues = array(LOOKUP_CACHE_SIZE, -2)
functionLookupKeys = array(LOOKUP_CACHE_SIZE)
functionLookupRawKeys = array(LOOKUP_CACHE_SIZE, 0)
functionLookupValues = array(LOOKUP_CACHE_SIZE, -2)

// Ensure sufficient storage or state for lookup machine.
function ensureLookupMachine(machine)
  global lookupMachine, fieldLookupKeys, fieldLookupRawKeys, fieldLookupValues
  global globalLookupKeys, globalLookupRawKeys, globalLookupValues
  global functionLookupKeys, functionLookupRawKeys, functionLookupValues
  if lookupMachine is not void and nativeRawValue(lookupMachine) == nativeRawValue(machine) then return true end if
  lookupMachine = machine
  // Keep the names themselves rooted.  Caching only a raw heap address would
  // let a later allocation reuse that address after GC and create a false hit.
  fieldLookupKeys = array(LOOKUP_CACHE_SIZE)
  fieldLookupRawKeys = array(LOOKUP_CACHE_SIZE, 0)
  fieldLookupValues = array(LOOKUP_CACHE_SIZE, -2)
  globalLookupKeys = array(LOOKUP_CACHE_SIZE)
  globalLookupRawKeys = array(LOOKUP_CACHE_SIZE, 0)
  globalLookupValues = array(LOOKUP_CACHE_SIZE, -2)
  functionLookupKeys = array(LOOKUP_CACHE_SIZE)
  functionLookupRawKeys = array(LOOKUP_CACHE_SIZE, 0)
  functionLookupValues = array(LOOKUP_CACHE_SIZE, -2)
  return true
end function

// Return slot.
function inline lookupSlot(key)
  return ((key >> 3) ^ (key >> 13) ^ (key >> 23)) & (LOOKUP_CACHE_SIZE - 1)
end function

// Create the zero-initialized state for array.
function zeroArray(count)
  return arrayutil.makeFilledArray(count, 0)
end function

// Transfer data for copy program words.
function copyProgramWords(source)
  return arrayutil.copyArrayLinear(source)
end function

// Create and initialize the module state.
function create(program, maxEdicts)
  globals = copyProgramWords(program.globals)
  edicts = arrayutil.makeEmptyArray(maxEdicts)
  i = 0
  while i < maxEdicts
    edicts[i] = zeroArray(program.entityFields)
    i = i + 1
  end while
  edictFree = arrayutil.makeFilledArray(maxEdicts, true)
  if maxEdicts > 0 then edictFree[0] = false end if
  // pr_exec.c uses fixed pr_stack[MAX_STACK_DEPTH] and localstack arrays.
  // Retain the public dynamic callStack for direct PR_EnterFunction fixtures,
  // while normal PR_ExecuteProgram runs on these allocation-free equivalents.
  return t.QuakeCMachine(
    program, globals, [], 0, 0, 0, 0, edicts, [], 100000, void, edictFree, [], "", 1, false,
    zeroArray(MAX_STACK_DEPTH), zeroArray(MAX_STACK_DEPTH), zeroArray(MAX_STACK_DEPTH),
    zeroArray(MAX_STACK_DEPTH), zeroArray(LOCALSTACK_SIZE), 0, 0, 0,
  )
end function

// Ensure sufficient storage or state for global.
function ensureGlobal(machine, offset)
  if offset < 0 then return error(2212, "negative QuakeC global offset") end if
  if len(machine.globals) <= offset then
    machine.globals = arrayutil.growArrayTo(machine.globals, offset + 1, 0)
  end if
end function

// Provide word behavior for the active subsystem.
function word(machine, offset)
  ensureGlobal(machine, offset)
  return machine.globals[offset]
end function

// Update module state for word.
function setWord(machine, offset, value)
  ensureGlobal(machine, offset)
  machine.globals[offset] = value & 0xffffffff
  return value
end function

// Provide global float behavior for the active subsystem.
function globalFloat(machine, offset)
  return native.bitsFloat(word(machine, offset))
end function

// Update module state for global float.
function setGlobalFloat(machine, offset, value)
  if value is bool then
    if value then value = 1.0 else value = 0.0 end if
  end if
  setWord(machine, offset, native.floatBits(value))
end function

// Provide return float behavior for the active subsystem.
function returnFloat(machine)
  return globalFloat(machine, op.OFS_RETURN)
end function

// Return string value derived from the active module state.
function stringValue(machine, rawValue)
  if rawValue == TEMP_STRING_HANDLE then return machine.temporaryString end if
  if rawValue >= 0x80000000 then
    dynamicIndex = rawValue - 0x80000000
    if dynamicIndex >= 0 and dynamicIndex < len(machine.dynamicStrings) then return machine.dynamicStrings[dynamicIndex] end if
    return ""
  end if
  if rawValue < 0 or rawValue >= len(machine.program.strings) then return "" end if
  endOffset = rawValue
  while endOffset < len(machine.program.strings) and machine.program.strings[endOffset] != 0
    endOffset = endOffset + 1
  end while
  return protocolText.decodeBytes(slice(machine.program.strings, rawValue, endOffset - rawValue))
end function

// Report whether canonical string.
function canonicalString(text)
  encoded = protocolText.encodeBytes(text)
  return protocolText.decodeBytes(encoded)
end function

// Provide string at behavior for the active subsystem.
function stringAt(machine, globalOffset)
  return stringValue(machine, word(machine, globalOffset))
end function

// Provide intern string behavior for the active subsystem.
function internString(machine, text)
  text = canonicalString(text)
  index = 0
  while index < len(machine.dynamicStrings)
    if machine.dynamicStrings[index] == text then return 0x80000000 + index end if
    index = index + 1
  end while
  machine.dynamicStrings = machine.dynamicStrings + [text]
  return 0x80000000 + len(machine.dynamicStrings) - 1
end function

// Update module state for temporary string.
function setTemporaryString(machine, text)
  machine.temporaryString = canonicalString(text)
  return TEMP_STRING_HANDLE
end function

// Update module state for global string.
function setGlobalString(machine, offset, text)
  return setWord(machine, offset, internString(machine, text))
end function

// Return vector derived from the active module state.
function vector(machine, offset)
  return t.Vec3(globalFloat(machine, offset), globalFloat(machine, offset + 1), globalFloat(machine, offset + 2))
end function

// Update module state for vector.
function setVector(machine, offset, value)
  setGlobalFloat(machine, offset, value.x)
  setGlobalFloat(machine, offset + 1, value.y)
  setGlobalFloat(machine, offset + 2, value.z)
end function

// Provide entity field behavior for the active subsystem.
function entityField(machine, entityIndex, fieldOffset)
  if entityIndex < 0 or entityIndex >= len(machine.edicts) then return error(2200, "QuakeC entity outside edict table") end if
  fields = machine.edicts[entityIndex]
  if fieldOffset < 0 or fieldOffset >= len(fields) then return error(2201, "QuakeC field outside edict") end if
  return fields[fieldOffset]
end function

// Update module state for entity field.
function setEntityField(machine, entityIndex, fieldOffset, value)
  if entityIndex < 0 or entityIndex >= len(machine.edicts) then return error(2202, "QuakeC entity outside edict table") end if
  if fieldOffset < 0 or fieldOffset >= len(machine.edicts[entityIndex]) then return error(2203, "QuakeC field outside edict") end if
  machine.edicts[entityIndex][fieldOffset] = value
end function

// Provide pointer entity behavior for the active subsystem.
function pointerEntity(machine, pointer)
  if machine.program.entityFields <= 0 then return 0 end if
  return native.trunc(pointer / machine.program.entityFields)
end function

// Provide pointer field behavior for the active subsystem.
function pointerField(machine, pointer)
  if machine.program.entityFields <= 0 then return 0 end if
  return pointer % machine.program.entityFields
end function

// Validate pointer and report any incompatibility.
function validatePointer(machine, pointer, wordCount)
  if machine.program.entityFields <= 0 then return error(2218, "QuakeC pointer uses an empty edict layout") end if
  totalWords = len(machine.edicts) * machine.program.entityFields
  if pointer < 0 or wordCount <= 0 or pointer >= totalWords or pointer + wordCount > totalWords then
    return error(2219, "QuakeC pointer outside edict storage")
  end if
  fieldOffset = pointerField(machine, pointer)
  if fieldOffset + wordCount > machine.program.entityFields then
    return error(2220, "QuakeC pointer crosses an edict boundary")
  end if
  return true
end function

// Encode and write locals.
function saveLocals(machine, functionValue)
  saved = arrayutil.makeEmptyArray(functionValue.locals)
  i = 0
  while i < functionValue.locals
    saved[i] = word(machine, functionValue.parmStart + i)
    i = i + 1
  end while
  return saved
end function

// Encode and write d local count.
function savedLocalCount(machine)
  if machine.fastExecutionDepth > 0 then return machine.fastLocalDepth end if
  count = 0
  for each frame in machine.callStack
    count = count + len(frame.savedLocals)
  end for
  return count
end function

// Enter a QuakeC function using the original fixed execution and locals
// stacks. Sources are saved before parameters overwrite a callee's locals.
function fastEnterFunction(machine, functionIndex)
  if functionIndex <= 0 or functionIndex >= len(machine.program.functions) then return error(2204, "bad QuakeC function index " + functionIndex) end if
  functionValue = machine.program.functions[functionIndex]
  if machine.fastDepth + 1 >= MAX_STACK_DEPTH then return error(2214, "QuakeC stack overflow") end if
  if machine.fastLocalDepth + functionValue.locals > LOCALSTACK_SIZE then return error(2215, "QuakeC locals stack overflow") end if

  slot = machine.fastDepth
  machine.fastStatements[slot] = machine.statement
  machine.fastFunctions[slot] = machine.currentFunction
  machine.fastLocalBases[slot] = machine.fastLocalDepth
  machine.fastLocalCounts[slot] = functionValue.locals
  i = 0
  while i < functionValue.locals
    machine.fastSavedLocals[machine.fastLocalDepth + i] = word(machine, functionValue.parmStart + i)
    i = i + 1
  end while
  machine.fastLocalDepth = machine.fastLocalDepth + functionValue.locals
  machine.fastDepth = slot + 1

  destination = functionValue.parmStart
  parameter = 0
  while parameter < functionValue.numParms
    size = functionValue.parmSize[parameter]
    component = 0
    while component < size
      setWord(machine, destination, word(machine, op.OFS_PARM0 + parameter * 3 + component))
      destination = destination + 1
      component = component + 1
    end while
    parameter = parameter + 1
  end while
  machine.currentFunction = functionIndex
  machine.statement = functionValue.firstStatement
  return true
end function

// Provide enter function behavior for the active subsystem.
function enterFunction(machine, functionIndex)
  if machine.fastExecutionDepth > 0 then return fastEnterFunction(machine, functionIndex) end if
  if functionIndex <= 0 or functionIndex >= len(machine.program.functions) then return error(2204, "bad QuakeC function index " + functionIndex) end if
  functionValue = machine.program.functions[functionIndex]
  // PR_EnterFunction increments pr_depth before checking MAX_STACK_DEPTH, so
  // depths 1..31 are usable and depth 32 is the original overflow boundary.
  if len(machine.callStack) + 1 >= MAX_STACK_DEPTH then return error(2214, "QuakeC stack overflow") end if
  if savedLocalCount(machine) + functionValue.locals > LOCALSTACK_SIZE then
    return error(2215, "QuakeC locals stack overflow")
  end if
  frame = t.QuakeCCallFrame(machine.statement, machine.currentFunction, saveLocals(machine, functionValue))
  machine.callStack = machine.callStack + [frame]
  destination = functionValue.parmStart
  parameter = 0
  while parameter < functionValue.numParms
    size = functionValue.parmSize[parameter]
    component = 0
    while component < size
      setWord(machine, destination, word(machine, op.OFS_PARM0 + parameter * 3 + component))
      destination = destination + 1
      component = component + 1
    end while
    parameter = parameter + 1
  end while
  machine.currentFunction = functionIndex
  machine.statement = functionValue.firstStatement
end function

// Consume pending state for pop array.
function popArray(values)
  if len(values) <= 1 then return [] end if
  return arrayutil.copyArrayPrefix(values, len(values) - 1)
end function

// Provide leave function behavior for the active subsystem.
function leaveFunction(machine)
  if machine.fastExecutionDepth > 0 then
    if machine.fastDepth == 0 then return error(2217, "prog stack underflow") end if
    slot = machine.fastDepth - 1
    functionValue = machine.program.functions[machine.currentFunction]
    base = machine.fastLocalBases[slot]
    count = machine.fastLocalCounts[slot]
    i = 0
    while i < functionValue.locals and i < count
      setWord(machine, functionValue.parmStart + i, machine.fastSavedLocals[base + i])
      i = i + 1
    end while
    machine.fastLocalDepth = base
    machine.fastDepth = slot
    machine.statement = machine.fastStatements[slot]
    machine.currentFunction = machine.fastFunctions[slot]
    return true
  end if
  if len(machine.callStack) == 0 then return error(2217, "prog stack underflow") end if
  frame = machine.callStack[len(machine.callStack) - 1]
  functionValue = machine.program.functions[machine.currentFunction]
  i = 0
  while i < functionValue.locals and i < len(frame.savedLocals)
    setWord(machine, functionValue.parmStart + i, frame.savedLocals[i])
    i = i + 1
  end while
  machine.callStack = popArray(machine.callStack)
  machine.statement = frame.statement
  machine.currentFunction = frame.functionIndex
  return true
end function

// Provide call builtin behavior for the active subsystem.
function callBuiltin(machine, builtinIndex)
  index = -builtinIndex
  if index < 0 or index >= len(machine.builtins) then return error(2205, "missing QuakeC builtin " + index) end if
  return machine.builtins[index](machine)
end function

// Return opcode name derived from the active module state.
function opcodeName(code)
  names = [
    "DONE", "MUL_F", "MUL_V", "MUL_FV", "MUL_VF", "DIV_F",
    "ADD_F", "ADD_V", "SUB_F", "SUB_V", "EQ_F", "EQ_V", "EQ_S",
    "EQ_E", "EQ_FNC", "NE_F", "NE_V", "NE_S", "NE_E", "NE_FNC",
    "LE", "GE", "LT", "GT", "LOAD_F", "LOAD_V", "LOAD_S",
    "LOAD_ENT", "LOAD_FLD", "LOAD_FNC", "ADDRESS", "STORE_F",
    "STORE_V", "STORE_S", "STORE_ENT", "STORE_FLD", "STORE_FNC",
    "STOREP_F", "STOREP_V", "STOREP_S", "STOREP_ENT", "STOREP_FLD",
    "STOREP_FNC", "RETURN", "NOT_F", "NOT_V", "NOT_S", "NOT_ENT",
    "NOT_FNC", "IF", "IFNOT", "CALL0", "CALL1", "CALL2", "CALL3",
    "CALL4", "CALL5", "CALL6", "CALL7", "CALL8", "STATE", "GOTO",
    "AND", "OR", "BITAND", "BITOR",
  ]
  if code < 0 or code >= len(names) then return "BAD_OPCODE_" + code end if
  return names[code]
end function

// Provide debug floor behavior for the active subsystem.
function debugFloor(value)
  truncated = native.trunc(value)
  if value < truncated then return truncated - 1 end if
  return truncated
end function

// Provide debug ceil behavior for the active subsystem.
function debugCeil(value)
  truncated = native.trunc(value)
  if value > truncated then return truncated + 1 end if
  return truncated
end function

// Provide debug one decimal behavior for the active subsystem.
function debugOneDecimal(value)
  scaled = 0
  if value >= 0.0 then scaled = debugFloor(value * 10.0 + 0.5) else scaled = debugCeil(value * 10.0 - 0.5) end if
  negative = scaled < 0
  if negative then scaled = -scaled end if
  text = "" + native.trunc(scaled / 10) + "." + (scaled % 10)
  if negative then text = "-" + text end if
  while len(bytes(text)) < 5
    text = " " + text
  end while
  return text
end function

// Return definition at offset derived from the active module state.
function definitionAtOffset(definitions, offset)
  for each definition in definitions
    if definition.offset == offset then return definition end if
  end for
  return void
end function

// Provide debug value string behavior for the active subsystem.
function debugValueString(machine, definition, offset)
  valueType = definition.type & 0x7fff
  if valueType == c.EV_STRING then return stringAt(machine, offset) end if
  if valueType == c.EV_ENTITY then return "entity " + word(machine, offset) end if
  if valueType == c.EV_FUNCTION then
    index = word(machine, offset)
    if index < 0 or index >= len(machine.program.functions) then return "" end if
    return machine.program.functions[index].name + "()"
  end if
  if valueType == c.EV_FIELD then
    field = definitionAtOffset(machine.program.fieldDefs, word(machine, offset))
    if field is void then return "" end if
    return "." + field.name
  end if
  if valueType == c.EV_VOID then return "void" end if
  if valueType == c.EV_FLOAT then return debugOneDecimal(globalFloat(machine, offset)) end if
  if valueType == c.EV_VECTOR then
    value = vector(machine, offset)
    return "'" + debugOneDecimal(value.x) + " " + debugOneDecimal(value.y) + " " + debugOneDecimal(value.z) + "'"
  end if
  if valueType == c.EV_POINTER then return "pointer" end if
  return "bad type " + valueType
end function

// Provide debug global string behavior for the active subsystem.
function debugGlobalString(machine, offset, includeContents)
  definition = definitionAtOffset(machine.program.globalDefs, offset)
  text = ""
  if definition is void then
    text = offset + "(???)"
  else
    text = offset + "(" + definition.name + ")"
    if includeContents then text = text + debugValueString(machine, definition, offset) end if
  end if
  while len(bytes(text)) < 20
    text = text + " "
  end while
  return text + " "
end function

// Format and emit statement.
function printStatement(machine, statementValue)
  text = ""
  codeName = opcodeName(statementValue.op)
  if statementValue.op >= 0 and statementValue.op <= op.OP_BITOR then
    text = codeName + " "
    padding = len(bytes(codeName))
    while padding < 10
      text = text + " "
      padding = padding + 1
    end while
  end if
  if statementValue.op == op.OP_IF or statementValue.op == op.OP_IFNOT then
    return text + debugGlobalString(machine, statementValue.a, true) + "branch " + statementValue.b
  end if
  if statementValue.op == op.OP_GOTO then return text + "branch " + statementValue.a end if
  if statementValue.op >= op.OP_STORE_F and statementValue.op <= op.OP_STORE_FNC then
    return text + debugGlobalString(machine, statementValue.a, true) +
      debugGlobalString(machine, statementValue.b, false)
  end if
  if statementValue.a != 0 then text = text + debugGlobalString(machine, statementValue.a, true) end if
  if statementValue.b != 0 then text = text + debugGlobalString(machine, statementValue.b, true) end if
  if statementValue.c != 0 then text = text + debugGlobalString(machine, statementValue.c, false) end if
  return text
end function

// Provide stack line behavior for the active subsystem.
function stackLine(functionValue)
  fileName = functionValue.file
  while len(bytes(fileName)) < 12
    fileName = " " + fileName
  end while
  return fileName + " : " + functionValue.name
end function

// Provide stack trace behavior for the active subsystem.
function stackTrace(machine)
  lines = []
  if machine.fastExecutionDepth > 0 then
    if machine.fastDepth == 0 then return ["<NO STACK>"] end if
    index = machine.fastDepth - 1
    current = machine.currentFunction
    while index >= 0
      if current <= 0 or current >= len(machine.program.functions) then
        lines = lines + ["<NO FUNCTION>"]
      else
        lines = lines + [stackLine(machine.program.functions[current])]
      end if
      current = machine.fastFunctions[index]
      index = index - 1
    end while
    if current <= 0 or current >= len(machine.program.functions) then
      lines = lines + ["<NO FUNCTION>"]
    else
      lines = lines + [stackLine(machine.program.functions[current])]
    end if
    return lines
  end if
  if len(machine.callStack) == 0 then return ["<NO STACK>"] end if
  index = len(machine.callStack) - 1
  current = machine.currentFunction
  while index >= 0
    if current <= 0 or current >= len(machine.program.functions) then
      lines = lines + ["<NO FUNCTION>"]
    else
      functionValue = machine.program.functions[current]
      lines = lines + [stackLine(functionValue)]
    end if
    current = machine.callStack[index].functionIndex
    index = index - 1
  end while
  // pr_stack[0] is the frame that existed before the outermost entry.  The
  // original trace includes it (normally as <NO FUNCTION>).
  if current <= 0 or current >= len(machine.program.functions) then
    lines = lines + ["<NO FUNCTION>"]
  else
    lines = lines + [stackLine(machine.program.functions[current])]
  end if
  return lines
end function

// Provide profile report behavior for the active subsystem.
function profileReport(machine)
  lines = []
  emitted = 0
  while true
    bestIndex = -1
    bestValue = 0
    index = 0
    while index < len(machine.program.functions)
      if machine.program.functions[index].profile > bestValue then
        bestValue = machine.program.functions[index].profile
        bestIndex = index
      end if
      index = index + 1
    end while
    if bestIndex < 0 then break end if
    if emitted < 10 then lines = lines + [bestValue + " " + machine.program.functions[bestIndex].name] end if
    functionValue = machine.program.functions[bestIndex]
    functionValue.profile = 0
    machine.program.functions[bestIndex] = functionValue
    emitted = emitted + 1
  end while
  return lines
end function

// Execute error.
function runError(machine, message)
  if machine.context is not void then
    statementIndex = machine.statement - 1
    if statementIndex < 0 then statementIndex = 0 end if
    if statementIndex < len(machine.program.statements) then
      machine.context.consoleLines = machine.context.consoleLines + [printStatement(machine, machine.program.statements[statementIndex])]
    end if
    for each line in stackTrace(machine)
      machine.context.consoleLines = machine.context.consoleLines + [line]
    end for
    machine.context.consoleLines = machine.context.consoleLines + [message]
  end if
  machine.callStack = []
  machine.fastDepth = 0
  machine.fastLocalDepth = 0
  machine.fastExecutionDepth = 0
  machine.currentFunction = 0
  return error(2216, "Program error: " + message)
end function

// Provide float truth behavior for the active subsystem.
function inline floatTruth(value)
  return value != 0.0
end function

// Provide string compare behavior for the active subsystem.
function stringCompare(left, right)
  leftBytes = protocolText.encodeBytes(left)
  rightBytes = protocolText.encodeBytes(right)
  count = len(leftBytes)
  if len(rightBytes) < count then count = len(rightBytes) end if
  index = 0
  while index < count
    if leftBytes[index] != rightBytes[index] then return leftBytes[index] - rightBytes[index] end if
    index = index + 1
  end while
  return len(leftBytes) - len(rightBytes)
end function


// Return definition offset derived from the active module state.
function definitionOffset(definitions, name)
  for each definition in definitions
    // ED_FindField/ED_FindGlobal use strcmp.  Treating generated names as
    // case-insensitive accepts entity/save data that MiniQuake rejects.
    if definition.name == name then return definition.offset end if
  end for
  return -1
end function

// Provide named global word behavior for the active subsystem.
function namedGlobalWord(machine, name)
  offset = globalOffset(machine, name)
  if offset < 0 then return 0 end if
  return word(machine, offset)
end function

// Provide named global float behavior for the active subsystem.
function namedGlobalFloat(machine, name)
  offset = globalOffset(machine, name)
  if offset < 0 then return 0.0 end if
  return globalFloat(machine, offset)
end function

// Return named field offset derived from the active module state.
function namedFieldOffset(machine, name)
  return fieldOffset(machine, name)
end function

// Execute state.
function executeState(machine, frameOffset, thinkOffset)
  selfIndex = namedGlobalWord(machine, "self")
  if selfIndex < 0 or selfIndex >= len(machine.edicts) then return error(2210, "OP_STATE: self is outside edict table") end if
  nextThinkField = namedFieldOffset(machine, "nextthink")
  frameField = namedFieldOffset(machine, "frame")
  thinkField = namedFieldOffset(machine, "think")
  if nextThinkField < 0 or frameField < 0 or thinkField < 0 then return error(2211, "OP_STATE: required generated field is missing") end if
  setEntityField(machine, selfIndex, nextThinkField, native.floatBits(namedGlobalFloat(machine, "time") + 0.1))

  // pr_exec.c compares the float values before assigning ed->v.frame.  This is
  // observable for +0/-0: they compare equal, so the existing sign bit stays.
  // NaNs compare unequal and therefore still replace the previous frame word.
  currentFrameWord = entityField(machine, selfIndex, frameField)
  if globalFloat(machine, frameOffset) != native.bitsFloat(currentFrameWord) then
    setEntityField(machine, selfIndex, frameField, word(machine, frameOffset))
  end if
  setEntityField(machine, selfIndex, thinkField, word(machine, thinkOffset))
  return true
end function

// Execute the requested value.
function execute(machine, functionIndex)
  // PR_ExecuteProgram resets the global pr_trace flag at the start of every
  // invocation, including recursive entries made by movement builtins.
  machine.trace = false

  // PR_ExecuteProgram may be entered recursively from builtins such as
  // walkmove/movetogoal when relinking an edict touches a trigger.  The stock
  // VM records the current depth and returns when the nested function has
  // unwound to that depth; it does not discard the caller's execution state.
  // Resetting the shared stack here made the suspended caller resume at the
  // statement following the nested function's DONE opcode.
  machine.fastExecutionDepth = machine.fastExecutionDepth + 1
  exitDepth = machine.fastDepth
  entered = try(enterFunction(machine, functionIndex))
  if entered is error then return runError(machine, entered.message) end if
  running = true
  steps = 0
  while running
    if steps >= machine.runaway then return runError(machine, "runaway loop error") end if
    if machine.statement < 0 or machine.statement >= len(machine.program.statements) then return runError(machine, "statement outside program") end if
    statement = machine.program.statements[machine.statement]
    machine.statement = machine.statement + 1
    steps = steps + 1
    functionValue = machine.program.functions[machine.currentFunction]
    functionValue.profile = functionValue.profile + 1
    machine.program.functions[machine.currentFunction] = functionValue
    code = statement.op
    if machine.trace and machine.context is not void then
      machine.context.consoleLines = machine.context.consoleLines + [printStatement(machine, statement)]
    end if

    if code == op.OP_DONE or code == op.OP_RETURN then
      setWord(machine, op.OFS_RETURN, word(machine, statement.a))
      setWord(machine, op.OFS_RETURN + 1, word(machine, statement.a + 1))
      setWord(machine, op.OFS_RETURN + 2, word(machine, statement.a + 2))
      machine.returnWord = word(machine, op.OFS_RETURN)
      leaveFunction(machine)
      if machine.fastDepth <= exitDepth then
        running = false
      end if
    else if code == op.OP_MUL_F then
      setGlobalFloat(machine, statement.c, globalFloat(machine, statement.a) * globalFloat(machine, statement.b))
    else if code == op.OP_MUL_V then
      ax = globalFloat(machine, statement.a)
      ay = globalFloat(machine, statement.a + 1)
      az = globalFloat(machine, statement.a + 2)
      bx = globalFloat(machine, statement.b)
      by = globalFloat(machine, statement.b + 1)
      bz = globalFloat(machine, statement.b + 2)
      setGlobalFloat(machine, statement.c, ax * bx + ay * by + az * bz)
    else if code == op.OP_MUL_FV then
      scalar = globalFloat(machine, statement.a)
      vx = globalFloat(machine, statement.b)
      vy = globalFloat(machine, statement.b + 1)
      vz = globalFloat(machine, statement.b + 2)
      setGlobalFloat(machine, statement.c, scalar * vx)
      setGlobalFloat(machine, statement.c + 1, scalar * vy)
      setGlobalFloat(machine, statement.c + 2, scalar * vz)
    else if code == op.OP_MUL_VF then
      vx = globalFloat(machine, statement.a)
      vy = globalFloat(machine, statement.a + 1)
      vz = globalFloat(machine, statement.a + 2)
      scalar = globalFloat(machine, statement.b)
      setGlobalFloat(machine, statement.c, vx * scalar)
      setGlobalFloat(machine, statement.c + 1, vy * scalar)
      setGlobalFloat(machine, statement.c + 2, vz * scalar)
    else if code == op.OP_DIV_F then
      setGlobalFloat(machine, statement.c, globalFloat(machine, statement.a) / globalFloat(machine, statement.b))
    else if code == op.OP_ADD_F then
      setGlobalFloat(machine, statement.c, globalFloat(machine, statement.a) + globalFloat(machine, statement.b))
    else if code == op.OP_ADD_V then
      ax = globalFloat(machine, statement.a)
      ay = globalFloat(machine, statement.a + 1)
      az = globalFloat(machine, statement.a + 2)
      bx = globalFloat(machine, statement.b)
      by = globalFloat(machine, statement.b + 1)
      bz = globalFloat(machine, statement.b + 2)
      setGlobalFloat(machine, statement.c, ax + bx)
      setGlobalFloat(machine, statement.c + 1, ay + by)
      setGlobalFloat(machine, statement.c + 2, az + bz)
    else if code == op.OP_SUB_F then
      setGlobalFloat(machine, statement.c, globalFloat(machine, statement.a) - globalFloat(machine, statement.b))
    else if code == op.OP_SUB_V then
      ax = globalFloat(machine, statement.a)
      ay = globalFloat(machine, statement.a + 1)
      az = globalFloat(machine, statement.a + 2)
      bx = globalFloat(machine, statement.b)
      by = globalFloat(machine, statement.b + 1)
      bz = globalFloat(machine, statement.b + 2)
      setGlobalFloat(machine, statement.c, ax - bx)
      setGlobalFloat(machine, statement.c + 1, ay - by)
      setGlobalFloat(machine, statement.c + 2, az - bz)
    else if code == op.OP_EQ_F then
      setGlobalFloat(machine, statement.c, globalFloat(machine, statement.a) == globalFloat(machine, statement.b))
    else if code == op.OP_EQ_V then
      ax = globalFloat(machine, statement.a)
      ay = globalFloat(machine, statement.a + 1)
      az = globalFloat(machine, statement.a + 2)
      bx = globalFloat(machine, statement.b)
      by = globalFloat(machine, statement.b + 1)
      bz = globalFloat(machine, statement.b + 2)
      setGlobalFloat(machine, statement.c, ax == bx and ay == by and az == bz)
    else if code == op.OP_EQ_S then
      setGlobalFloat(machine, statement.c, stringAt(machine, statement.a) == stringAt(machine, statement.b))
    else if code == op.OP_EQ_E or code == op.OP_EQ_FNC then
      setGlobalFloat(machine, statement.c, word(machine, statement.a) == word(machine, statement.b))
    else if code == op.OP_NE_F then
      setGlobalFloat(machine, statement.c, globalFloat(machine, statement.a) != globalFloat(machine, statement.b))
    else if code == op.OP_NE_V then
      ax = globalFloat(machine, statement.a)
      ay = globalFloat(machine, statement.a + 1)
      az = globalFloat(machine, statement.a + 2)
      bx = globalFloat(machine, statement.b)
      by = globalFloat(machine, statement.b + 1)
      bz = globalFloat(machine, statement.b + 2)
      setGlobalFloat(machine, statement.c, ax != bx or ay != by or az != bz)
    else if code == op.OP_NE_S then
      setGlobalFloat(machine, statement.c, stringCompare(stringAt(machine, statement.a), stringAt(machine, statement.b)))
    else if code == op.OP_NE_E or code == op.OP_NE_FNC then
      setGlobalFloat(machine, statement.c, word(machine, statement.a) != word(machine, statement.b))
    else if code == op.OP_LE then
      setGlobalFloat(machine, statement.c, globalFloat(machine, statement.a) <= globalFloat(machine, statement.b))
    else if code == op.OP_GE then
      setGlobalFloat(machine, statement.c, globalFloat(machine, statement.a) >= globalFloat(machine, statement.b))
    else if code == op.OP_LT then
      setGlobalFloat(machine, statement.c, globalFloat(machine, statement.a) < globalFloat(machine, statement.b))
    else if code == op.OP_GT then
      setGlobalFloat(machine, statement.c, globalFloat(machine, statement.a) > globalFloat(machine, statement.b))
    else if code >= op.OP_LOAD_F and code <= op.OP_LOAD_FNC then
      entityIndex = word(machine, statement.a)
      fieldOffset = word(machine, statement.b)
      loaded = try(entityField(machine, entityIndex, fieldOffset))
      if loaded is error then return runError(machine, loaded.message) end if
      setWord(machine, statement.c, loaded)
      if code == op.OP_LOAD_V then
        loadedY = try(entityField(machine, entityIndex, fieldOffset + 1))
        if loadedY is error then return runError(machine, loadedY.message) end if
        loadedZ = try(entityField(machine, entityIndex, fieldOffset + 2))
        if loadedZ is error then return runError(machine, loadedZ.message) end if
        setWord(machine, statement.c + 1, loadedY)
        setWord(machine, statement.c + 2, loadedZ)
      end if
    else if code == op.OP_ADDRESS then
      entityIndex = word(machine, statement.a)
      fieldOffset = word(machine, statement.b)
      if entityIndex < 0 or entityIndex >= len(machine.edicts) then return runError(machine, "QuakeC entity outside edict table") end if
      if fieldOffset < 0 or fieldOffset >= machine.program.entityFields then return runError(machine, "QuakeC field outside edict") end if
      if entityIndex == 0 and machine.context is not void and machine.context.server is not void and machine.context.server.active and not machine.context.server.loading then
        return runError(machine, "assignment to world entity")
      end if
      setWord(machine, statement.c, entityIndex * machine.program.entityFields + fieldOffset)
    else if code >= op.OP_STORE_F and code <= op.OP_STORE_FNC then
      setWord(machine, statement.b, word(machine, statement.a))
      if code == op.OP_STORE_V then
        setWord(machine, statement.b + 1, word(machine, statement.a + 1))
        setWord(machine, statement.b + 2, word(machine, statement.a + 2))
      end if
    else if code >= op.OP_STOREP_F and code <= op.OP_STOREP_FNC then
      pointer = word(machine, statement.b)
      pointerWords = 1
      if code == op.OP_STOREP_V then pointerWords = 3 end if
      pointerCheck = try(validatePointer(machine, pointer, pointerWords))
      if pointerCheck is error then return runError(machine, pointerCheck.message) end if
      entityIndex = pointerEntity(machine, pointer)
      fieldOffset = pointerField(machine, pointer)
      setEntityField(machine, entityIndex, fieldOffset, word(machine, statement.a))
      if code == op.OP_STOREP_V then
        setEntityField(machine, entityIndex, fieldOffset + 1, word(machine, statement.a + 1))
        setEntityField(machine, entityIndex, fieldOffset + 2, word(machine, statement.a + 2))
      end if
    else if code == op.OP_NOT_F then
      setGlobalFloat(machine, statement.c, globalFloat(machine, statement.a) == 0.0)
    else if code == op.OP_NOT_V then
      vx = globalFloat(machine, statement.a)
      vy = globalFloat(machine, statement.a + 1)
      vz = globalFloat(machine, statement.a + 2)
      setGlobalFloat(machine, statement.c, vx == 0.0 and vy == 0.0 and vz == 0.0)
    else if code == op.OP_NOT_S then
      setGlobalFloat(machine, statement.c, word(machine, statement.a) == 0 or stringAt(machine, statement.a) == "")
    else if code == op.OP_NOT_ENT or code == op.OP_NOT_FNC then
      setGlobalFloat(machine, statement.c, word(machine, statement.a) == 0)
    else if code == op.OP_IF then
      if word(machine, statement.a) != 0 then machine.statement = machine.statement + statement.b - 1 end if
    else if code == op.OP_IFNOT then
      if word(machine, statement.a) == 0 then machine.statement = machine.statement + statement.b - 1 end if
    else if code >= op.OP_CALL0 and code <= op.OP_CALL8 then
      machine.argCount = code - op.OP_CALL0
      targetIndex = word(machine, statement.a)
      if targetIndex <= 0 or targetIndex >= len(machine.program.functions) then return runError(machine, "NULL function") end if
      target = machine.program.functions[targetIndex]
      if target.firstStatement < 0 then
        builtinResult = try(callBuiltin(machine, target.firstStatement))
        if builtinResult is error then return runError(machine, builtinResult.message) end if
      else
        entered = try(enterFunction(machine, targetIndex))
        if entered is error then return runError(machine, entered.message) end if
      end if
    else if code == op.OP_STATE then
      stateResult = try(executeState(machine, statement.a, statement.b))
      if stateResult is error then return runError(machine, stateResult.message) end if
    else if code == op.OP_GOTO then
      machine.statement = machine.statement + statement.a - 1
    else if code == op.OP_AND then
      setGlobalFloat(machine, statement.c, floatTruth(globalFloat(machine, statement.a)) and floatTruth(globalFloat(machine, statement.b)))
    else if code == op.OP_OR then
      setGlobalFloat(machine, statement.c, floatTruth(globalFloat(machine, statement.a)) or floatTruth(globalFloat(machine, statement.b)))
    else if code == op.OP_BITAND then
      setGlobalFloat(machine, statement.c, native.trunc(globalFloat(machine, statement.a)) & native.trunc(globalFloat(machine, statement.b)))
    else if code == op.OP_BITOR then
      setGlobalFloat(machine, statement.c, native.trunc(globalFloat(machine, statement.a)) | native.trunc(globalFloat(machine, statement.b)))
    else
      return runError(machine, "Bad opcode " + code)
    end if
  end while
  machine.fastExecutionDepth = machine.fastExecutionDepth - 1
  return machine.returnWord
end function

// Resolve the active PR_ExecuteProgram depth for diagnostics without exposing
// the fixed-stack representation to compatibility fixtures.
function callDepth(machine)
  if machine.fastExecutionDepth > 0 then return machine.fastDepth end if
  return len(machine.callStack)
end function

// Update module state for context.
function setContext(machine, context)
  machine.context = context
  return machine
end function

// Return field offset derived from the active module state.
function fieldOffset(machine, name)
  global fieldLookupKeys, fieldLookupRawKeys, fieldLookupValues
  ensureLookupMachine(machine)
  key = nativeRawValue(name)
  slot = lookupSlot(key)
  if fieldLookupValues[slot] != -2 and fieldLookupKeys[slot] is not void and fieldLookupRawKeys[slot] == key then return fieldLookupValues[slot] end if
  for each definition in machine.program.fieldDefs
    if definition.name == name then
      fieldLookupKeys[slot] = name
      fieldLookupRawKeys[slot] = key
      fieldLookupValues[slot] = definition.offset
      return definition.offset
    end if
  end for
  fieldLookupKeys[slot] = name
  fieldLookupRawKeys[slot] = key
  fieldLookupValues[slot] = -1
  return -1
end function

// Return global offset derived from the active module state.
function globalOffset(machine, name)
  global globalLookupKeys, globalLookupRawKeys, globalLookupValues
  ensureLookupMachine(machine)
  key = nativeRawValue(name)
  slot = lookupSlot(key)
  if globalLookupValues[slot] != -2 and globalLookupKeys[slot] is not void and globalLookupRawKeys[slot] == key then return globalLookupValues[slot] end if
  for each definition in machine.program.globalDefs
    if definition.name == name then
      globalLookupKeys[slot] = name
      globalLookupRawKeys[slot] = key
      globalLookupValues[slot] = definition.offset
      return definition.offset
    end if
  end for
  globalLookupKeys[slot] = name
  globalLookupRawKeys[slot] = key
  globalLookupValues[slot] = -1
  return -1
end function

// Return function index derived from the active module state.
function functionIndex(machine, name)
  global functionLookupKeys, functionLookupRawKeys, functionLookupValues
  ensureLookupMachine(machine)
  key = nativeRawValue(name)
  slot = lookupSlot(key)
  if functionLookupValues[slot] != -2 and functionLookupKeys[slot] is not void and functionLookupRawKeys[slot] == key then return functionLookupValues[slot] end if
  index = 0
  while index < len(machine.program.functions)
    if machine.program.functions[index].name == name then
      functionLookupKeys[slot] = name
      functionLookupRawKeys[slot] = key
      functionLookupValues[slot] = index
      return index
    end if
    index = index + 1
  end while
  functionLookupKeys[slot] = name
  functionLookupRawKeys[slot] = key
  functionLookupValues[slot] = 0
  return 0
end function

// Provide entity float behavior for the active subsystem.
function entityFloat(machine, entityIndex, fieldOffsetValue)
  return native.bitsFloat(entityField(machine, entityIndex, fieldOffsetValue))
end function

// Update module state for entity float.
function setEntityFloat(machine, entityIndex, fieldOffsetValue, value)
  return setEntityField(machine, entityIndex, fieldOffsetValue, native.floatBits(value))
end function

// Return entity vector derived from the active module state.
function entityVector(machine, entityIndex, fieldOffsetValue)
  return t.Vec3(
    entityFloat(machine, entityIndex, fieldOffsetValue),
    entityFloat(machine, entityIndex, fieldOffsetValue + 1),
    entityFloat(machine, entityIndex, fieldOffsetValue + 2),
  )
end function

// Update module state for entity vector.
function setEntityVector(machine, entityIndex, fieldOffsetValue, value)
  setEntityFloat(machine, entityIndex, fieldOffsetValue, value.x)
  setEntityFloat(machine, entityIndex, fieldOffsetValue + 1, value.y)
  setEntityFloat(machine, entityIndex, fieldOffsetValue + 2, value.z)
  return value
end function

// Provide entity string behavior for the active subsystem.
function entityString(machine, entityIndex, fieldOffsetValue)
  return stringValue(machine, entityField(machine, entityIndex, fieldOffsetValue))
end function

// Update module state for entity string.
function setEntityString(machine, entityIndex, fieldOffsetValue, text)
  return setEntityField(machine, entityIndex, fieldOffsetValue, internString(machine, text))
end function

// Update module state for entity.
function clearEntity(machine, entityIndex)
  if entityIndex < 0 or entityIndex >= len(machine.edicts) then return error(2210, "clearEntity outside edict table") end if
  index = 0
  while index < len(machine.edicts[entityIndex])
    machine.edicts[entityIndex][index] = 0
    index = index + 1
  end while
  return true
end function

// Provide random float behavior for the active subsystem.
function randomFloat(machine)
  machine.randomSeed = (machine.randomSeed * 214013 + 2531011) & 0xffffffff
  return ((machine.randomSeed >> 16) & 0x7fff) / 32767.0
end function

// Names matching the MiniQuake entry points keep the source-to-port mapping
// explicit while the lower-camel functions remain the idiomatic MiniLang API.
function PR_PrintStatement(machine, statementValue)
  return printStatement(machine, statementValue)
end function

// Mirror Quake's PR_StackTrace routine and its observable state changes.
function PR_StackTrace(machine)
  return stackTrace(machine)
end function

// Mirror Quake's PR_Profile_f routine and its observable state changes.
function PR_Profile_f(machine)
  return profileReport(machine)
end function

// Mirror Quake's PR_RunError routine and its observable state changes.
function PR_RunError(machine, message)
  return runError(machine, message)
end function

// Mirror Quake's PR_EnterFunction routine and its observable state changes.
function PR_EnterFunction(machine, functionIndexValue)
  return enterFunction(machine, functionIndexValue)
end function

// Mirror Quake's PR_LeaveFunction routine and its observable state changes.
function PR_LeaveFunction(machine)
  return leaveFunction(machine)
end function

// Mirror Quake's PR_ExecuteProgram routine and its observable state changes.
function PR_ExecuteProgram(machine, functionIndexValue)
  return execute(machine, functionIndexValue)
end function
