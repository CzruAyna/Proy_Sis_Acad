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
		_spawn(row[0], Map.building(row[4])["door"] + Vector2(62, 32))
	var blocks := Map.buildings()
	for index in range(Cast.STUDENT_COUNT):
		var block: Dictionary = blocks[(index * 7 + 8) % blocks.size()]
		_spawn("estudiante_%d" % index, block["door"] + Vector2(-64 if index % 2 == 0 else 64, 56))
	for row in Cast.STAFF:
		_spawn(row[0], Map.building(row[4])["door"] + Vector2(-90, 52))
	for index in range(Cast.DOGS.size() - 1):
		_spawn(Cast.DOGS[index][0], Land.landmarks()[0]["point"] + Vector2(-156 + index * 76, 132))


func _spawn(id: String, origin: Vector2) -> void:
	var radius := Scale.DOG_RADIUS if id.begins_with("perro_") else Scale.FOOT_RADIUS
	for attempt in range(8):
		var overlap := false
		for other in actors:
			if origin.distance_to(other["point"]) < radius + float(other["radius"]) + 4:
				overlap = true
				break
		if not overlap:
			break
		origin.y += 32
	if not walkable.call(origin, radius):
		return
	actors.append({"id": id, "instance_id": "ambient/" + id, "point": origin, "origin": origin, "target": origin, "facing": Vector2.DOWN, "stride": 0.0, "moving": false, "wait": rng.randf_range(0.2, 2.0), "radius": radius})


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
		var next := point.move_toward(actor["target"], (54 if str(actor["id"]).begins_with("perro_") else 44) * minf(delta, 0.1))
		var clear := next.distance_to(player) > float(actor["radius"]) + Scale.FOOT_RADIUS + 4
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
		var candidate: Vector2 = actor["origin"] + Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(36, 144)
		var clear := true
		for step in range(1, ceili(start.distance_to(candidate) / 10) + 1):
			var p := start.move_toward(candidate, step * 10)
			if not walkable.call(p, actor["radius"]):
				clear = false
				break
		if clear:
			return candidate.snapped(Vector2(2, 2))
	return start
