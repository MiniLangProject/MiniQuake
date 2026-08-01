# BP-075 math/chase audit

Reference units: `mathlib.c`, `mathlib.h`, `chase.c`.

Bound behavior includes 65,536-unit angle quantization, `AngleVectors`, normalization and plane helpers, `FloorDivMod`, GCD, chase defaults (`100/16/0`), the 4,096-unit trace target and preservation of yaw/roll in the refdef adapter.
