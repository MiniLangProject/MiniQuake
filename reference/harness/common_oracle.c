/* Direct deterministic harness for the pinned WinQuake/common.c. */

typedef unsigned char byte;
typedef int qboolean;
typedef char *va_list;
typedef struct link_s {
    struct link_s *prev;
    struct link_s *next;
} link_t;
typedef struct sizebuf_s {
    qboolean allowoverflow;
    qboolean overflowed;
    byte *data;
    int maxsize;
    int cursize;
} sizebuf_t;
typedef struct cvar_s {
    char *name;
    char *string;
    qboolean archive;
    qboolean server;
    float value;
    struct cvar_s *next;
} cvar_t;
typedef struct cache_user_s {
    void *data;
} cache_user_t;
typedef struct quakeparms_s {
    char *basedir;
    char *cachedir;
} quakeparms_t;
typedef struct mq_file_s {
    int slot;
    int position;
} FILE;

#define true 1
#define false 0
#define NULL 0
#define MAX_NUM_ARGVS 50
#define MAX_QPATH 64
#define MAX_OSPATH 128
#define GAMENAME "id1"
#define SEEK_SET 0
#define WINDED 0

__declspec(dllimport) int __cdecl sprintf(char *, const char *, ...);
int _fltused = 0;

sizebuf_t net_message;
quakeparms_t host_parms;

static byte mq_hunk[262144];
static int mq_hunk_used;
static byte mq_zone[65536];
static int mq_zone_used;
static byte mq_temp[65536];
static int mq_temp_used;
static int mq_print_calls;
static int mq_sys_print_calls;
static int mq_error_calls;
static int mq_close_calls;
static int mq_seek_calls;
static int mq_mkdir_calls;
static int mq_cvar_register_calls;
static int mq_cvar_set_calls;
static int mq_command_calls;
static int mq_disc_begin_calls;
static int mq_disc_end_calls;

#define MQ_FILE_SLOTS 16
#define MQ_FILE_CAPACITY 16384
static char mq_file_names[MQ_FILE_SLOTS][256];
static byte mq_file_data[MQ_FILE_SLOTS][MQ_FILE_CAPACITY];
static int mq_file_lengths[MQ_FILE_SLOTS];
static int mq_file_positions[MQ_FILE_SLOTS];
static int mq_file_times[MQ_FILE_SLOTS];
static int mq_file_count;
static FILE mq_stdio_files[MQ_FILE_SLOTS];

static int mq_strlen(const char *text)
{
    int length = 0;
    while (text && text[length]) length++;
    return length;
}
static void mq_copy(char *destination, const char *source)
{
    while ((*destination++ = *source++) != 0) ;
}
static void mq_copy_n(char *destination, const char *source, int count)
{
    int index = 0;
    while (index < count && source[index]) {
        destination[index] = source[index];
        index++;
    }
    while (index < count) destination[index++] = 0;
}
static int mq_compare(const char *left, const char *right)
{
    int index = 0;
    while (left[index] && right[index] && left[index] == right[index]) index++;
    return (unsigned char)left[index] - (unsigned char)right[index];
}
static char *mq_concat(char *destination, const char *source)
{
    mq_copy(destination + mq_strlen(destination), source);
    return destination;
}
static char *mq_find_char(const char *text, int wanted)
{
    while (*text) {
        if ((unsigned char)*text == (unsigned char)wanted) return (char *)text;
        text++;
    }
    return wanted == 0 ? (char *)text : NULL;
}
static void *mq_memcpy(void *destination, const void *source, int count)
{
    byte *out = (byte *)destination;
    const byte *in = (const byte *)source;
    int index;
    for (index = 0; index < count; index++) out[index] = in[index];
    return destination;
}
static void mq_zero(void *destination, int count)
{
    byte *out = (byte *)destination;
    int index;
    for (index = 0; index < count; index++) out[index] = 0;
}
static int mq_vsprintf(char *destination, const char *format, va_list arguments)
{
    (void)arguments;
    if (mq_compare(format, "%s/id1") == 0) mq_copy(destination, "base/id1");
    else if (mq_compare(format, "%s/rogue") == 0) mq_copy(destination, "base/rogue");
    else if (mq_compare(format, "%s/hipnotic") == 0) mq_copy(destination, "base/hipnotic");
    else if (mq_compare(format, "%s/%s") == 0) mq_copy(destination, "base/mod");
    else mq_copy(destination, format);
    return mq_strlen(destination);
}
static int mq_find_slot(const char *name)
{
    int index;
    for (index = 0; index < mq_file_count; index++)
        if (mq_compare(mq_file_names[index], name) == 0) return index;
    return -1;
}
static int mq_add_file(const char *name, const byte *data, int length, int timestamp)
{
    int slot = mq_find_slot(name);
    if (slot < 0) slot = mq_file_count++;
    mq_copy(mq_file_names[slot], name);
    if (data && length) mq_memcpy(mq_file_data[slot], data, length);
    mq_file_lengths[slot] = length;
    mq_file_positions[slot] = 0;
    mq_file_times[slot] = timestamp;
    mq_stdio_files[slot].slot = slot;
    mq_stdio_files[slot].position = 0;
    return slot;
}

void *Hunk_AllocName(int size, char *name)
{
    void *result;
    (void)name;
    if (mq_hunk_used + size > (int)sizeof(mq_hunk)) return NULL;
    result = mq_hunk + mq_hunk_used;
    mq_zero(result, size);
    mq_hunk_used += size;
    return result;
}
void *Hunk_Alloc(int size) { return Hunk_AllocName(size, "hunk"); }
void *Hunk_TempAlloc(int size)
{
    void *result;
    if (mq_temp_used + size > (int)sizeof(mq_temp)) return NULL;
    result = mq_temp + mq_temp_used;
    mq_zero(result, size);
    mq_temp_used += size;
    return result;
}
void *Z_Malloc(int size)
{
    void *result;
    if (mq_zone_used + size > (int)sizeof(mq_zone)) return NULL;
    result = mq_zone + mq_zone_used;
    mq_zero(result, size);
    mq_zone_used += size;
    return result;
}
void *Cache_Alloc(cache_user_t *user, int size, char *name)
{
    (void)name;
    user->data = Hunk_Alloc(size);
    return user->data;
}

void Con_Printf(char *format, ...) { (void)format; mq_print_calls++; }
void Sys_Printf(char *format, ...) { (void)format; mq_sys_print_calls++; }
void Sys_Error(char *format, ...) { (void)format; mq_error_calls++; }
void Sys_mkdir(char *path) { (void)path; mq_mkdir_calls++; }
void Cvar_RegisterVariable(cvar_t *variable) { (void)variable; mq_cvar_register_calls++; }
void Cvar_Set(char *name, char *value) { (void)name; (void)value; mq_cvar_set_calls++; }
void Cmd_AddCommand(char *name, void (*function)(void))
{
    (void)name; (void)function; mq_command_calls++;
}
void Draw_BeginDisc(void) { mq_disc_begin_calls++; }
void Draw_EndDisc(void) { mq_disc_end_calls++; }
void CRC_Init(unsigned short *crc) { *crc = 0xffff; }
void CRC_ProcessByte(unsigned short *crc, byte value)
{
    *crc = (unsigned short)((*crc << 5) ^ (*crc >> 11) ^ value);
}

int Sys_FileOpenRead(char *name, int *handle)
{
    int slot = mq_find_slot(name);
    if (slot < 0) { *handle = -1; return -1; }
    mq_file_positions[slot] = 0;
    *handle = slot + 10;
    return mq_file_lengths[slot];
}
int Sys_FileOpenWrite(char *name)
{
    int slot = mq_find_slot(name);
    if (slot < 0) slot = mq_add_file(name, NULL, 0, 2);
    mq_file_lengths[slot] = 0;
    mq_file_positions[slot] = 0;
    return slot + 10;
}
void Sys_FileClose(int handle) { (void)handle; mq_close_calls++; }
void Sys_FileSeek(int handle, int position)
{
    int slot = handle - 10;
    if (slot >= 0 && slot < mq_file_count) mq_file_positions[slot] = position;
    mq_seek_calls++;
}
int Sys_FileRead(int handle, void *destination, int count)
{
    int slot = handle - 10;
    int available;
    if (slot < 0 || slot >= mq_file_count) return 0;
    available = mq_file_lengths[slot] - mq_file_positions[slot];
    if (count > available) count = available;
    mq_memcpy(destination, mq_file_data[slot] + mq_file_positions[slot], count);
    mq_file_positions[slot] += count;
    return count;
}
int Sys_FileWrite(int handle, void *source, int count)
{
    int slot = handle - 10;
    if (slot < 0 || slot >= mq_file_count) return 0;
    mq_memcpy(mq_file_data[slot] + mq_file_positions[slot], source, count);
    mq_file_positions[slot] += count;
    if (mq_file_positions[slot] > mq_file_lengths[slot])
        mq_file_lengths[slot] = mq_file_positions[slot];
    return count;
}
int Sys_FileTime(char *name)
{
    int slot = mq_find_slot(name);
    return slot < 0 ? -1 : mq_file_times[slot];
}
static FILE *mq_fopen(char *name, char *mode)
{
    int slot = mq_find_slot(name);
    (void)mode;
    if (slot < 0) return NULL;
    mq_stdio_files[slot].position = 0;
    return &mq_stdio_files[slot];
}
static int mq_fseek(FILE *file, int position, int origin)
{
    (void)origin;
    file->position = position;
    return 0;
}

void COM_InitFilesystem(void);
int COM_OpenFile(char *filename, int *handle);
void COM_CloseFile(int handle);
void *SZ_GetSpace(sizebuf_t *buffer, int length);
void SZ_Write(sizebuf_t *buffer, void *data, int length);

#define strlen mq_strlen
#define strcpy(destination,source) (mq_copy((destination),(source)),(destination))
#define strncpy(destination,source,count) (mq_copy_n((destination),(source),(count)),(destination))
#define strcat mq_concat
#define strcmp mq_compare
#define strchr mq_find_char
#define memcpy mq_memcpy
#define fopen mq_fopen
#define fseek mq_fseek
#define va_start(arguments,last) ((arguments) = NULL)
#define va_end(arguments) ((void)(arguments))
#define vsprintf mq_vsprintf
/*__PINNED_COMMON_SOURCE__*/
#undef strlen
#undef strcpy
#undef strncpy
#undef strcat
#undef strcmp
#undef strchr
#undef memcpy
#undef fopen
#undef fseek
#undef va_start
#undef va_end
#undef vsprintf

static void mq_reset(void)
{
    mq_hunk_used = mq_zone_used = mq_temp_used = 0;
    mq_print_calls = mq_sys_print_calls = mq_error_calls = 0;
    mq_close_calls = mq_seek_calls = mq_mkdir_calls = 0;
    mq_cvar_register_calls = mq_cvar_set_calls = mq_command_calls = 0;
    mq_disc_begin_calls = mq_disc_end_calls = 0;
    mq_file_count = 0;
    com_modified = false;
    proghack = false;
    static_registered = true;
    com_filesize = -1;
    com_cachedir[0] = 0;
    com_gamedir[0] = 0;
    com_searchpaths = NULL;
    standard_quake = true;
    rogue = false;
    hipnotic = false;
    host_parms.basedir = "base";
    host_parms.cachedir = NULL;
    BigShort = ShortSwap;
    LittleShort = ShortNoSwap;
    BigLong = LongSwap;
    LittleLong = LongNoSwap;
    BigFloat = FloatSwap;
    LittleFloat = FloatNoSwap;
}
static void mq_emit(char *output, int capacity, const char *line)
{
    int used = mq_strlen(output), length = mq_strlen(line), index;
    if (used + length + 1 >= capacity) return;
    for (index = 0; index < length; index++) output[used + index] = line[index];
    output[used + length] = '\n';
    output[used + length + 1] = 0;
}
static int mq_same(const char *left, const char *right)
{
    return mq_compare(left, right) == 0;
}
static int mq_bytes_equal(const byte *left, const byte *right, int count)
{
    int index;
    for (index = 0; index < count; index++) if (left[index] != right[index]) return false;
    return true;
}
static searchpath_t *mq_add_directory_path(const char *name)
{
    searchpath_t *search = Hunk_Alloc(sizeof(searchpath_t));
    mq_copy(search->filename, name);
    search->next = com_searchpaths;
    com_searchpaths = search;
    return search;
}
static int mq_build_pack(const char *name)
{
    byte image[80];
    int filepos = 12, filelen = 4, dirofs = 16, dirlen = 64;
    mq_zero(image, sizeof(image));
    image[0] = 'P'; image[1] = 'A'; image[2] = 'C'; image[3] = 'K';
    mq_memcpy(image + 4, &dirofs, 4);
    mq_memcpy(image + 8, &dirlen, 4);
    image[12] = 9; image[13] = 8; image[14] = 7; image[15] = 6;
    mq_copy((char *)(image + 16), "inside.bin");
    mq_memcpy(image + 72, &filepos, 4);
    mq_memcpy(image + 76, &filelen, 4);
    return mq_add_file(name, image, sizeof(image), 3);
}
static void mq_prepare_loose_file(void)
{
    byte data[4] = {1, 2, 3, 4};
    mq_add_file("base/id1/test.bin", data, 4, 3);
    mq_add_directory_path("base/id1");
}

__declspec(dllexport) int common_oracle_jsonl(char *output, int capacity)
{
    char line[1024];
    byte bytes_a[32], bytes_b[32], storage[512];
    char text_a[128], text_b[128];
    link_t head, first, second;
    sizebuf_t buffer;
    cache_user_t cache;
    searchpath_t *search;
    pack_t *pack;
    FILE *stdio_file;
    byte *loaded;
    char *next;
    int handle, length, index;
    int float_bits;
    float float_value;
    char *safe_args[] = {"quake", "-safe", "-rogue"};
    char *base_args[] = {"quake", "-basedir", "base"};

    if (!output || capacity < 2) return -1;
    output[0] = 0;

    mq_reset(); ClearLink(&head);
    sprintf(line, "{\"function\":\"ClearLink\",\"case\":\"self\",\"self\":%s}", head.next == &head && head.prev == &head ? "true" : "false"); mq_emit(output, capacity, line);

    mq_reset(); ClearLink(&head); ClearLink(&first); InsertLinkBefore(&first, &head); RemoveLink(&first);
    sprintf(line, "{\"function\":\"RemoveLink\",\"case\":\"unlink\",\"empty\":%s}", head.next == &head && head.prev == &head ? "true" : "false"); mq_emit(output, capacity, line);

    mq_reset(); ClearLink(&head); ClearLink(&first); InsertLinkBefore(&first, &head);
    sprintf(line, "{\"function\":\"InsertLinkBefore\",\"case\":\"order\",\"ok\":%s}", head.next == &first && head.prev == &first ? "true" : "false"); mq_emit(output, capacity, line);

    mq_reset(); ClearLink(&head); ClearLink(&first); ClearLink(&second); InsertLinkAfter(&first, &head); InsertLinkAfter(&second, &head);
    sprintf(line, "{\"function\":\"InsertLinkAfter\",\"case\":\"order\",\"second_first\":%s}", head.next == &second && second.next == &first ? "true" : "false"); mq_emit(output, capacity, line);

    mq_reset(); mq_zero(bytes_a, 8); Q_memset(bytes_a, 0x5a, 8);
    sprintf(line, "{\"function\":\"Q_memset\",\"case\":\"fill\",\"sum\":%i}", bytes_a[0]+bytes_a[1]+bytes_a[2]+bytes_a[3]+bytes_a[4]+bytes_a[5]+bytes_a[6]+bytes_a[7]); mq_emit(output, capacity, line);

    mq_reset(); for (index=0; index<8; index++) bytes_a[index]=(byte)(index+1); mq_zero(bytes_b, 8); Q_memcpy(bytes_b, bytes_a, 8);
    sprintf(line, "{\"function\":\"Q_memcpy\",\"case\":\"copy\",\"equal\":%s}", mq_bytes_equal(bytes_a, bytes_b, 8) ? "true":"false"); mq_emit(output, capacity, line);

    mq_reset(); bytes_a[0]=1; bytes_a[1]=2; bytes_b[0]=1; bytes_b[1]=3;
    sprintf(line, "{\"function\":\"Q_memcmp\",\"case\":\"equal_mismatch\",\"equal\":%i,\"different\":%i}", Q_memcmp(bytes_a,bytes_a,2), Q_memcmp(bytes_a,bytes_b,2)); mq_emit(output, capacity, line);

    mq_reset(); Q_strcpy(text_a, "quake");
    sprintf(line, "{\"function\":\"Q_strcpy\",\"case\":\"copy\",\"text\":\"%s\"}", text_a); mq_emit(output, capacity, line);

    mq_reset(); mq_zero(text_a,sizeof(text_a)); Q_strncpy(text_a, "abcdef", 3);
    sprintf(line, "{\"function\":\"Q_strncpy\",\"case\":\"bounded\",\"bytes\":[%i,%i,%i]}", text_a[0],text_a[1],text_a[2]); mq_emit(output, capacity, line);

    mq_reset(); sprintf(line, "{\"function\":\"Q_strlen\",\"case\":\"length\",\"value\":%i}", Q_strlen("quake")); mq_emit(output, capacity, line);
    mq_reset(); next=Q_strrchr("a/b/c",'/' ); sprintf(line, "{\"function\":\"Q_strrchr\",\"case\":\"last\",\"suffix\":\"%s\"}", next); mq_emit(output, capacity, line);
    mq_reset(); mq_copy(text_a,"mini"); Q_strcat(text_a,"quake"); sprintf(line, "{\"function\":\"Q_strcat\",\"case\":\"append\",\"text\":\"%s\"}",text_a); mq_emit(output,capacity,line);
    mq_reset(); sprintf(line, "{\"function\":\"Q_strcmp\",\"case\":\"equal_mismatch\",\"equal\":%i,\"different\":%i}",Q_strcmp("abc","abc"),Q_strcmp("abc","abd")); mq_emit(output,capacity,line);
    mq_reset(); sprintf(line, "{\"function\":\"Q_strncmp\",\"case\":\"prefix\",\"two\":%i,\"three\":%i}",Q_strncmp("abc","abd",2),Q_strncmp("abc","abd",3)); mq_emit(output,capacity,line);
    mq_reset(); sprintf(line, "{\"function\":\"Q_strncasecmp\",\"case\":\"fold\",\"equal\":%i,\"different\":%i}",Q_strncasecmp("AbC","aBc",3),Q_strncasecmp("AbC","aBd",3)); mq_emit(output,capacity,line);
    mq_reset(); sprintf(line, "{\"function\":\"Q_strcasecmp\",\"case\":\"fold\",\"equal\":%i,\"different\":%i}",Q_strcasecmp("QuAkE","qUaKe"),Q_strcasecmp("a","b")); mq_emit(output,capacity,line);
    mq_reset(); sprintf(line, "{\"function\":\"Q_atoi\",\"case\":\"forms\",\"decimal\":%i,\"hex\":%i,\"character\":%i}",Q_atoi("-42x"),Q_atoi("0x2a"),Q_atoi("'Z")); mq_emit(output,capacity,line);
    mq_reset(); sprintf(line, "{\"function\":\"Q_atof\",\"case\":\"forms\",\"decimal\":%.6f,\"hex\":%.6f,\"character\":%.6f}",Q_atof("-12.5x"),Q_atof("0x2a"),Q_atof("'Z")); mq_emit(output,capacity,line);

    mq_reset(); sprintf(line, "{\"function\":\"ShortSwap\",\"case\":\"swap\",\"value\":%i}",(int)ShortSwap((short)0x1234)); mq_emit(output,capacity,line);
    mq_reset(); sprintf(line, "{\"function\":\"ShortNoSwap\",\"case\":\"identity\",\"value\":%i}",(int)ShortNoSwap((short)-1234)); mq_emit(output,capacity,line);
    mq_reset(); sprintf(line, "{\"function\":\"LongSwap\",\"case\":\"swap\",\"value\":%i}",LongSwap(0x12345678)); mq_emit(output,capacity,line);
    mq_reset(); sprintf(line, "{\"function\":\"LongNoSwap\",\"case\":\"identity\",\"value\":%i}",LongNoSwap(-1234567)); mq_emit(output,capacity,line);
    mq_reset(); float_value=FloatSwap(12.5f); mq_memcpy(&float_bits,&float_value,4); sprintf(line, "{\"function\":\"FloatSwap\",\"case\":\"swap\",\"bits\":%i}",float_bits); mq_emit(output,capacity,line);
    mq_reset(); sprintf(line, "{\"function\":\"FloatNoSwap\",\"case\":\"identity\",\"value\":%.6f}",FloatNoSwap(-12.5f)); mq_emit(output,capacity,line);

#define MQ_WRITE_EVENT(NAME,CALL) mq_reset(); mq_zero(storage,sizeof(storage)); buffer.data=storage; buffer.maxsize=sizeof(storage); buffer.cursize=0; buffer.allowoverflow=false; buffer.overflowed=false; CALL; sprintf(line,"{\"function\":\"" NAME "\",\"case\":\"encode\",\"size\":%i,\"bytes\":[%i,%i,%i,%i]}",buffer.cursize,storage[0],storage[1],storage[2],storage[3]); mq_emit(output,capacity,line)
    MQ_WRITE_EVENT("MSG_WriteChar", MSG_WriteChar(&buffer,-2));
    MQ_WRITE_EVENT("MSG_WriteByte", MSG_WriteByte(&buffer,254));
    MQ_WRITE_EVENT("MSG_WriteShort", MSG_WriteShort(&buffer,-1234));
    MQ_WRITE_EVENT("MSG_WriteLong", MSG_WriteLong(&buffer,0x12345678));
    MQ_WRITE_EVENT("MSG_WriteFloat", MSG_WriteFloat(&buffer,12.5f));
    MQ_WRITE_EVENT("MSG_WriteString", MSG_WriteString(&buffer,"quake"));
    MQ_WRITE_EVENT("MSG_WriteCoord", MSG_WriteCoord(&buffer,-12.25f));
    MQ_WRITE_EVENT("MSG_WriteAngle", MSG_WriteAngle(&buffer,90.75f));
#undef MQ_WRITE_EVENT

    mq_reset(); net_message.data=storage; net_message.cursize=4; msg_readcount=3; msg_badread=true; MSG_BeginReading();
    sprintf(line,"{\"function\":\"MSG_BeginReading\",\"case\":\"reset\",\"count\":%i,\"bad\":%s}",msg_readcount,msg_badread?"true":"false"); mq_emit(output,capacity,line);

#define MQ_READ_PREP() mq_reset(); net_message.data=storage; net_message.maxsize=sizeof(storage); net_message.cursize=8; msg_readcount=0; msg_badread=false; LittleLong=LongNoSwap
    MQ_READ_PREP(); storage[0]=254; sprintf(line,"{\"function\":\"MSG_ReadChar\",\"case\":\"decode\",\"value\":%i,\"count\":%i}",MSG_ReadChar(),msg_readcount); mq_emit(output,capacity,line);
    MQ_READ_PREP(); storage[0]=254; sprintf(line,"{\"function\":\"MSG_ReadByte\",\"case\":\"decode\",\"value\":%i,\"count\":%i}",MSG_ReadByte(),msg_readcount); mq_emit(output,capacity,line);
    MQ_READ_PREP(); storage[0]=46;storage[1]=251; sprintf(line,"{\"function\":\"MSG_ReadShort\",\"case\":\"decode\",\"value\":%i,\"count\":%i}",MSG_ReadShort(),msg_readcount); mq_emit(output,capacity,line);
    MQ_READ_PREP(); storage[0]=120;storage[1]=86;storage[2]=52;storage[3]=18; sprintf(line,"{\"function\":\"MSG_ReadLong\",\"case\":\"decode\",\"value\":%i,\"count\":%i}",MSG_ReadLong(),msg_readcount); mq_emit(output,capacity,line);
    MQ_READ_PREP(); float_value=12.5f;mq_memcpy(storage,&float_value,4); sprintf(line,"{\"function\":\"MSG_ReadFloat\",\"case\":\"decode\",\"value\":%.6f,\"count\":%i}",MSG_ReadFloat(),msg_readcount); mq_emit(output,capacity,line);
    MQ_READ_PREP(); mq_copy((char*)storage,"quake"); sprintf(line,"{\"function\":\"MSG_ReadString\",\"case\":\"decode\",\"value\":\"%s\",\"count\":%i}",MSG_ReadString(),msg_readcount); mq_emit(output,capacity,line);
    MQ_READ_PREP(); storage[0]=0x9e;storage[1]=0xff; sprintf(line,"{\"function\":\"MSG_ReadCoord\",\"case\":\"decode\",\"value\":%.6f,\"count\":%i}",MSG_ReadCoord(),msg_readcount); mq_emit(output,capacity,line);
    MQ_READ_PREP(); storage[0]=0xc0; sprintf(line,"{\"function\":\"MSG_ReadAngle\",\"case\":\"decode\",\"value\":%.6f,\"count\":%i}",MSG_ReadAngle(),msg_readcount); mq_emit(output,capacity,line);
#undef MQ_READ_PREP

    mq_reset(); mq_zero(&buffer,sizeof(buffer)); SZ_Alloc(&buffer,32); sprintf(line,"{\"function\":\"SZ_Alloc\",\"case\":\"minimum\",\"capacity\":%i,\"size\":%i}",buffer.maxsize,buffer.cursize); mq_emit(output,capacity,line);
    mq_reset(); buffer.data=storage;buffer.maxsize=sizeof(storage);buffer.cursize=9;SZ_Free(&buffer);sprintf(line,"{\"function\":\"SZ_Free\",\"case\":\"logical\",\"size\":%i}",buffer.cursize);mq_emit(output,capacity,line);
    mq_reset(); buffer.data=storage;buffer.maxsize=sizeof(storage);buffer.cursize=9;SZ_Clear(&buffer);sprintf(line,"{\"function\":\"SZ_Clear\",\"case\":\"clear\",\"size\":%i}",buffer.cursize);mq_emit(output,capacity,line);
    mq_reset(); buffer.data=storage;buffer.maxsize=8;buffer.cursize=7;buffer.allowoverflow=true;buffer.overflowed=false;SZ_GetSpace(&buffer,2);sprintf(line,"{\"function\":\"SZ_GetSpace\",\"case\":\"overflow\",\"size\":%i,\"overflowed\":%s}",buffer.cursize,buffer.overflowed?"true":"false");mq_emit(output,capacity,line);
    mq_reset(); mq_zero(storage,16);buffer.data=storage;buffer.maxsize=16;buffer.cursize=0;buffer.allowoverflow=false;bytes_a[0]=1;bytes_a[1]=2;bytes_a[2]=3;SZ_Write(&buffer,bytes_a,3);sprintf(line,"{\"function\":\"SZ_Write\",\"case\":\"copy\",\"size\":%i,\"sum\":%i}",buffer.cursize,storage[0]+storage[1]+storage[2]);mq_emit(output,capacity,line);
    mq_reset(); mq_zero(storage,16);buffer.data=storage;buffer.maxsize=16;buffer.cursize=1;buffer.allowoverflow=false;storage[0]=0;SZ_Print(&buffer,"abc");sprintf(line,"{\"function\":\"SZ_Print\",\"case\":\"replace_nul\",\"size\":%i,\"text\":\"%s\"}",buffer.cursize,storage);mq_emit(output,capacity,line);

    mq_reset(); sprintf(line,"{\"function\":\"COM_SkipPath\",\"case\":\"last\",\"value\":\"%s\"}",COM_SkipPath("maps/e1m1.bsp"));mq_emit(output,capacity,line);
    mq_reset(); COM_StripExtension("maps/e1m1.bsp",text_a);sprintf(line,"{\"function\":\"COM_StripExtension\",\"case\":\"strip\",\"value\":\"%s\"}",text_a);mq_emit(output,capacity,line);
    mq_reset(); sprintf(line,"{\"function\":\"COM_FileExtension\",\"case\":\"extension\",\"value\":\"%s\"}",COM_FileExtension("maps/e1m1.bsp"));mq_emit(output,capacity,line);
    mq_reset(); COM_FileBase("maps/e1m1.bsp",text_a);sprintf(line,"{\"function\":\"COM_FileBase\",\"case\":\"base\",\"value\":\"%s\"}",text_a);mq_emit(output,capacity,line);
    mq_reset(); mq_copy(text_a,"maps/e1m1");COM_DefaultExtension(text_a,".bsp");sprintf(line,"{\"function\":\"COM_DefaultExtension\",\"case\":\"append\",\"value\":\"%s\"}",text_a);mq_emit(output,capacity,line);
    mq_reset(); mq_copy(text_a," // note\n \"two words\" tail");next=COM_Parse(text_a);sprintf(line,"{\"function\":\"COM_Parse\",\"case\":\"quoted\",\"token\":\"%s\",\"remaining\":\"%s\"}",com_token,next);mq_emit(output,capacity,line);
    mq_reset(); COM_InitArgv(3,safe_args);sprintf(line,"{\"function\":\"COM_CheckParm\",\"case\":\"found_missing\",\"found\":%i,\"missing\":%i}",COM_CheckParm("-rogue"),COM_CheckParm("-none"));mq_emit(output,capacity,line);
    mq_reset(); COM_InitArgv(3,safe_args);sprintf(line,"{\"function\":\"COM_InitArgv\",\"case\":\"safe\",\"argc\":%i,\"rogue\":%s,\"safe_tail\":\"%s\"}",com_argc,rogue?"true":"false",com_argv[com_argc-1]);mq_emit(output,capacity,line);
    mq_reset(); COM_InitArgv(3,base_args);COM_Init("ignored");sprintf(line,"{\"function\":\"COM_Init\",\"case\":\"little_endian\",\"bigendian\":%s,\"cvars\":%i,\"commands\":%i,\"paths\":%i}",bigendien?"true":"false",mq_cvar_register_calls,mq_command_calls,com_searchpaths?1:0);mq_emit(output,capacity,line);
    mq_reset(); sprintf(line,"{\"function\":\"va\",\"case\":\"literal\",\"value\":\"%s\"}",va("quake"));mq_emit(output,capacity,line);
    mq_reset(); bytes_a[0]=3;bytes_a[1]=9;bytes_a[2]=7;sprintf(line,"{\"function\":\"memsearch\",\"case\":\"found_missing\",\"found\":%i,\"missing\":%i}",memsearch(bytes_a,3,9),memsearch(bytes_a,3,8));mq_emit(output,capacity,line);

    mq_reset(); search=mq_add_directory_path("base/id1");(void)search;COM_Path_f();sprintf(line,"{\"function\":\"COM_Path_f\",\"case\":\"one_directory\",\"prints\":%i}",mq_print_calls);mq_emit(output,capacity,line);
    mq_reset(); mq_copy(com_gamedir,"base/id1");bytes_a[0]=4;bytes_a[1]=5;COM_WriteFile("out.bin",bytes_a,2);index=mq_find_slot("base/id1/out.bin");sprintf(line,"{\"function\":\"COM_WriteFile\",\"case\":\"write\",\"length\":%i,\"prints\":%i}",index<0?-1:mq_file_lengths[index],mq_sys_print_calls);mq_emit(output,capacity,line);
    mq_reset(); mq_copy(text_a,"a/b/c.bin");COM_CreatePath(text_a);sprintf(line,"{\"function\":\"COM_CreatePath\",\"case\":\"nested\",\"mkdirs\":%i}",mq_mkdir_calls);mq_emit(output,capacity,line);
    mq_reset(); bytes_a[0]=1;bytes_a[1]=2;bytes_a[2]=3;mq_add_file("net.bin",bytes_a,3,1);mq_copy(text_a,"cache/x.bin");COM_CopyFile("net.bin",text_a);index=mq_find_slot("cache/x.bin");sprintf(line,"{\"function\":\"COM_CopyFile\",\"case\":\"copy\",\"length\":%i,\"mkdirs\":%i}",index<0?-1:mq_file_lengths[index],mq_mkdir_calls);mq_emit(output,capacity,line);

    mq_reset(); mq_prepare_loose_file();length=COM_FindFile("test.bin",&handle,NULL);sprintf(line,"{\"function\":\"COM_FindFile\",\"case\":\"loose\",\"length\":%i,\"opened\":%s}",length,handle>=0?"true":"false");mq_emit(output,capacity,line);
    mq_reset(); mq_prepare_loose_file();length=COM_OpenFile("test.bin",&handle);sprintf(line,"{\"function\":\"COM_OpenFile\",\"case\":\"loose\",\"length\":%i,\"opened\":%s}",length,handle>=0?"true":"false");mq_emit(output,capacity,line);
    mq_reset(); mq_prepare_loose_file();length=COM_FOpenFile("test.bin",&stdio_file);sprintf(line,"{\"function\":\"COM_FOpenFile\",\"case\":\"loose\",\"length\":%i,\"opened\":%s}",length,stdio_file?"true":"false");mq_emit(output,capacity,line);
    mq_reset(); mq_prepare_loose_file();COM_OpenFile("test.bin",&handle);COM_CloseFile(handle);sprintf(line,"{\"function\":\"COM_CloseFile\",\"case\":\"loose\",\"closed\":%s}",mq_close_calls==1?"true":"false");mq_emit(output,capacity,line);

    mq_reset(); mq_prepare_loose_file();loaded=COM_LoadFile("test.bin",0);sprintf(line,"{\"function\":\"COM_LoadFile\",\"case\":\"zone\",\"terminated\":%s,\"sum\":%i}",loaded[4]==0?"true":"false",loaded[0]+loaded[1]+loaded[2]+loaded[3]);mq_emit(output,capacity,line);
    mq_reset(); mq_prepare_loose_file();loaded=COM_LoadHunkFile("test.bin");sprintf(line,"{\"function\":\"COM_LoadHunkFile\",\"case\":\"hunk\",\"terminated\":%s,\"sum\":%i}",loaded[4]==0?"true":"false",loaded[0]+loaded[1]+loaded[2]+loaded[3]);mq_emit(output,capacity,line);
    mq_reset(); mq_prepare_loose_file();loaded=COM_LoadTempFile("test.bin");sprintf(line,"{\"function\":\"COM_LoadTempFile\",\"case\":\"temp\",\"terminated\":%s}",loaded[4]==0?"true":"false");mq_emit(output,capacity,line);
    mq_reset(); mq_prepare_loose_file();cache.data=NULL;COM_LoadCacheFile("test.bin",&cache);loaded=(byte*)cache.data;sprintf(line,"{\"function\":\"COM_LoadCacheFile\",\"case\":\"cache\",\"allocated\":%s,\"terminated\":%s}",loaded?"true":"false",loaded&&loaded[4]==0?"true":"false");mq_emit(output,capacity,line);
    mq_reset(); mq_prepare_loose_file();mq_zero(storage,sizeof(storage));loaded=COM_LoadStackFile("test.bin",storage,sizeof(storage));sprintf(line,"{\"function\":\"COM_LoadStackFile\",\"case\":\"stack\",\"same\":%s,\"terminated\":%s}",loaded==storage?"true":"false",loaded[4]==0?"true":"false");mq_emit(output,capacity,line);

    mq_reset(); mq_build_pack("sample.pak");pack=COM_LoadPackFile("sample.pak");sprintf(line,"{\"function\":\"COM_LoadPackFile\",\"case\":\"one_entry\",\"loaded\":%s,\"files\":%i,\"modified\":%s}",pack?"true":"false",pack?pack->numfiles:0,com_modified?"true":"false");mq_emit(output,capacity,line);
    mq_reset(); COM_AddGameDirectory("base/id1");sprintf(line,"{\"function\":\"COM_AddGameDirectory\",\"case\":\"directory\",\"gamedir\":\"%s\",\"paths\":%i}",com_gamedir,com_searchpaths?1:0);mq_emit(output,capacity,line);
    mq_reset(); COM_InitArgv(3,base_args);COM_InitFilesystem();sprintf(line,"{\"function\":\"COM_InitFilesystem\",\"case\":\"basedir\",\"gamedir\":\"%s\",\"cachedir\":\"%s\",\"paths\":%i}",com_gamedir,com_cachedir,com_searchpaths?1:0);mq_emit(output,capacity,line);
    mq_reset(); COM_CheckRegistered();sprintf(line,"{\"function\":\"COM_CheckRegistered\",\"case\":\"shareware\",\"registered\":%i,\"prints\":%i}",static_registered,mq_print_calls);mq_emit(output,capacity,line);

    return mq_strlen(output);
}
