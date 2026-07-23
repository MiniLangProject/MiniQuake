package miniquake.constants

const QUAKE_VERSION = "1.09"
const PROTOCOL_VERSION = 15
const BSP_VERSION = 29
const PROG_VERSION = 6
const MDL_VERSION = 6
const SPRITE_VERSION = 1

const MAX_MSGLEN = 8000
const MAX_DATAGRAM = 1024
const MAX_EDICTS = 600
const MAX_MODELS = 256
const MAX_SOUNDS = 256
const MAX_CLIENTS = 16
const MAX_DLIGHTS = 32
const MAX_VISEDICTS = 256

// Player color translation ranges from render.h.
const TOP_RANGE = 16
const BOTTOM_RANGE = 96

const CONTENTS_EMPTY = -1
const CONTENTS_SOLID = -2
const CONTENTS_WATER = -3
const CONTENTS_SLIME = -4
const CONTENTS_LAVA = -5
const CONTENTS_SKY = -6

const DIST_EPSILON = 0.03125

const LUMP_ENTITIES = 0
const LUMP_PLANES = 1
const LUMP_TEXTURES = 2
const LUMP_VERTEXES = 3
const LUMP_VISIBILITY = 4
const LUMP_NODES = 5
const LUMP_TEXINFO = 6
const LUMP_FACES = 7
const LUMP_LIGHTING = 8
const LUMP_CLIPNODES = 9
const LUMP_LEAFS = 10
const LUMP_MARKSURFACES = 11
const LUMP_EDGES = 12
const LUMP_SURFEDGES = 13
const LUMP_MODELS = 14
const HEADER_LUMPS = 15

const SVC_BAD = 0
const SVC_NOP = 1
const SVC_DISCONNECT = 2
const SVC_UPDATESTAT = 3
const SVC_VERSION = 4
const SVC_SETVIEW = 5
const SVC_SOUND = 6
const SVC_TIME = 7
const SVC_PRINT = 8
const SVC_STUFFTEXT = 9
const SVC_SETANGLE = 10
const SVC_SERVERINFO = 11
const SVC_LIGHTSTYLE = 12
const SVC_UPDATENAME = 13
const SVC_UPDATEFRAGS = 14
const SVC_CLIENTDATA = 15
const SVC_STOPSOUND = 16
const SVC_UPDATECOLORS = 17
const SVC_PARTICLE = 18
const SVC_DAMAGE = 19
const SVC_SPAWNSTATIC = 20
const SVC_SPAWNBINARY = 21
const SVC_SPAWNBASELINE = 22
const SVC_TEMP_ENTITY = 23
const SVC_SETPAUSE = 24
const SVC_SIGNONNUM = 25
const SVC_CENTERPRINT = 26
const SVC_KILLEDMONSTER = 27
const SVC_FOUNDSECRET = 28
const SVC_SPAWNSTATICSOUND = 29
const SVC_INTERMISSION = 30
const SVC_FINALE = 31
const SVC_CDTRACK = 32
const SVC_SELLSCREEN = 33
const SVC_CUTSCENE = 34

const U_MOREBITS = 1
const U_ORIGIN1 = 2
const U_ORIGIN2 = 4
const U_ORIGIN3 = 8
const U_ANGLE2 = 16
const U_NOLERP = 32
const U_FRAME = 64
const U_SIGNAL = 128
const U_ANGLE1 = 256
const U_ANGLE3 = 512
const U_MODEL = 1024
const U_COLORMAP = 2048
const U_SKIN = 4096
const U_EFFECTS = 8192
const U_LONGENTITY = 16384

const EF_BRIGHTFIELD = 1
const EF_MUZZLEFLASH = 2
const EF_BRIGHTLIGHT = 4
const EF_DIMLIGHT = 8

const SU_VIEWHEIGHT = 1
const SU_IDEALPITCH = 2
const SU_PUNCH1 = 4
const SU_PUNCH2 = 8
const SU_PUNCH3 = 16
const SU_VELOCITY1 = 32
const SU_VELOCITY2 = 64
const SU_VELOCITY3 = 128
const SU_ITEMS = 512
const SU_ONGROUND = 1024
const SU_INWATER = 2048
const SU_WEAPONFRAME = 4096
const SU_ARMOR = 8192
const SU_WEAPON = 16384

const CLC_BAD = 0
const CLC_NOP = 1
const CLC_DISCONNECT = 2
const CLC_MOVE = 3
const CLC_STRINGCMD = 4

const TE_SPIKE = 0
const TE_SUPERSPIKE = 1
const TE_GUNSHOT = 2
const TE_EXPLOSION = 3
const TE_TAREXPLOSION = 4
const TE_LIGHTNING1 = 5
const TE_LIGHTNING2 = 6
const TE_WIZSPIKE = 7
const TE_KNIGHTSPIKE = 8
const TE_LIGHTNING3 = 9
const TE_LAVASPLASH = 10
const TE_TELEPORT = 11
const TE_EXPLOSION2 = 12
const TE_BEAM = 13

// Win32 virtual-key values used by the native input bridge.
const VK_ESCAPE = 27
const VK_SPACE = 32
const VK_SHIFT = 16
const VK_CONTROL = 17
const VK_ALT = 18
const VK_TAB = 9
const VK_F1 = 112
const VK_F12 = 123

// Original Quake player hull and movement defaults.
const PLAYER_MINS_X = -16.0
const PLAYER_MINS_Y = -16.0
const PLAYER_MINS_Z = -24.0
const PLAYER_MAXS_X = 16.0
const PLAYER_MAXS_Y = 16.0
const PLAYER_MAXS_Z = 32.0
const DEFAULT_VIEWHEIGHT = 22.0
const DEFAULT_GRAVITY = 800.0
const DEFAULT_MAXSPEED = 320.0
const DEFAULT_ACCELERATE = 10.0
const DEFAULT_FRICTION = 4.0
const DEFAULT_STOPSPEED = 100.0
const DEFAULT_JUMPSPEED = 270.0
const STEP_SIZE = 18.0

// Entity movement and solidity values from protocol.h / progs.h.
const MOVETYPE_NONE = 0
const MOVETYPE_ANGLENOCLIP = 1
const MOVETYPE_ANGLECLIP = 2
const MOVETYPE_WALK = 3
const MOVETYPE_STEP = 4
const MOVETYPE_FLY = 5
const MOVETYPE_TOSS = 6
const MOVETYPE_PUSH = 7
const MOVETYPE_NOCLIP = 8
const MOVETYPE_FLYMISSILE = 9
const MOVETYPE_BOUNCE = 10

const SOLID_NOT = 0
const SOLID_TRIGGER = 1
const SOLID_BBOX = 2
const SOLID_SLIDEBOX = 3
const SOLID_BSP = 4

const FL_FLY = 1
const FL_SWIM = 2
const FL_CONVEYOR = 4
const FL_CLIENT = 8
const FL_INWATER = 16
const FL_MONSTER = 32
const FL_GODMODE = 64
const FL_NOTARGET = 128
const FL_ITEM = 256
const FL_ONGROUND = 512
const FL_PARTIALGROUND = 1024
const FL_WATERJUMP = 2048
const FL_JUMPRELEASED = 4096

const DAMAGE_NO = 0
const DAMAGE_YES = 1
const DAMAGE_AIM = 2

const GAME_COOP = 0
const GAME_DEATHMATCH = 1
const SIGNONS = 4

// Surface flags used by the GL world renderer.
const SURF_PLANEBACK = 2
const SURF_DRAWSKY = 4
const SURF_DRAWSPRITE = 8
const SURF_DRAWTURB = 16
const SURF_DRAWTILED = 32
const SURF_DRAWBACKGROUND = 64
const TEX_SPECIAL = 1

// Classic Quake gameplay/server constants.
const MAX_LIGHTSTYLES = 64
const NUM_SPAWN_PARMS = 16
const MAX_STATIC_ENTITIES = 128
const MAX_TEMP_ENTITIES = 64
const MAX_PARTICLES = 2048




const MOVE_NORMAL = 0
const MOVE_NOMONSTERS = 1
const MOVE_MISSILE = 2

const BUTTON_ATTACK = 1
const BUTTON_JUMP = 2

// Quake item bits used by client rendering and the status bar.
const IT_SHOTGUN = 1
const IT_SUPER_SHOTGUN = 2
const IT_NAILGUN = 4
const IT_SUPER_NAILGUN = 8
const IT_GRENADE_LAUNCHER = 16
const IT_ROCKET_LAUNCHER = 32
const IT_LIGHTNING = 64
const IT_SUPER_LIGHTNING = 128
const IT_SHELLS = 256
const IT_NAILS = 512
const IT_ROCKETS = 1024
const IT_CELLS = 2048
const IT_AXE = 4096
const IT_ARMOR1 = 8192
const IT_ARMOR2 = 16384
const IT_ARMOR3 = 32768
const IT_SUPERHEALTH = 65536
const IT_KEY1 = 131072
const IT_KEY2 = 262144
const IT_INVISIBILITY = 524288
const IT_INVULNERABILITY = 1048576
const IT_SUIT = 2097152
const IT_QUAD = 4194304
const IT_SIGIL1 = 268435456
const IT_SIGIL2 = 536870912
const IT_SIGIL3 = 1073741824
const IT_SIGIL4 = 2147483648

// Host timing and original movement defaults.
const MINIMUM_FRAME_TIME = 0.001
const MAXIMUM_FRAME_TIME = 0.1
const DEFAULT_EDGE_FRICTION = 2.0
const DEFAULT_STOP_SPEED = 100.0
const DEFAULT_MAX_SPEED = 320.0
const DEFAULT_AIR_ACCELERATE = 0.7
const DEFAULT_FORWARD_SPEED = 200.0
const DEFAULT_BACK_SPEED = 200.0
const DEFAULT_SIDE_SPEED = 350.0
const DEFAULT_UP_SPEED = 200.0
const DEFAULT_STEP_SIZE = 18.0
const PLAYER_VIEW_HEIGHT = 22.0

// Protocol-15 signon progress. A connected client remains at 0 until the
// server sends svc_signonnum 1. Network connectivity is tracked separately.
const SIGNON_NONE = 0
const SIGNON_SERVERINFO = 1
const SIGNON_PRESPAWN = 2
const SIGNON_SPAWN = 3
const SIGNON_ACTIVE = 4

// Internal renderer flags. BSP texinfo's TEX_SPECIAL remains bit 0.
const SURF_SKY = 1
const SURF_TURBULENT = 2
const SURF_MISSING = 4
const SURF_LIGHTMAPPED = 8
const SURF_TRANSPARENT = 16
const LIGHTMAP_BLOCK_WIDTH = 128
const LIGHTMAP_BLOCK_HEIGHT = 128
const MAX_LIGHTMAPS = 64

// QuakeC value types and generated global offsets.
const EV_VOID = 0
const EV_STRING = 1
const EV_FLOAT = 2
const EV_VECTOR = 3
const EV_ENTITY = 4
const EV_FIELD = 5
const EV_FUNCTION = 6
const EV_POINTER = 7
const DEF_SAVEGLOBAL = 0x8000
const QC_RESERVED_OFS = 28
const QC_GLOBAL_SELF = 28
const QC_GLOBAL_OTHER = 29
const QC_GLOBAL_WORLD = 30
const QC_GLOBAL_TIME = 31
const QC_GLOBAL_FRAMETIME = 32

// Win32 virtual-key values used by the MiniLang input layer.
const VK_BACK = 8
const VK_RETURN = 13
const VK_LEFT = 37
const VK_UP = 38
const VK_RIGHT = 39
const VK_DOWN = 40
const VK_DELETE = 46
const VK_1 = 49
const VK_2 = 50
const VK_3 = 51
const VK_4 = 52
const VK_5 = 53
const VK_6 = 54
const VK_7 = 55
const VK_8 = 56
const VK_F2 = 113
const VK_F3 = 114
const VK_F4 = 115
const VK_F5 = 116
const VK_F6 = 117
const VK_F7 = 118
const VK_F8 = 119
const VK_F9 = 120
const VK_F10 = 121
const VK_F11 = 122
const VK_A = 65
const VK_C = 67
const VK_D = 68
const VK_N = 78
const VK_S = 83
const VK_Y = 89
const VK_W = 87

const SPAWNFLAG_NOT_EASY = 256
const SPAWNFLAG_NOT_MEDIUM = 512
const SPAWNFLAG_NOT_HARD = 1024
const SPAWNFLAG_NOT_DEATHMATCH = 2048

// Win32 key used by the original Quake console binding (` / ~).
const VK_OEM_3 = 192
