/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.types.
*/
package miniquake.types

// Store one three-dimensional vector in Quake world coordinates.
struct Vec3
  /// Stores the x value in `miniquake.types.Vec3`.
  x
  /// Stores the y value in `miniquake.types.Vec3`.
  y
  /// Stores the z value in `miniquake.types.Vec3`.
  z
end struct

// Group the fields that describe one link.
struct Link
  /// Stores the previous value in `miniquake.types.Link`.
  previous
  /// Stores the next value in `miniquake.types.Link`.
  next
end struct

// Group the fields that describe one common file handle.
struct CommonFileHandle
  /// Stores the data value in `miniquake.types.CommonFileHandle`.
  data
  /// Stores the position value in `miniquake.types.CommonFileHandle`.
  position
  /// Stores the length value in `miniquake.types.CommonFileHandle`.
  length
  /// Stores the persistent value in `miniquake.types.CommonFileHandle`.
  persistent
  /// Stores the closed value in `miniquake.types.CommonFileHandle`.
  closed
  /// Stores the source value in `miniquake.types.CommonFileHandle`.
  source
end struct

// Group the fields that describe one plane.
struct Plane
  /// Stores the normal value in `miniquake.types.Plane`.
  normal
  /// Stores the dist value in `miniquake.types.Plane`.
  dist
  /// Stores the type value in `miniquake.types.Plane`.
  type
  /// Stores the sign bits value in `miniquake.types.Plane`.
  signBits
end struct

// Track storage and runtime state for one size buffer.
struct SizeBuffer
  /// Stores the data value in `miniquake.types.SizeBuffer`.
  data
  /// Stores the max size value in `miniquake.types.SizeBuffer`.
  maxSize
  /// Stores the cur size value in `miniquake.types.SizeBuffer`.
  curSize
  /// Stores the allow overflow value in `miniquake.types.SizeBuffer`.
  allowOverflow
  /// Stores the overflowed value in `miniquake.types.SizeBuffer`.
  overflowed
end struct

// Group the fields that describe one message reader.
struct MessageReader
  /// Stores the data value in `miniquake.types.MessageReader`.
  data
  /// Stores the read count value in `miniquake.types.MessageReader`.
  readCount
  /// Stores the bad read value in `miniquake.types.MessageReader`.
  badRead
end struct

// Group the fields that describe one cvar.
struct Cvar
  /// Stores the name value in `miniquake.types.Cvar`.
  name
  /// Stores the string value in `miniquake.types.Cvar`.
  string
  /// Stores the current value in `miniquake.types.Cvar`.
  value
  /// Stores the archive value in `miniquake.types.Cvar`.
  archive
  /// Stores the server value in `miniquake.types.Cvar`.
  server
end struct

// Own the coordinated data required by the cvar registry.
struct CvarRegistry
  /// Stores the variables value in `miniquake.types.CvarRegistry`.
  variables
  /// Stores the server changes value in `miniquake.types.CvarRegistry`.
  serverChanges
  /// Stores the lookup value in `miniquake.types.CvarRegistry`.
  lookup
end struct

// Group the fields that describe one command alias.
struct CommandAlias
  /// Stores the name value in `miniquake.types.CommandAlias`.
  name
  /// Stores the alias expansion value in `miniquake.types.CommandAlias`.
  value
end struct

// Own the coordinated data required by the command system.
struct CommandSystem
  /// Stores the commands value in `miniquake.types.CommandSystem`.
  commands
  /// Stores the aliases value in `miniquake.types.CommandSystem`.
  aliases
  /// Stores the arguments value in `miniquake.types.CommandSystem`.
  arguments
  /// Stores the raw args value in `miniquake.types.CommandSystem`.
  rawArgs
  /// Stores the text value in `miniquake.types.CommandSystem`.
  text
  /// Stores the wait value in `miniquake.types.CommandSystem`.
  wait
end struct

// Group the fields that describe one pack file.
struct PackFile
  /// Stores the name value in `miniquake.types.PackFile`.
  name
  /// Stores the offset value in `miniquake.types.PackFile`.
  offset
  /// Stores the length value in `miniquake.types.PackFile`.
  length
end struct

// Store the parsed data and relationships for one pack archive.
struct PackArchive
  /// Stores the filename value in `miniquake.types.PackArchive`.
  filename
  /// Stores the data value in `miniquake.types.PackArchive`.
  data
  /// Stores the files value in `miniquake.types.PackArchive`.
  files
  /// Stores the num files value in `miniquake.types.PackArchive`.
  numFiles
end struct

// Group the fields that describe one WAD lump.
struct WadLump
  /// Stores the file position value in `miniquake.types.WadLump`.
  filePosition
  /// Stores the disk size value in `miniquake.types.WadLump`.
  diskSize
  /// Stores the size value in `miniquake.types.WadLump`.
  size
  /// Stores the type value in `miniquake.types.WadLump`.
  type
  /// Stores the compression value in `miniquake.types.WadLump`.
  compression
  /// Stores the name value in `miniquake.types.WadLump`.
  name
end struct

// Store the parsed data and relationships for one WAD archive.
struct WadArchive
  /// Stores the filename value in `miniquake.types.WadArchive`.
  filename
  /// Stores the data value in `miniquake.types.WadArchive`.
  data
  /// Stores the lumps value in `miniquake.types.WadArchive`.
  lumps
  /// Stores the num lumps value in `miniquake.types.WadArchive`.
  numLumps
end struct

// Track storage and runtime state for one loop socket.
struct LoopSocket
  /// Stores the peer value in `miniquake.types.LoopSocket`.
  peer
  /// Stores the messages value in `miniquake.types.LoopSocket`.
  messages
  /// Stores the message types value in `miniquake.types.LoopSocket`.
  messageTypes
  /// Stores the can send value in `miniquake.types.LoopSocket`.
  canSend
  /// Stores the disconnected value in `miniquake.types.LoopSocket`.
  disconnected
  /// Stores the transport value in `miniquake.types.LoopSocket`.
  transport
  /// Stores the udp value in `miniquake.types.LoopSocket`.
  udp
  /// Stores the address value in `miniquake.types.LoopSocket`.
  address
  /// Stores the port value in `miniquake.types.LoopSocket`.
  port
  /// Stores the channel value in `miniquake.types.LoopSocket`.
  channel
  /// Stores the last receive time value in `miniquake.types.LoopSocket`.
  lastReceiveTime
  /// Stores the connect time value in `miniquake.types.LoopSocket`.
  connectTime
  /// Stores the last send time value in `miniquake.types.LoopSocket`.
  lastSendTime
  /// Stores the driver value in `miniquake.types.LoopSocket`.
  driver
  /// Stores the landriver value in `miniquake.types.LoopSocket`.
  landriver
end struct

// Track mutable loop state across subsystem calls.
struct LoopState
  /// Stores the client value in `miniquake.types.LoopState`.
  client
  /// Stores the server value in `miniquake.types.LoopState`.
  server
  /// Stores the pending value in `miniquake.types.LoopState`.
  pending
  /// Stores the listener value in `miniquake.types.LoopState`.
  listener
  /// Stores the pending remote value in `miniquake.types.LoopState`.
  pendingRemote
  /// Stores the host name value in `miniquake.types.LoopState`.
  hostName
  /// Stores the map name value in `miniquake.types.LoopState`.
  mapName
  /// Stores the current players value in `miniquake.types.LoopState`.
  currentPlayers
  /// Stores the max players value in `miniquake.types.LoopState`.
  maxPlayers
  /// Stores the remote sockets value in `miniquake.types.LoopState`.
  remoteSockets
  /// Stores the host cache value in `miniquake.types.LoopState`.
  hostCache
  /// Stores the ban address value in `miniquake.types.LoopState`.
  banAddress
  /// Stores the ban mask value in `miniquake.types.LoopState`.
  banMask
  /// Stores the player info value in `miniquake.types.LoopState`.
  playerInfo
  /// Stores the server rules value in `miniquake.types.LoopState`.
  serverRules
  /// Stores the lan enabled value in `miniquake.types.LoopState`.
  lanEnabled
end struct

// Group the fields that describe one memory block.
struct MemoryBlock
  /// Stores the kind value in `miniquake.types.MemoryBlock`.
  kind
  /// Stores the name value in `miniquake.types.MemoryBlock`.
  name
  /// Stores the data value in `miniquake.types.MemoryBlock`.
  data
  /// Stores the size value in `miniquake.types.MemoryBlock`.
  size
  /// Stores the alive value in `miniquake.types.MemoryBlock`.
  alive
  /// Stores the allocation index value in `miniquake.types.MemoryBlock`.
  allocationIndex
end struct

// Track mutable memory state across subsystem calls.
struct MemoryState
  /// Stores the capacity value in `miniquake.types.MemoryState`.
  capacity
  /// Stores the blocks value in `miniquake.types.MemoryState`.
  blocks
  /// Stores the total allocated value in `miniquake.types.MemoryState`.
  totalAllocated
end struct

// Group the fields that describe one cache user.
struct CacheUser
  /// Stores the block value in `miniquake.types.CacheUser`.
  block
end struct

// Group the fields that describe one hull.
struct Hull
  /// Stores the mins value in `miniquake.types.Hull`.
  mins
  /// Stores the maxs value in `miniquake.types.Hull`.
  maxs
end struct

// Group the fields that describe one trace.
struct Trace
  /// Stores the all solid value in `miniquake.types.Trace`.
  allSolid
  /// Stores the start solid value in `miniquake.types.Trace`.
  startSolid
  /// Stores the in open value in `miniquake.types.Trace`.
  inOpen
  /// Stores the in water value in `miniquake.types.Trace`.
  inWater
  /// Stores the fraction value in `miniquake.types.Trace`.
  fraction
  /// Stores the end position value in `miniquake.types.Trace`.
  endPosition
  /// Stores the plane value in `miniquake.types.Trace`.
  plane
  /// Stores the entity value in `miniquake.types.Trace`.
  entity
end struct

// Group the fields that describe one entity pair.
struct EntityPair
  /// Stores the key value in `miniquake.types.EntityPair`.
  key
  /// Stores the entity-pair value in `miniquake.types.EntityPair`.
  value
end struct

// Group the fields that describe one entity.
struct Entity
  /// Stores the pairs value in `miniquake.types.Entity`.
  pairs
end struct

// Group the fields that describe one lump.
struct Lump
  /// Stores the offset value in `miniquake.types.Lump`.
  offset
  /// Stores the length value in `miniquake.types.Lump`.
  length
end struct

// Describe one BSP plane consumed by the renderer or asset loader.
struct BspPlane
  /// Stores the normal value in `miniquake.types.BspPlane`.
  normal
  /// Stores the dist value in `miniquake.types.BspPlane`.
  dist
  /// Stores the type value in `miniquake.types.BspPlane`.
  type
end struct

// Describe one BSP vertex consumed by the renderer or asset loader.
struct BspVertex
  /// Stores the position value in `miniquake.types.BspVertex`.
  position
end struct

// Describe one BSP edge consumed by the renderer or asset loader.
struct BspEdge
  /// Stores the vertex0 value in `miniquake.types.BspEdge`.
  vertex0
  /// Stores the vertex1 value in `miniquake.types.BspEdge`.
  vertex1
end struct

// Group the fields that describe one BSP node.
struct BspNode
  /// Stores the plane index value in `miniquake.types.BspNode`.
  planeIndex
  /// Stores the child0 value in `miniquake.types.BspNode`.
  child0
  /// Stores the child1 value in `miniquake.types.BspNode`.
  child1
  /// Stores the mins value in `miniquake.types.BspNode`.
  mins
  /// Stores the maxs value in `miniquake.types.BspNode`.
  maxs
  /// Stores the first face value in `miniquake.types.BspNode`.
  firstFace
  /// Stores the num faces value in `miniquake.types.BspNode`.
  numFaces
end struct

// Group the fields that describe one BSP clip node.
struct BspClipNode
  /// Stores the plane index value in `miniquake.types.BspClipNode`.
  planeIndex
  /// Stores the child0 value in `miniquake.types.BspClipNode`.
  child0
  /// Stores the child1 value in `miniquake.types.BspClipNode`.
  child1
end struct

// Group the fields that describe one BSP tex info.
struct BspTexInfo
  /// Stores the s value in `miniquake.types.BspTexInfo`.
  s
  /// Stores the t value in `miniquake.types.BspTexInfo`.
  t
  /// Stores the texture index value in `miniquake.types.BspTexInfo`.
  textureIndex
  /// Stores the flags value in `miniquake.types.BspTexInfo`.
  flags
end struct

// Describe one BSP face consumed by the renderer or asset loader.
struct BspFace
  /// Stores the plane index value in `miniquake.types.BspFace`.
  planeIndex
  /// Stores the side value in `miniquake.types.BspFace`.
  side
  /// Stores the first edge value in `miniquake.types.BspFace`.
  firstEdge
  /// Stores the num edges value in `miniquake.types.BspFace`.
  numEdges
  /// Stores the tex info value in `miniquake.types.BspFace`.
  texInfo
  /// Stores the styles value in `miniquake.types.BspFace`.
  styles
  /// Stores the light offset value in `miniquake.types.BspFace`.
  lightOffset
end struct

// Group the fields that describe one BSP leaf.
struct BspLeaf
  /// Stores the contents value in `miniquake.types.BspLeaf`.
  contents
  /// Stores the visibility offset value in `miniquake.types.BspLeaf`.
  visibilityOffset
  /// Stores the mins value in `miniquake.types.BspLeaf`.
  mins
  /// Stores the maxs value in `miniquake.types.BspLeaf`.
  maxs
  /// Stores the first mark surface value in `miniquake.types.BspLeaf`.
  firstMarkSurface
  /// Stores the num mark surfaces value in `miniquake.types.BspLeaf`.
  numMarkSurfaces
  /// Stores the ambient value in `miniquake.types.BspLeaf`.
  ambient
end struct

// Store the parsed data and relationships for one BSP model.
struct BspModel
  /// Stores the mins value in `miniquake.types.BspModel`.
  mins
  /// Stores the maxs value in `miniquake.types.BspModel`.
  maxs
  /// Stores the origin value in `miniquake.types.BspModel`.
  origin
  /// Stores the head nodes value in `miniquake.types.BspModel`.
  headNodes
  /// Stores the visible leafs value in `miniquake.types.BspModel`.
  visibleLeafs
  /// Stores the first face value in `miniquake.types.BspModel`.
  firstFace
  /// Stores the num faces value in `miniquake.types.BspModel`.
  numFaces
end struct

// Describe one BSP texture consumed by the renderer or asset loader.
struct BspTexture
  /// Stores the name value in `miniquake.types.BspTexture`.
  name
  /// Stores the width value in `miniquake.types.BspTexture`.
  width
  /// Stores the height value in `miniquake.types.BspTexture`.
  height
  /// Stores the mip offsets value in `miniquake.types.BspTexture`.
  mipOffsets
  /// Stores the pixels value in `miniquake.types.BspTexture`.
  pixels
end struct

// Store the parsed data and relationships for one BSP map.
struct BspMap
  /// Stores the filename value in `miniquake.types.BspMap`.
  filename
  /// Stores the data value in `miniquake.types.BspMap`.
  data
  /// Stores the version value in `miniquake.types.BspMap`.
  version
  /// Stores the lumps value in `miniquake.types.BspMap`.
  lumps
  /// Stores the entity text value in `miniquake.types.BspMap`.
  entityText
  /// Stores the entities value in `miniquake.types.BspMap`.
  entities
  /// Stores the planes value in `miniquake.types.BspMap`.
  planes
  /// Stores the textures value in `miniquake.types.BspMap`.
  textures
  /// Stores the vertices value in `miniquake.types.BspMap`.
  vertices
  /// Stores the visibility value in `miniquake.types.BspMap`.
  visibility
  /// Stores the nodes value in `miniquake.types.BspMap`.
  nodes
  /// Stores the tex info value in `miniquake.types.BspMap`.
  texInfo
  /// Stores the faces value in `miniquake.types.BspMap`.
  faces
  /// Stores the lighting value in `miniquake.types.BspMap`.
  lighting
  /// Stores the clip nodes value in `miniquake.types.BspMap`.
  clipNodes
  /// Stores the leafs value in `miniquake.types.BspMap`.
  leafs
  /// Stores the mark surfaces value in `miniquake.types.BspMap`.
  markSurfaces
  /// Stores the edges value in `miniquake.types.BspMap`.
  edges
  /// Stores the surf edges value in `miniquake.types.BspMap`.
  surfEdges
  /// Stores the models value in `miniquake.types.BspMap`.
  models
end struct

// Group the fields that describe one MDL skin.
struct MdlSkin
  /// Stores the grouped value in `miniquake.types.MdlSkin`.
  grouped
  /// Stores the intervals value in `miniquake.types.MdlSkin`.
  intervals
  /// Stores the images value in `miniquake.types.MdlSkin`.
  images
end struct

// Group the fields that describe one MDL tex coord.
struct MdlTexCoord
  /// Stores the on seam value in `miniquake.types.MdlTexCoord`.
  onSeam
  /// Stores the s value in `miniquake.types.MdlTexCoord`.
  s
  /// Stores the t value in `miniquake.types.MdlTexCoord`.
  t
end struct

// Group the fields that describe one MDL triangle.
struct MdlTriangle
  /// Stores the faces front value in `miniquake.types.MdlTriangle`.
  facesFront
  /// Stores the vertex0 value in `miniquake.types.MdlTriangle`.
  vertex0
  /// Stores the vertex1 value in `miniquake.types.MdlTriangle`.
  vertex1
  /// Stores the vertex2 value in `miniquake.types.MdlTriangle`.
  vertex2
end struct

// Describe one MDL vertex consumed by the renderer or asset loader.
struct MdlVertex
  /// Stores the x value in `miniquake.types.MdlVertex`.
  x
  /// Stores the y value in `miniquake.types.MdlVertex`.
  y
  /// Stores the z value in `miniquake.types.MdlVertex`.
  z
  /// Stores the normal index value in `miniquake.types.MdlVertex`.
  normalIndex
end struct

// Describe one runtime MDL frame and its observable Quake state.
struct MdlFrame
  /// Stores the name value in `miniquake.types.MdlFrame`.
  name
  /// Stores the mins value in `miniquake.types.MdlFrame`.
  mins
  /// Stores the maxs value in `miniquake.types.MdlFrame`.
  maxs
  /// Stores the vertices value in `miniquake.types.MdlFrame`.
  vertices
end struct

// Group the fields that describe one MDL frame set.
struct MdlFrameSet
  /// Stores the grouped value in `miniquake.types.MdlFrameSet`.
  grouped
  /// Stores the intervals value in `miniquake.types.MdlFrameSet`.
  intervals
  /// Stores the frames value in `miniquake.types.MdlFrameSet`.
  frames
end struct

// Store the parsed data and relationships for one MDL model.
struct MdlModel
  /// Stores the filename value in `miniquake.types.MdlModel`.
  filename
  /// Stores the data value in `miniquake.types.MdlModel`.
  data
  /// Stores the version value in `miniquake.types.MdlModel`.
  version
  /// Stores the scale value in `miniquake.types.MdlModel`.
  scale
  /// Stores the scale origin value in `miniquake.types.MdlModel`.
  scaleOrigin
  /// Stores the bounding radius value in `miniquake.types.MdlModel`.
  boundingRadius
  /// Stores the eye position value in `miniquake.types.MdlModel`.
  eyePosition
  /// Stores the num skins value in `miniquake.types.MdlModel`.
  numSkins
  /// Stores the skin width value in `miniquake.types.MdlModel`.
  skinWidth
  /// Stores the skin height value in `miniquake.types.MdlModel`.
  skinHeight
  /// Stores the num vertices value in `miniquake.types.MdlModel`.
  numVertices
  /// Stores the num triangles value in `miniquake.types.MdlModel`.
  numTriangles
  /// Stores the num frames value in `miniquake.types.MdlModel`.
  numFrames
  /// Stores the sync type value in `miniquake.types.MdlModel`.
  syncType
  /// Stores the flags value in `miniquake.types.MdlModel`.
  flags
  /// Stores the size value in `miniquake.types.MdlModel`.
  size
  /// Stores the skins value in `miniquake.types.MdlModel`.
  skins
  /// Stores the tex coords value in `miniquake.types.MdlModel`.
  texCoords
  /// Stores the triangles value in `miniquake.types.MdlModel`.
  triangles
  /// Stores the frames value in `miniquake.types.MdlModel`.
  frames
end struct

// Describe one runtime sprite frame and its observable Quake state.
struct SpriteFrame
  /// Stores the origin x value in `miniquake.types.SpriteFrame`.
  originX
  /// Stores the origin y value in `miniquake.types.SpriteFrame`.
  originY
  /// Stores the width value in `miniquake.types.SpriteFrame`.
  width
  /// Stores the height value in `miniquake.types.SpriteFrame`.
  height
  /// Stores the pixels value in `miniquake.types.SpriteFrame`.
  pixels
end struct

// Group the fields that describe one sprite frame set.
struct SpriteFrameSet
  /// Stores the grouped value in `miniquake.types.SpriteFrameSet`.
  grouped
  /// Stores the intervals value in `miniquake.types.SpriteFrameSet`.
  intervals
  /// Stores the frames value in `miniquake.types.SpriteFrameSet`.
  frames
end struct

// Store the parsed data and relationships for one sprite model.
struct SpriteModel
  /// Stores the filename value in `miniquake.types.SpriteModel`.
  filename
  /// Stores the data value in `miniquake.types.SpriteModel`.
  data
  /// Stores the version value in `miniquake.types.SpriteModel`.
  version
  /// Stores the type value in `miniquake.types.SpriteModel`.
  type
  /// Stores the bounding radius value in `miniquake.types.SpriteModel`.
  boundingRadius
  /// Stores the width value in `miniquake.types.SpriteModel`.
  width
  /// Stores the height value in `miniquake.types.SpriteModel`.
  height
  /// Stores the num frames value in `miniquake.types.SpriteModel`.
  numFrames
  /// Stores the beam length value in `miniquake.types.SpriteModel`.
  beamLength
  /// Stores the sync type value in `miniquake.types.SpriteModel`.
  syncType
  /// Stores the frames value in `miniquake.types.SpriteModel`.
  frames
end struct

// Group the fields that describe one QuakeC statement.
struct QuakeCStatement
  /// Stores the op value in `miniquake.types.QuakeCStatement`.
  op
  /// Stores the a value in `miniquake.types.QuakeCStatement`.
  a
  /// Stores the b value in `miniquake.types.QuakeCStatement`.
  b
  /// Stores the c value in `miniquake.types.QuakeCStatement`.
  c
end struct

// Group the fields that describe one QuakeC def.
struct QuakeCDef
  /// Stores the type value in `miniquake.types.QuakeCDef`.
  type
  /// Stores the offset value in `miniquake.types.QuakeCDef`.
  offset
  /// Stores the name offset value in `miniquake.types.QuakeCDef`.
  nameOffset
  /// Stores the name value in `miniquake.types.QuakeCDef`.
  name
end struct

// Group the fields that describe one QuakeC function.
struct QuakeCFunction
  /// Stores the first statement value in `miniquake.types.QuakeCFunction`.
  firstStatement
  /// Stores the parm start value in `miniquake.types.QuakeCFunction`.
  parmStart
  /// Stores the locals value in `miniquake.types.QuakeCFunction`.
  locals
  /// Stores the profile value in `miniquake.types.QuakeCFunction`.
  profile
  /// Stores the name value in `miniquake.types.QuakeCFunction`.
  name
  /// Stores the file value in `miniquake.types.QuakeCFunction`.
  file
  /// Stores the num parms value in `miniquake.types.QuakeCFunction`.
  numParms
  /// Stores the parm size value in `miniquake.types.QuakeCFunction`.
  parmSize
end struct

// Store the parsed data and relationships for one QuakeC program.
struct QuakeCProgram
  /// Stores the filename value in `miniquake.types.QuakeCProgram`.
  filename
  /// Stores the data value in `miniquake.types.QuakeCProgram`.
  data
  /// Stores the version value in `miniquake.types.QuakeCProgram`.
  version
  /// Stores the crc value in `miniquake.types.QuakeCProgram`.
  crc
  /// Stores the statements value in `miniquake.types.QuakeCProgram`.
  statements
  /// Stores the global defs value in `miniquake.types.QuakeCProgram`.
  globalDefs
  /// Stores the field defs value in `miniquake.types.QuakeCProgram`.
  fieldDefs
  /// Stores the functions value in `miniquake.types.QuakeCProgram`.
  functions
  /// Stores the strings value in `miniquake.types.QuakeCProgram`.
  strings
  /// Stores the globals value in `miniquake.types.QuakeCProgram`.
  globals
  /// Stores the entity fields value in `miniquake.types.QuakeCProgram`.
  entityFields
end struct

// Describe one runtime QuakeC call frame and its observable Quake state.
struct QuakeCCallFrame
  /// Stores the statement value in `miniquake.types.QuakeCCallFrame`.
  statement
  /// Stores the function index value in `miniquake.types.QuakeCCallFrame`.
  functionIndex
  /// Stores the saved locals value in `miniquake.types.QuakeCCallFrame`.
  savedLocals
end struct

// Group the fields that describe one QuakeC machine.
struct QuakeCMachine
  /// Stores the program value in `miniquake.types.QuakeCMachine`.
  program
  /// Stores the globals value in `miniquake.types.QuakeCMachine`.
  globals
  /// Stores the call stack value in `miniquake.types.QuakeCMachine`.
  callStack
  /// Stores the current function value in `miniquake.types.QuakeCMachine`.
  currentFunction
  /// Stores the statement value in `miniquake.types.QuakeCMachine`.
  statement
  /// Stores the return word value in `miniquake.types.QuakeCMachine`.
  returnWord
  /// Stores the arg count value in `miniquake.types.QuakeCMachine`.
  argCount
  /// Stores the edicts value in `miniquake.types.QuakeCMachine`.
  edicts
  /// Stores the builtins value in `miniquake.types.QuakeCMachine`.
  builtins
  /// Stores the runaway value in `miniquake.types.QuakeCMachine`.
  runaway
  /// Stores the context value in `miniquake.types.QuakeCMachine`.
  context
  /// Stores the edict free value in `miniquake.types.QuakeCMachine`.
  edictFree
  /// Stores the dynamic strings value in `miniquake.types.QuakeCMachine`.
  dynamicStrings
  /// Stores the temporary string value in `miniquake.types.QuakeCMachine`.
  temporaryString
  /// Stores the random seed value in `miniquake.types.QuakeCMachine`.
  randomSeed
  /// Stores the trace value in `miniquake.types.QuakeCMachine`.
  trace
  /// Stores the fast statements value in `miniquake.types.QuakeCMachine`.
  fastStatements
  /// Stores the fast functions value in `miniquake.types.QuakeCMachine`.
  fastFunctions
  /// Stores the fast local bases value in `miniquake.types.QuakeCMachine`.
  fastLocalBases
  /// Stores the fast local counts value in `miniquake.types.QuakeCMachine`.
  fastLocalCounts
  /// Stores the fast saved locals value in `miniquake.types.QuakeCMachine`.
  fastSavedLocals
  /// Stores the fast depth value in `miniquake.types.QuakeCMachine`.
  fastDepth
  /// Stores the fast local depth value in `miniquake.types.QuakeCMachine`.
  fastLocalDepth
  /// Stores the fast execution depth value in `miniquake.types.QuakeCMachine`.
  fastExecutionDepth
end struct

// Group the fields that describe one wave info.
struct WaveInfo
  /// Stores the rate value in `miniquake.types.WaveInfo`.
  rate
  /// Stores the width value in `miniquake.types.WaveInfo`.
  width
  /// Stores the channels value in `miniquake.types.WaveInfo`.
  channels
  /// Stores the samples value in `miniquake.types.WaveInfo`.
  samples
  /// Stores the loop start value in `miniquake.types.WaveInfo`.
  loopStart
  /// Stores the data offset value in `miniquake.types.WaveInfo`.
  dataOffset
  /// Stores the data length value in `miniquake.types.WaveInfo`.
  dataLength
end struct

// Group the fields that describe one demo message.
struct DemoMessage
  /// Stores the view angles value in `miniquake.types.DemoMessage`.
  viewAngles
  /// Stores the payload value in `miniquake.types.DemoMessage`.
  payload
end struct

// Group the fields that describe one demo.
struct Demo
  /// Stores the forced track value in `miniquake.types.Demo`.
  forcedTrack
  /// Stores the messages value in `miniquake.types.Demo`.
  messages
  /// Stores the track header value in `miniquake.types.Demo`.
  trackHeader
end struct

// Group the fields that describe one save game.
struct SaveGame
  /// Stores the version value in `miniquake.types.SaveGame`.
  version
  /// Stores the comment value in `miniquake.types.SaveGame`.
  comment
  /// Stores the spawn parms value in `miniquake.types.SaveGame`.
  spawnParms
  /// Stores the skill value in `miniquake.types.SaveGame`.
  skill
  /// Stores the map name value in `miniquake.types.SaveGame`.
  mapName
  /// Stores the time value in `miniquake.types.SaveGame`.
  time
  /// Stores the light styles value in `miniquake.types.SaveGame`.
  lightStyles
  /// Stores the global state value in `miniquake.types.SaveGame`.
  globalState
  /// Stores the entities value in `miniquake.types.SaveGame`.
  entities
end struct

// Group the fields that describe one protocol event.
struct ProtocolEvent
  /// Stores the command value in `miniquake.types.ProtocolEvent`.
  command
  /// Stores the payload value in `miniquake.types.ProtocolEvent`.
  payload
end struct

// Collect the outcome and diagnostics for one protocol result.
struct ProtocolResult
  /// Stores the events value in `miniquake.types.ProtocolResult`.
  events
  /// Stores the bytes read value in `miniquake.types.ProtocolResult`.
  bytesRead
end struct

// Canonical input record for the stock Protocol-15 svc_clientdata writer.
// Keeping the wire state separate from PlayerState makes the C field ordering
// and mission-pack active-weapon rule directly testable.
struct ProtocolClientData
  /// Stores the view height value in `miniquake.types.ProtocolClientData`.
  viewHeight
  /// Stores the ideal pitch value in `miniquake.types.ProtocolClientData`.
  idealPitch
  /// Stores the punch value in `miniquake.types.ProtocolClientData`.
  punch
  /// Stores the velocity value in `miniquake.types.ProtocolClientData`.
  velocity
  /// Stores the flags value in `miniquake.types.ProtocolClientData`.
  flags
  /// Stores the water level value in `miniquake.types.ProtocolClientData`.
  waterLevel
  /// Stores the weapon frame value in `miniquake.types.ProtocolClientData`.
  weaponFrame
  /// Stores the armor value in `miniquake.types.ProtocolClientData`.
  armor
  /// Stores the weapon model value in `miniquake.types.ProtocolClientData`.
  weaponModel
  /// Stores the health value in `miniquake.types.ProtocolClientData`.
  health
  /// Stores the current ammo value in `miniquake.types.ProtocolClientData`.
  currentAmmo
  /// Stores the shells value in `miniquake.types.ProtocolClientData`.
  shells
  /// Stores the nails value in `miniquake.types.ProtocolClientData`.
  nails
  /// Stores the rockets value in `miniquake.types.ProtocolClientData`.
  rockets
  /// Stores the cells value in `miniquake.types.ProtocolClientData`.
  cells
  /// Stores the items value in `miniquake.types.ProtocolClientData`.
  items
  /// Stores the active weapon value in `miniquake.types.ProtocolClientData`.
  activeWeapon
  /// Stores the standard quake value in `miniquake.types.ProtocolClientData`.
  standardQuake
end struct

// Group the fields that describe one search path.
struct SearchPath
  /// Stores the directory value in `miniquake.types.SearchPath`.
  directory
  /// Stores the archive value in `miniquake.types.SearchPath`.
  archive
end struct

// Own the coordinated data required by the file system.
struct FileSystem
  /// Stores the base directory value in `miniquake.types.FileSystem`.
  baseDirectory
  /// Stores the game directory value in `miniquake.types.FileSystem`.
  gameDirectory
  /// Stores the search paths value in `miniquake.types.FileSystem`.
  searchPaths
  /// Stores the cache directory value in `miniquake.types.FileSystem`.
  cacheDirectory
  /// Stores the modified value in `miniquake.types.FileSystem`.
  modified
  /// Stores the registered value in `miniquake.types.FileSystem`.
  registered
  /// Stores the static registered value in `miniquake.types.FileSystem`.
  staticRegistered
  /// Stores the progs hack value in `miniquake.types.FileSystem`.
  progsHack
end struct

// Own the coordinated data required by the model registry.
struct ModelRegistry
  /// Stores the names value in `miniquake.types.ModelRegistry`.
  names
  /// Stores the models value in `miniquake.types.ModelRegistry`.
  models
  /// Stores the need load value in `miniquake.types.ModelRegistry`.
  needLoad
  /// Stores the types value in `miniquake.types.ModelRegistry`.
  types
  /// Stores the touched value in `miniquake.types.ModelRegistry`.
  touched
  /// Stores the no vis value in `miniquake.types.ModelRegistry`.
  noVis
end struct

// Group the fields that describe one user command.
struct UserCommand
  /// Stores the view angles value in `miniquake.types.UserCommand`.
  viewAngles
  /// Stores the forward move value in `miniquake.types.UserCommand`.
  forwardMove
  /// Stores the side move value in `miniquake.types.UserCommand`.
  sideMove
  /// Stores the up move value in `miniquake.types.UserCommand`.
  upMove
  /// Stores the buttons value in `miniquake.types.UserCommand`.
  buttons
  /// Stores the impulse value in `miniquake.types.UserCommand`.
  impulse
  /// Stores the msec value in `miniquake.types.UserCommand`.
  msec
end struct

// Track mutable chase state across subsystem calls.
struct ChaseState
  /// Stores the active value in `miniquake.types.ChaseState`.
  active
  /// Stores the back value in `miniquake.types.ChaseState`.
  back
  /// Stores the up value in `miniquake.types.ChaseState`.
  up
  /// Stores the right value in `miniquake.types.ChaseState`.
  right
end struct


// Track mutable client state across subsystem calls.
struct ClientState
  /// Stores the protocol value in `miniquake.types.ClientState`.
  protocol
  /// Stores the time value in `miniquake.types.ClientState`.
  time
  /// Stores the view entity value in `miniquake.types.ClientState`.
  viewEntity
  /// Stores the view angles value in `miniquake.types.ClientState`.
  viewAngles
  /// Stores the entities value in `miniquake.types.ClientState`.
  entities
  /// Stores the stats value in `miniquake.types.ClientState`.
  stats
  /// Stores the messages value in `miniquake.types.ClientState`.
  messages
end struct

// Track mutable server state across subsystem calls.
struct ServerState
  /// Stores the active value in `miniquake.types.ServerState`.
  active
  /// Stores the time value in `miniquake.types.ServerState`.
  time
  /// Stores the map name value in `miniquake.types.ServerState`.
  mapName
  /// Stores the clients value in `miniquake.types.ServerState`.
  clients
  /// Stores the entities value in `miniquake.types.ServerState`.
  entities
  /// Stores the reliable datagram value in `miniquake.types.ServerState`.
  reliableDatagram
end struct

// Group the fields that describe one particle.
struct Particle
  /// Stores the origin value in `miniquake.types.Particle`.
  origin
  /// Stores the velocity value in `miniquake.types.Particle`.
  velocity
  /// Stores the die value in `miniquake.types.Particle`.
  die
  /// Stores the color value in `miniquake.types.Particle`.
  color
  /// Stores the ramp value in `miniquake.types.Particle`.
  ramp
  /// Stores the type value in `miniquake.types.Particle`.
  type
end struct

// Describe one runtime temporary entity and its observable Quake state.
struct TemporaryEntity
  /// Stores the type value in `miniquake.types.TemporaryEntity`.
  type
  /// Stores the origin value in `miniquake.types.TemporaryEntity`.
  origin
  /// Stores the end position value in `miniquake.types.TemporaryEntity`.
  endPosition
  /// Stores the entity value in `miniquake.types.TemporaryEntity`.
  entity
end struct

// Track mutable audio state across subsystem calls.
struct AudioState
  /// Stores the opened value in `miniquake.types.AudioState`.
  opened
  /// Stores the rate value in `miniquake.types.AudioState`.
  rate
  /// Stores the channels value in `miniquake.types.AudioState`.
  channels
  /// Stores the width value in `miniquake.types.AudioState`.
  width
end struct

// -----------------------------------------------------------------------------
// Playable-engine milestone state.  The original lightweight structs above are
// kept for the format/protocol tools; these structs mirror the long-lived host,
// server, client, collision and renderer state used by the real game loop.
// -----------------------------------------------------------------------------

struct CommandLine
  /// Stores the args value in `miniquake.types.CommandLine`.
  args
  /// Stores the command line value in `miniquake.types.CommandLine`.
  commandLine
  /// Stores the safe mode value in `miniquake.types.CommandLine`.
  safeMode
  /// Stores the rogue value in `miniquake.types.CommandLine`.
  rogue
  /// Stores the hipnotic value in `miniquake.types.CommandLine`.
  hipnotic
  /// Stores the standard quake value in `miniquake.types.CommandLine`.
  standardQuake
end struct

// Group the fields that describe one host timing.
struct HostTiming
  /// Stores the realtime value in `miniquake.types.HostTiming`.
  realtime
  /// Stores the old realtime value in `miniquake.types.HostTiming`.
  oldRealtime
  /// Stores the frame time value in `miniquake.types.HostTiming`.
  frameTime
  /// Stores the frame count value in `miniquake.types.HostTiming`.
  frameCount
  /// Stores the filtered frames value in `miniquake.types.HostTiming`.
  filteredFrames
end struct

// Group the fields that describe one entity baseline.
struct EntityBaseline
  /// Stores the model index value in `miniquake.types.EntityBaseline`.
  modelIndex
  /// Stores the frame value in `miniquake.types.EntityBaseline`.
  frame
  /// Stores the colormap value in `miniquake.types.EntityBaseline`.
  colormap
  /// Stores the skin value in `miniquake.types.EntityBaseline`.
  skin
  /// Stores the effects value in `miniquake.types.EntityBaseline`.
  effects
  /// Stores the origin value in `miniquake.types.EntityBaseline`.
  origin
  /// Stores the angles value in `miniquake.types.EntityBaseline`.
  angles
end struct

// Describe one runtime quake edict and its observable Quake state.
struct QuakeEdict
  /// Stores the number value in `miniquake.types.QuakeEdict`.
  number
  /// Stores the free value in `miniquake.types.QuakeEdict`.
  free
  /// Stores the free time value in `miniquake.types.QuakeEdict`.
  freeTime
  /// Stores the fields value in `miniquake.types.QuakeEdict`.
  fields
  /// Stores the key values value in `miniquake.types.QuakeEdict`.
  keyValues
  /// Stores the class name value in `miniquake.types.QuakeEdict`.
  className
  /// Stores the model value in `miniquake.types.QuakeEdict`.
  model
  /// Stores the model handle value in `miniquake.types.QuakeEdict`.
  modelHandle
  /// Stores the model index value in `miniquake.types.QuakeEdict`.
  modelIndex
  /// Stores the frame value in `miniquake.types.QuakeEdict`.
  frame
  /// Stores the skin value in `miniquake.types.QuakeEdict`.
  skin
  /// Stores the colormap value in `miniquake.types.QuakeEdict`.
  colormap
  /// Stores the effects value in `miniquake.types.QuakeEdict`.
  effects
  /// Stores the origin value in `miniquake.types.QuakeEdict`.
  origin
  /// Stores the angles value in `miniquake.types.QuakeEdict`.
  angles
  /// Stores the velocity value in `miniquake.types.QuakeEdict`.
  velocity
  /// Stores the mins value in `miniquake.types.QuakeEdict`.
  mins
  /// Stores the maxs value in `miniquake.types.QuakeEdict`.
  maxs
  /// Stores the move type value in `miniquake.types.QuakeEdict`.
  moveType
  /// Stores the solid value in `miniquake.types.QuakeEdict`.
  solid
  /// Stores the flags value in `miniquake.types.QuakeEdict`.
  flags
  /// Stores the health value in `miniquake.types.QuakeEdict`.
  health
  /// Stores the view offset value in `miniquake.types.QuakeEdict`.
  viewOffset
  /// Stores the on ground value in `miniquake.types.QuakeEdict`.
  onGround
  /// Stores the ground entity value in `miniquake.types.QuakeEdict`.
  groundEntity
  /// Stores the baseline value in `miniquake.types.QuakeEdict`.
  baseline
  /// Stores the leaf nums value in `miniquake.types.QuakeEdict`.
  leafNums
end struct

// Group the fields that describe one server client.
struct ServerClient
  /// Stores the active value in `miniquake.types.ServerClient`.
  active
  /// Stores the spawned value in `miniquake.types.ServerClient`.
  spawned
  /// Stores the send signon value in `miniquake.types.ServerClient`.
  sendSignon
  /// Stores the signon stage value in `miniquake.types.ServerClient`.
  signonStage
  /// Stores the name value in `miniquake.types.ServerClient`.
  name
  /// Stores the colors value in `miniquake.types.ServerClient`.
  colors
  /// Stores the privileged value in `miniquake.types.ServerClient`.
  privileged
  /// Stores the edict index value in `miniquake.types.ServerClient`.
  edictIndex
  /// Stores the socket value in `miniquake.types.ServerClient`.
  socket
  /// Stores the message value in `miniquake.types.ServerClient`.
  message
  /// Stores the spawn parms value in `miniquake.types.ServerClient`.
  spawnParms
  /// Stores the command value in `miniquake.types.ServerClient`.
  command
  /// Stores the ping times value in `miniquake.types.ServerClient`.
  pingTimes
  /// Stores the num pings value in `miniquake.types.ServerClient`.
  numPings
  /// Stores the old frags value in `miniquake.types.ServerClient`.
  oldFrags
  /// Stores the last message value in `miniquake.types.ServerClient`.
  lastMessage
  /// Stores the drop asap value in `miniquake.types.ServerClient`.
  dropAsap
  /// Stores the player state value in `miniquake.types.ServerClient`.
  playerState
  /// Stores the datagram buffer value in `miniquake.types.ServerClient`.
  datagramBuffer
end struct

// Group the fields that describe one game server.
struct GameServer
  /// Stores the active value in `miniquake.types.GameServer`.
  active
  /// Stores the loading value in `miniquake.types.GameServer`.
  loading
  /// Stores the load game value in `miniquake.types.GameServer`.
  loadGame
  /// Stores the paused value in `miniquake.types.GameServer`.
  paused
  /// Stores the time value in `miniquake.types.GameServer`.
  time
  /// Stores the map name value in `miniquake.types.GameServer`.
  mapName
  /// Stores the model name value in `miniquake.types.GameServer`.
  modelName
  /// Stores the level name value in `miniquake.types.GameServer`.
  levelName
  /// Stores the world model value in `miniquake.types.GameServer`.
  worldModel
  /// Stores the progs value in `miniquake.types.GameServer`.
  progs
  /// Stores the machine value in `miniquake.types.GameServer`.
  machine
  /// Stores the edicts value in `miniquake.types.GameServer`.
  edicts
  /// Stores the num edicts value in `miniquake.types.GameServer`.
  numEdicts
  /// Stores the max edicts value in `miniquake.types.GameServer`.
  maxEdicts
  /// Stores the clients value in `miniquake.types.GameServer`.
  clients
  /// Stores the max clients value in `miniquake.types.GameServer`.
  maxClients
  /// Stores the model precache value in `miniquake.types.GameServer`.
  modelPrecache
  /// Stores the sound precache value in `miniquake.types.GameServer`.
  soundPrecache
  /// Stores the light styles value in `miniquake.types.GameServer`.
  lightStyles
  /// Stores the datagram value in `miniquake.types.GameServer`.
  datagram
  /// Stores the reliable datagram value in `miniquake.types.GameServer`.
  reliableDatagram
  /// Stores the signon value in `miniquake.types.GameServer`.
  signon
  /// Stores the collision hull value in `miniquake.types.GameServer`.
  collisionHull
  /// Stores the spawn point value in `miniquake.types.GameServer`.
  spawnPoint
  /// Stores the spawn angles value in `miniquake.types.GameServer`.
  spawnAngles
  /// Stores the skill value in `miniquake.types.GameServer`.
  skill
  /// Stores the deathmatch value in `miniquake.types.GameServer`.
  deathmatch
  /// Stores the coop value in `miniquake.types.GameServer`.
  coop
  /// Stores the server flags value in `miniquake.types.GameServer`.
  serverFlags
  /// Stores the cd track value in `miniquake.types.GameServer`.
  cdTrack
  /// Stores the standard quake value in `miniquake.types.GameServer`.
  standardQuake
  /// Stores the random seed value in `miniquake.types.GameServer`.
  randomSeed
  /// Stores the diagnostics value in `miniquake.types.GameServer`.
  diagnostics
end struct

// Group the fields that describe one local client.
struct LocalClient
  /// Stores the connected value in `miniquake.types.LocalClient`.
  connected
  /// Stores the signon value in `miniquake.types.LocalClient`.
  signon
  /// Stores the spawned value in `miniquake.types.LocalClient`.
  spawned
  /// Stores the socket value in `miniquake.types.LocalClient`.
  socket
  /// Stores the outgoing value in `miniquake.types.LocalClient`.
  outgoing
  /// Stores the incoming value in `miniquake.types.LocalClient`.
  incoming
  /// Stores the protocol value in `miniquake.types.LocalClient`.
  protocol
  /// Stores the max clients value in `miniquake.types.LocalClient`.
  maxClients
  /// Stores the game type value in `miniquake.types.LocalClient`.
  gameType
  /// Stores the level name value in `miniquake.types.LocalClient`.
  levelName
  /// Stores the model precache value in `miniquake.types.LocalClient`.
  modelPrecache
  /// Stores the sound precache value in `miniquake.types.LocalClient`.
  soundPrecache
  /// Stores the view entity value in `miniquake.types.LocalClient`.
  viewEntity
  /// Stores the server time value in `miniquake.types.LocalClient`.
  serverTime
  /// Stores the messages value in `miniquake.types.LocalClient`.
  messages
  /// Stores the print log value in `miniquake.types.LocalClient`.
  printLog
  /// Stores the entities value in `miniquake.types.LocalClient`.
  entities
  /// Stores the static entities value in `miniquake.types.LocalClient`.
  staticEntities
  /// Stores the player value in `miniquake.types.LocalClient`.
  player
  /// Stores the last message time value in `miniquake.types.LocalClient`.
  lastMessageTime
  /// Stores the command value in `miniquake.types.LocalClient`.
  command
  /// Stores the name value in `miniquake.types.LocalClient`.
  name
  /// Stores the colors value in `miniquake.types.LocalClient`.
  colors
  /// Stores the local authoritative value in `miniquake.types.LocalClient`.
  localAuthoritative
  /// Stores the scores value in `miniquake.types.LocalClient`.
  scores
  /// Stores the stats value in `miniquake.types.LocalClient`.
  stats
  /// Stores the item get time value in `miniquake.types.LocalClient`.
  itemGetTime
  /// Stores the completed time value in `miniquake.types.LocalClient`.
  completedTime
  /// Stores the face anim time value in `miniquake.types.LocalClient`.
  faceAnimTime
  /// Stores the items value in `miniquake.types.LocalClient`.
  items
  /// Stores the ideal pitch value in `miniquake.types.LocalClient`.
  idealPitch
  /// Stores the time value in `miniquake.types.LocalClient`.
  time
  /// Stores the old time value in `miniquake.types.LocalClient`.
  oldTime
  /// Stores the message times value in `miniquake.types.LocalClient`.
  messageTimes
  /// Stores the velocity samples value in `miniquake.types.LocalClient`.
  velocitySamples
  /// Stores the view angle samples value in `miniquake.types.LocalClient`.
  viewAngleSamples
  /// Stores the spawn parms value in `miniquake.types.LocalClient`.
  spawnParms
  /// Stores the visible entities value in `miniquake.types.LocalClient`.
  visibleEntities
  /// Stores the initialized value in `miniquake.types.LocalClient`.
  initialized
  /// Stores the demo playback value in `miniquake.types.LocalClient`.
  demoPlayback
  /// Stores the timedemo value in `miniquake.types.LocalClient`.
  timedemo
  /// Stores the no lerp value in `miniquake.types.LocalClient`.
  noLerp
  /// Stores the light styles value in `miniquake.types.LocalClient`.
  lightStyles
  /// Stores the paused value in `miniquake.types.LocalClient`.
  paused
  /// Stores the intermission value in `miniquake.types.LocalClient`.
  intermission
  /// Stores the intermission text value in `miniquake.types.LocalClient`.
  intermissionText
  /// Stores the cd track value in `miniquake.types.LocalClient`.
  cdTrack
  /// Stores the loop track value in `miniquake.types.LocalClient`.
  loopTrack
  /// Stores the sell screen value in `miniquake.types.LocalClient`.
  sellScreen
  /// Stores the standard quake value in `miniquake.types.LocalClient`.
  standardQuake
end struct

// Group the fields that describe one client score.
struct ClientScore
  /// Stores the name value in `miniquake.types.ClientScore`.
  name
  /// Stores the enter time value in `miniquake.types.ClientScore`.
  enterTime
  /// Stores the frags value in `miniquake.types.ClientScore`.
  frags
  /// Stores the colors value in `miniquake.types.ClientScore`.
  colors
end struct

// Track mutable player state across subsystem calls.
struct PlayerState
  /// Stores the origin value in `miniquake.types.PlayerState`.
  origin
  /// Stores the velocity value in `miniquake.types.PlayerState`.
  velocity
  /// Stores the view angles value in `miniquake.types.PlayerState`.
  viewAngles
  /// Stores the render angles value in `miniquake.types.PlayerState`.
  renderAngles
  /// Stores the mins value in `miniquake.types.PlayerState`.
  mins
  /// Stores the maxs value in `miniquake.types.PlayerState`.
  maxs
  /// Stores the view height value in `miniquake.types.PlayerState`.
  viewHeight
  /// Stores the on ground value in `miniquake.types.PlayerState`.
  onGround
  /// Stores the water level value in `miniquake.types.PlayerState`.
  waterLevel
  /// Stores the move type value in `miniquake.types.PlayerState`.
  moveType
  /// Stores the health value in `miniquake.types.PlayerState`.
  health
  /// Stores the armor value in `miniquake.types.PlayerState`.
  armor
  /// Stores the ammo value in `miniquake.types.PlayerState`.
  ammo
  /// Stores the shells value in `miniquake.types.PlayerState`.
  shells
  /// Stores the nails value in `miniquake.types.PlayerState`.
  nails
  /// Stores the rockets value in `miniquake.types.PlayerState`.
  rockets
  /// Stores the cells value in `miniquake.types.PlayerState`.
  cells
  /// Stores the items value in `miniquake.types.PlayerState`.
  items
  /// Stores the active weapon value in `miniquake.types.PlayerState`.
  activeWeapon
  /// Stores the weapon frame value in `miniquake.types.PlayerState`.
  weaponFrame
  /// Stores the weapon value in `miniquake.types.PlayerState`.
  weapon
  /// Stores the noclip value in `miniquake.types.PlayerState`.
  noclip
  /// Stores the jump held value in `miniquake.types.PlayerState`.
  jumpHeld
  /// Stores the flags value in `miniquake.types.PlayerState`.
  flags
  /// Stores the ground entity value in `miniquake.types.PlayerState`.
  groundEntity
  /// Stores the water type value in `miniquake.types.PlayerState`.
  waterType
  /// Stores the punch angle value in `miniquake.types.PlayerState`.
  punchAngle
  /// Stores the fix angle value in `miniquake.types.PlayerState`.
  fixAngle
  /// Stores the teleport time value in `miniquake.types.PlayerState`.
  teleportTime
  /// Stores the move dir value in `miniquake.types.PlayerState`.
  moveDir
  /// Stores the old origin value in `miniquake.types.PlayerState`.
  oldOrigin
  /// Stores the dead flag value in `miniquake.types.PlayerState`.
  deadFlag
end struct

// Store the parsed data and relationships for one BSP collision hull.
struct BspCollisionHull
  /// Stores the map value in `miniquake.types.BspCollisionHull`.
  map
  /// Stores the clip nodes value in `miniquake.types.BspCollisionHull`.
  clipNodes
  /// Stores the planes value in `miniquake.types.BspCollisionHull`.
  planes
  /// Stores the first clip node value in `miniquake.types.BspCollisionHull`.
  firstClipNode
  /// Stores the last clip node value in `miniquake.types.BspCollisionHull`.
  lastClipNode
  /// Stores the clip mins value in `miniquake.types.BspCollisionHull`.
  clipMins
  /// Stores the clip maxs value in `miniquake.types.BspCollisionHull`.
  clipMaxs
end struct

// Describe one render vertex consumed by the renderer or asset loader.
struct RenderVertex
  /// Stores the position value in `miniquake.types.RenderVertex`.
  position
  /// Stores the s value in `miniquake.types.RenderVertex`.
  s
  /// Stores the t value in `miniquake.types.RenderVertex`.
  t
  /// Stores the light s value in `miniquake.types.RenderVertex`.
  lightS
  /// Stores the light t value in `miniquake.types.RenderVertex`.
  lightT
end struct

// Describe one render surface consumed by the renderer or asset loader.
struct RenderSurface
  /// Stores the face index value in `miniquake.types.RenderSurface`.
  faceIndex
  /// Stores the texture index value in `miniquake.types.RenderSurface`.
  textureIndex
  /// Stores the texture mins value in `miniquake.types.RenderSurface`.
  textureMins
  /// Stores the extents value in `miniquake.types.RenderSurface`.
  extents
  /// Stores the light width value in `miniquake.types.RenderSurface`.
  lightWidth
  /// Stores the light height value in `miniquake.types.RenderSurface`.
  lightHeight
  /// Stores the light offset value in `miniquake.types.RenderSurface`.
  lightOffset
  /// Stores the flags value in `miniquake.types.RenderSurface`.
  flags
  /// Stores the vertices value in `miniquake.types.RenderSurface`.
  vertices
  /// Stores the lightmap id value in `miniquake.types.RenderSurface`.
  lightmapId
end struct

// Describe one render texture consumed by the renderer or asset loader.
struct RenderTexture
  /// Stores the name value in `miniquake.types.RenderTexture`.
  name
  /// Stores the width value in `miniquake.types.RenderTexture`.
  width
  /// Stores the height value in `miniquake.types.RenderTexture`.
  height
  /// Stores the gl id value in `miniquake.types.RenderTexture`.
  glId
  /// Stores the pixels value in `miniquake.types.RenderTexture`.
  pixels
  /// Stores the transparent value in `miniquake.types.RenderTexture`.
  transparent
end struct

// Group the fields that describe one world renderer.
struct WorldRenderer
  /// Stores the map value in `miniquake.types.WorldRenderer`.
  map
  /// Stores the palette value in `miniquake.types.WorldRenderer`.
  palette
  /// Stores the textures value in `miniquake.types.WorldRenderer`.
  textures
  /// Stores the surfaces value in `miniquake.types.WorldRenderer`.
  surfaces
  /// Stores the lightmaps value in `miniquake.types.WorldRenderer`.
  lightmaps
  /// Stores the uploaded value in `miniquake.types.WorldRenderer`.
  uploaded
  /// Stores the no texture id value in `miniquake.types.WorldRenderer`.
  noTextureId
  /// Stores the fullbright value in `miniquake.types.WorldRenderer`.
  fullbright
  /// Stores the wireframe value in `miniquake.types.WorldRenderer`.
  wireframe
  /// Stores the view leaf value in `miniquake.types.WorldRenderer`.
  viewLeaf
  /// Stores the visible faces value in `miniquake.types.WorldRenderer`.
  visibleFaces
  /// Stores the frame count value in `miniquake.types.WorldRenderer`.
  frameCount
  /// Stores the water alpha value in `miniquake.types.WorldRenderer`.
  waterAlpha
end struct

// Own the coordinated data required by the game session.
struct GameSession
  /// Stores the arguments value in `miniquake.types.GameSession`.
  arguments
  /// Stores the filesystem value in `miniquake.types.GameSession`.
  filesystem
  /// Stores the commands value in `miniquake.types.GameSession`.
  commands
  /// Stores the cvars value in `miniquake.types.GameSession`.
  cvars
  /// Stores the timing value in `miniquake.types.GameSession`.
  timing
  /// Stores the server value in `miniquake.types.GameSession`.
  server
  /// Stores the client value in `miniquake.types.GameSession`.
  client
  /// Stores the network value in `miniquake.types.GameSession`.
  network
  /// Stores the player value in `miniquake.types.GameSession`.
  player
  /// Stores the renderer value in `miniquake.types.GameSession`.
  renderer
  /// Stores the entity renderer value in `miniquake.types.GameSession`.
  entityRenderer
  /// Stores the running value in `miniquake.types.GameSession`.
  running
  /// Stores the initialized value in `miniquake.types.GameSession`.
  initialized
  /// Stores the window created value in `miniquake.types.GameSession`.
  windowCreated
  /// Stores the basedir value in `miniquake.types.GameSession`.
  basedir
  /// Stores the game directory value in `miniquake.types.GameSession`.
  gameDirectory
  /// Stores the start map value in `miniquake.types.GameSession`.
  startMap
  /// Stores the width value in `miniquake.types.GameSession`.
  width
  /// Stores the height value in `miniquake.types.GameSession`.
  height
  /// Stores the fullscreen value in `miniquake.types.GameSession`.
  fullscreen
  /// Stores the headless value in `miniquake.types.GameSession`.
  headless
  /// Stores the max frames value in `miniquake.types.GameSession`.
  maxFrames
  /// Stores the last ticks value in `miniquake.types.GameSession`.
  lastTicks
  /// Stores the console visible value in `miniquake.types.GameSession`.
  consoleVisible
  /// Stores the status message value in `miniquake.types.GameSession`.
  statusMessage
  /// Stores the console value in `miniquake.types.GameSession`.
  console
  /// Stores the menu value in `miniquake.types.GameSession`.
  menu
  /// Stores the view value in `miniquake.types.GameSession`.
  view
  /// Stores the mixer value in `miniquake.types.GameSession`.
  mixer
  /// Stores the particles value in `miniquake.types.GameSession`.
  particles
  /// Stores the temporary entities value in `miniquake.types.GameSession`.
  temporaryEntities
  /// Stores the qc enabled value in `miniquake.types.GameSession`.
  qcEnabled
  /// Stores the no sound value in `miniquake.types.GameSession`.
  noSound
  /// Stores the audio started value in `miniquake.types.GameSession`.
  audioStarted
  /// Stores the rendered frames value in `miniquake.types.GameSession`.
  renderedFrames
  /// Stores the simulated frames value in `miniquake.types.GameSession`.
  simulatedFrames
  /// Stores the demo name value in `miniquake.types.GameSession`.
  demoName
  /// Stores the demo recording value in `miniquake.types.GameSession`.
  demoRecording
  /// Stores the demo playback value in `miniquake.types.GameSession`.
  demoPlayback
  /// Stores the timedemo active value in `miniquake.types.GameSession`.
  timedemoActive
  /// Stores the timedemo start frame value in `miniquake.types.GameSession`.
  timedemoStartFrame
  /// Stores the timedemo start time value in `miniquake.types.GameSession`.
  timedemoStartTime
  /// Stores the timedemo last frame value in `miniquake.types.GameSession`.
  timedemoLastFrame
  /// Stores the last remote host value in `miniquake.types.GameSession`.
  lastRemoteHost
  /// Stores the demo loop value in `miniquake.types.GameSession`.
  demoLoop
  /// Stores the demo number value in `miniquake.types.GameSession`.
  demoNumber
  /// Stores the host time value in `miniquake.types.GameSession`.
  hostTime
  /// Stores the shutdown started value in `miniquake.types.GameSession`.
  shutdownStarted
  /// Stores the in error value in `miniquake.types.GameSession`.
  inError
  /// Stores the frame trace value in `miniquake.types.GameSession`.
  frameTrace
  /// Stores the profile time value in `miniquake.types.GameSession`.
  profileTime
  /// Stores the profile count value in `miniquake.types.GameSession`.
  profileCount
  /// Stores the diagnostic context path value in `miniquake.types.GameSession`.
  diagnosticContextPath
  /// Stores the diagnostic frame value in `miniquake.types.GameSession`.
  diagnosticFrame
  /// Stores the diagnostic last stage value in `miniquake.types.GameSession`.
  diagnosticLastStage
  /// Stores the diagnostic write error value in `miniquake.types.GameSession`.
  diagnosticWriteError
end struct

// -----------------------------------------------------------------------------
// Integrated engine services added after the first compiler-stable milestone.
// These keep platform resources at the boundary while host/game state stays in
// MiniLang, matching the ownership split of WinQuake's common/host subsystems.
// -----------------------------------------------------------------------------

struct LaunchOptions
  /// Stores the original args value in `miniquake.types.LaunchOptions`.
  originalArgs
  /// Stores the basedir value in `miniquake.types.LaunchOptions`.
  basedir
  /// Stores the game directory value in `miniquake.types.LaunchOptions`.
  gameDirectory
  /// Stores the width value in `miniquake.types.LaunchOptions`.
  width
  /// Stores the height value in `miniquake.types.LaunchOptions`.
  height
  /// Stores the fullscreen value in `miniquake.types.LaunchOptions`.
  fullscreen
  /// Stores the no sound value in `miniquake.types.LaunchOptions`.
  noSound
  /// Stores the developer value in `miniquake.types.LaunchOptions`.
  developer
  /// Stores the dedicated value in `miniquake.types.LaunchOptions`.
  dedicated
  /// Stores the skill value in `miniquake.types.LaunchOptions`.
  skill
  /// Stores the start map value in `miniquake.types.LaunchOptions`.
  startMap
  /// Stores the plus commands value in `miniquake.types.LaunchOptions`.
  plusCommands
  /// Stores the max frames value in `miniquake.types.LaunchOptions`.
  maxFrames
  /// Stores the validate only value in `miniquake.types.LaunchOptions`.
  validateOnly
  /// Stores the headless value in `miniquake.types.LaunchOptions`.
  headless
  /// Stores the timedemo value in `miniquake.types.LaunchOptions`.
  timedemo
end struct

// Collect the outcome and diagnostics for one game validation.
struct GameValidation
  /// Stores the ok value in `miniquake.types.GameValidation`.
  ok
  /// Stores the messages value in `miniquake.types.GameValidation`.
  messages
  /// Stores the pack files value in `miniquake.types.GameValidation`.
  packFiles
  /// Stores the map faces value in `miniquake.types.GameValidation`.
  mapFaces
  /// Stores the map textures value in `miniquake.types.GameValidation`.
  mapTextures
  /// Stores the map entities value in `miniquake.types.GameValidation`.
  mapEntities
  /// Stores the progs functions value in `miniquake.types.GameValidation`.
  progsFunctions
end struct

// Group the fields that describe one lightmap page.
struct LightmapPage
  /// Stores the gl id value in `miniquake.types.LightmapPage`.
  glId
  /// Stores the pixels value in `miniquake.types.LightmapPage`.
  pixels
  /// Stores the allocated value in `miniquake.types.LightmapPage`.
  allocated
  /// Stores the dirty value in `miniquake.types.LightmapPage`.
  dirty
end struct

// Own the coordinated data required by the edict runtime.
struct EdictRuntime
  /// Stores the max edicts value in `miniquake.types.EdictRuntime`.
  maxEdicts
  /// Stores the num edicts value in `miniquake.types.EdictRuntime`.
  numEdicts
  /// Stores the free flags value in `miniquake.types.EdictRuntime`.
  freeFlags
  /// Stores the free times value in `miniquake.types.EdictRuntime`.
  freeTimes
end struct

// Own the coordinated data required by the QuakeC context.
struct QuakeCContext
  /// Stores the filesystem value in `miniquake.types.QuakeCContext`.
  filesystem
  /// Stores the world map value in `miniquake.types.QuakeCContext`.
  worldMap
  /// Stores the collision hull value in `miniquake.types.QuakeCContext`.
  collisionHull
  /// Stores the cvars value in `miniquake.types.QuakeCContext`.
  cvars
  /// Stores the commands value in `miniquake.types.QuakeCContext`.
  commands
  /// Stores the edicts value in `miniquake.types.QuakeCContext`.
  edicts
  /// Stores the model precache value in `miniquake.types.QuakeCContext`.
  modelPrecache
  /// Stores the sound precache value in `miniquake.types.QuakeCContext`.
  soundPrecache
  /// Stores the light styles value in `miniquake.types.QuakeCContext`.
  lightStyles
  /// Stores the datagram value in `miniquake.types.QuakeCContext`.
  datagram
  /// Stores the reliable datagram value in `miniquake.types.QuakeCContext`.
  reliableDatagram
  /// Stores the signon value in `miniquake.types.QuakeCContext`.
  signon
  /// Stores the console lines value in `miniquake.types.QuakeCContext`.
  consoleLines
  /// Stores the static entities value in `miniquake.types.QuakeCContext`.
  staticEntities
  /// Stores the static sounds value in `miniquake.types.QuakeCContext`.
  staticSounds
  /// Stores the sound events value in `miniquake.types.QuakeCContext`.
  soundEvents
  /// Stores the particles value in `miniquake.types.QuakeCContext`.
  particles
  /// Stores the server time value in `miniquake.types.QuakeCContext`.
  serverTime
  /// Stores the random seed value in `miniquake.types.QuakeCContext`.
  randomSeed
  /// Stores the change level value in `miniquake.types.QuakeCContext`.
  changeLevel
  /// Stores the trace entity value in `miniquake.types.QuakeCContext`.
  traceEntity
  /// Stores the server value in `miniquake.types.QuakeCContext`.
  server
  /// Stores the client messages value in `miniquake.types.QuakeCContext`.
  clientMessages
  /// Stores the client spawn parms value in `miniquake.types.QuakeCContext`.
  clientSpawnParms
  /// Stores the last check client value in `miniquake.types.QuakeCContext`.
  lastCheckClient
  /// Stores the last check time value in `miniquake.types.QuakeCContext`.
  lastCheckTime
  /// Stores the check pvs value in `miniquake.types.QuakeCContext`.
  checkPvs
end struct

// Describe one runtime dynamic light and its observable Quake state.
struct DynamicLight
  /// Stores the origin value in `miniquake.types.DynamicLight`.
  origin
  /// Stores the radius value in `miniquake.types.DynamicLight`.
  radius
  /// Stores the die value in `miniquake.types.DynamicLight`.
  die
  /// Stores the decay value in `miniquake.types.DynamicLight`.
  decay
  /// Stores the min light value in `miniquake.types.DynamicLight`.
  minLight
  /// Stores the key value in `miniquake.types.DynamicLight`.
  key
end struct

// Track mutable client entity state across subsystem calls.
struct ClientEntityState
  /// Stores the number value in `miniquake.types.ClientEntityState`.
  number
  /// Stores the model index value in `miniquake.types.ClientEntityState`.
  modelIndex
  /// Stores the frame value in `miniquake.types.ClientEntityState`.
  frame
  /// Stores the colormap value in `miniquake.types.ClientEntityState`.
  colormap
  /// Stores the skin value in `miniquake.types.ClientEntityState`.
  skin
  /// Stores the effects value in `miniquake.types.ClientEntityState`.
  effects
  /// Stores the origin value in `miniquake.types.ClientEntityState`.
  origin
  /// Stores the angles value in `miniquake.types.ClientEntityState`.
  angles
  /// Stores the message time value in `miniquake.types.ClientEntityState`.
  messageTime
  /// Stores the message origin value in `miniquake.types.ClientEntityState`.
  messageOrigin
  /// Stores the previous message origin value in `miniquake.types.ClientEntityState`.
  previousMessageOrigin
  /// Stores the message angles value in `miniquake.types.ClientEntityState`.
  messageAngles
  /// Stores the previous message angles value in `miniquake.types.ClientEntityState`.
  previousMessageAngles
  /// Stores the force link value in `miniquake.types.ClientEntityState`.
  forceLink
  /// Stores the baseline value in `miniquake.types.ClientEntityState`.
  baseline
  /// Stores the sync base value in `miniquake.types.ClientEntityState`.
  syncBase
end struct

// Group the fields that describe one sound effect.
struct SoundEffect
  /// Stores the name value in `miniquake.types.SoundEffect`.
  name
  /// Stores the samples value in `miniquake.types.SoundEffect`.
  samples
  /// Stores the rate value in `miniquake.types.SoundEffect`.
  rate
  /// Stores the width value in `miniquake.types.SoundEffect`.
  width
  /// Stores the channels value in `miniquake.types.SoundEffect`.
  channels
  /// Stores the loop start value in `miniquake.types.SoundEffect`.
  loopStart
end struct

// Track storage and runtime state for one mixer channel.
struct MixerChannel
  /// Stores the entity number value in `miniquake.types.MixerChannel`.
  entityNumber
  /// Stores the channel number value in `miniquake.types.MixerChannel`.
  channelNumber
  /// Stores the effect value in `miniquake.types.MixerChannel`.
  effect
  /// Stores the origin value in `miniquake.types.MixerChannel`.
  origin
  /// Stores the volume value in `miniquake.types.MixerChannel`.
  volume
  /// Stores the attenuation value in `miniquake.types.MixerChannel`.
  attenuation
  /// Stores the sample value in `miniquake.types.MixerChannel`.
  sample
  /// Stores the looping value in `miniquake.types.MixerChannel`.
  looping
  /// Stores the active value in `miniquake.types.MixerChannel`.
  active
  /// Stores the end time value in `miniquake.types.MixerChannel`.
  endTime
end struct

// Group the fields that describe one music track.
struct MusicTrack
  /// Stores the number value in `miniquake.types.MusicTrack`.
  number
  /// Stores the source value in `miniquake.types.MusicTrack`.
  source
  /// Stores the samples value in `miniquake.types.MusicTrack`.
  samples
  /// Stores the rate value in `miniquake.types.MusicTrack`.
  rate
  /// Stores the channels value in `miniquake.types.MusicTrack`.
  channels
  /// Stores the frames value in `miniquake.types.MusicTrack`.
  frames
  /// Stores the position value in `miniquake.types.MusicTrack`.
  position
  /// Stores the looping value in `miniquake.types.MusicTrack`.
  looping
  /// Stores the playing value in `miniquake.types.MusicTrack`.
  playing
  /// Stores the paused value in `miniquake.types.MusicTrack`.
  paused
  /// Stores the sample base value in `miniquake.types.MusicTrack`.
  sampleBase
  /// Stores the sample frames value in `miniquake.types.MusicTrack`.
  sampleFrames
end struct

// Group the fields that describe one sound mixer.
struct SoundMixer
  /// Stores the audio state value in `miniquake.types.SoundMixer`.
  audioState
  /// Stores the filesystem value in `miniquake.types.SoundMixer`.
  filesystem
  /// Stores the effects value in `miniquake.types.SoundMixer`.
  effects
  /// Stores the channels value in `miniquake.types.SoundMixer`.
  channels
  /// Stores the sample rate value in `miniquake.types.SoundMixer`.
  sampleRate
  /// Stores the master volume value in `miniquake.types.SoundMixer`.
  masterVolume
  /// Stores the listener origin value in `miniquake.types.SoundMixer`.
  listenerOrigin
  /// Stores the listener forward value in `miniquake.types.SoundMixer`.
  listenerForward
  /// Stores the listener right value in `miniquake.types.SoundMixer`.
  listenerRight
  /// Stores the listener entity value in `miniquake.types.SoundMixer`.
  listenerEntity
  /// Stores the enabled value in `miniquake.types.SoundMixer`.
  enabled
  /// Stores the underruns value in `miniquake.types.SoundMixer`.
  underruns
  /// Stores the submitted buffers value in `miniquake.types.SoundMixer`.
  submittedBuffers
  /// Stores the music value in `miniquake.types.SoundMixer`.
  music
  /// Stores the music volume value in `miniquake.types.SoundMixer`.
  musicVolume
  /// Stores the painted time value in `miniquake.types.SoundMixer`.
  paintedTime
  /// Stores the block depth value in `miniquake.types.SoundMixer`.
  blockDepth
  /// Stores the static allocations value in `miniquake.types.SoundMixer`.
  staticAllocations
  /// Stores the play hash value in `miniquake.types.SoundMixer`.
  playHash
  /// Stores the play volume hash value in `miniquake.types.SoundMixer`.
  playVolumeHash
end struct

// Track mutable console state across subsystem calls.
struct ConsoleState
  /// Stores the lines value in `miniquake.types.ConsoleState`.
  lines
  /// Stores the max lines value in `miniquake.types.ConsoleState`.
  maxLines
  /// Stores the input text value in `miniquake.types.ConsoleState`.
  inputText
  /// Stores the active value in `miniquake.types.ConsoleState`.
  active
  /// Stores the notify until value in `miniquake.types.ConsoleState`.
  notifyUntil
  /// Stores the texture id value in `miniquake.types.ConsoleState`.
  textureId
  /// Stores the toggle latch value in `miniquake.types.ConsoleState`.
  toggleLatch
  /// Stores the center text value in `miniquake.types.ConsoleState`.
  centerText
  /// Stores the center until value in `miniquake.types.ConsoleState`.
  centerUntil
  /// Stores the text buffer value in `miniquake.types.ConsoleState`.
  textBuffer
  /// Stores the line width value in `miniquake.types.ConsoleState`.
  lineWidth
  /// Stores the total lines value in `miniquake.types.ConsoleState`.
  totalLines
  /// Stores the current line value in `miniquake.types.ConsoleState`.
  currentLine
  /// Stores the cursor x value in `miniquake.types.ConsoleState`.
  cursorX
  /// Stores the carriage return value in `miniquake.types.ConsoleState`.
  carriageReturn
  /// Stores the notify times value in `miniquake.types.ConsoleState`.
  notifyTimes
  /// Stores the realtime value in `miniquake.types.ConsoleState`.
  realtime
  /// Stores the visible pixel lines value in `miniquake.types.ConsoleState`.
  visiblePixelLines
  /// Stores the forced up value in `miniquake.types.ConsoleState`.
  forcedUp
  /// Stores the initialized value in `miniquake.types.ConsoleState`.
  initialized
  /// Stores the notify pixel lines value in `miniquake.types.ConsoleState`.
  notifyPixelLines
  /// Stores the debug log value in `miniquake.types.ConsoleState`.
  debugLog
  /// Stores the debug log name value in `miniquake.types.ConsoleState`.
  debugLogName
  /// Stores the filesystem value in `miniquake.types.ConsoleState`.
  filesystem
  /// Stores the line count value in `miniquake.types.ConsoleState`.
  lineCount
  /// Stores the talk sound requested value in `miniquake.types.ConsoleState`.
  talkSoundRequested
  /// Stores the draw trace value in `miniquake.types.ConsoleState`.
  drawTrace
  /// Stores the update requested value in `miniquake.types.ConsoleState`.
  updateRequested
  /// Stores the safe print depth value in `miniquake.types.ConsoleState`.
  safePrintDepth
  /// Stores the notify box text value in `miniquake.types.ConsoleState`.
  notifyBoxText
  /// Stores the dedicated value in `miniquake.types.ConsoleState`.
  dedicated
end struct

// Group the fields that describe one menu picture.
struct MenuPicture
  /// Stores the name value in `miniquake.types.MenuPicture`.
  name
  /// Stores the width value in `miniquake.types.MenuPicture`.
  width
  /// Stores the height value in `miniquake.types.MenuPicture`.
  height
  /// Stores the texture id value in `miniquake.types.MenuPicture`.
  textureId
end struct

// Track mutable menu state across subsystem calls.
struct MenuState
  /// Stores the active value in `miniquake.types.MenuState`.
  active
  /// Stores the selection value in `miniquake.types.MenuState`.
  selection
  /// Stores the items value in `miniquake.types.MenuState`.
  items
  /// Stores the title value in `miniquake.types.MenuState`.
  title
  /// Stores the paused by menu value in `miniquake.types.MenuState`.
  pausedByMenu
  /// Stores the page value in `miniquake.types.MenuState`.
  page
  /// Stores the previous page value in `miniquake.types.MenuState`.
  previousPage
  /// Stores the help page value in `miniquake.types.MenuState`.
  helpPage
  /// Stores the pictures value in `miniquake.types.MenuState`.
  pictures
  /// Stores the initialized value in `miniquake.types.MenuState`.
  initialized
  /// Stores the status text value in `miniquake.types.MenuState`.
  statusText
  /// Stores the waiting for key value in `miniquake.types.MenuState`.
  waitingForKey
  /// Stores the page selections value in `miniquake.types.MenuState`.
  pageSelections
  /// Stores the draw trace value in `miniquake.types.MenuState`.
  drawTrace
  /// Stores the action value in `miniquake.types.MenuState`.
  action
  /// Stores the setup hostname value in `miniquake.types.MenuState`.
  setupHostname
  /// Stores the setup name value in `miniquake.types.MenuState`.
  setupName
  /// Stores the setup top value in `miniquake.types.MenuState`.
  setupTop
  /// Stores the setup bottom value in `miniquake.types.MenuState`.
  setupBottom
  /// Stores the setup old top value in `miniquake.types.MenuState`.
  setupOldTop
  /// Stores the setup old bottom value in `miniquake.types.MenuState`.
  setupOldBottom
  /// Stores the lan port value in `miniquake.types.MenuState`.
  lanPort
  /// Stores the lan port text value in `miniquake.types.MenuState`.
  lanPortText
  /// Stores the lan join name value in `miniquake.types.MenuState`.
  lanJoinName
  /// Stores the joining game value in `miniquake.types.MenuState`.
  joiningGame
  /// Stores the tcp available value in `miniquake.types.MenuState`.
  tcpAvailable
  /// Stores the local address value in `miniquake.types.MenuState`.
  localAddress
  /// Stores the max players value in `miniquake.types.MenuState`.
  maxPlayers
  /// Stores the max players limit value in `miniquake.types.MenuState`.
  maxPlayersLimit
  /// Stores the start episode value in `miniquake.types.MenuState`.
  startEpisode
  /// Stores the start level value in `miniquake.types.MenuState`.
  startLevel
  /// Stores the mission pack value in `miniquake.types.MenuState`.
  missionPack
  /// Stores the search complete value in `miniquake.types.MenuState`.
  searchComplete
  /// Stores the search complete time value in `miniquake.types.MenuState`.
  searchCompleteTime
  /// Stores the servers value in `miniquake.types.MenuState`.
  servers
  /// Stores the server list sorted value in `miniquake.types.MenuState`.
  serverListSorted
  /// Stores the return reason value in `miniquake.types.MenuState`.
  returnReason
  /// Stores the enter sound value in `miniquake.types.MenuState`.
  enterSound
  /// Stores the excluded paths value in `miniquake.types.MenuState`.
  excludedPaths
  /// Stores the video draw callback value in `miniquake.types.MenuState`.
  videoDrawCallback
  /// Stores the video key callback value in `miniquake.types.MenuState`.
  videoKeyCallback
  /// Stores the loadable value in `miniquake.types.MenuState`.
  loadable
end struct

// Track mutable view state across subsystem calls.
struct ViewState
  /// Stores the origin value in `miniquake.types.ViewState`.
  origin
  /// Stores the angles value in `miniquake.types.ViewState`.
  angles
  /// Stores the forward value in `miniquake.types.ViewState`.
  forward
  /// Stores the right value in `miniquake.types.ViewState`.
  right
  /// Stores the up value in `miniquake.types.ViewState`.
  up
  /// Stores the bob value in `miniquake.types.ViewState`.
  bob
  /// Stores the roll value in `miniquake.types.ViewState`.
  roll
  /// Stores the damage kick value in `miniquake.types.ViewState`.
  damageKick
  /// Stores the blend value in `miniquake.types.ViewState`.
  blend
  /// Stores the old z value in `miniquake.types.ViewState`.
  oldZ
  /// Stores the old z valid value in `miniquake.types.ViewState`.
  oldZValid
  /// Stores the gun origin value in `miniquake.types.ViewState`.
  gunOrigin
  /// Stores the gun angles value in `miniquake.types.ViewState`.
  gunAngles
  /// Stores the pitch velocity value in `miniquake.types.ViewState`.
  pitchVelocity
  /// Stores the no drift value in `miniquake.types.ViewState`.
  noDrift
  /// Stores the drift move value in `miniquake.types.ViewState`.
  driftMove
  /// Stores the last stop value in `miniquake.types.ViewState`.
  lastStop
  /// Stores the damage time value in `miniquake.types.ViewState`.
  damageTime
  /// Stores the damage roll value in `miniquake.types.ViewState`.
  damageRoll
  /// Stores the damage pitch value in `miniquake.types.ViewState`.
  damagePitch
  /// Stores the cshifts value in `miniquake.types.ViewState`.
  cshifts
  /// Stores the previous cshifts value in `miniquake.types.ViewState`.
  previousCshifts
  /// Stores the gamma table value in `miniquake.types.ViewState`.
  gammaTable
  /// Stores the ramps value in `miniquake.types.ViewState`.
  ramps
  /// Stores the old gamma value in `miniquake.types.ViewState`.
  oldGamma
  /// Stores the old gun yaw value in `miniquake.types.ViewState`.
  oldGunYaw
  /// Stores the old gun pitch value in `miniquake.types.ViewState`.
  oldGunPitch
  /// Stores the intermission value in `miniquake.types.ViewState`.
  intermission
  /// Stores the view model visible value in `miniquake.types.ViewState`.
  viewModelVisible
  /// Stores the command trace value in `miniquake.types.ViewState`.
  commandTrace
  /// Stores the last input pitch value in `miniquake.types.ViewState`.
  lastInputPitch
  /// Stores the last input pitch valid value in `miniquake.types.ViewState`.
  lastInputPitchValid
  /// Stores the empty cshift value in `miniquake.types.ViewState`.
  emptyCshift
end struct

// Store the parsed data and relationships for one alias GPU model.
struct AliasGpuModel
  /// Stores the source value in `miniquake.types.AliasGpuModel`.
  source
  /// Stores the texture ids value in `miniquake.types.AliasGpuModel`.
  textureIds
  /// Stores the uploaded value in `miniquake.types.AliasGpuModel`.
  uploaded
end struct

// Store the parsed data and relationships for one sprite GPU model.
struct SpriteGpuModel
  /// Stores the source value in `miniquake.types.SpriteGpuModel`.
  source
  /// Stores the texture ids value in `miniquake.types.SpriteGpuModel`.
  textureIds
  /// Stores the uploaded value in `miniquake.types.SpriteGpuModel`.
  uploaded
end struct


// Store the parsed data and relationships for one client render model.
struct ClientRenderModel
  /// Stores the name value in `miniquake.types.ClientRenderModel`.
  name
  /// Stores the kind value in `miniquake.types.ClientRenderModel`.
  kind
  /// Stores the alias model value in `miniquake.types.ClientRenderModel`.
  aliasModel
  /// Stores the sprite model value in `miniquake.types.ClientRenderModel`.
  spriteModel
  /// Stores the brush renderer value in `miniquake.types.ClientRenderModel`.
  brushRenderer
  /// Stores the texture ids value in `miniquake.types.ClientRenderModel`.
  textureIds
  /// Stores the uploaded value in `miniquake.types.ClientRenderModel`.
  uploaded
end struct

// Group the fields that describe one entity renderer.
struct EntityRenderer
  /// Stores the filesystem value in `miniquake.types.EntityRenderer`.
  filesystem
  /// Stores the palette value in `miniquake.types.EntityRenderer`.
  palette
  /// Stores the models value in `miniquake.types.EntityRenderer`.
  models
  /// Stores the rendered entities value in `miniquake.types.EntityRenderer`.
  renderedEntities
end struct

// Track storage and runtime state for one UDP socket.
struct UdpSocket
  /// Stores the handle value in `miniquake.types.UdpSocket`.
  handle
  /// Stores the port value in `miniquake.types.UdpSocket`.
  port
  /// Stores the address value in `miniquake.types.UdpSocket`.
  address
  /// Stores the open value in `miniquake.types.UdpSocket`.
  open
  /// Stores the bind address value in `miniquake.types.UdpSocket`.
  bindAddress
  /// Stores the broadcast value in `miniquake.types.UdpSocket`.
  broadcast
end struct

// Group the fields that describe one WinSock address.
struct WinSockAddress
  /// Stores the family value in `miniquake.types.WinSockAddress`.
  family
  /// Stores the address value in `miniquake.types.WinSockAddress`.
  address
  /// Stores the port value in `miniquake.types.WinSockAddress`.
  port
end struct

// Collect the outcome and diagnostics for one host soak result.
struct HostSoakResult
  /// Stores the frames value in `miniquake.types.HostSoakResult`.
  frames
  /// Stores the live before value in `miniquake.types.HostSoakResult`.
  liveBefore
  /// Stores the live after value in `miniquake.types.HostSoakResult`.
  liveAfter
  /// Stores the bytes before value in `miniquake.types.HostSoakResult`.
  bytesBefore
  /// Stores the bytes after value in `miniquake.types.HostSoakResult`.
  bytesAfter
  /// Stores the stable value in `miniquake.types.HostSoakResult`.
  stable
end struct


// Collect the outcome and diagnostics for one UDP smoke result.
struct UdpSmokeResult
  /// Stores the ok value in `miniquake.types.UdpSmokeResult`.
  ok
  /// Stores the sender port value in `miniquake.types.UdpSmokeResult`.
  senderPort
  /// Stores the receiver port value in `miniquake.types.UdpSmokeResult`.
  receiverPort
  /// Stores the bytes sent value in `miniquake.types.UdpSmokeResult`.
  bytesSent
  /// Stores the bytes received value in `miniquake.types.UdpSmokeResult`.
  bytesReceived
  /// Stores the payload value in `miniquake.types.UdpSmokeResult`.
  payload
  /// Stores the remote address value in `miniquake.types.UdpSmokeResult`.
  remoteAddress
  /// Stores the remote port value in `miniquake.types.UdpSmokeResult`.
  remotePort
  /// Stores the error code value in `miniquake.types.UdpSmokeResult`.
  errorCode
end struct

// Collect the outcome and diagnostics for one compatibility trace result.
struct CompatibilityTraceResult
  /// Stores the ok value in `miniquake.types.CompatibilityTraceResult`.
  ok
  /// Stores the frames requested value in `miniquake.types.CompatibilityTraceResult`.
  framesRequested
  /// Stores the frames written value in `miniquake.types.CompatibilityTraceResult`.
  framesWritten
  /// Stores the accepted frames value in `miniquake.types.CompatibilityTraceResult`.
  acceptedFrames
  /// Stores the rolling hash value in `miniquake.types.CompatibilityTraceResult`.
  rollingHash
  /// Stores the trace path value in `miniquake.types.CompatibilityTraceResult`.
  tracePath
  /// Stores the snapshot path value in `miniquake.types.CompatibilityTraceResult`.
  snapshotPath
  /// Stores the context path value in `miniquake.types.CompatibilityTraceResult`.
  contextPath
  /// Stores the summary path value in `miniquake.types.CompatibilityTraceResult`.
  summaryPath
  /// Stores the last stage value in `miniquake.types.CompatibilityTraceResult`.
  lastStage
  /// Stores the error message value in `miniquake.types.CompatibilityTraceResult`.
  errorMessage
  /// Stores the clean shutdown value in `miniquake.types.CompatibilityTraceResult`.
  cleanShutdown
end struct

// Collect the outcome and diagnostics for one runtime validation.
struct RuntimeValidation
  /// Stores the ok value in `miniquake.types.RuntimeValidation`.
  ok
  /// Stores the messages value in `miniquake.types.RuntimeValidation`.
  messages
  /// Stores the map name value in `miniquake.types.RuntimeValidation`.
  mapName
  /// Stores the signon value in `miniquake.types.RuntimeValidation`.
  signon
  /// Stores the spawned value in `miniquake.types.RuntimeValidation`.
  spawned
  /// Stores the edicts value in `miniquake.types.RuntimeValidation`.
  edicts
  /// Stores the model precache value in `miniquake.types.RuntimeValidation`.
  modelPrecache
  /// Stores the sound precache value in `miniquake.types.RuntimeValidation`.
  soundPrecache
  /// Stores the world faces value in `miniquake.types.RuntimeValidation`.
  worldFaces
  /// Stores the render surfaces value in `miniquake.types.RuntimeValidation`.
  renderSurfaces
  /// Stores the simulated frames value in `miniquake.types.RuntimeValidation`.
  simulatedFrames
  /// Stores the trace fraction value in `miniquake.types.RuntimeValidation`.
  traceFraction
  /// Stores the heap live before value in `miniquake.types.RuntimeValidation`.
  heapLiveBefore
  /// Stores the heap live after value in `miniquake.types.RuntimeValidation`.
  heapLiveAfter
  /// Stores the heap bytes before value in `miniquake.types.RuntimeValidation`.
  heapBytesBefore
  /// Stores the heap bytes after value in `miniquake.types.RuntimeValidation`.
  heapBytesAfter
  /// Stores the clean shutdown value in `miniquake.types.RuntimeValidation`.
  cleanShutdown
end struct

// Group the fields that describe one demo playback.
struct DemoPlayback
  /// Stores the recording value in `miniquake.types.DemoPlayback`.
  recording
  /// Stores the client value in `miniquake.types.DemoPlayback`.
  client
  /// Stores the index value in `miniquake.types.DemoPlayback`.
  index
  /// Stores the event count value in `miniquake.types.DemoPlayback`.
  eventCount
  /// Stores the payload bytes value in `miniquake.types.DemoPlayback`.
  payloadBytes
  /// Stores the complete value in `miniquake.types.DemoPlayback`.
  complete
  /// Stores the errors value in `miniquake.types.DemoPlayback`.
  errors
  /// Stores the timedemo value in `miniquake.types.DemoPlayback`.
  timedemo
  /// Stores the start frame value in `miniquake.types.DemoPlayback`.
  startFrame
  /// Stores the start time value in `miniquake.types.DemoPlayback`.
  startTime
  /// Stores the last frame value in `miniquake.types.DemoPlayback`.
  lastFrame
  /// Stores the stopped value in `miniquake.types.DemoPlayback`.
  stopped
  /// Stores the finish result value in `miniquake.types.DemoPlayback`.
  finishResult
end struct

// Collect the outcome and diagnostics for one demo verification.
struct DemoVerification
  /// Stores the ok value in `miniquake.types.DemoVerification`.
  ok
  /// Stores the messages value in `miniquake.types.DemoVerification`.
  messages
  /// Stores the event count value in `miniquake.types.DemoVerification`.
  eventCount
  /// Stores the payload bytes value in `miniquake.types.DemoVerification`.
  payloadBytes
  /// Stores the signon value in `miniquake.types.DemoVerification`.
  signon
  /// Stores the server time value in `miniquake.types.DemoVerification`.
  serverTime
  /// Stores the view entity value in `miniquake.types.DemoVerification`.
  viewEntity
  /// Stores the entities value in `miniquake.types.DemoVerification`.
  entities
  /// Stores the prints value in `miniquake.types.DemoVerification`.
  prints
end struct

// Group the fields that describe one datagram packet.
struct DatagramPacket
  /// Stores the flags value in `miniquake.types.DatagramPacket`.
  flags
  /// Stores the sequence value in `miniquake.types.DatagramPacket`.
  sequence
  /// Stores the payload value in `miniquake.types.DatagramPacket`.
  payload
end struct

// Track storage and runtime state for one datagram channel.
struct DatagramChannel
  /// Stores the send sequence value in `miniquake.types.DatagramChannel`.
  sendSequence
  /// Stores the receive sequence value in `miniquake.types.DatagramChannel`.
  receiveSequence
  /// Stores the unreliable send sequence value in `miniquake.types.DatagramChannel`.
  unreliableSendSequence
  /// Stores the unreliable receive sequence value in `miniquake.types.DatagramChannel`.
  unreliableReceiveSequence
  /// Stores the dropped unreliable value in `miniquake.types.DatagramChannel`.
  droppedUnreliable
  /// Stores the ack sequence value in `miniquake.types.DatagramChannel`.
  ackSequence
  /// Stores the send message value in `miniquake.types.DatagramChannel`.
  sendMessage
  /// Stores the receive message value in `miniquake.types.DatagramChannel`.
  receiveMessage
  /// Stores the can send value in `miniquake.types.DatagramChannel`.
  canSend
  /// Stores the send next value in `miniquake.types.DatagramChannel`.
  sendNext
  /// Stores the last send time value in `miniquake.types.DatagramChannel`.
  lastSendTime
  /// Stores the packets re sent value in `miniquake.types.DatagramChannel`.
  packetsReSent
end struct

/// MiniLang's native backend returns package-qualified concrete type names for
/// packaged structs (for example "miniquake.types.Vec3"), while older
/// backends and package-free fixtures may return the short name.  Accept both
/// spellings so runtime type guards remain backend-independent.
/// @param value Value consumed by `concreteTypeNameMatches`.
/// @param shortName Name that identifies the requested value or resource.
/// @param qualifiedName Name that identifies the requested value or resource.
function concreteTypeNameMatches(value, shortName, qualifiedName)
  kind = typeName(value)
  return kind == shortName or kind == qualifiedName
end function

/// Report whether is vec3 value.
/// @param value Value consumed by `isVec3Value`.
function isVec3Value(value)
  return concreteTypeNameMatches(value, "Vec3", "miniquake.types.Vec3")
end function

/// Report whether is entity baseline value.
/// @param value Value consumed by `isEntityBaselineValue`.
function isEntityBaselineValue(value)
  return concreteTypeNameMatches(
    value,
    "EntityBaseline",
    "miniquake.types.EntityBaseline",
  )
end function

/// Report whether is quake edict value.
/// @param value Value consumed by `isQuakeEdictValue`.
function isQuakeEdictValue(value)
  return concreteTypeNameMatches(
    value,
    "QuakeEdict",
    "miniquake.types.QuakeEdict",
  )
end function
