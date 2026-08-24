/*
 * Vulkan 1.3 backend for MiniQuake's fixed-function renderer bridge ABI.
 *
 * Copyright (c) 1996-1997 Id Software, Inc.
 * Copyright (c) 2026 Nils Kopal
 * SPDX-License-Identifier: GPL-2.0-or-later
 *
 * The MiniLang renderer remains authoritative.  This module translates its
 * small immediate-mode ABI to one Vulkan command buffer and one persistently
 * mapped vertex upload buffer per presented frame.  Vulkan is loaded at
 * runtime, so OpenGL remains a working fallback on systems without a loader.
 */
#define VK_NO_PROTOTYPES
#define VK_NO_STDDEF_H
#define VK_NO_STDINT_H
typedef signed __int8 int8_t;
typedef unsigned __int8 uint8_t;
typedef signed __int16 int16_t;
typedef unsigned __int16 uint16_t;
typedef signed __int32 int32_t;
typedef unsigned __int32 uint32_t;
typedef signed __int64 int64_t;
typedef unsigned __int64 uint64_t;
typedef unsigned __int64 size_t;
#include <vulkan/vulkan.h>

#include "miniquake_vulkan.h"
#include "miniquake_vulkan_shaders.h"

#define MQ_DLLIMPORT __declspec(dllimport)
#define MQ_WINAPI __stdcall
#define MQ_NULL ((void *)0)

typedef void *MQ_HMODULE;
typedef void *MQ_HINSTANCE;
typedef VkFlags VkWin32SurfaceCreateFlagsKHR;
/* Mirror the Win32 vk win32 surface create info khr ABI layout without requiring SDK declarations. */
typedef struct VkWin32SurfaceCreateInfoKHR {
    VkStructureType sType;
    const void *pNext;
    VkWin32SurfaceCreateFlagsKHR flags;
    MQ_HINSTANCE hinstance;
    void *hwnd;
} VkWin32SurfaceCreateInfoKHR;
typedef VkResult (VKAPI_PTR *PFN_vkCreateWin32SurfaceKHR)(VkInstance instance, const VkWin32SurfaceCreateInfoKHR *create_info, const VkAllocationCallbacks *allocator, VkSurfaceKHR *surface);
#define VK_KHR_WIN32_SURFACE_EXTENSION_NAME "VK_KHR_win32_surface"
MQ_DLLIMPORT MQ_HMODULE MQ_WINAPI LoadLibraryA(const char *name);
MQ_DLLIMPORT void *MQ_WINAPI GetProcAddress(MQ_HMODULE module, const char *name);
MQ_DLLIMPORT mq_i32 MQ_WINAPI FreeLibrary(MQ_HMODULE module);
MQ_DLLIMPORT MQ_HMODULE MQ_WINAPI GetModuleHandleW(const unsigned short *name);
MQ_DLLIMPORT void * __cdecl memcpy(void *destination, const void *source, mq_u64 count);
MQ_DLLIMPORT void * __cdecl memset(void *destination, mq_i32 value, mq_u64 count);
MQ_DLLIMPORT double __cdecl sin(double value);
MQ_DLLIMPORT double __cdecl cos(double value);
MQ_DLLIMPORT double __cdecl sqrt(double value);

#define MQ_VK_FRAMES 2u
#define MQ_VK_MAX_TEXTURES 16384u
#define MQ_VK_MAX_VERTICES 1048576u
#define MQ_VK_MATRIX_STACK 64u
#define MQ_VK_PRESENT_IMAGE_INVALID 0xffffffffu

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

/* Store the Vulkan backend fields for one vk vertex. */
typedef struct mq_vk_vertex_s {
    float x, y, z;
    float s, t;
    float r, g, b, a;
} mq_vk_vertex_t;

/* Store the Vulkan backend fields for one vk push. */
typedef struct mq_vk_push_s {
    float transform[16];
    float alpha_reference[4];
    float depth_range[4];
    float lights[8];
} mq_vk_push_t;

/* Store the Vulkan backend fields for one vk texture. */
typedef struct mq_vk_texture_s {
    VkImage image;
    VkDeviceMemory memory;
    VkImageView view;
    VkSampler sampler;
    VkDescriptorSet descriptor;
    mq_i32 width;
    mq_i32 height;
    mq_i32 levels;
    mq_i32 uploaded_levels;
    mq_i32 min_filter;
    mq_i32 mag_filter;
    mq_i32 wrap_s;
    mq_i32 wrap_t;
    mq_i32 anisotropy;
    mq_i32 allocated;
} mq_vk_texture_t;

/* Store the Vulkan backend fields for one vk frame. */
typedef struct mq_vk_frame_s {
    VkCommandBuffer command;
    VkFence fence;
    VkSemaphore acquired;
    VkSemaphore complete;
    VkBuffer vertex_buffer;
    VkDeviceMemory vertex_memory;
    mq_vk_vertex_t *vertices;
    mq_u32 vertex_count;
    mq_u32 image_index;
    mq_i32 recording;
    mq_i32 rendering;
} mq_vk_frame_t;

static MQ_HMODULE mq_vk_module = MQ_NULL;
static PFN_vkGetInstanceProcAddr mq_vk_get_instance_proc = MQ_NULL;
static PFN_vkGetDeviceProcAddr mq_vk_get_device_proc = MQ_NULL;

static PFN_vkCreateInstance mq_vkCreateInstance;
static PFN_vkDestroyInstance mq_vkDestroyInstance;
static PFN_vkEnumeratePhysicalDevices mq_vkEnumeratePhysicalDevices;
static PFN_vkGetPhysicalDeviceProperties mq_vkGetPhysicalDeviceProperties;
static PFN_vkGetPhysicalDeviceFeatures2 mq_vkGetPhysicalDeviceFeatures2;
static PFN_vkGetPhysicalDeviceQueueFamilyProperties mq_vkGetPhysicalDeviceQueueFamilyProperties;
static PFN_vkGetPhysicalDeviceMemoryProperties mq_vkGetPhysicalDeviceMemoryProperties;
static PFN_vkEnumerateDeviceExtensionProperties mq_vkEnumerateDeviceExtensionProperties;
static PFN_vkCreateWin32SurfaceKHR mq_vkCreateWin32SurfaceKHR;
static PFN_vkDestroySurfaceKHR mq_vkDestroySurfaceKHR;
static PFN_vkGetPhysicalDeviceSurfaceSupportKHR mq_vkGetPhysicalDeviceSurfaceSupportKHR;
static PFN_vkGetPhysicalDeviceSurfaceCapabilitiesKHR mq_vkGetPhysicalDeviceSurfaceCapabilitiesKHR;
static PFN_vkGetPhysicalDeviceSurfaceFormatsKHR mq_vkGetPhysicalDeviceSurfaceFormatsKHR;
static PFN_vkGetPhysicalDeviceSurfacePresentModesKHR mq_vkGetPhysicalDeviceSurfacePresentModesKHR;
static PFN_vkCreateDevice mq_vkCreateDevice;

static PFN_vkDestroyDevice mq_vkDestroyDevice;
static PFN_vkGetDeviceQueue mq_vkGetDeviceQueue;
static PFN_vkDeviceWaitIdle mq_vkDeviceWaitIdle;
static PFN_vkQueueSubmit mq_vkQueueSubmit;
static PFN_vkQueuePresentKHR mq_vkQueuePresentKHR;
static PFN_vkCreateSwapchainKHR mq_vkCreateSwapchainKHR;
static PFN_vkDestroySwapchainKHR mq_vkDestroySwapchainKHR;
static PFN_vkGetSwapchainImagesKHR mq_vkGetSwapchainImagesKHR;
static PFN_vkAcquireNextImageKHR mq_vkAcquireNextImageKHR;
static PFN_vkCreateImageView mq_vkCreateImageView;
static PFN_vkDestroyImageView mq_vkDestroyImageView;
static PFN_vkCreateCommandPool mq_vkCreateCommandPool;
static PFN_vkDestroyCommandPool mq_vkDestroyCommandPool;
static PFN_vkAllocateCommandBuffers mq_vkAllocateCommandBuffers;
static PFN_vkFreeCommandBuffers mq_vkFreeCommandBuffers;
static PFN_vkResetCommandPool mq_vkResetCommandPool;
static PFN_vkResetCommandBuffer mq_vkResetCommandBuffer;
static PFN_vkBeginCommandBuffer mq_vkBeginCommandBuffer;
static PFN_vkEndCommandBuffer mq_vkEndCommandBuffer;
static PFN_vkCreateFence mq_vkCreateFence;
static PFN_vkDestroyFence mq_vkDestroyFence;
static PFN_vkWaitForFences mq_vkWaitForFences;
static PFN_vkResetFences mq_vkResetFences;
static PFN_vkCreateSemaphore mq_vkCreateSemaphore;
static PFN_vkDestroySemaphore mq_vkDestroySemaphore;
static PFN_vkCreateBuffer mq_vkCreateBuffer;
static PFN_vkDestroyBuffer mq_vkDestroyBuffer;
static PFN_vkGetBufferMemoryRequirements mq_vkGetBufferMemoryRequirements;
static PFN_vkAllocateMemory mq_vkAllocateMemory;
static PFN_vkFreeMemory mq_vkFreeMemory;
static PFN_vkBindBufferMemory mq_vkBindBufferMemory;
static PFN_vkMapMemory mq_vkMapMemory;
static PFN_vkUnmapMemory mq_vkUnmapMemory;
static PFN_vkCreateImage mq_vkCreateImage;
static PFN_vkDestroyImage mq_vkDestroyImage;
static PFN_vkGetImageMemoryRequirements mq_vkGetImageMemoryRequirements;
static PFN_vkBindImageMemory mq_vkBindImageMemory;
static PFN_vkCreateSampler mq_vkCreateSampler;
static PFN_vkDestroySampler mq_vkDestroySampler;
static PFN_vkCreateDescriptorSetLayout mq_vkCreateDescriptorSetLayout;
static PFN_vkDestroyDescriptorSetLayout mq_vkDestroyDescriptorSetLayout;
static PFN_vkCreateDescriptorPool mq_vkCreateDescriptorPool;
static PFN_vkDestroyDescriptorPool mq_vkDestroyDescriptorPool;
static PFN_vkAllocateDescriptorSets mq_vkAllocateDescriptorSets;
static PFN_vkUpdateDescriptorSets mq_vkUpdateDescriptorSets;
static PFN_vkCreatePipelineLayout mq_vkCreatePipelineLayout;
static PFN_vkDestroyPipelineLayout mq_vkDestroyPipelineLayout;
static PFN_vkCreateShaderModule mq_vkCreateShaderModule;
static PFN_vkDestroyShaderModule mq_vkDestroyShaderModule;
static PFN_vkCreateGraphicsPipelines mq_vkCreateGraphicsPipelines;
static PFN_vkDestroyPipeline mq_vkDestroyPipeline;
static PFN_vkCmdPipelineBarrier mq_vkCmdPipelineBarrier;
static PFN_vkCmdCopyBufferToImage mq_vkCmdCopyBufferToImage;
static PFN_vkCmdCopyImageToBuffer mq_vkCmdCopyImageToBuffer;
static PFN_vkCmdBeginRendering mq_vkCmdBeginRendering;
static PFN_vkCmdEndRendering mq_vkCmdEndRendering;
static PFN_vkCmdBindPipeline mq_vkCmdBindPipeline;
static PFN_vkCmdBindDescriptorSets mq_vkCmdBindDescriptorSets;
static PFN_vkCmdBindVertexBuffers mq_vkCmdBindVertexBuffers;
static PFN_vkCmdPushConstants mq_vkCmdPushConstants;
static PFN_vkCmdSetViewport mq_vkCmdSetViewport;
static PFN_vkCmdSetScissor mq_vkCmdSetScissor;
static PFN_vkCmdSetCullMode mq_vkCmdSetCullMode;
static PFN_vkCmdSetFrontFace mq_vkCmdSetFrontFace;
static PFN_vkCmdSetPrimitiveTopology mq_vkCmdSetPrimitiveTopology;
static PFN_vkCmdSetDepthTestEnable mq_vkCmdSetDepthTestEnable;
static PFN_vkCmdSetDepthWriteEnable mq_vkCmdSetDepthWriteEnable;
static PFN_vkCmdSetDepthCompareOp mq_vkCmdSetDepthCompareOp;
static PFN_vkCmdSetPolygonModeEXT mq_vkCmdSetPolygonModeEXT;
static PFN_vkCmdSetColorBlendEnableEXT mq_vkCmdSetColorBlendEnableEXT;
static PFN_vkCmdSetColorBlendEquationEXT mq_vkCmdSetColorBlendEquationEXT;
static PFN_vkCmdDraw mq_vkCmdDraw;

static VkInstance mq_vk_instance = VK_NULL_HANDLE;
static VkPhysicalDevice mq_vk_physical = VK_NULL_HANDLE;
static VkDevice mq_vk_device = VK_NULL_HANDLE;
static VkSurfaceKHR mq_vk_surface = VK_NULL_HANDLE;
static VkQueue mq_vk_queue = VK_NULL_HANDLE;
static mq_u32 mq_vk_queue_family = 0u;
static VkPhysicalDeviceMemoryProperties mq_vk_memory;
static VkSwapchainKHR mq_vk_swapchain = VK_NULL_HANDLE;
static VkFormat mq_vk_swapchain_format = VK_FORMAT_B8G8R8A8_UNORM;
static VkExtent2D mq_vk_extent;
static VkImage mq_vk_images[8];
static VkImageView mq_vk_image_views[8];
static mq_i32 mq_vk_image_initialized[8];
static mq_u32 mq_vk_image_count = 0u;
static VkImage mq_vk_depth_image = VK_NULL_HANDLE;
static VkDeviceMemory mq_vk_depth_memory = VK_NULL_HANDLE;
static VkImageView mq_vk_depth_view = VK_NULL_HANDLE;
static VkCommandPool mq_vk_command_pool = VK_NULL_HANDLE;
static mq_vk_frame_t mq_vk_frames[MQ_VK_FRAMES];
static mq_u32 mq_vk_frame_index = 0u;
static VkDescriptorSetLayout mq_vk_descriptor_layout = VK_NULL_HANDLE;
static VkDescriptorPool mq_vk_descriptor_pool = VK_NULL_HANDLE;
static VkPipelineLayout mq_vk_pipeline_layout = VK_NULL_HANDLE;
static VkPipeline mq_vk_pipeline = VK_NULL_HANDLE;
static mq_vk_texture_t mq_vk_textures[MQ_VK_MAX_TEXTURES];
static mq_u32 mq_vk_next_texture = 1u;
static mq_vk_texture_t mq_vk_white_texture;
static mq_u32 mq_vk_bound_texture = 0u;
static VkBuffer mq_vk_staging_buffer = VK_NULL_HANDLE;
static VkDeviceMemory mq_vk_staging_memory = VK_NULL_HANDLE;
static mq_u8 *mq_vk_staging = MQ_NULL;
static VkDeviceSize mq_vk_staging_size = 0u;
static mq_i32 mq_vk_width = 0;
static mq_i32 mq_vk_height = 0;
static mq_i32 mq_vk_last_error = 0;
static char mq_vk_device_name[VK_MAX_PHYSICAL_DEVICE_NAME_SIZE];
static mq_i32 mq_vk_sampler_anisotropy_enabled = 0;
static float mq_vk_max_sampler_anisotropy = 1.0f;
static mq_i32 mq_vk_enhanced_enabled = 0;
static mq_i32 mq_vk_enhanced_draw_kind_value = 0;
static mq_i32 mq_vk_enhanced_light_count = 0;
static float mq_vk_enhanced_view[16];
static float mq_vk_enhanced_lights[12];

static mq_u32 mq_vk_primitive_mode = MQ_GL_TRIANGLES;
static mq_vk_vertex_t mq_vk_immediate[65536];
static mq_vk_vertex_t mq_vk_expanded[98304];
static mq_u32 mq_vk_immediate_count = 0u;
static float mq_vk_current_s = 0.0f;
static float mq_vk_current_t = 0.0f;
static float mq_vk_current_color[4] = {1.0f, 1.0f, 1.0f, 1.0f};
static mq_i32 mq_vk_texture_enabled = 1;
static mq_i32 mq_vk_texture_environment = MQ_GL_REPLACE;
static mq_i32 mq_vk_depth_test = 1;
static mq_i32 mq_vk_depth_write = 1;
static mq_i32 mq_vk_blend = 0;
static mq_i32 mq_vk_alpha_test = 0;
static mq_i32 mq_vk_cull = 0;
static mq_u32 mq_vk_cull_face_value = MQ_GL_FRONT;
static mq_u32 mq_vk_depth_function = MQ_GL_LEQUAL;
static mq_u32 mq_vk_blend_source = MQ_GL_SRC_ALPHA;
static mq_u32 mq_vk_blend_destination = MQ_GL_ONE_MINUS_SRC_ALPHA;
static mq_u32 mq_vk_polygon_mode = 0u;
static float mq_vk_alpha_reference = 0.666f;
static float mq_vk_depth_min = 0.0f;
static float mq_vk_depth_max = 1.0f;
static VkClearColorValue mq_vk_clear_color;
static mq_u32 mq_vk_clear_mask = MQ_GL_COLOR_BUFFER_BIT | MQ_GL_DEPTH_BUFFER_BIT;
static mq_i32 mq_vk_viewport_x = 0;
static mq_i32 mq_vk_viewport_y = 0;
static mq_i32 mq_vk_viewport_width = 1;
static mq_i32 mq_vk_viewport_height = 1;
static mq_u32 mq_vk_matrix_mode_value = MQ_GL_MODELVIEW;
static float mq_vk_modelview[MQ_VK_MATRIX_STACK][16];
static float mq_vk_projection[MQ_VK_MATRIX_STACK][16];
static mq_u32 mq_vk_modelview_top = 0u;
static mq_u32 mq_vk_projection_top = 0u;

#define MQ_VK_INSTANCE(name) do { mq_vk##name = (PFN_vk##name)mq_vk_get_instance_proc(mq_vk_instance, "vk" #name); if (mq_vk##name == MQ_NULL) goto fail; } while (0)
#define MQ_VK_DEVICE(name) do { mq_vk##name = (PFN_vk##name)mq_vk_get_device_proc(mq_vk_device, "vk" #name); if (mq_vk##name == MQ_NULL) goto fail; } while (0)

/* Reinterpret MiniLang's IEEE-754 bit pattern as a native float. */
static float mq_vk_bits_float(mq_u32 bits) { union { mq_u32 u; float f; } value; value.u = bits; return value.f; }
/* Clamp a scalar to the inclusive requested range. */
static float mq_vk_clamp(float value, float low, float high) { if (value < low) return low; if (value > high) return high; return value; }

/* Initialize a column-major identity matrix. */
static void mq_vk_identity(float *matrix) {
    mq_u32 i;
    for (i = 0u; i < 16u; ++i) matrix[i] = 0.0f;
    matrix[0] = matrix[5] = matrix[10] = matrix[15] = 1.0f;
}

/* Multiply two column-major transform matrices. */
static void mq_vk_multiply(float *output, const float *left, const float *right) {
    float result[16];
    mq_u32 row, column, inner;
    for (column = 0u; column < 4u; ++column) for (row = 0u; row < 4u; ++row) {
        float value = 0.0f;
        for (inner = 0u; inner < 4u; ++inner) value += left[inner * 4u + row] * right[column * 4u + inner];
        result[column * 4u + row] = value;
    }
    memcpy(output, result, sizeof(result));
}

static float *mq_vk_current_matrix(void) {
    return mq_vk_matrix_mode_value == MQ_GL_PROJECTION ? mq_vk_projection[mq_vk_projection_top] : mq_vk_modelview[mq_vk_modelview_top];
}

/* Multiply two column-major transform matrices. */
static void mq_vk_postmultiply(const float *right) { float *value = mq_vk_current_matrix(); mq_vk_multiply(value, value, right); }

/* Find an exact extension name in the enumerated Vulkan properties. */
static mq_i32 mq_vk_extension(const VkExtensionProperties *values, mq_u32 count, const char *name) {
    mq_u32 i;
    for (i = 0u; i < count; ++i) {
        const char *a = values[i].extensionName;
        const char *b = name;
        while (*a != 0 && *a == *b) { ++a; ++b; }
        if (*a == 0 && *b == 0) return 1;
    }
    return 0;
}

/* Load the backend library and resolve its required entry points. */
static mq_i32 mq_vk_load(void) {
    if (mq_vk_module != MQ_NULL) return 1;
    mq_vk_module = LoadLibraryA("vulkan-1.dll");
    if (mq_vk_module == MQ_NULL) return 0;
    mq_vk_get_instance_proc = (PFN_vkGetInstanceProcAddr)GetProcAddress(mq_vk_module, "vkGetInstanceProcAddr");
    mq_vkCreateInstance = (PFN_vkCreateInstance)GetProcAddress(mq_vk_module, "vkCreateInstance");
    if (mq_vk_get_instance_proc == MQ_NULL || mq_vkCreateInstance == MQ_NULL) {
        FreeLibrary(mq_vk_module); mq_vk_module = MQ_NULL; return 0;
    }
    return 1;
}

/* Select a compatible Vulkan memory type for the requested properties. */
static mq_u32 mq_vk_memory_type(mq_u32 bits, VkMemoryPropertyFlags properties) {
    mq_u32 index;
    for (index = 0u; index < mq_vk_memory.memoryTypeCount; ++index) {
        if ((bits & (1u << index)) != 0u && (mq_vk_memory.memoryTypes[index].propertyFlags & properties) == properties) return index;
    }
    return 0xffffffffu;
}

/* Create and initialize create buffer. */
static mq_i32 mq_vk_create_buffer(VkDeviceSize size, VkBufferUsageFlags usage, VkMemoryPropertyFlags properties, VkBuffer *buffer, VkDeviceMemory *memory, void **mapped) {
    VkBufferCreateInfo info;
    VkMemoryRequirements requirements;
    VkMemoryAllocateInfo allocation;
    mq_u32 type;
    if (buffer == MQ_NULL || memory == MQ_NULL || size == 0u) return 0;
    *buffer = VK_NULL_HANDLE;
    *memory = VK_NULL_HANDLE;
    if (mapped != MQ_NULL) *mapped = MQ_NULL;
    memset(&info, 0, sizeof(info));
    info.sType = VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO;
    info.size = size;
    info.usage = usage;
    info.sharingMode = VK_SHARING_MODE_EXCLUSIVE;
    if (mq_vkCreateBuffer(mq_vk_device, &info, MQ_NULL, buffer) != VK_SUCCESS) return 0;
    mq_vkGetBufferMemoryRequirements(mq_vk_device, *buffer, &requirements);
    type = mq_vk_memory_type(requirements.memoryTypeBits, properties);
    if (type == 0xffffffffu) goto fail;
    memset(&allocation, 0, sizeof(allocation));
    allocation.sType = VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO;
    allocation.allocationSize = requirements.size;
    allocation.memoryTypeIndex = type;
    if (mq_vkAllocateMemory(mq_vk_device, &allocation, MQ_NULL, memory) != VK_SUCCESS) goto fail;
    if (mq_vkBindBufferMemory(mq_vk_device, *buffer, *memory, 0u) != VK_SUCCESS) goto fail;
    if (mapped != MQ_NULL && mq_vkMapMemory(mq_vk_device, *memory, 0u, size, 0u, mapped) != VK_SUCCESS) goto fail;
    return 1;
fail:
    if (*memory != VK_NULL_HANDLE) mq_vkFreeMemory(mq_vk_device, *memory, MQ_NULL);
    if (*buffer != VK_NULL_HANDLE) mq_vkDestroyBuffer(mq_vk_device, *buffer, MQ_NULL);
    *memory = VK_NULL_HANDLE;
    *buffer = VK_NULL_HANDLE;
    if (mapped != MQ_NULL) *mapped = MQ_NULL;
    return 0;
}

/* Create and initialize create image. */
static mq_i32 mq_vk_create_image(mq_i32 width, mq_i32 height, mq_i32 levels, VkFormat format, VkImageUsageFlags usage, VkImage *image, VkDeviceMemory *memory) {
    VkImageCreateInfo info;
    VkMemoryRequirements requirements;
    VkMemoryAllocateInfo allocation;
    mq_u32 type;
    if (image == MQ_NULL || memory == MQ_NULL || width < 1 || height < 1 || levels < 1) return 0;
    *image = VK_NULL_HANDLE;
    *memory = VK_NULL_HANDLE;
    memset(&info, 0, sizeof(info));
    info.sType = VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO;
    info.imageType = VK_IMAGE_TYPE_2D;
    info.format = format;
    info.extent.width = (mq_u32)width;
    info.extent.height = (mq_u32)height;
    info.extent.depth = 1u;
    info.mipLevels = (mq_u32)levels;
    info.arrayLayers = 1u;
    info.samples = VK_SAMPLE_COUNT_1_BIT;
    info.tiling = VK_IMAGE_TILING_OPTIMAL;
    info.usage = usage;
    info.sharingMode = VK_SHARING_MODE_EXCLUSIVE;
    info.initialLayout = VK_IMAGE_LAYOUT_UNDEFINED;
    if (mq_vkCreateImage(mq_vk_device, &info, MQ_NULL, image) != VK_SUCCESS) return 0;
    mq_vkGetImageMemoryRequirements(mq_vk_device, *image, &requirements);
    type = mq_vk_memory_type(requirements.memoryTypeBits, VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT);
    if (type == 0xffffffffu) goto fail;
    memset(&allocation, 0, sizeof(allocation));
    allocation.sType = VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO;
    allocation.allocationSize = requirements.size;
    allocation.memoryTypeIndex = type;
    if (mq_vkAllocateMemory(mq_vk_device, &allocation, MQ_NULL, memory) != VK_SUCCESS) goto fail;
    if (mq_vkBindImageMemory(mq_vk_device, *image, *memory, 0u) != VK_SUCCESS) goto fail;
    return 1;
fail:
    if (*memory != VK_NULL_HANDLE) mq_vkFreeMemory(mq_vk_device, *memory, MQ_NULL);
    if (*image != VK_NULL_HANDLE) mq_vkDestroyImage(mq_vk_device, *image, MQ_NULL);
    *memory = VK_NULL_HANDLE;
    *image = VK_NULL_HANDLE;
    return 0;
}

/* Create an image view for backend texture access. */
static mq_i32 mq_vk_view(VkImage image, VkFormat format, VkImageAspectFlags aspect, mq_i32 levels, VkImageView *view) {
    VkImageViewCreateInfo info;
    memset(&info, 0, sizeof(info));
    info.sType = VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO;
    info.image = image;
    info.viewType = VK_IMAGE_VIEW_TYPE_2D;
    info.format = format;
    info.subresourceRange.aspectMask = aspect;
    info.subresourceRange.levelCount = (mq_u32)levels;
    info.subresourceRange.layerCount = 1u;
    return mq_vkCreateImageView(mq_vk_device, &info, MQ_NULL, view) == VK_SUCCESS;
}

/* Record the image-layout transition required by the next operation. */
static void mq_vk_image_barrier(VkCommandBuffer command, VkImage image, VkImageAspectFlags aspect, mq_u32 base_level, mq_u32 levels, VkImageLayout old_layout, VkImageLayout new_layout, VkPipelineStageFlags source_stage, VkPipelineStageFlags destination_stage, VkAccessFlags source_access, VkAccessFlags destination_access) {
    VkImageMemoryBarrier barrier;
    memset(&barrier, 0, sizeof(barrier));
    barrier.sType = VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
    barrier.srcAccessMask = source_access;
    barrier.dstAccessMask = destination_access;
    barrier.oldLayout = old_layout;
    barrier.newLayout = new_layout;
    barrier.srcQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED;
    barrier.dstQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED;
    barrier.image = image;
    barrier.subresourceRange.aspectMask = aspect;
    barrier.subresourceRange.baseMipLevel = base_level;
    barrier.subresourceRange.levelCount = levels;
    barrier.subresourceRange.layerCount = 1u;
    mq_vkCmdPipelineBarrier(command, source_stage, destination_stage, 0u, 0u, MQ_NULL, 0u, MQ_NULL, 1u, &barrier);
}

/* Begin a transient Vulkan command buffer for a one-shot operation. */
static VkCommandBuffer mq_vk_one_time_begin(void) {
    VkCommandBufferAllocateInfo allocate;
    VkCommandBufferBeginInfo begin;
    VkCommandBuffer command = VK_NULL_HANDLE;
    memset(&allocate, 0, sizeof(allocate));
    allocate.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO;
    allocate.commandPool = mq_vk_command_pool;
    allocate.level = VK_COMMAND_BUFFER_LEVEL_PRIMARY;
    allocate.commandBufferCount = 1u;
    if (mq_vkAllocateCommandBuffers(mq_vk_device, &allocate, &command) != VK_SUCCESS) return VK_NULL_HANDLE;
    memset(&begin, 0, sizeof(begin));
    begin.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO;
    begin.flags = VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT;
    if (mq_vkBeginCommandBuffer(command, &begin) != VK_SUCCESS) {
        mq_vkFreeCommandBuffers(mq_vk_device, mq_vk_command_pool, 1u, &command);
        return VK_NULL_HANDLE;
    }
    return command;
}

/* Submit and retire a transient Vulkan command buffer. */
static mq_i32 mq_vk_one_time_end(VkCommandBuffer command) {
    VkSubmitInfo submit;
    VkFenceCreateInfo fence_info;
    VkFence fence = VK_NULL_HANDLE;
    mq_i32 submitted = 0;
    mq_i32 success = 0;
    if (command == VK_NULL_HANDLE) return 0;
    if (mq_vkEndCommandBuffer(command) != VK_SUCCESS) goto done;
    memset(&fence_info, 0, sizeof(fence_info)); fence_info.sType = VK_STRUCTURE_TYPE_FENCE_CREATE_INFO;
    if (mq_vkCreateFence(mq_vk_device, &fence_info, MQ_NULL, &fence) != VK_SUCCESS) goto done;
    memset(&submit, 0, sizeof(submit)); submit.sType = VK_STRUCTURE_TYPE_SUBMIT_INFO; submit.commandBufferCount = 1u; submit.pCommandBuffers = &command;
    if (mq_vkQueueSubmit(mq_vk_queue, 1u, &submit, fence) != VK_SUCCESS) goto done;
    submitted = 1;
    if (mq_vkWaitForFences(mq_vk_device, 1u, &fence, VK_TRUE, ~(mq_u64)0u) != VK_SUCCESS) goto done;
    success = 1;
done:
    if (submitted && !success) mq_vkDeviceWaitIdle(mq_vk_device);
    if (fence != VK_NULL_HANDLE) mq_vkDestroyFence(mq_vk_device, fence, MQ_NULL);
    mq_vkFreeCommandBuffers(mq_vk_device, mq_vk_command_pool, 1u, &command);
    return success;
}

/* Release resources owned by destroy texture. */
static void mq_vk_destroy_texture(mq_vk_texture_t *texture) {
    if (texture->sampler != VK_NULL_HANDLE) mq_vkDestroySampler(mq_vk_device, texture->sampler, MQ_NULL);
    if (texture->view != VK_NULL_HANDLE) mq_vkDestroyImageView(mq_vk_device, texture->view, MQ_NULL);
    if (texture->image != VK_NULL_HANDLE) mq_vkDestroyImage(mq_vk_device, texture->image, MQ_NULL);
    if (texture->memory != VK_NULL_HANDLE) mq_vkFreeMemory(mq_vk_device, texture->memory, MQ_NULL);
    memset(texture, 0, sizeof(*texture));
}

/* Create the sampler matching the texture's filter and wrap state. */
static mq_i32 mq_vk_sampler(mq_vk_texture_t *texture) {
    VkSamplerCreateInfo info;
    VkSampler replacement = VK_NULL_HANDLE;
    memset(&info, 0, sizeof(info));
    info.sType = VK_STRUCTURE_TYPE_SAMPLER_CREATE_INFO;
    info.magFilter = texture->mag_filter == MQ_GL_LINEAR ? VK_FILTER_LINEAR : VK_FILTER_NEAREST;
    info.minFilter = (texture->min_filter == MQ_GL_LINEAR || texture->min_filter == MQ_GL_LINEAR_MIPMAP_NEAREST || texture->min_filter == MQ_GL_LINEAR_MIPMAP_LINEAR) ? VK_FILTER_LINEAR : VK_FILTER_NEAREST;
    info.mipmapMode = (texture->min_filter == MQ_GL_NEAREST_MIPMAP_LINEAR || texture->min_filter == MQ_GL_LINEAR_MIPMAP_LINEAR) ? VK_SAMPLER_MIPMAP_MODE_LINEAR : VK_SAMPLER_MIPMAP_MODE_NEAREST;
    info.addressModeU = texture->wrap_s == MQ_GL_CLAMP ? VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE : VK_SAMPLER_ADDRESS_MODE_REPEAT;
    info.addressModeV = texture->wrap_t == MQ_GL_CLAMP ? VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE : VK_SAMPLER_ADDRESS_MODE_REPEAT;
    info.addressModeW = VK_SAMPLER_ADDRESS_MODE_REPEAT;
    if (mq_vk_sampler_anisotropy_enabled && texture->anisotropy > 1) {
        info.anisotropyEnable = VK_TRUE;
        info.maxAnisotropy = mq_vk_clamp((float)texture->anisotropy, 1.0f, mq_vk_max_sampler_anisotropy);
    }
    info.maxLod = (texture->min_filter == MQ_GL_NEAREST_MIPMAP_NEAREST || texture->min_filter == MQ_GL_LINEAR_MIPMAP_NEAREST || texture->min_filter == MQ_GL_NEAREST_MIPMAP_LINEAR || texture->min_filter == MQ_GL_LINEAR_MIPMAP_LINEAR) ? (float)(texture->uploaded_levels > 0 ? texture->uploaded_levels - 1 : 0) : 0.0f;
    if (mq_vkCreateSampler(mq_vk_device, &info, MQ_NULL, &replacement) != VK_SUCCESS) return 0;
    if (texture->sampler != VK_NULL_HANDLE) mq_vkDestroySampler(mq_vk_device, texture->sampler, MQ_NULL);
    texture->sampler = replacement;
    return 1;
}

/* Bind the texture image and sampler to its descriptor set. */
static void mq_vk_update_descriptor(mq_vk_texture_t *texture) {
    VkDescriptorImageInfo image;
    VkWriteDescriptorSet write;
    if (texture->descriptor == VK_NULL_HANDLE || texture->view == VK_NULL_HANDLE || texture->sampler == VK_NULL_HANDLE) return;
    memset(&image, 0, sizeof(image)); image.sampler = texture->sampler; image.imageView = texture->view; image.imageLayout = VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
    memset(&write, 0, sizeof(write)); write.sType = VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET; write.dstSet = texture->descriptor; write.descriptorCount = 1u; write.descriptorType = VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER; write.pImageInfo = &image;
    mq_vkUpdateDescriptorSets(mq_vk_device, 1u, &write, 0u, MQ_NULL);
}

/* Allocate a descriptor set for one texture. */
static mq_i32 mq_vk_alloc_descriptor(mq_vk_texture_t *texture) {
    VkDescriptorSetAllocateInfo allocation;
    memset(&allocation, 0, sizeof(allocation)); allocation.sType = VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO; allocation.descriptorPool = mq_vk_descriptor_pool; allocation.descriptorSetCount = 1u; allocation.pSetLayouts = &mq_vk_descriptor_layout;
    return mq_vkAllocateDescriptorSets(mq_vk_device, &allocation, &texture->descriptor) == VK_SUCCESS;
}

/* Create and initialize create white. */
static mq_i32 mq_vk_create_white(void) {
    mq_u8 white[4] = {255u, 255u, 255u, 255u};
    mq_vk_bound_texture = 0u;
    if (!mq_vk_alloc_descriptor(&mq_vk_white_texture)) return 0;
    mq_vk_white_texture.min_filter = MQ_GL_NEAREST;
    mq_vk_white_texture.mag_filter = MQ_GL_NEAREST;
    mq_vk_white_texture.wrap_s = MQ_GL_REPEAT;
    mq_vk_white_texture.wrap_t = MQ_GL_REPEAT;
    mq_vulkan_tex_image_2d(MQ_GL_TEXTURE_2D, 0, MQ_GL_RGBA, 1, 1, 0, MQ_GL_RGBA, MQ_GL_UNSIGNED_BYTE, white);
    return mq_vk_white_texture.view != VK_NULL_HANDLE;
}

/* Create and initialize create pipeline. */
static mq_i32 mq_vk_create_pipeline(void) {
    VkShaderModuleCreateInfo shader_info;
    VkShaderModule vertex = VK_NULL_HANDLE, fragment = VK_NULL_HANDLE;
    VkPipelineShaderStageCreateInfo stages[2];
    VkVertexInputBindingDescription binding;
    VkVertexInputAttributeDescription attributes[3];
    VkPipelineVertexInputStateCreateInfo vertex_input;
    VkPipelineInputAssemblyStateCreateInfo assembly;
    VkPipelineViewportStateCreateInfo viewport;
    VkPipelineRasterizationStateCreateInfo raster;
    VkPipelineMultisampleStateCreateInfo multisample;
    VkPipelineDepthStencilStateCreateInfo depth;
    VkPipelineColorBlendAttachmentState attachment;
    VkPipelineColorBlendStateCreateInfo blend;
    VkDynamicState dynamics[11];
    VkPipelineDynamicStateCreateInfo dynamic;
    VkPipelineRenderingCreateInfo rendering;
    VkGraphicsPipelineCreateInfo pipeline;
    VkPipelineLayoutCreateInfo layout;
    VkPushConstantRange push;
    VkDescriptorSetLayoutBinding descriptor_binding;
    VkDescriptorSetLayoutCreateInfo descriptor_layout;

    memset(&descriptor_binding, 0, sizeof(descriptor_binding)); descriptor_binding.binding = 0u; descriptor_binding.descriptorType = VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER; descriptor_binding.descriptorCount = 1u; descriptor_binding.stageFlags = VK_SHADER_STAGE_FRAGMENT_BIT;
    memset(&descriptor_layout, 0, sizeof(descriptor_layout)); descriptor_layout.sType = VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO; descriptor_layout.bindingCount = 1u; descriptor_layout.pBindings = &descriptor_binding;
    if (mq_vkCreateDescriptorSetLayout(mq_vk_device, &descriptor_layout, MQ_NULL, &mq_vk_descriptor_layout) != VK_SUCCESS) return 0;
    memset(&push, 0, sizeof(push)); push.stageFlags = VK_SHADER_STAGE_VERTEX_BIT | VK_SHADER_STAGE_FRAGMENT_BIT; push.size = sizeof(mq_vk_push_t);
    memset(&layout, 0, sizeof(layout)); layout.sType = VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO; layout.setLayoutCount = 1u; layout.pSetLayouts = &mq_vk_descriptor_layout; layout.pushConstantRangeCount = 1u; layout.pPushConstantRanges = &push;
    if (mq_vkCreatePipelineLayout(mq_vk_device, &layout, MQ_NULL, &mq_vk_pipeline_layout) != VK_SUCCESS) return 0;

    memset(&shader_info, 0, sizeof(shader_info)); shader_info.sType = VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO; shader_info.codeSize = sizeof(mq_vulkan_vertex_spirv); shader_info.pCode = mq_vulkan_vertex_spirv;
    if (mq_vkCreateShaderModule(mq_vk_device, &shader_info, MQ_NULL, &vertex) != VK_SUCCESS) return 0;
    shader_info.codeSize = sizeof(mq_vulkan_fragment_spirv); shader_info.pCode = mq_vulkan_fragment_spirv;
    if (mq_vkCreateShaderModule(mq_vk_device, &shader_info, MQ_NULL, &fragment) != VK_SUCCESS) {
        mq_vkDestroyShaderModule(mq_vk_device, vertex, MQ_NULL);
        return 0;
    }
    memset(stages, 0, sizeof(stages));
    stages[0].sType = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO; stages[0].stage = VK_SHADER_STAGE_VERTEX_BIT; stages[0].module = vertex; stages[0].pName = "main";
    stages[1].sType = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO; stages[1].stage = VK_SHADER_STAGE_FRAGMENT_BIT; stages[1].module = fragment; stages[1].pName = "main";
    binding.binding = 0u; binding.stride = sizeof(mq_vk_vertex_t); binding.inputRate = VK_VERTEX_INPUT_RATE_VERTEX;
    memset(attributes, 0, sizeof(attributes));
    attributes[0].location = 0u; attributes[0].binding = 0u; attributes[0].format = VK_FORMAT_R32G32B32_SFLOAT; attributes[0].offset = 0u;
    attributes[1].location = 1u; attributes[1].binding = 0u; attributes[1].format = VK_FORMAT_R32G32_SFLOAT; attributes[1].offset = 12u;
    attributes[2].location = 2u; attributes[2].binding = 0u; attributes[2].format = VK_FORMAT_R32G32B32A32_SFLOAT; attributes[2].offset = 20u;
    memset(&vertex_input, 0, sizeof(vertex_input)); vertex_input.sType = VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO; vertex_input.vertexBindingDescriptionCount = 1u; vertex_input.pVertexBindingDescriptions = &binding; vertex_input.vertexAttributeDescriptionCount = 3u; vertex_input.pVertexAttributeDescriptions = attributes;
    memset(&assembly, 0, sizeof(assembly)); assembly.sType = VK_STRUCTURE_TYPE_PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO; assembly.topology = VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST;
    memset(&viewport, 0, sizeof(viewport)); viewport.sType = VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_STATE_CREATE_INFO; viewport.viewportCount = 1u; viewport.scissorCount = 1u;
    memset(&raster, 0, sizeof(raster)); raster.sType = VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_CREATE_INFO; raster.lineWidth = 1.0f; raster.polygonMode = VK_POLYGON_MODE_FILL; raster.cullMode = VK_CULL_MODE_NONE; raster.frontFace = VK_FRONT_FACE_CLOCKWISE;
    memset(&multisample, 0, sizeof(multisample)); multisample.sType = VK_STRUCTURE_TYPE_PIPELINE_MULTISAMPLE_STATE_CREATE_INFO; multisample.rasterizationSamples = VK_SAMPLE_COUNT_1_BIT;
    memset(&depth, 0, sizeof(depth)); depth.sType = VK_STRUCTURE_TYPE_PIPELINE_DEPTH_STENCIL_STATE_CREATE_INFO; depth.depthTestEnable = VK_TRUE; depth.depthWriteEnable = VK_TRUE; depth.depthCompareOp = VK_COMPARE_OP_LESS_OR_EQUAL;
    memset(&attachment, 0, sizeof(attachment)); attachment.colorWriteMask = 0xfu; attachment.srcColorBlendFactor = VK_BLEND_FACTOR_SRC_ALPHA; attachment.dstColorBlendFactor = VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA; attachment.colorBlendOp = VK_BLEND_OP_ADD; attachment.srcAlphaBlendFactor = VK_BLEND_FACTOR_SRC_ALPHA; attachment.dstAlphaBlendFactor = VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA; attachment.alphaBlendOp = VK_BLEND_OP_ADD;
    memset(&blend, 0, sizeof(blend)); blend.sType = VK_STRUCTURE_TYPE_PIPELINE_COLOR_BLEND_STATE_CREATE_INFO; blend.attachmentCount = 1u; blend.pAttachments = &attachment;
    dynamics[0] = VK_DYNAMIC_STATE_VIEWPORT; dynamics[1] = VK_DYNAMIC_STATE_SCISSOR; dynamics[2] = VK_DYNAMIC_STATE_CULL_MODE; dynamics[3] = VK_DYNAMIC_STATE_FRONT_FACE; dynamics[4] = VK_DYNAMIC_STATE_PRIMITIVE_TOPOLOGY; dynamics[5] = VK_DYNAMIC_STATE_DEPTH_TEST_ENABLE; dynamics[6] = VK_DYNAMIC_STATE_DEPTH_WRITE_ENABLE; dynamics[7] = VK_DYNAMIC_STATE_DEPTH_COMPARE_OP; dynamics[8] = VK_DYNAMIC_STATE_POLYGON_MODE_EXT; dynamics[9] = VK_DYNAMIC_STATE_COLOR_BLEND_ENABLE_EXT; dynamics[10] = VK_DYNAMIC_STATE_COLOR_BLEND_EQUATION_EXT;
    memset(&dynamic, 0, sizeof(dynamic)); dynamic.sType = VK_STRUCTURE_TYPE_PIPELINE_DYNAMIC_STATE_CREATE_INFO; dynamic.dynamicStateCount = 11u; dynamic.pDynamicStates = dynamics;
    memset(&rendering, 0, sizeof(rendering)); rendering.sType = VK_STRUCTURE_TYPE_PIPELINE_RENDERING_CREATE_INFO; rendering.colorAttachmentCount = 1u; rendering.pColorAttachmentFormats = &mq_vk_swapchain_format; rendering.depthAttachmentFormat = VK_FORMAT_D32_SFLOAT;
    memset(&pipeline, 0, sizeof(pipeline)); pipeline.sType = VK_STRUCTURE_TYPE_GRAPHICS_PIPELINE_CREATE_INFO; pipeline.pNext = &rendering; pipeline.stageCount = 2u; pipeline.pStages = stages; pipeline.pVertexInputState = &vertex_input; pipeline.pInputAssemblyState = &assembly; pipeline.pViewportState = &viewport; pipeline.pRasterizationState = &raster; pipeline.pMultisampleState = &multisample; pipeline.pDepthStencilState = &depth; pipeline.pColorBlendState = &blend; pipeline.pDynamicState = &dynamic; pipeline.layout = mq_vk_pipeline_layout;
    mq_vk_last_error = mq_vkCreateGraphicsPipelines(mq_vk_device, VK_NULL_HANDLE, 1u, &pipeline, MQ_NULL, &mq_vk_pipeline);
    mq_vkDestroyShaderModule(mq_vk_device, fragment, MQ_NULL); mq_vkDestroyShaderModule(mq_vk_device, vertex, MQ_NULL);
    return mq_vk_last_error == VK_SUCCESS;
}

/* Release resources owned by destroy swapchain. */
static void mq_vk_destroy_swapchain(void) {
    mq_u32 i;
    if (mq_vk_device != VK_NULL_HANDLE) mq_vkDeviceWaitIdle(mq_vk_device);
    if (mq_vk_depth_view != VK_NULL_HANDLE) mq_vkDestroyImageView(mq_vk_device, mq_vk_depth_view, MQ_NULL);
    if (mq_vk_depth_image != VK_NULL_HANDLE) mq_vkDestroyImage(mq_vk_device, mq_vk_depth_image, MQ_NULL);
    if (mq_vk_depth_memory != VK_NULL_HANDLE) mq_vkFreeMemory(mq_vk_device, mq_vk_depth_memory, MQ_NULL);
    mq_vk_depth_view = VK_NULL_HANDLE; mq_vk_depth_image = VK_NULL_HANDLE; mq_vk_depth_memory = VK_NULL_HANDLE;
    for (i = 0u; i < mq_vk_image_count; ++i) if (mq_vk_image_views[i] != VK_NULL_HANDLE) mq_vkDestroyImageView(mq_vk_device, mq_vk_image_views[i], MQ_NULL);
    if (mq_vk_swapchain != VK_NULL_HANDLE) mq_vkDestroySwapchainKHR(mq_vk_device, mq_vk_swapchain, MQ_NULL);
    mq_vk_swapchain = VK_NULL_HANDLE;
    mq_vk_image_count = 0u;
    memset(mq_vk_images, 0, sizeof(mq_vk_images));
    memset(mq_vk_image_views, 0, sizeof(mq_vk_image_views));
    memset(mq_vk_image_initialized, 0, sizeof(mq_vk_image_initialized));
}

/* Create and initialize create swapchain. */
static mq_i32 mq_vk_create_swapchain(mq_i32 width, mq_i32 height) {
    VkSurfaceCapabilitiesKHR capabilities;
    VkSurfaceFormatKHR formats[32]; mq_u32 format_count = 32u;
    VkPresentModeKHR modes[16]; mq_u32 mode_count = 16u;
    VkSwapchainCreateInfoKHR info;
    VkPresentModeKHR present = VK_PRESENT_MODE_FIFO_KHR;
    VkCompositeAlphaFlagBitsKHR composite_alpha;
    VkResult result;
    mq_u32 image_count;
    mq_u32 i;
    mq_u32 selected_format = 0u;
    result = mq_vkGetPhysicalDeviceSurfaceCapabilitiesKHR(mq_vk_physical, mq_vk_surface, &capabilities);
    if (result != VK_SUCCESS) goto fail;
    result = mq_vkGetPhysicalDeviceSurfaceFormatsKHR(mq_vk_physical, mq_vk_surface, &format_count, formats);
    if (result != VK_SUCCESS || format_count == 0u) goto fail;
    result = mq_vkGetPhysicalDeviceSurfacePresentModesKHR(mq_vk_physical, mq_vk_surface, &mode_count, modes);
    if (result != VK_SUCCESS || mode_count == 0u) goto fail;
    if ((capabilities.supportedUsageFlags & (VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT | VK_IMAGE_USAGE_TRANSFER_SRC_BIT)) != (VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT | VK_IMAGE_USAGE_TRANSFER_SRC_BIT)) goto fail;
    for (i = 0u; i < format_count; ++i) {
        if (formats[i].format == VK_FORMAT_B8G8R8A8_UNORM || formats[i].format == VK_FORMAT_R8G8B8A8_UNORM) { selected_format = i; break; }
    }
    mq_vk_swapchain_format = formats[selected_format].format == VK_FORMAT_UNDEFINED ? VK_FORMAT_B8G8R8A8_UNORM : formats[selected_format].format;
    for (i = 0u; i < mode_count; ++i) if (modes[i] == VK_PRESENT_MODE_IMMEDIATE_KHR) present = modes[i];
    if (capabilities.currentExtent.width != 0xffffffffu) {
        mq_vk_extent = capabilities.currentExtent;
    } else {
        mq_vk_extent.width = (mq_u32)width;
        mq_vk_extent.height = (mq_u32)height;
        if (mq_vk_extent.width < capabilities.minImageExtent.width) mq_vk_extent.width = capabilities.minImageExtent.width;
        if (mq_vk_extent.width > capabilities.maxImageExtent.width) mq_vk_extent.width = capabilities.maxImageExtent.width;
        if (mq_vk_extent.height < capabilities.minImageExtent.height) mq_vk_extent.height = capabilities.minImageExtent.height;
        if (mq_vk_extent.height > capabilities.maxImageExtent.height) mq_vk_extent.height = capabilities.maxImageExtent.height;
    }
    composite_alpha = VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR;
    if ((capabilities.supportedCompositeAlpha & composite_alpha) == 0u) {
        if ((capabilities.supportedCompositeAlpha & VK_COMPOSITE_ALPHA_PRE_MULTIPLIED_BIT_KHR) != 0u) composite_alpha = VK_COMPOSITE_ALPHA_PRE_MULTIPLIED_BIT_KHR;
        else if ((capabilities.supportedCompositeAlpha & VK_COMPOSITE_ALPHA_POST_MULTIPLIED_BIT_KHR) != 0u) composite_alpha = VK_COMPOSITE_ALPHA_POST_MULTIPLIED_BIT_KHR;
        else composite_alpha = VK_COMPOSITE_ALPHA_INHERIT_BIT_KHR;
    }
    memset(&info, 0, sizeof(info)); info.sType = VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR; info.surface = mq_vk_surface; info.minImageCount = capabilities.minImageCount + 1u; if (capabilities.maxImageCount != 0u && info.minImageCount > capabilities.maxImageCount) info.minImageCount = capabilities.maxImageCount; info.imageFormat = mq_vk_swapchain_format; info.imageColorSpace = formats[selected_format].colorSpace; info.imageExtent = mq_vk_extent; info.imageArrayLayers = 1u; info.imageUsage = VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT | VK_IMAGE_USAGE_TRANSFER_SRC_BIT; info.imageSharingMode = VK_SHARING_MODE_EXCLUSIVE; info.preTransform = capabilities.currentTransform; info.compositeAlpha = composite_alpha; info.presentMode = present; info.clipped = VK_TRUE;
    result = mq_vkCreateSwapchainKHR(mq_vk_device, &info, MQ_NULL, &mq_vk_swapchain);
    if (result != VK_SUCCESS) goto fail;
    image_count = 0u;
    result = mq_vkGetSwapchainImagesKHR(mq_vk_device, mq_vk_swapchain, &image_count, MQ_NULL);
    if (result != VK_SUCCESS || image_count == 0u || image_count > 8u) goto fail;
    mq_vk_image_count = image_count;
    result = mq_vkGetSwapchainImagesKHR(mq_vk_device, mq_vk_swapchain, &mq_vk_image_count, mq_vk_images);
    if (result != VK_SUCCESS || mq_vk_image_count != image_count) goto fail;
    for (i = 0u; i < mq_vk_image_count; ++i) if (!mq_vk_view(mq_vk_images[i], mq_vk_swapchain_format, VK_IMAGE_ASPECT_COLOR_BIT, 1, &mq_vk_image_views[i])) goto fail;
    if (!mq_vk_create_image((mq_i32)mq_vk_extent.width, (mq_i32)mq_vk_extent.height, 1, VK_FORMAT_D32_SFLOAT, VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT, &mq_vk_depth_image, &mq_vk_depth_memory)) goto fail;
    if (!mq_vk_view(mq_vk_depth_image, VK_FORMAT_D32_SFLOAT, VK_IMAGE_ASPECT_DEPTH_BIT, 1, &mq_vk_depth_view)) goto fail;
    mq_vk_width = (mq_i32)mq_vk_extent.width; mq_vk_height = (mq_i32)mq_vk_extent.height;
    return 1;
fail:
    mq_vk_last_error = result;
    mq_vk_destroy_swapchain();
    return 0;
}

/* Report whether available is available. */
mq_i32 mq_vulkan_available(void) {
    VkApplicationInfo app;
    VkInstanceCreateInfo info;
    VkInstance probe = VK_NULL_HANDLE;
    if (!mq_vk_load()) return 0;
    memset(&app, 0, sizeof(app)); app.sType = VK_STRUCTURE_TYPE_APPLICATION_INFO; app.pApplicationName = "MiniQuake"; app.apiVersion = VK_API_VERSION_1_3;
    memset(&info, 0, sizeof(info)); info.sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO; info.pApplicationInfo = &app;
    if (mq_vkCreateInstance(&info, MQ_NULL, &probe) != VK_SUCCESS) return 0;
    ((PFN_vkDestroyInstance)mq_vk_get_instance_proc(probe, "vkDestroyInstance"))(probe, MQ_NULL);
    return 1;
}

/* Create and initialize initialize. */
mq_i32 mq_vulkan_initialize(mq_ptr window, mq_i32 width, mq_i32 height) {
    const char *instance_extensions[2] = {VK_KHR_SURFACE_EXTENSION_NAME, VK_KHR_WIN32_SURFACE_EXTENSION_NAME};
    const char *device_extensions[4] = {VK_KHR_SWAPCHAIN_EXTENSION_NAME, VK_EXT_EXTENDED_DYNAMIC_STATE_EXTENSION_NAME, VK_EXT_EXTENDED_DYNAMIC_STATE_3_EXTENSION_NAME, VK_KHR_DYNAMIC_RENDERING_EXTENSION_NAME};
    VkApplicationInfo app; VkInstanceCreateInfo instance_info; VkWin32SurfaceCreateInfoKHR surface_info;
    VkPhysicalDevice physicals[16]; mq_u32 physical_count = 16u; mq_u32 physical_index;
    VkDeviceQueueCreateInfo queue_info; float priority = 1.0f; VkDeviceCreateInfo device_info;
    VkPhysicalDeviceFeatures2 features; VkPhysicalDeviceFeatures enabled_features; VkPhysicalDeviceVulkan13Features features13; VkPhysicalDeviceExtendedDynamicStateFeaturesEXT dynamic1; VkPhysicalDeviceExtendedDynamicState3FeaturesEXT dynamic3;
    VkCommandPoolCreateInfo pool_info; VkCommandBufferAllocateInfo commands; VkCommandBuffer frame_commands[MQ_VK_FRAMES];
    VkFenceCreateInfo fence; VkSemaphoreCreateInfo semaphore; VkDescriptorPoolSize pool_size; VkDescriptorPoolCreateInfo descriptor_pool;
    mq_u32 i;
    mq_vulkan_shutdown();
    if (window == MQ_NULL || width < 1 || height < 1 || !mq_vk_load()) return 0;
    memset(&app, 0, sizeof(app)); app.sType = VK_STRUCTURE_TYPE_APPLICATION_INFO; app.pApplicationName = "MiniQuake"; app.applicationVersion = VK_MAKE_API_VERSION(0, 1, 9, 0); app.pEngineName = "MiniLang"; app.apiVersion = VK_API_VERSION_1_3;
    memset(&instance_info, 0, sizeof(instance_info)); instance_info.sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO; instance_info.pApplicationInfo = &app; instance_info.enabledExtensionCount = 2u; instance_info.ppEnabledExtensionNames = instance_extensions;
    if (mq_vkCreateInstance(&instance_info, MQ_NULL, &mq_vk_instance) != VK_SUCCESS) goto fail;
    MQ_VK_INSTANCE(DestroyInstance); MQ_VK_INSTANCE(EnumeratePhysicalDevices); MQ_VK_INSTANCE(GetPhysicalDeviceProperties); MQ_VK_INSTANCE(GetPhysicalDeviceFeatures2); MQ_VK_INSTANCE(GetPhysicalDeviceQueueFamilyProperties); MQ_VK_INSTANCE(GetPhysicalDeviceMemoryProperties); MQ_VK_INSTANCE(EnumerateDeviceExtensionProperties); MQ_VK_INSTANCE(CreateWin32SurfaceKHR); MQ_VK_INSTANCE(DestroySurfaceKHR); MQ_VK_INSTANCE(GetPhysicalDeviceSurfaceSupportKHR); MQ_VK_INSTANCE(GetPhysicalDeviceSurfaceCapabilitiesKHR); MQ_VK_INSTANCE(GetPhysicalDeviceSurfaceFormatsKHR); MQ_VK_INSTANCE(GetPhysicalDeviceSurfacePresentModesKHR); MQ_VK_INSTANCE(CreateDevice);
    memset(&surface_info, 0, sizeof(surface_info)); surface_info.sType = VK_STRUCTURE_TYPE_WIN32_SURFACE_CREATE_INFO_KHR; surface_info.hinstance = (MQ_HINSTANCE)GetModuleHandleW(MQ_NULL); surface_info.hwnd = window;
    if (mq_vkCreateWin32SurfaceKHR(mq_vk_instance, &surface_info, MQ_NULL, &mq_vk_surface) != VK_SUCCESS) goto fail;
    if (mq_vkEnumeratePhysicalDevices(mq_vk_instance, &physical_count, physicals) != VK_SUCCESS) goto fail;
    for (physical_index = 0u; physical_index < physical_count; ++physical_index) {
        VkQueueFamilyProperties queues[32]; mq_u32 queue_count = 32u; VkExtensionProperties extensions[128]; mq_u32 extension_count = 128u;
        mq_vkGetPhysicalDeviceQueueFamilyProperties(physicals[physical_index], &queue_count, queues);
        mq_vkEnumerateDeviceExtensionProperties(physicals[physical_index], MQ_NULL, &extension_count, extensions);
        if (!mq_vk_extension(extensions, extension_count, VK_KHR_SWAPCHAIN_EXTENSION_NAME) || !mq_vk_extension(extensions, extension_count, VK_EXT_EXTENDED_DYNAMIC_STATE_EXTENSION_NAME) || !mq_vk_extension(extensions, extension_count, VK_EXT_EXTENDED_DYNAMIC_STATE_3_EXTENSION_NAME)) continue;
        for (i = 0u; i < queue_count; ++i) { VkBool32 present = VK_FALSE; mq_vkGetPhysicalDeviceSurfaceSupportKHR(physicals[physical_index], i, mq_vk_surface, &present); if ((queues[i].queueFlags & VK_QUEUE_GRAPHICS_BIT) != 0u && present) { mq_vk_physical = physicals[physical_index]; mq_vk_queue_family = i; break; } }
        if (mq_vk_physical != VK_NULL_HANDLE) break;
    }
    if (mq_vk_physical == VK_NULL_HANDLE) goto fail;
    { VkPhysicalDeviceProperties properties; mq_vkGetPhysicalDeviceProperties(mq_vk_physical, &properties); memcpy(mq_vk_device_name, properties.deviceName, sizeof(mq_vk_device_name)); mq_vk_max_sampler_anisotropy = properties.limits.maxSamplerAnisotropy; }
    memset(&features, 0, sizeof(features)); memset(&features13, 0, sizeof(features13)); memset(&dynamic1, 0, sizeof(dynamic1)); memset(&dynamic3, 0, sizeof(dynamic3));
    features.sType = VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FEATURES_2; features.pNext = &features13; features13.sType = VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_3_FEATURES; features13.pNext = &dynamic1; dynamic1.sType = VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_EXTENDED_DYNAMIC_STATE_FEATURES_EXT; dynamic1.pNext = &dynamic3; dynamic3.sType = VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_EXTENDED_DYNAMIC_STATE_3_FEATURES_EXT;
    mq_vkGetPhysicalDeviceFeatures2(mq_vk_physical, &features);
    if (!features13.dynamicRendering || !dynamic1.extendedDynamicState || !dynamic3.extendedDynamicState3PolygonMode || !dynamic3.extendedDynamicState3ColorBlendEnable || !dynamic3.extendedDynamicState3ColorBlendEquation) goto fail;
    features13.pNext = &dynamic1; dynamic1.pNext = &dynamic3; dynamic3.pNext = MQ_NULL;
    memset(&queue_info, 0, sizeof(queue_info)); queue_info.sType = VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO; queue_info.queueFamilyIndex = mq_vk_queue_family; queue_info.queueCount = 1u; queue_info.pQueuePriorities = &priority;
    memset(&enabled_features, 0, sizeof(enabled_features)); enabled_features.fillModeNonSolid = features.features.fillModeNonSolid; enabled_features.samplerAnisotropy = features.features.samplerAnisotropy; mq_vk_sampler_anisotropy_enabled = enabled_features.samplerAnisotropy != VK_FALSE;
    memset(&device_info, 0, sizeof(device_info)); device_info.sType = VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO; device_info.pNext = &features13; device_info.pEnabledFeatures = &enabled_features; device_info.queueCreateInfoCount = 1u; device_info.pQueueCreateInfos = &queue_info; device_info.enabledExtensionCount = 3u; device_info.ppEnabledExtensionNames = device_extensions;
    if (mq_vkCreateDevice(mq_vk_physical, &device_info, MQ_NULL, &mq_vk_device) != VK_SUCCESS) goto fail;
    mq_vk_get_device_proc = (PFN_vkGetDeviceProcAddr)mq_vk_get_instance_proc(mq_vk_instance, "vkGetDeviceProcAddr"); if (mq_vk_get_device_proc == MQ_NULL) goto fail;
    MQ_VK_DEVICE(DestroyDevice); MQ_VK_DEVICE(GetDeviceQueue); MQ_VK_DEVICE(DeviceWaitIdle); MQ_VK_DEVICE(QueueSubmit); MQ_VK_DEVICE(QueuePresentKHR); MQ_VK_DEVICE(CreateSwapchainKHR); MQ_VK_DEVICE(DestroySwapchainKHR); MQ_VK_DEVICE(GetSwapchainImagesKHR); MQ_VK_DEVICE(AcquireNextImageKHR); MQ_VK_DEVICE(CreateImageView); MQ_VK_DEVICE(DestroyImageView); MQ_VK_DEVICE(CreateCommandPool); MQ_VK_DEVICE(DestroyCommandPool); MQ_VK_DEVICE(AllocateCommandBuffers); MQ_VK_DEVICE(FreeCommandBuffers); MQ_VK_DEVICE(ResetCommandPool); MQ_VK_DEVICE(ResetCommandBuffer); MQ_VK_DEVICE(BeginCommandBuffer); MQ_VK_DEVICE(EndCommandBuffer); MQ_VK_DEVICE(CreateFence); MQ_VK_DEVICE(DestroyFence); MQ_VK_DEVICE(WaitForFences); MQ_VK_DEVICE(ResetFences); MQ_VK_DEVICE(CreateSemaphore); MQ_VK_DEVICE(DestroySemaphore); MQ_VK_DEVICE(CreateBuffer); MQ_VK_DEVICE(DestroyBuffer); MQ_VK_DEVICE(GetBufferMemoryRequirements); MQ_VK_DEVICE(AllocateMemory); MQ_VK_DEVICE(FreeMemory); MQ_VK_DEVICE(BindBufferMemory); MQ_VK_DEVICE(MapMemory); MQ_VK_DEVICE(UnmapMemory); MQ_VK_DEVICE(CreateImage); MQ_VK_DEVICE(DestroyImage); MQ_VK_DEVICE(GetImageMemoryRequirements); MQ_VK_DEVICE(BindImageMemory); MQ_VK_DEVICE(CreateSampler); MQ_VK_DEVICE(DestroySampler); MQ_VK_DEVICE(CreateDescriptorSetLayout); MQ_VK_DEVICE(DestroyDescriptorSetLayout); MQ_VK_DEVICE(CreateDescriptorPool); MQ_VK_DEVICE(DestroyDescriptorPool); MQ_VK_DEVICE(AllocateDescriptorSets); MQ_VK_DEVICE(UpdateDescriptorSets); MQ_VK_DEVICE(CreatePipelineLayout); MQ_VK_DEVICE(DestroyPipelineLayout); MQ_VK_DEVICE(CreateShaderModule); MQ_VK_DEVICE(DestroyShaderModule); MQ_VK_DEVICE(CreateGraphicsPipelines); MQ_VK_DEVICE(DestroyPipeline); MQ_VK_DEVICE(CmdPipelineBarrier); MQ_VK_DEVICE(CmdCopyBufferToImage); MQ_VK_DEVICE(CmdCopyImageToBuffer); MQ_VK_DEVICE(CmdBeginRendering); MQ_VK_DEVICE(CmdEndRendering); MQ_VK_DEVICE(CmdBindPipeline); MQ_VK_DEVICE(CmdBindDescriptorSets); MQ_VK_DEVICE(CmdBindVertexBuffers); MQ_VK_DEVICE(CmdPushConstants); MQ_VK_DEVICE(CmdSetViewport); MQ_VK_DEVICE(CmdSetScissor); MQ_VK_DEVICE(CmdSetCullMode); MQ_VK_DEVICE(CmdSetFrontFace); MQ_VK_DEVICE(CmdSetPrimitiveTopology); MQ_VK_DEVICE(CmdSetDepthTestEnable); MQ_VK_DEVICE(CmdSetDepthWriteEnable); MQ_VK_DEVICE(CmdSetDepthCompareOp); MQ_VK_DEVICE(CmdSetPolygonModeEXT); MQ_VK_DEVICE(CmdSetColorBlendEnableEXT); MQ_VK_DEVICE(CmdSetColorBlendEquationEXT); MQ_VK_DEVICE(CmdDraw);
    mq_vkGetDeviceQueue(mq_vk_device, mq_vk_queue_family, 0u, &mq_vk_queue); mq_vkGetPhysicalDeviceMemoryProperties(mq_vk_physical, &mq_vk_memory);
    memset(&pool_info, 0, sizeof(pool_info)); pool_info.sType = VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO; pool_info.flags = VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT; pool_info.queueFamilyIndex = mq_vk_queue_family; if (mq_vkCreateCommandPool(mq_vk_device, &pool_info, MQ_NULL, &mq_vk_command_pool) != VK_SUCCESS) goto fail;
    if (!mq_vk_create_swapchain(width, height)) goto fail;
    if (!mq_vk_create_pipeline()) goto fail;
    memset(&pool_size, 0, sizeof(pool_size)); pool_size.type = VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER; pool_size.descriptorCount = MQ_VK_MAX_TEXTURES + 1u;
    memset(&descriptor_pool, 0, sizeof(descriptor_pool)); descriptor_pool.sType = VK_STRUCTURE_TYPE_DESCRIPTOR_POOL_CREATE_INFO; descriptor_pool.maxSets = MQ_VK_MAX_TEXTURES + 1u; descriptor_pool.poolSizeCount = 1u; descriptor_pool.pPoolSizes = &pool_size; if (mq_vkCreateDescriptorPool(mq_vk_device, &descriptor_pool, MQ_NULL, &mq_vk_descriptor_pool) != VK_SUCCESS) goto fail;
    memset(&commands, 0, sizeof(commands)); commands.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO; commands.commandPool = mq_vk_command_pool; commands.level = VK_COMMAND_BUFFER_LEVEL_PRIMARY; commands.commandBufferCount = MQ_VK_FRAMES; if (mq_vkAllocateCommandBuffers(mq_vk_device, &commands, frame_commands) != VK_SUCCESS) goto fail; for (i = 0u; i < MQ_VK_FRAMES; ++i) mq_vk_frames[i].command = frame_commands[i];
    memset(&fence, 0, sizeof(fence)); fence.sType = VK_STRUCTURE_TYPE_FENCE_CREATE_INFO; fence.flags = VK_FENCE_CREATE_SIGNALED_BIT; memset(&semaphore, 0, sizeof(semaphore)); semaphore.sType = VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO;
    for (i = 0u; i < MQ_VK_FRAMES; ++i) { if (mq_vkCreateFence(mq_vk_device, &fence, MQ_NULL, &mq_vk_frames[i].fence) != VK_SUCCESS || mq_vkCreateSemaphore(mq_vk_device, &semaphore, MQ_NULL, &mq_vk_frames[i].acquired) != VK_SUCCESS || mq_vkCreateSemaphore(mq_vk_device, &semaphore, MQ_NULL, &mq_vk_frames[i].complete) != VK_SUCCESS) goto fail; if (!mq_vk_create_buffer(MQ_VK_MAX_VERTICES * sizeof(mq_vk_vertex_t), VK_BUFFER_USAGE_VERTEX_BUFFER_BIT, VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT, &mq_vk_frames[i].vertex_buffer, &mq_vk_frames[i].vertex_memory, (void **)&mq_vk_frames[i].vertices)) goto fail; mq_vk_frames[i].image_index = MQ_VK_PRESENT_IMAGE_INVALID; }
    mq_vk_staging_size = 64u * 1024u * 1024u; if (!mq_vk_create_buffer(mq_vk_staging_size, VK_BUFFER_USAGE_TRANSFER_SRC_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT, VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT, &mq_vk_staging_buffer, &mq_vk_staging_memory, (void **)&mq_vk_staging)) goto fail;
    mq_vk_identity(mq_vk_modelview[0]); mq_vk_identity(mq_vk_projection[0]); mq_vk_clear_color.float32[3] = 1.0f;
    if (!mq_vk_create_white()) goto fail;
    return 1;
fail:
    mq_vulkan_shutdown(); return 0;
}

/* Release resources owned by shutdown. */
void mq_vulkan_shutdown(void) {
    mq_u32 i;
    if (mq_vk_device != VK_NULL_HANDLE) mq_vkDeviceWaitIdle(mq_vk_device);
    for (i = 0u; i < MQ_VK_MAX_TEXTURES; ++i) mq_vk_destroy_texture(&mq_vk_textures[i]);
    mq_vk_destroy_texture(&mq_vk_white_texture);
    if (mq_vk_staging != MQ_NULL) mq_vkUnmapMemory(mq_vk_device, mq_vk_staging_memory);
    if (mq_vk_staging_buffer != VK_NULL_HANDLE) mq_vkDestroyBuffer(mq_vk_device, mq_vk_staging_buffer, MQ_NULL);
    if (mq_vk_staging_memory != VK_NULL_HANDLE) mq_vkFreeMemory(mq_vk_device, mq_vk_staging_memory, MQ_NULL);
    for (i = 0u; i < MQ_VK_FRAMES; ++i) { if (mq_vk_frames[i].vertices != MQ_NULL) mq_vkUnmapMemory(mq_vk_device, mq_vk_frames[i].vertex_memory); if (mq_vk_frames[i].vertex_buffer != VK_NULL_HANDLE) mq_vkDestroyBuffer(mq_vk_device, mq_vk_frames[i].vertex_buffer, MQ_NULL); if (mq_vk_frames[i].vertex_memory != VK_NULL_HANDLE) mq_vkFreeMemory(mq_vk_device, mq_vk_frames[i].vertex_memory, MQ_NULL); if (mq_vk_frames[i].fence != VK_NULL_HANDLE) mq_vkDestroyFence(mq_vk_device, mq_vk_frames[i].fence, MQ_NULL); if (mq_vk_frames[i].acquired != VK_NULL_HANDLE) mq_vkDestroySemaphore(mq_vk_device, mq_vk_frames[i].acquired, MQ_NULL); if (mq_vk_frames[i].complete != VK_NULL_HANDLE) mq_vkDestroySemaphore(mq_vk_device, mq_vk_frames[i].complete, MQ_NULL); }
    if (mq_vk_pipeline != VK_NULL_HANDLE) mq_vkDestroyPipeline(mq_vk_device, mq_vk_pipeline, MQ_NULL);
    if (mq_vk_pipeline_layout != VK_NULL_HANDLE) mq_vkDestroyPipelineLayout(mq_vk_device, mq_vk_pipeline_layout, MQ_NULL);
    if (mq_vk_descriptor_pool != VK_NULL_HANDLE) mq_vkDestroyDescriptorPool(mq_vk_device, mq_vk_descriptor_pool, MQ_NULL);
    if (mq_vk_descriptor_layout != VK_NULL_HANDLE) mq_vkDestroyDescriptorSetLayout(mq_vk_device, mq_vk_descriptor_layout, MQ_NULL);
    mq_vk_destroy_swapchain();
    if (mq_vk_command_pool != VK_NULL_HANDLE) mq_vkDestroyCommandPool(mq_vk_device, mq_vk_command_pool, MQ_NULL);
    if (mq_vk_device != VK_NULL_HANDLE) mq_vkDestroyDevice(mq_vk_device, MQ_NULL);
    if (mq_vk_surface != VK_NULL_HANDLE) mq_vkDestroySurfaceKHR(mq_vk_instance, mq_vk_surface, MQ_NULL);
    if (mq_vk_instance != VK_NULL_HANDLE) mq_vkDestroyInstance(mq_vk_instance, MQ_NULL);
    memset(mq_vk_frames, 0, sizeof(mq_vk_frames)); memset(mq_vk_textures, 0, sizeof(mq_vk_textures)); memset(&mq_vk_white_texture, 0, sizeof(mq_vk_white_texture));
    mq_vk_instance = VK_NULL_HANDLE; mq_vk_device = VK_NULL_HANDLE; mq_vk_physical = VK_NULL_HANDLE; mq_vk_surface = VK_NULL_HANDLE; mq_vk_queue = VK_NULL_HANDLE; mq_vk_command_pool = VK_NULL_HANDLE; mq_vk_pipeline = VK_NULL_HANDLE; mq_vk_pipeline_layout = VK_NULL_HANDLE; mq_vk_descriptor_pool = VK_NULL_HANDLE; mq_vk_descriptor_layout = VK_NULL_HANDLE; mq_vk_staging = MQ_NULL; mq_vk_staging_buffer = VK_NULL_HANDLE; mq_vk_staging_memory = VK_NULL_HANDLE; mq_vk_staging_size = 0u; mq_vk_next_texture = 1u; mq_vk_bound_texture = 0u;
    mq_vk_enhanced_enabled = 0; mq_vk_enhanced_draw_kind_value = 0; mq_vk_enhanced_light_count = 0;
    memset(mq_vk_enhanced_view, 0, sizeof(mq_vk_enhanced_view));
    memset(mq_vk_enhanced_lights, 0, sizeof(mq_vk_enhanced_lights));
}

/* Report whether ready is available. */
mq_i32 mq_vulkan_ready(void) { return mq_vk_device != VK_NULL_HANDLE && mq_vk_swapchain != VK_NULL_HANDLE; }

/* Resize or recreate backend presentation resources. */
mq_i32 mq_vulkan_resize(mq_i32 width, mq_i32 height) {
    if (mq_vk_device == VK_NULL_HANDLE || width < 1 || height < 1) return 0;
    mq_vk_destroy_swapchain();
    if (!mq_vk_create_swapchain(width, height)) return 0;
    return 1;
}

/* Acquire the next swap-chain image and begin recording its frame. */
static mq_i32 mq_vk_frame_begin(void) {
    mq_vk_frame_t *frame = &mq_vk_frames[mq_vk_frame_index];
    VkCommandBufferBeginInfo begin;
    VkRenderingAttachmentInfo color, depth;
    VkRenderingInfo rendering;
    VkViewport viewport;
    VkRect2D scissor;
    VkResult result;
    if (frame->recording) return 1;
    result = mq_vkWaitForFences(mq_vk_device, 1u, &frame->fence, VK_TRUE, ~(mq_u64)0u);
    if (result != VK_SUCCESS) { mq_vk_last_error = result; return 0; }
    result = mq_vkAcquireNextImageKHR(mq_vk_device, mq_vk_swapchain, ~(mq_u64)0u, frame->acquired, VK_NULL_HANDLE, &frame->image_index);
    if (result == VK_ERROR_OUT_OF_DATE_KHR) { if (!mq_vulkan_resize(mq_vk_width, mq_vk_height)) return 0; return mq_vk_frame_begin(); }
    if (result != VK_SUCCESS && result != VK_SUBOPTIMAL_KHR) return 0;
    if (mq_vkResetCommandBuffer(frame->command, 0u) != VK_SUCCESS) return 0;
    memset(&begin, 0, sizeof(begin)); begin.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO; begin.flags = VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT; if (mq_vkBeginCommandBuffer(frame->command, &begin) != VK_SUCCESS) return 0;
    mq_vk_image_barrier(frame->command, mq_vk_images[frame->image_index], VK_IMAGE_ASPECT_COLOR_BIT, 0u, 1u, mq_vk_image_initialized[frame->image_index] ? VK_IMAGE_LAYOUT_PRESENT_SRC_KHR : VK_IMAGE_LAYOUT_UNDEFINED, VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL, mq_vk_image_initialized[frame->image_index] ? VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT : VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT, VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT, 0u, VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT);
    mq_vk_image_barrier(frame->command, mq_vk_depth_image, VK_IMAGE_ASPECT_DEPTH_BIT, 0u, 1u, VK_IMAGE_LAYOUT_UNDEFINED, VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL, VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT, VK_PIPELINE_STAGE_EARLY_FRAGMENT_TESTS_BIT, 0u, VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT);
    memset(&color, 0, sizeof(color)); color.sType = VK_STRUCTURE_TYPE_RENDERING_ATTACHMENT_INFO; color.imageView = mq_vk_image_views[frame->image_index]; color.imageLayout = VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL; color.loadOp = ((mq_vk_clear_mask & MQ_GL_COLOR_BUFFER_BIT) || !mq_vk_image_initialized[frame->image_index]) ? VK_ATTACHMENT_LOAD_OP_CLEAR : VK_ATTACHMENT_LOAD_OP_LOAD; color.storeOp = VK_ATTACHMENT_STORE_OP_STORE; color.clearValue.color = mq_vk_clear_color;
    /* GLQuake's z-trick preserves alternate depth ranges instead of clearing.
     * Vulkan uses one depth attachment for the swapchain, so clear to the
     * compare-appropriate extreme each frame: visually equivalent and free
     * of cross-frame depth hazards. */
    memset(&depth, 0, sizeof(depth)); depth.sType = VK_STRUCTURE_TYPE_RENDERING_ATTACHMENT_INFO; depth.imageView = mq_vk_depth_view; depth.imageLayout = VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL; depth.loadOp = VK_ATTACHMENT_LOAD_OP_CLEAR; depth.storeOp = VK_ATTACHMENT_STORE_OP_STORE; depth.clearValue.depthStencil.depth = mq_vk_depth_function == MQ_GL_GEQUAL ? 0.0f : 1.0f;
    memset(&rendering, 0, sizeof(rendering)); rendering.sType = VK_STRUCTURE_TYPE_RENDERING_INFO; rendering.renderArea.extent = mq_vk_extent; rendering.layerCount = 1u; rendering.colorAttachmentCount = 1u; rendering.pColorAttachments = &color; rendering.pDepthAttachment = &depth;
    mq_vkCmdBeginRendering(frame->command, &rendering); frame->rendering = 1; frame->recording = 1; frame->vertex_count = 0u;
    /* glClear is a command, not persistent state. Calls made before the first
     * draw select this frame's attachment load operations and are consumed
     * here; keeping the bits set would clear every later frame red. */
    mq_vk_clear_mask = 0u;
    mq_vkCmdBindPipeline(frame->command, VK_PIPELINE_BIND_POINT_GRAPHICS, mq_vk_pipeline);
    viewport.x = 0.0f; viewport.y = 0.0f; viewport.width = (float)mq_vk_extent.width; viewport.height = (float)mq_vk_extent.height; viewport.minDepth = 0.0f; viewport.maxDepth = 1.0f; mq_vkCmdSetViewport(frame->command, 0u, 1u, &viewport);
    scissor.offset.x = 0; scissor.offset.y = 0; scissor.extent = mq_vk_extent; mq_vkCmdSetScissor(frame->command, 0u, 1u, &scissor);
    return 1;
}

/* Translate a GL blend-factor token to its Vulkan equivalent. */
static VkBlendFactor mq_vk_blend_factor(mq_u32 value) {
    if (value == MQ_GL_ZERO) return VK_BLEND_FACTOR_ZERO; if (value == MQ_GL_ONE) return VK_BLEND_FACTOR_ONE; if (value == MQ_GL_SRC_COLOR) return VK_BLEND_FACTOR_SRC_COLOR; if (value == MQ_GL_ONE_MINUS_SRC_COLOR) return VK_BLEND_FACTOR_ONE_MINUS_SRC_COLOR; if (value == MQ_GL_SRC_ALPHA) return VK_BLEND_FACTOR_SRC_ALPHA; if (value == MQ_GL_ONE_MINUS_SRC_ALPHA) return VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA; if (value == MQ_GL_DST_COLOR) return VK_BLEND_FACTOR_DST_COLOR; if (value == MQ_GL_ONE_MINUS_DST_COLOR) return VK_BLEND_FACTOR_ONE_MINUS_DST_COLOR; return VK_BLEND_FACTOR_ONE;
}

/* Translate a GL comparison token to its Vulkan equivalent. */
static VkCompareOp mq_vk_compare(mq_u32 value) { if (value == MQ_GL_LEQUAL) return VK_COMPARE_OP_LESS_OR_EQUAL; if (value == MQ_GL_GEQUAL) return VK_COMPARE_OP_GREATER_OR_EQUAL; if (value == MQ_GL_GREATER) return VK_COMPARE_OP_GREATER; return VK_COMPARE_OP_LESS; }

/* Translate the active GL primitive mode to Vulkan topology. */
static VkPrimitiveTopology mq_vk_topology(mq_u32 mode) { if (mode == MQ_GL_POINTS) return VK_PRIMITIVE_TOPOLOGY_POINT_LIST; if (mode == MQ_GL_LINES) return VK_PRIMITIVE_TOPOLOGY_LINE_LIST; if (mode == MQ_GL_LINE_STRIP || mode == MQ_GL_LINE_LOOP) return VK_PRIMITIVE_TOPOLOGY_LINE_STRIP; if (mode == MQ_GL_TRIANGLE_STRIP) return VK_PRIMITIVE_TOPOLOGY_TRIANGLE_STRIP; return VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST; }

/* Submit draw geometry to the active backend command buffer. */
static mq_i32 mq_vk_draw(const mq_vk_vertex_t *vertices, mq_u32 count, mq_u32 mode) {
    mq_vk_frame_t *frame = &mq_vk_frames[mq_vk_frame_index];
    mq_vk_push_t push;
    VkDeviceSize offset;
    VkViewport viewport;
    VkRect2D scissor;
    VkBool32 blend;
    VkColorBlendEquationEXT equation;
    mq_vk_texture_t *texture;
    mq_i32 enhanced_draw;
    mq_u32 vertex_index;
    if (vertices == MQ_NULL || count == 0u) return 0;
    enhanced_draw = mq_vk_enhanced_enabled && mq_vk_enhanced_draw_kind_value != 0;
    if (!mq_vk_frame_begin() || count > MQ_VK_MAX_VERTICES - frame->vertex_count) return 0;
    if (enhanced_draw) {
        const float *matrix = mq_vk_modelview[mq_vk_modelview_top];
        for (vertex_index = 0u; vertex_index < count; ++vertex_index) {
            const mq_vk_vertex_t *source = &vertices[vertex_index];
            mq_vk_vertex_t *destination = &frame->vertices[frame->vertex_count + vertex_index];
            *destination = *source;
            destination->x = matrix[0] * source->x + matrix[4] * source->y + matrix[8] * source->z + matrix[12];
            destination->y = matrix[1] * source->x + matrix[5] * source->y + matrix[9] * source->z + matrix[13];
            destination->z = matrix[2] * source->x + matrix[6] * source->y + matrix[10] * source->z + matrix[14];
        }
    } else {
        memcpy(&frame->vertices[frame->vertex_count], vertices, count * sizeof(mq_vk_vertex_t));
    }
    offset = frame->vertex_count * sizeof(mq_vk_vertex_t);
    mq_vkCmdBindVertexBuffers(frame->command, 0u, 1u, &frame->vertex_buffer, &offset);
    memset(&push, 0, sizeof(push));
    if (enhanced_draw) memcpy(push.transform, mq_vk_projection[mq_vk_projection_top], sizeof(push.transform));
    else mq_vk_multiply(push.transform, mq_vk_projection[mq_vk_projection_top], mq_vk_modelview[mq_vk_modelview_top]);
    if (enhanced_draw && mq_vk_enhanced_light_count > 2) {
        memcpy(push.alpha_reference, &mq_vk_enhanced_lights[8], 4u * sizeof(float));
    } else {
        push.alpha_reference[0] = mq_vk_alpha_reference; push.alpha_reference[1] = (float)mq_vk_alpha_test; push.alpha_reference[2] = (float)mq_vk_texture_enabled; push.alpha_reference[3] = mq_vk_texture_environment == MQ_GL_MODULATE ? 1.0f : 0.0f;
    }
    push.depth_range[0] = mq_vk_depth_min; push.depth_range[1] = mq_vk_depth_max; push.depth_range[2] = (float)enhanced_draw; push.depth_range[3] = (float)mq_vk_enhanced_light_count; memcpy(push.lights, mq_vk_enhanced_lights, sizeof(push.lights));
    mq_vkCmdPushConstants(frame->command, mq_vk_pipeline_layout, VK_SHADER_STAGE_VERTEX_BIT | VK_SHADER_STAGE_FRAGMENT_BIT, 0u, sizeof(push), &push);
    texture = mq_vk_bound_texture < MQ_VK_MAX_TEXTURES && mq_vk_textures[mq_vk_bound_texture].allocated && mq_vk_textures[mq_vk_bound_texture].image != VK_NULL_HANDLE ? &mq_vk_textures[mq_vk_bound_texture] : &mq_vk_white_texture;
    mq_vkCmdBindDescriptorSets(frame->command, VK_PIPELINE_BIND_POINT_GRAPHICS, mq_vk_pipeline_layout, 0u, 1u, &texture->descriptor, 0u, MQ_NULL);
    viewport.x = (float)mq_vk_viewport_x; viewport.y = (float)(mq_vk_height - mq_vk_viewport_y); viewport.width = (float)mq_vk_viewport_width; viewport.height = -(float)mq_vk_viewport_height; viewport.minDepth = 0.0f; viewport.maxDepth = 1.0f; mq_vkCmdSetViewport(frame->command, 0u, 1u, &viewport);
    scissor.offset.x = mq_vk_viewport_x < 0 ? 0 : mq_vk_viewport_x; scissor.offset.y = mq_vk_height - mq_vk_viewport_y - mq_vk_viewport_height; if (scissor.offset.y < 0) scissor.offset.y = 0; scissor.extent.width = (mq_u32)(mq_vk_viewport_width < 1 ? 1 : mq_vk_viewport_width); scissor.extent.height = (mq_u32)(mq_vk_viewport_height < 1 ? 1 : mq_vk_viewport_height); mq_vkCmdSetScissor(frame->command, 0u, 1u, &scissor);
    mq_vkCmdSetPrimitiveTopology(frame->command, mq_vk_topology(mode));
    /* GLQuake's projection and Vulkan's negative-height viewport disagree on
       framebuffer winding.  Conservative no-cull avoids missing front faces. */
    mq_vkCmdSetCullMode(frame->command, VK_CULL_MODE_NONE);
    mq_vkCmdSetFrontFace(frame->command, VK_FRONT_FACE_CLOCKWISE); mq_vkCmdSetDepthTestEnable(frame->command, mq_vk_depth_test); mq_vkCmdSetDepthWriteEnable(frame->command, mq_vk_depth_write); mq_vkCmdSetDepthCompareOp(frame->command, mq_vk_compare(mq_vk_depth_function)); mq_vkCmdSetPolygonModeEXT(frame->command, mq_vk_polygon_mode == MQ_GL_LINE ? VK_POLYGON_MODE_LINE : VK_POLYGON_MODE_FILL);
    blend = (VkBool32)mq_vk_blend; mq_vkCmdSetColorBlendEnableEXT(frame->command, 0u, 1u, &blend); memset(&equation, 0, sizeof(equation)); equation.srcColorBlendFactor = mq_vk_blend_factor(mq_vk_blend_source); equation.dstColorBlendFactor = mq_vk_blend_factor(mq_vk_blend_destination); equation.colorBlendOp = VK_BLEND_OP_ADD; equation.srcAlphaBlendFactor = equation.srcColorBlendFactor; equation.dstAlphaBlendFactor = equation.dstColorBlendFactor; equation.alphaBlendOp = VK_BLEND_OP_ADD; mq_vkCmdSetColorBlendEquationEXT(frame->command, 0u, 1u, &equation);
    mq_vkCmdDraw(frame->command, count, 1u, 0u, 0u); frame->vertex_count += count; return 1;
}

/* Present the completed back buffer to the window. */
void mq_vulkan_present(void) {
    mq_vk_frame_t *frame = &mq_vk_frames[mq_vk_frame_index];
    VkSubmitInfo submit; VkPresentInfoKHR present; VkPipelineStageFlags wait = VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT; VkResult result;
    if (!frame->recording && !mq_vk_frame_begin()) return;
    if (frame->rendering) { mq_vkCmdEndRendering(frame->command); frame->rendering = 0; }
    mq_vk_image_barrier(frame->command, mq_vk_images[frame->image_index], VK_IMAGE_ASPECT_COLOR_BIT, 0u, 1u, VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL, VK_IMAGE_LAYOUT_PRESENT_SRC_KHR, VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT, VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT, VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT, 0u);
    result = mq_vkEndCommandBuffer(frame->command);
    if (result != VK_SUCCESS) { mq_vk_last_error = result; return; }
    memset(&submit, 0, sizeof(submit)); submit.sType = VK_STRUCTURE_TYPE_SUBMIT_INFO; submit.waitSemaphoreCount = 1u; submit.pWaitSemaphores = &frame->acquired; submit.pWaitDstStageMask = &wait; submit.commandBufferCount = 1u; submit.pCommandBuffers = &frame->command; submit.signalSemaphoreCount = 1u; submit.pSignalSemaphores = &frame->complete;
    result = mq_vkResetFences(mq_vk_device, 1u, &frame->fence);
    if (result != VK_SUCCESS) { mq_vk_last_error = result; return; }
    result = mq_vkQueueSubmit(mq_vk_queue, 1u, &submit, frame->fence);
    if (result != VK_SUCCESS) { mq_vk_last_error = result; return; }
    memset(&present, 0, sizeof(present)); present.sType = VK_STRUCTURE_TYPE_PRESENT_INFO_KHR; present.waitSemaphoreCount = 1u; present.pWaitSemaphores = &frame->complete; present.swapchainCount = 1u; present.pSwapchains = &mq_vk_swapchain; present.pImageIndices = &frame->image_index;
    result = mq_vkQueuePresentKHR(mq_vk_queue, &present); mq_vk_image_initialized[frame->image_index] = 1; frame->recording = 0; frame->image_index = MQ_VK_PRESENT_IMAGE_INVALID; mq_vk_frame_index = (mq_vk_frame_index + 1u) % MQ_VK_FRAMES;
    if (result == VK_ERROR_OUT_OF_DATE_KHR || result == VK_SUBOPTIMAL_KHR) mq_vulkan_resize(mq_vk_width, mq_vk_height);
}

/* Begin collecting immediate-mode vertices for one draw. */
void mq_vulkan_begin(mq_u32 mode) { mq_vk_primitive_mode = mode; mq_vk_immediate_count = 0u; }
/* Append one vertex with the current immediate-mode attributes. */
static void mq_vk_add(float x, float y, float z) { mq_vk_vertex_t *vertex; if (mq_vk_immediate_count >= 65536u) return; vertex = &mq_vk_immediate[mq_vk_immediate_count++]; vertex->x = x; vertex->y = y; vertex->z = z; vertex->s = mq_vk_current_s; vertex->t = mq_vk_current_t; vertex->r = mq_vk_current_color[0]; vertex->g = mq_vk_current_color[1]; vertex->b = mq_vk_current_color[2]; vertex->a = mq_vk_current_color[3]; }
/* Submit the immediate-mode vertices collected for the draw. */
void mq_vulkan_end(void) {
    mq_u32 i, output = 0u;
    if (mq_vk_primitive_mode == MQ_GL_QUADS) for (i = 0u; i + 3u < mq_vk_immediate_count; i += 4u) { mq_vk_expanded[output++] = mq_vk_immediate[i]; mq_vk_expanded[output++] = mq_vk_immediate[i + 1u]; mq_vk_expanded[output++] = mq_vk_immediate[i + 2u]; mq_vk_expanded[output++] = mq_vk_immediate[i]; mq_vk_expanded[output++] = mq_vk_immediate[i + 2u]; mq_vk_expanded[output++] = mq_vk_immediate[i + 3u]; }
    else if (mq_vk_primitive_mode == MQ_GL_POLYGON || mq_vk_primitive_mode == MQ_GL_TRIANGLE_FAN) for (i = 0u; i + 2u < mq_vk_immediate_count; ++i) { mq_vk_expanded[output++] = mq_vk_immediate[0]; mq_vk_expanded[output++] = mq_vk_immediate[i + 1u]; mq_vk_expanded[output++] = mq_vk_immediate[i + 2u]; }
    else if (mq_vk_primitive_mode == MQ_GL_LINE_LOOP && mq_vk_immediate_count > 1u) { memcpy(mq_vk_expanded, mq_vk_immediate, mq_vk_immediate_count * sizeof(mq_vk_vertex_t)); mq_vk_expanded[mq_vk_immediate_count] = mq_vk_immediate[0]; output = mq_vk_immediate_count + 1u; }
    if (output > 0u) mq_vk_draw(mq_vk_expanded, output, mq_vk_primitive_mode == MQ_GL_LINE_LOOP ? MQ_GL_LINE_STRIP : MQ_GL_TRIANGLES); else mq_vk_draw(mq_vk_immediate, mq_vk_immediate_count, mq_vk_primitive_mode);
    mq_vk_immediate_count = 0u;
}

/* Submit draw interleaved t2f v3f geometry to the active backend command buffer. */
mq_i32 mq_vulkan_draw_interleaved_t2f_v3f(const float *vertices, mq_u32 count) { mq_u32 i, first = 0u; if (vertices == MQ_NULL) return 0; while (first < count) { mq_u32 chunk = count - first; if (chunk > 65536u) chunk = 65535u; chunk -= chunk % 3u; for (i = 0u; i < chunk; ++i) { const float *source = &vertices[(first + i) * 5u]; mq_vk_vertex_t *destination = &mq_vk_immediate[i]; destination->x = source[2]; destination->y = source[3]; destination->z = source[4]; destination->s = source[0]; destination->t = source[1]; destination->r = mq_vk_current_color[0]; destination->g = mq_vk_current_color[1]; destination->b = mq_vk_current_color[2]; destination->a = mq_vk_current_color[3]; } mq_vk_draw(mq_vk_immediate, chunk, MQ_GL_TRIANGLES); first += chunk; } return (mq_i32)(count / 3u); }
/* Store the Vulkan backend fields for one vk alias input. */
typedef struct mq_vk_alias_input_s { float s, t; mq_u8 r, g, b, a; float x, y, z; } mq_vk_alias_input_t;
/* Submit draw interleaved t2f c4ub v3f geometry to the active backend command buffer. */
mq_i32 mq_vulkan_draw_interleaved_t2f_c4ub_v3f(const void *vertices, mq_u32 count) { const mq_vk_alias_input_t *source = (const mq_vk_alias_input_t *)vertices; mq_u32 i, first = 0u; if (vertices == MQ_NULL) return 0; while (first < count) { mq_u32 chunk = count - first; if (chunk > 65536u) chunk = 65535u; chunk -= chunk % 3u; for (i = 0u; i < chunk; ++i) { mq_vk_vertex_t *destination = &mq_vk_immediate[i]; destination->x = source[first + i].x; destination->y = source[first + i].y; destination->z = source[first + i].z; destination->s = source[first + i].s; destination->t = source[first + i].t; destination->r = source[first + i].r / 255.0f; destination->g = source[first + i].g / 255.0f; destination->b = source[first + i].b / 255.0f; destination->a = source[first + i].a / 255.0f; } mq_vk_draw(mq_vk_immediate, chunk, MQ_GL_TRIANGLES); first += chunk; } return (mq_i32)(count / 3u); }
/* Update the current immediate-mode vertex attributes. */
void mq_vulkan_vertex2(mq_u32 x, mq_u32 y) { mq_vk_add(mq_vk_bits_float(x), mq_vk_bits_float(y), 0.0f); }
/* Update the current immediate-mode vertex attributes. */
void mq_vulkan_vertex3(mq_u32 x, mq_u32 y, mq_u32 z) { mq_vk_add(mq_vk_bits_float(x), mq_vk_bits_float(y), mq_vk_bits_float(z)); }
/* Update the current immediate-mode texture coordinates. */
void mq_vulkan_texcoord2(mq_u32 s, mq_u32 t) { mq_vk_current_s = mq_vk_bits_float(s); mq_vk_current_t = mq_vk_bits_float(t); }
/* Update the current immediate-mode vertex attributes. */
void mq_vulkan_color4ub(mq_u32 r, mq_u32 g, mq_u32 b, mq_u32 a) { mq_vk_current_color[0] = (r & 255u) / 255.0f; mq_vk_current_color[1] = (g & 255u) / 255.0f; mq_vk_current_color[2] = (b & 255u) / 255.0f; mq_vk_current_color[3] = (a & 255u) / 255.0f; }
/* Update the current immediate-mode vertex attributes. */
void mq_vulkan_clear_color(mq_u32 r, mq_u32 g, mq_u32 b, mq_u32 a) { mq_vk_clear_color.float32[0] = mq_vk_bits_float(r); mq_vk_clear_color.float32[1] = mq_vk_bits_float(g); mq_vk_clear_color.float32[2] = mq_vk_bits_float(b); mq_vk_clear_color.float32[3] = mq_vk_bits_float(a); }
/* Clear the selected buffers or pending native state. */
void mq_vulkan_clear(mq_u32 mask) { mq_vk_clear_mask = mask; }
/* Update the enabled state of enable. */
void mq_vulkan_enable(mq_u32 capability) { if (capability == MQ_GL_TEXTURE_2D) mq_vk_texture_enabled = 1; else if (capability == MQ_GL_DEPTH_TEST) mq_vk_depth_test = 1; else if (capability == MQ_GL_BLEND) mq_vk_blend = 1; else if (capability == MQ_GL_ALPHA_TEST) mq_vk_alpha_test = 1; else if (capability == MQ_GL_CULL_FACE) mq_vk_cull = 1; }
/* Update the enabled state of disable. */
void mq_vulkan_disable(mq_u32 capability) { if (capability == MQ_GL_TEXTURE_2D) mq_vk_texture_enabled = 0; else if (capability == MQ_GL_DEPTH_TEST) mq_vk_depth_test = 0; else if (capability == MQ_GL_BLEND) mq_vk_blend = 0; else if (capability == MQ_GL_ALPHA_TEST) mq_vk_alpha_test = 0; else if (capability == MQ_GL_CULL_FACE) mq_vk_cull = 0; }
/* Update the source and destination blend factors. */
void mq_vulkan_blend_func(mq_u32 source, mq_u32 destination) { mq_vk_blend_source = source; mq_vk_blend_destination = destination; }
/* Update the depth comparison function. */
void mq_vulkan_depth_func(mq_u32 value) { mq_vk_depth_function = value; }
/* Enable or disable depth-buffer writes. */
void mq_vulkan_depth_mask(mq_i32 enabled) { mq_vk_depth_write = enabled != 0; }
/* Clamp and update the viewport depth range. */
void mq_vulkan_depth_range(mq_u32 near_value, mq_u32 far_value) { mq_vk_depth_min = mq_vk_clamp(mq_vk_bits_float(near_value), 0.0f, 1.0f); mq_vk_depth_max = mq_vk_clamp(mq_vk_bits_float(far_value), 0.0f, 1.0f); }
/* Update the alpha-test reference value. */
void mq_vulkan_alpha_func(mq_u32 function_name, mq_u32 reference) { (void)function_name; mq_vk_alpha_reference = mq_vk_clamp(mq_vk_bits_float(reference), 0.0f, 1.0f); }
/* Select which polygon face is culled. */
void mq_vulkan_cull_face(mq_u32 mode) { mq_vk_cull_face_value = mode; }
/* Accept the fixed-function shade-model state. */
void mq_vulkan_shade_model(mq_u32 mode) { (void)mode; }
/* Select the polygon rasterization mode. */
void mq_vulkan_polygon_mode(mq_u32 face, mq_u32 mode) { (void)face; mq_vk_polygon_mode = mode; }
/* Update the backend viewport rectangle. */
void mq_vulkan_viewport(mq_i32 x, mq_i32 y, mq_i32 width, mq_i32 height) { mq_vk_viewport_x = x; mq_vk_viewport_y = y; mq_vk_viewport_width = width; mq_vk_viewport_height = height; }
/* Select the active fixed-function matrix stack. */
void mq_vulkan_matrix_mode(mq_u32 mode) { mq_vk_matrix_mode_value = mode; }
/* Initialize a column-major identity matrix. */
void mq_vulkan_load_identity(void) { mq_vk_identity(mq_vk_current_matrix()); }
/* Submit matrix to the native queue. */
void mq_vulkan_push_matrix(void) { if (mq_vk_matrix_mode_value == MQ_GL_PROJECTION) { if (mq_vk_projection_top + 1u < MQ_VK_MATRIX_STACK) { memcpy(mq_vk_projection[mq_vk_projection_top + 1u], mq_vk_projection[mq_vk_projection_top], 64u); ++mq_vk_projection_top; } } else if (mq_vk_modelview_top + 1u < MQ_VK_MATRIX_STACK) { memcpy(mq_vk_modelview[mq_vk_modelview_top + 1u], mq_vk_modelview[mq_vk_modelview_top], 64u); ++mq_vk_modelview_top; } }
/* Remove matrix from the native queue. */
void mq_vulkan_pop_matrix(void) { if (mq_vk_matrix_mode_value == MQ_GL_PROJECTION) { if (mq_vk_projection_top > 0u) --mq_vk_projection_top; } else if (mq_vk_modelview_top > 0u) --mq_vk_modelview_top; }
/* Postmultiply the current matrix with a translate transform. */
void mq_vulkan_translate(mq_u32 x, mq_u32 y, mq_u32 z) { float matrix[16]; mq_vk_identity(matrix); matrix[12] = mq_vk_bits_float(x); matrix[13] = mq_vk_bits_float(y); matrix[14] = mq_vk_bits_float(z); mq_vk_postmultiply(matrix); }
/* Postmultiply the current matrix with a rotate transform. */
void mq_vulkan_rotate(mq_u32 angle_bits, mq_u32 x_bits, mq_u32 y_bits, mq_u32 z_bits) { float angle = mq_vk_bits_float(angle_bits) * 0.01745329251994329577f; float x = mq_vk_bits_float(x_bits), y = mq_vk_bits_float(y_bits), z = mq_vk_bits_float(z_bits); float length = (float)sqrt(x*x + y*y + z*z); float s = (float)sin(angle), c = (float)cos(angle), one = 1.0f-c; float matrix[16]; if (length == 0.0f) return; x/=length; y/=length; z/=length; mq_vk_identity(matrix); matrix[0]=x*x*one+c; matrix[4]=x*y*one-z*s; matrix[8]=x*z*one+y*s; matrix[1]=y*x*one+z*s; matrix[5]=y*y*one+c; matrix[9]=y*z*one-x*s; matrix[2]=z*x*one-y*s; matrix[6]=z*y*one+x*s; matrix[10]=z*z*one+c; mq_vk_postmultiply(matrix); }
/* Postmultiply the current matrix with a scale transform. */
void mq_vulkan_scale(mq_u32 x, mq_u32 y, mq_u32 z) { float matrix[16]; mq_vk_identity(matrix); matrix[0]=mq_vk_bits_float(x); matrix[5]=mq_vk_bits_float(y); matrix[10]=mq_vk_bits_float(z); mq_vk_postmultiply(matrix); }
/* Postmultiply the current matrix with the requested ortho projection. */
void mq_vulkan_ortho(mq_u32 left_bits, mq_u32 right_bits, mq_u32 bottom_bits, mq_u32 top_bits, mq_u32 near_bits, mq_u32 far_bits) { float l=mq_vk_bits_float(left_bits),r=mq_vk_bits_float(right_bits),b=mq_vk_bits_float(bottom_bits),t=mq_vk_bits_float(top_bits),n=mq_vk_bits_float(near_bits),f=mq_vk_bits_float(far_bits),m[16]; mq_vk_identity(m); m[0]=2.0f/(r-l); m[5]=2.0f/(t-b); m[10]=-2.0f/(f-n); m[12]=-(r+l)/(r-l); m[13]=-(t+b)/(t-b); m[14]=-(f+n)/(f-n); mq_vk_postmultiply(m); }
/* Postmultiply the current matrix with the requested frustum projection. */
void mq_vulkan_frustum(mq_u32 left_bits, mq_u32 right_bits, mq_u32 bottom_bits, mq_u32 top_bits, mq_u32 near_bits, mq_u32 far_bits) { float l=mq_vk_bits_float(left_bits),r=mq_vk_bits_float(right_bits),b=mq_vk_bits_float(bottom_bits),t=mq_vk_bits_float(top_bits),n=mq_vk_bits_float(near_bits),f=mq_vk_bits_float(far_bits),m[16]; memset(m,0,sizeof(m)); m[0]=2.0f*n/(r-l); m[5]=2.0f*n/(t-b); m[8]=(r+l)/(r-l); m[9]=(t+b)/(t-b); m[10]=-(f+n)/(f-n); m[11]=-1.0f; m[14]=-(2.0f*f*n)/(f-n); mq_vk_postmultiply(m); }

/* Bind the selected texture for subsequent draws. */
void mq_vulkan_bind_texture(mq_u32 target, mq_u32 texture) {
    mq_vk_texture_t *entry;
    (void)target;
    mq_vk_bound_texture = texture < MQ_VK_MAX_TEXTURES ? texture : 0u;
    if (mq_vk_bound_texture == 0u) return;
    entry = &mq_vk_textures[mq_vk_bound_texture];
    if (entry->descriptor == VK_NULL_HANDLE && !mq_vk_alloc_descriptor(entry)) {
        mq_vk_bound_texture = 0u;
        return;
    }
    entry->allocated = 1;
}
/* Allocate caller-visible texture identifiers. */
void mq_vulkan_gen_textures(mq_i32 count, void *texture_ids) {
    mq_u32 *ids = (mq_u32 *)texture_ids;
    mq_i32 i;
    if (ids == MQ_NULL || count < 1) return;
    for (i = 0; i < count; ++i) {
        mq_vk_texture_t *entry;
        while (mq_vk_next_texture < MQ_VK_MAX_TEXTURES && mq_vk_textures[mq_vk_next_texture].allocated) ++mq_vk_next_texture;
        if (mq_vk_next_texture >= MQ_VK_MAX_TEXTURES) { ids[i] = 0u; continue; }
        entry = &mq_vk_textures[mq_vk_next_texture];
        if (entry->descriptor == VK_NULL_HANDLE && !mq_vk_alloc_descriptor(entry)) { ids[i] = 0u; continue; }
        ids[i] = mq_vk_next_texture++;
        entry->allocated = 1;
        entry->min_filter = MQ_GL_NEAREST;
        entry->mag_filter = MQ_GL_NEAREST;
        entry->wrap_s = MQ_GL_REPEAT;
        entry->wrap_t = MQ_GL_REPEAT;
        entry->anisotropy = 1;
    }
}
/* Release resources owned by delete textures. */
void mq_vulkan_delete_textures(mq_i32 count, const void *texture_ids) { const mq_u32 *ids=(const mq_u32*)texture_ids; mq_i32 i; if(ids==MQ_NULL||count<=0)return; for(i=0;i<count;++i) if(ids[i]>0u&&ids[i]<MQ_VK_MAX_TEXTURES) { mq_vk_texture_t *entry=&mq_vk_textures[ids[i]]; VkDescriptorSet descriptor=entry->descriptor; mq_vk_destroy_texture(entry); entry->descriptor=descriptor; if(mq_vk_bound_texture==ids[i])mq_vk_bound_texture=0u; if(ids[i]<mq_vk_next_texture)mq_vk_next_texture=ids[i]; } }
/* Update fixed-function texture sampling state. */
void mq_vulkan_tex_parameter_i(mq_u32 target, mq_u32 name, mq_i32 value) { mq_vk_texture_t *texture; (void)target; if(mq_vk_bound_texture>=MQ_VK_MAX_TEXTURES)return; texture=mq_vk_bound_texture==0u?&mq_vk_white_texture:&mq_vk_textures[mq_vk_bound_texture]; if(name==MQ_GL_TEXTURE_MIN_FILTER)texture->min_filter=value;else if(name==MQ_GL_TEXTURE_MAG_FILTER)texture->mag_filter=value;else if(name==MQ_GL_TEXTURE_WRAP_S)texture->wrap_s=value;else if(name==MQ_GL_TEXTURE_WRAP_T)texture->wrap_t=value;else if(name==MQ_GL_TEXTURE_MAX_ANISOTROPY_EXT){if(value<1)value=1;if(value>16)value=16;texture->anisotropy=value;} if(texture->view!=VK_NULL_HANDLE){mq_vk_sampler(texture);mq_vk_update_descriptor(texture);} }
/* Update fixed-function texture sampling state. */
void mq_vulkan_tex_env_i(mq_u32 target, mq_u32 name, mq_i32 value) { (void)target; if(name==MQ_GL_TEXTURE_ENV_MODE)mq_vk_texture_environment=value; }
/* Return the source pixel stride for the selected format. */
static mq_u32 mq_vk_source_bytes(mq_u32 format) { return format == MQ_GL_RGBA ? 4u : (format == MQ_GL_RGB ? 3u : 1u); }

/* Convert one source pixel into the backend's RGBA upload format. */
static void mq_vk_pixel(mq_u8 *destination, const mq_u8 *source, mq_u32 format) {
    if (format == MQ_GL_RGBA) {
        destination[0] = source[0]; destination[1] = source[1]; destination[2] = source[2]; destination[3] = source[3];
    } else if (format == MQ_GL_RGB) {
        destination[0] = source[0]; destination[1] = source[1]; destination[2] = source[2]; destination[3] = 255u;
    } else {
        destination[0] = source[0]; destination[1] = source[0]; destination[2] = source[0]; destination[3] = 255u;
    }
}

/* Resolve a valid mip level without undefined oversized integer shifts. */
static mq_i32 mq_vk_texture_level_extent(const mq_vk_texture_t *texture, mq_i32 level, mq_i32 *width, mq_i32 *height) {
    mq_i32 current_width;
    mq_i32 current_height;
    mq_i32 current_level;
    if (texture == MQ_NULL || texture->image == VK_NULL_HANDLE || level < 0 || level >= texture->levels) return 0;
    current_width = texture->width;
    current_height = texture->height;
    for (current_level = 0; current_level < level; ++current_level) {
        if (current_width > 1) current_width /= 2;
        if (current_height > 1) current_height /= 2;
    }
    if (width != MQ_NULL) *width = current_width;
    if (height != MQ_NULL) *height = current_height;
    return 1;
}

/* Allocate and upload a complete texture image. */
void mq_vulkan_tex_image_2d(mq_u32 target, mq_i32 level, mq_i32 internal_format, mq_i32 width, mq_i32 height, mq_i32 border, mq_u32 format, mq_u32 type, const void *pixels) {
    mq_vk_texture_t *texture;
    VkCommandBuffer command;
    VkBufferImageCopy region;
    VkDescriptorSet descriptor = VK_NULL_HANDLE;
    mq_u32 source_bytes;
    mq_i32 allocated = 0;
    mq_i32 expected_width;
    mq_i32 expected_height;
    mq_i32 mip_width;
    mq_i32 mip_height;
    mq_i32 created = 0;
    mq_i32 x;
    mq_i32 y;
    (void)target; (void)internal_format; (void)border;
    if (mq_vk_bound_texture >= MQ_VK_MAX_TEXTURES || level < 0 || width < 1 || height < 1 || pixels == MQ_NULL || type != MQ_GL_UNSIGNED_BYTE || mq_vk_staging == MQ_NULL) return;
    if ((mq_u64)(mq_u32)width * (mq_u64)(mq_u32)height * 4u > mq_vk_staging_size) return;
    texture = mq_vk_bound_texture == 0u ? &mq_vk_white_texture : &mq_vk_textures[mq_vk_bound_texture];
    if (level == 0) {
        descriptor = texture->descriptor;
        allocated = texture->allocated;
        mq_vk_destroy_texture(texture);
        texture->descriptor = descriptor;
        texture->allocated = allocated;
        texture->width = width;
        texture->height = height;
        texture->levels = 1;
        mip_width = width;
        mip_height = height;
        while (mip_width > 1 || mip_height > 1) {
            if (mip_width > 1) mip_width /= 2;
            if (mip_height > 1) mip_height /= 2;
            ++texture->levels;
        }
        if (!mq_vk_create_image(width, height, texture->levels, VK_FORMAT_R8G8B8A8_UNORM, VK_IMAGE_USAGE_TRANSFER_DST_BIT | VK_IMAGE_USAGE_SAMPLED_BIT, &texture->image, &texture->memory)) goto fail;
        if (!mq_vk_view(texture->image, VK_FORMAT_R8G8B8A8_UNORM, VK_IMAGE_ASPECT_COLOR_BIT, texture->levels, &texture->view)) goto fail;
        texture->min_filter = MQ_GL_NEAREST;
        texture->mag_filter = MQ_GL_NEAREST;
        texture->wrap_s = MQ_GL_REPEAT;
        texture->wrap_t = MQ_GL_REPEAT;
        created = 1;
    } else {
        if (!mq_vk_texture_level_extent(texture, level, &expected_width, &expected_height)) return;
        if (width != expected_width || height != expected_height) return;
    }
    source_bytes = mq_vk_source_bytes(format);
    for (y = 0; y < height; ++y) {
        for (x = 0; x < width; ++x) {
            mq_u64 destination_offset = ((mq_u64)(mq_u32)y * (mq_u32)width + (mq_u32)x) * 4u;
            mq_u64 source_offset = ((mq_u64)(mq_u32)y * (mq_u32)width + (mq_u32)x) * source_bytes;
            mq_vk_pixel(&mq_vk_staging[destination_offset], &((const mq_u8 *)pixels)[source_offset], format);
        }
    }
    command = mq_vk_one_time_begin();
    if (command == VK_NULL_HANDLE) goto fail;
    mq_vk_image_barrier(command, texture->image, VK_IMAGE_ASPECT_COLOR_BIT, (mq_u32)level, 1u, VK_IMAGE_LAYOUT_UNDEFINED, VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT, VK_PIPELINE_STAGE_TRANSFER_BIT, 0u, VK_ACCESS_TRANSFER_WRITE_BIT);
    memset(&region, 0, sizeof(region));
    region.imageSubresource.aspectMask = VK_IMAGE_ASPECT_COLOR_BIT;
    region.imageSubresource.mipLevel = (mq_u32)level;
    region.imageSubresource.layerCount = 1u;
    region.imageExtent.width = (mq_u32)width;
    region.imageExtent.height = (mq_u32)height;
    region.imageExtent.depth = 1u;
    mq_vkCmdCopyBufferToImage(command, mq_vk_staging_buffer, texture->image, VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, 1u, &region);
    mq_vk_image_barrier(command, texture->image, VK_IMAGE_ASPECT_COLOR_BIT, (mq_u32)level, 1u, VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL, VK_PIPELINE_STAGE_TRANSFER_BIT, VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT, VK_ACCESS_TRANSFER_WRITE_BIT, VK_ACCESS_SHADER_READ_BIT);
    if (!mq_vk_one_time_end(command)) goto fail;
    if (texture->uploaded_levels < level + 1) texture->uploaded_levels = level + 1;
    if (!mq_vk_sampler(texture)) goto fail;
    mq_vk_update_descriptor(texture);
    return;
fail:
    if (created || level == 0) {
        descriptor = texture->descriptor;
        allocated = texture->allocated;
        mq_vk_destroy_texture(texture);
        texture->descriptor = descriptor;
        texture->allocated = allocated;
    }
}

/* Upload a rectangular update into an existing texture image. */
void mq_vulkan_tex_sub_image_2d(mq_u32 target, mq_i32 level, mq_i32 x_offset, mq_i32 y_offset, mq_i32 width, mq_i32 height, mq_u32 format, mq_u32 type, const void *pixels) {
    mq_vk_texture_t *texture;
    VkCommandBuffer command;
    VkBufferImageCopy region;
    mq_u32 source_bytes;
    mq_i32 level_width;
    mq_i32 level_height;
    mq_i32 x;
    mq_i32 y;
    (void)target;
    if (mq_vk_bound_texture >= MQ_VK_MAX_TEXTURES || level < 0 || x_offset < 0 || y_offset < 0 || width < 1 || height < 1 || pixels == MQ_NULL || type != MQ_GL_UNSIGNED_BYTE || mq_vk_staging == MQ_NULL) return;
    if ((mq_u64)(mq_u32)width * (mq_u64)(mq_u32)height * 4u > mq_vk_staging_size) return;
    texture = mq_vk_bound_texture == 0u ? &mq_vk_white_texture : &mq_vk_textures[mq_vk_bound_texture];
    if (!mq_vk_texture_level_extent(texture, level, &level_width, &level_height) || level >= texture->uploaded_levels) return;
    if (width > level_width || height > level_height || x_offset > level_width - width || y_offset > level_height - height) return;
    source_bytes = mq_vk_source_bytes(format);
    for (y = 0; y < height; ++y) {
        for (x = 0; x < width; ++x) {
            mq_u64 destination_offset = ((mq_u64)(mq_u32)y * (mq_u32)width + (mq_u32)x) * 4u;
            mq_u64 source_offset = ((mq_u64)(mq_u32)y * (mq_u32)width + (mq_u32)x) * source_bytes;
            mq_vk_pixel(&mq_vk_staging[destination_offset], &((const mq_u8 *)pixels)[source_offset], format);
        }
    }
    command = mq_vk_one_time_begin();
    if (command == VK_NULL_HANDLE) return;
    mq_vk_image_barrier(command, texture->image, VK_IMAGE_ASPECT_COLOR_BIT, (mq_u32)level, 1u, VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL, VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT, VK_PIPELINE_STAGE_TRANSFER_BIT, VK_ACCESS_SHADER_READ_BIT, VK_ACCESS_TRANSFER_WRITE_BIT);
    memset(&region, 0, sizeof(region));
    region.imageSubresource.aspectMask = VK_IMAGE_ASPECT_COLOR_BIT;
    region.imageSubresource.mipLevel = (mq_u32)level;
    region.imageSubresource.layerCount = 1u;
    region.imageOffset.x = x_offset;
    region.imageOffset.y = y_offset;
    region.imageExtent.width = (mq_u32)width;
    region.imageExtent.height = (mq_u32)height;
    region.imageExtent.depth = 1u;
    mq_vkCmdCopyBufferToImage(command, mq_vk_staging_buffer, texture->image, VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, 1u, &region);
    mq_vk_image_barrier(command, texture->image, VK_IMAGE_ASPECT_COLOR_BIT, (mq_u32)level, 1u, VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL, VK_PIPELINE_STAGE_TRANSFER_BIT, VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT, VK_ACCESS_TRANSFER_WRITE_BIT, VK_ACCESS_SHADER_READ_BIT);
    mq_vk_one_time_end(command);
}

/* Read pixels into caller-owned storage. */
void mq_vulkan_read_pixels(mq_i32 x, mq_i32 y, mq_i32 width, mq_i32 height, mq_u32 format, mq_u32 type, void *pixels) {
    mq_vk_frame_t *frame = &mq_vk_frames[mq_vk_frame_index];
    VkBufferImageCopy region;
    mq_u8 *destination = (mq_u8 *)pixels;
    mq_u64 byte_count;
    mq_i32 row;
    mq_i32 column;
    if (pixels == MQ_NULL || format != MQ_GL_RGBA || type != MQ_GL_UNSIGNED_BYTE || width < 1 || height < 1) return;
    byte_count = (mq_u64)(mq_u32)width * (mq_u64)(mq_u32)height * 4u;
    if (byte_count > mq_vk_staging_size) return;
    memset(destination, 0, (size_t)byte_count);
    if (x < 0 || y < 0 || width > mq_vk_width || height > mq_vk_height || x > mq_vk_width - width || y > mq_vk_height - height || !mq_vk_frame_begin()) return;
    if (frame->rendering) { mq_vkCmdEndRendering(frame->command); frame->rendering = 0; }
    mq_vk_image_barrier(frame->command, mq_vk_images[frame->image_index], VK_IMAGE_ASPECT_COLOR_BIT, 0u, 1u, VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL, VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT, VK_PIPELINE_STAGE_TRANSFER_BIT, VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT, VK_ACCESS_TRANSFER_READ_BIT);
    memset(&region, 0, sizeof(region));
    region.bufferRowLength = (mq_u32)width;
    region.imageSubresource.aspectMask = VK_IMAGE_ASPECT_COLOR_BIT;
    region.imageSubresource.layerCount = 1u;
    region.imageOffset.x = x;
    region.imageOffset.y = mq_vk_height - y - height;
    region.imageExtent.width = (mq_u32)width;
    region.imageExtent.height = (mq_u32)height;
    region.imageExtent.depth = 1u;
    mq_vkCmdCopyImageToBuffer(frame->command, mq_vk_images[frame->image_index], VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, mq_vk_staging_buffer, 1u, &region);
    mq_vk_image_barrier(frame->command, mq_vk_images[frame->image_index], VK_IMAGE_ASPECT_COLOR_BIT, 0u, 1u, VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL, VK_PIPELINE_STAGE_TRANSFER_BIT, VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT, VK_ACCESS_TRANSFER_READ_BIT, VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT);
    mq_vulkan_present();
    if (mq_vkDeviceWaitIdle(mq_vk_device) != VK_SUCCESS) return;
    for (row = 0; row < height; ++row) {
        const mq_u8 *source = &mq_vk_staging[(mq_u64)(mq_u32)(height - 1 - row) * (mq_u32)width * 4u];
        for (column = 0; column < width; ++column) {
            mq_u64 offset = ((mq_u64)(mq_u32)row * (mq_u32)width + (mq_u32)column) * 4u;
            if (mq_vk_swapchain_format == VK_FORMAT_B8G8R8A8_UNORM) {
                destination[offset] = source[column * 4u + 2u];
                destination[offset + 1u] = source[column * 4u + 1u];
                destination[offset + 2u] = source[column * 4u];
            } else {
                destination[offset] = source[column * 4u];
                destination[offset + 1u] = source[column * 4u + 1u];
                destination[offset + 2u] = source[column * 4u + 2u];
            }
            destination[offset + 3u] = source[column * 4u + 3u];
        }
    }
}
const char*mq_vulkan_get_string(mq_u32 name){if(name==MQ_GL_VENDOR)return"Khronos Group";if(name==MQ_GL_RENDERER)return mq_vk_device_name;if(name==MQ_GL_VERSION)return"Vulkan 1.3";return"";}
/* Return the current get error value. */
mq_u32 mq_vulkan_get_error(void){mq_u32 value=(mq_u32)mq_vk_last_error;mq_vk_last_error=0;return value;}void mq_vulkan_finish(void){if(mq_vk_device!=VK_NULL_HANDLE)mq_vkDeviceWaitIdle(mq_vk_device);}void mq_vulkan_flush(void){}void mq_vulkan_draw_buffer(mq_u32 mode){(void)mode;}

/* Report whether Vulkan can execute the enhanced per-pixel light pass. */
mq_i32 mq_vulkan_enhanced_available(void) {
    return mq_vk_device != VK_NULL_HANDLE && mq_vk_pipeline != VK_NULL_HANDLE;
}

/* Configure the optional Vulkan enhanced-lighting path. */
mq_i32 mq_vulkan_enhanced_configure(mq_i32 enabled, mq_i32 shadows, mq_i32 shadow_quality) {
    (void)shadows;
    (void)shadow_quality;
    mq_vk_enhanced_enabled = enabled != 0 && mq_vulkan_enhanced_available();
    mq_vk_enhanced_draw_kind_value = 0;
    if (!mq_vk_enhanced_enabled) mq_vk_enhanced_light_count = 0;
    return enabled == 0 || mq_vk_enhanced_enabled;
}

/* Snapshot the view matrix and transform compact world lights to eye space. */
mq_i32 mq_vulkan_enhanced_begin_frame(const void *light_data, mq_u32 byte_count) {
    const float *source = (const float *)light_data;
    mq_u32 index;
    mq_u32 count;
    if (!mq_vk_enhanced_enabled || source == MQ_NULL) return 0;
    memcpy(mq_vk_enhanced_view, mq_vk_modelview[mq_vk_modelview_top], sizeof(mq_vk_enhanced_view));
    count = byte_count / (4u * (mq_u32)sizeof(float));
    if (count > 3u) count = 3u;
    for (index = 0u; index < count; ++index) {
        float x = source[index * 4u];
        float y = source[index * 4u + 1u];
        float z = source[index * 4u + 2u];
        mq_vk_enhanced_lights[index * 4u] = mq_vk_enhanced_view[0] * x + mq_vk_enhanced_view[4] * y + mq_vk_enhanced_view[8] * z + mq_vk_enhanced_view[12];
        mq_vk_enhanced_lights[index * 4u + 1u] = mq_vk_enhanced_view[1] * x + mq_vk_enhanced_view[5] * y + mq_vk_enhanced_view[9] * z + mq_vk_enhanced_view[13];
        mq_vk_enhanced_lights[index * 4u + 2u] = mq_vk_enhanced_view[2] * x + mq_vk_enhanced_view[6] * y + mq_vk_enhanced_view[10] * z + mq_vk_enhanced_view[14];
        mq_vk_enhanced_lights[index * 4u + 3u] = source[index * 4u + 3u];
    }
    mq_vk_enhanced_light_count = (mq_i32)count;
    return 1;
}

/* Select whether subsequent Vulkan geometry belongs to the enhanced overlay. */
void mq_vulkan_enhanced_draw_kind(mq_i32 kind) {
    mq_vk_enhanced_draw_kind_value = mq_vk_enhanced_enabled ? kind : 0;
}

/* Restore classic Vulkan drawing state at the end of the 3-D frame. */
void mq_vulkan_enhanced_end_frame(void) {
    mq_vk_enhanced_draw_kind_value = 0;
}
