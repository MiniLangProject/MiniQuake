import miniquake.types as t
import miniquake.native as native
import miniquake.cvar as cvar
import miniquake.chase as chasePort

function number(value)
  return native.floatText(value)
end function

function main(args)
  registry = cvar.createRegistry()
  state = chasePort.Chase_Init(registry)
  print "{\"function\":\"Chase_Init\",\"case\":\"defaults\",\"registered\":" +
    len(registry.variables) + ",\"values\":[" + number(state.back) + "," +
    number(state.up) + "," + number(state.right) + ",0]}"

  same = chasePort.Chase_Reset(state)
  called = 0
  if same == state then called = 1 end if
  print "{\"function\":\"Chase_Reset\",\"case\":\"noop\",\"called\":" + called + "}"

  impact = chasePort.TraceLine(
    void,
    t.Vec3(1.0, 2.0, 3.0),
    t.Vec3(4.0, 5.0, 6.0),
  )
  print "{\"function\":\"TraceLine\",\"case\":\"clear\",\"values\":[" +
    number(impact.x) + "," + number(impact.y) + "," + number(impact.z) + "]}"

  updated = chasePort.Chase_Update(
    state,
    t.Vec3(10.0, 20.0, 30.0),
    t.Vec3(0.0, 0.0, 0.0),
    void,
  )
  origin = updated[0]
  angles = updated[1]
  destination = updated[2]
  print "{\"function\":\"Chase_Update\",\"case\":\"clear\",\"values\":[" +
    number(origin.x) + "," + number(origin.y) + "," + number(origin.z) + "," +
    number(angles.x) + "," + number(angles.y) + "," + number(angles.z) + "," +
    number(destination.x) + "," + number(destination.y) + "," +
    number(destination.z) + "]}"
  return 0
end function
