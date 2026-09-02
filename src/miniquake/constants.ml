/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.constants.
*/
package miniquake.constants

// quakedef.h exposes numeric per-renderer versions. QUAKE_VERSION remains a
// MiniQuake text alias for the original "%.2f" console formatting.
const VERSION = 1.09
/// Defines the glquake version value used by `miniquake.constants`.
const GLQUAKE_VERSION = 1.0
/// Defines the d3 dquake version value used by `miniquake.constants`.
const D3DQUAKE_VERSION = 0.01
/// Defines the winquake version value used by `miniquake.constants`.
const WINQUAKE_VERSION = 0.996
/// Defines the linux version value used by `miniquake.constants`.
const LINUX_VERSION = 1.30
/// Defines the x11 version value used by `miniquake.constants`.
const X11_VERSION = 1.10
/// Defines the quake version value used by `miniquake.constants`.
const QUAKE_VERSION = "1.09"
/// Defines the gamename value used by `miniquake.constants`.
const GAMENAME = "id1"
/// Defines the game name value used by `miniquake.constants`.
const GAME_NAME = GAMENAME
/// Defines the protocol version value used by `miniquake.constants`.
const PROTOCOL_VERSION = 15
/// Defines the bsp version value used by `miniquake.constants`.
const BSP_VERSION = 29
/// Defines the prog version value used by `miniquake.constants`.
const PROG_VERSION = 6
/// Defines the progheader crc value used by `miniquake.constants`.
const PROGHEADER_CRC = 5927
/// Defines the mdl version value used by `miniquake.constants`.
const MDL_VERSION = 6
/// Defines the sprite version value used by `miniquake.constants`.
const SPRITE_VERSION = 1

/// Defines the max msglen value used by `miniquake.constants`.
const MAX_MSGLEN = 8000
/// Defines the max datagram value used by `miniquake.constants`.
const MAX_DATAGRAM = 1024
/// Defines the max edicts value used by `miniquake.constants`.
const MAX_EDICTS = 600
/// Defines the max models value used by `miniquake.constants`.
const MAX_MODELS = 256
/// Defines the max sounds value used by `miniquake.constants`.
const MAX_SOUNDS = 256
/// Defines the max clients value used by `miniquake.constants`.
const MAX_CLIENTS = 16
/// Defines the max dlights value used by `miniquake.constants`.
const MAX_DLIGHTS = 32
/// Defines the max visedicts value used by `miniquake.constants`.
const MAX_VISEDICTS = 256
/// Defines the max mod known value used by `miniquake.constants`.
const MAX_MOD_KNOWN = 512
/// Defines the max skins value used by `miniquake.constants`.
const MAX_SKINS = 32
/// Defines the max alias verts value used by `miniquake.constants`.
const MAX_ALIAS_VERTS = 1024
/// Defines the max alias frames value used by `miniquake.constants`.
const MAX_ALIAS_FRAMES = 256
/// Defines the max alias tris value used by `miniquake.constants`.
const MAX_ALIAS_TRIS = 2048
/// Defines the max lbm height value used by `miniquake.constants`.
const MAX_LBM_HEIGHT = 480
/// Defines the alias base size ratio value used by `miniquake.constants`.
const ALIAS_BASE_SIZE_RATIO = 0.09090909090909091
/// Defines the max qpath value used by `miniquake.constants`.
const MAX_QPATH = 64
/// Defines the max ospath value used by `miniquake.constants`.
const MAX_OSPATH = 128
/// Defines the cache size value used by `miniquake.constants`.
const CACHE_SIZE = 32
/// Defines the minimum memory value used by `miniquake.constants`.
const MINIMUM_MEMORY = 0x550000
/// Defines the minimum memory levelpak value used by `miniquake.constants`.
const MINIMUM_MEMORY_LEVELPAK = 0x650000
/// Defines the max num argvs value used by `miniquake.constants`.
const MAX_NUM_ARGVS = 50
/// Defines the pitch value used by `miniquake.constants`.
const PITCH = 0
/// Defines the yaw value used by `miniquake.constants`.
const YAW = 1
/// Defines the roll value used by `miniquake.constants`.
const ROLL = 2
/// Defines the on epsilon value used by `miniquake.constants`.
const ON_EPSILON = 0.1
/// Defines the savegame comment length value used by `miniquake.constants`.
const SAVEGAME_COMMENT_LENGTH = 39
/// Defines the max stylestring value used by `miniquake.constants`.
const MAX_STYLESTRING = 64
/// Defines the max scoreboard value used by `miniquake.constants`.
const MAX_SCOREBOARD = 16
/// Defines the max scoreboardname value used by `miniquake.constants`.
const MAX_SCOREBOARDNAME = 32
/// Defines the sound channels value used by `miniquake.constants`.
const SOUND_CHANNELS = 8

// BSP29 disk ABI and design bounds from bspfile.h.  Some of these are tool
// limits rather than runtime allocation sizes, but keeping the complete
// format vocabulary here prevents parsers and gameplay code from replacing
// meaningful on-disk values with unexplained literals.
const MAX_MAP_HULLS = 4
/// Defines the max map models value used by `miniquake.constants`.
const MAX_MAP_MODELS = 256
/// Defines the max map brushes value used by `miniquake.constants`.
const MAX_MAP_BRUSHES = 4096
/// Defines the max map entities value used by `miniquake.constants`.
const MAX_MAP_ENTITIES = 1024
/// Defines the max map entstring value used by `miniquake.constants`.
const MAX_MAP_ENTSTRING = 65536
/// Defines the max map planes value used by `miniquake.constants`.
const MAX_MAP_PLANES = 32767
/// Defines the max map nodes value used by `miniquake.constants`.
const MAX_MAP_NODES = 32767
/// Defines the max map clipnodes value used by `miniquake.constants`.
const MAX_MAP_CLIPNODES = 32767
/// Defines the max map leafs value used by `miniquake.constants`.
const MAX_MAP_LEAFS = 8192
/// Defines the max map verts value used by `miniquake.constants`.
const MAX_MAP_VERTS = 65535
/// Defines the max map faces value used by `miniquake.constants`.
const MAX_MAP_FACES = 65535
/// Defines the max map marksurfaces value used by `miniquake.constants`.
const MAX_MAP_MARKSURFACES = 65535
/// Defines the max map texinfo value used by `miniquake.constants`.
const MAX_MAP_TEXINFO = 4096
/// Defines the max map edges value used by `miniquake.constants`.
const MAX_MAP_EDGES = 256000
/// Defines the max map surfedges value used by `miniquake.constants`.
const MAX_MAP_SURFEDGES = 512000
/// Defines the max map textures value used by `miniquake.constants`.
const MAX_MAP_TEXTURES = 512
/// Defines the max map miptex value used by `miniquake.constants`.
const MAX_MAP_MIPTEX = 0x200000
/// Defines the max map lighting value used by `miniquake.constants`.
const MAX_MAP_LIGHTING = 0x100000
/// Defines the max map visibility value used by `miniquake.constants`.
const MAX_MAP_VISIBILITY = 0x100000
/// Defines the max map portals value used by `miniquake.constants`.
const MAX_MAP_PORTALS = 65536
/// Defines the max entity key value used by `miniquake.constants`.
const MAX_ENTITY_KEY = 32
/// Defines the max entity value value used by `miniquake.constants`.
const MAX_ENTITY_VALUE = 1024
/// Defines the bsp tool version value used by `miniquake.constants`.
const BSP_TOOL_VERSION = 2
/// Defines the mip levels value used by `miniquake.constants`.
const MIP_LEVELS = 4
/// Defines the max key value used by `miniquake.constants`.
const MAX_KEY = MAX_ENTITY_KEY
/// Defines the max value value used by `miniquake.constants`.
const MAX_VALUE = MAX_ENTITY_VALUE
/// Defines the bspversion value used by `miniquake.constants`.
const BSPVERSION = BSP_VERSION
/// Defines the toolversion value used by `miniquake.constants`.
const TOOLVERSION = BSP_TOOL_VERSION
/// Defines the miplevels value used by `miniquake.constants`.
const MIPLEVELS = MIP_LEVELS
/// Defines the plane x value used by `miniquake.constants`.
const PLANE_X = 0
/// Defines the plane y value used by `miniquake.constants`.
const PLANE_Y = 1
/// Defines the plane z value used by `miniquake.constants`.
const PLANE_Z = 2
/// Defines the plane anyx value used by `miniquake.constants`.
const PLANE_ANYX = 3
/// Defines the plane anyy value used by `miniquake.constants`.
const PLANE_ANYY = 4
/// Defines the plane anyz value used by `miniquake.constants`.
const PLANE_ANYZ = 5

// Player color translation ranges from render.h.
const TOP_RANGE = 16
/// Defines the bottom range value used by `miniquake.constants`.
const BOTTOM_RANGE = 96

/// Defines the contents empty value used by `miniquake.constants`.
const CONTENTS_EMPTY = -1
/// Defines the contents solid value used by `miniquake.constants`.
const CONTENTS_SOLID = -2
/// Defines the contents water value used by `miniquake.constants`.
const CONTENTS_WATER = -3
/// Defines the contents slime value used by `miniquake.constants`.
const CONTENTS_SLIME = -4
/// Defines the contents lava value used by `miniquake.constants`.
const CONTENTS_LAVA = -5
/// Defines the contents sky value used by `miniquake.constants`.
const CONTENTS_SKY = -6
/// Defines the contents origin value used by `miniquake.constants`.
const CONTENTS_ORIGIN = -7
/// Defines the contents clip value used by `miniquake.constants`.
const CONTENTS_CLIP = -8
/// Defines the contents current 0 value used by `miniquake.constants`.
const CONTENTS_CURRENT_0 = -9
/// Defines the contents current 90 value used by `miniquake.constants`.
const CONTENTS_CURRENT_90 = -10
/// Defines the contents current 180 value used by `miniquake.constants`.
const CONTENTS_CURRENT_180 = -11
/// Defines the contents current 270 value used by `miniquake.constants`.
const CONTENTS_CURRENT_270 = -12
/// Defines the contents current up value used by `miniquake.constants`.
const CONTENTS_CURRENT_UP = -13
/// Defines the contents current down value used by `miniquake.constants`.
const CONTENTS_CURRENT_DOWN = -14

/// Defines the bsp max lightmaps value used by `miniquake.constants`.
const BSP_MAX_LIGHTMAPS = 4
/// Defines the maxlightmaps value used by `miniquake.constants`.
const MAXLIGHTMAPS = BSP_MAX_LIGHTMAPS
/// Defines the ambient water value used by `miniquake.constants`.
const AMBIENT_WATER = 0
/// Defines the ambient sky value used by `miniquake.constants`.
const AMBIENT_SKY = 1
/// Defines the ambient slime value used by `miniquake.constants`.
const AMBIENT_SLIME = 2
/// Defines the ambient lava value used by `miniquake.constants`.
const AMBIENT_LAVA = 3
/// Defines the num ambients value used by `miniquake.constants`.
const NUM_AMBIENTS = 4

/// Defines the dist epsilon value used by `miniquake.constants`.
const DIST_EPSILON = 0.03125

/// Defines the lump entities value used by `miniquake.constants`.
const LUMP_ENTITIES = 0
/// Defines the lump planes value used by `miniquake.constants`.
const LUMP_PLANES = 1
/// Defines the lump textures value used by `miniquake.constants`.
const LUMP_TEXTURES = 2
/// Defines the lump vertexes value used by `miniquake.constants`.
const LUMP_VERTEXES = 3
/// Defines the lump visibility value used by `miniquake.constants`.
const LUMP_VISIBILITY = 4
/// Defines the lump nodes value used by `miniquake.constants`.
const LUMP_NODES = 5
/// Defines the lump texinfo value used by `miniquake.constants`.
const LUMP_TEXINFO = 6
/// Defines the lump faces value used by `miniquake.constants`.
const LUMP_FACES = 7
/// Defines the lump lighting value used by `miniquake.constants`.
const LUMP_LIGHTING = 8
/// Defines the lump clipnodes value used by `miniquake.constants`.
const LUMP_CLIPNODES = 9
/// Defines the lump leafs value used by `miniquake.constants`.
const LUMP_LEAFS = 10
/// Defines the lump marksurfaces value used by `miniquake.constants`.
const LUMP_MARKSURFACES = 11
/// Defines the lump edges value used by `miniquake.constants`.
const LUMP_EDGES = 12
/// Defines the lump surfedges value used by `miniquake.constants`.
const LUMP_SURFEDGES = 13
/// Defines the lump models value used by `miniquake.constants`.
const LUMP_MODELS = 14
/// Defines the header lumps value used by `miniquake.constants`.
const HEADER_LUMPS = 15

// MDL6 and SPR1 disk ABI from modelgen.h and spritegn.h.
const ALIAS_VERSION = 6
/// Defines the alias onseam value used by `miniquake.constants`.
const ALIAS_ONSEAM = 0x0020
/// Defines the st sync value used by `miniquake.constants`.
const ST_SYNC = 0
/// Defines the st rand value used by `miniquake.constants`.
const ST_RAND = 1
/// Defines the alias single value used by `miniquake.constants`.
const ALIAS_SINGLE = 0
/// Defines the alias group value used by `miniquake.constants`.
const ALIAS_GROUP = 1
/// Defines the alias skin single value used by `miniquake.constants`.
const ALIAS_SKIN_SINGLE = 0
/// Defines the alias skin group value used by `miniquake.constants`.
const ALIAS_SKIN_GROUP = 1
/// Defines the dt faces front value used by `miniquake.constants`.
const DT_FACES_FRONT = 0x0010
/// Defines the idpolyheader value used by `miniquake.constants`.
const IDPOLYHEADER = 0x4f504449
/// Defines the spr vp parallel upright value used by `miniquake.constants`.
const SPR_VP_PARALLEL_UPRIGHT = 0
/// Defines the spr facing upright value used by `miniquake.constants`.
const SPR_FACING_UPRIGHT = 1
/// Defines the spr vp parallel value used by `miniquake.constants`.
const SPR_VP_PARALLEL = 2
/// Defines the spr oriented value used by `miniquake.constants`.
const SPR_ORIENTED = 3
/// Defines the spr vp parallel oriented value used by `miniquake.constants`.
const SPR_VP_PARALLEL_ORIENTED = 4
/// Defines the spr single value used by `miniquake.constants`.
const SPR_SINGLE = 0
/// Defines the spr group value used by `miniquake.constants`.
const SPR_GROUP = 1
/// Defines the idspriteheader value used by `miniquake.constants`.
const IDSPRITEHEADER = 0x50534449

/// Defines the svc bad value used by `miniquake.constants`.
const SVC_BAD = 0
/// Defines the svc nop value used by `miniquake.constants`.
const SVC_NOP = 1
/// Defines the svc disconnect value used by `miniquake.constants`.
const SVC_DISCONNECT = 2
/// Defines the svc updatestat value used by `miniquake.constants`.
const SVC_UPDATESTAT = 3
/// Defines the svc version value used by `miniquake.constants`.
const SVC_VERSION = 4
/// Defines the svc setview value used by `miniquake.constants`.
const SVC_SETVIEW = 5
/// Defines the svc sound value used by `miniquake.constants`.
const SVC_SOUND = 6
/// Defines the svc time value used by `miniquake.constants`.
const SVC_TIME = 7
/// Defines the svc print value used by `miniquake.constants`.
const SVC_PRINT = 8
/// Defines the svc stufftext value used by `miniquake.constants`.
const SVC_STUFFTEXT = 9
/// Defines the svc setangle value used by `miniquake.constants`.
const SVC_SETANGLE = 10
/// Defines the svc serverinfo value used by `miniquake.constants`.
const SVC_SERVERINFO = 11
/// Defines the svc lightstyle value used by `miniquake.constants`.
const SVC_LIGHTSTYLE = 12
/// Defines the svc updatename value used by `miniquake.constants`.
const SVC_UPDATENAME = 13
/// Defines the svc updatefrags value used by `miniquake.constants`.
const SVC_UPDATEFRAGS = 14
/// Defines the svc clientdata value used by `miniquake.constants`.
const SVC_CLIENTDATA = 15
/// Defines the svc stopsound value used by `miniquake.constants`.
const SVC_STOPSOUND = 16
/// Defines the svc updatecolors value used by `miniquake.constants`.
const SVC_UPDATECOLORS = 17
/// Defines the svc particle value used by `miniquake.constants`.
const SVC_PARTICLE = 18
/// Defines the svc damage value used by `miniquake.constants`.
const SVC_DAMAGE = 19
/// Defines the svc spawnstatic value used by `miniquake.constants`.
const SVC_SPAWNSTATIC = 20
/// Defines the svc spawnbinary value used by `miniquake.constants`.
const SVC_SPAWNBINARY = 21
/// Defines the svc spawnbaseline value used by `miniquake.constants`.
const SVC_SPAWNBASELINE = 22
/// Defines the svc temp entity value used by `miniquake.constants`.
const SVC_TEMP_ENTITY = 23
/// Defines the svc setpause value used by `miniquake.constants`.
const SVC_SETPAUSE = 24
/// Defines the svc signonnum value used by `miniquake.constants`.
const SVC_SIGNONNUM = 25
/// Defines the svc centerprint value used by `miniquake.constants`.
const SVC_CENTERPRINT = 26
/// Defines the svc killedmonster value used by `miniquake.constants`.
const SVC_KILLEDMONSTER = 27
/// Defines the svc foundsecret value used by `miniquake.constants`.
const SVC_FOUNDSECRET = 28
/// Defines the svc spawnstaticsound value used by `miniquake.constants`.
const SVC_SPAWNSTATICSOUND = 29
/// Defines the svc intermission value used by `miniquake.constants`.
const SVC_INTERMISSION = 30
/// Defines the svc finale value used by `miniquake.constants`.
const SVC_FINALE = 31
/// Defines the svc cdtrack value used by `miniquake.constants`.
const SVC_CDTRACK = 32
/// Defines the svc sellscreen value used by `miniquake.constants`.
const SVC_SELLSCREEN = 33
/// Defines the svc cutscene value used by `miniquake.constants`.
const SVC_CUTSCENE = 34

/// Defines the u morebits value used by `miniquake.constants`.
const U_MOREBITS = 1
/// Defines the u origin1 value used by `miniquake.constants`.
const U_ORIGIN1 = 2
/// Defines the u origin2 value used by `miniquake.constants`.
const U_ORIGIN2 = 4
/// Defines the u origin3 value used by `miniquake.constants`.
const U_ORIGIN3 = 8
/// Defines the u angle2 value used by `miniquake.constants`.
const U_ANGLE2 = 16
/// Defines the u nolerp value used by `miniquake.constants`.
const U_NOLERP = 32
/// Defines the u frame value used by `miniquake.constants`.
const U_FRAME = 64
/// Defines the u signal value used by `miniquake.constants`.
const U_SIGNAL = 128
/// Defines the u angle1 value used by `miniquake.constants`.
const U_ANGLE1 = 256
/// Defines the u angle3 value used by `miniquake.constants`.
const U_ANGLE3 = 512
/// Defines the u model value used by `miniquake.constants`.
const U_MODEL = 1024
/// Defines the u colormap value used by `miniquake.constants`.
const U_COLORMAP = 2048
/// Defines the u skin value used by `miniquake.constants`.
const U_SKIN = 4096
/// Defines the u effects value used by `miniquake.constants`.
const U_EFFECTS = 8192
/// Defines the u longentity value used by `miniquake.constants`.
const U_LONGENTITY = 16384

/// Defines the snd volume value used by `miniquake.constants`.
const SND_VOLUME = 1
/// Defines the snd attenuation value used by `miniquake.constants`.
const SND_ATTENUATION = 2
/// Defines the snd looping value used by `miniquake.constants`.
const SND_LOOPING = 4

/// Defines the ef brightfield value used by `miniquake.constants`.
const EF_BRIGHTFIELD = 1
/// Defines the ef muzzleflash value used by `miniquake.constants`.
const EF_MUZZLEFLASH = 2
/// Defines the ef brightlight value used by `miniquake.constants`.
const EF_BRIGHTLIGHT = 4
/// Defines the ef dimlight value used by `miniquake.constants`.
const EF_DIMLIGHT = 8

// model_t.flags trail/rotation bits from gl_model.h.  These names do not
// overlap the client EF_BRIGHT* namespace despite sharing low bit values.
const EF_ROCKET = 1
/// Defines the ef grenade value used by `miniquake.constants`.
const EF_GRENADE = 2
/// Defines the ef gib value used by `miniquake.constants`.
const EF_GIB = 4
/// Defines the ef rotate value used by `miniquake.constants`.
const EF_ROTATE = 8
/// Defines the ef tracer value used by `miniquake.constants`.
const EF_TRACER = 16
/// Defines the ef zomgib value used by `miniquake.constants`.
const EF_ZOMGIB = 32
/// Defines the ef tracer2 value used by `miniquake.constants`.
const EF_TRACER2 = 64
/// Defines the ef tracer3 value used by `miniquake.constants`.
const EF_TRACER3 = 128

/// Defines the su viewheight value used by `miniquake.constants`.
const SU_VIEWHEIGHT = 1
/// Defines the su idealpitch value used by `miniquake.constants`.
const SU_IDEALPITCH = 2
/// Defines the su punch1 value used by `miniquake.constants`.
const SU_PUNCH1 = 4
/// Defines the su punch2 value used by `miniquake.constants`.
const SU_PUNCH2 = 8
/// Defines the su punch3 value used by `miniquake.constants`.
const SU_PUNCH3 = 16
/// Defines the su velocity1 value used by `miniquake.constants`.
const SU_VELOCITY1 = 32
/// Defines the su velocity2 value used by `miniquake.constants`.
const SU_VELOCITY2 = 64
/// Defines the su velocity3 value used by `miniquake.constants`.
const SU_VELOCITY3 = 128
/// Defines the su items value used by `miniquake.constants`.
const SU_ITEMS = 512
/// Defines the su onground value used by `miniquake.constants`.
const SU_ONGROUND = 1024
/// Defines the su inwater value used by `miniquake.constants`.
const SU_INWATER = 2048
/// Defines the su weaponframe value used by `miniquake.constants`.
const SU_WEAPONFRAME = 4096
/// Defines the su armor value used by `miniquake.constants`.
const SU_ARMOR = 8192
/// Defines the su weapon value used by `miniquake.constants`.
const SU_WEAPON = 16384

/// Defines the clc bad value used by `miniquake.constants`.
const CLC_BAD = 0
/// Defines the clc nop value used by `miniquake.constants`.
const CLC_NOP = 1
/// Defines the clc disconnect value used by `miniquake.constants`.
const CLC_DISCONNECT = 2
/// Defines the clc move value used by `miniquake.constants`.
const CLC_MOVE = 3
/// Defines the clc stringcmd value used by `miniquake.constants`.
const CLC_STRINGCMD = 4

/// Defines the te spike value used by `miniquake.constants`.
const TE_SPIKE = 0
/// Defines the te superspike value used by `miniquake.constants`.
const TE_SUPERSPIKE = 1
/// Defines the te gunshot value used by `miniquake.constants`.
const TE_GUNSHOT = 2
/// Defines the te explosion value used by `miniquake.constants`.
const TE_EXPLOSION = 3
/// Defines the te tarexplosion value used by `miniquake.constants`.
const TE_TAREXPLOSION = 4
/// Defines the te lightning1 value used by `miniquake.constants`.
const TE_LIGHTNING1 = 5
/// Defines the te lightning2 value used by `miniquake.constants`.
const TE_LIGHTNING2 = 6
/// Defines the te wizspike value used by `miniquake.constants`.
const TE_WIZSPIKE = 7
/// Defines the te knightspike value used by `miniquake.constants`.
const TE_KNIGHTSPIKE = 8
/// Defines the te lightning3 value used by `miniquake.constants`.
const TE_LIGHTNING3 = 9
/// Defines the te lavasplash value used by `miniquake.constants`.
const TE_LAVASPLASH = 10
/// Defines the te teleport value used by `miniquake.constants`.
const TE_TELEPORT = 11
/// Defines the te explosion2 value used by `miniquake.constants`.
const TE_EXPLOSION2 = 12
/// Defines the te beam value used by `miniquake.constants`.
const TE_BEAM = 13

// Win32 virtual-key values used by the native input bridge.
const VK_ESCAPE = 27
/// Defines the vk space value used by `miniquake.constants`.
const VK_SPACE = 32
/// Defines the vk shift value used by `miniquake.constants`.
const VK_SHIFT = 16
/// Defines the vk control value used by `miniquake.constants`.
const VK_CONTROL = 17
/// Defines the vk alt value used by `miniquake.constants`.
const VK_ALT = 18
/// Defines the vk tab value used by `miniquake.constants`.
const VK_TAB = 9
/// Defines the vk f1 value used by `miniquake.constants`.
const VK_F1 = 112
/// Defines the vk f12 value used by `miniquake.constants`.
const VK_F12 = 123

// Original Quake player hull and movement defaults.
const PLAYER_MINS_X = -16.0
/// Defines the player mins y value used by `miniquake.constants`.
const PLAYER_MINS_Y = -16.0
/// Defines the player mins z value used by `miniquake.constants`.
const PLAYER_MINS_Z = -24.0
/// Defines the player maxs x value used by `miniquake.constants`.
const PLAYER_MAXS_X = 16.0
/// Defines the player maxs y value used by `miniquake.constants`.
const PLAYER_MAXS_Y = 16.0
/// Defines the player maxs z value used by `miniquake.constants`.
const PLAYER_MAXS_Z = 32.0
/// Defines the default viewheight value used by `miniquake.constants`.
const DEFAULT_VIEWHEIGHT = 22.0
/// Defines the default gravity value used by `miniquake.constants`.
const DEFAULT_GRAVITY = 800.0
/// Defines the default maxspeed value used by `miniquake.constants`.
const DEFAULT_MAXSPEED = 320.0
/// Defines the default accelerate value used by `miniquake.constants`.
const DEFAULT_ACCELERATE = 10.0
/// Defines the default friction value used by `miniquake.constants`.
const DEFAULT_FRICTION = 4.0
/// Defines the default stopspeed value used by `miniquake.constants`.
const DEFAULT_STOPSPEED = 100.0
/// Defines the default jumpspeed value used by `miniquake.constants`.
const DEFAULT_JUMPSPEED = 270.0
/// Defines the step size value used by `miniquake.constants`.
const STEP_SIZE = 18.0

// Entity movement and solidity values from protocol.h / progs.h.
const MOVETYPE_NONE = 0
/// Defines the movetype anglenoclip value used by `miniquake.constants`.
const MOVETYPE_ANGLENOCLIP = 1
/// Defines the movetype angleclip value used by `miniquake.constants`.
const MOVETYPE_ANGLECLIP = 2
/// Defines the movetype walk value used by `miniquake.constants`.
const MOVETYPE_WALK = 3
/// Defines the movetype step value used by `miniquake.constants`.
const MOVETYPE_STEP = 4
/// Defines the movetype fly value used by `miniquake.constants`.
const MOVETYPE_FLY = 5
/// Defines the movetype toss value used by `miniquake.constants`.
const MOVETYPE_TOSS = 6
/// Defines the movetype push value used by `miniquake.constants`.
const MOVETYPE_PUSH = 7
/// Defines the movetype noclip value used by `miniquake.constants`.
const MOVETYPE_NOCLIP = 8
/// Defines the movetype flymissile value used by `miniquake.constants`.
const MOVETYPE_FLYMISSILE = 9
/// Defines the movetype bounce value used by `miniquake.constants`.
const MOVETYPE_BOUNCE = 10

/// Defines the solid not value used by `miniquake.constants`.
const SOLID_NOT = 0
/// Defines the solid trigger value used by `miniquake.constants`.
const SOLID_TRIGGER = 1
/// Defines the solid bbox value used by `miniquake.constants`.
const SOLID_BBOX = 2
/// Defines the solid slidebox value used by `miniquake.constants`.
const SOLID_SLIDEBOX = 3
/// Defines the solid bsp value used by `miniquake.constants`.
const SOLID_BSP = 4

/// Defines the fl fly value used by `miniquake.constants`.
const FL_FLY = 1
/// Defines the fl swim value used by `miniquake.constants`.
const FL_SWIM = 2
/// Defines the fl conveyor value used by `miniquake.constants`.
const FL_CONVEYOR = 4
/// Defines the fl client value used by `miniquake.constants`.
const FL_CLIENT = 8
/// Defines the fl inwater value used by `miniquake.constants`.
const FL_INWATER = 16
/// Defines the fl monster value used by `miniquake.constants`.
const FL_MONSTER = 32
/// Defines the fl godmode value used by `miniquake.constants`.
const FL_GODMODE = 64
/// Defines the fl notarget value used by `miniquake.constants`.
const FL_NOTARGET = 128
/// Defines the fl item value used by `miniquake.constants`.
const FL_ITEM = 256
/// Defines the fl onground value used by `miniquake.constants`.
const FL_ONGROUND = 512
/// Defines the fl partialground value used by `miniquake.constants`.
const FL_PARTIALGROUND = 1024
/// Defines the fl waterjump value used by `miniquake.constants`.
const FL_WATERJUMP = 2048
/// Defines the fl jumpreleased value used by `miniquake.constants`.
const FL_JUMPRELEASED = 4096

/// Defines the damage no value used by `miniquake.constants`.
const DAMAGE_NO = 0
/// Defines the damage yes value used by `miniquake.constants`.
const DAMAGE_YES = 1
/// Defines the damage aim value used by `miniquake.constants`.
const DAMAGE_AIM = 2

/// Defines the game coop value used by `miniquake.constants`.
const GAME_COOP = 0
/// Defines the game deathmatch value used by `miniquake.constants`.
const GAME_DEATHMATCH = 1
/// Defines the signons value used by `miniquake.constants`.
const SIGNONS = 4

// Surface flags used by the GL world renderer.
const SURF_PLANEBACK = 2
/// Defines the surf drawsky value used by `miniquake.constants`.
const SURF_DRAWSKY = 4
/// Defines the surf drawsprite value used by `miniquake.constants`.
const SURF_DRAWSPRITE = 8
/// Defines the surf drawturb value used by `miniquake.constants`.
const SURF_DRAWTURB = 16
/// Defines the surf drawtiled value used by `miniquake.constants`.
const SURF_DRAWTILED = 32
/// Defines the surf drawbackground value used by `miniquake.constants`.
const SURF_DRAWBACKGROUND = 64
/// Defines the surf underwater value used by `miniquake.constants`.
const SURF_UNDERWATER = 128
/// Defines the tex special value used by `miniquake.constants`.
const TEX_SPECIAL = 1
/// Defines the side front value used by `miniquake.constants`.
const SIDE_FRONT = 0
/// Defines the side back value used by `miniquake.constants`.
const SIDE_BACK = 1
/// Defines the side on value used by `miniquake.constants`.
const SIDE_ON = 2
/// Defines the vertexsize value used by `miniquake.constants`.
const VERTEXSIZE = 7

// Classic Quake gameplay/server constants.
const MAX_LIGHTSTYLES = 64
/// Defines the num spawn parms value used by `miniquake.constants`.
const NUM_SPAWN_PARMS = 16
/// Defines the max static entities value used by `miniquake.constants`.
const MAX_STATIC_ENTITIES = 128
/// Defines the max temp entities value used by `miniquake.constants`.
const MAX_TEMP_ENTITIES = 64
/// Defines the max particles value used by `miniquake.constants`.
const MAX_PARTICLES = 2048




/// Defines the move normal value used by `miniquake.constants`.
const MOVE_NORMAL = 0
/// Defines the move nomonsters value used by `miniquake.constants`.
const MOVE_NOMONSTERS = 1
/// Defines the move missile value used by `miniquake.constants`.
const MOVE_MISSILE = 2

/// Defines the button attack value used by `miniquake.constants`.
const BUTTON_ATTACK = 1
/// Defines the button jump value used by `miniquake.constants`.
const BUTTON_JUMP = 2

// Quake item bits used by client rendering and the status bar.
const IT_SHOTGUN = 1
/// Defines the it super shotgun value used by `miniquake.constants`.
const IT_SUPER_SHOTGUN = 2
/// Defines the it nailgun value used by `miniquake.constants`.
const IT_NAILGUN = 4
/// Defines the it super nailgun value used by `miniquake.constants`.
const IT_SUPER_NAILGUN = 8
/// Defines the it grenade launcher value used by `miniquake.constants`.
const IT_GRENADE_LAUNCHER = 16
/// Defines the it rocket launcher value used by `miniquake.constants`.
const IT_ROCKET_LAUNCHER = 32
/// Defines the it lightning value used by `miniquake.constants`.
const IT_LIGHTNING = 64
/// Defines the it super lightning value used by `miniquake.constants`.
const IT_SUPER_LIGHTNING = 128
/// Defines the it shells value used by `miniquake.constants`.
const IT_SHELLS = 256
/// Defines the it nails value used by `miniquake.constants`.
const IT_NAILS = 512
/// Defines the it rockets value used by `miniquake.constants`.
const IT_ROCKETS = 1024
/// Defines the it cells value used by `miniquake.constants`.
const IT_CELLS = 2048
/// Defines the it axe value used by `miniquake.constants`.
const IT_AXE = 4096
/// Defines the it armor1 value used by `miniquake.constants`.
const IT_ARMOR1 = 8192
/// Defines the it armor2 value used by `miniquake.constants`.
const IT_ARMOR2 = 16384
/// Defines the it armor3 value used by `miniquake.constants`.
const IT_ARMOR3 = 32768
/// Defines the it superhealth value used by `miniquake.constants`.
const IT_SUPERHEALTH = 65536
/// Defines the it key1 value used by `miniquake.constants`.
const IT_KEY1 = 131072
/// Defines the it key2 value used by `miniquake.constants`.
const IT_KEY2 = 262144
/// Defines the it invisibility value used by `miniquake.constants`.
const IT_INVISIBILITY = 524288
/// Defines the it invulnerability value used by `miniquake.constants`.
const IT_INVULNERABILITY = 1048576
/// Defines the it suit value used by `miniquake.constants`.
const IT_SUIT = 2097152
/// Defines the it quad value used by `miniquake.constants`.
const IT_QUAD = 4194304
/// Defines the it sigil1 value used by `miniquake.constants`.
const IT_SIGIL1 = 268435456
/// Defines the it sigil2 value used by `miniquake.constants`.
const IT_SIGIL2 = 536870912
/// Defines the it sigil3 value used by `miniquake.constants`.
const IT_SIGIL3 = 1073741824
/// Defines the it sigil4 value used by `miniquake.constants`.
const IT_SIGIL4 = 2147483648

/// Defines the stat health value used by `miniquake.constants`.
const STAT_HEALTH = 0
/// Defines the stat frags value used by `miniquake.constants`.
const STAT_FRAGS = 1
/// Defines the stat weapon value used by `miniquake.constants`.
const STAT_WEAPON = 2
/// Defines the stat ammo value used by `miniquake.constants`.
const STAT_AMMO = 3
/// Defines the stat armor value used by `miniquake.constants`.
const STAT_ARMOR = 4
/// Defines the stat weaponframe value used by `miniquake.constants`.
const STAT_WEAPONFRAME = 5
/// Defines the stat shells value used by `miniquake.constants`.
const STAT_SHELLS = 6
/// Defines the stat nails value used by `miniquake.constants`.
const STAT_NAILS = 7
/// Defines the stat rockets value used by `miniquake.constants`.
const STAT_ROCKETS = 8
/// Defines the stat cells value used by `miniquake.constants`.
const STAT_CELLS = 9
/// Defines the stat activeweapon value used by `miniquake.constants`.
const STAT_ACTIVEWEAPON = 10
/// Defines the stat totalsecrets value used by `miniquake.constants`.
const STAT_TOTALSECRETS = 11
/// Defines the stat totalmonsters value used by `miniquake.constants`.
const STAT_TOTALMONSTERS = 12
/// Defines the stat secrets value used by `miniquake.constants`.
const STAT_SECRETS = 13
/// Defines the stat monsters value used by `miniquake.constants`.
const STAT_MONSTERS = 14
/// Defines the max cl stats value used by `miniquake.constants`.
const MAX_CL_STATS = 32

/// Defines the rit shells value used by `miniquake.constants`.
const RIT_SHELLS = 128
/// Defines the rit nails value used by `miniquake.constants`.
const RIT_NAILS = 256
/// Defines the rit rockets value used by `miniquake.constants`.
const RIT_ROCKETS = 512
/// Defines the rit cells value used by `miniquake.constants`.
const RIT_CELLS = 1024
/// Defines the rit axe value used by `miniquake.constants`.
const RIT_AXE = 2048
/// Defines the rit lava nailgun value used by `miniquake.constants`.
const RIT_LAVA_NAILGUN = 4096
/// Defines the rit lava super nailgun value used by `miniquake.constants`.
const RIT_LAVA_SUPER_NAILGUN = 8192
/// Defines the rit multi grenade value used by `miniquake.constants`.
const RIT_MULTI_GRENADE = 16384
/// Defines the rit multi rocket value used by `miniquake.constants`.
const RIT_MULTI_ROCKET = 32768
/// Defines the rit plasma gun value used by `miniquake.constants`.
const RIT_PLASMA_GUN = 65536
/// Defines the rit armor1 value used by `miniquake.constants`.
const RIT_ARMOR1 = 8388608
/// Defines the rit armor2 value used by `miniquake.constants`.
const RIT_ARMOR2 = 16777216
/// Defines the rit armor3 value used by `miniquake.constants`.
const RIT_ARMOR3 = 33554432
/// Defines the rit lava nails value used by `miniquake.constants`.
const RIT_LAVA_NAILS = 67108864
/// Defines the rit plasma ammo value used by `miniquake.constants`.
const RIT_PLASMA_AMMO = 134217728
/// Defines the rit multi rockets value used by `miniquake.constants`.
const RIT_MULTI_ROCKETS = 268435456
/// Defines the rit shield value used by `miniquake.constants`.
const RIT_SHIELD = 536870912
/// Defines the rit antigrav value used by `miniquake.constants`.
const RIT_ANTIGRAV = 1073741824
/// Defines the rit superhealth value used by `miniquake.constants`.
const RIT_SUPERHEALTH = 2147483648
/// Defines the hit proximity gun bit value used by `miniquake.constants`.
const HIT_PROXIMITY_GUN_BIT = 16
/// Defines the hit mjolnir bit value used by `miniquake.constants`.
const HIT_MJOLNIR_BIT = 7
/// Defines the hit laser cannon bit value used by `miniquake.constants`.
const HIT_LASER_CANNON_BIT = 23
/// Defines the hit proximity gun value used by `miniquake.constants`.
const HIT_PROXIMITY_GUN = 65536
/// Defines the hit mjolnir value used by `miniquake.constants`.
const HIT_MJOLNIR = 128
/// Defines the hit laser cannon value used by `miniquake.constants`.
const HIT_LASER_CANNON = 8388608
/// Defines the hit wetsuit value used by `miniquake.constants`.
const HIT_WETSUIT = 33554432
/// Defines the hit empathy shields value used by `miniquake.constants`.
const HIT_EMPATHY_SHIELDS = 67108864

// Host timing and original movement defaults.
const MINIMUM_FRAME_TIME = 0.001
/// Defines the maximum frame time value used by `miniquake.constants`.
const MAXIMUM_FRAME_TIME = 0.1
/// Defines the default edge friction value used by `miniquake.constants`.
const DEFAULT_EDGE_FRICTION = 2.0
/// Defines the default stop speed value used by `miniquake.constants`.
const DEFAULT_STOP_SPEED = 100.0
/// Defines the default max speed value used by `miniquake.constants`.
const DEFAULT_MAX_SPEED = 320.0
/// Defines the default air accelerate value used by `miniquake.constants`.
const DEFAULT_AIR_ACCELERATE = 0.7
/// Defines the default forward speed value used by `miniquake.constants`.
const DEFAULT_FORWARD_SPEED = 200.0
/// Defines the default back speed value used by `miniquake.constants`.
const DEFAULT_BACK_SPEED = 200.0
/// Defines the default side speed value used by `miniquake.constants`.
const DEFAULT_SIDE_SPEED = 350.0
/// Defines the default up speed value used by `miniquake.constants`.
const DEFAULT_UP_SPEED = 200.0
/// Defines the default step size value used by `miniquake.constants`.
const DEFAULT_STEP_SIZE = 18.0
/// Defines the player view height value used by `miniquake.constants`.
const PLAYER_VIEW_HEIGHT = 22.0

// Protocol-15 signon progress. A connected client remains at 0 until the
// server sends svc_signonnum 1. Network connectivity is tracked separately.
const SIGNON_NONE = 0
/// Defines the signon serverinfo value used by `miniquake.constants`.
const SIGNON_SERVERINFO = 1
/// Defines the signon prespawn value used by `miniquake.constants`.
const SIGNON_PRESPAWN = 2
/// Defines the signon spawn value used by `miniquake.constants`.
const SIGNON_SPAWN = 3
/// Defines the signon active value used by `miniquake.constants`.
const SIGNON_ACTIVE = 4

// Internal renderer flags. BSP texinfo's TEX_SPECIAL remains bit 0.
const SURF_SKY = 1
/// Defines the surf turbulent value used by `miniquake.constants`.
const SURF_TURBULENT = 2
/// Defines the surf missing value used by `miniquake.constants`.
const SURF_MISSING = 4
/// Defines the surf lightmapped value used by `miniquake.constants`.
const SURF_LIGHTMAPPED = 8
/// Defines the surf transparent value used by `miniquake.constants`.
const SURF_TRANSPARENT = 16
/// Defines the lightmap block width value used by `miniquake.constants`.
const LIGHTMAP_BLOCK_WIDTH = 128
/// Defines the lightmap block height value used by `miniquake.constants`.
const LIGHTMAP_BLOCK_HEIGHT = 128
/// Defines the max lightmaps value used by `miniquake.constants`.
const MAX_LIGHTMAPS = 64

// QuakeC value types and generated global offsets.
const EV_VOID = 0
/// Defines the ev string value used by `miniquake.constants`.
const EV_STRING = 1
/// Defines the ev float value used by `miniquake.constants`.
const EV_FLOAT = 2
/// Defines the ev vector value used by `miniquake.constants`.
const EV_VECTOR = 3
/// Defines the ev entity value used by `miniquake.constants`.
const EV_ENTITY = 4
/// Defines the ev field value used by `miniquake.constants`.
const EV_FIELD = 5
/// Defines the ev function value used by `miniquake.constants`.
const EV_FUNCTION = 6
/// Defines the ev pointer value used by `miniquake.constants`.
const EV_POINTER = 7
/// Defines the def saveglobal value used by `miniquake.constants`.
const DEF_SAVEGLOBAL = 0x8000
/// Defines the qc reserved ofs value used by `miniquake.constants`.
const QC_RESERVED_OFS = 28
/// Defines the qc global self value used by `miniquake.constants`.
const QC_GLOBAL_SELF = 28
/// Defines the qc global other value used by `miniquake.constants`.
const QC_GLOBAL_OTHER = 29
/// Defines the qc global world value used by `miniquake.constants`.
const QC_GLOBAL_WORLD = 30
/// Defines the qc global time value used by `miniquake.constants`.
const QC_GLOBAL_TIME = 31
/// Defines the qc global frametime value used by `miniquake.constants`.
const QC_GLOBAL_FRAMETIME = 32
/// Defines the qc max parms value used by `miniquake.constants`.
const QC_MAX_PARMS = 8
/// Defines the qc max ent leafs value used by `miniquake.constants`.
const QC_MAX_ENT_LEAFS = 16
/// Defines the max ent leafs value used by `miniquake.constants`.
const MAX_ENT_LEAFS = QC_MAX_ENT_LEAFS

// Win32 virtual-key values used by the MiniLang input layer.
const VK_BACK = 8
/// Defines the vk return value used by `miniquake.constants`.
const VK_RETURN = 13
/// Defines the vk left value used by `miniquake.constants`.
const VK_LEFT = 37
/// Defines the vk up value used by `miniquake.constants`.
const VK_UP = 38
/// Defines the vk right value used by `miniquake.constants`.
const VK_RIGHT = 39
/// Defines the vk down value used by `miniquake.constants`.
const VK_DOWN = 40
/// Defines the vk delete value used by `miniquake.constants`.
const VK_DELETE = 46
/// Defines the vk 1 value used by `miniquake.constants`.
const VK_1 = 49
/// Defines the vk 2 value used by `miniquake.constants`.
const VK_2 = 50
/// Defines the vk 3 value used by `miniquake.constants`.
const VK_3 = 51
/// Defines the vk 4 value used by `miniquake.constants`.
const VK_4 = 52
/// Defines the vk 5 value used by `miniquake.constants`.
const VK_5 = 53
/// Defines the vk 6 value used by `miniquake.constants`.
const VK_6 = 54
/// Defines the vk 7 value used by `miniquake.constants`.
const VK_7 = 55
/// Defines the vk 8 value used by `miniquake.constants`.
const VK_8 = 56
/// Defines the vk f2 value used by `miniquake.constants`.
const VK_F2 = 113
/// Defines the vk f3 value used by `miniquake.constants`.
const VK_F3 = 114
/// Defines the vk f4 value used by `miniquake.constants`.
const VK_F4 = 115
/// Defines the vk f5 value used by `miniquake.constants`.
const VK_F5 = 116
/// Defines the vk f6 value used by `miniquake.constants`.
const VK_F6 = 117
/// Defines the vk f7 value used by `miniquake.constants`.
const VK_F7 = 118
/// Defines the vk f8 value used by `miniquake.constants`.
const VK_F8 = 119
/// Defines the vk f9 value used by `miniquake.constants`.
const VK_F9 = 120
/// Defines the vk f10 value used by `miniquake.constants`.
const VK_F10 = 121
/// Defines the vk f11 value used by `miniquake.constants`.
const VK_F11 = 122
/// Defines the vk a value used by `miniquake.constants`.
const VK_A = 65
/// Defines the vk c value used by `miniquake.constants`.
const VK_C = 67
/// Defines the vk d value used by `miniquake.constants`.
const VK_D = 68
/// Defines the vk n value used by `miniquake.constants`.
const VK_N = 78
/// Defines the vk s value used by `miniquake.constants`.
const VK_S = 83
/// Defines the vk y value used by `miniquake.constants`.
const VK_Y = 89
/// Defines the vk w value used by `miniquake.constants`.
const VK_W = 87

/// Defines the spawnflag not easy value used by `miniquake.constants`.
const SPAWNFLAG_NOT_EASY = 256
/// Defines the spawnflag not medium value used by `miniquake.constants`.
const SPAWNFLAG_NOT_MEDIUM = 512
/// Defines the spawnflag not hard value used by `miniquake.constants`.
const SPAWNFLAG_NOT_HARD = 1024
/// Defines the spawnflag not deathmatch value used by `miniquake.constants`.
const SPAWNFLAG_NOT_DEATHMATCH = 2048

// Win32 key used by the original Quake console binding (` / ~).
const VK_OEM_3 = 192
