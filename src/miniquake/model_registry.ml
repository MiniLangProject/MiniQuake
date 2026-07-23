package miniquake.model_registry

import miniquake.types as t
import miniquake.byteio as bio

function create()
  return t.ModelRegistry([], [])
end function

function findIndex(registry, name)
  wanted = bio.lower(name)
  i = 0
  while i < len(registry.names)
    if bio.lower(registry.names[i]) == wanted then return i end if
    i = i + 1
  end while
  return -1
end function

function register(registry, name, model)
  index = findIndex(registry, name)
  if index >= 0 then
    registry.models[index] = model
    return index
  end if
  registry.names = registry.names + [name]
  registry.models = registry.models + [model]
  return len(registry.names) - 1
end function

function get(registry, name)
  index = findIndex(registry, name)
  if index < 0 then return void end if
  return registry.models[index]
end function
