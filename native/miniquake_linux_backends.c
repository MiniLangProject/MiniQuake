/*
 * Copyright (c) 2026 Nils Kopal
 * SPDX-License-Identifier: Apache-2.0
 *
 * Unavailable Windows renderer backends for the Linux build.  Linux exposes
 * the production OpenGL path; menu selection rejects Direct3D 9 and Vulkan
 * instead of advertising a backend that cannot create a compatible context.
 */
#include "miniquake_d3d9.h"
#include "miniquake_vulkan.h"

#define MQ_STUB_BACKEND(prefix) \
mq_i32 prefix##_available(void) { return 0; } \
mq_i32 prefix##_initialize(mq_ptr window, mq_i32 width, mq_i32 height) { (void)window; (void)width; (void)height; return 0; } \
void prefix##_shutdown(void) {} \
mq_i32 prefix##_ready(void) { return 0; } \
mq_i32 prefix##_resize(mq_i32 width, mq_i32 height) { (void)width; (void)height; return 0; } \
void prefix##_present(void) {} \
void prefix##_begin(mq_u32 mode) { (void)mode; } \
void prefix##_end(void) {} \
mq_i32 prefix##_draw_interleaved_t2f_v3f(const float *v, mq_u32 n) { (void)v; (void)n; return 0; } \
mq_i32 prefix##_draw_interleaved_t2f_c4ub_v3f(const void *v, mq_u32 n) { (void)v; (void)n; return 0; } \
void prefix##_vertex2(mq_u32 a, mq_u32 b) { (void)a; (void)b; } \
void prefix##_vertex3(mq_u32 a, mq_u32 b, mq_u32 c) { (void)a; (void)b; (void)c; } \
void prefix##_texcoord2(mq_u32 a, mq_u32 b) { (void)a; (void)b; } \
void prefix##_color4ub(mq_u32 a, mq_u32 b, mq_u32 c, mq_u32 d) { (void)a; (void)b; (void)c; (void)d; } \
void prefix##_clear_color(mq_u32 a, mq_u32 b, mq_u32 c, mq_u32 d) { (void)a; (void)b; (void)c; (void)d; } \
void prefix##_clear(mq_u32 a) { (void)a; } \
void prefix##_enable(mq_u32 a) { (void)a; } \
void prefix##_disable(mq_u32 a) { (void)a; } \
void prefix##_blend_func(mq_u32 a, mq_u32 b) { (void)a; (void)b; } \
void prefix##_depth_func(mq_u32 a) { (void)a; } \
void prefix##_depth_mask(mq_i32 a) { (void)a; } \
void prefix##_depth_range(mq_u32 a, mq_u32 b) { (void)a; (void)b; } \
void prefix##_alpha_func(mq_u32 a, mq_u32 b) { (void)a; (void)b; } \
void prefix##_cull_face(mq_u32 a) { (void)a; } \
void prefix##_shade_model(mq_u32 a) { (void)a; } \
void prefix##_polygon_mode(mq_u32 a, mq_u32 b) { (void)a; (void)b; } \
void prefix##_viewport(mq_i32 a, mq_i32 b, mq_i32 c, mq_i32 d) { (void)a; (void)b; (void)c; (void)d; } \
void prefix##_matrix_mode(mq_u32 a) { (void)a; } \
void prefix##_load_identity(void) {} \
void prefix##_push_matrix(void) {} \
void prefix##_pop_matrix(void) {} \
void prefix##_translate(mq_u32 a, mq_u32 b, mq_u32 c) { (void)a; (void)b; (void)c; } \
void prefix##_rotate(mq_u32 a, mq_u32 b, mq_u32 c, mq_u32 d) { (void)a; (void)b; (void)c; (void)d; } \
void prefix##_scale(mq_u32 a, mq_u32 b, mq_u32 c) { (void)a; (void)b; (void)c; } \
void prefix##_ortho(mq_u32 a, mq_u32 b, mq_u32 c, mq_u32 d, mq_u32 e, mq_u32 f) { (void)a; (void)b; (void)c; (void)d; (void)e; (void)f; } \
void prefix##_frustum(mq_u32 a, mq_u32 b, mq_u32 c, mq_u32 d, mq_u32 e, mq_u32 f) { (void)a; (void)b; (void)c; (void)d; (void)e; (void)f; } \
void prefix##_bind_texture(mq_u32 a, mq_u32 b) { (void)a; (void)b; } \
void prefix##_gen_textures(mq_i32 a, void *b) { (void)a; (void)b; } \
void prefix##_delete_textures(mq_i32 a, const void *b) { (void)a; (void)b; } \
void prefix##_tex_parameter_i(mq_u32 a, mq_u32 b, mq_i32 c) { (void)a; (void)b; (void)c; } \
void prefix##_tex_env_i(mq_u32 a, mq_u32 b, mq_i32 c) { (void)a; (void)b; (void)c; } \
void prefix##_tex_image_2d(mq_u32 a, mq_i32 b, mq_i32 c, mq_i32 d, mq_i32 e, mq_i32 f, mq_u32 g, mq_u32 h, const void *i) { (void)a;(void)b;(void)c;(void)d;(void)e;(void)f;(void)g;(void)h;(void)i; } \
void prefix##_tex_sub_image_2d(mq_u32 a, mq_i32 b, mq_i32 c, mq_i32 d, mq_i32 e, mq_i32 f, mq_u32 g, mq_u32 h, const void *i) { (void)a;(void)b;(void)c;(void)d;(void)e;(void)f;(void)g;(void)h;(void)i; } \
void prefix##_read_pixels(mq_i32 a, mq_i32 b, mq_i32 c, mq_i32 d, mq_u32 e, mq_u32 f, void *g) { (void)a;(void)b;(void)c;(void)d;(void)e;(void)f;(void)g; } \
const char *prefix##_get_string(mq_u32 a) { (void)a; return "Unavailable on Linux"; } \
mq_u32 prefix##_get_error(void) { return 0; } \
void prefix##_finish(void) {} \
void prefix##_flush(void) {} \
void prefix##_draw_buffer(mq_u32 a) { (void)a; } \
mq_i32 prefix##_enhanced_available(void) { return 0; } \
mq_i32 prefix##_enhanced_configure(mq_i32 a, mq_i32 b, mq_i32 c) { (void)a;(void)b;(void)c; return 0; } \
mq_i32 prefix##_enhanced_begin_frame(const void *a, mq_u32 b) { (void)a;(void)b; return 0; } \
void prefix##_enhanced_draw_kind(mq_i32 a) { (void)a; } \
void prefix##_enhanced_end_frame(void) {}

MQ_STUB_BACKEND(mq_d3d9)
MQ_STUB_BACKEND(mq_vulkan)
