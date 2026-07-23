package miniquake.quakec.vm

import miniquake.types as t
import miniquake.native as native
import miniquake.quakec.opcodes as op
import miniquake.byteio as bio
import miniquake.array_util as arrayutil

function zeroArray(count)
  return arrayutil.makeFilledArray(count, 0)
end function

function copyProgramWords(source)
  return arrayutil.copyArrayLinear(source)
end function

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
  return t.QuakeCMachine(program, globals, [], 0, 0, 0, edicts, [], 100000, void, edictFree, [], 1)
end function

function ensureGlobal(machine, offset)
  if offset < 0 then return error(2212, "negative QuakeC global offset") end if
  if len(machine.globals) <= offset then
    machine.globals = arrayutil.growArrayTo(machine.globals, offset + 1, 0)
  end if
end function

function word(machine, offset)
  ensureGlobal(machine, offset)
  return machine.globals[offset]
end function

function setWord(machine, offset, value)
  ensureGlobal(machine, offset)
  machine.globals[offset] = value & 0xffffffff
  return value
end function

function globalFloat(machine, offset)
  return native.bitsFloat(word(machine, offset))
end function

function setGlobalFloat(machine, offset, value)
  if value is bool then
    if value then value = 1.0 else value = 0.0 end if
  end if
  setWord(machine, offset, native.floatBits(value))
end function

function returnFloat(machine)
  return globalFloat(machine, op.OFS_RETURN)
end function

function stringValue(machine, rawValue)
  if rawValue >= 0x80000000 then
    dynamicIndex = rawValue - 0x80000000
    if dynamicIndex >= 0 and dynamicIndex < len(machine.dynamicStrings) then return machine.dynamicStrings[dynamicIndex] end if
    return ""
  end if
  if rawValue < 0 or rawValue >= len(machine.program.strings) then return "" end if
  return bio.cString(machine.program.strings, rawValue)
end function

function stringAt(machine, globalOffset)
  return stringValue(machine, word(machine, globalOffset))
end function

function internString(machine, text)
  index = 0
  while index < len(machine.dynamicStrings)
    if machine.dynamicStrings[index] == text then return 0x80000000 + index end if
    index = index + 1
  end while
  machine.dynamicStrings = machine.dynamicStrings + [text]
  return 0x80000000 + len(machine.dynamicStrings) - 1
end function

function setGlobalString(machine, offset, text)
  return setWord(machine, offset, internString(machine, text))
end function

function vector(machine, offset)
  return t.Vec3(globalFloat(machine, offset), globalFloat(machine, offset + 1), globalFloat(machine, offset + 2))
end function

function setVector(machine, offset, value)
  setGlobalFloat(machine, offset, value.x)
  setGlobalFloat(machine, offset + 1, value.y)
  setGlobalFloat(machine, offset + 2, value.z)
end function

function entityField(machine, entityIndex, fieldOffset)
  if entityIndex < 0 or entityIndex >= len(machine.edicts) then return error(2200, "QuakeC entity outside edict table") end if
  fields = machine.edicts[entityIndex]
  if fieldOffset < 0 or fieldOffset >= len(fields) then return error(2201, "QuakeC field outside edict") end if
  return fields[fieldOffset]
end function

function setEntityField(machine, entityIndex, fieldOffset, value)
  if entityIndex < 0 or entityIndex >= len(machine.edicts) then return error(2202, "QuakeC entity outside edict table") end if
  if fieldOffset < 0 or fieldOffset >= len(machine.edicts[entityIndex]) then return error(2203, "QuakeC field outside edict") end if
  machine.edicts[entityIndex][fieldOffset] = value
end function

function pointerEntity(machine, pointer)
  if machine.program.entityFields <= 0 then return 0 end if
  return native.trunc(pointer / machine.program.entityFields)
end function

function pointerField(machine, pointer)
  if machine.program.entityFields <= 0 then return 0 end if
  return pointer % machine.program.entityFields
end function

function saveLocals(machine, functionValue)
  saved = arrayutil.makeEmptyArray(functionValue.locals)
  i = 0
  while i < functionValue.locals
    saved[i] = word(machine, functionValue.parmStart + i)
    i = i + 1
  end while
  return saved
end function

function enterFunction(machine, functionIndex)
  if functionIndex <= 0 or functionIndex >= len(machine.program.functions) then return error(2204, "bad QuakeC function index " + functionIndex) end if
  functionValue = machine.program.functions[functionIndex]
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

function popArray(values)
  if len(values) <= 1 then return [] end if
  return arrayutil.copyArrayPrefix(values, len(values) - 1)
end function

function leaveFunction(machine)
  if len(machine.callStack) == 0 then return false end if
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

function callBuiltin(machine, builtinIndex)
  index = -builtinIndex
  if index < 0 or index >= len(machine.builtins) then return error(2205, "missing QuakeC builtin " + index) end if
  return machine.builtins[index](machine)
end function

function floatTruth(value)
  return value != 0.0
end function


function definitionOffset(definitions, name)
  wanted = bio.lower(name)
  for each definition in definitions
    if bio.lower(definition.name) == wanted then return definition.offset end if
  end for
  return -1
end function

function namedGlobalWord(machine, name)
  offset = definitionOffset(machine.program.globalDefs, name)
  if offset < 0 then return 0 end if
  return word(machine, offset)
end function

function namedGlobalFloat(machine, name)
  offset = definitionOffset(machine.program.globalDefs, name)
  if offset < 0 then return 0.0 end if
  return globalFloat(machine, offset)
end function

function namedFieldOffset(machine, name)
  return definitionOffset(machine.program.fieldDefs, name)
end function

function executeState(machine, frameOffset, thinkOffset)
  selfIndex = namedGlobalWord(machine, "self")
  if selfIndex < 0 or selfIndex >= len(machine.edicts) then return error(2210, "OP_STATE: self is outside edict table") end if
  nextThinkField = namedFieldOffset(machine, "nextthink")
  frameField = namedFieldOffset(machine, "frame")
  thinkField = namedFieldOffset(machine, "think")
  if nextThinkField < 0 or frameField < 0 or thinkField < 0 then return error(2211, "OP_STATE: required generated field is missing") end if
  setEntityField(machine, selfIndex, nextThinkField, native.floatBits(namedGlobalFloat(machine, "time") + 0.1))
  setEntityField(machine, selfIndex, frameField, word(machine, frameOffset))
  setEntityField(machine, selfIndex, thinkField, word(machine, thinkOffset))
  return true
end function

function execute(machine, functionIndex)
  machine.callStack = []
  machine.currentFunction = 0
  machine.statement = 0
  enterFunction(machine, functionIndex)
  running = true
  steps = 0
  while running
    if steps >= machine.runaway then return error(2206, "QuakeC runaway loop") end if
    if machine.statement < 0 or machine.statement >= len(machine.program.statements) then return error(2207, "QuakeC statement outside program") end if
    statement = machine.program.statements[machine.statement]
    machine.statement = machine.statement + 1
    steps = steps + 1
    code = statement.op

    if code == op.OP_DONE or code == op.OP_RETURN then
      setWord(machine, op.OFS_RETURN, word(machine, statement.a))
      setWord(machine, op.OFS_RETURN + 1, word(machine, statement.a + 1))
      setWord(machine, op.OFS_RETURN + 2, word(machine, statement.a + 2))
      machine.returnWord = word(machine, op.OFS_RETURN)
      if len(machine.callStack) <= 1 then
        machine.callStack = []
        running = false
      else
        leaveFunction(machine)
      end if
    else if code == op.OP_MUL_F then
      setGlobalFloat(machine, statement.c, globalFloat(machine, statement.a) * globalFloat(machine, statement.b))
    else if code == op.OP_MUL_V then
      a = vector(machine, statement.a)
      b = vector(machine, statement.b)
      setGlobalFloat(machine, statement.c, a.x * b.x + a.y * b.y + a.z * b.z)
    else if code == op.OP_MUL_FV then
      scalar = globalFloat(machine, statement.a)
      value = vector(machine, statement.b)
      setVector(machine, statement.c, t.Vec3(scalar * value.x, scalar * value.y, scalar * value.z))
    else if code == op.OP_MUL_VF then
      value = vector(machine, statement.a)
      scalar = globalFloat(machine, statement.b)
      setVector(machine, statement.c, t.Vec3(value.x * scalar, value.y * scalar, value.z * scalar))
    else if code == op.OP_DIV_F then
      setGlobalFloat(machine, statement.c, globalFloat(machine, statement.a) / globalFloat(machine, statement.b))
    else if code == op.OP_ADD_F then
      setGlobalFloat(machine, statement.c, globalFloat(machine, statement.a) + globalFloat(machine, statement.b))
    else if code == op.OP_ADD_V then
      a = vector(machine, statement.a)
      b = vector(machine, statement.b)
      setVector(machine, statement.c, t.Vec3(a.x + b.x, a.y + b.y, a.z + b.z))
    else if code == op.OP_SUB_F then
      setGlobalFloat(machine, statement.c, globalFloat(machine, statement.a) - globalFloat(machine, statement.b))
    else if code == op.OP_SUB_V then
      a = vector(machine, statement.a)
      b = vector(machine, statement.b)
      setVector(machine, statement.c, t.Vec3(a.x - b.x, a.y - b.y, a.z - b.z))
    else if code == op.OP_EQ_F then
      setGlobalFloat(machine, statement.c, globalFloat(machine, statement.a) == globalFloat(machine, statement.b))
    else if code == op.OP_EQ_V then
      a = vector(machine, statement.a)
      b = vector(machine, statement.b)
      setGlobalFloat(machine, statement.c, a.x == b.x and a.y == b.y and a.z == b.z)
    else if code == op.OP_EQ_S then
      setGlobalFloat(machine, statement.c, stringAt(machine, statement.a) == stringAt(machine, statement.b))
    else if code == op.OP_EQ_E or code == op.OP_EQ_FNC then
      setGlobalFloat(machine, statement.c, word(machine, statement.a) == word(machine, statement.b))
    else if code == op.OP_NE_F then
      setGlobalFloat(machine, statement.c, globalFloat(machine, statement.a) != globalFloat(machine, statement.b))
    else if code == op.OP_NE_V then
      a = vector(machine, statement.a)
      b = vector(machine, statement.b)
      setGlobalFloat(machine, statement.c, a.x != b.x or a.y != b.y or a.z != b.z)
    else if code == op.OP_NE_S then
      setGlobalFloat(machine, statement.c, stringAt(machine, statement.a) != stringAt(machine, statement.b))
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
      setWord(machine, statement.c, entityField(machine, entityIndex, fieldOffset))
      if code == op.OP_LOAD_V then
        setWord(machine, statement.c + 1, entityField(machine, entityIndex, fieldOffset + 1))
        setWord(machine, statement.c + 2, entityField(machine, entityIndex, fieldOffset + 2))
      end if
    else if code == op.OP_ADDRESS then
      entityIndex = word(machine, statement.a)
      fieldOffset = word(machine, statement.b)
      setWord(machine, statement.c, entityIndex * machine.program.entityFields + fieldOffset)
    else if code >= op.OP_STORE_F and code <= op.OP_STORE_FNC then
      setWord(machine, statement.b, word(machine, statement.a))
      if code == op.OP_STORE_V then
        setWord(machine, statement.b + 1, word(machine, statement.a + 1))
        setWord(machine, statement.b + 2, word(machine, statement.a + 2))
      end if
    else if code >= op.OP_STOREP_F and code <= op.OP_STOREP_FNC then
      pointer = word(machine, statement.b)
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
      value = vector(machine, statement.a)
      setGlobalFloat(machine, statement.c, value.x == 0.0 and value.y == 0.0 and value.z == 0.0)
    else if code == op.OP_NOT_S then
      setGlobalFloat(machine, statement.c, word(machine, statement.a) == 0 or stringAt(machine, statement.a) == "")
    else if code == op.OP_NOT_ENT or code == op.OP_NOT_FNC then
      setGlobalFloat(machine, statement.c, word(machine, statement.a) == 0)
    else if code == op.OP_IF then
      if floatTruth(globalFloat(machine, statement.a)) then machine.statement = machine.statement + statement.b - 1 end if
    else if code == op.OP_IFNOT then
      if not floatTruth(globalFloat(machine, statement.a)) then machine.statement = machine.statement + statement.b - 1 end if
    else if code >= op.OP_CALL0 and code <= op.OP_CALL8 then
      targetIndex = word(machine, statement.a)
      if targetIndex <= 0 or targetIndex >= len(machine.program.functions) then return error(2208, "bad QuakeC call target") end if
      target = machine.program.functions[targetIndex]
      if target.firstStatement < 0 then
        callBuiltin(machine, target.firstStatement)
      else
        enterFunction(machine, targetIndex)
      end if
    else if code == op.OP_STATE then
      executeState(machine, statement.a, statement.b)
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
      return error(2209, "unsupported QuakeC opcode " + code)
    end if
  end while
  return machine.returnWord
end function

function setContext(machine, context)
  machine.context = context
  return machine
end function

function fieldOffset(machine, name)
  wanted = bio.lower(name)
  for each definition in machine.program.fieldDefs
    if bio.lower(definition.name) == wanted then return definition.offset end if
  end for
  return -1
end function

function globalOffset(machine, name)
  wanted = bio.lower(name)
  for each definition in machine.program.globalDefs
    if bio.lower(definition.name) == wanted then return definition.offset end if
  end for
  return -1
end function

function functionIndex(machine, name)
  wanted = bio.lower(name)
  index = 0
  while index < len(machine.program.functions)
    if bio.lower(machine.program.functions[index].name) == wanted then return index end if
    index = index + 1
  end while
  return 0
end function

function entityFloat(machine, entityIndex, fieldOffsetValue)
  return native.bitsFloat(entityField(machine, entityIndex, fieldOffsetValue))
end function

function setEntityFloat(machine, entityIndex, fieldOffsetValue, value)
  return setEntityField(machine, entityIndex, fieldOffsetValue, native.floatBits(value))
end function

function entityVector(machine, entityIndex, fieldOffsetValue)
  return t.Vec3(
    entityFloat(machine, entityIndex, fieldOffsetValue),
    entityFloat(machine, entityIndex, fieldOffsetValue + 1),
    entityFloat(machine, entityIndex, fieldOffsetValue + 2),
  )
end function

function setEntityVector(machine, entityIndex, fieldOffsetValue, value)
  setEntityFloat(machine, entityIndex, fieldOffsetValue, value.x)
  setEntityFloat(machine, entityIndex, fieldOffsetValue + 1, value.y)
  setEntityFloat(machine, entityIndex, fieldOffsetValue + 2, value.z)
  return value
end function

function entityString(machine, entityIndex, fieldOffsetValue)
  return stringValue(machine, entityField(machine, entityIndex, fieldOffsetValue))
end function

function setEntityString(machine, entityIndex, fieldOffsetValue, text)
  return setEntityField(machine, entityIndex, fieldOffsetValue, internString(machine, text))
end function

function clearEntity(machine, entityIndex)
  if entityIndex < 0 or entityIndex >= len(machine.edicts) then return error(2210, "clearEntity outside edict table") end if
  index = 0
  while index < len(machine.edicts[entityIndex])
    machine.edicts[entityIndex][index] = 0
    index = index + 1
  end while
  return true
end function

function randomFloat(machine)
  machine.randomSeed = (machine.randomSeed * 1103515245 + 12345) & 0x7fffffff
  return (machine.randomSeed & 0xffff) / 65535.0
end function

