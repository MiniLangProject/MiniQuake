/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang parity and regression tests for tests/pr_cmds_differential_fixture.ml.
*/
import miniquake.types as t
import miniquake.constants as c
import miniquake.native as native
import miniquake.array_util as arrayutil
import miniquake.sizebuf as sz
import miniquake.cvar as cvar
import miniquake.cmd as cmd
import miniquake.server as server
import miniquake.quakec.opcodes as op
import miniquake.quakec.vm as vm
import miniquake.quakec.builtins as qc

// Add the requested value to the destination state.
function emit(name, caseName, i0, i1, f0, f1, f2, f3)
  print "{\"function\":\"" + name + "\",\"case\":\"" + caseName +
    "\",\"i0\":" + i0 + ",\"i1\":" + i1 +
    ",\"f0\":" + native.floatText(f0) + ",\"f1\":" + native.floatText(f1) +
    ",\"f2\":" + native.floatText(f2) + ",\"f3\":" + native.floatText(f3) + "}"
end function

// Exercise int bool as part of this deterministic regression fixture.
function intBool(value)
  if value then return 1 end if
  return 0
end function

// Trace checksum through the collision world.
function traceChecksum(value)
  data = value
  if value is string then data = bytes(value) end if
  result = 0
  index = 0
  while index < len(data)
    result = result + (index + 1) * data[index]
    index = index + 1
  end while
  return result
end function

// Exercise field as part of this deterministic regression fixture.
function field(typeValue, offset, name)
  return t.QuakeCDef(typeValue, offset, 0, name)
end function

// Create and initialize fields.
function makeFields()
  return [
    field(c.EV_VOID, 0, ""),
    field(c.EV_STRING, 1, "model"),
    field(c.EV_FLOAT, 2, "modelindex"),
    field(c.EV_FLOAT, 3, "frame"),
    field(c.EV_FLOAT, 4, "colormap"),
    field(c.EV_FLOAT, 5, "skin"),
    field(c.EV_VECTOR, 6, "origin"),
    field(c.EV_VECTOR, 9, "angles"),
    field(c.EV_VECTOR, 12, "mins"),
    field(c.EV_VECTOR, 15, "maxs"),
    field(c.EV_VECTOR, 18, "size"),
    field(c.EV_VECTOR, 21, "absmin"),
    field(c.EV_VECTOR, 24, "absmax"),
    field(c.EV_VECTOR, 27, "view_ofs"),
    field(c.EV_FLOAT, 30, "health"),
    field(c.EV_FLOAT, 31, "flags"),
    field(c.EV_FLOAT, 32, "solid"),
    field(c.EV_ENTITY, 33, "chain"),
    field(c.EV_FLOAT, 34, "takedamage"),
    field(c.EV_FLOAT, 35, "team"),
    field(c.EV_FLOAT, 36, "ideal_yaw"),
    field(c.EV_FLOAT, 37, "yaw_speed"),
    field(c.EV_ENTITY, 38, "groundentity"),
    field(c.EV_STRING, 39, "classname"),
    field(c.EV_FLOAT, 40, "nextthink"),
  ]
end function

// Create and initialize globals.
function makeGlobals()
  result = [
    field(c.EV_VOID, 0, ""),
    field(c.EV_ENTITY, 80, "self"),
    field(c.EV_ENTITY, 81, "msg_entity"),
    field(c.EV_VECTOR, 82, "v_forward"),
    field(c.EV_VECTOR, 85, "v_right"),
    field(c.EV_VECTOR, 88, "v_up"),
    field(c.EV_FLOAT, 91, "trace_allsolid"),
    field(c.EV_FLOAT, 92, "trace_startsolid"),
    field(c.EV_FLOAT, 93, "trace_fraction"),
    field(c.EV_FLOAT, 94, "trace_inwater"),
    field(c.EV_FLOAT, 95, "trace_inopen"),
    field(c.EV_VECTOR, 96, "trace_endpos"),
    field(c.EV_VECTOR, 99, "trace_plane_normal"),
    field(c.EV_FLOAT, 102, "trace_plane_dist"),
    field(c.EV_ENTITY, 103, "trace_ent"),
  ]
  index = 1
  while index <= 16
    result = result + [field(c.EV_FLOAT, 103 + index, "parm" + index)]
    index = index + 1
  end while
  return result
end function

// Exercise no command as part of this deterministic regression fixture.
function noCommand(name)
  return false
end function

// Exercise fresh as part of this deterministic regression fixture.
function fresh()
  dummy = t.QuakeCFunction(0, 0, 0, 0, "", "", 0, [])
  program = t.QuakeCProgram(
    "pr_cmds_fixture.dat",
    bytes(),
    c.PROG_VERSION,
    0,
    [],
    makeGlobals(),
    makeFields(),
    [dummy],
    bytes(1),
    vm.zeroArray(192),
    48,
  )
  machine = vm.create(program, 16)
  freeFlags = arrayutil.makeFilledArray(16, true)
  freeTimes = arrayutil.makeFilledArray(16, 0.0)
  freeFlags[0] = false
  freeFlags[1] = false
  freeFlags[2] = false
  runtime = t.EdictRuntime(16, 8, freeFlags, freeTimes)
  machine.edictFree = freeFlags
  registry = cvar.createRegistry()
  cvar.register(registry, cvar.create("skill", "2.5", false, false), noCommand)
  cvar.register(registry, cvar.create("sv_aim", "0.93", false, false), noCommand)
  cvar.register(registry, cvar.create("teamplay", "0", false, false), noCommand)
  styles = arrayutil.makeFilledArray(64, "")
  contextValue = t.QuakeCContext(
    void,
    void,
    void,
    registry,
    cmd.create(),
    runtime,
    [],
    [],
    styles,
    sz.allocOverflowing(4096),
    sz.allocOverflowing(4096),
    sz.alloc(4096),
    [],
    [],
    [],
    [],
    [],
    0.0,
    1,
    "",
    0,
    void,
    [sz.alloc(1024), sz.alloc(1024)],
    [arrayutil.makeFilledArray(16, 0.0), arrayutil.makeFilledArray(16, 0.0)],
    0,
    0.0,
    bytes(),
  )
  vm.setContext(machine, contextValue)
  qc.bind(contextValue)
  return [machine, contextValue]
end function

// Update module state for parm word.
function setParmWord(machine, index, value)
  qc.setWord(machine, op.OFS_PARM0 + index * 3, value)
end function

// Update module state for parm float.
function setParmFloat(machine, index, value)
  qc.setFloat(machine, op.OFS_PARM0 + index * 3, value)
end function

// Update module state for parm vector.
function setParmVector(machine, index, x, y, z)
  qc.setVectorValue(machine, op.OFS_PARM0 + index * 3, t.Vec3(x, y, z))
end function

// Update module state for parm string.
function setParmString(machine, index, text)
  setParmWord(machine, index, vm.internString(machine, text))
end function

// Return returned vector derived from the active module state.
function returnedVector(machine)
  return qc.vectorValue(machine, op.OFS_RETURN)
end function

// Exercise returned float as part of this deterministic regression fixture.
function returnedFloat(machine)
  return qc.floatValue(machine, op.OFS_RETURN)
end function

// Return fatal mode derived from the active module state.
function fatalMode(caseNumber)
  // Set up deterministic fixtures first, then exercise parity cases and aggregate failures.
  state = fresh()
  machine = state[0]
  contextValue = state[1]
  machine.argCount = 1
  qc.setGlobalWord(machine, "self", 2)
  result = void
  if caseNumber == 0 then setParmString(machine, 0, "fatal"); result = try(qc.PF_error(machine)) end if
  if caseNumber == 1 then setParmString(machine, 0, "fatal"); result = try(qc.PF_objerror(machine)) end if
  if caseNumber == 2 then result = try(qc.PF_break(machine)) end if
  if caseNumber == 3 then result = try(qc.PF_Fixme(machine)) end if
  if caseNumber == 4 then result = try(qc.SetMinMaxSize(machine, 2, t.Vec3(1, 0, 0), t.Vec3(0, 0, 0), false)) end if
  if caseNumber >= 5 and caseNumber <= 7 then
    setParmWord(machine, 0, 2)
    setParmFloat(machine, 1, 0)
    setParmString(machine, 2, "bad.wav")
    setParmFloat(machine, 3, 1)
    setParmFloat(machine, 4, 1)
    if caseNumber == 5 then setParmFloat(machine, 3, 2) end if
    if caseNumber == 6 then setParmFloat(machine, 4, 5) end if
    if caseNumber == 7 then setParmFloat(machine, 1, 8) end if
    result = try(qc.PF_sound(machine))
  end if
  if caseNumber == 8 then setParmWord(machine, 0, 0); setParmString(machine, 1, "cmd\n"); result = try(qc.PF_stuffcmd(machine)) end if
  if caseNumber == 9 then result = try(qc.PR_CheckEmptyString(" bad")) end if
  if caseNumber == 10 then
    contextValue.server = server.create(2)
    contextValue.server.loading = false
    setParmString(machine, 0, "bad.wav")
    result = try(qc.PF_precache_sound(machine))
  end if
  if caseNumber == 11 then setParmString(machine, 0, " bad.mdl"); result = try(qc.PF_precache_model(machine)) end if
  if caseNumber == 12 then setParmFloat(machine, 0, 4); result = try(qc.WriteDest(machine)) end if
  if caseNumber == 13 then setParmFloat(machine, 0, 1); qc.setGlobalWord(machine, "msg_entity", 0); result = try(qc.WriteDest(machine)) end if
  if caseNumber == 14 then setParmWord(machine, 0, 0); result = try(qc.PF_setspawnparms(machine)) end if
  if caseNumber == 15 then setParmWord(machine, 0, 2); setParmString(machine, 1, "missing.mdl"); result = try(qc.PF_setmodel(machine)) end if
  if result is error then return 42 end if
  return 0
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  if len(args) >= 2 and args[0] == "--fatal" then return fatalMode(toNumber(args[1])) end if

  // Exercise PF_Find's null-string branch without changing the oracle event
  // schema: an unset string_t must not match an empty requested string.
  nullFind = fresh()
  nullMachine = nullFind[0]
  setParmWord(nullMachine, 0, 0)
  setParmWord(nullMachine, 1, qc.fieldOffset(nullMachine, "classname"))
  setParmString(nullMachine, 2, "")
  qc.PF_Find(nullMachine)
  if qc.word(nullMachine, op.OFS_RETURN) != 0 then return 89 end if

  state = fresh(); machine = state[0]; contextValue = state[1]
  machine.argCount = 3; setParmString(machine,0,"one");setParmString(machine,1," two");setParmString(machine,2," three")
  text = qc.PF_VarString(machine,0)
  emit("PF_VarString","variadic",len(bytes(text)),traceChecksum(text),0,0,0,0)

  state=fresh();machine=state[0];contextValue=state[1];machine.argCount=1;setParmString(machine,0,"fatal");qc.setGlobalWord(machine,"self",1)
  result=try(qc.PF_error(machine));emit("PF_error","terminal_body",intBool(result is error),len(contextValue.consoleLines),0,0,0,0)

  state=fresh();machine=state[0];contextValue=state[1];machine.argCount=1;setParmString(machine,0,"object");qc.setGlobalWord(machine,"self",2)
  result=try(qc.PF_objerror(machine));emit("PF_objerror","free_self",intBool(result is error),intBool(machine.edictFree[2]),0,0,0,0)

  state=fresh();machine=state[0];setParmVector(machine,0,0,90,0);qc.PF_makevectors(machine)
  forward=qc.globalVector(machine,"v_forward");right=qc.globalVector(machine,"v_right");up=qc.globalVector(machine,"v_up")
  emit("PF_makevectors","yaw90",0,0,forward.x,forward.y,right.x,up.z)

  state=fresh();machine=state[0];setParmWord(machine,0,2);setParmVector(machine,1,10,20,30);qc.PF_setorigin(machine);value=qc.entityVector(machine,2,"origin")
  emit("PF_setorigin","relink",1,0,value.x,value.y,value.z,qc.entityVector(machine,2,"absmin").x)

  state=fresh();machine=state[0];qc.SetMinMaxSize(machine,2,t.Vec3(-1,-2,-3),t.Vec3(4,5,6),true)
  mins=qc.entityVector(machine,2,"mins");maxs=qc.entityVector(machine,2,"maxs");size=qc.entityVector(machine,2,"size")
  emit("SetMinMaxSize","axis_aligned",1,0,mins.y,maxs.z,size.x,size.z)

  state=fresh();machine=state[0];setParmWord(machine,0,2);setParmVector(machine,1,-1,-2,-3);setParmVector(machine,2,4,5,6);qc.PF_setsize(machine)
  mins=qc.entityVector(machine,2,"mins");maxs=qc.entityVector(machine,2,"maxs");size=qc.entityVector(machine,2,"size")
  emit("PF_setsize","bounds",1,0,mins.x,maxs.y,size.x,size.z)

  state=fresh();machine=state[0];contextValue=state[1];contextValue.modelPrecache=["progs/test.mdl"];setParmWord(machine,0,2);setParmString(machine,1,"progs/test.mdl");qc.PF_setmodel(machine)
  mins=qc.entityVector(machine,2,"mins");maxs=qc.entityVector(machine,2,"maxs");size=qc.entityVector(machine,2,"size")
  emit("PF_setmodel","precache",1,native.trunc(qc.entityFloat(machine,2,"modelindex")),mins.x,maxs.x,size.x,0)

  state=fresh();machine=state[0];machine.argCount=2;setParmString(machine,0,"hello");setParmString(machine,1," world");qc.PF_bprint(machine)
  emit("PF_bprint","variadic",1,0,0,0,0,0)

  state=fresh();machine=state[0];contextValue=state[1];machine.argCount=3;setParmWord(machine,0,1);setParmString(machine,1,"client");setParmString(machine,2," text");qc.PF_sprint(machine)
  emit("PF_sprint","client",contextValue.clientMessages[0].curSize,contextValue.clientMessages[0].data[0],0,0,0,0)

  state=fresh();machine=state[0];contextValue=state[1];machine.argCount=2;setParmWord(machine,0,1);setParmString(machine,1,"center");qc.PF_centerprint(machine)
  emit("PF_centerprint","client",contextValue.clientMessages[0].curSize,contextValue.clientMessages[0].data[0],0,0,0,0)

  state=fresh();machine=state[0];setParmVector(machine,0,3,4,0);qc.PF_normalize(machine);value=returnedVector(machine)
  emit("PF_normalize","three_four",0,0,value.x,value.y,value.z,0)
  state=fresh();machine=state[0];setParmVector(machine,0,3,4,12);qc.PF_vlen(machine);emit("PF_vlen","length",0,0,returnedFloat(machine),0,0,0)
  state=fresh();machine=state[0];setParmVector(machine,0,1,2,0);qc.PF_vectoyaw(machine);emit("PF_vectoyaw","quadrant",0,0,returnedFloat(machine),0,0,0)
  state=fresh();machine=state[0];setParmVector(machine,0,1,1,1);qc.PF_vectoangles(machine);value=returnedVector(machine);emit("PF_vectoangles","angles",0,0,value.x,value.y,value.z,0)
  state=fresh();machine=state[0];qc.PF_random(machine);emit("PF_random","msvc",0,0,returnedFloat(machine),0,0,0)

  state=fresh();machine=state[0];contextValue=state[1];setParmVector(machine,0,1,2,3);setParmVector(machine,1,4,5,6);setParmFloat(machine,2,7);setParmFloat(machine,3,8);qc.PF_particle(machine)
  emit("PF_particle","dispatch",len(contextValue.particles),0,0,0,0,0)

  state=fresh();machine=state[0];contextValue=state[1];contextValue.soundPrecache=["amb.wav"];setParmVector(machine,0,8,16,24);setParmString(machine,1,"amb.wav");setParmFloat(machine,2,0.5);setParmFloat(machine,3,1.5);qc.PF_ambientsound(machine)
  emit("PF_ambientsound","signon",contextValue.signon.curSize,contextValue.signon.data[0],0,0,0,0)

  state=fresh();machine=state[0];contextValue=state[1];setParmWord(machine,0,2);setParmFloat(machine,1,3);setParmString(machine,2,"sound.wav");setParmFloat(machine,3,0.5);setParmFloat(machine,4,1.25);qc.PF_sound(machine)
  emit("PF_sound","dispatch",len(contextValue.soundEvents),0,0,0,0,0)

  state=fresh();machine=state[0];setParmVector(machine,0,0,0,0);setParmVector(machine,1,10,10,10);setParmFloat(machine,2,1);setParmWord(machine,3,2);qc.PF_traceline(machine)
  endPosition=qc.globalVector(machine,"trace_endpos");normal=qc.globalVector(machine,"trace_plane_normal")
  emit("PF_traceline","no_world",qc.globalWord(machine,"trace_ent"),0,native.bitsFloat(qc.globalWord(machine,"trace_fraction")),endPosition.x,normal.z,native.bitsFloat(qc.globalWord(machine,"trace_plane_dist")))

  state=fresh();machine=state[0];qc.setFloat(machine,op.OFS_RETURN,9);qc.PF_checkpos(machine);emit("PF_checkpos","empty_body",0,0,returnedFloat(machine),0,0,0)

  state=fresh();machine=state[0];contextValue=state[1];game=server.create(2);contextValue.server=game;qc.setEntityFloat(machine,1,"health",100);qc.setEntityFloat(machine,2,"health",100)
  value=qc.PF_newcheckclient(machine,1);emit("PF_newcheckclient","cycle",value,3,0,0,0,0)

  state=fresh();machine=state[0];contextValue=state[1];game=server.create(2);game.time=1.05;contextValue.server=game;contextValue.lastCheckClient=1;contextValue.lastCheckTime=1;qc.setEntityFloat(machine,1,"health",0);qc.setGlobalWord(machine,"self",2);qc.PF_checkclient(machine)
  emit("PF_checkclient","dead",qc.word(machine,op.OFS_RETURN),0,0,0,0,0)

  state=fresh();machine=state[0];machine.argCount=2;setParmWord(machine,0,1);setParmString(machine,1,"echo hi\n");qc.PF_stuffcmd(machine);emit("PF_stuffcmd","client",1,0,0,0,0,0)
  state=fresh();machine=state[0];contextValue=state[1];setParmString(machine,0,"echo local\n");qc.PF_localcmd(machine);emit("PF_localcmd","append",1,traceChecksum(contextValue.commands.text),0,0,0,0)
  state=fresh();machine=state[0];setParmString(machine,0,"skill");qc.PF_cvar(machine);emit("PF_cvar","value",0,0,returnedFloat(machine),0,0,0)
  state=fresh();machine=state[0];contextValue=state[1];setParmString(machine,0,"skill");setParmString(machine,1,"3");qc.PF_cvar_set(machine);emit("PF_cvar_set","set",intBool(cvar.find(contextValue.cvars,"skill").string=="3"),0,0,0,0,0)

  state=fresh();machine=state[0];qc.setEntityFloat(machine,1,"solid",1);qc.setEntityVector(machine,1,"origin",t.Vec3(2,0,0));qc.setEntityFloat(machine,2,"solid",1);qc.setEntityVector(machine,2,"origin",t.Vec3(6,0,0));setParmVector(machine,0,0,0,0);setParmFloat(machine,1,8);qc.PF_findradius(machine)
  emit("PF_findradius","chain",qc.word(machine,op.OFS_RETURN),qc.entityWord(machine,2,"chain"),qc.entityWord(machine,1,"chain"),0,0,0)

  state=fresh();machine=state[0];contextValue=state[1];machine.argCount=2;setParmString(machine,0,"debug");setParmString(machine,1," text");qc.PF_dprint(machine);emit("PF_dprint","variadic",len(contextValue.consoleLines),0,0,0,0,0)
  state=fresh();machine=state[0];setParmFloat(machine,0,12.5);qc.PF_ftos(machine);text=qc.stringAt(machine,qc.word(machine,op.OFS_RETURN));emit("PF_ftos","format",len(bytes(text)),traceChecksum(text),0,0,0,0)
  state=fresh();machine=state[0];setParmFloat(machine,0,-12.5);qc.PF_fabs(machine);emit("PF_fabs","absolute",0,0,returnedFloat(machine),0,0,0)
  state=fresh();machine=state[0];setParmVector(machine,0,1.25,-2.5,3);qc.PF_vtos(machine);text=qc.stringAt(machine,qc.word(machine,op.OFS_RETURN));emit("PF_vtos","format",len(bytes(text)),traceChecksum(text),0,0,0,0)

  state=fresh();machine=state[0];qc.PF_Spawn(machine);entityIndex=qc.word(machine,op.OFS_RETURN);emit("PF_Spawn","allocate",entityIndex,intBool(machine.edictFree[entityIndex]),0,0,0,0)
  state=fresh();machine=state[0];setParmWord(machine,0,2);qc.PF_Remove(machine);emit("PF_Remove","free",intBool(machine.edictFree[2]),1,0,0,0,0)

  state=fresh();machine=state[0];qc.setEntityWord(machine,2,"classname",vm.internString(machine,"target"));setParmWord(machine,0,0);setParmWord(machine,1,qc.fieldOffset(machine,"classname"));setParmString(machine,2,"target");qc.PF_Find(machine)
  emit("PF_Find","field",qc.word(machine,op.OFS_RETURN),intBool(qc.word(machine,op.OFS_RETURN)==2),0,0,0,0)

  result=try(qc.PR_CheckEmptyString("valid"));emit("PR_CheckEmptyString","valid",intBool(result is error),0,0,0,0,0)
  state=fresh();machine=state[0];setParmString(machine,0,"maps/e1m1.bsp");qc.PF_precache_file(machine);emit("PF_precache_file","identity",intBool(qc.word(machine,op.OFS_RETURN)==qc.word(machine,op.OFS_PARM0)),0,0,0,0,0)
  state=fresh();machine=state[0];contextValue=state[1];setParmString(machine,0,"sound/test.wav");qc.PF_precache_sound(machine);emit("PF_precache_sound","insert",len(contextValue.soundPrecache),intBool(qc.word(machine,op.OFS_RETURN)==qc.word(machine,op.OFS_PARM0)),0,0,0,0)
  state=fresh();machine=state[0];contextValue=state[1];setParmString(machine,0,"progs/test.mdl");qc.PF_precache_model(machine);emit("PF_precache_model","insert",len(contextValue.modelPrecache),1,0,0,0,0)

  state=fresh();machine=state[0];contextValue=state[1];qc.PF_coredump(machine);emit("PF_coredump","dump",len(contextValue.consoleLines),0,0,0,0,0)
  state=fresh();machine=state[0];qc.PF_traceon(machine);emit("PF_traceon","enable",intBool(machine.trace),0,0,0,0,0)
  state=fresh();machine=state[0];machine.trace=true;qc.PF_traceoff(machine);emit("PF_traceoff","disable",intBool(machine.trace),0,0,0,0,0)
  state=fresh();machine=state[0];contextValue=state[1];setParmWord(machine,0,2);qc.PF_eprint(machine);emit("PF_eprint","print",len(contextValue.consoleLines),0,0,0,0,0)

  state=fresh();machine=state[0];qc.setGlobalWord(machine,"self",2);qc.setEntityFloat(machine,2,"flags",c.FL_ONGROUND);setParmFloat(machine,0,90);setParmFloat(machine,1,16);qc.PF_walkmove(machine)
  emit("PF_walkmove","grounded",intBool(returnedFloat(machine)!=0),0,returnedFloat(machine),0,0,0)

  state=fresh();machine=state[0];qc.setGlobalWord(machine,"self",2);qc.setEntityVector(machine,2,"origin",t.Vec3(0,0,100));qc.PF_droptofloor(machine);value=qc.entityVector(machine,2,"origin")
  emit("PF_droptofloor","land",0,qc.entityWord(machine,2,"groundentity"),returnedFloat(machine),value.z,qc.entityFloat(machine,2,"flags"),0)

  state=fresh();machine=state[0];contextValue=state[1];game=server.create(2);game.active=true;game.loading=false;game.clients[0].active=true;contextValue.server=game;setParmFloat(machine,0,3);setParmString(machine,1,"abc");qc.PF_lightstyle(machine)
  emit("PF_lightstyle","broadcast",contextValue.clientMessages[0].curSize,contextValue.clientMessages[0].data[0],0,0,0,0)

  state=fresh();machine=state[0];setParmFloat(machine,0,-1.5);qc.PF_rint(machine);emit("PF_rint","negative",0,0,returnedFloat(machine),0,0,0)
  state=fresh();machine=state[0];setParmFloat(machine,0,-1.2);qc.PF_floor(machine);emit("PF_floor","negative",0,0,returnedFloat(machine),0,0,0)
  state=fresh();machine=state[0];setParmFloat(machine,0,-1.2);qc.PF_ceil(machine);emit("PF_ceil","negative",0,0,returnedFloat(machine),0,0,0)
  state=fresh();machine=state[0];setParmWord(machine,0,2);qc.PF_checkbottom(machine);emit("PF_checkbottom","no_world",0,0,returnedFloat(machine),0,0,0)
  state=fresh();machine=state[0];setParmVector(machine,0,1,2,3);qc.PF_pointcontents(machine);emit("PF_pointcontents","no_world",0,0,returnedFloat(machine),0,0,0)

  state=fresh();machine=state[0];machine.edictFree[1]=true;machine.edictFree[2]=false;setParmWord(machine,0,0);qc.PF_nextent(machine);emit("PF_nextent","skip_free",qc.word(machine,op.OFS_RETURN),0,0,0,0,0)
  state=fresh();machine=state[0];setParmWord(machine,0,1);setParmFloat(machine,1,1000);qc.setGlobalVector(machine,"v_forward",t.Vec3(1,0,0));qc.PF_aim(machine);value=returnedVector(machine);emit("PF_aim","straight",0,0,value.x,value.y,value.z,0)
  state=fresh();machine=state[0];qc.setGlobalWord(machine,"self",2);qc.setEntityVector(machine,2,"angles",t.Vec3(0,350,0));qc.setEntityFloat(machine,2,"ideal_yaw",10);qc.setEntityFloat(machine,2,"yaw_speed",5);qc.PF_changeyaw(machine);emit("PF_changeyaw","wrap",0,0,qc.entityVector(machine,2,"angles").y,0,0,0)

  state=fresh();machine=state[0];contextValue=state[1];setParmFloat(machine,0,2);destination=qc.WriteDest(machine);emit("WriteDest","reliable",intBool(destination==contextValue.reliableDatagram),0,0,0,0,0)

  state=fresh();machine=state[0];contextValue=state[1];setParmFloat(machine,0,0);setParmFloat(machine,1,254);qc.PF_WriteByte(machine);emit("PF_WriteByte","broadcast",contextValue.datagram.curSize,contextValue.datagram.data[0],254,0,0,0)
  state=fresh();machine=state[0];contextValue=state[1];setParmFloat(machine,0,0);setParmFloat(machine,1,-2);qc.PF_WriteChar(machine);emit("PF_WriteChar","broadcast",contextValue.datagram.curSize,contextValue.datagram.data[0],254,0,0,0)
  state=fresh();machine=state[0];contextValue=state[1];setParmFloat(machine,0,0);setParmFloat(machine,1,-1234);qc.PF_WriteShort(machine);emit("PF_WriteShort","broadcast",contextValue.datagram.curSize,contextValue.datagram.data[0],46,0,0,0)
  state=fresh();machine=state[0];contextValue=state[1];setParmFloat(machine,0,0);setParmFloat(machine,1,305419896);qc.PF_WriteLong(machine);emit("PF_WriteLong","broadcast",contextValue.datagram.curSize,contextValue.datagram.data[0],120,0,0,0)
  state=fresh();machine=state[0];contextValue=state[1];setParmFloat(machine,0,0);setParmFloat(machine,1,90.75);qc.PF_WriteAngle(machine);emit("PF_WriteAngle","broadcast",contextValue.datagram.curSize,contextValue.datagram.data[0],64,0,0,0)
  state=fresh();machine=state[0];contextValue=state[1];setParmFloat(machine,0,0);setParmFloat(machine,1,-12.25);qc.PF_WriteCoord(machine);emit("PF_WriteCoord","broadcast",contextValue.datagram.curSize,contextValue.datagram.data[0],158,0,0,0)
  state=fresh();machine=state[0];contextValue=state[1];setParmFloat(machine,0,0);setParmString(machine,1,"quake");qc.PF_WriteString(machine);emit("PF_WriteString","broadcast",contextValue.datagram.curSize,traceChecksum(slice(contextValue.datagram.data,0,contextValue.datagram.curSize)),0,0,0,0)
  state=fresh();machine=state[0];contextValue=state[1];setParmFloat(machine,0,0);setParmWord(machine,1,513);qc.PF_WriteEntity(machine);emit("PF_WriteEntity","broadcast",contextValue.datagram.curSize,contextValue.datagram.data[0],contextValue.datagram.data[1],0,0,0)

  state=fresh();machine=state[0];contextValue=state[1];contextValue.modelPrecache=["progs/test.mdl"];qc.setEntityWord(machine,2,"model",vm.internString(machine,"progs/test.mdl"));qc.setEntityVector(machine,2,"origin",t.Vec3(8,0,0));setParmWord(machine,0,2);qc.PF_makestatic(machine)
  emit("PF_makestatic","baseline",contextValue.signon.curSize,contextValue.signon.data[0],intBool(machine.edictFree[2]),0,0,0)

  state=fresh();machine=state[0];contextValue=state[1];spawnValues=arrayutil.makeEmptyArray(16);index=0
  while index<16
    spawnValues[index]=index+1
    index=index+1
  end while
  contextValue.clientSpawnParms[0]=spawnValues;setParmWord(machine,0,1);qc.PF_setspawnparms(machine)
  emit("PF_setspawnparms","copy",0,0,native.bitsFloat(qc.globalWord(machine,"parm1")),native.bitsFloat(qc.globalWord(machine,"parm8")),native.bitsFloat(qc.globalWord(machine,"parm16")),0)

  state=fresh();machine=state[0];contextValue=state[1];setParmString(machine,0,"e1m2");qc.PF_changelevel(machine);emit("PF_changelevel","once",intBool(contextValue.changeLevel!=""),intBool(len(bytes(contextValue.commands.text))>0),0,0,0,0)
  state=fresh();machine=state[0];result=try(qc.PF_Fixme(machine));emit("PF_Fixme","runerror",intBool(result is error),0,0,0,0,0)
  return 0
end function
