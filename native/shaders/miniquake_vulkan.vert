#version 450

// Copyright (c) 1996-1997 Id Software, Inc.
// Copyright (c) 2026 Nils Kopal
// SPDX-License-Identifier: GPL-2.0-or-later

layout(location = 0) in vec3 inPosition;
layout(location = 1) in vec2 inTexcoord;
layout(location = 2) in vec4 inColor;

layout(push_constant) uniform MiniQuakePush {
    mat4 transform;
    vec4 alphaReference;
    vec4 depthRange;
} pushData;

layout(location = 0) out vec2 texcoord;
layout(location = 1) out vec4 color;

void main() {
    gl_Position = pushData.transform * vec4(inPosition, 1.0);
    gl_Position.z = (gl_Position.z + gl_Position.w) * 0.5;
    gl_Position.z = mix(
        pushData.depthRange.x * gl_Position.w,
        pushData.depthRange.y * gl_Position.w,
        gl_Position.z / gl_Position.w
    );
    texcoord = inTexcoord;
    color = inColor;
}
