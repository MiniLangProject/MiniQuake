#version 450

// Copyright (c) 1996-1997 Id Software, Inc.
// Copyright (c) 2026 Nils Kopal
// SPDX-License-Identifier: GPL-2.0-or-later

layout(set = 0, binding = 0) uniform sampler2D colorTexture;

layout(push_constant) uniform MiniQuakePush {
    mat4 transform;
    vec4 alphaReference;
    vec4 depthRange;
} pushData;

layout(location = 0) in vec2 texcoord;
layout(location = 1) in vec4 color;
layout(location = 0) out vec4 fragmentColor;

void main() {
    vec4 sampled = pushData.alphaReference.z > 0.5
        ? texture(colorTexture, texcoord)
        : vec4(1.0);
    vec4 shaded = (pushData.alphaReference.z < 0.5 || pushData.alphaReference.w > 0.5)
        ? sampled * color
        : vec4(sampled.rgb, sampled.a * color.a);
    if (pushData.alphaReference.y > 0.5 && shaded.a <= pushData.alphaReference.x) {
        discard;
    }
    fragmentColor = shaded;
}
