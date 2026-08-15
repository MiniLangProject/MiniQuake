/*
 * Copyright (c) 2026 Nils Kopal
 * SPDX-License-Identifier: Apache-2.0
 *
 * Shared fixed-width types and exports for the MiniLang/Win64 bridge ABI.
 */
#ifndef MINIQUAKE_NATIVE_H
#define MINIQUAKE_NATIVE_H

/* Fixed-width types for the narrow MiniLang <-> Win64 bridge ABI. */
typedef unsigned char mq_u8;
typedef unsigned short mq_u16;
typedef unsigned int mq_u32;
typedef unsigned long long mq_u64;
typedef signed char mq_i8;
typedef signed short mq_i16;
typedef signed int mq_i32;
typedef signed long long mq_i64;
typedef void *mq_ptr;

#define MQ_EXPORT __declspec(dllexport)

/* Forward declarations needed by the implementation before their definitions. */
MQ_EXPORT void mq_win_destroy(void);
MQ_EXPORT void mq_win_set_cursor_capture(mq_i32 enabled);

#endif
