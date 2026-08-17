#!/usr/bin/env python3
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: Apache-2.0

"""Guard Vulkan/D3D9 resource, fence and texture-boundary invariants."""

from __future__ import annotations

from pathlib import Path
import sys


def function_body(source: str, name: str) -> str:
    """Extract one C function body with a small brace-aware scanner."""
    signature = source.index(name + "(")
    opening = source.index("{", signature)
    depth = 0
    for index in range(opening, len(source)):
        character = source[index]
        if character == "{":
            depth += 1
        elif character == "}":
            depth -= 1
            if depth == 0:
                return source[opening : index + 1]
    raise AssertionError(f"unterminated function: {name}")


def require(condition: bool, message: str, errors: list[str]) -> None:
    """Append a readable failure when one safety invariant is absent."""
    if not condition:
        errors.append(message)


def main() -> int:
    """Check source-level regressions that previously caused hangs or memory writes."""
    root = Path(__file__).resolve().parents[1]
    vulkan = (root / "native" / "miniquake_vulkan.c").read_text(encoding="utf-8-sig")
    d3d9 = (root / "native" / "miniquake_d3d9.c").read_text(encoding="utf-8-sig")
    errors: list[str] = []

    frame_begin = function_body(vulkan, "mq_vk_frame_begin")
    present = function_body(vulkan, "mq_vulkan_present")
    require("mq_vkResetFences" not in frame_begin, "Vulkan resets a frame fence before image acquisition", errors)
    require("mq_vkResetFences" in present, "Vulkan present no longer resets the submit fence", errors)
    require(
        present.find("mq_vkResetFences") < present.find("mq_vkQueueSubmit"),
        "Vulkan submit fence is not reset immediately before submission",
        errors,
    )

    create_buffer = function_body(vulkan, "mq_vk_create_buffer")
    create_image = function_body(vulkan, "mq_vk_create_image")
    require("mq_vkDestroyBuffer" in create_buffer and "mq_vkFreeMemory" in create_buffer, "Vulkan buffer failure cleanup is incomplete", errors)
    require("mq_vkDestroyImage" in create_image and "mq_vkFreeMemory" in create_image, "Vulkan image failure cleanup is incomplete", errors)

    destroy_swapchain = function_body(vulkan, "mq_vk_destroy_swapchain")
    require("memset(mq_vk_image_views" in destroy_swapchain, "Vulkan swapchain leaves stale image-view handles", errors)
    require("memset(mq_vk_images" in destroy_swapchain, "Vulkan swapchain leaves stale image handles", errors)

    vk_sub_image = function_body(vulkan, "mq_vulkan_tex_sub_image_2d")
    require("mq_vk_texture_level_extent" in vk_sub_image, "Vulkan sub-image upload does not validate its mip level", errors)
    require("x_offset > level_width - width" in vk_sub_image, "Vulkan sub-image upload does not validate horizontal bounds", errors)
    require("y_offset > level_height - height" in vk_sub_image, "Vulkan sub-image upload does not validate vertical bounds", errors)
    require("mq_vk_staging_size" in vk_sub_image, "Vulkan sub-image upload does not protect the staging buffer", errors)

    d3d_image = function_body(d3d9, "mq_d3d9_tex_image_2d")
    d3d_sub_image = function_body(d3d9, "mq_d3d9_tex_sub_image_2d")
    require("mq_d3d_texture_level_extent" in d3d_image and ">> level" not in d3d_image, "D3D9 mip validation can shift by an invalid level", errors)
    require("x_offset > level_width - width" in d3d_sub_image, "D3D9 sub-image upload does not validate horizontal bounds", errors)
    require("y_offset > level_height - height" in d3d_sub_image, "D3D9 sub-image upload does not validate vertical bounds", errors)

    d3d_read = function_body(d3d9, "mq_d3d9_read_pixels")
    require("memset(pixels, 0" in d3d_read, "D3D9 readback can expose uninitialized clipped pixels", errors)

    if errors:
        print("native renderer safety tests: FAIL")
        for error in errors:
            print("  " + error)
        return 1
    print("native renderer safety tests: PASS (15 invariants)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
