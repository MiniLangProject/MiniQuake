package miniquake.chase

import miniquake.types as t
import miniquake.mathlib as math

function create()
  return t.ChaseState(false, 100.0, 16.0, 0.0)
end function

function update(state, viewOrigin, viewAngles)
  vectors = math.angleVectors(viewAngles)
  forward = vectors[0]
  right = vectors[1]
  destination = math.subtract(viewOrigin, math.scale(forward, state.back))
  destination = math.multiplyAdd(destination, state.right, right)
  destination.z = destination.z + state.up
  return destination
end function
