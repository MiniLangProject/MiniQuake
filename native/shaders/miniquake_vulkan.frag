#version 450

// Copyright (c) 1996-1997 Id Software, Inc.
// Copyright (c) 2026 Nils Kopal
// SPDX-License-Identifier: GPL-2.0-or-later

layout(set = 0, binding = 0) uniform sampler2D colorTexture;

layout(push_constant) uniform MiniQuakePush {
    mat4 transform;
    vec4 alphaReference;
    vec4 depthRange;
    vec4 lights[2];
} pushData;

layout(location = 0) in vec2 texcoord;
layout(location = 1) in vec4 color;
layout(location = 2) in vec3 eyePosition;
layout(location = 0) out vec4 fragmentColor;

// Evaluate one Quake dynamic light as a smooth physically oriented point
// source. Static map illumination still comes from the original lightmaps.
float enhancedLight(vec4 light, vec3 normal) {
    vec3 delta = light.xyz - eyePosition;
    float distanceToLight = length(delta);
    if (light.w <= 0.0 || distanceToLight >= light.w) {
        return 0.0;
    }
    float attenuation = 1.0 - distanceToLight / light.w;
    attenuation *= attenuation;
    float diffuse = max(dot(normal, delta / max(distanceToLight, 0.001)), 0.0);
    // A back-facing receiver must stay dark.  The earlier ambient floor made
    // muzzle flashes leak visibly through thin BSP walls.
    return attenuation * diffuse;
}

void main() {
    if (pushData.depthRange.z > 0.5) {
        vec4 sampled = texture(colorTexture, texcoord);
        vec3 normal = normalize(cross(dFdx(eyePosition), dFdy(eyePosition)));
        if (dot(normal, -eyePosition) < 0.0) {
            normal = -normal;
        }
        float lightAmount = 0.0;
        if (pushData.depthRange.w > 0.0) lightAmount += enhancedLight(pushData.lights[0], normal);
        if (pushData.depthRange.w > 1.0) lightAmount += enhancedLight(pushData.lights[1], normal);
        // During enhanced draws alphaReference is repurposed as light three;
        // classic draws retain its fixed-function alpha-test meaning.
        if (pushData.depthRange.w > 2.0) lightAmount += enhancedLight(pushData.alphaReference, normal);
        fragmentColor = vec4(
            sampled.rgb * vec3(1.0, 0.58, 0.30) * min(lightAmount, 1.5),
            sampled.a
        );
        return;
    }
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
