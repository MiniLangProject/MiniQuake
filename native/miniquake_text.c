/*
 * MiniQuake caller-owned text bridge.
 *
 * MiniLang compiler v1.0 can pass a bytes payload to extern functions, but a
 * direct `returns cstr` from a high-address Win64 DLL may be truncated before
 * the runtime copies it.  This shim calls the legacy string exports in
 * miniquake_native.dll inside native code and copies the result into storage
 * owned by MiniLang.
 */
typedef unsigned char mq_u8;
typedef unsigned short mq_u16;
typedef unsigned int mq_u32;
typedef unsigned long long mq_u64;
typedef signed int mq_i32;
typedef void *mq_ptr;
typedef mq_ptr HMODULE;
typedef const mq_u16 *LPCWSTR;
typedef const char *LPCSTR;
typedef mq_ptr FARPROC;

#define MQ_EXPORT __declspec(dllexport)
#define MQ_DLLIMPORT __declspec(dllimport)
#define MQ_WINAPI __stdcall
#define MQ_CDECL __cdecl
#define MQ_NULL ((void *)0)

/* Required by MSVC-compatible code generation whenever float values appear. */
int _fltused = 0;

MQ_DLLIMPORT HMODULE MQ_WINAPI GetModuleHandleW(LPCWSTR module_name);
MQ_DLLIMPORT HMODULE MQ_WINAPI LoadLibraryW(LPCWSTR file_name);
MQ_DLLIMPORT FARPROC MQ_WINAPI GetProcAddress(HMODULE module, LPCSTR name);

static HMODULE mq_backend_module = MQ_NULL;
static const mq_u16 mq_backend_name[] = {
    'm','i','n','i','q','u','a','k','e','_','n','a','t','i','v','e','.','d','l','l',0
};

static HMODULE mq_crt_module = MQ_NULL;
static const mq_u16 mq_crt_name[] = {
    'm','s','v','c','r','t','.','d','l','l',0
};

static FARPROC mq_backend_proc(const char *name) {
    if (mq_backend_module == MQ_NULL) {
        mq_backend_module = GetModuleHandleW(mq_backend_name);
        if (mq_backend_module == MQ_NULL) {
            mq_backend_module = LoadLibraryW(mq_backend_name);
        }
    }
    if (mq_backend_module == MQ_NULL || name == MQ_NULL) {
        return MQ_NULL;
    }
    return GetProcAddress(mq_backend_module, name);
}

static FARPROC mq_crt_proc(const char *name) {
    if (mq_crt_module == MQ_NULL) {
        mq_crt_module = GetModuleHandleW(mq_crt_name);
        if (mq_crt_module == MQ_NULL) {
            mq_crt_module = LoadLibraryW(mq_crt_name);
        }
    }
    if (mq_crt_module == MQ_NULL || name == MQ_NULL) {
        return MQ_NULL;
    }
    return GetProcAddress(mq_crt_module, name);
}

static float mq_bits_to_float(mq_u32 bits) {
    union {
        mq_u32 word;
        float value;
    } converted;
    converted.word = bits;
    return converted.value;
}

static mq_u32 mq_copy_text(void *destination_value, mq_u32 capacity, const char *source) {
    mq_u8 *destination = (mq_u8 *)destination_value;
    mq_u32 index = 0;
    if (destination == MQ_NULL || capacity == 0 || source == MQ_NULL) {
        return 0;
    }
    while (index < capacity && source[index] != 0) {
        destination[index] = (mq_u8)source[index];
        ++index;
    }
    return index;
}

typedef const char *(*mq_text_u32_fn)(mq_u32);
typedef const char *(*mq_text_i32_fn)(mq_i32);
typedef const char *(*mq_text_i32_i32_fn)(mq_i32, mq_i32);
typedef const char *(*mq_text_ptr_u32_fn)(mq_ptr, mq_u32);
typedef const char *(*mq_text_u64_fn)(mq_u64);
typedef const char *(*mq_text_void_fn)(void);
typedef const char *(*mq_text_cstr_fn)(const char *);
typedef int (MQ_CDECL *mq_sprintf_fn)(char *, const char *, ...);

MQ_EXPORT mq_u32 mqt_f32_to_text(mq_u32 bits, void *destination, mq_u32 capacity) {
    mq_text_u32_fn function_value = (mq_text_u32_fn)mq_backend_proc("mq_f32_to_text");
    return function_value != MQ_NULL ? mq_copy_text(destination, capacity, function_value(bits)) : 0;
}

/*
 * WinQuake writes Cvars, QuakeC fields and savegame floats with printf("%f").
 * Formatting by first multiplying the complete value by 1,000,000 and
 * truncating to i32 overflows for perfectly ordinary Quake values such as the
 * 4097 item bitmask.  Resolve the same MSVCRT formatter used by the main bridge
 * and copy its six-decimal result into caller-owned MiniLang storage.
 */
MQ_EXPORT mq_u32 mqt_f32_to_fixed6(
    mq_u32 bits,
    void *destination,
    mq_u32 capacity
) {
    char formatted[96];
    mq_sprintf_fn function_value =
        (mq_sprintf_fn)mq_crt_proc("sprintf");
    int written;
    if (function_value == MQ_NULL) {
        return 0;
    }
    written = function_value(
        formatted,
        "%.6f",
        (double)mq_bits_to_float(bits)
    );
    if (written < 0) {
        return 0;
    }
    return mq_copy_text(destination, capacity, formatted);
}

MQ_EXPORT mq_u32 mqt_ascii_char(mq_i32 value, void *destination_value, mq_u32 capacity) {
    mq_u8 *destination = (mq_u8 *)destination_value;
    mq_u32 code = (mq_u32)value & 255u;
    mq_text_i32_fn function_value =
        (mq_text_i32_fn)mq_backend_proc("mq_ascii_char");
    if (destination == MQ_NULL || capacity == 0 || code == 0) {
        return 0;
    }
    if (code < 0x80u) {
        return function_value != MQ_NULL
            ? mq_copy_text(destination, capacity, function_value(value))
            : 0;
    }
    /* Represent the original byte as Unicode U+0080..U+00FF in UTF-8. */
    if (capacity < 2u) {
        return 0;
    }
    destination[0] = (mq_u8)(0xC0u | (code >> 6));
    destination[1] = (mq_u8)(0x80u | (code & 0x3Fu));
    return 2;
}

MQ_EXPORT mq_u32 mqt_conproc_read_text(
    mq_ptr mapped,
    mq_u32 byte_offset,
    void *destination,
    mq_u32 capacity
) {
    mq_text_ptr_u32_fn function_value =
        (mq_text_ptr_u32_fn)mq_backend_proc("mq_conproc_read_text");
    return function_value != MQ_NULL
        ? mq_copy_text(destination, capacity, function_value(mapped, byte_offset))
        : 0;
}

MQ_EXPORT mq_u32 mqt_conproc_read_console_text(
    mq_i32 begin_line,
    mq_i32 end_line,
    void *destination,
    mq_u32 capacity
) {
    mq_text_i32_i32_fn function_value =
        (mq_text_i32_i32_fn)mq_backend_proc("mq_conproc_read_console_text");
    return function_value != MQ_NULL
        ? mq_copy_text(destination, capacity, function_value(begin_line, end_line))
        : 0;
}

MQ_EXPORT mq_u32 mqt_udp_bound_address(
    mq_u64 handle,
    void *destination,
    mq_u32 capacity
) {
    mq_text_u64_fn function_value =
        (mq_text_u64_fn)mq_backend_proc("mq_udp_bound_address");
    return function_value != MQ_NULL
        ? mq_copy_text(destination, capacity, function_value(handle))
        : 0;
}

MQ_EXPORT mq_u32 mqt_udp_last_address(void *destination, mq_u32 capacity) {
    mq_text_void_fn function_value =
        (mq_text_void_fn)mq_backend_proc("mq_udp_last_address");
    return function_value != MQ_NULL
        ? mq_copy_text(destination, capacity, function_value())
        : 0;
}

MQ_EXPORT mq_u32 mqt_udp_local_address(void *destination, mq_u32 capacity) {
    mq_text_void_fn function_value =
        (mq_text_void_fn)mq_backend_proc("mq_udp_local_address");
    return function_value != MQ_NULL
        ? mq_copy_text(destination, capacity, function_value())
        : 0;
}

MQ_EXPORT mq_u32 mqt_udp_host_name(void *destination, mq_u32 capacity) {
    mq_text_void_fn function_value =
        (mq_text_void_fn)mq_backend_proc("mq_udp_host_name");
    return function_value != MQ_NULL
        ? mq_copy_text(destination, capacity, function_value())
        : 0;
}

MQ_EXPORT mq_u32 mqt_udp_resolve_name(
    const char *name,
    void *destination,
    mq_u32 capacity
) {
    mq_text_cstr_fn function_value =
        (mq_text_cstr_fn)mq_backend_proc("mq_udp_resolve_name");
    return function_value != MQ_NULL
        ? mq_copy_text(destination, capacity, function_value(name))
        : 0;
}

MQ_EXPORT mq_u32 mqt_udp_reverse_name(
    const char *address,
    void *destination,
    mq_u32 capacity
) {
    mq_text_cstr_fn function_value =
        (mq_text_cstr_fn)mq_backend_proc("mq_udp_reverse_name");
    return function_value != MQ_NULL
        ? mq_copy_text(destination, capacity, function_value(address))
        : 0;
}

MQ_EXPORT mq_u32 mqt_gl_get_string(
    mq_u32 name,
    void *destination,
    mq_u32 capacity
) {
    mq_text_u32_fn function_value =
        (mq_text_u32_fn)mq_backend_proc("mq_gl_get_string");
    return function_value != MQ_NULL
        ? mq_copy_text(destination, capacity, function_value(name))
        : 0;
}
