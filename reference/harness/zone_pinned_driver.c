#include "zone_oracle_stubs.h"

int _fltused = 0;
int com_argc;
char **com_argv;

static byte arena[131072];
static int print_count;
static int command_count;
static int sys_errors;
static int fatal_mode;
static char arg0[] = "miniquake";
static char arg1[] = "-zone";
static char arg2[] = "1";
static char *default_argv[] = {arg0, arg1, arg2};

typedef struct oracle_memblock_s {
    int size;
    int tag;
    int id;
    struct oracle_memblock_s *next;
    struct oracle_memblock_s *prev;
    int pad;
} oracle_memblock_t;

typedef struct {
    int size;
    oracle_memblock_t blocklist;
    oracle_memblock_t *rover;
} oracle_memzone_t;

typedef struct cache_system_s {
    int size;
    cache_user_t *user;
    char name[16];
    struct cache_system_s *prev;
    struct cache_system_s *next;
    struct cache_system_s *lru_prev;
    struct cache_system_s *lru_next;
} cache_system_t;

extern void *mainzone;
extern byte *hunk_base;
extern int hunk_size;
extern int hunk_low_used;
extern int hunk_high_used;
extern qboolean hunk_tempactive;
extern int hunk_tempmark;
extern cache_system_t cache_head;

void Z_ClearZone(void *, int);
void Z_Free(void *);
void *Z_Malloc(int);
void *Z_TagMalloc(int, int);
void Z_Print(void *);
void Z_CheckHeap(void);
void Hunk_Check(void);
void Hunk_Print(qboolean);
void *Hunk_AllocName(int, char *);
void *Hunk_Alloc(int);
int Hunk_LowMark(void);
void Hunk_FreeToLowMark(int);
int Hunk_HighMark(void);
void Hunk_FreeToHighMark(int);
void *Hunk_HighAllocName(int, char *);
void *Hunk_TempAlloc(int);
void Cache_Move(cache_system_t *);
void Cache_FreeLow(int);
void Cache_FreeHigh(int);
void Cache_UnlinkLRU(cache_system_t *);
void Cache_MakeLRU(cache_system_t *);
cache_system_t *Cache_TryAlloc(int, qboolean);
void Cache_Flush(void);
void Cache_Print(void);
void Cache_Report(void);
void Cache_Compact(void);
void Cache_Init(void);
void Cache_Free(cache_user_t *);
void *Cache_Check(cache_user_t *);
void *Cache_Alloc(cache_user_t *, int, char *);
void Memory_Init(void *, int);

void Sys_Error(char *format, ...)
{
    (void)format;
    ++sys_errors;
    if (fatal_mode)
    {
        volatile int *invalid = (int *)0;
        *invalid = 1;
    }
}

void Con_Printf(char *format, ...)
{
    (void)format;
    ++print_count;
}

void Con_DPrintf(char *format, ...)
{
    (void)format;
    ++print_count;
}

void *Q_memset(void *destination, int value, int count)
{
    return memset(destination, value, (unsigned __int64)count);
}

void *Q_memcpy(void *destination, const void *source, int count)
{
    return memcpy(destination, source, (unsigned __int64)count);
}

int mq_strncmp(const char *left, const char *right, unsigned __int64 count)
{
    unsigned __int64 index = 0;
    while (index < count && left[index] && left[index] == right[index])
        ++index;
    if (index == count)
        return 0;
    return (byte)left[index] - (byte)right[index];
}

char *mq_strncpy(char *destination, const char *source, unsigned __int64 count)
{
    unsigned __int64 index = 0;
    while (index < count && source[index])
    {
        destination[index] = source[index];
        ++index;
    }
    while (index < count)
        destination[index++] = 0;
    return destination;
}

char *Q_strncpy(char *destination, const char *source, int count)
{
    int index = 0;
    while (index < count && source[index])
    {
        destination[index] = source[index];
        ++index;
    }
    while (index < count)
        destination[index++] = 0;
    return destination;
}

static int string_equal(const char *left, const char *right)
{
    while (*left && *left == *right)
    {
        ++left;
        ++right;
    }
    return *left == *right;
}

void Cmd_AddCommand(char *name, void (*function)(void))
{
    (void)name;
    (void)function;
    ++command_count;
}

int COM_CheckParm(char *name)
{
    int index;
    for (index = 1; index < com_argc; ++index)
        if (string_equal(com_argv[index], name))
            return index;
    return 0;
}

int Q_atoi(char *value)
{
    int result = 0;
    int sign = 1;
    if (*value == '-')
    {
        sign = -1;
        ++value;
    }
    while (*value >= '0' && *value <= '9')
        result = result * 10 + (*value++ - '0');
    return result * sign;
}

void R_FreeTextures(void)
{
}

static void reset_memory(void)
{
    memset(arena, 0, sizeof(arena));
    com_argc = 3;
    com_argv = default_argv;
    print_count = 0;
    command_count = 0;
    sys_errors = 0;
    fatal_mode = 0;
    Memory_Init(arena, 32768);
}

static int zone_blocks(void)
{
    oracle_memzone_t *zone = (oracle_memzone_t *)mainzone;
    oracle_memblock_t *block = zone->blocklist.next;
    int count = 0;
    while (block != &zone->blocklist)
    {
        ++count;
        block = block->next;
        if (count > 128)
            return -1;
    }
    return count;
}

static int zone_free_blocks(void)
{
    oracle_memzone_t *zone = (oracle_memzone_t *)mainzone;
    oracle_memblock_t *block = zone->blocklist.next;
    int count = 0;
    while (block != &zone->blocklist)
    {
        if (block->tag == 0)
            ++count;
        block = block->next;
    }
    return count;
}

static int cache_blocks(void)
{
    cache_system_t *block;
    int count = 0;
    for (block = cache_head.next; block != &cache_head; block = block->next)
    {
        ++count;
        if (count > 128)
            return -1;
    }
    return count;
}

static cache_system_t *cache_header(cache_user_t *user)
{
    return ((cache_system_t *)user->data) - 1;
}

static int cache_offset(cache_user_t *user)
{
    return (int)((byte *)cache_header(user) - hunk_base);
}

static char *emit(
    char *output,
    const char *function,
    const char *case_name,
    int result,
    int index,
    float value,
    int count)
{
    output += sprintf(
        output,
        "{\"function\":\"%s\",\"case\":\"%s\",\"result\":%d,"
        "\"index\":%d,\"value\":%.9g,\"count\":%d}\n",
        function,
        case_name,
        result,
        index,
        value,
        count);
    return output;
}

__declspec(dllexport) int __cdecl zone_oracle_jsonl(char *output, int capacity)
{
    char *cursor = output;
    void *pointer;
    cache_system_t *cache;
    cache_user_t first;
    cache_user_t second;
    int mark;
    int before;
    int old_offset;
    int result;
    (void)capacity;

    reset_memory();
    Z_ClearZone(mainzone, 1024);
    cursor = emit(cursor, "Z_ClearZone", "single_free", zone_free_blocks() == 1, zone_blocks(), 0, 1);

    reset_memory();
    pointer = Z_TagMalloc(40, 2);
    Z_Free(pointer);
    cursor = emit(cursor, "Z_Free", "merge", zone_blocks() == 1, zone_free_blocks(), 0, 1);

    reset_memory();
    pointer = Z_Malloc(17);
    result = ((byte *)pointer)[0] == 0 && ((byte *)pointer)[16] == 0;
    cursor = emit(cursor, "Z_Malloc", "zeroed", result, zone_blocks(), 17, zone_free_blocks());

    reset_memory();
    pointer = Z_TagMalloc(33, 7);
    cursor = emit(cursor, "Z_TagMalloc", "tagged", pointer != NULL, zone_blocks(), 33, 7);

    reset_memory();
    Z_TagMalloc(24, 3);
    print_count = 0;
    Z_Print(mainzone);
    cursor = emit(cursor, "Z_Print", "two_blocks", 1, zone_blocks(), 0, print_count);

    reset_memory();
    Z_TagMalloc(24, 3);
    Z_CheckHeap();
    cursor = emit(cursor, "Z_CheckHeap", "consistent", sys_errors == 0, zone_blocks(), 0, zone_free_blocks());

    reset_memory();
    Hunk_AllocName(33, "check");
    Hunk_Check();
    cursor = emit(cursor, "Hunk_Check", "consistent", sys_errors == 0, hunk_low_used, 0, 1);

    reset_memory();
    Hunk_AllocName(17, "alpha");
    Hunk_HighAllocName(19, "beta");
    print_count = 0;
    Hunk_Print(true);
    cursor = emit(cursor, "Hunk_Print", "both_sides", 1, hunk_low_used, hunk_high_used, print_count);

    reset_memory();
    Hunk_AllocName(17, "alpha");
    Hunk_AllocName(1, "alpha");
    Hunk_HighAllocName(19, "beta");
    print_count = 0;
    Hunk_Print(false);
    cursor = emit(cursor, "Hunk_Print", "grouped_names", 1, hunk_low_used, hunk_high_used, print_count);

    reset_memory();
    before = hunk_low_used;
    pointer = Hunk_AllocName(17, "abcdefghijk");
    cursor = emit(cursor, "Hunk_AllocName", "aligned_named", pointer != NULL, hunk_low_used - before, 17, ((char *)pointer)[0] == 0);

    reset_memory();
    before = hunk_low_used;
    pointer = Hunk_Alloc(1);
    cursor = emit(cursor, "Hunk_Alloc", "unknown", pointer != NULL, hunk_low_used - before, 1, 1);

    reset_memory();
    Hunk_Alloc(20);
    mark = Hunk_LowMark();
    cursor = emit(cursor, "Hunk_LowMark", "after_alloc", mark, mark, 0, 1);

    reset_memory();
    mark = Hunk_LowMark();
    Hunk_Alloc(20);
    Hunk_FreeToLowMark(mark);
    cursor = emit(cursor, "Hunk_FreeToLowMark", "restore", hunk_low_used == mark, hunk_low_used, 0, 1);

    reset_memory();
    Hunk_TempAlloc(20);
    mark = Hunk_HighMark();
    cursor = emit(cursor, "Hunk_HighMark", "clears_temp", !hunk_tempactive, mark, hunk_high_used, 1);

    reset_memory();
    mark = Hunk_HighMark();
    Hunk_HighAllocName(20, "high");
    Hunk_FreeToHighMark(mark);
    cursor = emit(cursor, "Hunk_FreeToHighMark", "restore", hunk_high_used == mark, hunk_high_used, 0, 1);

    reset_memory();
    before = hunk_high_used;
    pointer = Hunk_HighAllocName(17, "highname");
    cursor = emit(cursor, "Hunk_HighAllocName", "aligned_named", pointer != NULL, hunk_high_used - before, 17, 1);

    reset_memory();
    before = hunk_high_used;
    pointer = Hunk_TempAlloc(17);
    cursor = emit(cursor, "Hunk_TempAlloc", "active", pointer != NULL, hunk_high_used - before, hunk_tempmark, hunk_tempactive);

    reset_memory();
    first.data = NULL;
    Cache_Alloc(&first, 64, "move");
    old_offset = cache_offset(&first);
    cache = cache_header(&first);
    Cache_Move(cache);
    result = first.data != NULL && cache_offset(&first) != old_offset;
    reset_memory();
    first.data = NULL;
    Cache_Alloc(&first, hunk_size - hunk_low_used - (int)sizeof(cache_system_t), "full");
    Cache_Move(cache_header(&first));
    cursor = emit(cursor, "Cache_Move", "relocate_or_release", result && first.data == NULL, 1, 64, cache_blocks());

    reset_memory();
    first.data = NULL;
    Cache_Alloc(&first, 64, "low");
    mark = hunk_low_used + 16;
    Cache_FreeLow(mark);
    result = first.data == NULL || cache_offset(&first) >= mark;
    cursor = emit(cursor, "Cache_FreeLow", "make_room", result, cache_blocks(), 64, first.data != NULL);

    reset_memory();
    first.data = NULL;
    Cache_Alloc(&first, 256, "high");
    mark = hunk_size - hunk_low_used - 64;
    Cache_FreeHigh(mark);
    result = first.data == NULL || cache_offset(&first) + cache_header(&first)->size <= hunk_size - mark;
    cursor = emit(cursor, "Cache_FreeHigh", "make_room", result, cache_blocks(), 256, first.data != NULL);

    reset_memory();
    first.data = NULL;
    Cache_Alloc(&first, 16, "unlink");
    cache = cache_header(&first);
    Cache_UnlinkLRU(cache);
    cursor = emit(cursor, "Cache_UnlinkLRU", "detach", cache->lru_next == NULL && cache->lru_prev == NULL, cache_blocks(), 0, 1);
    Cache_MakeLRU(cache);
    cursor = emit(cursor, "Cache_MakeLRU", "attach", cache->lru_next != NULL && cache->lru_prev != NULL, cache_blocks(), 0, 1);

    reset_memory();
    cache = Cache_TryAlloc(128, false);
    cursor = emit(cursor, "Cache_TryAlloc", "empty_bottom", cache != NULL, (int)((byte *)cache - hunk_base), 128, cache_blocks());

    reset_memory();
    first.data = NULL;
    second.data = NULL;
    Cache_Alloc(&first, 16, "first");
    Cache_Alloc(&second, 16, "second");
    Cache_Flush();
    cursor = emit(cursor, "Cache_Flush", "all", first.data == NULL && second.data == NULL, cache_blocks(), 0, 2);

    reset_memory();
    first.data = NULL;
    Cache_Alloc(&first, 16, "print");
    print_count = 0;
    Cache_Print();
    cursor = emit(cursor, "Cache_Print", "one", 1, cache_blocks(), 0, print_count);

    reset_memory();
    print_count = 0;
    Cache_Report();
    cursor = emit(cursor, "Cache_Report", "free_megabytes", 1, hunk_size - hunk_low_used - hunk_high_used, 0, print_count);

    reset_memory();
    Cache_Compact();
    cursor = emit(cursor, "Cache_Compact", "noop", 1, cache_blocks(), 0, 0);

    reset_memory();
    command_count = 0;
    Cache_Init();
    cursor = emit(cursor, "Cache_Init", "sentinels", cache_head.next == &cache_head && cache_head.lru_next == &cache_head, cache_blocks(), 0, command_count);

    reset_memory();
    first.data = NULL;
    Cache_Alloc(&first, 16, "free");
    Cache_Free(&first);
    cursor = emit(cursor, "Cache_Free", "release", first.data == NULL, cache_blocks(), 0, 1);

    reset_memory();
    first.data = NULL;
    second.data = NULL;
    Cache_Alloc(&first, 16, "check");
    Cache_Alloc(&second, 16, "other");
    pointer = Cache_Check(&first);
    cursor = emit(cursor, "Cache_Check", "touch_lru", pointer == first.data && pointer != NULL && cache_head.lru_next == cache_header(&first), cache_blocks(), 16, 2);

    reset_memory();
    first.data = NULL;
    pointer = Cache_Alloc(&first, 33, "allocate");
    cursor = emit(cursor, "Cache_Alloc", "new", pointer != NULL && pointer == first.data, cache_blocks(), 33, 1);

    memset(arena, 0, sizeof(arena));
    com_argc = 3;
    com_argv = default_argv;
    command_count = 0;
    Memory_Init(arena, 32768);
    cursor = emit(cursor, "Memory_Init", "zone_override", mainzone != NULL, hunk_low_used, hunk_size, command_count);

    *cursor = 0;
    return (int)(cursor - output);
}

__declspec(dllexport) int __cdecl zone_error_case(int mode)
{
    cache_user_t user;
    cache_system_t *cache;
    oracle_memzone_t *zone;
    char *missing_argv[] = {arg0, arg1};
    reset_memory();
    fatal_mode = 1;
    user.data = NULL;

    if (mode == 0)
        Z_Free(NULL);
    else if (mode == 1)
        Z_TagMalloc(8, 0);
    else if (mode == 2)
    {
        zone = (oracle_memzone_t *)mainzone;
        zone->blocklist.next->next = zone->blocklist.next;
        Z_CheckHeap();
    }
    else if (mode == 3)
    {
        Hunk_Alloc(16);
        ((int *)hunk_base)[0] = 0;
        Hunk_Check();
    }
    else if (mode == 4)
        Hunk_AllocName(-1, "bad");
    else if (mode == 5)
        Hunk_FreeToLowMark(hunk_low_used + 1);
    else if (mode == 6)
        Hunk_FreeToHighMark(hunk_high_used + 1);
    else if (mode == 7)
        Hunk_HighAllocName(-1, "bad");
    else if (mode == 8)
    {
        cache = Cache_TryAlloc(64, false);
        Cache_UnlinkLRU(cache);
        Cache_UnlinkLRU(cache);
    }
    else if (mode == 9)
    {
        user.data = Cache_Alloc(&user, 16, "active");
        Cache_MakeLRU(cache_header(&user));
    }
    else if (mode == 10)
        Cache_TryAlloc(hunk_size, false);
    else if (mode == 11)
        Cache_Free(&user);
    else if (mode == 12)
    {
        Cache_Alloc(&user, 16, "first");
        Cache_Alloc(&user, 16, "second");
    }
    else if (mode == 13)
        Cache_Alloc(&user, 0, "zero");
    else if (mode == 14)
    {
        com_argc = 2;
        com_argv = missing_argv;
        Memory_Init(arena, 32768);
    }
    else if (mode == 15)
        Z_Malloc(2048);
    else if (mode == 16)
        Hunk_AllocName(hunk_size, "overflow");
    else
    {
        void *pointer = Z_TagMalloc(8, 1);
        oracle_memblock_t *block =
            (oracle_memblock_t *)((byte *)pointer - sizeof(oracle_memblock_t));
        block->id = 0;
        Z_Free(pointer);
    }
    return 0;
}
