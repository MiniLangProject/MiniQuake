# BP-072 WAD/graphics audit

This step covers `W_CleanupName`, `W_LoadWadFile`, `W_GetLumpinfo`, qpic headers and the console-font loading path. ASCII case folding remains identical to the original while bytes above `0x7f` are preserved without UTF-8 expansion.
