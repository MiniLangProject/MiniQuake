package miniquake.black_port_corpus

const SCHEMA_VERSION = 1
const FRAMES_PER_SCENARIO = 64
const SCENARIO_COUNT = 4

function scenarios()
  return [
    ["start-064", "start", 64],
    ["e1m1-064", "e1m1", 64],
    ["e1m2-064", "e1m2", 64],
    ["e1m3-064", "e1m3", 64],
  ]
end function

function scenarioAt(index)
  values = scenarios()
  if index < 0 or index >= len(values) then return error(8400, "black-port corpus scenario index out of range") end if
  return values[index]
end function

function validate()
  values = scenarios()
  if SCHEMA_VERSION != 1 or len(values) != SCENARIO_COUNT then return false end if
  index = 0
  while index < len(values)
    item = values[index]
    if len(item) != 3 then return false end if
    if item[2] != FRAMES_PER_SCENARIO then return false end if
    index = index + 1
  end while
  return true
end function
