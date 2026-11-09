extends RefCounted
## Persistent fictional routines, pet interactions and once-per-run rare encounter.
const Map = preload("res://scripts/campus_map.gd")
const Land = preload("res://scripts/campus_landscape.gd")
const Cast = preload("res://scripts/campus_cast.gd")
const Scale = preload("res://scripts/campus_scale.gd")
const Routes = preload("res://scripts/campus_routes.gd")
const RARE_DENOMINATOR := 100 # Explicitly selected by the user, 06/11/2026.
var actors: Array[Dictionary] = []
var rng := RandomNumberGenerator.new()
var walkable: Callable
var routes := Routes.new()
var elapsed := 0.0
var seed_value := 0
var rare := false
var petted: Array[String] = []
var monuments: Array[String] = []
var _plan_budget := 0
var _blocks: Array[Dictionary] = []
var state_revision := 0
var _cells: Dictionary = {}


func build(can_walk: Callable, saved: Dictionary = {}, new_seed: int = -1) -> void:
	actors.clear()
	petted.clear()
	monuments.clear()
	elapsed = 0
	state_revision = 0
	walkable = can_walk
	_blocks = Map.buildings()
	_spawn_cast()
	seed_value = new_seed if new_seed >= 0 else randi() & 0x7fffffff
	var version: Variant = saved.get("version")
	var valid_save: bool = (version is int or version is float) and version == 1
	if valid_save and saved.get("seed") is String:
		seed_value = str(saved["seed"]).to_int()
	rng.seed = seed_value
	rare = rng.randi_range(1, RARE_DENOMINATOR) == 1
	if valid_save and saved.get("rare") is bool:
		rare = saved["rare"]
	if rare:
		_spawn("piedritas_recuerdo", Land.PIEDRITAS + Vector2(0, 75))
	routes.build(can_walk)
	var assigned_buildings := {}
	for row in Cast.PROFESSIONS + Cast.STAFF:
		assigned_buildings[row[0]] = Map.building(row[4])
	for index in range(actors.size()):
		var actor: Dictionary = actors[index]
		var home: Dictionary = assigned_buildings.get(actor["id"], _blocks[(index * 7 + 8) % _blocks.size()])
		actor.merge({"index": index, "state": "WAIT", "home_id": home["id"], "building_id": home["id"], "room_name": str(home["rooms"][0]), "floor": 0, "route": PackedVector2Array(), "cursor": 0, "cooldown": rng.randf_range(1, 8), "pending": 0.0, "class_count": 0, "pet_count": 0})
	if valid_save:
		_restore(saved)


func _spawn_cast() -> void:
	for row in Cast.PROFESSIONS:
		_spawn(row[0], Map.building(row[4])["door"] + Vector2(31, 16))
	for index in range(Cast.STUDENT_COUNT):
		var block: Dictionary = _blocks[(index * 7 + 8) % _blocks.size()]
		_spawn("estudiante_%d" % index, block["door"] + Vector2(-32 if index % 2 == 0 else 32, 28))
	for row in Cast.STAFF:
		_spawn(row[0], Map.building(row[4])["door"] + Vector2(-45, 26))
	for index in range(Cast.DOGS.size() - 1):
		_spawn(Cast.DOGS[index][0], Land.PIEDRITAS + Vector2(-78 + index * 38, 66))


func _spawn(id: String, origin: Vector2) -> void:
	var radius := Scale.DOG_RADIUS if _is_dog_design(id) else Scale.OUTDOOR_RADIUS
	for offset in [0, 12, 24, 40, 64, 96]:
		for index in range(1 if offset == 0 else 8):
			var candidate := (origin + Vector2.from_angle(index * TAU / 8) * float(offset)).round()
			if _available_spawn(candidate, radius):
				actors.append({"id": id, "instance_id": "ambient/" + id, "point": candidate, "origin": candidate, "target": candidate, "facing": Vector2.DOWN, "stride": 0.0, "moving": false, "radius": radius})
				return


func _available_spawn(point: Vector2, radius: float) -> bool:
	if not walkable.call(point, radius):
		return false
	for other in actors:
		if point.distance_to(other["point"]) < radius + float(other["radius"]) + 3:
			return false
	return true


func _destination(actor: Dictionary) -> Vector2:
	var start: Vector2 = actor["point"]
	for attempt in range(10):
		var candidate: Vector2 = actor["origin"] + Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(18, 72)
		candidate = candidate.snapped(Vector2(2, 2))
		if routes.clear_line(start, candidate, actor["radius"]):
			return candidate
	return start


func _is_dog_design(id: String) -> bool:
	return id.begins_with("perro_") or id == "piedritas_recuerdo"


func is_dog(actor: Dictionary) -> bool:
	return _is_dog_design(actor["id"])


func find_instance(id: String) -> Dictionary:
	for actor in actors:
		if actor["instance_id"] == id:
			return actor
	return {}


func pet(id: String, player: Vector2) -> Dictionary:
	var actor := find_instance(id)
	if actor.is_empty() or not is_dog(actor) or player.distance_to(actor["point"]) > Scale.OUTDOOR_REACH or actor["state"] == "CLASS":
		return {"ok": false, "message": "Acércate al perro para acariciarlo."}
	if actor["state"] == "PET":
		return {"ok": false, "message": "Ya está recibiendo tu caricia."}
	actor["state"] = "PET"
	actor["cooldown"] = 2.5
	actor["moving"] = false
	actor["pet_count"] += 1
	if not petted.has(id):
		petted.append(id)
	return {"ok": true, "message": "El compañero se queda contigo y mueve la cola.", "rare": actor["id"] == "piedritas_recuerdo"}


func visit_monument(id: String, player: Vector2) -> bool:
	for landmark in Land.landmarks():
		if landmark["id"] == id and player.distance_to(landmark["approach"]) <= Scale.OUTDOOR_REACH:
			if not monuments.has(id):
				monuments.append(id)
			return true
	return false


func advance(delta: float, player: Vector2) -> bool:
	if not is_finite(delta) or delta <= 0:
		return false
	var dt := minf(delta, 0.25)
	elapsed += dt
	_plan_budget = 1
	_cells.clear()
	for actor in actors:
		if actor["state"] != "CLASS":
			var cell := Vector2i((Vector2(actor["point"]) / 128).floor())
			if not _cells.has(cell):
				_cells[cell] = []
			_cells[cell].append(actor["index"])
	var changed := false
	for actor in actors:
		actor["pending"] += dt
		var nearby: bool = Vector2(actor["point"]).distance_squared_to(player) < 700 * 700
		var interval := 0.1 if nearby else 0.8
		if actor["pending"] < interval:
			continue
		var step: float = actor["pending"]
		actor["pending"] = 0.0
		var previous := str(actor["state"])
		var moved := _advance_actor(actor, step, player)
		if previous != actor["state"]:
			state_revision += 1
		changed = (moved and nearby) or changed
	return changed


func _advance_actor(actor: Dictionary, dt: float, player: Vector2) -> bool:
	var was_moving: bool = actor["moving"]
	actor["moving"] = false
	actor["cooldown"] = maxf(0, float(actor["cooldown"]) - dt)
	if actor["cooldown"] > 0:
		return was_moving
	if actor["state"] == "PET":
		actor["state"] = "WAIT"
		return true
	if actor["state"] == "CLASS":
		actor["state"] = "WAIT"
		actor["class_count"] += 1
		actor["cooldown"] = 3.0
		return true
	if is_dog(actor):
		if Vector2(actor["point"]).distance_to(actor["target"]) < 4:
			actor["target"] = _destination(actor)
			actor["cooldown"] = rng.randf_range(0.5, 2)
		return _move(actor, actor["target"], dt, player) or was_moving
	var path: PackedVector2Array = actor["route"]
	if actor["cursor"] >= path.size():
		if actor["state"] == "WALK":
			actor["state"] = "CLASS"
			actor["cooldown"] = rng.randf_range(25, 55)
			return true
		if _plan_budget == 0:
			return was_moving
		_plan_budget -= 1
		var home := Map.building(actor["home_id"])
		var goal: Vector2 = home["door"]
		# Alternate a campus walk and return to the simulated classroom.
		if actor["class_count"] % 2 == 1:
			home = _blocks[(int(actor["class_count"]) + posmod(str(actor["instance_id"]).hash(), 40)) % _blocks.size()]
			goal = home["door"]
		actor["building_id"] = home["id"]
		actor["room_name"] = str(home["rooms"][0])
		actor["route"] = routes.path(actor["point"], goal)
		actor["cursor"] = 1
		if actor["route"].is_empty():
			actor["cooldown"] = 4.0
			actor["target"] = _destination(actor)
			return _move(actor, actor["target"], dt, player)
		actor["state"] = "WALK"
		path = actor["route"]
	var target: Vector2 = path[mini(actor["cursor"], path.size() - 1)]
	if Vector2(actor["point"]).distance_to(target) < 5:
		actor["cursor"] += 1
		return was_moving
	return _move(actor, target, dt, player) or was_moving


func _move(actor: Dictionary, target: Vector2, dt: float, player: Vector2) -> bool:
	var start: Vector2 = actor["point"]
	var next := start.move_toward(target, (Scale.DOG_SPEED if is_dog(actor) else Scale.NPC_WALK_SPEED) * minf(dt, 0.8))
	if next.distance_squared_to(player) < pow(float(actor["radius"]) + Scale.OUTDOOR_RADIUS + 3, 2):
		return false
	var cell := Vector2i((next / 128).floor())
	for y in range(cell.y - 1, cell.y + 2):
		for x in range(cell.x - 1, cell.x + 2):
			for index in _cells.get(Vector2i(x, y), []):
				var other: Dictionary = actors[index]
				if index != actor["index"] and other["state"] != "CLASS" and next.distance_squared_to(other["point"]) < pow(float(actor["radius"]) + float(other["radius"]) + 3, 2):
					return false
	var steps := maxi(1, ceili(start.distance_to(next) / 8))
	for i in range(1, steps + 1):
		if not walkable.call(start.lerp(next, float(i) / steps), actor["radius"]):
			actor["state"] = "WAIT"
			actor["route"] = PackedVector2Array()
			actor["target"] = start
			actor["cooldown"] = 3.0
			return false
	actor["point"] = next
	var previous_cell := Vector2i((start / 128).floor())
	if previous_cell != cell:
		_cells.get(previous_cell, []).erase(actor["index"])
		if not _cells.has(cell):
			_cells[cell] = []
		_cells[cell].append(actor["index"])
	actor["facing"] = start.direction_to(next)
	actor["stride"] += start.distance_to(next) * 0.24
	actor["moving"] = next != start
	return actor["moving"]


func snapshot() -> Dictionary:
	var records := []
	for actor in actors:
		records.append({"instance_id": actor["instance_id"], "point": [actor["point"].x, actor["point"].y], "state": actor["state"], "cooldown": actor["cooldown"], "class_count": actor["class_count"], "pet_count": actor["pet_count"], "building_id": actor["building_id"]})
	return {"version": 1, "seed": str(seed_value), "rare": rare, "rng": str(rng.state), "elapsed": elapsed, "petted": petted.duplicate(), "monuments": monuments.duplicate(), "actors": records}


func _restore(saved: Dictionary) -> void:
	if saved.get("actors") is Array:
		for record in saved["actors"].slice(0, actors.size()):
			if not record is Dictionary or not record.get("point") is Array or record["point"].size() != 2:
				continue
			var actor := find_instance(str(record.get("instance_id", "")))
			if actor.is_empty() or not (record["point"][0] is float or record["point"][0] is int) or not (record["point"][1] is float or record["point"][1] is int):
				continue
			var point := Vector2(record["point"][0], record["point"][1])
			if point.is_finite() and walkable.call(point, actor["radius"]):
				actor["point"] = point
			actor["state"] = str(record.get("state", "WAIT")) if record.get("state") in ["WAIT", "WALK", "CLASS", "PET"] else "WAIT"
			actor["cooldown"] = _saved_number(record.get("cooldown"), 60)
			actor["class_count"] = int(_saved_number(record.get("class_count"), 100000))
			actor["pet_count"] = int(_saved_number(record.get("pet_count"), 100000))
			var destination := Map.building(str(record.get("building_id", actor["building_id"])))
			if not destination.is_empty():
				actor["building_id"] = destination["id"]
				actor["room_name"] = str(destination["rooms"][0])
			if actor["state"] == "WALK":
				actor["state"] = "WAIT" # Replan from the saved position; no stale paths.
	for id in saved.get("petted", []) if saved.get("petted") is Array else []:
		var actor := find_instance(str(id))
		if not actor.is_empty() and is_dog(actor) and not petted.has(str(id)):
			petted.append(str(id))
	for id in saved.get("monuments", []) if saved.get("monuments") is Array else []:
		if id in ["piedritas", "chivato"] and not monuments.has(str(id)):
			monuments.append(str(id))
	elapsed = _saved_number(saved.get("elapsed"), 1e12)
	rng.state = str(saved.get("rng", str(rng.state))).to_int()


static func migrate_positions(saved: Dictionary, from_map: String) -> void:
	if from_map == Map.ID or not saved.get("actors") is Array:
		return
	for record in saved["actors"]:
		if not record is Dictionary:
			continue
		var position: Variant = record.get("point")
		if position is Array and position.size() == 2 and (position[0] is float or position[0] is int) and (position[1] is float or position[1] is int):
			var point := Vector2(position[0], position[1])
			if point.is_finite():
				point = Map.migrate_outside(point, from_map)
				record["point"] = [point.x, point.y]


func _saved_number(value: Variant, maximum: float) -> float:
	if not (value is float or value is int) or not is_finite(float(value)):
		return 0
	return clampf(float(value), 0, maximum)
