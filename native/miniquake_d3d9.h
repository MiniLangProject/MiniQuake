/*
 * Copyright (c) 1996-1997 Id Software, Inc.
 * Copyright (c) 2026 Nils Kopal
 * SPDX-License-Identifier: GPL-2.0-or-later
 *
 * Direct3D 9 implementation of MiniQuake's renderer bridge vocabulary.
 */
#ifndef MINIQUAKE_D3D9_H
#define MINIQUAKE_D3D9_H

#include "miniquake_native.h"

mq_i32 mq_d3d9_available(void);
mq_i32 mq_d3d9_initialize(mq_ptr window, mq_i32 width, mq_i32 height);
void mq_d3d9_shutdown(void);
mq_i32 mq_d3d9_ready(void);
mq_i32 mq_d3d9_resize(mq_i32 width, mq_i32 height);
void mq_d3d9_present(void);

void mq_d3d9_begin(mq_u32 mode);
void mq_d3d9_end(void);
mq_i32 mq_d3d9_draw_interleaved_t2f_v3f(const float *vertices, mq_u32 vertex_count);
mq_i32 mq_d3d9_draw_interleaved_t2f_c4ub_v3f(const void *vertices, mq_u32 vertex_count);
void mq_d3d9_vertex2(mq_u32 x_bits, mq_u32 y_bits);
void mq_d3d9_vertex3(mq_u32 x_bits, mq_u32 y_bits, mq_u32 z_bits);
void mq_d3d9_texcoord2(mq_u32 s_bits, mq_u32 t_bits);
void mq_d3d9_color4ub(mq_u32 red, mq_u32 green, mq_u32 blue, mq_u32 alpha);
void mq_d3d9_clear_color(mq_u32 red_bits, mq_u32 green_bits, mq_u32 blue_bits, mq_u32 alpha_bits);
void mq_d3d9_clear(mq_u32 mask);
void mq_d3d9_enable(mq_u32 capability);
void mq_d3d9_disable(mq_u32 capability);
void mq_d3d9_blend_func(mq_u32 source, mq_u32 destination);
void mq_d3d9_depth_func(mq_u32 function_name);
void mq_d3d9_depth_mask(mq_i32 enabled);
void mq_d3d9_depth_range(mq_u32 near_bits, mq_u32 far_bits);
void mq_d3d9_alpha_func(mq_u32 function_name, mq_u32 reference_bits);
void mq_d3d9_cull_face(mq_u32 mode);
void mq_d3d9_shade_model(mq_u32 mode);
void mq_d3d9_polygon_mode(mq_u32 face, mq_u32 mode);
void mq_d3d9_viewport(mq_i32 x, mq_i32 y, mq_i32 width, mq_i32 height);
void mq_d3d9_matrix_mode(mq_u32 mode);
void mq_d3d9_load_identity(void);
void mq_d3d9_push_matrix(void);
void mq_d3d9_pop_matrix(void);
void mq_d3d9_translate(mq_u32 x_bits, mq_u32 y_bits, mq_u32 z_bits);
void mq_d3d9_rotate(mq_u32 angle_bits, mq_u32 x_bits, mq_u32 y_bits, mq_u32 z_bits);
void mq_d3d9_scale(mq_u32 x_bits, mq_u32 y_bits, mq_u32 z_bits);
void mq_d3d9_ortho(mq_u32 left_bits, mq_u32 right_bits, mq_u32 bottom_bits, mq_u32 top_bits, mq_u32 near_bits, mq_u32 far_bits);
void mq_d3d9_frustum(mq_u32 left_bits, mq_u32 right_bits, mq_u32 bottom_bits, mq_u32 top_bits, mq_u32 near_bits, mq_u32 far_bits);
void mq_d3d9_bind_texture(mq_u32 target, mq_u32 texture);
void mq_d3d9_gen_textures(mq_i32 count, void *texture_ids);
void mq_d3d9_delete_textures(mq_i32 count, const void *texture_ids);
void mq_d3d9_tex_parameter_i(mq_u32 target, mq_u32 name, mq_i32 value);
void mq_d3d9_tex_env_i(mq_u32 target, mq_u32 name, mq_i32 value);
void mq_d3d9_tex_image_2d(mq_u32 target, mq_i32 level, mq_i32 internal_format, mq_i32 width, mq_i32 height, mq_i32 border, mq_u32 format, mq_u32 type, const void *pixels);
void mq_d3d9_tex_sub_image_2d(mq_u32 target, mq_i32 level, mq_i32 x_offset, mq_i32 y_offset, mq_i32 width, mq_i32 height, mq_u32 format, mq_u32 type, const void *pixels);
void mq_d3d9_read_pixels(mq_i32 x, mq_i32 y, mq_i32 width, mq_i32 height, mq_u32 format, mq_u32 type, void *pixels);
const char *mq_d3d9_get_string(mq_u32 name);
mq_u32 mq_d3d9_get_error(void);
void mq_d3d9_finish(void);
void mq_d3d9_flush(void);
void mq_d3d9_draw_buffer(mq_u32 mode);
mq_i32 mq_d3d9_enhanced_available(void);
mq_i32 mq_d3d9_enhanced_configure(mq_i32 enabled, mq_i32 shadows, mq_i32 shadow_quality);
mq_i32 mq_d3d9_enhanced_begin_frame(const void *light_data, mq_u32 byte_count);
void mq_d3d9_enhanced_draw_kind(mq_i32 kind);
void mq_d3d9_enhanced_end_frame(void);

#endif
