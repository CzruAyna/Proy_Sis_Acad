extends RefCounted
## Volatile ambient walks. Academic schedules, classes and rewards belong to motor.
const Map = preload("res://scripts/campus_map.gd")
const Land = preload("res://scripts/campus_landscape.gd")
const Cast = preload("res://scripts/campus_cast.gd")
const Scale = preload("res://scripts/campus_scale.gd")
var actors: Array[Dictionary] = []
var rng := RandomNumberGenerator.new()
var walkable: Callable


func build(can_walk: Callable) -> void:
	walkable = can_walk
	rng.seed = 20261104
	for row in Cast.PROFESSIONS:
		_spawn(row[0], Map.building(row[4])["door"] + Vector2(31, 16))
	var blocks := Map.buildings()
	for index in range(Cast.STUDENT_COUNT):
		var block: Dictionary = blocks[(index * 7 + 8) % blocks.size()]
		_spawn("estudiante_%d" % index, block["door"] + Vector2(-32 if index % 2 == 0 else 32, 28))
	for row in Cast.STAFF:
		_spawn(row[0], Map.building(row[4])["door"] + Vector2(-45, 26))
	for index in range(Cast.DOGS.size() - 1):
		_spawn(Cast.DOGS[index][0], Land.PIEDRITAS + Vector2(-78 + index * 38, 66))


func _spawn(id: String, origin: Vector2) -> void:
	var dog := id.begins_with("perro_") or id == "piedritas_recuerdo"
	var radius := Scale.DOG_RADIUS if dog else Scale.OUTDOOR_RADIUS
	for offset in [0, 12, 24, 40, 64, 96]:
		for index in range(1 if offset == 0 else 8):
			var candidate := (origin + Vector2.from_angle(index * TAU / 8) * float(offset)).round()
			if _available_spawn(candidate, radius):
				actors.append({"id": id, "instance_id": "ambient/" + id, "point": candidate, "origin": candidate, "target": candidate, "facing": Vector2.DOWN, "stride": 0.0, "moving": false, "wait": rng.randf_range(0.2, 2.0), "radius": radius})
				return


func _available_spawn(point: Vector2, radius: float) -> bool:
	if not walkable.call(point, radius):
		return false
	for other in actors:
		if point.distance_to(other["point"]) < radius + float(other["radius"]) + 3:
			return false
	return true


func advance(delta: float, player: Vector2) -> bool:
	var changed := false
	for actor in actors:
		if actor["moving"]:
			changed = true # Repaint the resting pose when a walk stops.
		actor["moving"] = false
		actor["wait"] = maxf(0, float(actor["wait"]) - delta)
		if actor["wait"] > 0:
			continue
		var point: Vector2 = actor["point"]
		if point.distance_to(actor["target"]) < 3:
			actor["target"] = _destination(actor)
			actor["wait"] = rng.randf_range(0.3, 1.8)
			continue
		var direction: Vector2 = point.direction_to(actor["target"])
		var speed := Scale.DOG_SPEED if str(actor["id"]).begins_with("perro_") else Scale.NPC_WALK_SPEED
		var next := point.move_toward(actor["target"], speed * minf(delta, 0.1))
		var clear := next.distance_to(player) > float(actor["radius"]) + Scale.OUTDOOR_RADIUS + 3
		for other in actors:
			if other["instance_id"] != actor["instance_id"] and next.distance_to(other["point"]) < float(actor["radius"]) + float(other["radius"]) + 3:
				clear = false
				break
		if clear and walkable.call(next, actor["radius"]):
			actor["point"] = next
			actor["facing"] = direction
			actor["stride"] = float(actor["stride"]) + point.distance_to(next) * 0.12
			actor["moving"] = true
			changed = true
		else:
			actor["target"] = point
			actor["wait"] = rng.randf_range(0.5, 2.0)
	return changed


func _destination(actor: Dictionary) -> Vector2:
	var start: Vector2 = actor["point"]
	for attempt in range(10):
		var candidate: Vector2 = actor["origin"] + Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(18, 72)
		var clear := true
		for step in range(1, ceili(start.distance_to(candidate) / 10) + 1):
			var p := start.move_toward(candidate, step * 10)
			if not walkable.call(p, actor["radius"]):
				clear = false
				break
		if clear:
			return candidate.snapped(Vector2(2, 2))
	return start
