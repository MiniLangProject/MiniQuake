# BP-047 2D, HUD and screenshot audit

The shared contract captures `GL_Set2D`, screen overlay order, centered
320-pixel status bars outside deathmatch, the 0.3 viewmodel depth range and
Quake's uncompressed 24-bit TGA layout. Screen, statusbar and entity rendering
consume the same pure rules. Twenty-four fixtures and a C oracle bind the
observable layout decisions.
