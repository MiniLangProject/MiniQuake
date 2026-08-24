/*
 * Direct3D 9 fixed-function backend for MiniQuake's renderer bridge ABI.
 *
 * Copyright (c) 1996-1997 Id Software, Inc.
 * Copyright (c) 2026 Nils Kopal
 * SPDX-License-Identifier: GPL-2.0-or-later
 *
 * The MiniLang renderer deliberately submits GLQuake's small OpenGL 1.1
 * command vocabulary through a private bridge.  This module translates that
 * vocabulary with Direct3D 9, whose fixed-function state maps directly to the
 * original renderer.  No D3DX runtime or Windows SDK headers are required.
 */
#include "miniquake_d3d9.h"

#define MQ_DLLIMPORT __declspec(dllimport)
#define MQ_WINAPI __stdcall
#define MQ_NULL ((void *)0)

typedef mq_i32 MQ_HRESULT;
typedef mq_i32 MQ_BOOL;
typedef mq_u32 MQ_DWORD;
typedef mq_ptr MQ_HWND;
typedef mq_ptr MQ_HANDLE;
typedef mq_ptr MQ_HMODULE;

/* Store the Direct3D 9 ABI fields for one D3D present parameters. */
typedef struct mq_d3d_present_parameters_s {
    mq_u32 BackBufferWidth;
    mq_u32 BackBufferHeight;
    mq_i32 BackBufferFormat;
    mq_u32 BackBufferCount;
    mq_i32 MultiSampleType;
    mq_u32 MultiSampleQuality;
    mq_i32 SwapEffect;
    MQ_HWND hDeviceWindow;
    MQ_BOOL Windowed;
    MQ_BOOL EnableAutoDepthStencil;
    mq_i32 AutoDepthStencilFormat;
    MQ_DWORD Flags;
    mq_u32 FullScreen_RefreshRateInHz;
    mq_u32 PresentationInterval;
} mq_d3d_present_parameters_t;

/* Store the Direct3D 9 ABI fields for one D3D viewport. */
typedef struct mq_d3d_viewport_s {
    mq_u32 X;
    mq_u32 Y;
    mq_u32 Width;
    mq_u32 Height;
    float MinZ;
    float MaxZ;
} mq_d3d_viewport_t;

/* Store the Direct3D 9 ABI fields for one D3D matrix. */
typedef struct mq_d3d_matrix_s {
    float m[4][4];
} mq_d3d_matrix_t;

/* Store the Direct3D 9 ABI fields for one D3D locked rect. */
typedef struct mq_d3d_locked_rect_s {
    mq_i32 Pitch;
    void *pBits;
} mq_d3d_locked_rect_t;

/* Store the Direct3D 9 ABI fields for one D3D rect. */
typedef struct mq_d3d_rect_s {
    mq_i32 left;
    mq_i32 top;
    mq_i32 right;
    mq_i32 bottom;
} mq_d3d_rect_t;

/* Store the Direct3D 9 ABI fields for one D3D surface desc. */
typedef struct mq_d3d_surface_desc_s {
    mq_i32 Format;
    mq_i32 Type;
    mq_u32 Usage;
    mq_i32 Pool;
    mq_i32 MultiSampleType;
    mq_u32 MultiSampleQuality;
    mq_u32 Width;
    mq_u32 Height;
} mq_d3d_surface_desc_t;

/* Store the Direct3D 9 ABI fields for one D3D display mode. */
typedef struct mq_d3d_display_mode_s {
    mq_u32 Width;
    mq_u32 Height;
    mq_u32 RefreshRate;
    mq_i32 Format;
} mq_d3d_display_mode_t;

/* Store the Direct3D 9 ABI fields for one D3D vertex. */
typedef struct mq_d3d_vertex_s {
    float x;
    float y;
    float z;
    mq_u32 color;
    float s;
    float t;
} mq_d3d_vertex_t;

/* Store the Direct3D 9 ABI fields for one D3D texture. */
typedef struct mq_d3d_texture_s {
    void *object;
    mq_i32 width;
    mq_i32 height;
    mq_i32 min_filter;
    mq_i32 mag_filter;
    mq_i32 wrap_s;
    mq_i32 wrap_t;
    mq_i32 anisotropy;
} mq_d3d_texture_t;

MQ_DLLIMPORT void *MQ_WINAPI Direct3DCreate9(mq_u32 sdk_version);
MQ_DLLIMPORT void * __cdecl memcpy(void *destination, const void *source, mq_u64 count);
MQ_DLLIMPORT void * __cdecl memset(void *destination, mq_i32 value, mq_u64 count);
MQ_DLLIMPORT double __cdecl sin(double value);
MQ_DLLIMPORT double __cdecl cos(double value);
MQ_DLLIMPORT double __cdecl sqrt(double value);
MQ_DLLIMPORT MQ_HMODULE MQ_WINAPI LoadLibraryA(const char *name);
MQ_DLLIMPORT void *MQ_WINAPI GetProcAddress(MQ_HMODULE module, const char *name);
MQ_DLLIMPORT MQ_BOOL MQ_WINAPI FreeLibrary(MQ_HMODULE module);

#define MQ_D3D_METHOD(object, index, type) ((type)(*(void ***)(object))[index])
#define MQ_D3D_SUCCEEDED(value) ((MQ_HRESULT)(value) >= 0)

#define MQ_D3D_SDK_VERSION 32u
#define MQ_D3DDEVTYPE_HAL 1
#define MQ_D3DCREATE_FPU_PRESERVE 0x00000002u
#define MQ_D3DCREATE_SOFTWARE_VERTEXPROCESSING 0x00000020u
#define MQ_D3DCREATE_HARDWARE_VERTEXPROCESSING 0x00000040u
#define MQ_D3DFMT_UNKNOWN 0
#define MQ_D3DFMT_A8R8G8B8 21
#define MQ_D3DFMT_X8R8G8B8 22
#define MQ_D3DFMT_D24S8 75
#define MQ_D3DFMT_D16 80
#define MQ_D3DMULTISAMPLE_NONE 0
#define MQ_D3DSWAPEFFECT_DISCARD 1
#define MQ_D3DPRESENT_INTERVAL_IMMEDIATE 0x80000000u
#define MQ_D3DPOOL_MANAGED 1
#define MQ_D3DPOOL_SYSTEMMEM 2
#define MQ_D3DCLEAR_TARGET 0x00000001u
#define MQ_D3DCLEAR_ZBUFFER 0x00000002u
#define MQ_D3DLOCK_READONLY 0x00000010u

#define MQ_D3DRS_ZENABLE 7
#define MQ_D3DRS_FILLMODE 8
#define MQ_D3DRS_SHADEMODE 9
#define MQ_D3DRS_ZWRITEENABLE 14
#define MQ_D3DRS_ALPHATESTENABLE 15
#define MQ_D3DRS_SRCBLEND 19
#define MQ_D3DRS_DESTBLEND 20
#define MQ_D3DRS_CULLMODE 22
#define MQ_D3DRS_ZFUNC 23
#define MQ_D3DRS_ALPHAREF 24
#define MQ_D3DRS_ALPHAFUNC 25
#define MQ_D3DRS_ALPHABLENDENABLE 27
#define MQ_D3DRS_CLIPPING 136
#define MQ_D3DRS_LIGHTING 137
#define MQ_D3DRS_COLORVERTEX 141

#define MQ_D3DFILL_WIREFRAME 2
#define MQ_D3DFILL_SOLID 3
#define MQ_D3DSHADE_FLAT 1
#define MQ_D3DSHADE_GOURAUD 2
#define MQ_D3DBLEND_ZERO 1
#define MQ_D3DBLEND_ONE 2
#define MQ_D3DBLEND_SRCCOLOR 3
#define MQ_D3DBLEND_INVSRCCOLOR 4
#define MQ_D3DBLEND_SRCALPHA 5
#define MQ_D3DBLEND_INVSRCALPHA 6
#define MQ_D3DBLEND_DESTCOLOR 9
#define MQ_D3DBLEND_INVDESTCOLOR 10
#define MQ_D3DCULL_NONE 1
#define MQ_D3DCULL_CW 2
#define MQ_D3DCULL_CCW 3
#define MQ_D3DCMP_LESS 2
#define MQ_D3DCMP_LESSEQUAL 4
#define MQ_D3DCMP_GREATER 5
#define MQ_D3DCMP_GREATEREQUAL 7
#define MQ_D3DCMP_ALWAYS 8

#define MQ_D3DTSS_COLOROP 1
#define MQ_D3DTSS_COLORARG1 2
#define MQ_D3DTSS_COLORARG2 3
#define MQ_D3DTSS_ALPHAOP 4
#define MQ_D3DTSS_ALPHAARG1 5
#define MQ_D3DTSS_ALPHAARG2 6
#define MQ_D3DTOP_DISABLE 1
#define MQ_D3DTOP_SELECTARG1 2
#define MQ_D3DTOP_MODULATE 4
#define MQ_D3DTA_DIFFUSE 0
#define MQ_D3DTA_TEXTURE 2

#define MQ_D3DSAMP_ADDRESSU 1
#define MQ_D3DSAMP_ADDRESSV 2
#define MQ_D3DSAMP_MAGFILTER 5
#define MQ_D3DSAMP_MINFILTER 6
#define MQ_D3DSAMP_MIPFILTER 7
#define MQ_D3DSAMP_MAXANISOTROPY 10
#define MQ_D3DTADDRESS_WRAP 1
#define MQ_D3DTADDRESS_CLAMP 3
#define MQ_D3DTEXF_NONE 0
#define MQ_D3DTEXF_POINT 1
#define MQ_D3DTEXF_LINEAR 2
#define MQ_D3DTEXF_ANISOTROPIC 3

#define MQ_D3DPT_POINTLIST 1
#define MQ_D3DPT_LINELIST 2
#define MQ_D3DPT_LINESTRIP 3
#define MQ_D3DPT_TRIANGLELIST 4
#define MQ_D3DPT_TRIANGLESTRIP 5
#define MQ_D3DPT_TRIANGLEFAN 6
#define MQ_D3DTS_VIEW 2
#define MQ_D3DTS_PROJECTION 3
#define MQ_D3DTS_WORLD 256
#define MQ_D3DFVF_XYZ 0x0002u
#define MQ_D3DFVF_DIFFUSE 0x0040u
#define MQ_D3DFVF_TEX1 0x0100u

#define MQ_GL_POINTS 0x0000u
#define MQ_GL_LINES 0x0001u
#define MQ_GL_LINE_LOOP 0x0002u
#define MQ_GL_LINE_STRIP 0x0003u
#define MQ_GL_TRIANGLES 0x0004u
#define MQ_GL_TRIANGLE_STRIP 0x0005u
#define MQ_GL_TRIANGLE_FAN 0x0006u
#define MQ_GL_QUADS 0x0007u
#define MQ_GL_POLYGON 0x0009u
#define MQ_GL_DEPTH_BUFFER_BIT 0x00000100u
#define MQ_GL_COLOR_BUFFER_BIT 0x00004000u
#define MQ_GL_DEPTH_TEST 0x0B71u
#define MQ_GL_BLEND 0x0BE2u
#define MQ_GL_TEXTURE_2D 0x0DE1u
#define MQ_GL_CULL_FACE 0x0B44u
#define MQ_GL_ALPHA_TEST 0x0BC0u
#define MQ_GL_PROJECTION 0x1701u
#define MQ_GL_MODELVIEW 0x1700u
#define MQ_GL_LEQUAL 0x0203u
#define MQ_GL_GEQUAL 0x0206u
#define MQ_GL_GREATER 0x0204u
#define MQ_GL_SMOOTH 0x1D01u
#define MQ_GL_FRONT 0x0404u
#define MQ_GL_LINE 0x1B01u
#define MQ_GL_SRC_ALPHA 0x0302u
#define MQ_GL_ONE_MINUS_SRC_ALPHA 0x0303u
#define MQ_GL_SRC_COLOR 0x0300u
#define MQ_GL_ONE_MINUS_SRC_COLOR 0x0301u
#define MQ_GL_DST_COLOR 0x0306u
#define MQ_GL_ONE_MINUS_DST_COLOR 0x0307u
#define MQ_GL_ZERO 0u
#define MQ_GL_ONE 1u
#define MQ_GL_RGBA 0x1908u
#define MQ_GL_RGB 0x1907u
#define MQ_GL_LUMINANCE 0x1909u
#define MQ_GL_COLOR_INDEX 0x1900u
#define MQ_GL_UNSIGNED_BYTE 0x1401u
#define MQ_GL_TEXTURE_MIN_FILTER 0x2801u
#define MQ_GL_TEXTURE_MAG_FILTER 0x2800u
#define MQ_GL_TEXTURE_WRAP_S 0x2802u
#define MQ_GL_TEXTURE_WRAP_T 0x2803u
#define MQ_GL_TEXTURE_MAX_ANISOTROPY_EXT 0x84FEu
#define MQ_GL_NEAREST 0x2600u
#define MQ_GL_LINEAR 0x2601u
#define MQ_GL_NEAREST_MIPMAP_NEAREST 0x2700u
#define MQ_GL_LINEAR_MIPMAP_NEAREST 0x2701u
#define MQ_GL_NEAREST_MIPMAP_LINEAR 0x2702u
#define MQ_GL_LINEAR_MIPMAP_LINEAR 0x2703u
#define MQ_GL_REPEAT 0x2901u
#define MQ_GL_CLAMP 0x2900u
#define MQ_GL_TEXTURE_ENV_MODE 0x2200u
#define MQ_GL_REPLACE 0x1E01u
#define MQ_GL_MODULATE 0x2100u
#define MQ_GL_VENDOR 0x1F00u
#define MQ_GL_RENDERER 0x1F01u
#define MQ_GL_VERSION 0x1F02u
#define MQ_GL_EXTENSIONS 0x1F03u

#define MQ_D3D_MAX_TEXTURES 16384u
#define MQ_D3D_MAX_VERTICES 65536u
#define MQ_D3D_MATRIX_STACK 64u
#define MQ_D3D_RENDER_STATE_CACHE_SIZE 256u
#define MQ_D3D_STAGE_STATE_CACHE_SIZE 32u
#define MQ_D3D_SAMPLER_STATE_CACHE_SIZE 32u

static void *mq_d3d_object = MQ_NULL;
static void *mq_d3d_device = MQ_NULL;
static MQ_HWND mq_d3d_window = MQ_NULL;
static mq_d3d_present_parameters_t mq_d3d_present;
static mq_i32 mq_d3d_width = 0;
static mq_i32 mq_d3d_height = 0;
static MQ_HRESULT mq_d3d_last_error = 0;
static mq_u32 mq_d3d_clear_color_value = 0xff000000u;
static mq_u32 mq_d3d_current_color = 0xffffffffu;
static float mq_d3d_current_s = 0.0f;
static float mq_d3d_current_t = 0.0f;
static mq_u32 mq_d3d_primitive_mode = MQ_GL_TRIANGLES;
static mq_d3d_vertex_t mq_d3d_vertices[MQ_D3D_MAX_VERTICES];
static mq_d3d_vertex_t mq_d3d_expanded_vertices[MQ_D3D_MAX_VERTICES + (MQ_D3D_MAX_VERTICES / 2u)];
static mq_u32 mq_d3d_vertex_count = 0u;
static mq_d3d_texture_t mq_d3d_textures[MQ_D3D_MAX_TEXTURES];
static mq_u32 mq_d3d_bound_texture = 0u;
static mq_u32 mq_d3d_next_texture = 1u;
static mq_i32 mq_d3d_texture_enabled = 1;
static mq_i32 mq_d3d_texture_environment = MQ_GL_REPLACE;
static mq_i32 mq_d3d_cull_enabled = 0;
static mq_i32 mq_d3d_cull_mode = MQ_D3DCULL_CCW;
static mq_i32 mq_d3d_viewport_x = 0;
static mq_i32 mq_d3d_viewport_y = 0;
static mq_i32 mq_d3d_viewport_width = 1;
static mq_i32 mq_d3d_viewport_height = 1;
static float mq_d3d_depth_min = 0.0f;
static float mq_d3d_depth_max = 1.0f;
static mq_u32 mq_d3d_matrix_mode_value = MQ_GL_MODELVIEW;
static float mq_d3d_modelview_stack[MQ_D3D_MATRIX_STACK][16];
static float mq_d3d_projection_stack[MQ_D3D_MATRIX_STACK][16];
static mq_u32 mq_d3d_modelview_top = 0u;
static mq_u32 mq_d3d_projection_top = 0u;
static mq_i32 mq_d3d_matrices_dirty = 1;
static void *mq_d3d_enhanced_vertex_shader = MQ_NULL;
static void *mq_d3d_enhanced_pixel_shader = MQ_NULL;
static mq_i32 mq_d3d_enhanced_enabled = 0;
static mq_i32 mq_d3d_enhanced_draw_kind_value = 0;
static mq_i32 mq_d3d_enhanced_light_count = 0;
static float mq_d3d_enhanced_view[16];
static float mq_d3d_enhanced_lights[16];
/* Direct3D state setters are COM calls and remain surprisingly expensive in
 * the GLQuake-style renderer, which deliberately repeats state restoration at
 * pass boundaries.  Cache only successful device writes; reset/loss paths
 * invalidate every entry before rebuilding the default state. */
static mq_u32 mq_d3d_render_state_cache[MQ_D3D_RENDER_STATE_CACHE_SIZE];
static mq_u8 mq_d3d_render_state_valid[MQ_D3D_RENDER_STATE_CACHE_SIZE];
static mq_u32 mq_d3d_stage_state_cache[MQ_D3D_STAGE_STATE_CACHE_SIZE];
static mq_u8 mq_d3d_stage_state_valid[MQ_D3D_STAGE_STATE_CACHE_SIZE];
static mq_u32 mq_d3d_sampler_state_cache[MQ_D3D_SAMPLER_STATE_CACHE_SIZE];
static mq_u8 mq_d3d_sampler_state_valid[MQ_D3D_SAMPLER_STATE_CACHE_SIZE];
static void *mq_d3d_applied_texture_object = MQ_NULL;

typedef mq_u32 (MQ_WINAPI *mq_d3d_release_fn)(void *self);
typedef MQ_HRESULT (MQ_WINAPI *mq_d3d_create_device_fn)(void *, mq_u32, mq_i32, MQ_HWND, mq_u32, mq_d3d_present_parameters_t *, void **);
typedef MQ_HRESULT (MQ_WINAPI *mq_d3d_check_device_type_fn)(void *, mq_u32, mq_i32, mq_i32, mq_i32, MQ_BOOL);
typedef MQ_HRESULT (MQ_WINAPI *mq_d3d_get_display_mode_fn)(void *, mq_u32, mq_d3d_display_mode_t *);
typedef MQ_HRESULT (MQ_WINAPI *mq_d3d_reset_fn)(void *, mq_d3d_present_parameters_t *);
typedef MQ_HRESULT (MQ_WINAPI *mq_d3d_present_fn)(void *, const void *, const void *, MQ_HWND, const void *);
typedef MQ_HRESULT (MQ_WINAPI *mq_d3d_test_cooperative_fn)(void *);
typedef MQ_HRESULT (MQ_WINAPI *mq_d3d_begin_scene_fn)(void *);
typedef MQ_HRESULT (MQ_WINAPI *mq_d3d_end_scene_fn)(void *);
typedef MQ_HRESULT (MQ_WINAPI *mq_d3d_clear_fn)(void *, mq_u32, const void *, mq_u32, mq_u32, float, mq_u32);
typedef MQ_HRESULT (MQ_WINAPI *mq_d3d_set_transform_fn)(void *, mq_i32, const mq_d3d_matrix_t *);
typedef MQ_HRESULT (MQ_WINAPI *mq_d3d_set_viewport_fn)(void *, const mq_d3d_viewport_t *);
typedef MQ_HRESULT (MQ_WINAPI *mq_d3d_set_render_state_fn)(void *, mq_i32, mq_u32);
typedef MQ_HRESULT (MQ_WINAPI *mq_d3d_set_texture_fn)(void *, mq_u32, void *);
typedef MQ_HRESULT (MQ_WINAPI *mq_d3d_set_texture_stage_state_fn)(void *, mq_u32, mq_i32, mq_u32);
typedef MQ_HRESULT (MQ_WINAPI *mq_d3d_set_sampler_state_fn)(void *, mq_u32, mq_i32, mq_u32);
typedef MQ_HRESULT (MQ_WINAPI *mq_d3d_set_fvf_fn)(void *, mq_u32);
typedef MQ_HRESULT (MQ_WINAPI *mq_d3d_draw_primitive_up_fn)(void *, mq_i32, mq_u32, const void *, mq_u32);
typedef MQ_HRESULT (MQ_WINAPI *mq_d3d_create_texture_fn)(void *, mq_u32, mq_u32, mq_u32, mq_u32, mq_i32, mq_i32, void **, MQ_HANDLE *);
typedef MQ_HRESULT (MQ_WINAPI *mq_d3d_texture_lock_rect_fn)(void *, mq_u32, mq_d3d_locked_rect_t *, const mq_d3d_rect_t *, mq_u32);
typedef MQ_HRESULT (MQ_WINAPI *mq_d3d_texture_unlock_rect_fn)(void *, mq_u32);
typedef MQ_HRESULT (MQ_WINAPI *mq_d3d_get_render_target_fn)(void *, mq_u32, void **);
typedef MQ_HRESULT (MQ_WINAPI *mq_d3d_get_render_target_data_fn)(void *, void *, void *);
typedef MQ_HRESULT (MQ_WINAPI *mq_d3d_create_offscreen_surface_fn)(void *, mq_u32, mq_u32, mq_i32, mq_i32, void **, MQ_HANDLE *);
typedef MQ_HRESULT (MQ_WINAPI *mq_d3d_surface_get_desc_fn)(void *, mq_d3d_surface_desc_t *);
typedef MQ_HRESULT (MQ_WINAPI *mq_d3d_surface_lock_rect_fn)(void *, mq_d3d_locked_rect_t *, const mq_d3d_rect_t *, mq_u32);
typedef MQ_HRESULT (MQ_WINAPI *mq_d3d_surface_unlock_rect_fn)(void *);
typedef MQ_HRESULT (MQ_WINAPI *mq_d3d_create_vertex_shader_fn)(void *, const mq_u32 *, void **);
typedef MQ_HRESULT (MQ_WINAPI *mq_d3d_set_vertex_shader_fn)(void *, void *);
typedef MQ_HRESULT (MQ_WINAPI *mq_d3d_set_vertex_shader_constant_f_fn)(void *, mq_u32, const float *, mq_u32);
typedef MQ_HRESULT (MQ_WINAPI *mq_d3d_create_pixel_shader_fn)(void *, const mq_u32 *, void **);
typedef MQ_HRESULT (MQ_WINAPI *mq_d3d_set_pixel_shader_fn)(void *, void *);
typedef MQ_HRESULT (MQ_WINAPI *mq_d3d_set_pixel_shader_constant_f_fn)(void *, mq_u32, const float *, mq_u32);
typedef MQ_HRESULT (MQ_WINAPI *mq_d3d_compile_fn)(
    const void *, mq_u64, const char *, const void *, void *, const char *,
    const char *, mq_u32, mq_u32, void **, void **);
typedef void * (MQ_WINAPI *mq_d3d_blob_pointer_fn)(void *);

static void mq_d3d_release(void **object);

/* Reinterpret MiniLang's IEEE-754 bit pattern as a native float. */
static float mq_d3d_bits_to_float(mq_u32 bits) {
    union { mq_u32 u; float f; } value;
    value.u = bits;
    return value.f;
}

/* Clamp a scalar to the inclusive requested range. */
static float mq_d3d_clamp(float value, float minimum, float maximum) {
    if (value < minimum) return minimum;
    if (value > maximum) return maximum;
    return value;
}

/* Pack normalized RGBA components into Direct3D's ARGB vertex format. */
static mq_u32 mq_d3d_color(float red, float green, float blue, float alpha) {
    mq_u32 r = (mq_u32)(mq_d3d_clamp(red, 0.0f, 1.0f) * 255.0f + 0.5f);
    mq_u32 g = (mq_u32)(mq_d3d_clamp(green, 0.0f, 1.0f) * 255.0f + 0.5f);
    mq_u32 b = (mq_u32)(mq_d3d_clamp(blue, 0.0f, 1.0f) * 255.0f + 0.5f);
    mq_u32 a = (mq_u32)(mq_d3d_clamp(alpha, 0.0f, 1.0f) * 255.0f + 0.5f);
    return (a << 24) | (r << 16) | (g << 8) | b;
}

/* Initialize a column-major identity matrix. */
static void mq_d3d_identity(float *matrix) {
    mq_u32 i;
    for (i = 0u; i < 16u; ++i) matrix[i] = 0.0f;
    matrix[0] = 1.0f;
    matrix[5] = 1.0f;
    matrix[10] = 1.0f;
    matrix[15] = 1.0f;
}

/* Multiply two column-major transform matrices. */
static void mq_d3d_multiply(float *output, const float *left, const float *right) {
    float result[16];
    mq_u32 row;
    mq_u32 column;
    mq_u32 inner;
    for (column = 0u; column < 4u; ++column) {
        for (row = 0u; row < 4u; ++row) {
            float value = 0.0f;
            for (inner = 0u; inner < 4u; ++inner) {
                value += left[inner * 4u + row] * right[column * 4u + inner];
            }
            result[column * 4u + row] = value;
        }
    }
    memcpy(output, result, sizeof(result));
}

static float *mq_d3d_current_matrix(void) {
    if (mq_d3d_matrix_mode_value == MQ_GL_PROJECTION) return mq_d3d_projection_stack[mq_d3d_projection_top];
    return mq_d3d_modelview_stack[mq_d3d_modelview_top];
}

/* Multiply two column-major transform matrices. */
static void mq_d3d_postmultiply(const float *right) {
    float *current = mq_d3d_current_matrix();
    mq_d3d_multiply(current, current, right);
    mq_d3d_matrices_dirty = 1;
}

/* Transpose a column-major matrix for Direct3D. */
static void mq_d3d_transpose(mq_d3d_matrix_t *output, const float *input) {
    mq_u32 row;
    mq_u32 column;
    for (row = 0u; row < 4u; ++row) {
        for (column = 0u; column < 4u; ++column) {
            output->m[row][column] = input[row * 4u + column];
        }
    }
}

/* Apply matrices to the active backend state. */
static void mq_d3d_apply_matrices(void) {
    mq_d3d_matrix_t world;
    mq_d3d_matrix_t view;
    mq_d3d_matrix_t projection;
    float identity[16];
    float depth_conversion[16];
    float converted_projection[16];
    mq_d3d_set_transform_fn set_transform;
    if (mq_d3d_device == MQ_NULL || !mq_d3d_matrices_dirty) return;
    set_transform = MQ_D3D_METHOD(mq_d3d_device, 44, mq_d3d_set_transform_fn);
    mq_d3d_transpose(&world, mq_d3d_modelview_stack[mq_d3d_modelview_top]);
    mq_d3d_identity(identity);
    mq_d3d_transpose(&view, identity);
    mq_d3d_identity(depth_conversion);
    depth_conversion[10] = mq_d3d_depth_min > mq_d3d_depth_max ? -0.5f : 0.5f;
    depth_conversion[14] = 0.5f;
    mq_d3d_multiply(converted_projection, depth_conversion, mq_d3d_projection_stack[mq_d3d_projection_top]);
    mq_d3d_transpose(&projection, converted_projection);
    mq_d3d_last_error = set_transform(mq_d3d_device, MQ_D3DTS_WORLD, &world);
    set_transform(mq_d3d_device, MQ_D3DTS_VIEW, &view);
    set_transform(mq_d3d_device, MQ_D3DTS_PROJECTION, &projection);
    mq_d3d_matrices_dirty = 0;
}

/* Apply viewport to the active backend state. */
static void mq_d3d_apply_viewport(void) {
    mq_d3d_viewport_t viewport;
    mq_i32 top;
    if (mq_d3d_device == MQ_NULL) return;
    top = mq_d3d_height - mq_d3d_viewport_y - mq_d3d_viewport_height;
    if (top < 0) top = 0;
    viewport.X = (mq_u32)(mq_d3d_viewport_x < 0 ? 0 : mq_d3d_viewport_x);
    viewport.Y = (mq_u32)top;
    viewport.Width = (mq_u32)(mq_d3d_viewport_width < 1 ? 1 : mq_d3d_viewport_width);
    viewport.Height = (mq_u32)(mq_d3d_viewport_height < 1 ? 1 : mq_d3d_viewport_height);
    if (mq_d3d_depth_min <= mq_d3d_depth_max) {
        viewport.MinZ = mq_d3d_depth_min;
        viewport.MaxZ = mq_d3d_depth_max;
    } else {
        viewport.MinZ = mq_d3d_depth_max;
        viewport.MaxZ = mq_d3d_depth_min;
    }
    mq_d3d_last_error = MQ_D3D_METHOD(mq_d3d_device, 47, mq_d3d_set_viewport_fn)(mq_d3d_device, &viewport);
}

/* Forget device-side state after create, reset, loss or shutdown. */
static void mq_d3d_invalidate_state_cache(void) {
    memset(mq_d3d_render_state_valid, 0, sizeof(mq_d3d_render_state_valid));
    memset(mq_d3d_stage_state_valid, 0, sizeof(mq_d3d_stage_state_valid));
    memset(mq_d3d_sampler_state_valid, 0, sizeof(mq_d3d_sampler_state_valid));
    mq_d3d_applied_texture_object = MQ_NULL;
}

/* Update backend state for render state. */
static void mq_d3d_set_render_state(mq_i32 state, mq_u32 value) {
    if (mq_d3d_device != MQ_NULL) {
        MQ_HRESULT result;
        if (state >= 0 && (mq_u32)state < MQ_D3D_RENDER_STATE_CACHE_SIZE &&
            mq_d3d_render_state_valid[state] && mq_d3d_render_state_cache[state] == value) {
            mq_d3d_last_error = 0;
            return;
        }
        result = MQ_D3D_METHOD(mq_d3d_device, 57, mq_d3d_set_render_state_fn)(mq_d3d_device, state, value);
        mq_d3d_last_error = result;
        if (MQ_D3D_SUCCEEDED(result) && state >= 0 && (mq_u32)state < MQ_D3D_RENDER_STATE_CACHE_SIZE) {
            mq_d3d_render_state_cache[state] = value;
            mq_d3d_render_state_valid[state] = 1u;
        }
    }
}

/* Update backend state for stage state. */
static void mq_d3d_set_stage_state(mq_i32 state, mq_u32 value) {
    if (mq_d3d_device != MQ_NULL) {
        MQ_HRESULT result;
        if (state >= 0 && (mq_u32)state < MQ_D3D_STAGE_STATE_CACHE_SIZE &&
            mq_d3d_stage_state_valid[state] && mq_d3d_stage_state_cache[state] == value) {
            mq_d3d_last_error = 0;
            return;
        }
        result = MQ_D3D_METHOD(mq_d3d_device, 67, mq_d3d_set_texture_stage_state_fn)(mq_d3d_device, 0u, state, value);
        mq_d3d_last_error = result;
        if (MQ_D3D_SUCCEEDED(result) && state >= 0 && (mq_u32)state < MQ_D3D_STAGE_STATE_CACHE_SIZE) {
            mq_d3d_stage_state_cache[state] = value;
            mq_d3d_stage_state_valid[state] = 1u;
        }
    }
}

/* Update backend state for sampler state. */
static void mq_d3d_set_sampler_state(mq_i32 state, mq_u32 value) {
    if (mq_d3d_device != MQ_NULL) {
        MQ_HRESULT result;
        if (state >= 0 && (mq_u32)state < MQ_D3D_SAMPLER_STATE_CACHE_SIZE &&
            mq_d3d_sampler_state_valid[state] && mq_d3d_sampler_state_cache[state] == value) {
            mq_d3d_last_error = 0;
            return;
        }
        result = MQ_D3D_METHOD(mq_d3d_device, 69, mq_d3d_set_sampler_state_fn)(mq_d3d_device, 0u, state, value);
        mq_d3d_last_error = result;
        if (MQ_D3D_SUCCEEDED(result) && state >= 0 && (mq_u32)state < MQ_D3D_SAMPLER_STATE_CACHE_SIZE) {
            mq_d3d_sampler_state_cache[state] = value;
            mq_d3d_sampler_state_valid[state] = 1u;
        }
    }
}

/* Translate a GL texture-filter token to the backend-specific value. */
static mq_u32 mq_d3d_min_filter_value(mq_i32 value) {
    if (value == MQ_GL_LINEAR || value == MQ_GL_LINEAR_MIPMAP_NEAREST || value == MQ_GL_LINEAR_MIPMAP_LINEAR) return MQ_D3DTEXF_LINEAR;
    return MQ_D3DTEXF_POINT;
}

/* Translate a GL texture-filter token to the backend-specific value. */
static mq_u32 mq_d3d_mip_filter_value(mq_i32 value) {
    if (value == MQ_GL_NEAREST || value == MQ_GL_LINEAR) return MQ_D3DTEXF_NONE;
    if (value == MQ_GL_NEAREST_MIPMAP_LINEAR || value == MQ_GL_LINEAR_MIPMAP_LINEAR) return MQ_D3DTEXF_LINEAR;
    return MQ_D3DTEXF_POINT;
}

/* Apply texture environment to the active backend state. */
static void mq_d3d_apply_texture_environment(void) {
    if (!mq_d3d_texture_enabled) {
        mq_d3d_set_stage_state(MQ_D3DTSS_COLOROP, MQ_D3DTOP_DISABLE);
        mq_d3d_set_stage_state(MQ_D3DTSS_ALPHAOP, MQ_D3DTOP_DISABLE);
        return;
    }
    if (mq_d3d_texture_environment == MQ_GL_MODULATE) {
        mq_d3d_set_stage_state(MQ_D3DTSS_COLOROP, MQ_D3DTOP_MODULATE);
        mq_d3d_set_stage_state(MQ_D3DTSS_COLORARG1, MQ_D3DTA_TEXTURE);
        mq_d3d_set_stage_state(MQ_D3DTSS_COLORARG2, MQ_D3DTA_DIFFUSE);
        mq_d3d_set_stage_state(MQ_D3DTSS_ALPHAOP, MQ_D3DTOP_MODULATE);
        mq_d3d_set_stage_state(MQ_D3DTSS_ALPHAARG1, MQ_D3DTA_TEXTURE);
        mq_d3d_set_stage_state(MQ_D3DTSS_ALPHAARG2, MQ_D3DTA_DIFFUSE);
    } else {
        mq_d3d_set_stage_state(MQ_D3DTSS_COLOROP, MQ_D3DTOP_SELECTARG1);
        mq_d3d_set_stage_state(MQ_D3DTSS_COLORARG1, MQ_D3DTA_TEXTURE);
        mq_d3d_set_stage_state(MQ_D3DTSS_ALPHAOP, MQ_D3DTOP_SELECTARG1);
        mq_d3d_set_stage_state(MQ_D3DTSS_ALPHAARG1, MQ_D3DTA_TEXTURE);
    }
}

/* Apply bound texture to the active backend state. */
static void mq_d3d_apply_bound_texture(void) {
    mq_d3d_texture_t *texture = MQ_NULL;
    void *object = MQ_NULL;
    if (mq_d3d_bound_texture < MQ_D3D_MAX_TEXTURES) {
        texture = &mq_d3d_textures[mq_d3d_bound_texture];
        object = texture->object;
    }
    if (mq_d3d_device != MQ_NULL && object != mq_d3d_applied_texture_object) {
        mq_d3d_last_error = MQ_D3D_METHOD(mq_d3d_device, 65, mq_d3d_set_texture_fn)(mq_d3d_device, 0u, object);
        if (MQ_D3D_SUCCEEDED(mq_d3d_last_error)) mq_d3d_applied_texture_object = object;
    }
    if (texture != MQ_NULL) {
        if (texture->anisotropy > 1) {
            mq_d3d_set_sampler_state(MQ_D3DSAMP_MINFILTER, MQ_D3DTEXF_ANISOTROPIC);
            mq_d3d_set_sampler_state(MQ_D3DSAMP_MAGFILTER, MQ_D3DTEXF_ANISOTROPIC);
        } else {
            mq_d3d_set_sampler_state(MQ_D3DSAMP_MINFILTER, mq_d3d_min_filter_value(texture->min_filter));
            mq_d3d_set_sampler_state(MQ_D3DSAMP_MAGFILTER, texture->mag_filter == MQ_GL_LINEAR ? MQ_D3DTEXF_LINEAR : MQ_D3DTEXF_POINT);
        }
        mq_d3d_set_sampler_state(MQ_D3DSAMP_MIPFILTER, mq_d3d_mip_filter_value(texture->min_filter));
        mq_d3d_set_sampler_state(MQ_D3DSAMP_MAXANISOTROPY, texture->anisotropy > 1 ? (mq_u32)texture->anisotropy : 1u);
        mq_d3d_set_sampler_state(MQ_D3DSAMP_ADDRESSU, texture->wrap_s == MQ_GL_CLAMP ? MQ_D3DTADDRESS_CLAMP : MQ_D3DTADDRESS_WRAP);
        mq_d3d_set_sampler_state(MQ_D3DSAMP_ADDRESSV, texture->wrap_t == MQ_GL_CLAMP ? MQ_D3DTADDRESS_CLAMP : MQ_D3DTADDRESS_WRAP);
    }
}

/* Translate a GL blend token to the backend-specific value. */
static mq_u32 mq_d3d_blend_value(mq_u32 value) {
    if (value == MQ_GL_ZERO) return MQ_D3DBLEND_ZERO;
    if (value == MQ_GL_ONE) return MQ_D3DBLEND_ONE;
    if (value == MQ_GL_SRC_COLOR) return MQ_D3DBLEND_SRCCOLOR;
    if (value == MQ_GL_ONE_MINUS_SRC_COLOR) return MQ_D3DBLEND_INVSRCCOLOR;
    if (value == MQ_GL_SRC_ALPHA) return MQ_D3DBLEND_SRCALPHA;
    if (value == MQ_GL_ONE_MINUS_SRC_ALPHA) return MQ_D3DBLEND_INVSRCALPHA;
    if (value == MQ_GL_DST_COLOR) return MQ_D3DBLEND_DESTCOLOR;
    if (value == MQ_GL_ONE_MINUS_DST_COLOR) return MQ_D3DBLEND_INVDESTCOLOR;
    return MQ_D3DBLEND_ONE;
}

/* Translate a GL comparison token to its Vulkan equivalent. */
static mq_u32 mq_d3d_compare_value(mq_u32 value) {
    if (value == MQ_GL_LEQUAL) return MQ_D3DCMP_LESSEQUAL;
    if (value == MQ_GL_GEQUAL) return MQ_D3DCMP_GREATEREQUAL;
    if (value == MQ_GL_GREATER) return MQ_D3DCMP_GREATER;
    return MQ_D3DCMP_LESS;
}

/* Release the optional Direct3D shader pair before reset/shutdown. */
static void mq_d3d_release_enhanced_shaders(void) {
    mq_d3d_release(&mq_d3d_enhanced_vertex_shader);
    mq_d3d_release(&mq_d3d_enhanced_pixel_shader);
    mq_d3d_enhanced_draw_kind_value = 0;
}

/* Compile and create the shared per-pixel additive light program. */
static mq_i32 mq_d3d_create_enhanced_shaders(void) {
    static const char vertex_source[] =
        /* The bridge uploads transposed OpenGL matrices for Direct3D's
         * row-vector convention.  Declare that layout explicitly; HLSL's
         * column-major default otherwise transposes the enhanced overlay a
         * second time and stretches muzzle-lit world triangles on screen. */
        "row_major float4x4 mq_mvp:register(c0);row_major float4x4 mq_mv:register(c4);"
        "struct I{float3 p:POSITION0;float4 c:COLOR0;float2 uv:TEXCOORD0;};"
        "struct O{float4 p:POSITION0;float2 uv:TEXCOORD0;float3 e:TEXCOORD1;};"
        "O main(I i){O o;float4 p=float4(i.p,1);o.p=mul(p,mq_mvp);"
        "o.e=mul(p,mq_mv).xyz;o.uv=i.uv;return o;}";
    static const char pixel_source[] =
        "sampler2D mq_base:register(s0);float4 mq_lights[4]:register(c0);"
        "float4 mq_params:register(c4);"
        "float one(float4 q,float3 e,float3 n){float3 d=q.xyz-e;float z=length(d);"
        "if(z>=q.w||q.w<=0)return 0;float a=1-z/q.w;a*=a;"
        "return a*max(dot(n,d/max(z,0.001)),0);}"
        "float4 main(float2 uv:TEXCOORD0,float3 e:TEXCOORD1):COLOR0{"
        "float3 n=normalize(cross(ddx(e),ddy(e)));if(dot(n,-e)<0)n=-n;float l=0;"
        "if(mq_params.x>0)l+=one(mq_lights[0],e,n);"
        "if(mq_params.x>1)l+=one(mq_lights[1],e,n);"
        "if(mq_params.x>2)l+=one(mq_lights[2],e,n);"
        "if(mq_params.x>3)l+=one(mq_lights[3],e,n);"
        "float4 b=tex2D(mq_base,uv);return float4(b.rgb*float3(1,0.58,0.30)*min(l,1.5),b.a);}";
    MQ_HMODULE compiler_module;
    mq_d3d_compile_fn compile;
    void *vertex_blob = MQ_NULL;
    void *pixel_blob = MQ_NULL;
    void *messages = MQ_NULL;
    const mq_u32 *vertex_code;
    const mq_u32 *pixel_code;
    MQ_HRESULT result;
    if (mq_d3d_enhanced_vertex_shader != MQ_NULL && mq_d3d_enhanced_pixel_shader != MQ_NULL) return 1;
    if (mq_d3d_device == MQ_NULL) return 0;
    compiler_module = LoadLibraryA("d3dcompiler_47.dll");
    if (compiler_module == MQ_NULL) compiler_module = LoadLibraryA("d3dcompiler_43.dll");
    if (compiler_module == MQ_NULL) return 0;
    compile = (mq_d3d_compile_fn)GetProcAddress(compiler_module, "D3DCompile");
    if (compile == (mq_d3d_compile_fn)0) { FreeLibrary(compiler_module); return 0; }
    result = compile(vertex_source, sizeof(vertex_source) - 1u, "MiniQuake enhanced vertex", MQ_NULL, MQ_NULL,
        "main", "vs_3_0", 0x00008000u /* D3DCOMPILE_OPTIMIZATION_LEVEL3 */, 0u, &vertex_blob, &messages);
    if (messages != MQ_NULL) mq_d3d_release(&messages);
    if (!MQ_D3D_SUCCEEDED(result) || vertex_blob == MQ_NULL) { FreeLibrary(compiler_module); return 0; }
    result = compile(pixel_source, sizeof(pixel_source) - 1u, "MiniQuake enhanced pixel", MQ_NULL, MQ_NULL,
        "main", "ps_3_0", 0x00008000u /* D3DCOMPILE_OPTIMIZATION_LEVEL3 */, 0u, &pixel_blob, &messages);
    if (messages != MQ_NULL) mq_d3d_release(&messages);
    if (!MQ_D3D_SUCCEEDED(result) || pixel_blob == MQ_NULL) {
        mq_d3d_release(&vertex_blob); FreeLibrary(compiler_module); return 0;
    }
    vertex_code = (const mq_u32 *)MQ_D3D_METHOD(vertex_blob, 3, mq_d3d_blob_pointer_fn)(vertex_blob);
    pixel_code = (const mq_u32 *)MQ_D3D_METHOD(pixel_blob, 3, mq_d3d_blob_pointer_fn)(pixel_blob);
    result = MQ_D3D_METHOD(mq_d3d_device, 91, mq_d3d_create_vertex_shader_fn)(
        mq_d3d_device, vertex_code, &mq_d3d_enhanced_vertex_shader);
    if (MQ_D3D_SUCCEEDED(result)) {
        result = MQ_D3D_METHOD(mq_d3d_device, 106, mq_d3d_create_pixel_shader_fn)(
            mq_d3d_device, pixel_code, &mq_d3d_enhanced_pixel_shader);
    }
    mq_d3d_release(&vertex_blob);
    mq_d3d_release(&pixel_blob);
    FreeLibrary(compiler_module);
    if (!MQ_D3D_SUCCEEDED(result) || mq_d3d_enhanced_vertex_shader == MQ_NULL ||
        mq_d3d_enhanced_pixel_shader == MQ_NULL) {
        mq_d3d_release_enhanced_shaders();
        return 0;
    }
    return 1;
}

/* Bind shader constants for one enhanced draw using the current model matrix. */
static mq_i32 mq_d3d_apply_enhanced_program(void) {
    float depth_conversion[16];
    float converted_projection[16];
    float combined[16];
    mq_d3d_matrix_t mvp;
    mq_d3d_matrix_t modelview;
    float parameters[4] = {0.0f, 0.0f, 0.0f, 0.0f};
    if (!mq_d3d_enhanced_enabled || mq_d3d_enhanced_draw_kind_value == 0 ||
        !mq_d3d_create_enhanced_shaders()) return 0;
    mq_d3d_identity(depth_conversion);
    depth_conversion[10] = mq_d3d_depth_min > mq_d3d_depth_max ? -0.5f : 0.5f;
    depth_conversion[14] = 0.5f;
    mq_d3d_multiply(converted_projection, depth_conversion, mq_d3d_projection_stack[mq_d3d_projection_top]);
    mq_d3d_multiply(combined, converted_projection, mq_d3d_modelview_stack[mq_d3d_modelview_top]);
    mq_d3d_transpose(&mvp, combined);
    mq_d3d_transpose(&modelview, mq_d3d_modelview_stack[mq_d3d_modelview_top]);
    parameters[0] = (float)mq_d3d_enhanced_light_count;
    MQ_D3D_METHOD(mq_d3d_device, 92, mq_d3d_set_vertex_shader_fn)(
        mq_d3d_device, mq_d3d_enhanced_vertex_shader);
    MQ_D3D_METHOD(mq_d3d_device, 107, mq_d3d_set_pixel_shader_fn)(
        mq_d3d_device, mq_d3d_enhanced_pixel_shader);
    MQ_D3D_METHOD(mq_d3d_device, 94, mq_d3d_set_vertex_shader_constant_f_fn)(
        mq_d3d_device, 0u, &mvp.m[0][0], 4u);
    MQ_D3D_METHOD(mq_d3d_device, 94, mq_d3d_set_vertex_shader_constant_f_fn)(
        mq_d3d_device, 4u, &modelview.m[0][0], 4u);
    MQ_D3D_METHOD(mq_d3d_device, 109, mq_d3d_set_pixel_shader_constant_f_fn)(
        mq_d3d_device, 0u, mq_d3d_enhanced_lights, 4u);
    MQ_D3D_METHOD(mq_d3d_device, 109, mq_d3d_set_pixel_shader_constant_f_fn)(
        mq_d3d_device, 4u, parameters, 1u);
    return 1;
}

/* Restore fixed-function shaders after an enhanced DrawPrimitiveUP call. */
static void mq_d3d_clear_enhanced_program(void) {
    if (mq_d3d_device == MQ_NULL) return;
    MQ_D3D_METHOD(mq_d3d_device, 92, mq_d3d_set_vertex_shader_fn)(mq_d3d_device, MQ_NULL);
    MQ_D3D_METHOD(mq_d3d_device, 107, mq_d3d_set_pixel_shader_fn)(mq_d3d_device, MQ_NULL);
}

/* Restore the renderer's GLQuake-compatible default state. */
static void mq_d3d_default_state(void) {
    if (mq_d3d_device == MQ_NULL) return;
    mq_d3d_set_render_state(MQ_D3DRS_LIGHTING, 0u);
    mq_d3d_set_render_state(MQ_D3DRS_COLORVERTEX, 1u);
    mq_d3d_set_render_state(MQ_D3DRS_CLIPPING, 1u);
    mq_d3d_set_render_state(MQ_D3DRS_ZENABLE, 1u);
    mq_d3d_set_render_state(MQ_D3DRS_ZWRITEENABLE, 1u);
    mq_d3d_set_render_state(MQ_D3DRS_ZFUNC, MQ_D3DCMP_LESSEQUAL);
    mq_d3d_set_render_state(MQ_D3DRS_FILLMODE, MQ_D3DFILL_SOLID);
    mq_d3d_set_render_state(MQ_D3DRS_SHADEMODE, MQ_D3DSHADE_FLAT);
    mq_d3d_set_render_state(MQ_D3DRS_CULLMODE, MQ_D3DCULL_NONE);
    mq_d3d_set_render_state(MQ_D3DRS_ALPHATESTENABLE, 1u);
    mq_d3d_set_render_state(MQ_D3DRS_ALPHAFUNC, MQ_D3DCMP_GREATER);
    mq_d3d_set_render_state(MQ_D3DRS_ALPHAREF, 170u);
    mq_d3d_set_render_state(MQ_D3DRS_ALPHABLENDENABLE, 0u);
    mq_d3d_set_render_state(MQ_D3DRS_SRCBLEND, MQ_D3DBLEND_SRCALPHA);
    mq_d3d_set_render_state(MQ_D3DRS_DESTBLEND, MQ_D3DBLEND_INVSRCALPHA);
    MQ_D3D_METHOD(mq_d3d_device, 89, mq_d3d_set_fvf_fn)(
        mq_d3d_device, MQ_D3DFVF_XYZ | MQ_D3DFVF_DIFFUSE | MQ_D3DFVF_TEX1);
    mq_d3d_apply_texture_environment();
    mq_d3d_apply_bound_texture();
    mq_d3d_apply_viewport();
    mq_d3d_matrices_dirty = 1;
    mq_d3d_apply_matrices();
}

/* Release the requested native resources. */
static void mq_d3d_release(void **object) {
    if (object != MQ_NULL && *object != MQ_NULL) {
        MQ_D3D_METHOD(*object, 2, mq_d3d_release_fn)(*object);
        *object = MQ_NULL;
    }
}

/* Release textures. */
static void mq_d3d_release_textures(void) {
    mq_u32 index;
    for (index = 0u; index < MQ_D3D_MAX_TEXTURES; ++index) {
        if (mq_d3d_textures[index].object != MQ_NULL) mq_d3d_release(&mq_d3d_textures[index].object);
    }
    memset(mq_d3d_textures, 0, sizeof(mq_d3d_textures));
}

/* Report whether 9 available is available. */
mq_i32 mq_d3d9_available(void) {
    void *probe = Direct3DCreate9(MQ_D3D_SDK_VERSION);
    if (probe == MQ_NULL) return 0;
    MQ_D3D_METHOD(probe, 2, mq_d3d_release_fn)(probe);
    return 1;
}

/* Create and initialize 9 initialize. */
mq_i32 mq_d3d9_initialize(mq_ptr window, mq_i32 width, mq_i32 height) {
    mq_d3d_create_device_fn create_device;
    mq_d3d_check_device_type_fn check_device_type;
    mq_d3d_get_display_mode_fn get_display_mode;
    mq_d3d_display_mode_t display_mode;
    MQ_HRESULT result;
    mq_u32 behavior;
    if (window == MQ_NULL || width < 1 || height < 1) return 0;
    mq_d3d9_shutdown();
    /*
     * Keep texture resources in D3DPOOL_MANAGED so the Direct3D runtime
     * restores them after Reset, Alt-Tab and display-mode changes.  D3D9Ex
     * rejects the managed pool and previously forced every Quake texture into
     * D3DPOOL_DEFAULT; a reset could then leave valid texture identifiers
     * pointing at discarded contents, producing white UI rectangles and
     * flat-colored world triangles until the whole renderer was restarted.
     */
    mq_d3d_object = Direct3DCreate9(MQ_D3D_SDK_VERSION);
    if (mq_d3d_object == MQ_NULL) return 0;
    memset(&mq_d3d_present, 0, sizeof(mq_d3d_present));
    mq_d3d_present.BackBufferWidth = (mq_u32)width;
    mq_d3d_present.BackBufferHeight = (mq_u32)height;
    memset(&display_mode, 0, sizeof(display_mode));
    get_display_mode = MQ_D3D_METHOD(mq_d3d_object, 8, mq_d3d_get_display_mode_fn);
    result = get_display_mode(mq_d3d_object, 0u, &display_mode);
    if (!MQ_D3D_SUCCEEDED(result)) {
        mq_d3d_last_error = result;
        mq_d3d9_shutdown();
        return 0;
    }
    mq_d3d_present.BackBufferFormat = display_mode.Format;
    mq_d3d_present.BackBufferCount = 1u;
    mq_d3d_present.MultiSampleType = MQ_D3DMULTISAMPLE_NONE;
    mq_d3d_present.SwapEffect = MQ_D3DSWAPEFFECT_DISCARD;
    mq_d3d_present.hDeviceWindow = window;
    mq_d3d_present.Windowed = 1;
    mq_d3d_present.EnableAutoDepthStencil = 1;
    mq_d3d_present.AutoDepthStencilFormat = MQ_D3DFMT_D24S8;
    mq_d3d_present.PresentationInterval = MQ_D3DPRESENT_INTERVAL_IMMEDIATE;
    check_device_type = MQ_D3D_METHOD(mq_d3d_object, 9, mq_d3d_check_device_type_fn);
    result = check_device_type(mq_d3d_object, 0u, MQ_D3DDEVTYPE_HAL, display_mode.Format, display_mode.Format, 1);
    if (!MQ_D3D_SUCCEEDED(result)) {
        mq_d3d_last_error = result;
        mq_d3d9_shutdown();
        return 0;
    }
    create_device = MQ_D3D_METHOD(mq_d3d_object, 16, mq_d3d_create_device_fn);
    behavior = MQ_D3DCREATE_FPU_PRESERVE | MQ_D3DCREATE_HARDWARE_VERTEXPROCESSING;
    result = create_device(mq_d3d_object, 0u, MQ_D3DDEVTYPE_HAL, window, behavior, &mq_d3d_present, &mq_d3d_device);
    if (!MQ_D3D_SUCCEEDED(result)) {
        behavior = MQ_D3DCREATE_FPU_PRESERVE | MQ_D3DCREATE_SOFTWARE_VERTEXPROCESSING;
        result = create_device(mq_d3d_object, 0u, MQ_D3DDEVTYPE_HAL, window, behavior, &mq_d3d_present, &mq_d3d_device);
    }
    if (!MQ_D3D_SUCCEEDED(result)) {
        mq_d3d_present.AutoDepthStencilFormat = MQ_D3DFMT_D16;
        result = create_device(mq_d3d_object, 0u, MQ_D3DDEVTYPE_HAL, window, behavior, &mq_d3d_present, &mq_d3d_device);
    }
    if (!MQ_D3D_SUCCEEDED(result) || mq_d3d_device == MQ_NULL) {
        mq_d3d_last_error = result;
        mq_d3d9_shutdown();
        return 0;
    }
    mq_d3d_window = window;
    mq_d3d_width = width;
    mq_d3d_height = height;
    mq_d3d_viewport_x = 0;
    mq_d3d_viewport_y = 0;
    mq_d3d_viewport_width = width;
    mq_d3d_viewport_height = height;
    mq_d3d_depth_min = 0.0f;
    mq_d3d_depth_max = 1.0f;
    mq_d3d_current_color = 0xffffffffu;
    mq_d3d_bound_texture = 0u;
    mq_d3d_next_texture = 1u;
    mq_d3d_texture_enabled = 1;
    mq_d3d_texture_environment = MQ_GL_REPLACE;
    mq_d3d_cull_enabled = 0;
    mq_d3d_cull_mode = MQ_D3DCULL_CCW;
    mq_d3d_matrix_mode_value = MQ_GL_MODELVIEW;
    mq_d3d_modelview_top = 0u;
    mq_d3d_projection_top = 0u;
    mq_d3d_identity(mq_d3d_modelview_stack[0]);
    mq_d3d_identity(mq_d3d_projection_stack[0]);
    mq_d3d_invalidate_state_cache();
    mq_d3d_default_state();
    mq_d3d_create_enhanced_shaders();
    mq_d3d_last_error = 0;
    return 1;
}

/* Release resources owned by 9 shutdown. */
void mq_d3d9_shutdown(void) {
    mq_d3d_release_enhanced_shaders();
    mq_d3d_release_textures();
    mq_d3d_release(&mq_d3d_device);
    mq_d3d_release(&mq_d3d_object);
    mq_d3d_window = MQ_NULL;
    mq_d3d_width = 0;
    mq_d3d_height = 0;
    mq_d3d_vertex_count = 0u;
    mq_d3d_invalidate_state_cache();
}

/* Report whether 9 ready is available. */
mq_i32 mq_d3d9_ready(void) {
    return mq_d3d_device != MQ_NULL;
}

/* Resize or recreate backend presentation resources. */
mq_i32 mq_d3d9_resize(mq_i32 width, mq_i32 height) {
    MQ_HRESULT result;
    if (mq_d3d_device == MQ_NULL || width < 1 || height < 1) return 0;
    mq_d3d_release_enhanced_shaders();
    mq_d3d_present.BackBufferWidth = (mq_u32)width;
    mq_d3d_present.BackBufferHeight = (mq_u32)height;
    result = MQ_D3D_METHOD(mq_d3d_device, 16, mq_d3d_reset_fn)(mq_d3d_device, &mq_d3d_present);
    mq_d3d_last_error = result;
    if (!MQ_D3D_SUCCEEDED(result)) return 0;
    mq_d3d_width = width;
    mq_d3d_height = height;
    if (mq_d3d_viewport_width > width) mq_d3d_viewport_width = width;
    if (mq_d3d_viewport_height > height) mq_d3d_viewport_height = height;
    mq_d3d_invalidate_state_cache();
    mq_d3d_default_state();
    mq_d3d_create_enhanced_shaders();
    return 1;
}

/* Present the completed back buffer to the window. */
void mq_d3d9_present(void) {
    MQ_HRESULT result;
    if (mq_d3d_device == MQ_NULL) return;
    result = MQ_D3D_METHOD(mq_d3d_device, 17, mq_d3d_present_fn)(mq_d3d_device, MQ_NULL, MQ_NULL, MQ_NULL, MQ_NULL);
    if (!MQ_D3D_SUCCEEDED(result)) {
        MQ_HRESULT cooperative = MQ_D3D_METHOD(mq_d3d_device, 3, mq_d3d_test_cooperative_fn)(mq_d3d_device);
        if (cooperative == (MQ_HRESULT)0x88760869u) mq_d3d9_resize(mq_d3d_width, mq_d3d_height);
    }
    mq_d3d_last_error = result;
}

/* Begin collecting immediate-mode vertices for one draw. */
void mq_d3d9_begin(mq_u32 mode) {
    mq_d3d_primitive_mode = mode;
    mq_d3d_vertex_count = 0u;
}

/* Submit draw vertices geometry to the active backend command buffer. */
static void mq_d3d_draw_vertices(mq_i32 primitive_type, mq_u32 primitive_count, const mq_d3d_vertex_t *vertices) {
    MQ_HRESULT result;
    mq_i32 enhanced_program;
    if (mq_d3d_device == MQ_NULL || primitive_count == 0u) return;
    mq_d3d_apply_matrices();
    enhanced_program = mq_d3d_apply_enhanced_program();
    result = MQ_D3D_METHOD(mq_d3d_device, 41, mq_d3d_begin_scene_fn)(mq_d3d_device);
    if (!MQ_D3D_SUCCEEDED(result)) {
        if (enhanced_program) mq_d3d_clear_enhanced_program();
        mq_d3d_last_error = result;
        return;
    }
    result = MQ_D3D_METHOD(mq_d3d_device, 83, mq_d3d_draw_primitive_up_fn)(
        mq_d3d_device, primitive_type, primitive_count, vertices, (mq_u32)sizeof(mq_d3d_vertex_t));
    MQ_D3D_METHOD(mq_d3d_device, 42, mq_d3d_end_scene_fn)(mq_d3d_device);
    if (enhanced_program) mq_d3d_clear_enhanced_program();
    mq_d3d_last_error = result;
}

/* Submit draw interleaved t2f v3f geometry to the active backend command buffer. */
mq_i32 mq_d3d9_draw_interleaved_t2f_v3f(const float *vertices, mq_u32 vertex_count) {
    mq_u32 first = 0u;
    if (vertices == MQ_NULL || vertex_count < 3u) return 0;
    vertex_count -= vertex_count % 3u;
    while (first < vertex_count) {
        mq_u32 count = vertex_count - first;
        mq_u32 index;
        if (count > MQ_D3D_MAX_VERTICES) count = MQ_D3D_MAX_VERTICES - (MQ_D3D_MAX_VERTICES % 3u);
        for (index = 0u; index < count; ++index) {
            const float *source = &vertices[(first + index) * 5u];
            mq_d3d_vertex_t *destination = &mq_d3d_vertices[index];
            destination->x = source[2];
            destination->y = source[3];
            destination->z = source[4];
            destination->color = mq_d3d_current_color;
            destination->s = source[0];
            destination->t = source[1];
        }
        mq_d3d_draw_vertices(MQ_D3DPT_TRIANGLELIST, count / 3u, mq_d3d_vertices);
        first += count;
    }
    return (mq_i32)(vertex_count / 3u);
}

/* Store the Direct3D 9 ABI fields for one D3D alias input. */
typedef struct mq_d3d_alias_input_s {
    float s;
    float t;
    mq_u8 r;
    mq_u8 g;
    mq_u8 b;
    mq_u8 a;
    float x;
    float y;
    float z;
} mq_d3d_alias_input_t;

/* Submit draw interleaved t2f c4ub v3f geometry to the active backend command buffer. */
mq_i32 mq_d3d9_draw_interleaved_t2f_c4ub_v3f(const void *vertices, mq_u32 vertex_count) {
    const mq_d3d_alias_input_t *source_vertices = (const mq_d3d_alias_input_t *)vertices;
    mq_u32 first = 0u;
    if (vertices == MQ_NULL || vertex_count < 3u) return 0;
    vertex_count -= vertex_count % 3u;
    while (first < vertex_count) {
        mq_u32 count = vertex_count - first;
        mq_u32 index;
        if (count > MQ_D3D_MAX_VERTICES) count = MQ_D3D_MAX_VERTICES - (MQ_D3D_MAX_VERTICES % 3u);
        for (index = 0u; index < count; ++index) {
            const mq_d3d_alias_input_t *source = &source_vertices[first + index];
            mq_d3d_vertex_t *destination = &mq_d3d_vertices[index];
            destination->x = source->x;
            destination->y = source->y;
            destination->z = source->z;
            destination->color = ((mq_u32)source->a << 24) | ((mq_u32)source->r << 16) | ((mq_u32)source->g << 8) | source->b;
            destination->s = source->s;
            destination->t = source->t;
        }
        mq_d3d_draw_vertices(MQ_D3DPT_TRIANGLELIST, count / 3u, mq_d3d_vertices);
        first += count;
    }
    return (mq_i32)(vertex_count / 3u);
}

/* Submit the immediate-mode vertices collected for the draw. */
void mq_d3d9_end(void) {
    mq_u32 primitives = 0u;
    mq_u32 index;
    if (mq_d3d_vertex_count == 0u) return;
    if (mq_d3d_primitive_mode == MQ_GL_POINTS) {
        mq_d3d_draw_vertices(MQ_D3DPT_POINTLIST, mq_d3d_vertex_count, mq_d3d_vertices);
    } else if (mq_d3d_primitive_mode == MQ_GL_LINES) {
        mq_d3d_draw_vertices(MQ_D3DPT_LINELIST, mq_d3d_vertex_count / 2u, mq_d3d_vertices);
    } else if (mq_d3d_primitive_mode == MQ_GL_LINE_STRIP) {
        if (mq_d3d_vertex_count >= 2u) mq_d3d_draw_vertices(MQ_D3DPT_LINESTRIP, mq_d3d_vertex_count - 1u, mq_d3d_vertices);
    } else if (mq_d3d_primitive_mode == MQ_GL_LINE_LOOP) {
        if (mq_d3d_vertex_count >= 2u && mq_d3d_vertex_count < MQ_D3D_MAX_VERTICES) {
            memcpy(mq_d3d_expanded_vertices, mq_d3d_vertices, mq_d3d_vertex_count * sizeof(mq_d3d_vertex_t));
            mq_d3d_expanded_vertices[mq_d3d_vertex_count] = mq_d3d_vertices[0];
            mq_d3d_draw_vertices(MQ_D3DPT_LINESTRIP, mq_d3d_vertex_count, mq_d3d_expanded_vertices);
        }
    } else if (mq_d3d_primitive_mode == MQ_GL_TRIANGLES) {
        mq_d3d_draw_vertices(MQ_D3DPT_TRIANGLELIST, mq_d3d_vertex_count / 3u, mq_d3d_vertices);
    } else if (mq_d3d_primitive_mode == MQ_GL_TRIANGLE_STRIP) {
        if (mq_d3d_vertex_count >= 3u) mq_d3d_draw_vertices(MQ_D3DPT_TRIANGLESTRIP, mq_d3d_vertex_count - 2u, mq_d3d_vertices);
    } else if (mq_d3d_primitive_mode == MQ_GL_TRIANGLE_FAN || mq_d3d_primitive_mode == MQ_GL_POLYGON) {
        if (mq_d3d_vertex_count >= 3u) mq_d3d_draw_vertices(MQ_D3DPT_TRIANGLEFAN, mq_d3d_vertex_count - 2u, mq_d3d_vertices);
    } else if (mq_d3d_primitive_mode == MQ_GL_QUADS) {
        mq_u32 output = 0u;
        for (index = 0u; index + 3u < mq_d3d_vertex_count && output + 5u < (mq_u32)(sizeof(mq_d3d_expanded_vertices) / sizeof(mq_d3d_expanded_vertices[0])); index += 4u) {
            mq_d3d_expanded_vertices[output++] = mq_d3d_vertices[index];
            mq_d3d_expanded_vertices[output++] = mq_d3d_vertices[index + 1u];
            mq_d3d_expanded_vertices[output++] = mq_d3d_vertices[index + 2u];
            mq_d3d_expanded_vertices[output++] = mq_d3d_vertices[index];
            mq_d3d_expanded_vertices[output++] = mq_d3d_vertices[index + 2u];
            mq_d3d_expanded_vertices[output++] = mq_d3d_vertices[index + 3u];
        }
        primitives = output / 3u;
        mq_d3d_draw_vertices(MQ_D3DPT_TRIANGLELIST, primitives, mq_d3d_expanded_vertices);
    }
    mq_d3d_vertex_count = 0u;
}

/* Update the current immediate-mode vertex attributes. */
static void mq_d3d_add_vertex(float x, float y, float z) {
    mq_d3d_vertex_t *vertex;
    if (mq_d3d_vertex_count >= MQ_D3D_MAX_VERTICES) return;
    vertex = &mq_d3d_vertices[mq_d3d_vertex_count++];
    vertex->x = x;
    vertex->y = y;
    vertex->z = z;
    vertex->color = mq_d3d_current_color;
    vertex->s = mq_d3d_current_s;
    vertex->t = mq_d3d_current_t;
}

/* Update the current immediate-mode vertex attributes. */
void mq_d3d9_vertex2(mq_u32 x_bits, mq_u32 y_bits) { mq_d3d_add_vertex(mq_d3d_bits_to_float(x_bits), mq_d3d_bits_to_float(y_bits), 0.0f); }
/* Update the current immediate-mode vertex attributes. */
void mq_d3d9_vertex3(mq_u32 x_bits, mq_u32 y_bits, mq_u32 z_bits) { mq_d3d_add_vertex(mq_d3d_bits_to_float(x_bits), mq_d3d_bits_to_float(y_bits), mq_d3d_bits_to_float(z_bits)); }
/* Update the current immediate-mode texture coordinates. */
void mq_d3d9_texcoord2(mq_u32 s_bits, mq_u32 t_bits) { mq_d3d_current_s = mq_d3d_bits_to_float(s_bits); mq_d3d_current_t = mq_d3d_bits_to_float(t_bits); }
/* Update the current immediate-mode vertex attributes. */
void mq_d3d9_color4ub(mq_u32 red, mq_u32 green, mq_u32 blue, mq_u32 alpha) { mq_d3d_current_color = ((alpha & 255u) << 24) | ((red & 255u) << 16) | ((green & 255u) << 8) | (blue & 255u); }
/* Update the current immediate-mode vertex attributes. */
void mq_d3d9_clear_color(mq_u32 red_bits, mq_u32 green_bits, mq_u32 blue_bits, mq_u32 alpha_bits) { mq_d3d_clear_color_value = mq_d3d_color(mq_d3d_bits_to_float(red_bits), mq_d3d_bits_to_float(green_bits), mq_d3d_bits_to_float(blue_bits), mq_d3d_bits_to_float(alpha_bits)); }

/* Clear the selected buffers or pending native state. */
void mq_d3d9_clear(mq_u32 mask) {
    mq_u32 flags = 0u;
    if (mq_d3d_device == MQ_NULL) return;
    if (mask & MQ_GL_COLOR_BUFFER_BIT) flags |= MQ_D3DCLEAR_TARGET;
    if (mask & MQ_GL_DEPTH_BUFFER_BIT) flags |= MQ_D3DCLEAR_ZBUFFER;
    if (flags != 0u) mq_d3d_last_error = MQ_D3D_METHOD(mq_d3d_device, 43, mq_d3d_clear_fn)(mq_d3d_device, 0u, MQ_NULL, flags, mq_d3d_clear_color_value, 1.0f, 0u);
}

/* Update the enabled state of enable. */
void mq_d3d9_enable(mq_u32 capability) {
    if (capability == MQ_GL_DEPTH_TEST) mq_d3d_set_render_state(MQ_D3DRS_ZENABLE, 1u);
    else if (capability == MQ_GL_BLEND) mq_d3d_set_render_state(MQ_D3DRS_ALPHABLENDENABLE, 1u);
    else if (capability == MQ_GL_ALPHA_TEST) mq_d3d_set_render_state(MQ_D3DRS_ALPHATESTENABLE, 1u);
    else if (capability == MQ_GL_CULL_FACE) { mq_d3d_cull_enabled = 1; mq_d3d_set_render_state(MQ_D3DRS_CULLMODE, (mq_u32)mq_d3d_cull_mode); }
    else if (capability == MQ_GL_TEXTURE_2D) { mq_d3d_texture_enabled = 1; mq_d3d_apply_texture_environment(); }
}

/* Update the enabled state of disable. */
void mq_d3d9_disable(mq_u32 capability) {
    if (capability == MQ_GL_DEPTH_TEST) mq_d3d_set_render_state(MQ_D3DRS_ZENABLE, 0u);
    else if (capability == MQ_GL_BLEND) mq_d3d_set_render_state(MQ_D3DRS_ALPHABLENDENABLE, 0u);
    else if (capability == MQ_GL_ALPHA_TEST) mq_d3d_set_render_state(MQ_D3DRS_ALPHATESTENABLE, 0u);
    else if (capability == MQ_GL_CULL_FACE) { mq_d3d_cull_enabled = 0; mq_d3d_set_render_state(MQ_D3DRS_CULLMODE, MQ_D3DCULL_NONE); }
    else if (capability == MQ_GL_TEXTURE_2D) { mq_d3d_texture_enabled = 0; mq_d3d_apply_texture_environment(); }
}

/* Update the source and destination blend factors. */
void mq_d3d9_blend_func(mq_u32 source, mq_u32 destination) { mq_d3d_set_render_state(MQ_D3DRS_SRCBLEND, mq_d3d_blend_value(source)); mq_d3d_set_render_state(MQ_D3DRS_DESTBLEND, mq_d3d_blend_value(destination)); }
/* Update the depth comparison function. */
void mq_d3d9_depth_func(mq_u32 function_name) { mq_d3d_set_render_state(MQ_D3DRS_ZFUNC, mq_d3d_compare_value(function_name)); }
/* Enable or disable depth-buffer writes. */
void mq_d3d9_depth_mask(mq_i32 enabled) { mq_d3d_set_render_state(MQ_D3DRS_ZWRITEENABLE, enabled != 0); }
/* Clamp and update the viewport depth range. */
void mq_d3d9_depth_range(mq_u32 near_bits, mq_u32 far_bits) { mq_d3d_depth_min = mq_d3d_clamp(mq_d3d_bits_to_float(near_bits), 0.0f, 1.0f); mq_d3d_depth_max = mq_d3d_clamp(mq_d3d_bits_to_float(far_bits), 0.0f, 1.0f); mq_d3d_matrices_dirty = 1; mq_d3d_apply_matrices(); mq_d3d_apply_viewport(); }
/* Update the alpha-test reference value. */
void mq_d3d9_alpha_func(mq_u32 function_name, mq_u32 reference_bits) { mq_d3d_set_render_state(MQ_D3DRS_ALPHAFUNC, mq_d3d_compare_value(function_name)); mq_d3d_set_render_state(MQ_D3DRS_ALPHAREF, (mq_u32)(mq_d3d_clamp(mq_d3d_bits_to_float(reference_bits), 0.0f, 1.0f) * 255.0f)); }
/* Select which polygon face is culled. */
void mq_d3d9_cull_face(mq_u32 mode) { mq_d3d_cull_mode = mode == MQ_GL_FRONT ? MQ_D3DCULL_CCW : MQ_D3DCULL_CW; if (mq_d3d_cull_enabled) mq_d3d_set_render_state(MQ_D3DRS_CULLMODE, (mq_u32)mq_d3d_cull_mode); }
/* Accept the fixed-function shade-model state. */
void mq_d3d9_shade_model(mq_u32 mode) { mq_d3d_set_render_state(MQ_D3DRS_SHADEMODE, mode == MQ_GL_SMOOTH ? MQ_D3DSHADE_GOURAUD : MQ_D3DSHADE_FLAT); }
/* Select the polygon rasterization mode. */
void mq_d3d9_polygon_mode(mq_u32 face, mq_u32 mode) { (void)face; mq_d3d_set_render_state(MQ_D3DRS_FILLMODE, mode == MQ_GL_LINE ? MQ_D3DFILL_WIREFRAME : MQ_D3DFILL_SOLID); }
/* Update the backend viewport rectangle. */
void mq_d3d9_viewport(mq_i32 x, mq_i32 y, mq_i32 width, mq_i32 height) { mq_d3d_viewport_x = x; mq_d3d_viewport_y = y; mq_d3d_viewport_width = width; mq_d3d_viewport_height = height; mq_d3d_apply_viewport(); }
/* Select the active fixed-function matrix stack. */
void mq_d3d9_matrix_mode(mq_u32 mode) { mq_d3d_matrix_mode_value = mode; }
/* Initialize a column-major identity matrix. */
void mq_d3d9_load_identity(void) { mq_d3d_identity(mq_d3d_current_matrix()); mq_d3d_matrices_dirty = 1; }

/* Submit matrix to the native queue. */
void mq_d3d9_push_matrix(void) {
    if (mq_d3d_matrix_mode_value == MQ_GL_PROJECTION) {
        if (mq_d3d_projection_top + 1u < MQ_D3D_MATRIX_STACK) { memcpy(mq_d3d_projection_stack[mq_d3d_projection_top + 1u], mq_d3d_projection_stack[mq_d3d_projection_top], 16u * sizeof(float)); mq_d3d_projection_top += 1u; }
    } else if (mq_d3d_modelview_top + 1u < MQ_D3D_MATRIX_STACK) { memcpy(mq_d3d_modelview_stack[mq_d3d_modelview_top + 1u], mq_d3d_modelview_stack[mq_d3d_modelview_top], 16u * sizeof(float)); mq_d3d_modelview_top += 1u; }
    mq_d3d_matrices_dirty = 1;
}

/* Remove matrix from the native queue. */
void mq_d3d9_pop_matrix(void) {
    if (mq_d3d_matrix_mode_value == MQ_GL_PROJECTION) { if (mq_d3d_projection_top > 0u) mq_d3d_projection_top -= 1u; }
    else if (mq_d3d_modelview_top > 0u) mq_d3d_modelview_top -= 1u;
    mq_d3d_matrices_dirty = 1;
}

/* Postmultiply the current matrix with a translate transform. */
void mq_d3d9_translate(mq_u32 x_bits, mq_u32 y_bits, mq_u32 z_bits) {
    float matrix[16];
    mq_d3d_identity(matrix);
    matrix[12] = mq_d3d_bits_to_float(x_bits);
    matrix[13] = mq_d3d_bits_to_float(y_bits);
    matrix[14] = mq_d3d_bits_to_float(z_bits);
    mq_d3d_postmultiply(matrix);
}

/* Postmultiply the current matrix with a rotate transform. */
void mq_d3d9_rotate(mq_u32 angle_bits, mq_u32 x_bits, mq_u32 y_bits, mq_u32 z_bits) {
    float angle = mq_d3d_bits_to_float(angle_bits) * 0.01745329251994329577f;
    float x = mq_d3d_bits_to_float(x_bits);
    float y = mq_d3d_bits_to_float(y_bits);
    float z = mq_d3d_bits_to_float(z_bits);
    float length = (float)sqrt((double)(x * x + y * y + z * z));
    float c;
    float s;
    float one_minus;
    float matrix[16];
    if (length <= 0.000001f) return;
    x /= length; y /= length; z /= length;
    c = (float)cos((double)angle);
    s = (float)sin((double)angle);
    one_minus = 1.0f - c;
    mq_d3d_identity(matrix);
    matrix[0] = x * x * one_minus + c;
    matrix[4] = x * y * one_minus - z * s;
    matrix[8] = x * z * one_minus + y * s;
    matrix[1] = y * x * one_minus + z * s;
    matrix[5] = y * y * one_minus + c;
    matrix[9] = y * z * one_minus - x * s;
    matrix[2] = z * x * one_minus - y * s;
    matrix[6] = z * y * one_minus + x * s;
    matrix[10] = z * z * one_minus + c;
    mq_d3d_postmultiply(matrix);
}

/* Postmultiply the current matrix with a scale transform. */
void mq_d3d9_scale(mq_u32 x_bits, mq_u32 y_bits, mq_u32 z_bits) {
    float matrix[16];
    mq_d3d_identity(matrix);
    matrix[0] = mq_d3d_bits_to_float(x_bits);
    matrix[5] = mq_d3d_bits_to_float(y_bits);
    matrix[10] = mq_d3d_bits_to_float(z_bits);
    mq_d3d_postmultiply(matrix);
}

/* Postmultiply the current matrix with the requested ortho projection. */
void mq_d3d9_ortho(mq_u32 left_bits, mq_u32 right_bits, mq_u32 bottom_bits, mq_u32 top_bits, mq_u32 near_bits, mq_u32 far_bits) {
    float left = mq_d3d_bits_to_float(left_bits), right = mq_d3d_bits_to_float(right_bits);
    float bottom = mq_d3d_bits_to_float(bottom_bits), top = mq_d3d_bits_to_float(top_bits);
    float near_value = mq_d3d_bits_to_float(near_bits), far_value = mq_d3d_bits_to_float(far_bits);
    float matrix[16];
    mq_d3d_identity(matrix);
    if (right == left || top == bottom || far_value == near_value) return;
    matrix[0] = 2.0f / (right - left);
    matrix[5] = 2.0f / (top - bottom);
    matrix[10] = -2.0f / (far_value - near_value);
    matrix[12] = -(right + left) / (right - left);
    matrix[13] = -(top + bottom) / (top - bottom);
    matrix[14] = -(far_value + near_value) / (far_value - near_value);
    mq_d3d_postmultiply(matrix);
}

/* Postmultiply the current matrix with the requested frustum projection. */
void mq_d3d9_frustum(mq_u32 left_bits, mq_u32 right_bits, mq_u32 bottom_bits, mq_u32 top_bits, mq_u32 near_bits, mq_u32 far_bits) {
    float left = mq_d3d_bits_to_float(left_bits), right = mq_d3d_bits_to_float(right_bits);
    float bottom = mq_d3d_bits_to_float(bottom_bits), top = mq_d3d_bits_to_float(top_bits);
    float near_value = mq_d3d_bits_to_float(near_bits), far_value = mq_d3d_bits_to_float(far_bits);
    float matrix[16];
    mq_u32 index;
    if (right == left || top == bottom || far_value == near_value || near_value == 0.0f) return;
    for (index = 0u; index < 16u; ++index) matrix[index] = 0.0f;
    matrix[0] = (2.0f * near_value) / (right - left);
    matrix[5] = (2.0f * near_value) / (top - bottom);
    matrix[8] = (right + left) / (right - left);
    matrix[9] = (top + bottom) / (top - bottom);
    matrix[10] = -(far_value + near_value) / (far_value - near_value);
    matrix[11] = -1.0f;
    matrix[14] = -(2.0f * far_value * near_value) / (far_value - near_value);
    mq_d3d_postmultiply(matrix);
}

/* Bind the selected texture for subsequent draws. */
void mq_d3d9_bind_texture(mq_u32 target, mq_u32 texture) { (void)target; mq_d3d_bound_texture = texture < MQ_D3D_MAX_TEXTURES ? texture : 0u; mq_d3d_apply_bound_texture(); }

/* Allocate caller-visible texture identifiers. */
void mq_d3d9_gen_textures(mq_i32 count, void *texture_ids) {
    mq_u32 *ids = (mq_u32 *)texture_ids;
    mq_i32 index;
    if (ids == MQ_NULL || count <= 0) return;
    for (index = 0; index < count; ++index) {
        while (mq_d3d_next_texture < MQ_D3D_MAX_TEXTURES && mq_d3d_textures[mq_d3d_next_texture].object != MQ_NULL) mq_d3d_next_texture += 1u;
        ids[index] = mq_d3d_next_texture < MQ_D3D_MAX_TEXTURES ? mq_d3d_next_texture++ : 0u;
    }
}

/* Release resources owned by delete textures. */
void mq_d3d9_delete_textures(mq_i32 count, const void *texture_ids) {
    const mq_u32 *ids = (const mq_u32 *)texture_ids;
    mq_i32 index;
    if (ids == MQ_NULL || count <= 0) return;
    for (index = 0; index < count; ++index) {
        mq_u32 id = ids[index];
        if (id > 0u && id < MQ_D3D_MAX_TEXTURES) {
            if (mq_d3d_textures[id].object != MQ_NULL) mq_d3d_release(&mq_d3d_textures[id].object);
            memset(&mq_d3d_textures[id], 0, sizeof(mq_d3d_textures[id]));
            if (mq_d3d_bound_texture == id) { mq_d3d_bound_texture = 0u; mq_d3d_apply_bound_texture(); }
            if (id > 0u && id < mq_d3d_next_texture) mq_d3d_next_texture = id;
        }
    }
}

/* Update fixed-function texture sampling state. */
void mq_d3d9_tex_parameter_i(mq_u32 target, mq_u32 name, mq_i32 value) {
    mq_d3d_texture_t *texture;
    (void)target;
    if (mq_d3d_bound_texture >= MQ_D3D_MAX_TEXTURES) return;
    texture = &mq_d3d_textures[mq_d3d_bound_texture];
    if (name == MQ_GL_TEXTURE_MIN_FILTER) texture->min_filter = value;
    else if (name == MQ_GL_TEXTURE_MAG_FILTER) texture->mag_filter = value;
    else if (name == MQ_GL_TEXTURE_WRAP_S) texture->wrap_s = value;
    else if (name == MQ_GL_TEXTURE_WRAP_T) texture->wrap_t = value;
    else if (name == MQ_GL_TEXTURE_MAX_ANISOTROPY_EXT) { if (value < 1) value = 1; if (value > 16) value = 16; texture->anisotropy = value; }
    mq_d3d_apply_bound_texture();
}

/* Update fixed-function texture sampling state. */
void mq_d3d9_tex_env_i(mq_u32 target, mq_u32 name, mq_i32 value) {
    (void)target;
    if (name == MQ_GL_TEXTURE_ENV_MODE) { mq_d3d_texture_environment = value; mq_d3d_apply_texture_environment(); }
}

/* Convert or transfer text across the MiniLang native boundary. */
static mq_i32 mq_d3d_texture_create(mq_d3d_texture_t *texture, mq_i32 base_width, mq_i32 base_height) {
    MQ_HRESULT result;
    void *object = MQ_NULL;
    if (texture == MQ_NULL || mq_d3d_device == MQ_NULL || base_width < 1 || base_height < 1) return 0;
    if (texture->object != MQ_NULL && texture->width == base_width && texture->height == base_height) return 1;
    if (texture->object != MQ_NULL) mq_d3d_release(&texture->object);
    result = MQ_D3D_METHOD(mq_d3d_device, 23, mq_d3d_create_texture_fn)(
        mq_d3d_device, (mq_u32)base_width, (mq_u32)base_height, 0u,
        0u, MQ_D3DFMT_A8R8G8B8, MQ_D3DPOOL_MANAGED,
        &object, (MQ_HANDLE *)MQ_NULL);
    mq_d3d_last_error = result;
    if (!MQ_D3D_SUCCEEDED(result) || object == MQ_NULL) return 0;
    texture->object = object;
    texture->width = base_width;
    texture->height = base_height;
    if (texture->min_filter == 0) texture->min_filter = MQ_GL_NEAREST;
    if (texture->mag_filter == 0) texture->mag_filter = MQ_GL_NEAREST;
    if (texture->wrap_s == 0) texture->wrap_s = MQ_GL_REPEAT;
    if (texture->wrap_t == 0) texture->wrap_t = MQ_GL_REPEAT;
    if (texture->anisotropy == 0) texture->anisotropy = 1;
    return 1;
}

/* Copy pixel into caller-owned storage. */
static void mq_d3d_copy_pixel(mq_u8 *destination, const mq_u8 *source, mq_u32 format) {
    if (format == MQ_GL_RGBA) {
        destination[0] = source[2]; destination[1] = source[1]; destination[2] = source[0]; destination[3] = source[3];
    } else if (format == MQ_GL_RGB) {
        destination[0] = source[2]; destination[1] = source[1]; destination[2] = source[0]; destination[3] = 255u;
    } else {
        destination[0] = source[0]; destination[1] = source[0]; destination[2] = source[0]; destination[3] = 255u;
    }
}

/* Return the source pixel stride for the selected format. */
static mq_u32 mq_d3d_source_pixel_bytes(mq_u32 format) {
    if (format == MQ_GL_RGBA) return 4u;
    if (format == MQ_GL_RGB) return 3u;
    return 1u;
}

/* Resolve a valid mip level without undefined oversized integer shifts. */
static mq_i32 mq_d3d_texture_level_extent(const mq_d3d_texture_t *texture, mq_i32 level, mq_i32 *width, mq_i32 *height) {
    mq_i32 current_width;
    mq_i32 current_height;
    mq_i32 current_level;
    if (texture == MQ_NULL || texture->object == MQ_NULL || level < 0) return 0;
    current_width = texture->width;
    current_height = texture->height;
    for (current_level = 0; current_level < level; ++current_level) {
        if (current_width == 1 && current_height == 1) return 0;
        if (current_width > 1) current_width /= 2;
        if (current_height > 1) current_height /= 2;
    }
    if (width != MQ_NULL) *width = current_width;
    if (height != MQ_NULL) *height = current_height;
    return 1;
}

/* Allocate and upload a complete texture image. */
void mq_d3d9_tex_image_2d(mq_u32 target, mq_i32 level, mq_i32 internal_format, mq_i32 width, mq_i32 height, mq_i32 border, mq_u32 format, mq_u32 type, const void *pixels) {
    mq_d3d_texture_t *texture;
    mq_d3d_locked_rect_t locked;
    mq_u32 source_bytes;
    mq_i32 x;
    mq_i32 y;
    MQ_HRESULT result;
    (void)target; (void)internal_format; (void)border;
    if (mq_d3d_bound_texture >= MQ_D3D_MAX_TEXTURES || level < 0 || width < 1 || height < 1 || pixels == MQ_NULL || type != MQ_GL_UNSIGNED_BYTE) return;
    texture = &mq_d3d_textures[mq_d3d_bound_texture];
    if (level == 0) {
        if (!mq_d3d_texture_create(texture, width, height)) return;
    } else {
        mq_i32 expected_width;
        mq_i32 expected_height;
        if (!mq_d3d_texture_level_extent(texture, level, &expected_width, &expected_height)) return;
        if (width != expected_width || height != expected_height) return;
    }
    result = MQ_D3D_METHOD(texture->object, 19, mq_d3d_texture_lock_rect_fn)(texture->object, (mq_u32)level, &locked, MQ_NULL, 0u);
    mq_d3d_last_error = result;
    if (!MQ_D3D_SUCCEEDED(result)) return;
    source_bytes = mq_d3d_source_pixel_bytes(format);
    for (y = 0; y < height; ++y) {
        mq_u8 *destination = (mq_u8 *)locked.pBits + y * locked.Pitch;
        const mq_u8 *source = (const mq_u8 *)pixels + (mq_u64)y * (mq_u64)width * source_bytes;
        for (x = 0; x < width; ++x) mq_d3d_copy_pixel(destination + x * 4, source + x * source_bytes, format);
    }
    MQ_D3D_METHOD(texture->object, 20, mq_d3d_texture_unlock_rect_fn)(texture->object, (mq_u32)level);
    mq_d3d_apply_bound_texture();
}

/* Upload a rectangular update into an existing texture image. */
void mq_d3d9_tex_sub_image_2d(mq_u32 target, mq_i32 level, mq_i32 x_offset, mq_i32 y_offset, mq_i32 width, mq_i32 height, mq_u32 format, mq_u32 type, const void *pixels) {
    mq_d3d_texture_t *texture;
    mq_d3d_locked_rect_t locked;
    mq_u32 source_bytes;
    mq_i32 x;
    mq_i32 y;
    mq_i32 level_width;
    mq_i32 level_height;
    MQ_HRESULT result;
    (void)target;
    if (mq_d3d_bound_texture >= MQ_D3D_MAX_TEXTURES || level < 0 || x_offset < 0 || y_offset < 0 || width < 1 || height < 1 || pixels == MQ_NULL || type != MQ_GL_UNSIGNED_BYTE) return;
    texture = &mq_d3d_textures[mq_d3d_bound_texture];
    if (!mq_d3d_texture_level_extent(texture, level, &level_width, &level_height)) return;
    if (width > level_width || height > level_height || x_offset > level_width - width || y_offset > level_height - height) return;
    result = MQ_D3D_METHOD(texture->object, 19, mq_d3d_texture_lock_rect_fn)(texture->object, (mq_u32)level, &locked, MQ_NULL, 0u);
    mq_d3d_last_error = result;
    if (!MQ_D3D_SUCCEEDED(result)) return;
    source_bytes = mq_d3d_source_pixel_bytes(format);
    for (y = 0; y < height; ++y) {
        mq_u8 *destination = (mq_u8 *)locked.pBits + (y + y_offset) * locked.Pitch + x_offset * 4;
        const mq_u8 *source = (const mq_u8 *)pixels + (mq_u64)y * (mq_u64)width * source_bytes;
        for (x = 0; x < width; ++x) mq_d3d_copy_pixel(destination + x * 4, source + x * source_bytes, format);
    }
    MQ_D3D_METHOD(texture->object, 20, mq_d3d_texture_unlock_rect_fn)(texture->object, (mq_u32)level);
}

/* Read pixels into caller-owned storage. */
void mq_d3d9_read_pixels(mq_i32 x, mq_i32 y, mq_i32 width, mq_i32 height, mq_u32 format, mq_u32 type, void *pixels) {
    void *render_target = MQ_NULL;
    void *system_surface = MQ_NULL;
    mq_d3d_surface_desc_t description;
    mq_d3d_locked_rect_t locked;
    mq_i32 row;
    mq_i32 column;
    MQ_HRESULT result;
    if (mq_d3d_device == MQ_NULL || pixels == MQ_NULL || width < 1 || height < 1 || format != MQ_GL_RGBA || type != MQ_GL_UNSIGNED_BYTE) return;
    memset(pixels, 0, (size_t)((mq_u64)(mq_u32)width * (mq_u64)(mq_u32)height * 4u));
    result = MQ_D3D_METHOD(mq_d3d_device, 38, mq_d3d_get_render_target_fn)(mq_d3d_device, 0u, &render_target);
    if (!MQ_D3D_SUCCEEDED(result) || render_target == MQ_NULL) goto done;
    result = MQ_D3D_METHOD(render_target, 12, mq_d3d_surface_get_desc_fn)(render_target, &description);
    if (!MQ_D3D_SUCCEEDED(result)) goto done;
    result = MQ_D3D_METHOD(mq_d3d_device, 36, mq_d3d_create_offscreen_surface_fn)(
        mq_d3d_device, description.Width, description.Height, description.Format,
        MQ_D3DPOOL_SYSTEMMEM, &system_surface, (MQ_HANDLE *)MQ_NULL);
    if (!MQ_D3D_SUCCEEDED(result) || system_surface == MQ_NULL) goto done;
    result = MQ_D3D_METHOD(mq_d3d_device, 32, mq_d3d_get_render_target_data_fn)(mq_d3d_device, render_target, system_surface);
    if (!MQ_D3D_SUCCEEDED(result)) goto done;
    result = MQ_D3D_METHOD(system_surface, 13, mq_d3d_surface_lock_rect_fn)(system_surface, &locked, MQ_NULL, MQ_D3DLOCK_READONLY);
    if (!MQ_D3D_SUCCEEDED(result)) goto done;
    for (row = 0; row < height; ++row) {
        mq_i32 source_y = mq_d3d_height - 1 - (y + row);
        mq_u8 *destination = (mq_u8 *)pixels + (mq_u64)row * (mq_u64)width * 4u;
        if (source_y < 0 || source_y >= (mq_i32)description.Height) continue;
        for (column = 0; column < width; ++column) {
            mq_i32 source_x = x + column;
            if (source_x >= 0 && source_x < (mq_i32)description.Width) {
                const mq_u8 *source = (const mq_u8 *)locked.pBits + source_y * locked.Pitch + source_x * 4;
                destination[column * 4] = source[2];
                destination[column * 4 + 1] = source[1];
                destination[column * 4 + 2] = source[0];
                destination[column * 4 + 3] = 255u;
            }
        }
    }
    MQ_D3D_METHOD(system_surface, 14, mq_d3d_surface_unlock_rect_fn)(system_surface);
done:
    mq_d3d_last_error = result;
    mq_d3d_release(&system_surface);
    mq_d3d_release(&render_target);
}

const char *mq_d3d9_get_string(mq_u32 name) {
    if (name == MQ_GL_VENDOR) return "Microsoft Corporation";
    if (name == MQ_GL_RENDERER) return "MiniQuake Direct3D 9";
    if (name == MQ_GL_VERSION) return "DirectX 9 fixed function";
    if (name == MQ_GL_EXTENSIONS) return "";
    return "";
}

/* Return the current get error value. */
mq_u32 mq_d3d9_get_error(void) { mq_u32 result = (mq_u32)mq_d3d_last_error; mq_d3d_last_error = 0; return result; }
/* Synchronize queued rendering work with the native backend. */
void mq_d3d9_finish(void) { }
/* Synchronize queued rendering work with the native backend. */
void mq_d3d9_flush(void) { }
/* Submit draw buffer geometry to the active backend command buffer. */
void mq_d3d9_draw_buffer(mq_u32 mode) { (void)mode; }

/* Report whether Direct3D can create the enhanced shader pair. */
mq_i32 mq_d3d9_enhanced_available(void) {
    return mq_d3d_device != MQ_NULL && mq_d3d_create_enhanced_shaders();
}

/* Configure Direct3D enhanced rendering; shadow options are shared-policy
 * inputs and are consumed by the shadow stage added above this light pass. */
mq_i32 mq_d3d9_enhanced_configure(mq_i32 enabled, mq_i32 shadows, mq_i32 shadow_quality) {
    (void)shadows;
    (void)shadow_quality;
    mq_d3d_enhanced_enabled = enabled != 0 && mq_d3d9_enhanced_available();
    mq_d3d_enhanced_draw_kind_value = 0;
    if (!mq_d3d_enhanced_enabled) mq_d3d_clear_enhanced_program();
    return enabled == 0 || mq_d3d_enhanced_enabled;
}

/* Transform compact world-space dynamic lights through the captured view. */
mq_i32 mq_d3d9_enhanced_begin_frame(const void *light_data, mq_u32 byte_count) {
    const float *source = (const float *)light_data;
    mq_u32 count;
    mq_u32 index;
    if (!mq_d3d_enhanced_enabled || source == (const float *)0 || (byte_count & 15u) != 0u) return 0;
    count = byte_count >> 4;
    if (count > 4u) count = 4u;
    memcpy(mq_d3d_enhanced_view, mq_d3d_modelview_stack[mq_d3d_modelview_top], sizeof(mq_d3d_enhanced_view));
    for (index = 0u; index < count; ++index) {
        float x = source[index * 4u];
        float y = source[index * 4u + 1u];
        float z = source[index * 4u + 2u];
        mq_d3d_enhanced_lights[index * 4u] = mq_d3d_enhanced_view[0] * x + mq_d3d_enhanced_view[4] * y + mq_d3d_enhanced_view[8] * z + mq_d3d_enhanced_view[12];
        mq_d3d_enhanced_lights[index * 4u + 1u] = mq_d3d_enhanced_view[1] * x + mq_d3d_enhanced_view[5] * y + mq_d3d_enhanced_view[9] * z + mq_d3d_enhanced_view[13];
        mq_d3d_enhanced_lights[index * 4u + 2u] = mq_d3d_enhanced_view[2] * x + mq_d3d_enhanced_view[6] * y + mq_d3d_enhanced_view[10] * z + mq_d3d_enhanced_view[14];
        mq_d3d_enhanced_lights[index * 4u + 3u] = source[index * 4u + 3u];
    }
    mq_d3d_enhanced_light_count = (mq_i32)count;
    return 1;
}

/* Select the optional per-pixel program for following geometry. */
void mq_d3d9_enhanced_draw_kind(mq_i32 kind) {
    mq_d3d_enhanced_draw_kind_value = kind;
    if (kind == 0) mq_d3d_clear_enhanced_program();
}

/* Restore Direct3D fixed-function rendering before the 2-D pass. */
void mq_d3d9_enhanced_end_frame(void) {
    mq_d3d_enhanced_draw_kind_value = 0;
    mq_d3d_clear_enhanced_program();
}
