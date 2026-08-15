# BP-038 audit — `r_part.c`

Particle updates use the server `sv_gravity` value and Binary32 storage at the
same observable boundaries as the C structures. Gravity, fire/explosion ramps,
blob acceleration/damping and particle expiry remain type-specific.
