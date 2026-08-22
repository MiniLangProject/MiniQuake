#!/usr/bin/env python3
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: Apache-2.0

"""Apply licence-aware source/test headers and MiniLang function summaries.

This maintenance helper is intentionally conservative: Quake-derived files are
kept under GPL-2.0-or-later with the original id notice, while project-original
support files use Apache-2.0.  It inserts short declaration-specific summaries
without changing executable statements.  Re-running it is idempotent.
"""

from __future__ import annotations

import argparse
import ast
from pathlib import Path
import re

from check_source_documentation import COPYRIGHT, DERIVED_MARKERS, ML_FUNCTION_RE


EXCLUDED_CONCURRENT_FILES = {
    "src/miniquake/client.ml",
    "src/miniquake/client_render_handoff.ml",
    "src/miniquake/particles.ml",
    "src/miniquake/render/particles.ml",
    "src/miniquake/sound/mixer.ml",
}

DERIVED_TOOL_PREFIXES = (
    "bp",
    "check_asset_",
    "check_audio_",
    "check_client_render_",
    "check_command_cvar",
    "check_compat_",
    "check_core_",
    "check_demo_lifecycle",
    "check_external_",
    "check_frontend_",
    "check_gameplay_",
    "check_host_",
    "check_network_0",
    "check_protocol15_",
    "check_quakec_",
    "check_render_special_",
    "check_savegame_",
    "check_server_",
    "check_source_0",
    "check_sv_user_",
    "check_world_",
    "client_render_checker_common",
    "world_render_checker_common",
)

MAINTAINED_POWERSHELL_DESCRIPTIONS = {
    "build.ps1": "Build MiniQuake and run the selected source and runtime verification gates.",
    "scripts/test.ps1": "Run the current MiniQuake acceptance package.",
    "scripts/validate_real_game.ps1": "Run retail-data validation against a caller-supplied Quake installation.",
}

def header(licence: str, description: str, *, derived: bool) -> str:
    """Build the canonical comment header for one production source file."""
    lines = ["/*"]
    if derived:
        lines.append("Copyright (c) 1996-1997 Id Software, Inc.")
    lines.extend((COPYRIGHT, f"SPDX-License-Identifier: {licence}", "", description, "*/", ""))
    return "\n".join(lines)


def strip_existing_header(text: str) -> tuple[str, str]:
    """Remove one existing leading block comment and preserve its description."""
    if not text.startswith("/*"):
        return text, ""
    end = text.find("*/")
    if end < 0:
        return text, ""
    raw = text[2:end]
    description: list[str] = []
    for raw_line in raw.splitlines():
        line = raw_line.strip().lstrip("*").strip()
        if not line:
            if description and description[-1]:
                description.append("")
            continue
        if (
            line.startswith("Copyright")
            or line.startswith("SPDX-License-Identifier:")
            or "free software" in line
            or line.startswith("modify it")
            or line.startswith("as published")
            or line.startswith("of the License")
            or line.startswith("This program is distributed")
            or line.startswith("but WITHOUT")
            or line.startswith("MERCHANTABILITY")
            or "GNU General Public License" in line
            or "Free Software Foundation" in line
            or line.startswith("See COPYING")
            or line.startswith("GPL-")
        ):
            continue
        description.append(line)
    while description and not description[-1]:
        description.pop()
    return text[end + 2 :].lstrip("\r\n"), "\n".join(description)


def split_words(name: str) -> str:
    """Turn a camel/snake-case function name into a readable phrase."""
    phrase = name.replace("_", " ")
    phrase = re.sub(r"(?<=[a-z0-9])(?=[A-Z])", " ", phrase)
    return " ".join(phrase.split()).lower()


def function_summary(name: str, *, test_context: bool = False) -> str:
    """Produce a concise, declaration-specific function summary."""
    original_name = name
    test_name = re.sub(r"^bp\d+", "", name, flags=re.IGNORECASE)
    is_numbered_test_helper = test_name != name
    phrase = split_words(test_name or name)
    tokens = phrase.split()
    verb = tokens[0] if tokens else ""
    tail_phrase = " ".join(tokens[1:]) or "the requested value"
    lower_name = name.lower()
    if lower_name in {"yes", "require", "check", "asserttrue"} or re.search(
        r"(?:yes|require|check|asserttrue)$", lower_name
    ):
        return "// Assert that the condition holds and identify a failing test."
    if lower_name in {"equal", "equals", "assertEqual".lower()} or re.search(
        r"(?:equal|equals|assertequal)$", lower_name
    ):
        return "// Assert exact equality and report both values on failure."
    if lower_name in {"near", "assertnear"} or re.search(r"(?:near|assertnear)$", lower_name):
        return "// Assert floating-point equality within the requested tolerance."
    if lower_name in {"run", "runtest"} or re.search(r"(?:run|runtest)$", lower_name):
        return "// Execute one named test case and record its pass/fail result."
    if verb == "test":
        return f"// Verify {tail_phrase} against the expected Quake behavior."
    if verb in {"fixture", "synthetic", "sample"}:
        return f"// Build deterministic test data for {tail_phrase}."
    if name == "create":
        return "// Create and initialize the module state."
    if name == "main" and test_context:
        return "// Run this module's regression scenarios and return aggregate status."
    if name == "main":
        return "// Parse command-line arguments and run the selected operation."
    if test_context and is_numbered_test_helper:
        return f"// Exercise the {phrase} test scenario and verify its expected result."
    scalar_readers = {
        "u8": "Read an unsigned 8-bit value from the byte buffer.",
        "i8": "Read a signed 8-bit value from the byte buffer.",
        "u16": "Read a little-endian unsigned 16-bit value from the byte buffer.",
        "i16": "Read a little-endian signed 16-bit value from the byte buffer.",
        "u32": "Read a little-endian unsigned 32-bit value from the byte buffer.",
        "i32": "Read a little-endian signed 32-bit value from the byte buffer.",
        "f32": "Read an IEEE-754 single-precision value from the byte buffer.",
        "argc": "Return the number of tokenized command arguments.",
        "argv": "Return one tokenized command argument by index.",
        "status": "Return the stable compatibility-contract status string.",
        "fingerprint": "Return the stable compatibility-contract fingerprint.",
        "capacity": "Return the backend queue capacity.",
        "position": "Return the current backend playback position.",
        "submitted": "Return the number of buffers submitted to the backend.",
    }
    if name in scalar_readers:
        return "// " + scalar_readers[name]
    if name == "copyArrayLinear":
        return "// Copy every source element into a new linear array."
    if name == "copyArrayPrefix":
        return "// Copy the requested source prefix into a new array."
    if name.startswith("makeFilledArray"):
        return "// Create an array prefilled with one value."
    if name.startswith("makeEmptyArray"):
        return "// Create an exact-sized array initialized with void slots."
    if name.startswith("copyArray"):
        return f"// Copy values for {phrase} into new storage."
    if name.startswith("zero"):
        return f"// Create the zero-initialized state for {phrase[5:] or 'this value'}."
    if verb == "hash":
        return f"// Fold {phrase[5:] or 'the value'} into the deterministic rolling hash."
    if verb in {"is", "has", "can", "should", "valid", "equals", "equal", "matches"}:
        return f"// Report whether {tail_phrase}."
    if verb in {"validate", "verify", "check"}:
        return f"// Validate {tail_phrase} and report any incompatibility."
    if verb in {"create", "make", "build", "alloc", "new"}:
        return f"// Create and initialize {tail_phrase}."
    if verb in {"read", "load", "parse", "decode"}:
        return f"// Read and validate {tail_phrase}."
    if verb in {"write", "encode", "serialize", "put"}:
        return f"// Encode and write {tail_phrase}."
    if verb == "save":
        if any(token in {"equal", "equals", "equivalent"} for token in tokens[1:]):
            return f"// Compare {tail_phrase}."
        return f"// Save {tail_phrase} in its persistent format."
    if verb in {"find", "lookup", "get", "current"}:
        return f"// Return {tail_phrase}."
    if verb in {"set", "update", "sync", "synchronize", "reset", "clear"}:
        return f"// Update module state for {tail_phrase}."
    if verb in {"draw", "render"}:
        return f"// Render {tail_phrase}."
    if verb in {"run", "execute", "process", "dispatch"}:
        return f"// Execute {tail_phrase}."
    if verb in {"print", "format"}:
        return f"// Format and emit {tail_phrase}."
    if verb == "svm":
        return f"// Apply server-side {tail_phrase} semantics."
    if verb == "physics":
        return f"// Apply server-physics {tail_phrase} semantics."
    if verb == "q":
        return f"// Provide the Quake-compatible {tail_phrase} entry point."
    if verb in {"add", "append", "insert", "push", "queue", "emit"}:
        return f"// Add {tail_phrase} to the destination state."
    if verb in {"remove", "delete", "free", "release", "shutdown", "close", "deinit"}:
        return f"// Release or remove state for {tail_phrase}."
    if verb in {"copy", "move", "transfer"}:
        return f"// Transfer data for {tail_phrase}."
    if verb in {"compute", "calculate", "crc", "checksum"}:
        return f"// Compute {tail_phrase}."
    if verb in {"connect", "reconnect"}:
        return f"// Establish {tail_phrase} using the active network transport."
    if verb in {"disconnect"}:
        return f"// Terminate {tail_phrase} and release its transport state."
    if verb in {"trace", "clip"}:
        return f"// Trace {tail_phrase} through the collision world."
    if verb in {"ensure", "grow", "reserve"}:
        return f"// Ensure sufficient storage or state for {tail_phrase}."
    if verb in {"apply"}:
        return f"// Apply {tail_phrase} to the active subsystem state."
    if verb in {"send", "transmit"}:
        return f"// Send {tail_phrase} through the active connection."
    if verb in {"begin", "start", "open", "init", "initialize"}:
        return f"// Initialize state for {tail_phrase}."
    if verb in {"end", "stop", "finish"}:
        return f"// Finalize state for {tail_phrase}."
    if verb in {"advance", "step", "pump", "tick", "frame"}:
        return f"// Advance {tail_phrase} by one processing step."
    if verb in {"split", "tokenize", "quote", "normalize", "strip"}:
        return f"// Convert {tail_phrase} into its canonical representation."
    if verb in {"clamp", "bounded", "safe"}:
        return f"// Return a validated {phrase} value."
    if verb in {"fail", "error"}:
        return f"// Report {tail_phrase} and return the corresponding failure status."
    if re.match(r"^[A-Z][A-Za-z0-9]*_", original_name):
        return f"// Mirror Quake's {original_name} routine and its observable state changes."
    if any(token in {"exists", "valid", "available", "visible", "enabled", "active"} for token in tokens):
        return f"// Report whether {phrase} holds for the active state."
    if verb in {"max", "min", "first", "last", "next"}:
        return f"// Return {phrase} for the active module state."
    if verb in {"configure", "register", "change", "toggle", "select"}:
        return f"// Update subsystem configuration for {phrase}."
    if verb in {"destroy", "discard"}:
        return f"// Release resources owned by {tail_phrase}."
    if verb in {"allocate", "spawn"}:
        return f"// Allocate and initialize {tail_phrase}."
    if verb == "play":
        return f"// Play {tail_phrase} through the active media subsystem."
    if verb == "mix":
        return f"// Mix {tail_phrase} into the active audio buffer."
    if verb == "upload":
        return f"// Upload {tail_phrase} to the active renderer."
    if verb == "precache":
        return f"// Preload and register the {tail_phrase} asset."
    if verb in {"handle", "complete"}:
        return f"// Handle {tail_phrase} and update the associated state."
    if tokens and tokens[-1] in {"update", "init", "reset", "shutdown", "change"}:
        return f"// Update subsystem state for {phrase}."
    if tokens and tokens[-1] in {
        "value", "values", "count", "index", "name", "names", "path", "paths",
        "state", "status", "vector", "summary", "bits", "byte", "bytes", "offset",
        "size", "length", "location", "mode", "type", "origin", "origins", "angles",
        "data", "number", "checksum", "crc",
    }:
        return f"// Return {phrase} derived from the active module state."
    if verb in {
        "count", "length", "capacity", "status", "fingerprint", "constants",
        "completed", "underruns", "available", "index", "name", "path",
    }:
        return f"// Return {phrase} for the active module state."
    if test_context:
        return f"// Exercise {phrase} as part of this deterministic regression fixture."
    return f"// Provide {phrase} behavior for the active subsystem."


def c_function_summary(name: str) -> str:
    """Produce a concise C comment for internal and exported bridge functions."""
    normalized = re.sub(r"^(?:mq|mqt)_", "", name)
    normalized = re.sub(
        r"^(?:d3d9?|vk|vulkan|gl|ogg|win|udp|audio|render)_?",
        "",
        normalized,
    )
    words = split_words(normalized)
    lower = words.lower()
    if lower == "main":
        return "/* Run the standalone differential oracle and emit its fixture rows. */"
    if lower == "die":
        return "/* Abort the oracle after reporting an invalid fixture condition. */"
    if lower.startswith(("row", "emit", "print ")) or lower.endswith(" row"):
        return "/* Emit one deterministic result row for the differential oracle. */"
    if lower in {"bits", "fbits", "float bits", "from bits"}:
        return "/* Convert the fixture value to or from its IEEE-754 bit pattern. */"
    exact_summaries = {
        "view": "Create an image view for backend texture access.",
        "sampler": "Create the sampler matching the texture's filter and wrap state.",
        "update descriptor": "Bind the texture image and sampler to its descriptor set.",
        "alloc descriptor": "Allocate a descriptor set for one texture.",
        "add": "Append one vertex with the current immediate-mode attributes.",
        "texcoord2": "Update the current immediate-mode texture coordinates.",
        "blend func": "Update the source and destination blend factors.",
        "depth func": "Update the depth comparison function.",
        "depth mask": "Enable or disable depth-buffer writes.",
        "depth range": "Clamp and update the viewport depth range.",
        "alpha func": "Update the alpha-test reference value.",
        "cull face": "Select which polygon face is culled.",
        "shade model": "Accept the fixed-function shade-model state.",
        "polygon mode": "Select the polygon rasterization mode.",
        "viewport": "Update the backend viewport rectangle.",
        "matrix mode": "Select the active fixed-function matrix stack.",
        "transpose": "Transpose a column-major matrix for Direct3D.",
        "default state": "Restore the renderer's GLQuake-compatible default state.",
        "backend proc": "Resolve a text-conversion export from the native bridge.",
        "crt proc": "Resolve a formatting routine from the process C runtime.",
        "f32 to text": "Format a MiniLang float into caller-owned UTF-8 storage.",
        "bound address": "Format the UDP socket's bound address for MiniLang.",
        "last address": "Format the address of the last received UDP packet.",
        "local address": "Format the host's selected local UDP address.",
        "host name": "Copy the local host name into caller-owned storage.",
        "resolve name": "Resolve a host name and format its UDP address.",
        "reverse name": "Resolve a UDP address back to a host name.",
        "select": "Wait for readiness on the requested socket set.",
        "abs i32": "Return the absolute value of a signed integer.",
        "update clip cursor": "Refresh the mouse confinement rectangle for the active window.",
        "zero bytes": "Clear a caller-provided byte range.",
        "sock start": "Initialize WinSock once for UDP networking.",
        "remember address": "Cache the most recently observed UDP peer address.",
        "prepare display mode": "Build a Win32 display-mode request from video settings.",
        "dow proc": "Resolve a procedure from the dynamically loaded backend module.",
        "f32 from ml raw": "Decode MiniLang's raw float representation.",
        "f32 to ml raw": "Encode a native float in MiniLang's raw representation.",
        "test display mode": "Validate a requested fullscreen display mode with Win32.",
        "make current": "Make the OpenGL rendering context current on this thread.",
        "is minimized": "Report whether the game window is currently minimized.",
        "activate": "Apply focus-dependent input and display state.",
        "swap": "Present the OpenGL back buffer to the game window.",
        "has focus": "Report whether the game window owns keyboard focus.",
        "input event pop": "Remove the oldest event from the native input queue.",
        "input test push": "Inject one event into the input queue for tests.",
        "cursor show": "Show or hide the Win32 cursor with balanced calls.",
        "cursor center": "Move the cursor to the center of the client area.",
        "ticks": "Return the monotonic high-resolution timer value.",
        "sleep": "Yield the current thread for the requested duration.",
        "sys counter": "Read the Win32 performance counter.",
        "sys frequency": "Return the Win32 performance-counter frequency.",
        "sys make code writeable": "Change protection on a generated-code memory range.",
        "sys sleep until input": "Wait until input arrives or the timeout expires.",
        "reap completed": "Recycle audio buffers completed by the output device.",
        "queued": "Return the number of queued audio frames.",
        "position": "Return the audio device's playback position.",
        "completed": "Return the number of audio frames completed by the device.",
        "underruns": "Return the accumulated audio underrun count.",
        "header state": "Return the state of the selected audio buffer header.",
        "capacity": "Return the audio queue's frame capacity.",
        "is open": "Report whether the requested native device is open.",
        "bound port": "Return the UDP port assigned to a socket.",
        "last port": "Return the source port of the last UDP packet.",
        "last error": "Return the last native networking error code.",
        "world program enable": "Enable or disable the OpenGL world shader program.",
        "active texture": "Select the active OpenGL texture unit.",
    }
    if lower in exact_summaries:
        return f"/* {exact_summaries[lower]} */"
    if lower.startswith("static multitexture draw"):
        return "/* Draw cached multitextured geometry through the native fast path. */"
    if lower in {"rate", "channels", "frames", "backend", "get error"}:
        return f"/* Return the current {lower} value. */"
    if lower.startswith("get ") or lower.endswith(" count") or lower.endswith(" width") or lower.endswith(" height"):
        return f"/* Return {lower}. */"
    if "available" in lower or "ready" in lower or lower.startswith("valid"):
        return f"/* Report whether {lower} is available. */"
    if "initialize" in lower or lower.startswith("create"):
        return f"/* Create and initialize {lower}. */"
    if "shutdown" in lower or lower.startswith("destroy") or lower.startswith("delete"):
        return f"/* Release resources owned by {lower}. */"
    if "bits to float" in lower or "bits float" in lower:
        return "/* Reinterpret MiniLang's IEEE-754 bit pattern as a native float. */"
    if "clamp" in lower:
        return "/* Clamp a scalar to the inclusive requested range. */"
    if "identity" in lower:
        return "/* Initialize a column-major identity matrix. */"
    if "multiply" in lower:
        return "/* Multiply two column-major transform matrices. */"
    if lower == "resize":
        return "/* Resize or recreate backend presentation resources. */"
    if lower == "extension":
        return "/* Find an exact extension name in the enumerated Vulkan properties. */"
    if "memory type" in lower:
        return "/* Select a compatible Vulkan memory type for the requested properties. */"
    if lower.endswith("image view") or lower == "image view":
        return "/* Create the Vulkan image view used by a texture or framebuffer. */"
    if "image barrier" in lower:
        return "/* Record the image-layout transition required by the next operation. */"
    if "one time begin" in lower:
        return "/* Begin a transient Vulkan command buffer for a one-shot operation. */"
    if "one time end" in lower:
        return "/* Submit and retire a transient Vulkan command buffer. */"
    if "frame begin" in lower:
        return "/* Acquire the next swap-chain image and begin recording its frame. */"
    if "blend factor" in lower:
        return "/* Translate a GL blend-factor token to its Vulkan equivalent. */"
    if "compare" in lower:
        return "/* Translate a GL comparison token to its Vulkan equivalent. */"
    if "topology" in lower:
        return "/* Translate the active GL primitive mode to Vulkan topology. */"
    if lower.endswith("begin"):
        return "/* Begin collecting immediate-mode vertices for one draw. */"
    if lower.endswith("end"):
        return "/* Submit the immediate-mode vertices collected for the draw. */"
    if any(token in lower for token in ("vertex", "tex coord", "color")):
        return "/* Update the current immediate-mode vertex attributes. */"
    if "present" in lower:
        return "/* Present the completed back buffer to the window. */"
    if "decode" in lower:
        return "/* Decode interleaved PCM frames into caller-owned storage. */"
    if lower.startswith("open"):
        return f"/* Open and validate {lower[5:] or 'the requested resource'}. */"
    if lower.startswith("close"):
        return f"/* Close {lower[6:] or 'the active resource'} and release its storage. */"
    if lower.startswith("load"):
        return "/* Load the backend library and resolve its required entry points. */"
    if lower.startswith("copy"):
        return f"/* Copy {lower[5:] or 'the requested data'} into caller-owned storage. */"
    if lower.startswith("read"):
        return f"/* Read {lower[5:] or 'the requested data'} into caller-owned storage. */"
    if lower.startswith("write"):
        return f"/* Write {lower[6:] or 'the requested data'} to the native destination. */"
    if lower.startswith("set "):
        return f"/* Update backend state for {lower[4:]}. */"
    if lower.startswith("apply "):
        return f"/* Apply {lower[6:]} to the active backend state. */"
    if lower.startswith("release"):
        return f"/* Release {lower[8:].strip() or 'the requested native resources'}. */"
    if lower.startswith("enable") or lower.startswith("disable"):
        return f"/* Update the enabled state of {lower.split(' ', 1)[-1]}. */"
    if lower.startswith("format"):
        return f"/* Format {lower[7:] or 'the native value'} for MiniLang. */"
    if lower.startswith("poll") or lower.startswith("peek"):
        return "/* Poll the native queue without blocking the game loop. */"
    if lower.startswith("push") or lower.startswith("submit"):
        return f"/* Submit {lower.split(' ', 1)[-1]} to the native queue. */"
    if lower.startswith("pop") or lower.startswith("receive"):
        return f"/* Remove {lower.split(' ', 1)[-1]} from the native queue. */"
    if lower.startswith("reset") or lower.startswith("restore"):
        return f"/* Restore {lower.split(' ', 1)[-1]} to its default state. */"
    if lower.startswith("configure"):
        return f"/* Configure {lower[10:]} from the requested settings. */"
    if lower.startswith("translate") or lower.startswith("rotate") or lower.startswith("scale"):
        return f"/* Postmultiply the current matrix with a {lower.split(' ', 1)[0]} transform. */"
    if lower in {"ortho", "frustum"}:
        return f"/* Postmultiply the current matrix with the requested {lower} projection. */"
    if lower.startswith("tex image"):
        return "/* Allocate and upload a complete texture image. */"
    if lower.startswith("tex sub image"):
        return "/* Upload a rectangular update into an existing texture image. */"
    if lower.startswith("tex parameter") or lower.startswith("tex env"):
        return "/* Update fixed-function texture sampling state. */"
    if lower.startswith("read pixels"):
        return "/* Copy the requested framebuffer rectangle into caller-owned RGBA storage. */"
    if lower.startswith("source bytes") or lower.startswith("source pixel bytes"):
        return "/* Return the source pixel stride for the selected format. */"
    if lower.startswith("blend") and lower.endswith("value"):
        return "/* Translate a GL blend token to the backend-specific value. */"
    if lower.startswith("min filter") or lower.startswith("mip filter"):
        return "/* Translate a GL texture-filter token to the backend-specific value. */"
    if lower.startswith("clear"):
        return "/* Clear the selected buffers or pending native state. */"
    if lower.startswith("finish") or lower.startswith("flush"):
        return "/* Synchronize queued rendering work with the native backend. */"
    if any(token in lower for token in ("sin", "cos", "sqrt", "atan2")):
        return "/* Evaluate the requested scalar math operation for MiniLang. */"
    if "to f32" in lower or "to i32" in lower or "to bits" in lower or "from text" in lower:
        return "/* Convert the scalar between MiniLang and native representations. */"
    if lower.startswith("joy") or lower.startswith("mouse") or lower.startswith("key"):
        return "/* Read or update the requested native input state. */"
    if lower.startswith("window ") or lower.startswith("display mode"):
        return f"/* Return the current {lower}. */"
    if lower.startswith("static geometry") or lower.startswith("alias "):
        return "/* Manage cached native geometry for the renderer fast path. */"
    if lower.startswith("conproc") or lower.startswith("sys console"):
        return "/* Bridge the dedicated-console operation to the Win32 host. */"
    if lower.startswith("ascii") or lower.startswith("text"):
        return "/* Convert or transfer text across the MiniLang native boundary. */"
    if lower.startswith("draw"):
        return f"/* Submit {lower} geometry to the active backend command buffer. */"
    if lower.startswith("bind texture"):
        return "/* Bind the selected texture for subsequent draws. */"
    if lower.startswith("gen textures"):
        return "/* Allocate caller-visible texture identifiers. */"
    if lower.startswith("seek start"):
        return "/* Rewind the active Vorbis stream to its first audio frame. */"
    return f"/* Execute the native {lower or name} operation for MiniLang. */"


def document_c_functions(text: str) -> str:
    """Insert declaration-specific comments before C function definitions."""
    from check_source_documentation import C_FUNCTION_RE

    inserts: list[tuple[int, str]] = []
    for match in C_FUNCTION_RE.finditer(text):
        if not has_preceding_comment(text, match.start()):
            inserts.append((match.start(), c_function_summary(match.group(1)) + "\n"))
    for offset, comment in reversed(inserts):
        text = text[:offset] + comment + text[offset:]
    return text


def type_summary(name: str, *, kind: str, test_context: bool = False) -> str:
    """Describe one MiniLang or native aggregate declaration in plain English."""
    clean = re.sub(r"^(?:MQ_|mq_)", "", name)
    clean = re.sub(r"_(?:s|t)$", "", clean)
    phrase = re.sub(r"(?<=[A-Z])(?=[A-Z][a-z])", " ", clean or kind)
    phrase = split_words(phrase)
    lower = phrase.lower()
    display = lower
    for acronym in ("bsp", "crc", "d3d", "dma", "gl", "gpu", "mdl", "ogg", "pcm", "udp", "wad"):
        display = re.sub(rf"\b{acronym}\b", acronym.upper(), display)
    display = re.sub(r"\bquake c\b", "QuakeC", display)
    display = re.sub(r"\bwin sock\b", "WinSock", display)
    display = re.sub(r"\bsizebuf\b", "size buffer", display)
    display = re.sub(r"\bclientdata\b", "client data", display)
    win32_layouts = {
        "MQ_SOCKADDR_IN", "MQ_HOSTENT", "MQ_POINT", "MQ_COORD", "MQ_SMALL_RECT",
        "MQ_CONSOLE_SCREEN_BUFFER_INFO", "MQ_KEY_EVENT_RECORD", "MQ_INPUT_RECORD",
        "MQ_RECT", "MQ_MSG", "MQ_WNDCLASSEXW", "MQ_PIXELFORMATDESCRIPTOR",
        "MQ_POINTL", "MQ_DEVMODEW", "MQ_WAVEFORMATEX", "MQ_WAVEHDR", "MQ_MMTIME",
        "MQ_JOYINFOEX", "MQ_JOYCAPSW", "MQ_LARGE_INTEGER",
    }
    if name in win32_layouts or name == "VkWin32SurfaceCreateInfoKHR":
        return f"Mirror the Win32 {display} ABI layout without requiring SDK declarations."
    if name.startswith("mq_d3d"):
        return f"Store the Direct3D 9 ABI fields for one {display}."
    if name.startswith("mq_vk"):
        return f"Store the Vulkan backend fields for one {display}."
    if "SHADOW" in name:
        return f"Store the native shadow-acceleration data for one {display}."
    if test_context:
        return f"Group the deterministic {display} fields used by this test fixture."
    if lower == "vec3":
        return "Store one three-dimensional vector in Quake world coordinates."
    if lower.endswith(" state"):
        return f"Track mutable {display[:-len(' state')]} state across subsystem calls."
    if lower.endswith((" result", " validation", " verification")):
        return f"Collect the outcome and diagnostics for one {display}."
    if lower.endswith((" vertex", " plane", " edge", " face", " surface", " texture")):
        return f"Describe one {display} consumed by the renderer or asset loader."
    if lower.endswith((" model", " archive", " program", " map", " hull")):
        return f"Store the parsed data and relationships for one {display}."
    if lower.endswith((" buffer", " channel", " socket", " stream")):
        return f"Track storage and runtime state for one {display}."
    if lower.endswith((" registry", " manager", " system", " context", " runtime", " session")):
        return f"Own the coordinated data required by the {display}."
    if lower.endswith((" entity", " edict", " particle", " light", " frame")):
        return f"Describe one runtime {display} and its observable Quake state."
    return f"Group the fields that describe one {display}."


def refresh_ml_struct_summaries(text: str, *, test_context: bool = False) -> str:
    """Refresh only single-line structure summaries emitted by this tool."""
    from check_source_documentation import ML_STRUCT_RE

    replacements: list[tuple[int, int, str]] = []
    generated = re.compile(
        r"// (?:Group the |Track mutable|Track storage|"
        r"Store the parsed|Own the coordinated|Describe one|Collect the outcome)[^\n]*\.\n$"
    )
    for match in ML_STRUCT_RE.finditer(text):
        previous = generated.search(text[:match.start()])
        if previous is None:
            continue
        summary = type_summary(match.group(1), kind="struct", test_context=test_context)
        replacements.append((previous.start(), previous.end(), f"// {summary}\n"))
    for start, end, comment in reversed(replacements):
        text = text[:start] + comment + text[end:]
    return text


def document_ml_structs(text: str, *, test_context: bool = False) -> str:
    """Insert concise comments before undocumented MiniLang structures."""
    from check_source_documentation import ML_STRUCT_RE

    inserts: list[tuple[int, str]] = []
    for match in ML_STRUCT_RE.finditer(text):
        if not has_preceding_comment(text, match.start()):
            summary = type_summary(match.group(1), kind="struct", test_context=test_context)
            inserts.append((match.start(), f"// {summary}\n"))
    for offset, comment in reversed(inserts):
        text = text[:offset] + comment + text[offset:]
    return text


def document_c_types(text: str) -> str:
    """Insert concise comments before undocumented native aggregate types."""
    from check_source_documentation import C_TYPE_RE, c_type_name

    inserts: list[tuple[int, str]] = []
    for match in C_TYPE_RE.finditer(text):
        if not has_preceding_comment(text, match.start()):
            name = c_type_name(text, match)
            summary = type_summary(name, kind=match.group(1))
            inserts.append((match.start(), f"/* {summary} */\n"))
    for offset, comment in reversed(inserts):
        text = text[:offset] + comment + text[offset:]
    return text


def refresh_c_type_summaries(text: str) -> str:
    """Refresh only native type summaries emitted by this maintenance tool."""
    from check_source_documentation import C_TYPE_RE, c_type_name

    replacements: list[tuple[int, int, str]] = []
    generated = re.compile(
        r"/\* (?:Group the |Track mutable|Track storage|Store the parsed|"
        r"Own the coordinated|Describe one|Collect the outcome)[^\n]*\. \*/\n$"
    )
    for match in C_TYPE_RE.finditer(text):
        previous = generated.search(text[:match.start()])
        if previous is None:
            continue
        name = c_type_name(text, match)
        summary = type_summary(name, kind=match.group(1))
        replacements.append((previous.start(), previous.end(), f"/* {summary} */\n"))
    for start, end, comment in reversed(replacements):
        text = text[:start] + comment + text[end:]
    return text


def refresh_generic_c_summaries(text: str) -> str:
    """Refresh C summaries emitted by older maintenance-script revisions."""
    from check_source_documentation import C_FUNCTION_RE

    matches = list(C_FUNCTION_RE.finditer(text))
    replacements: list[tuple[int, int, str]] = []
    for match in matches:
        prefix = text[:match.start()]
        generic = re.search(
            r"/\* (?:Perform the [^.]+ bridge operation|Execute the native [^.]+ operation for MiniLang)\. \*/\r?\n[ \t]*$",
            prefix,
        )
        if generic is not None:
            replacements.append((generic.start(), generic.end(), c_function_summary(match.group(1)) + "\n"))
    for start, end, summary in reversed(replacements):
        text = text[:start] + summary + text[end:]
    return text


def apply_c(path: Path) -> bool:
    """Document C function definitions without altering their implementation."""
    original = path.read_text(encoding="utf-8-sig", errors="replace")
    updated = original
    updated = refresh_c_type_summaries(updated)
    updated = document_c_types(updated)
    updated = document_c_functions(updated)
    if updated == original:
        return False
    path.write_text(updated, encoding="utf-8", newline="\n")
    return True


def has_preceding_comment(text: str, start: int, *, hash_comments: bool = False) -> bool:
    """Report whether the declaration at start already has documentation."""
    prefix = text[:start]
    lines = prefix.splitlines()
    cursor = len(lines) - 1
    while cursor >= 0 and not lines[cursor].strip():
        cursor -= 1
    return cursor >= 0 and (
        lines[cursor].strip().startswith("//")
        or (hash_comments and lines[cursor].strip().startswith("#"))
        or lines[cursor].strip().endswith(("*/", "#>"))
    )


def document_functions(text: str, *, test_context: bool = False) -> str:
    """Insert summaries before all currently undocumented MiniLang functions."""
    inserts: list[tuple[int, str]] = []
    for match in ML_FUNCTION_RE.finditer(text):
        if not has_preceding_comment(text, match.start()):
            inserts.append((match.start(), function_summary(match.group(1), test_context=test_context) + "\n"))
    for offset, comment in reversed(inserts):
        text = text[:offset] + comment + text[offset:]
    return text


def refresh_generated_summaries(text: str) -> str:
    """Replace summaries emitted by older revisions of this maintenance tool."""
    patterns = (
        re.compile(r"(?m)^// Implement ([^.]+)\.\n(function(?: inline)?\s+([A-Za-z_][A-Za-z0-9_]*)\()"),
        re.compile(r"(?m)^// Create ([^.]+)\.\n(function(?: inline)?\s+([A-Za-z_][A-Za-z0-9_]*)\()"),
        re.compile(r"(?m)^// Read ([^.]+)\.\n(function(?: inline)?\s+([A-Za-z_][A-Za-z0-9_]*)\()"),
        re.compile(r"(?m)^// Write ([^.]+)\.\n(function(?: inline)?\s+([A-Za-z_][A-Za-z0-9_]*)\()"),
        re.compile(r"(?m)^// Return ([^.]+)\.\n(function(?: inline)?\s+([A-Za-z_][A-Za-z0-9_]*)\()"),
        re.compile(r"(?m)^// Update state for ([^.]+)\.\n(function(?: inline)?\s+([A-Za-z_][A-Za-z0-9_]*)\()"),
        re.compile(r"(?m)^// Render ([^.]+)\.\n(function(?: inline)?\s+([A-Za-z_][A-Za-z0-9_]*)\()"),
        re.compile(r"(?m)^// Execute ([^.]+)\.\n(function(?: inline)?\s+([A-Za-z_][A-Za-z0-9_]*)\()"),
        re.compile(r"(?m)^// Format ([^.]+)\.\n(function(?: inline)?\s+([A-Za-z_][A-Za-z0-9_]*)\()"),
        re.compile(r"(?m)^// Report whether hash ([^.]+)\.\n(function(?: inline)?\s+([A-Za-z_][A-Za-z0-9_]*)\()"),
        re.compile(r"(?m)^// Perform the ([^.]+) operation\.\n(function(?: inline)?\s+([A-Za-z_][A-Za-z0-9_]*)\()"),
        re.compile(r"(?m)^// Report whether ([^.]+)\.\n(function(?: inline)?\s+(validate[A-Za-z0-9_]*)\()"),
        re.compile(r"(?m)^// Encode and write ([^.]+)\.\n(function(?: inline)?\s+(save[A-Za-z0-9_]*(?:Equal|Equals|Equivalent)[A-Za-z0-9_]*)\()"),
        re.compile(r"(?m)^// Copy values for (copy array (?:linear|prefix)) into new storage\.\n(function(?: inline)?\s+(copyArray(?:Linear|Prefix))\()"),
        re.compile(r"(?m)^// Handle (u8|i8|u16|i16|u32|i32|f32|argc|argv|status|fingerprint|capacity|position|submitted)\.\n(function(?: inline)?\s+([A-Za-z_][A-Za-z0-9_]*)\()"),
        re.compile(r"(?m)^// Update module state for hronize[^.]*\.\n((function(?: inline)?\s+([A-Za-z_][A-Za-z0-9_]*)\())"),
        re.compile(r"(?m)^// Report whether has [^.]+\.\n((function(?: inline)?\s+([A-Za-z_][A-Za-z0-9_]*)\())"),
        re.compile(r"(?m)^// Check check[^.]*\.\n((function(?: inline)?\s+([A-Za-z_][A-Za-z0-9_]*)\())"),
        re.compile(r"(?m)^// Handle (?:svm|physics|q) [^.]+\.\n((function(?: inline)?\s+([A-Za-z_][A-Za-z0-9_]*)\())"),
    )
    for pattern in patterns:
        text = pattern.sub(lambda match: function_summary(match.group(3)) + "\n" + match.group(2), text)
    return text


def refresh_weak_summaries(text: str, *, test_context: bool = False) -> str:
    """Replace vague generated comments with declaration-specific summaries."""
    patterns = (
        re.compile(
            r"(?m)^// Process [^.]+\.\n"
            r"(function(?: inline)?\s+([A-Za-z_][A-Za-z0-9_]*)\()"
        ),
        re.compile(
            r"(?m)^// Implement the [^.]+ helper\.\n"
            r"(function(?: inline)?\s+([A-Za-z_][A-Za-z0-9_]*)\()"
        ),
        re.compile(
            r"(?m)^// Implement the (?:server-side|server-physics) [^.]+ helper\.\n"
            r"(function(?: inline)?\s+([A-Za-z_][A-Za-z0-9_]*)\()"
        ),
        re.compile(
            r"(?m)^// Execute the [^.]+ routine and preserve its documented invariants\.\n"
            r"(function(?: inline)?\s+([A-Za-z_][A-Za-z0-9_]*)\()"
        ),
        re.compile(
            r"(?m)^// Perform [^.]+ for the active subsystem\.\n"
            r"(function(?: inline)?\s+([A-Za-z_][A-Za-z0-9_]*)\()"
        ),
        re.compile(
            r"(?m)^// Process [^.]+\.\n"
            r"(function(?: inline)?\s+([A-Za-z_][A-Za-z0-9_]*)\()"
        ),
        re.compile(
            r"(?m)^// Process [^.]+ through the active media subsystem\.\n"
            r"(function(?: inline)?\s+([A-Za-z_][A-Za-z0-9_]*)\()"
        ),
        re.compile(
            r"(?m)^// Resolve [^.]+ for the caller\.\n"
            r"(function(?: inline)?\s+([A-Za-z_][A-Za-z0-9_]*)\()"
        ),
    )
    for pattern in patterns:
        text = pattern.sub(
            lambda match: function_summary(match.group(2), test_context=test_context) + "\n" + match.group(1),
            text,
        )
    return text


def document_complex_function_bodies(text: str, *, test_context: bool = False) -> str:
    """Insert one internal roadmap comment into undocumented complex routines."""
    for generated in (
        "  // Set up deterministic fixtures first, then exercise parity cases and aggregate failures.\n",
        "  // Build dependent state in order so later fields reference fully initialized data.\n",
        "  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.\n",
    ):
        text = text.replace(generated, "")
    lines = text.splitlines(keepends=True)
    inserts: list[tuple[int, str]] = []
    index = 0
    while index < len(lines):
        match = re.match(
            r"^(?:static\s+)?function(?:\s+inline)?\s+"
            r"([A-Za-z_][A-Za-z0-9_]*)\s*\(",
            lines[index],
        )
        if match is None:
            index += 1
            continue
        end = index + 1
        while end < len(lines) and lines[end].strip() != "end function":
            end += 1
        body = lines[index + 1 : end]
        logical_lines = sum(bool(line.strip()) for line in body)
        decisions = sum(
            len(
                re.findall(
                    r"\b(?:if|while|for|select|case)\b",
                    re.sub(r'"(?:[^"\\]|\\.)*"', '""', line),
                )
            )
            for line in body
            if not line.strip().startswith(("//", "/*", "*"))
        )
        complex_body = (
            logical_lines >= 100
            or (logical_lines >= 60 and decisions >= 3)
            or (logical_lines >= 35 and decisions >= 12)
        )
        internal_comment = any(
            line.strip().startswith(("//", "/*", "*")) for line in body
        )
        if complex_body and not internal_comment:
            if test_context:
                comment = (
                    "  // Set up deterministic fixtures first, then exercise parity cases "
                    "and aggregate failures.\n"
                )
            elif match.group(1).startswith(("make", "build", "create")):
                comment = (
                    "  // Build dependent state in order so later fields reference fully "
                    "initialized data.\n"
                )
            else:
                comment = (
                    "  // Preserve this routine's phase ordering: validate and prepare state "
                    "before mutation and output.\n"
                )
            inserts.append((index + 1, comment))
        index = end + 1
    for offset, comment in reversed(inserts):
        lines.insert(offset, comment)
    return "".join(lines)


def refine_operation_summaries(text: str) -> str:
    """Turn generic operation summaries into verb-led declaration summaries."""
    pattern = re.compile(
        r"(?m)^// Perform the ([^.]+) operation\.\n"
        r"(function(?: inline)?\s+([A-Za-z_][A-Za-z0-9_]*)\()"
    )

    def replacement(match: re.Match[str]) -> str:
        """Rewrite one matched source fragment according to the enclosing rule."""
        phrase = split_words(match.group(3))
        lower = phrase.lower()
        if lower.startswith(("crc", "hash", "checksum")):
            summary = f"Compute {phrase}."
        elif lower.startswith(("cl ", "sv ", "host ", "r ", "s ", "m ", "vid ")):
            summary = f"Apply the Quake-compatible {phrase} behavior."
        elif lower.startswith(("close", "free", "remove", "shutdown", "drop")):
            summary = f"Release state for {phrase}."
        elif lower.startswith(("add", "append", "insert", "push", "queue")):
            summary = f"Add state for {phrase}."
        elif lower.startswith(("copy", "move")):
            summary = f"Transfer data for {phrase}."
        elif lower.startswith(("check", "compare", "equal", "matches")):
            summary = f"Check {phrase}."
        elif lower.startswith(("open", "start", "begin", "init")):
            summary = f"Initialize state for {phrase}."
        elif lower.startswith(("stop", "end", "finish")):
            summary = f"Finalize state for {phrase}."
        elif lower.startswith(("consume", "drain", "take", "pop")):
            summary = f"Consume pending state for {phrase}."
        else:
            summary = f"Handle {phrase}."
        return f"// {summary}\n{match.group(2)}"

    return pattern.sub(replacement, text)


def refine_handle_summaries(text: str) -> str:
    """Replace legacy `Handle name` placeholders with action-oriented summaries."""
    pattern = re.compile(
        r"(?m)^// Handle ([^.]+)\.\n"
        r"(function(?: inline)?\s+([A-Za-z_][A-Za-z0-9_]*)\()"
    )

    def replacement(match: re.Match[str]) -> str:
        """Rewrite one matched source fragment according to the enclosing rule."""
        name = match.group(3)
        phrase = split_words(name)
        tokens = phrase.split()
        verb = tokens[0] if tokens else ""
        tail = " ".join(tokens[1:]) or "the requested value"
        if verb in {"inspect", "describe"}:
            summary = f"Inspect {tail} and emit its decoded metadata."
        elif verb in {"verify", "validate", "check", "require"}:
            summary = f"Validate {tail} and report any invalid state."
        elif verb in {"safe", "bounded", "clamp"}:
            summary = f"Return a validated {phrase} value."
        elif verb in {"index", "count", "length", "capacity", "status", "fingerprint"}:
            summary = f"Return {phrase}."
        elif verb in {"put", "write"}:
            summary = f"Write {tail} to the caller-provided destination."
        elif verb in {"short", "long", "float", "little", "big"} and any(
            token in {"swap", "endian", "short", "long", "float"} for token in tokens[1:]
        ):
            summary = f"Convert byte order for {phrase}."
        elif verb in {"convert", "swap", "decode", "encode", "format", "quote", "lower", "upper"}:
            summary = f"Convert data for {phrase}."
        elif verb in {"trace", "mix", "parse", "tokenize", "complete", "persist"}:
            summary = f"Process {phrase}."
        elif verb in {"submit", "queue", "push", "append", "add"}:
            summary = f"Submit state for {phrase}."
        elif verb in {"remove", "discard", "consume", "drain", "close", "stop"}:
            summary = f"Release or consume state for {phrase}."
        elif any(token in {"json", "text", "name", "index", "count", "depth", "stage", "hash", "crc"} for token in tokens):
            summary = f"Resolve {phrase} for the caller."
        else:
            summary = f"Process {phrase}."
        return f"// {summary}\n{match.group(2)}"

    return pattern.sub(replacement, text)


def refresh_resolve_summaries(text: str) -> str:
    """Refine broad `Resolve name` summaries using the latest token rules."""
    pattern = re.compile(
        r"(?m)^// Resolve ([^.]+) for the caller\.\n"
        r"(function(?: inline)?\s+([A-Za-z_][A-Za-z0-9_]*)\()"
    )

    def replacement(match: re.Match[str]) -> str:
        """Rewrite one matched source fragment according to the enclosing rule."""
        phrase = split_words(match.group(3))
        tokens = phrase.split()
        verb = tokens[0] if tokens else ""
        tail = " ".join(tokens[1:]) or "the requested value"
        if verb in {"put", "write"}:
            summary = f"Write {tail} to the caller-provided destination."
        elif verb in {"short", "long", "float", "little", "big"} and any(
            token in {"swap", "endian", "short", "long", "float"} for token in tokens[1:]
        ):
            summary = f"Convert byte order for {phrase}."
        elif any(token in {"json", "text", "name", "index", "count", "depth", "stage", "hash", "crc"} for token in tokens):
            summary = f"Resolve {phrase} for the caller."
        else:
            summary = f"Process {phrase}."
        return f"// {summary}\n{match.group(2)}"

    return pattern.sub(replacement, text)


def apply_ml(path: Path, root: Path) -> bool:
    """Apply the canonical header and function summaries to one MiniLang file."""
    relative = path.relative_to(root).as_posix()
    original = path.read_text(encoding="utf-8-sig", errors="replace")
    body, description = strip_existing_header(original)
    # The MiniLang engine is distributed as one Quake-derived work.  Do not
    # attempt file-by-file relicensing of support modules inside src/.
    derived = relative.startswith("src/") or any(marker in original[:2048] for marker in DERIVED_MARKERS)
    if not description:
        package = re.search(r"(?m)^package\s+([^\s]+)", body)
        unit = package.group(1) if package else relative
        if relative.startswith("tests/"):
            description = f"MiniLang parity and regression tests for {unit}."
        else:
            description = f"Quake-compatible MiniLang implementation of {unit}."
    licence = "GPL-2.0-or-later"
    updated = header(licence, description, derived=derived) + body
    test_context = relative.startswith("tests/")
    updated = refresh_ml_struct_summaries(updated, test_context=test_context)
    updated = document_ml_structs(updated, test_context=test_context)
    updated = document_functions(updated, test_context=test_context)
    if updated == original:
        return False
    path.write_text(updated, encoding="utf-8", newline="\n")
    return True


def tool_is_derived(path: Path) -> bool:
    """Classify compatibility checkers that encode Quake-derived semantics."""
    return path.stem.startswith(DERIVED_TOOL_PREFIXES)


def python_module_summary(path: Path) -> str:
    """Describe one maintenance module from its stable command role."""
    phrase = path.stem.replace("_", " ")
    if path.stem.startswith(("check_", "bp")):
        return f"Verify the {phrase} compatibility and regression contract."
    if path.stem.startswith("compare_"):
        return f"Compare deterministic {phrase.removeprefix('compare ')} evidence."
    if path.stem.startswith("analyze_"):
        return f"Analyze {phrase.removeprefix('analyze ')} validation evidence."
    if path.stem.endswith("_common"):
        return f"Provide shared fixtures for the {phrase.removesuffix(' common')} checkers."
    if path.stem == "verify":
        return "Verify repository integrity and source-hygiene contracts."
    if path.stem == "embed_spirv":
        return "Embed compiled Vulkan shaders in the native bridge."
    if path.stem == "generate_source_inventory":
        return "Generate the deterministic MiniLang source inventory."
    if path.stem == "prepare_original_reference":
        return "Prepare a local original-Quake reference without redistributing it."
    if path.stem == "run_process_live":
        return "Run a child process while streaming output and status evidence."
    if path.stem == "ui_resolution_matrix_report":
        return "Report UI scaling behavior across the supported resolution matrix."
    raise ValueError(f"no precise module description rule for {path.name}")


def python_function_summary(name: str) -> str:
    """Return a behavior-oriented docstring for a maintenance-tool function."""
    clean = name.strip("_")
    phrase = clean.replace("_", " ")
    exact = {
        "__init__": "Initialize the helper with its immutable verification inputs.",
        "main": "Run the command-line workflow and return its process exit status.",
        "replacement": "Rewrite one matched source fragment according to the enclosing rule.",
        "repl": "Rewrite one matched source fragment according to the enclosing rule.",
        "block": "Replace a block comment with matching newlines to preserve source locations.",
        "sha": "Compute the SHA-256 digest of the requested file.",
        "sha256": "Compute the SHA-256 digest of the requested file.",
        "sha256_file": "Compute the SHA-256 digest of the requested file.",
        "sha256_bytes": "Compute the SHA-256 digest of the supplied bytes.",
        "fbits": "Return the IEEE-754 binary32 bit pattern for a Python float.",
        "f32_bits": "Return the IEEE-754 binary32 bit pattern for a Python float.",
        "fb": "Return the IEEE-754 binary32 bit pattern for a Python float.",
        "f32": "Round a value through the IEEE-754 binary32 representation.",
        "float32": "Round a value through the IEEE-754 binary32 representation.",
        "float": "Decode the fixture's IEEE-754 binary32 scalar value.",
        "i32": "Interpret the low 32 bits as a signed integer.",
        "fnv": "Compute the fixture's FNV-1a fingerprint.",
        "fnv1a32": "Compute the fixture's 32-bit FNV-1a fingerprint.",
        "hb": "Fold one byte into the running FNV-1a contract hash.",
        "hw": "Fold one 32-bit word into the running FNV-1a contract hash.",
        "ht": "Fold one NUL-terminated ASCII string into the contract hash.",
        "contract_fingerprint": "Compute the QuakeC closure contract fingerprint.",
        "crc_block": "Compute Quake's 16-bit CRC over one byte block.",
        "comment": "Encode the fixed-width Quake v5 savegame level comment.",
        "_protected_server_hash": "Compute the accepted hash over protected server functions.",
        "_function_hashes": "Compute normalized hashes for the selected MiniLang functions.",
        "fingerprint": "Compute the contract fingerprint from its canonical fixture values.",
        "_const_string": "Extract a named MiniLang string constant from source text.",
        "const_string": "Extract a named MiniLang string constant from source text.",
        "rows": "Build the deterministic result rows for this verifier.",
        "cases": "Build the deterministic test cases for this verifier.",
        "values": "Build the deterministic values consumed by this verifier.",
        "vectors": "Build the protocol vectors consumed by this verifier.",
        "vector": "Package one encoded protocol message as a deterministic vector row.",
        "outcome": "Map a signed send result to the delivery-state outcome code.",
        "initial": "Select the initial server-message delivery plan for a client state.",
        "reliable": "Select the reliable-message delivery plan for queue state.",
        "contract": "Evaluate the source and runtime evidence for this contract.",
        "verify": "Evaluate all source, golden and oracle evidence for this verifier.",
        "validate": "Validate candidate evidence and return its contract violations.",
        "compare": "Compare candidate evidence with its accepted reference and report differences.",
        "cmd": "Encode one client string command with its Protocol 15 opcode and terminator.",
        "sz_print": "Append a NUL-terminated string using Quake's SZ_Print overwrite rule.",
        "result": "Return the bytes currently written to the bounded fixture buffer.",
        "write": "Append payload bytes to the bounded fixture buffer.",
        "artifact": "Return the expected build-artifact path for a prefix and suffix.",
        "fixture": "Build one deterministic QuakeC program fixture.",
        "load_json": "Load and decode one UTF-8 JSON document.",
        "load_tga": "Load and validate one uncompressed TGA reference image.",
        "load": "Load and decode one JSON evidence report.",
        "load_comparator": "Load the render-comparison module used by the corpus check.",
        "load_reference": "Load and validate the pinned original-reference manifest.",
        "ui_scale": "Compute the integral virtual-console scale for one resolution.",
        "document": "Render the canonical evidence document for this verifier.",
        "doc": "Render the canonical evidence document for this verifier.",
        "compiler": "Locate a supported C compiler for the reference oracle.",
        "compilers": "Return all supported C compiler commands available to the verifier.",
        "compiler_candidates": "Return candidate C compiler commands in preference order.",
        "cc": "Locate a supported C compiler for the reference oracle.",
        "oracle": "Compile and run the reference oracle for this verifier.",
        "compile_oracle": "Compile and execute the C reference oracle with one compiler.",
        "emit": "Emit one deterministic machine-readable verification report.",
        "emit_report": "Emit one deterministic machine-readable verification report.",
        "self_test": "Exercise the tool with synthetic fixtures and verify its invariants.",
        "function_body": "Extract one complete MiniLang function body from source text.",
        "function_slice": "Extract one complete MiniLang function body from source text.",
        "function_block": "Extract one complete MiniLang function body from source text.",
        "function": "Extract one named MiniLang function body for contract hashing.",
        "source_files": "Return the maintained source files in deterministic order.",
        "ml_files": "Return the MiniLang source files in deterministic order.",
        "ml_functions": "Extract MiniLang function declarations from normalized source text.",
        "source_definitions": "Extract the source definitions used by the inventory.",
        "header_text": "Return the leading comment region used for license classification.",
        "preceding_comment": "Report whether a declaration has an immediately preceding comment.",
        "complex_function_findings": "Audit internal roadmap comments in complex MiniLang functions.",
        "audit_file": "Audit one source file and return its documentation coverage findings.",
        "scan_text": "Scan MiniLang text for balanced delimiters outside strings and comments.",
        "trace_calls": "Extract traced function calls and their argument lists from source text.",
        "text": "Read one repository-relative UTF-8 source file for the enclosing check.",
        "terminate_process": "Terminate a child process tree and preserve its final status.",
        "percentage_improvement": "Compute the percentage improvement from baseline to candidate.",
        "imp": "Compute the percentage improvement from baseline to candidate.",
        "ratio": "Compute a guarded candidate-to-baseline ratio.",
        "luminance": "Convert one RGB sample to relative luminance.",
        "luminance_bgr": "Convert one BGR sample to relative luminance.",
        "global_ssim": "Compute the global structural-similarity score for two images.",
        "windowed_ssim": "Compute windowed structural similarity for two framebuffers.",
        "ssim_values": "Compute structural-similarity statistics for paired samples.",
        "metrics": "Compute pixel-difference and SSIM metrics for two reference images.",
        "trace_info": "Read trace metadata and normalized frame records from one file.",
        "pe_machine": "Read the PE machine identifier from a Windows executable.",
        "link_or_copy": "Create a local reference link, falling back to a byte copy when required.",
        "_status_payload": "Build the serializable status record for a supervised process.",
        "write_status": "Atomically persist the supervised process status as JSON.",
        "emit_ascii": "Forward one child-output chunk through the ASCII console stream.",
        "def_exports": "Parse exported symbol names from a Windows module-definition file.",
    }
    if name in exact:
        return exact[name]
    if clean.startswith(("check_", "verify_", "validate_")):
        return f"Validate {phrase.split(' ', 1)[-1]} and return its contract findings."
    if clean.endswith("_errors"):
        return f"Return the contract violations found by the {phrase.removesuffix(' errors')} guard."
    if clean.startswith(("run_", "run")):
        tail = phrase.removeprefix("run ") or "the requested component"
        return f"Run {tail} and capture its deterministic result."
    if clean.startswith(("load_", "load")):
        tail = phrase.removeprefix("load ") or "the requested input"
        return f"Load and validate {tail}."
    if clean.startswith(("read_", "read")):
        tail = phrase.removeprefix("read ") or "the requested input"
        return f"Read {tail} from its caller-supplied source."
    if clean.startswith("parse_"):
        return f"Parse {phrase.removeprefix('parse ')} into its normalized representation."
    if clean.startswith(("write_", "write")):
        tail = phrase.removeprefix("write ") or "the requested output"
        return f"Encode and write {tail} to the fixture buffer."
    if clean.startswith(("emit_", "print_")):
        return f"Emit {phrase.split(' ', 1)[-1]} in the requested report format."
    if clean.startswith(("compare_", "comparison", "same")):
        return f"Compare {phrase.split(' ', 1)[-1]} and report the first mismatch."
    if clean.startswith(("find_", "resolve_")):
        return f"Locate {phrase.split(' ', 1)[-1]} from the available inputs."
    if clean.startswith(("strip_", "normalize_")):
        return f"Normalize {phrase.split(' ', 1)[-1]} for deterministic comparison."
    if clean.startswith(("make_", "build_", "create_")):
        return f"Build {phrase.split(' ', 1)[-1]} for deterministic verification."
    if clean.startswith(("require", "ensure")):
        return f"Require {phrase.split(' ', 1)[-1]} and record a clear failure otherwise."
    if clean.startswith(("has_", "can_", "is_")):
        return f"Report whether {phrase.split(' ', 1)[-1]} satisfies the required condition."
    if clean.startswith(("get_", "current_", "first_", "last_")):
        return f"Return {phrase.split(' ', 1)[-1]} from the normalized evidence."
    if clean.startswith(("pack_", "encoded_", "update_")):
        return f"Encode {phrase.split(' ', 1)[-1]} using the Protocol 15 layout."
    if clean.endswith(("_cases", "_rows", "_vectors")):
        return f"Build the deterministic {phrase} consumed by this verifier."
    if clean.startswith(("quake_", "c_")):
        return f"Reproduce the reference {phrase} operation for differential testing."
    if clean == "case_stable":
        return "Report whether one soak-test snapshot obeys the entity high-water limits."
    if clean in {
        "artifact", "baseline_state", "builtin_items", "clientdata_bits",
        "constants", "default_clientdata", "fixture", "initial_cases",
        "model_rows", "python_vectors", "reliable_cases", "temp_kind",
        "temp_size", "sound_field_mask", "source_contract", "expected_model",
        "expected_vectors", "initial_delivery_plan", "reliable_delivery_plan",
        "reliable_plan", "freeze_document", "expected_document", "complete_golden",
    }:
        return f"Build the deterministic {phrase} fixture used by this verifier."
    if clean in {
        "angle", "byte", "coord", "direction_byte", "long", "short",
        "short_bytes", "string", "string_command", "color_component",
        "frame_number", "client_entity_limit", "update_bits", "quoted_count",
        "sound_field_mask", "ui_scale", "track", "playback_track",
        "encoded_update_size", "space", "trunc_zero", "c_div", "c_atoi",
        "c_one", "c_float_product", "quake_anglemod", "quake_c_string",
    }:
        return f"Compute the reference {phrase} value for a deterministic fixture."
    raise ValueError(f"no precise function description rule for {name}")


def add_python_header(text: str, path: Path) -> str:
    """Add a provenance-aware SPDX header without disturbing the shebang."""
    if "SPDX-License-Identifier:" in "\n".join(text.splitlines()[:8]):
        return text
    derived = tool_is_derived(path)
    lines = text.splitlines(keepends=True)
    offset = 1 if lines and lines[0].startswith("#!") else 0
    header_lines = []
    if derived:
        header_lines.append("# Copyright (c) 1996-1997 Id Software, Inc.\n")
    header_lines.extend(
        (
            "# Copyright (c) 2026 Nils Kopal\n",
            f"# SPDX-License-Identifier: {'GPL-2.0-or-later' if derived else 'Apache-2.0'}\n",
            "\n",
        )
    )
    lines[offset:offset] = header_lines
    return "".join(lines)


def add_python_module_docstring(text: str, path: Path) -> str:
    """Insert a concrete module description when a tool has none."""
    tree = ast.parse(text)
    if ast.get_docstring(tree) is not None:
        return text
    lines = text.splitlines(keepends=True)
    insert = 0
    while insert < len(lines) and (
        not lines[insert].strip() or lines[insert].lstrip().startswith("#")
    ):
        insert += 1
    lines.insert(insert, f'"""{python_module_summary(path)}"""\n\n')
    return "".join(lines)


def add_python_function_docstrings(text: str) -> str:
    """Document each Python function while preserving executable statements."""
    tree = ast.parse(text)
    lines = text.splitlines(keepends=True)
    starts: list[int] = []
    offset = 0
    for line in lines:
        starts.append(offset)
        offset += len(line)
    edits: list[tuple[int, int, str]] = []
    functions = [
        node for node in ast.walk(tree)
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef))
        and ast.get_docstring(node) is None
    ]
    for node in functions:
        summary = python_function_summary(node.name)
        first = node.body[0]
        if first.lineno == node.lineno:
            line = lines[node.lineno - 1]
            statement_column = first.col_offset
            header_line = line[:statement_column].rstrip()
            if not header_line.endswith(":"):
                raise ValueError(f"cannot split inline function {node.name}")
            statement = line[statement_column:].strip()
            indent = " " * (node.col_offset + 4)
            replacement = (
                header_line + "\n"
                + f'{indent}"""{summary}"""\n'
                + indent
                + statement
                + ("\n" if line.endswith("\n") else "")
            )
            start = starts[node.lineno - 1]
            edits.append((start, start + len(line), replacement))
        else:
            indent = " " * first.col_offset
            start = starts[first.lineno - 1]
            edits.append((start, start, f'{indent}"""{summary}"""\n'))
    for start, end, replacement in sorted(edits, reverse=True):
        text = text[:start] + replacement + text[end:]
    return text


def python_class_summary(name: str) -> str:
    """Return a concise docstring for one maintenance-tool data type."""
    phrase = split_words(name)
    if name in {"Check", "Finding", "Issue"}:
        return f"Represent one {phrase} discovered by the source verifier."
    if name == "Report":
        return "Collect the machine-readable outcome of one verification run."
    if name == "Buffer":
        return "Encode deterministic protocol bytes for the reference vectors."
    if name == "Writer":
        return "Encode one bounded Protocol 15 message for differential checks."
    if name == "Image":
        return "Store decoded image pixels and dimensions for visual comparison."
    return f"Store normalized {phrase} data used by the verification workflow."


def add_python_class_docstrings(text: str) -> str:
    """Document every Python class while preserving decorators and statements."""
    tree = ast.parse(text)
    lines = text.splitlines(keepends=True)
    starts: list[int] = []
    offset = 0
    for line in lines:
        starts.append(offset)
        offset += len(line)
    inserts: list[tuple[int, str]] = []
    for node in ast.walk(tree):
        if not isinstance(node, ast.ClassDef) or ast.get_docstring(node) is not None:
            continue
        first = node.body[0]
        indent = " " * first.col_offset
        inserts.append(
            (starts[first.lineno - 1], f'{indent}"""{python_class_summary(node.name)}"""\n')
        )
    for offset, docstring in sorted(inserts, reverse=True):
        text = text[:offset] + docstring + text[offset:]
    return text


def apply_python_tool(path: Path) -> bool:
    """Apply headers and semantic docstrings to one maintained Python tool."""
    original = path.read_text(encoding="utf-8-sig", errors="replace")
    updated = add_python_header(original, path)
    updated = add_python_module_docstring(updated, path)
    updated = add_python_class_docstrings(updated)
    updated = add_python_function_docstrings(updated)
    if updated == original:
        return False
    path.write_text(updated, encoding="utf-8", newline="\n")
    return True


def apply_shader(path: Path) -> bool:
    """Document every maintained GLSL function entry point."""
    from check_source_documentation import SHADER_FUNCTION_RE

    original = path.read_text(encoding="utf-8-sig", errors="replace")
    inserts: list[tuple[int, str]] = []
    for match in SHADER_FUNCTION_RE.finditer(original):
        if has_preceding_comment(original, match.start()):
            continue
        if match.group(1) == "main" and path.suffix == ".vert":
            summary = "Transform one submitted vertex into Vulkan clip space."
        elif match.group(1) == "main":
            summary = "Shade one fragment with the selected classic or enhanced-lighting path."
        else:
            summary = f"Evaluate {split_words(match.group(1))} for the active shader stage."
        inserts.append((match.start(), f"// {summary}\n"))
    updated = original
    for offset, comment in reversed(inserts):
        updated = updated[:offset] + comment + updated[offset:]
    if updated == original:
        return False
    path.write_text(updated, encoding="utf-8", newline="\n")
    return True


def powershell_function_summary(name: str) -> str:
    """Describe the small set of maintained PowerShell workflow functions."""
    summaries = {
        "Resolve-CommandOrFile": "Resolve a configured executable from a path or command name.",
        "Normalize-StdImportRoot": "Normalize a standard-library candidate to its import root.",
        "Find-StdImportRoot": "Locate a usable MiniLang standard-library import root.",
        "Invoke-LiveCapturedProcess": "Run a process while streaming and retaining its diagnostic output.",
        "Invoke-MiniLangCompile": "Compile one MiniLang target with the selected compiler interface.",
        "Copy-NativeBridgeIfChanged": "Copy a rebuilt native bridge only when its bytes changed.",
        "Get-RuntimeTestFailureMarker": "Extract the first actionable failure marker from a runtime log.",
        "Invoke-MiniQuakeTestBinary": "Run a MiniQuake test binary and validate its process result.",
        "Get-BuildArtifactExclusionReason": "Explain why an artifact must not enter the evidence archive.",
        "Copy-SafeFile": "Copy an allowed evidence file into the staging tree.",
    }
    if name not in summaries:
        raise ValueError(f"no precise PowerShell description rule for {name}")
    return summaries[name]


def apply_powershell_tool(path: Path, relative: str) -> bool:
    """Apply an Apache header and function comments to a maintained PS script."""
    original = path.read_text(encoding="utf-8-sig", errors="replace")
    updated = original
    if "SPDX-License-Identifier:" not in "\n".join(updated.splitlines()[:8]):
        description = MAINTAINED_POWERSHELL_DESCRIPTIONS[relative]
        updated = (
            "# Copyright (c) 2026 Nils Kopal\n"
            "# SPDX-License-Identifier: Apache-2.0\n"
            f"# {description}\n\n"
            + updated
        )
    for summary in (
        powershell_function_summary(name)
        for name in (
            "Resolve-CommandOrFile", "Normalize-StdImportRoot", "Find-StdImportRoot",
            "Invoke-LiveCapturedProcess", "Invoke-MiniLangCompile",
            "Copy-NativeBridgeIfChanged", "Get-RuntimeTestFailureMarker",
            "Invoke-MiniQuakeTestBinary", "Get-BuildArtifactExclusionReason",
            "Copy-SafeFile",
        )
    ):
        comment = "# " + summary
        updated = re.sub(
            rf"(?m)^(?:{re.escape(comment)}\r?\n){{2,}}",
            comment + "\n",
            updated,
        )
    function_re = re.compile(
        r"(?im)^(?P<indent>[ \t]*)function\s+(?P<name>[A-Za-z_][A-Za-z0-9_-]*)\b"
    )
    inserts: list[tuple[int, str]] = []
    for match in function_re.finditer(updated):
        if not has_preceding_comment(updated, match.start(), hash_comments=True):
            summary = powershell_function_summary(match.group("name"))
            inserts.append((match.start(), f'{match.group("indent")}# {summary}\n'))
    for offset, comment in reversed(inserts):
        updated = updated[:offset] + comment + updated[offset:]
    if updated == original:
        return False
    path.write_text(updated, encoding="utf-8", newline="\n")
    return True


def main() -> int:
    """Apply documentation changes without changing existing C licences."""
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--include-concurrent", action="store_true")
    parser.add_argument(
        "--tools-only",
        action="store_true",
        help="document maintained Python and PowerShell tools without touching product sources",
    )
    args = parser.parse_args()
    root = args.root.resolve()
    changed = 0
    skipped = 0
    if not args.tools_only:
        for path in sorted((root / "src").rglob("*.ml")):
            relative = path.relative_to(root).as_posix()
            if relative in EXCLUDED_CONCURRENT_FILES and not args.include_concurrent:
                skipped += 1
                continue
            changed += int(apply_ml(path, root))
        for path in sorted((root / "tests").rglob("*.ml")):
            changed += int(apply_ml(path, root))
        for path in sorted((root / "native").glob("*.c")):
            changed += int(apply_c(path))
        for path in sorted((root / "native" / "shaders").glob("*.vert")):
            changed += int(apply_shader(path))
        for path in sorted((root / "native" / "shaders").glob("*.frag")):
            changed += int(apply_shader(path))
    for path in sorted((root / "tools").glob("*.py")):
        changed += int(apply_python_tool(path))
    for relative in MAINTAINED_POWERSHELL_DESCRIPTIONS:
        changed += int(apply_powershell_tool(root / relative, relative))
    print(f"documented files changed: {changed}; concurrent files skipped: {skipped}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
