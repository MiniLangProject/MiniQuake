#include "pr_exec_oracle_stubs.h"

int _fltused = 0;

static dprograms_t program_header;
dprograms_t *progs = &program_header;
static dfunction_t functions[4];
dfunction_t *pr_functions = functions;
static dstatement_t statements[16];
dstatement_t *pr_statements = statements;
static float globals_words[128];
float *pr_globals = globals_words;
static char strings_data[256];
char *pr_strings = strings_data;
static globalvars_t global_struct;
globalvars_t *pr_global_struct = &global_struct;
server_t sv;
static edict_t edicts[4];
static int print_calls;
static int host_errors;
static int fatal_mode;

void (*pr_builtins[2])(void);
int pr_numbuiltins = 2;

extern int pr_depth;
extern int localstack_used;
extern qboolean pr_trace;
extern dfunction_t *pr_xfunction;
extern int pr_xstatement;

void PR_PrintStatement(dstatement_t *statement);
void PR_StackTrace(void);
void PR_Profile_f(void);
void PR_RunError(char *error, ...);
int PR_EnterFunction(dfunction_t *function);
int PR_LeaveFunction(void);
void PR_ExecuteProgram(func_t function_number);

int mq_strlen(const char *value)
{
    int length = 0;
    while (value[length])
        ++length;
    return length;
}

int mq_strcmp(const char *left, const char *right)
{
    while (*left && *left == *right) {
        ++left;
        ++right;
    }
    return (unsigned char)*left - (unsigned char)*right;
}

int mq_vsprintf(char *output, const char *format, va_list arguments)
{
    int index = 0;
    (void)arguments;
    while (format[index]) {
        output[index] = format[index];
        ++index;
    }
    output[index] = 0;
    return index;
}

void Con_Printf(char *format, ...)
{
    (void)format;
    ++print_calls;
}

void Host_Error(char *format, ...)
{
    (void)format;
    ++host_errors;
    if (fatal_mode) {
        volatile int *invalid = (volatile int *)0;
        *invalid = 42;
    }
}

void Sys_Error(char *format, ...) { (void)format; }
void ED_Print(edict_t *entity) { (void)entity; }
char *PR_GlobalString(int offset) { (void)offset; return "global "; }
char *PR_GlobalStringNoContents(int offset)
{
    (void)offset;
    return "global";
}

static void reset_all(void)
{
    memset(functions, 0, sizeof(functions));
    memset(statements, 0, sizeof(statements));
    memset(globals_words, 0, sizeof(globals_words));
    memset(strings_data, 0, sizeof(strings_data));
    memset(&global_struct, 0, sizeof(global_struct));
    memset(edicts, 0, sizeof(edicts));
    sv.edicts = edicts;
    sv.state = 0;
    program_header.numfunctions = 4;
    pr_depth = 0;
    localstack_used = 0;
    pr_trace = false;
    pr_xfunction = NULL;
    pr_xstatement = 0;
    print_calls = 0;
    host_errors = 0;
    fatal_mode = 0;
}

static char *emit(
    char *output, const char *function_name, const char *case_name,
    int result, int depth, int locals, float value, int count)
{
    output += sprintf(
        output,
        "{\"function\":\"%s\",\"case\":\"%s\",\"result\":%d,"
        "\"depth\":%d,\"locals\":%d,\"value\":%.9g,\"count\":%d}\n",
        function_name, case_name, result, depth, locals, value, count);
    return output;
}

__declspec(dllexport) int __cdecl pr_exec_oracle_jsonl(
    char *output, int capacity)
{
    char *cursor = output;
    int result;
    (void)capacity;

    reset_all();
    statements[0].op = OP_ADD_F;
    statements[0].a = 28;
    statements[0].b = 29;
    statements[0].c = 30;
    PR_PrintStatement(&statements[0]);
    cursor = emit(
        cursor, "PR_PrintStatement", "add", 1,
        pr_depth, localstack_used, 0.0f, print_calls);

    reset_all();
    PR_StackTrace();
    cursor = emit(
        cursor, "PR_StackTrace", "empty", 1,
        pr_depth, localstack_used, 0.0f, print_calls);

    reset_all();
    functions[1].profile = 3;
    functions[2].profile = 5;
    PR_Profile_f();
    cursor = emit(
        cursor, "PR_Profile_f", "ranked", 1,
        pr_depth, localstack_used,
        (float)(functions[1].profile + functions[2].profile), print_calls);

    reset_all();
    statements[0].op = OP_DONE;
    pr_xstatement = 0;
    PR_RunError("fixture error");
    cursor = emit(
        cursor, "PR_RunError", "host_error", host_errors,
        pr_depth, localstack_used, 0.0f, print_calls);

    reset_all();
    functions[1].first_statement = 7;
    functions[1].parm_start = 40;
    functions[1].locals = 2;
    functions[1].numparms = 1;
    functions[1].parm_size[0] = 1;
    ((int *)pr_globals)[40] = 111;
    ((int *)pr_globals)[41] = 222;
    ((int *)pr_globals)[OFS_PARM0] = 333;
    result = PR_EnterFunction(&functions[1]);
    cursor = emit(
        cursor, "PR_EnterFunction", "locals_params", result,
        pr_depth, localstack_used, (float)((int *)pr_globals)[40], 0);

    result = PR_LeaveFunction();
    cursor = emit(
        cursor, "PR_LeaveFunction", "restore", result,
        pr_depth, localstack_used, (float)((int *)pr_globals)[40], 0);

    reset_all();
    functions[1].first_statement = 0;
    statements[0].op = OP_ADD_F;
    statements[0].a = 28;
    statements[0].b = 29;
    statements[0].c = 30;
    statements[1].op = OP_RETURN;
    statements[1].a = 30;
    globals_words[28] = 1.25f;
    globals_words[29] = 2.5f;
    PR_ExecuteProgram(1);
    cursor = emit(
        cursor, "PR_ExecuteProgram", "add_return", 1,
        pr_depth, localstack_used, globals_words[OFS_RETURN],
        functions[1].profile);

    *cursor = 0;
    return (int)(cursor - output);
}

__declspec(dllexport) int __cdecl pr_exec_error_case(void)
{
    reset_all();
    statements[0].op = OP_DONE;
    fatal_mode = 1;
    PR_RunError("fatal fixture");
    return 0;
}
