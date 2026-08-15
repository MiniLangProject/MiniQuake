# BP-046 sprite synchronization audit

BP-046 ports the `ST_SYNC`/`ST_RAND` model synchronization distinction. Model
sync types are transferred into client entities, random sync bases use the
shared MSVCRT-compatible Quake random sequence and grouped sprite timing adds
the entity-specific sync base. The value is part of compatibility traces and
snapshots. Twenty-two fixtures and an independent C oracle bind the sequence.
