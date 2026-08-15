/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang parity and regression tests for tests/gl_mesh_differential_fixture.ml.
*/
import miniquake.types as t
import miniquake.render.alias_mesh as mesh

struct MeshFixture
  filename
  triangles
  texCoords
  skinWidth
  skinHeight
end struct

// Exercise texture coordinates as part of this deterministic regression fixture.
function textureCoordinates(count)
  result = []
  index = 0
  while index < count
    result = result + [t.MdlTexCoord(index & 1, index * 5, index * 3)]
    index = index + 1
  end while
  return result
end function

// Convert model into its canonical representation.
function stripModel(filename)
  triangles = [
    t.MdlTriangle(0, 0, 1, 2),
    t.MdlTriangle(0, 2, 1, 3),
    t.MdlTriangle(0, 2, 3, 4),
    t.MdlTriangle(0, 4, 3, 5),
  ]
  return MeshFixture(filename, triangles, textureCoordinates(6), 64, 32)
end function

// Exercise fan model as part of this deterministic regression fixture.
function fanModel(filename)
  triangles = [
    t.MdlTriangle(0, 0, 1, 2),
    t.MdlTriangle(0, 0, 2, 3),
    t.MdlTriangle(0, 0, 3, 4),
  ]
  return MeshFixture(filename, triangles, textureCoordinates(6), 64, 32)
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  mesh.configureAliasModel(stripModel("strip"))
  stripCount = mesh.StripLength(0, 0)
  print "{\"function\":\"StripLength\",\"case\":\"chain\",\"count\":" +
    stripCount + ",\"vertices\":[" + mesh.stripverts[0] + "," +
    mesh.stripverts[1] + "," + mesh.stripverts[2] + "," +
    mesh.stripverts[3] + "," + mesh.stripverts[4] + "," +
    mesh.stripverts[5] + "],\"triangles\":[" + mesh.striptris[0] + "," +
    mesh.striptris[1] + "," + mesh.striptris[2] + "," +
    mesh.striptris[3] + "]}"

  mesh.configureAliasModel(fanModel("fan"))
  fanCount = mesh.FanLength(0, 0)
  print "{\"function\":\"FanLength\",\"case\":\"chain\",\"count\":" +
    fanCount + ",\"vertices\":[" + mesh.stripverts[0] + "," +
    mesh.stripverts[1] + "," + mesh.stripverts[2] + "," +
    mesh.stripverts[3] + "," + mesh.stripverts[4] +
    "],\"triangles\":[" + mesh.striptris[0] + "," + mesh.striptris[1] +
    "," + mesh.striptris[2] + "]}"

  mesh.configureAliasModel(stripModel("build"))
  built = mesh.BuildTris()
  first = built.commands[0]
  print "{\"function\":\"BuildTris\",\"case\":\"strip\",\"numcommands\":" +
    built.numCommands + ",\"numorder\":" + built.numOrder + ",\"count\":" +
    first.count + ",\"first\":[" + first.vertices[0].s + "," +
    first.vertices[0].t + "],\"last\":[" + first.vertices[5].s + "," +
    first.vertices[5].t + "],\"order\":[" + built.vertexOrder[0] + "," +
    built.vertexOrder[1] + "," + built.vertexOrder[2] + "," +
    built.vertexOrder[3] + "," + built.vertexOrder[4] + "," +
    built.vertexOrder[5] + "]}"

  displayModel = stripModel("display")
  display = mesh.GL_MakeAliasModelDisplayLists(displayModel, displayModel)
  displayFirst = display.commands[0]
  print "{\"function\":\"GL_MakeAliasModelDisplayLists\",\"case\":\"build\",\"numcommands\":" +
    display.numCommands + ",\"numorder\":" + display.numOrder + ",\"count\":" +
    displayFirst.count + ",\"first\":[" + displayFirst.vertices[0].s + "," +
    displayFirst.vertices[0].t + "],\"last\":[" +
    displayFirst.vertices[5].s + "," + displayFirst.vertices[5].t +
    "],\"order\":[" + display.vertexOrder[0] + "," +
    display.vertexOrder[1] + "," + display.vertexOrder[2] + "," +
    display.vertexOrder[3] + "," + display.vertexOrder[4] + "," +
    display.vertexOrder[5] + "],\"poseverts\":" + display.numOrder +
    ",\"commands\":1,\"posedata\":1}"
  return 0
end function
