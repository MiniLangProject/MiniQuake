# BP-068 menu lifecycle audit

Compared paths: `menu.c::M_ToggleMenu_f`, `M_Menu_Save_f`, and `M_AdjustSliders`.
Submenu toggles return to main, save entry is dispatched once, and the Windows
CD-volume slider uses the original full-unit step.

The Windows R0 result exposed two fixture-only precision errors. `Cvar_SetValue`
formats a C `float` with six decimals and reparses it into the `cvar_t.value`
float field. The corrected test therefore binds both the serialized string and
the IEEE-754 binary32 value:

| Value | Cvar string | binary32 |
|---|---|---|
| sound volume after `0.7 + 0.1` | `0.800000` | `0x3f4ccccd` |
| inverted `m_pitch` | `-0.022000` | `0xbcb43958` |

The test contains 24 fixtures; the original denominator of 22 was a reporting
error and is corrected in the R1 delivery.
