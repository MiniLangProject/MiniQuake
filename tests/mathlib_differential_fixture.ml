import miniquake.types as t
import miniquake.native as native
import miniquake.mathlib as mathPort

function number(value)
  return native.floatText(value)
end function

function vecEvent(functionName, caseName, value)
  print "{\"function\":\"" + functionName + "\",\"case\":\"" + caseName +
    "\",\"x\":" + number(value.x) + ",\"y\":" + number(value.y) +
    ",\"z\":" + number(value.z) + "}"
end function

function scalarEvent(functionName, caseName, value)
  print "{\"function\":\"" + functionName + "\",\"case\":\"" + caseName +
    "\",\"value\":" + number(value) + "}"
end function

function matrix3Event(functionName, caseName, value)
  print "{\"function\":\"" + functionName + "\",\"case\":\"" + caseName +
    "\",\"values\":[" +
    number(value[0][0]) + "," + number(value[0][1]) + "," + number(value[0][2]) + "," +
    number(value[1][0]) + "," + number(value[1][1]) + "," + number(value[1][2]) + "," +
    number(value[2][0]) + "," + number(value[2][1]) + "," + number(value[2][2]) + "]}"
end function

function matrix34Event(functionName, caseName, value)
  print "{\"function\":\"" + functionName + "\",\"case\":\"" + caseName +
    "\",\"values\":[" +
    number(value[0][0]) + "," + number(value[0][1]) + "," + number(value[0][2]) + "," + number(value[0][3]) + "," +
    number(value[1][0]) + "," + number(value[1][1]) + "," + number(value[1][2]) + "," + number(value[1][3]) + "," +
    number(value[2][0]) + "," + number(value[2][1]) + "," + number(value[2][2]) + "," + number(value[2][3]) + "]}"
end function

function main(args)
  point = t.Vec3(3.0, 4.0, 5.0)
  normal = t.Vec3(0.0, 0.0, 2.0)
  vecEvent("ProjectPointOnPlane", "basic", mathPort.ProjectPointOnPlane(point, normal))

  source = t.Vec3(0.6, 0.8, 0.0)
  vecEvent("PerpendicularVector", "normalized", mathPort.PerpendicularVector(source))

  vecEvent(
    "RotatePointAroundVector",
    "quarter_turn",
    mathPort.RotatePointAroundVector(
      t.Vec3(0.0, 0.0, 1.0),
      t.Vec3(1.0, 0.0, 0.0),
      90.0,
    ),
  )
  scalarEvent("anglemod", "negative", mathPort.anglemod(-45.25))

  plane = t.Plane(t.Vec3(0.5, -0.25, 0.75), 1.25, 3, 2)
  print "{\"function\":\"BoxOnPlaneSide\",\"case\":\"general\",\"value\":" +
    mathPort.BoxOnPlaneSide(t.Vec3(-2.0, -3.0, -4.0), t.Vec3(5.0, 6.0, 7.0), plane) + "}"

  vectors = mathPort.AngleVectors(t.Vec3(25.0, 130.0, -15.0))
  print "{\"function\":\"AngleVectors\",\"case\":\"angles\",\"values\":[" +
    number(vectors[0].x) + "," + number(vectors[0].y) + "," + number(vectors[0].z) + "," +
    number(vectors[1].x) + "," + number(vectors[1].y) + "," + number(vectors[1].z) + "," +
    number(vectors[2].x) + "," + number(vectors[2].y) + "," + number(vectors[2].z) + "]}"

  first = t.Vec3(1.25, -2.5, 3.75)
  second = t.Vec3(-4.0, 5.5, 6.25)
  print "{\"function\":\"VectorCompare\",\"case\":\"equal\",\"value\":" +
    mathPort.VectorCompare(first, mathPort.VectorCopy(first)) + "}"
  vecEvent("VectorMA", "basic", mathPort.VectorMA(first, 0.75, second))
  scalarEvent("_DotProduct", "basic", mathPort._DotProduct(first, second))
  vecEvent("_VectorSubtract", "basic", mathPort._VectorSubtract(first, second))
  vecEvent("_VectorAdd", "basic", mathPort._VectorAdd(first, second))
  vecEvent("_VectorCopy", "basic", mathPort._VectorCopy(first))
  vecEvent("CrossProduct", "basic", mathPort.CrossProduct(first, second))
  scalarEvent("Length", "basic", mathPort.Length(first))

  normalizeValue = t.Vec3(3.0, 4.0, 12.0)
  normalizeLength = mathPort.VectorNormalize(normalizeValue)
  print "{\"function\":\"VectorNormalize\",\"case\":\"basic\",\"length\":" +
    number(normalizeLength) + ",\"x\":" + number(normalizeValue.x) +
    ",\"y\":" + number(normalizeValue.y) + ",\"z\":" + number(normalizeValue.z) + "}"

  inverseValue = t.Vec3(1.5, -2.0, 3.25)
  mathPort.VectorInverse(inverseValue)
  vecEvent("VectorInverse", "basic", inverseValue)
  vecEvent("VectorScale", "basic", mathPort.VectorScale(first, -1.5))
  print "{\"function\":\"Q_log2\",\"case\":\"basic\",\"value\":" + mathPort.Q_log2(1025) + "}"

  rotationA = [[1.0, 2.0, 3.0], [0.0, -1.0, 4.0], [2.0, 1.0, 0.5]]
  rotationB = [[-2.0, 1.0, 0.0], [3.0, 0.5, 2.0], [1.0, -1.0, 1.5]]
  matrix3Event("R_ConcatRotations", "basic", mathPort.R_ConcatRotations(rotationA, rotationB))

  transformA = [[1.0, 2.0, 3.0, 4.0], [0.0, -1.0, 4.0, 2.0], [2.0, 1.0, 0.5, -3.0]]
  transformB = [[-2.0, 1.0, 0.0, 5.0], [3.0, 0.5, 2.0, -2.0], [1.0, -1.0, 1.5, 3.0]]
  matrix34Event("R_ConcatTransforms", "basic", mathPort.R_ConcatTransforms(transformA, transformB))

  floorResult = mathPort.FloorDivMod(-17.0, 5.0)
  print "{\"function\":\"FloorDivMod\",\"case\":\"negative\",\"quotient\":" +
    floorResult[0] + ",\"remainder\":" + floorResult[1] + "}"
  print "{\"function\":\"GreatestCommonDivisor\",\"case\":\"basic\",\"value\":" +
    mathPort.GreatestCommonDivisor(462, 1071) + "}"
  print "{\"function\":\"Invert24To16\",\"case\":\"basic\",\"value\":" +
    mathPort.Invert24To16(0x123456) + "}"
  return 0
end function
