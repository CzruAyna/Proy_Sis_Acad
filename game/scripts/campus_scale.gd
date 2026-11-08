extends RefCounted
## Frontend: keep feet, collision clearance and interaction reach in sync.
const PLAYER_SIZE := Vector2(24, 32)
const OUTDOOR_SIZE := Vector2(12, 16)
const DOG_SIZE := Vector2(10, 12)
const FOOT_RADIUS := 12.0
const OUTDOOR_RADIUS := 6.0
const DOG_RADIUS := 4.0
const UNITS_PER_METRE := 8.0
const WALK_METRES_PER_SECOND := 1.4
const OUTDOOR_TIME_RATE := 14.0
const WALK_SPEED := UNITS_PER_METRE * WALK_METRES_PER_SECOND * OUTDOOR_TIME_RATE
const NPC_WALK_SPEED := WALK_SPEED * 0.58
const DOG_SPEED := WALK_SPEED * 0.34
const OUTDOOR_REACH := 20.0
const INDOOR_SPEED := 160.0
const RUN_MULTIPLIER := 1.8
