#ifdef MINIQUAKE_PINNED_ORACLE

static char *mq_vid_append(char *cursor, const char *format, ...)
{
    va_list arguments;
    va_start(arguments, format);
    cursor += vsprintf(cursor, format, arguments);
    va_end(arguments);
    return cursor;
}

static void mq_vid_make_palette(byte *palette)
{
    int index;
    for (index = 0; index < 256; index++)
    {
        palette[index * 3 + 0] = (byte)index;
        palette[index * 3 + 1] = (byte)index;
        palette[index * 3 + 2] = (byte)index;
    }
}

static void mq_vid_mode(
    int index, modestate_t type, int width, int height, int bpp,
    const char *description)
{
    modelist[index].type = type;
    modelist[index].width = width;
    modelist[index].height = height;
    modelist[index].modenum = index;
    modelist[index].dib = true;
    modelist[index].fullscreen = type == MS_FULLDIB;
    modelist[index].bpp = bpp;
    modelist[index].halfscreen = false;
    strncpy(modelist[index].modedesc, description, sizeof(modelist[index].modedesc) - 1);
    modelist[index].modedesc[sizeof(modelist[index].modedesc) - 1] = 0;
}

__declspec(dllexport) int gl_vidnt_oracle_jsonl(char *output, int capacity)
{
    char *cursor = output;
    byte palette[768];
    byte shifted[768];
    int x, y, width, height;
    int before;
    int result;
    int index;

    (void)capacity;
    mq_vid_make_palette(palette);
    memcpy(shifted, palette, sizeof(shifted));
    memset(&vid, 0, sizeof(vid));
    memset(modelist, 0, sizeof(modelist));
    memset(&badmode, 0, sizeof(badmode));
    strcpy(badmode.modedesc, "Bad mode");
    mq_vid_mode(0, MS_WINDOWED, 640, 480, 0, "640x480");
    mq_vid_mode(1, MS_FULLDIB, 800, 600, 16, "800x600x16");
    mq_vid_mode(2, MS_FULLDIB, 1024, 768, 32, "1024x768x32");
    nummodes = 3;
    vid.conwidth = 640;
    vid.conheight = 480;
    windowed = true;
    leavecurrentmode = false;
    _windowed_mouse.value = 0;
    ActiveApp = true;
    key_dest = key_game;
    mq_vid_gl_vendor = "MiniGL";
    mq_vid_gl_renderer = "PowerVR Test";
    mq_vid_gl_version = "1.1";
    mq_vid_gl_extensions =
        "GL_EXT_texture_object GL_EXT_vertex_array GL_SGIS_multitexture ";
    gl_extensions = mq_vid_gl_extensions;

    VID_HandlePause(true);
    cursor = mq_vid_append(cursor, "{\"function\":\"VID_HandlePause\",\"case\":\"noop\",\"result\":0}\n");
    VID_ForceLockState(7);
    cursor = mq_vid_append(cursor, "{\"function\":\"VID_ForceLockState\",\"case\":\"noop\",\"result\":0}\n");
    VID_LockBuffer();
    cursor = mq_vid_append(cursor, "{\"function\":\"VID_LockBuffer\",\"case\":\"noop\",\"result\":0}\n");
    VID_UnlockBuffer();
    cursor = mq_vid_append(cursor, "{\"function\":\"VID_UnlockBuffer\",\"case\":\"noop\",\"result\":0}\n");
    result = VID_ForceUnlockedAndReturnState();
    cursor = mq_vid_append(cursor, "{\"function\":\"VID_ForceUnlockedAndReturnState\",\"case\":\"constant\",\"result\":%d}\n", result);
    D_BeginDirectRect(1, 2, palette, 8, 8);
    cursor = mq_vid_append(cursor, "{\"function\":\"D_BeginDirectRect\",\"case\":\"noop\",\"result\":0}\n");
    D_EndDirectRect(1, 2, 8, 8);
    cursor = mq_vid_append(cursor, "{\"function\":\"D_EndDirectRect\",\"case\":\"noop\",\"result\":0}\n");

    mq_vid_window_calls = 0;
    CenterWindow((HWND)1, 640, 480, false);
    cursor = mq_vid_append(
        cursor,
        "{\"function\":\"CenterWindow\",\"case\":\"dual-center\",\"x\":%d,\"y\":%d,\"calls\":%d}\n",
        mq_vid_window_x, mq_vid_window_y, mq_vid_window_calls);

    result = VID_SetWindowedMode(0);
    cursor = mq_vid_append(
        cursor,
        "{\"function\":\"VID_SetWindowedMode\",\"case\":\"640x480\",\"result\":%d,\"state\":%d,\"width\":%d,\"height\":%d}\n",
        result, modestate, DIBWidth, DIBHeight);

    mq_vid_enum_enabled = 1;
    result = VID_SetFullDIBMode(1);
    cursor = mq_vid_append(
        cursor,
        "{\"function\":\"VID_SetFullDIBMode\",\"case\":\"800x600x16\",\"result\":%d,\"state\":%d,\"width\":%d,\"height\":%d}\n",
        result, modestate, DIBWidth, DIBHeight);

    windowed = true;
    result = VID_SetMode(0, palette);
    cursor = mq_vid_append(
        cursor,
        "{\"function\":\"VID_SetMode\",\"case\":\"windowed\",\"result\":%d,\"mode\":%d,\"recalc\":%d}\n",
        result, vid_modenum, vid.recalc_refdef);

    window_x = 10;
    window_y = 20;
    window_width = 800;
    window_height = 600;
    mq_vid_clip_updates = 0;
    VID_UpdateWindowStatus();
    cursor = mq_vid_append(
        cursor,
        "{\"function\":\"VID_UpdateWindowStatus\",\"case\":\"rect\",\"center\":[%d,%d],\"clip\":%d}\n",
        window_center_x, window_center_y, mq_vid_clip_updates);

    CheckTextureExtensions();
    cursor = mq_vid_append(
        cursor,
        "{\"function\":\"CheckTextureExtensions\",\"case\":\"extension\",\"bound\":%d}\n",
        bindTexFunc != NULL);
    CheckArrayExtensions();
    cursor = mq_vid_append(
        cursor,
        "{\"function\":\"CheckArrayExtensions\",\"case\":\"extension\",\"loaded\":%d}\n",
        glArrayElementEXT != NULL && glVertexPointerEXT != NULL);
    gl_mtexable = false;
    CheckMultiTextureExtensions();
    cursor = mq_vid_append(
        cursor,
        "{\"function\":\"CheckMultiTextureExtensions\",\"case\":\"sgis\",\"enabled\":%d}\n",
        gl_mtexable);

    fullsbardraw = false;
    isPermedia = false;
    GL_Init();
    cursor = mq_vid_append(
        cursor,
        "{\"function\":\"GL_Init\",\"case\":\"powervr\",\"vendor\":\"%s\",\"fullsbar\":%d,\"permedia\":%d}\n",
        gl_vendor, fullsbardraw, isPermedia);

    WindowRect.left = 3;
    WindowRect.top = 4;
    WindowRect.right = 803;
    WindowRect.bottom = 604;
    GL_BeginRendering(&x, &y, &width, &height);
    cursor = mq_vid_append(
        cursor,
        "{\"function\":\"GL_BeginRendering\",\"case\":\"rect\",\"box\":[%d,%d,%d,%d]}\n",
        x, y, width, height);
    mq_vid_swap_calls = 0;
    scr_skipupdate = false;
    block_drawing = false;
    modestate = MS_WINDOWED;
    GL_EndRendering();
    cursor = mq_vid_append(
        cursor,
        "{\"function\":\"GL_EndRendering\",\"case\":\"swap\",\"swaps\":%d}\n",
        mq_vid_swap_calls);
    mq_vid_swap_calls = 0;
    scr_skipupdate = true;
    block_drawing = false;
    GL_EndRendering();
    before = mq_vid_swap_calls;
    block_drawing = true;
    GL_EndRendering();
    cursor = mq_vid_append(
        cursor,
        "{\"function\":\"GL_EndRendering\",\"case\":\"skip-block\","
        "\"skipped\":%d,\"blocked\":%d}\n",
        before, mq_vid_swap_calls - before);

    VID_SetPalette(palette);
    cursor = mq_vid_append(
        cursor,
        "{\"function\":\"VID_SetPalette\",\"case\":\"gray\",\"first\":%u,\"transparent\":%u,\"nearest\":%u}\n",
        d_8to24table[0], d_8to24table[255], d_15to8table[0]);
    before = gammaworks;
    VID_ShiftPalette(shifted);
    cursor = mq_vid_append(
        cursor,
        "{\"function\":\"VID_ShiftPalette\",\"case\":\"noop\",\"gammaworks\":%d}\n",
        gammaworks == before);

    before = mq_vid_mouse_deactivations;
    VID_SetDefaultMode();
    cursor = mq_vid_append(
        cursor,
        "{\"function\":\"VID_SetDefaultMode\",\"case\":\"deactivate\",\"calls\":%d}\n",
        mq_vid_mouse_deactivations - before);

    vid_initialized = true;
    modestate = MS_WINDOWED;
    before = mq_vid_mouse_deactivations;
    VID_Shutdown();
    cursor = mq_vid_append(
        cursor,
        "{\"function\":\"VID_Shutdown\",\"case\":\"initialized\",\"deactivations\":%d}\n",
        mq_vid_mouse_deactivations - before);

    result = bSetupPixelFormat((HDC)1);
    cursor = mq_vid_append(
        cursor,
        "{\"function\":\"bSetupPixelFormat\",\"case\":\"supported\",\"result\":%d}\n",
        result);

    cursor = mq_vid_append(
        cursor,
        "{\"function\":\"MapKey\",\"case\":\"scan\",\"escape\":%d,\"a\":%d,\"invalid\":%d}\n",
        MapKey(1 << 16), MapKey(30 << 16), MapKey(200 << 16));

    mq_vid_key_events = 0;
    ClearAllStates();
    cursor = mq_vid_append(
        cursor,
        "{\"function\":\"ClearAllStates\",\"case\":\"release\",\"events\":%d}\n",
        mq_vid_key_events);

    modestate = MS_WINDOWED;
    _windowed_mouse.value = 1;
    before = mq_vid_mouse_deactivations;
    AppActivate(false, false);
    cursor = mq_vid_append(
        cursor,
        "{\"function\":\"AppActivate\",\"case\":\"windowed-inactive\",\"active\":%d,\"minimized\":%d,\"deactivations\":%d}\n",
        ActiveApp, Minimized, mq_vid_mouse_deactivations - before);
    modestate = MS_FULLDIB;
    vid_canalttab = true;
    vid_wassuspended = false;
    AppActivate(false, true);
    before = vid_wassuspended;
    AppActivate(true, false);
    cursor = mq_vid_append(
        cursor,
        "{\"function\":\"AppActivate\",\"case\":\"fullscreen-cycle\","
        "\"suspended\":%d,\"restored\":%d,\"active\":%d}\n",
        before, !vid_wassuspended, ActiveApp);

    mq_vid_key_events = 0;
    MainWndProc((HWND)1, WM_KEYDOWN, 0, 30 << 16);
    cursor = mq_vid_append(
        cursor,
        "{\"function\":\"MainWndProc\",\"case\":\"keydown\",\"events\":%d}\n",
        mq_vid_key_events);

    cursor = mq_vid_append(
        cursor,
        "{\"function\":\"VID_NumModes\",\"case\":\"three\",\"count\":%d}\n",
        VID_NumModes());
    cursor = mq_vid_append(
        cursor,
        "{\"function\":\"VID_GetModePtr\",\"case\":\"sentinel\",\"valid\":\"%s\",\"bad\":\"%s\"}\n",
        VID_GetModePtr(1)->modedesc, VID_GetModePtr(99)->modedesc);
    cursor = mq_vid_append(
        cursor,
        "{\"function\":\"VID_GetModeDescription\",\"case\":\"fullscreen\",\"description\":\"%s\"}\n",
        VID_GetModeDescription(1));
    leavecurrentmode = true;
    cursor = mq_vid_append(
        cursor,
        "{\"function\":\"VID_GetModeDescription\",\"case\":\"desktop\","
        "\"description\":\"%s\"}\n",
        VID_GetModeDescription(2));
    leavecurrentmode = false;
    modestate = MS_FULLDIB;
    cursor = mq_vid_append(
        cursor,
        "{\"function\":\"VID_GetExtModeDescription\",\"case\":\"fullscreen\",\"description\":\"%s\"}\n",
        VID_GetExtModeDescription(1));

    mq_vid_console_clear();
    vid_modenum = 1;
    VID_DescribeCurrentMode_f();
    cursor = mq_vid_append(
        cursor,
        "{\"function\":\"VID_DescribeCurrentMode_f\",\"case\":\"current\",\"text\":\"%s\"}\n",
        mq_vid_console_text());
    mq_vid_console_clear();
    VID_NumModes_f();
    cursor = mq_vid_append(
        cursor,
        "{\"function\":\"VID_NumModes_f\",\"case\":\"plural\",\"text\":\"%s\"}\n",
        mq_vid_console_text());
    mq_vid_console_clear();
    VID_DescribeMode_f();
    cursor = mq_vid_append(
        cursor,
        "{\"function\":\"VID_DescribeMode_f\",\"case\":\"one\",\"text\":\"%s\"}\n",
        mq_vid_console_text());
    mq_vid_console_clear();
    VID_DescribeModes_f();
    cursor = mq_vid_append(
        cursor,
        "{\"function\":\"VID_DescribeModes_f\",\"case\":\"all\",\"lines\":%d}\n",
        mq_vid_console_lines());

    mq_vid_set_arguments(5, mq_vid_window_arguments());
    VID_InitDIB((HINSTANCE)1);
    cursor = mq_vid_append(
        cursor,
        "{\"function\":\"VID_InitDIB\",\"case\":\"args\",\"count\":%d,\"mode\":\"%s\"}\n",
        nummodes, modelist[0].modedesc);

    mq_vid_enum_enabled = 1;
    VID_InitFullDIB((HINSTANCE)1);
    cursor = mq_vid_append(
        cursor,
        "{\"function\":\"VID_InitFullDIB\",\"case\":\"enumerated\",\"count\":%d,"
        "\"first\":\"%s\",\"last_width\":%d,\"halfscreen\":%d}\n",
        nummodes, modelist[1].modedesc, modelist[nummodes - 1].width,
        modelist[nummodes - 1].halfscreen);

    is8bit = false;
    cursor = mq_vid_append(
        cursor,
        "{\"function\":\"VID_Is8bit\",\"case\":\"disabled\",\"result\":%d}\n",
        VID_Is8bit());
    gl_extensions = mq_vid_gl_extensions;
    VID_Init8bitPalette();
    cursor = mq_vid_append(
        cursor,
        "{\"function\":\"VID_Init8bitPalette\",\"case\":\"entrypoint\",\"enabled\":%d}\n",
        is8bit);

    mq_vid_set_arguments(2, mq_vid_gamma_arguments());
    Check_Gamma(shifted);
    cursor = mq_vid_append(
        cursor,
        "{\"function\":\"Check_Gamma\",\"case\":\"gamma-one\",\"black\":%u,\"mid\":%u,\"white\":%u}\n",
        shifted[0], shifted[127], shifted[255]);

    mq_vid_set_arguments(2, mq_vid_init_arguments());
    mq_vid_enum_enabled = 0;
    mq_vid_cvar_registers = 0;
    mq_vid_command_registers = 0;
    memcpy(shifted, palette, sizeof(shifted));
    VID_Init(shifted);
    cursor = mq_vid_append(
        cursor,
        "{\"function\":\"VID_Init\",\"case\":\"windowed\",\"cvars\":%d,\"commands\":%d,\"mode\":%d,\"size\":[%d,%d]}\n",
        mq_vid_cvar_registers, mq_vid_command_registers, vid_modenum,
        vid.width, vid.height);

    memset(modelist, 0, sizeof(modelist));
    mq_vid_mode(0, MS_WINDOWED, 640, 480, 0, "640x480");
    mq_vid_mode(1, MS_FULLDIB, 800, 600, 16, "800x600x16");
    mq_vid_mode(2, MS_FULLDIB, 1024, 768, 32, "1024x768x32");
    nummodes = 3;
    vid_modenum = 1;
    mq_vid_menu_prints = 0;
    VID_MenuDraw();
    cursor = mq_vid_append(
        cursor,
        "{\"function\":\"VID_MenuDraw\",\"case\":\"two-modes\",\"prints\":%d,\"wmodes\":%d}\n",
        mq_vid_menu_prints, vid_wmodes);

    mq_vid_menu_options = 0;
    VID_MenuKey(K_ESCAPE);
    cursor = mq_vid_append(
        cursor,
        "{\"function\":\"VID_MenuKey\",\"case\":\"escape\",\"options\":%d}\n",
        mq_vid_menu_options);

    index = (int)(cursor - output);
    return index;
}

#endif
