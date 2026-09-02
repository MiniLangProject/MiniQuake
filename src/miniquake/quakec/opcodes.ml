/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang implementation of miniquake.quakec.opcodes.
*/
package miniquake.quakec.opcodes

/// Defines the op done value used by `miniquake.quakec.opcodes`.
const OP_DONE = 0
/// Defines the op mul f value used by `miniquake.quakec.opcodes`.
const OP_MUL_F = 1
/// Defines the op mul v value used by `miniquake.quakec.opcodes`.
const OP_MUL_V = 2
/// Defines the op mul fv value used by `miniquake.quakec.opcodes`.
const OP_MUL_FV = 3
/// Defines the op mul vf value used by `miniquake.quakec.opcodes`.
const OP_MUL_VF = 4
/// Defines the op div f value used by `miniquake.quakec.opcodes`.
const OP_DIV_F = 5
/// Defines the op add f value used by `miniquake.quakec.opcodes`.
const OP_ADD_F = 6
/// Defines the op add v value used by `miniquake.quakec.opcodes`.
const OP_ADD_V = 7
/// Defines the op sub f value used by `miniquake.quakec.opcodes`.
const OP_SUB_F = 8
/// Defines the op sub v value used by `miniquake.quakec.opcodes`.
const OP_SUB_V = 9
/// Defines the op eq f value used by `miniquake.quakec.opcodes`.
const OP_EQ_F = 10
/// Defines the op eq v value used by `miniquake.quakec.opcodes`.
const OP_EQ_V = 11
/// Defines the op eq s value used by `miniquake.quakec.opcodes`.
const OP_EQ_S = 12
/// Defines the op eq e value used by `miniquake.quakec.opcodes`.
const OP_EQ_E = 13
/// Defines the op eq fnc value used by `miniquake.quakec.opcodes`.
const OP_EQ_FNC = 14
/// Defines the op ne f value used by `miniquake.quakec.opcodes`.
const OP_NE_F = 15
/// Defines the op ne v value used by `miniquake.quakec.opcodes`.
const OP_NE_V = 16
/// Defines the op ne s value used by `miniquake.quakec.opcodes`.
const OP_NE_S = 17
/// Defines the op ne e value used by `miniquake.quakec.opcodes`.
const OP_NE_E = 18
/// Defines the op ne fnc value used by `miniquake.quakec.opcodes`.
const OP_NE_FNC = 19
/// Defines the op le value used by `miniquake.quakec.opcodes`.
const OP_LE = 20
/// Defines the op ge value used by `miniquake.quakec.opcodes`.
const OP_GE = 21
/// Defines the op lt value used by `miniquake.quakec.opcodes`.
const OP_LT = 22
/// Defines the op gt value used by `miniquake.quakec.opcodes`.
const OP_GT = 23
/// Defines the op load f value used by `miniquake.quakec.opcodes`.
const OP_LOAD_F = 24
/// Defines the op load v value used by `miniquake.quakec.opcodes`.
const OP_LOAD_V = 25
/// Defines the op load s value used by `miniquake.quakec.opcodes`.
const OP_LOAD_S = 26
/// Defines the op load ent value used by `miniquake.quakec.opcodes`.
const OP_LOAD_ENT = 27
/// Defines the op load fld value used by `miniquake.quakec.opcodes`.
const OP_LOAD_FLD = 28
/// Defines the op load fnc value used by `miniquake.quakec.opcodes`.
const OP_LOAD_FNC = 29
/// Defines the op address value used by `miniquake.quakec.opcodes`.
const OP_ADDRESS = 30
/// Defines the op store f value used by `miniquake.quakec.opcodes`.
const OP_STORE_F = 31
/// Defines the op store v value used by `miniquake.quakec.opcodes`.
const OP_STORE_V = 32
/// Defines the op store s value used by `miniquake.quakec.opcodes`.
const OP_STORE_S = 33
/// Defines the op store ent value used by `miniquake.quakec.opcodes`.
const OP_STORE_ENT = 34
/// Defines the op store fld value used by `miniquake.quakec.opcodes`.
const OP_STORE_FLD = 35
/// Defines the op store fnc value used by `miniquake.quakec.opcodes`.
const OP_STORE_FNC = 36
/// Defines the op storep f value used by `miniquake.quakec.opcodes`.
const OP_STOREP_F = 37
/// Defines the op storep v value used by `miniquake.quakec.opcodes`.
const OP_STOREP_V = 38
/// Defines the op storep s value used by `miniquake.quakec.opcodes`.
const OP_STOREP_S = 39
/// Defines the op storep ent value used by `miniquake.quakec.opcodes`.
const OP_STOREP_ENT = 40
/// Defines the op storep fld value used by `miniquake.quakec.opcodes`.
const OP_STOREP_FLD = 41
/// Defines the op storep fnc value used by `miniquake.quakec.opcodes`.
const OP_STOREP_FNC = 42
/// Defines the op return value used by `miniquake.quakec.opcodes`.
const OP_RETURN = 43
/// Defines the op not f value used by `miniquake.quakec.opcodes`.
const OP_NOT_F = 44
/// Defines the op not v value used by `miniquake.quakec.opcodes`.
const OP_NOT_V = 45
/// Defines the op not s value used by `miniquake.quakec.opcodes`.
const OP_NOT_S = 46
/// Defines the op not ent value used by `miniquake.quakec.opcodes`.
const OP_NOT_ENT = 47
/// Defines the op not fnc value used by `miniquake.quakec.opcodes`.
const OP_NOT_FNC = 48
/// Defines the op if value used by `miniquake.quakec.opcodes`.
const OP_IF = 49
/// Defines the op ifnot value used by `miniquake.quakec.opcodes`.
const OP_IFNOT = 50
/// Defines the op call0 value used by `miniquake.quakec.opcodes`.
const OP_CALL0 = 51
/// Defines the op call1 value used by `miniquake.quakec.opcodes`.
const OP_CALL1 = 52
/// Defines the op call2 value used by `miniquake.quakec.opcodes`.
const OP_CALL2 = 53
/// Defines the op call3 value used by `miniquake.quakec.opcodes`.
const OP_CALL3 = 54
/// Defines the op call4 value used by `miniquake.quakec.opcodes`.
const OP_CALL4 = 55
/// Defines the op call5 value used by `miniquake.quakec.opcodes`.
const OP_CALL5 = 56
/// Defines the op call6 value used by `miniquake.quakec.opcodes`.
const OP_CALL6 = 57
/// Defines the op call7 value used by `miniquake.quakec.opcodes`.
const OP_CALL7 = 58
/// Defines the op call8 value used by `miniquake.quakec.opcodes`.
const OP_CALL8 = 59
/// Defines the op state value used by `miniquake.quakec.opcodes`.
const OP_STATE = 60
/// Defines the op goto value used by `miniquake.quakec.opcodes`.
const OP_GOTO = 61
/// Defines the op and value used by `miniquake.quakec.opcodes`.
const OP_AND = 62
/// Defines the op or value used by `miniquake.quakec.opcodes`.
const OP_OR = 63
/// Defines the op bitand value used by `miniquake.quakec.opcodes`.
const OP_BITAND = 64
/// Defines the op bitor value used by `miniquake.quakec.opcodes`.
const OP_BITOR = 65

/// Defines the ofs null value used by `miniquake.quakec.opcodes`.
const OFS_NULL = 0
/// Defines the ofs return value used by `miniquake.quakec.opcodes`.
const OFS_RETURN = 1
/// Defines the ofs parm0 value used by `miniquake.quakec.opcodes`.
const OFS_PARM0 = 4
/// Defines the ofs parm1 value used by `miniquake.quakec.opcodes`.
const OFS_PARM1 = 7
/// Defines the ofs parm2 value used by `miniquake.quakec.opcodes`.
const OFS_PARM2 = 10
/// Defines the ofs parm3 value used by `miniquake.quakec.opcodes`.
const OFS_PARM3 = 13
/// Defines the ofs parm4 value used by `miniquake.quakec.opcodes`.
const OFS_PARM4 = 16
/// Defines the ofs parm5 value used by `miniquake.quakec.opcodes`.
const OFS_PARM5 = 19
/// Defines the ofs parm6 value used by `miniquake.quakec.opcodes`.
const OFS_PARM6 = 22
/// Defines the ofs parm7 value used by `miniquake.quakec.opcodes`.
const OFS_PARM7 = 25
/// Defines the reserved ofs value used by `miniquake.quakec.opcodes`.
const RESERVED_OFS = 28
/// Defines the max parms value used by `miniquake.quakec.opcodes`.
const MAX_PARMS = 8
