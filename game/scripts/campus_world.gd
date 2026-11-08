extends Control

signal progress_changed(state: Dictionary)
signal menu_requested
signal map_requested
signal activity_requested(building: Dictionary, room: String)
signal minigame_requested(id: String)
signal context_changed(text: String)
signal landmark_requested(id: String)
signal actor_requested(id: String)
signal stairs_requested(id: String)

const Map = preload("res://scripts/campus_map.gd")
const Neon = preload("res://scripts/neon_visuals.gd")
const Architecture = preload("res://scripts/campus_architecture.gd")
const GameTables = preload("res://scripts/minigame_preview.gd")
const Land = preload("res://scripts/campus_landscape.gd")
const Terrain = preload("res://scripts/campus_terrain.gd")
const Foliage = preload("res://scripts/campus_foliage.gd")
const LandmarkArt = preload("res://scripts/campus_landmark_art.gd")
const Cast = preload("res://scripts/campus_cast.gd")
const Floors = preload("res://scripts/campus_floor_plan.gd")
const RoomArt = preload("res://scripts/campus_room_art.gd")
const Scale = preload("res://scripts/campus_scale.gd")
const AmbientCast = preload("res://scripts/campus_life.gd")
const Collision = preload("res://scripts/campus_collision.gd")
const SPEED := Scale.WALK_SPEED
const PLAYER_RADIUS := Scale.FOOT_RADIUS
const SPRITE := [
	"....hhhh....", "...hhhhhh...", "...hssssh...", "...hssssh...", "....ssss....",
	"...bbbbbb...", "..sbbbbbbs..", "..sbbppbbs..", "..sbbppbbs..", "...bbbbbb...",
	"...dddddd...", "...dd.ddd...", "...dd.ddd...", "...kk.kkk..."
]

var player := Map.SPAWN
var camera := Map.SPAWN
var room_id := ""
var room_name := ""
var floor_level := 0
var visited: Array[String] = []
var buildings: Array[Dictionary] = Map.buildings()
var facing := Vector2.DOWN
var stride := 0.0
var moving := false
var zoom := 2.0
var paused := false
var _held: Dictionary = {}
var _textures: Dictionary = {}
var _last_context := ""
var _outside := Map.SPAWN
var _tree_positions: Array[Vector2] = []
var _interior_key := ""
var _interior_walls: Array[Rect2] = []
var animations_enabled := true
var _ambient_phase := 0.0
var _ambient_tick := 0.0
var cast_instances: Array[Dictionary] = []
var ambient_cast := AmbientCast.new()
var _cast_tick := 0.0
var _context_tick := 0.0
var _progress_tick := 0.0
var _life_saved: Dictionary = {}
var life_enabled := true
var _life_revision := -1


func _ready() -> void:
	focus_mode = Control.FOCUS_ALL
	clip_contents = true
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	mouse_filter = Control.MOUSE_FILTER_STOP
	_take_focus.call_deferred()
	_tree_positions = Foliage.all()
	ambient_cast.build(_can_stand_outside, _life_saved)
	cast_instances = ambient_cast.actors
	set_process(true)


func _can_plant(point: Vector2) -> bool:
	return Foliage.can_plant(point, buildings)


func _take_focus() -> void:
	if is_inside_tree() and is_visible_in_tree():
		grab_focus()


func restore(saved: Dictionary) -> void:
	player = Map.SPAWN
	room_id = ""
	room_name = ""
	floor_level = 0
	_life_saved = saved.get("life", {}).duplicate(true) if saved.get("life") is Dictionary else {}
	visited.clear()
	var from_map := str(saved.get("map_id", ""))
	if from_map not in [Map.ID, Map.PREVIOUS_ID, Map.LEGACY_ID] or int(saved.get("version", 0)) != 1:
		camera = player
		return
	AmbientCast.migrate_positions(_life_saved, from_map)
	var stored: Variant = saved.get("position", [])
	if stored is Array and stored.size() == 2 and (stored[0] is float or stored[0] is int) and (stored[1] is float or stored[1] is int):
		var point := Vector2(float(stored[0]), float(stored[1]))
		point = Map.migrate_outside(point, from_map)
		if point.is_finite():
			player = _safe_outside_position(point)
	var previous: Variant = saved.get("visited", [])
	if previous is Array:
		for id in previous:
			if id is String and not visited.has(id) and _valid_visit(id):
				visited.append(id)
	var building := Map.building(str(saved.get("room_id", "")))
	var stored_room := str(saved.get("room_name", ""))
	if not building.is_empty() and stored_room == Map.LEGACY_ROOMS.get(building["id"], "__none__"):
		stored_room = "" # Old whole-block interiors now resume in their corridor.
	if not building.is_empty() and (Map.room_floor(building["id"], stored_room) >= 0 or (stored_room.is_empty() and building["rooms"].size() > 1)):
		_outside = building["door"]
		room_id = building["id"]
		room_name = stored_room
		floor_level = Map.room_floor(room_id, room_name) if not room_name.is_empty() else clampi(int(saved.get("floor", 0)), 0, Map.floor_count(room_id) - 1)
		player = Map.hall_spawn(room_id) if room_name.is_empty() else Map.room_spawn(room_id, room_name)
	camera = player


func _valid_visit(id: String) -> bool:
	for building in buildings:
		if Map.LEGACY_ROOMS.has(building["id"]) and id == str(building["id"]) + "/" + str(Map.LEGACY_ROOMS[building["id"]]):
			return true
		for room in building["rooms"]:
			if id == str(building["id"]) + "/" + str(room):
				return true
		if id.begins_with(str(building["id"]) + "/") and Map.room_floor(building["id"], id.substr(str(building["id"]).length() + 1)) >= 0:
			return true
	return false


func snapshot() -> Dictionary:
	var outside := player if room_id.is_empty() else _outside
	return {"version": 1, "map_id": Map.ID, "position": [outside.x, outside.y], "room_id": room_id, "room_name": room_name, "floor": floor_level, "visited": visited.duplicate(), "life": ambient_cast.snapshot() if not ambient_cast.actors.is_empty() else _life_saved.duplicate(true)}


func _process(delta: float) -> void:
	if paused:
		return
	var was_moving := moving
	var direction := Vector2(float(_pressed(KEY_D) or _pressed(KEY_RIGHT)) - float(_pressed(KEY_A) or _pressed(KEY_LEFT)), float(_pressed(KEY_S) or _pressed(KEY_DOWN)) - float(_pressed(KEY_W) or _pressed(KEY_UP)))
	move_player(direction, delta, _pressed(KEY_SHIFT))
	_context_tick += delta
	_progress_tick += delta
	if _context_tick >= 0.1:
		_context_tick = 0
		var current := interaction_text()
		if current != _last_context:
			_last_context = current
			context_changed.emit(current)
	if moving or was_moving:
		queue_redraw()
	if life_enabled:
		_cast_tick += delta
		if _cast_tick >= 0.1:
			if ambient_cast.advance(minf(_cast_tick, 0.1), player):
				queue_redraw()
			if ambient_cast.state_revision != _life_revision:
				_life_revision = ambient_cast.state_revision
				if not room_id.is_empty():
					queue_redraw()
			_cast_tick = 0
	if animations_enabled and room_id.is_empty():
		_ambient_tick += delta
		_ambient_phase += delta
		if _ambient_tick > 0.2:
			_ambient_tick = 0
			for fountain in Land.fountains():
				if player.distance_to(fountain["point"]) < 420:
					queue_redraw()
			if Terrain._bounds(Land.polygon(Land.POND)).grow(420).has_point(player):
				queue_redraw()


func _pressed(key: Key) -> bool:
	return bool(_held.get(key, false))


func _input(event: InputEvent) -> void:
	if paused or not is_visible_in_tree():
		return
	if event is InputEventKey:
		var key: int = event.physical_keycode if event.physical_keycode != 0 else event.keycode
		if key in [KEY_W, KEY_A, KEY_S, KEY_D, KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT, KEY_SHIFT]:
			_held[key] = event.pressed
			get_viewport().set_input_as_handled()
		if event.pressed and not event.echo:
			if key in [KEY_E, KEY_ENTER]:
				get_viewport().set_input_as_handled()
				interact()
			elif key in [KEY_P, KEY_TAB]:
				_held.clear()
				paused = true
				get_viewport().set_input_as_handled()
				menu_requested.emit()
			elif key == KEY_M:
				_held.clear()
				paused = true
				get_viewport().set_input_as_handled()
				map_requested.emit()


func _notification(what: int) -> void:
	if what in [NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_WM_WINDOW_FOCUS_OUT]:
		_held.clear()


func move_player(direction: Vector2, delta: float, running: bool = false) -> void:
	if paused or not direction.is_finite() or not is_finite(delta) or delta <= 0:
		return
	var speed := SPEED if room_id.is_empty() else Scale.INDOOR_SPEED
	var motion := direction.limit_length() * speed * (Scale.RUN_MULTIPLIER if running else 1.0) * minf(delta, 0.1)
	moving = motion.length_squared() > 0.001
	if moving:
		facing = direction.normalized()
		stride += motion.length() * (0.24 if room_id.is_empty() else 0.12)
		var steps := maxi(1, ceili(motion.length() / 4.0))
		for step in range(steps):
			var offset := motion / float(steps)
			var candidate := player + Vector2(offset.x, 0)
			if _can_stand(candidate):
				player = candidate
			candidate = player + Vector2(0, offset.y)
			if _can_stand(candidate):
				player = candidate
		if _progress_tick >= 0.25:
			_progress_tick = 0
			progress_changed.emit(snapshot())
	camera = player.round()


func _can_stand(point: Vector2) -> bool:
	if not point.is_finite():
		return false
	if room_id.is_empty():
		return _can_stand_outside(point)
	else:
		var extent := Map.hall_size(room_id) if room_name.is_empty() else Map.room_size(room_id, room_name)
		var bounds := Rect2(Vector2(22, 30), extent - Vector2(44, 50))
		if not bounds.grow(-PLAYER_RADIUS).has_point(point):
			return false
		var key := room_id + "/" + room_name + "/" + str(floor_level)
		if key != _interior_key:
			_interior_key = key
			_interior_walls = Map.interior_obstacles(room_id, room_name, floor_level)
		for obstacle in _interior_walls:
			if obstacle.grow(PLAYER_RADIUS).has_point(point):
				return false
	return true


func _can_stand_outside(point: Vector2, radius: float = Scale.OUTDOOR_RADIUS) -> bool:
	return Collision.can_stand(point, radius)


func _safe_outside_position(point: Vector2) -> Vector2:
	if _can_stand_outside(point):
		return point
	# An older, smaller footprint may have stood too close to a wall.
	for radius in [8, 16, 24, 32, 48, 64]:
		for index in range(8):
			var candidate: Vector2 = (point + Vector2.from_angle(index * TAU / 8) * float(radius)).snapped(Vector2(2, 2))
			if _can_stand_outside(candidate):
				return candidate
	return Map.SPAWN


func nearby_building() -> Dictionary:
	var closest := {}
	var distance := Scale.OUTDOOR_REACH
	for building in buildings:
		var candidate := player.distance_to(building["door"])
		if candidate < distance:
			closest = building
			distance = candidate
	return closest


func interaction_text() -> String:
	if not room_id.is_empty():
		if room_name.is_empty():
			if player.distance_to(Map.hall_exit(room_id)) < 36:
				return "E · Salir al campus · Camina por el pasillo para elegir aula"
			if _near_stairs():
				return "E · Subir/bajar · Piso %d · distribución recreada" % floor_level
			var space := nearby_room()
			return "E · Entrar a " + str(space["name"]) if not space.is_empty() else "Pasillo · Acércate a una puerta iluminada y pulsa E"
		if player.distance_to(Map.room_exit(room_id, room_name)) < 36:
			return "E · Volver al pasillo" if Map.building(room_id)["rooms"].size() > 1 else "E · Salir al campus"
		if Map.room_kind(room_id, room_name) == "games_room":
			var station := nearby_game()
			if not station.is_empty():
				return "E · Ver mesa de " + str(station["title"])
			return "Sala de juegos · Acércate a una mesa o al cartel del fondo"
		var feature := nearby_feature()
		if not feature.is_empty():
			return "E · " + str(feature["title"])
		if player.y < 92:
			return "E · Consultar actividades y otras aulas de este bloque"
		return room_name + " · Acércate al tablero o a la puerta"
	var building := nearby_building()
	if not building.is_empty():
		return "E · Entrar: " + str(building["name"])
	var feature := nearby_feature()
	if not feature.is_empty():
		return "E · " + str(feature.get("title", "Conocer este diseño"))
	return "WASD / flechas · Recorre caminos, jardines y edificios"


func interact() -> void:
	if paused:
		return
	if not room_id.is_empty():
		if room_name.is_empty():
			if player.distance_to(Map.hall_exit(room_id)) < 36:
				leave_room()
			elif _near_stairs():
				paused = true
				_held.clear()
				stairs_requested.emit(room_id)
			else:
				var space := nearby_room()
				if not space.is_empty():
					enter_room(room_id, str(space["name"]))
		elif player.distance_to(Map.room_exit(room_id, room_name)) < 36:
			if Map.building(room_id)["rooms"].size() > 1:
				return_to_hall()
			else:
				leave_room()
		elif Map.room_kind(room_id, room_name) == "games_room" and not nearby_game().is_empty():
			paused = true
			_held.clear()
			minigame_requested.emit(str(nearby_game()["id"]))
		elif not nearby_feature().is_empty():
			paused = true
			_held.clear()
			actor_requested.emit(nearby_feature()["id"])
		elif player.y < 92:
			paused = true
			_held.clear()
			activity_requested.emit(Map.building(room_id), room_name)
	else:
		var building := nearby_building()
		if not building.is_empty():
			enter_building(str(building["id"]))
		else:
			var feature := nearby_feature()
			if not feature.is_empty():
				paused = true
				_held.clear()
				if feature["kind"] == "statue":
					landmark_requested.emit(feature["id"])
				else:
					actor_requested.emit(feature["id"])


func nearby_feature() -> Dictionary:
	if not room_id.is_empty():
		var count := 0
		for actor in cast_instances:
			if actor.get("state", "") == "CLASS" and actor["building_id"] == room_id and actor["room_name"] == room_name:
				var point := Vector2(Map.room_size(room_id, room_name).x / 2, 130 + count * 36)
				if player.distance_to(point) < 45:
					return {"kind": "actor", "id": actor["instance_id"], "title": "Conversar · clase simulada"}
				count += 1
				if count == 4:
					break
		return {}
	for item in Land.landmarks():
		if player.distance_to(item["approach"]) < Scale.OUTDOOR_REACH:
			return item
	for item in cast_instances:
		if item.get("state", "WAIT") != "CLASS" and player.distance_to(item["point"]) < Scale.OUTDOOR_REACH:
			return {"kind": "actor", "id": item["instance_id"], "title": "Acariciar compañero" if ambient_cast.is_dog(item) else "Conversar · rutina simulada"}
	return {}


func _near_stairs() -> bool:
	return not room_id.is_empty() and room_name.is_empty() and Map.floor_count(room_id) > 1 and player.distance_to(Vector2(360, Map.hall_size(room_id).y - 108)) < 32


func nearby_room() -> Dictionary:
	for space in Map.hall_rooms(room_id, floor_level):
		if player.distance_to(space["door"]) < 30:
			return space
	return {}


func nearby_game() -> Dictionary:
	if room_id != "sis_e" or room_name.is_empty():
		return {}
	for station in Map.game_stations():
		if player.distance_to(station["approach"]) < 32:
			return station
	return {}


func enter_building(id: String) -> bool:
	var building := Map.building(id)
	if building.is_empty():
		return false
	if building["rooms"].size() == 1:
		return enter_room(id, str(building["rooms"][0]))
	_outside = building["door"]
	room_id = id
	room_name = ""
	floor_level = 0
	player = Map.hall_spawn(id)
	camera = player
	_held.clear()
	progress_changed.emit(snapshot())
	context_changed.emit(interaction_text())
	queue_redraw()
	return true


func return_to_hall() -> void:
	var previous_room := room_name
	var previous_floor := floor_level
	if not enter_building(room_id):
		return
	floor_level = previous_floor
	for space in Map.hall_rooms(room_id, floor_level):
		if space["name"] == previous_room:
			player = space["door"]
			camera = player
	progress_changed.emit(snapshot())
	context_changed.emit(interaction_text())
	queue_redraw()


func enter_room(id: String, selected_room: String) -> bool:
	var building := Map.building(id)
	if building.is_empty() or Map.room_floor(id, selected_room) < 0:
		return false
	_outside = building["door"]
	room_id = id
	room_name = selected_room
	floor_level = Map.room_floor(id, selected_room)
	player = Map.room_spawn(id, selected_room)
	camera = player
	var visit := id + "/" + room_name
	if not visited.has(visit):
		visited.append(visit)
	_held.clear()
	progress_changed.emit(snapshot())
	context_changed.emit(interaction_text())
	queue_redraw()
	return true


func leave_room() -> void:
	room_id = ""
	room_name = ""
	floor_level = 0
	player = _outside
	camera = player
	_held.clear()
	progress_changed.emit(snapshot())
	context_changed.emit(interaction_text())
	queue_redraw()


func change_floor(level: int) -> bool:
	if not _near_stairs() or level < 0 or level >= Map.floor_count(room_id) or absi(level - floor_level) != 1:
		return false
	floor_level = level
	player = Vector2(360, Map.hall_size(room_id).y - 108)
	camera = player
	_interior_key = ""
	_held.clear()
	progress_changed.emit(snapshot())
	context_changed.emit(interaction_text())
	queue_redraw()
	return true


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("#0c1720"))
	zoom = maxf(2, floorf(minf(size.x / 420.0, size.y / 220.0)))
	if room_id.is_empty():
		zoom += 1
	var world_size := Map.SIZE if room_id.is_empty() else (Map.hall_size(room_id) if room_name.is_empty() else Map.room_size(room_id, room_name))
	var extent := size / zoom
	var origin := camera - extent * 0.5
	origin.x = clampf(origin.x, minf(0, (world_size.x - extent.x) * 0.5), maxf(0, world_size.x - extent.x))
	origin.y = clampf(origin.y, minf(0, (world_size.y - extent.y) * 0.5), maxf(0, world_size.y - extent.y))
	draw_set_transform((-origin * zoom).round(), 0, Vector2.ONE * zoom)
	if room_id.is_empty():
		_draw_campus(Rect2(origin, extent))
	elif room_name.is_empty():
		_draw_hall()
	else:
		_draw_room()
	_draw_player()
	draw_set_transform(Vector2.ZERO)


func _draw_campus(view: Rect2) -> void:
	Terrain.draw(self, view, _ambient_phase if animations_enabled else 0)
	for row in Map.COURTS:
		var rect := Architecture.court_rect(row)
		if not view.intersects(rect):
			continue
		Architecture.court(self, row)
		_sign(rect.position + Vector2(4, 16), str(row[0]), 10)
	for building in buildings:
		var rect: Rect2 = building["rect"]
		if not view.grow(80).intersects(rect):
			continue
		_draw_building(building, view)
	for point in Foliage.visible(view):
		Architecture.tree(self, point)
	for item in Land.landmarks():
		if view.grow(90).has_point(item["point"]):
			draw_texture_rect(LandmarkArt.texture(item["id"]), Rect2(item["point"] - Vector2(14, 32), Vector2(28, 34)), false)
	for item in cast_instances:
		if item.get("state", "WAIT") == "CLASS":
			continue
		if view.grow(44).has_point(item["point"]):
			var dog := ambient_cast.is_dog(item)
			var extent := Scale.DOG_SIZE if dog else Scale.OUTDOOR_SIZE
			var destination := Rect2(item["point"] - Vector2(extent.x * 0.5, extent.y - 2), extent)
			var direction: Vector2 = item.get("facing", Vector2.DOWN)
			if direction.x < -0.4:
				destination.size.x *= -1
			var frame := int(item.get("stride", 0.0)) % 2 if item.get("moving", false) and animations_enabled else 0
			draw_texture_rect(Cast.texture(item["id"], frame, direction.y < -0.4), destination, false)
			if item.get("state", "") == "PET":
				for offset in [Vector2(-4, -34), Vector2(2, -34), Vector2(-6, -32), Vector2(4, -32), Vector2(-4, -30), Vector2(2, -30), Vector2(-2, -28), Vector2(0, -28), Vector2(0, -26)]:
					draw_rect(Rect2(Vector2(item["point"]) + offset, Vector2(3, 3)), Color("#f2c477"))
	# Wayfinding stays readable above canopies and roof details.
	for block in buildings:
		if view.grow(80).intersects(block["rect"]):
			_sign(Rect2(block["rect"]).position + Vector2(3, -8), str(block["name"]), 10)


func _draw_building(building: Dictionary, view: Rect2) -> void:
	Architecture.building(self, building, view)
	var door: Vector2 = building["door"]
	var top_access := bool(building.get("door_top", false))
	var door_rect := Rect2(door - Vector2(9, 0 if top_access else 18), Vector2(18, 17))
	draw_rect(door_rect, Color("#223a40"))
	draw_rect(door_rect.grow(-3), Color("#6ddab9"))
	draw_rect(Rect2(door - Vector2(11, 0), Vector2(22, 3)), Color("#d4c7a0"))
	if view.grow(100).has_point(door):
		_sign(door + Vector2(-24, -22), str(building["name"]), 8)
	if player.distance_to(door) < Scale.OUTDOOR_REACH:
		draw_rect(door_rect.grow(2), Color("#fff1a6"), false, 1)


func _draw_room() -> void:
	var building := Map.building(room_id)
	var kind := Map.room_kind(room_id, room_name)
	var layout := Map.room_layout(room_id, room_name)
	RoomArt.draw(self, layout, room_name)
	var count := 0
	for actor in cast_instances:
		if actor.get("state", "") == "CLASS" and actor["building_id"] == room_id and actor["room_name"] == room_name:
			var point := Vector2(layout["size"].x / 2, 130 + count * 36)
			draw_texture_rect(Cast.texture(actor["id"]), Rect2(point - Vector2(12, 30), Vector2(24, 32)), false)
			count += 1
			if count == 4:
				break
	if kind == "games_room":
		_draw_games_room()
		return
	_sign(Vector2(40, 52), room_name, 10)
	_sign(Vector2(32, 80), "E: ACTIVIDADES / AULAS", 10)
	var exit := Map.room_exit(room_id, room_name)
	draw_rect(Rect2(exit + Vector2(-18, 6), Vector2(36, 16)), Color("#6ddab9"))
	_sign(exit + Vector2(-20, 4), "PASILLO" if building["rooms"].size() > 1 else "SALIR", 10)


func _draw_games_room() -> void:
	_sign(Vector2(174, 48), "SALA DE JUEGOS · E", 10)
	for station in Map.game_stations():
		var rect: Rect2 = station["rect"]
		GameTables.draw_table(self, rect, str(station["id"]))
		_sign(rect.position + Vector2(0, -8), str(station["title"]).to_upper(), 9)
		if player.distance_to(station["approach"]) < 32:
			draw_rect(rect.grow(3), Color("#f2e8a5"), false, 2)
	# Lamps stay clear of the walkable central aisle.
	for x in [52, 408]:
		draw_rect(Rect2(x, 42, 18, 4), Color("#f5dea0"))
	_sign(Vector2(152, 67), "E: ELIGE UNA MESA", 9)
	draw_rect(Rect2(222, 292, 36, 16), Color("#6ddab9"))
	_sign(Vector2(220, 290), "SALIR", 10)


func _draw_hall() -> void:
	var extent := Map.hall_size(room_id)
	draw_rect(Rect2(Vector2.ZERO, extent), Color("#15212b"))
	draw_rect(Rect2(20, 28, 680, extent.y - 44), Color("#a1a394"))
	for y in range(36, int(extent.y - 24), 16):
		for x in range(28, 694, 16):
			draw_rect(Rect2(x, y, 15, 15), Color("#adb0a0") if (x + y) % 32 == 0 else Color("#989f96"))
	draw_rect(Rect2(22, 24, 676, 16), Color("#666c69"))
	var heading := str(Map.building(room_id)["name"]) + " · " + ("PB" if floor_level == 0 else "PISO %d" % floor_level)
	var heading_width := Neon.PIXEL_FONT.get_string_size(heading, HORIZONTAL_ALIGNMENT_LEFT, -1, 11).x
	_sign(Vector2(360 - heading_width * 0.5, 22), heading, 11)
	for space in Map.hall_rooms(room_id, floor_level):
		var rect: Rect2 = space["rect"]
		draw_rect(Rect2(rect.position + Vector2(2, 4), rect.size), Color("#6e7368"))
		draw_rect(rect, Color("#777b70"))
		draw_rect(rect.grow(-5), Color("#c0b99b"))
		var caption := str(space["name"])
		var caption_width := Neon.PIXEL_FONT.get_string_size(caption, HORIZONTAL_ALIGNMENT_LEFT, -1, 11).x
		var caption_x := rect.end.x - caption_width - 18 if rect.position.x < 360 else rect.position.x + 12
		_sign(Vector2(caption_x, rect.position.y + 20), caption, 11)
		for column in range(4):
			var p := rect.position + Vector2(24 + column * 52, 42)
			draw_rect(Rect2(p, Vector2(30, 13)), Color("#92765a"))
			draw_rect(Rect2(p + Vector2(7, -6), Vector2(16, 10)), Color("#46666e") if Map.room_kind(room_id, str(space["name"])) == "computer_lab" else Color("#ddd5b7"))
		var door: Vector2 = space["door"]
		var left := door.x < 360
		var frame := Vector2(298 if left else 416, door.y - 13)
		draw_rect(Rect2(frame, Vector2(6, 26)), Color("#64bda7"))
		draw_rect(Rect2(frame + Vector2(0, 2), Vector2(6, 21)), Color("#315b61"))
		if player.distance_to(door) < 30:
			draw_rect(Rect2(frame - Vector2(2, 2), Vector2(10, 30)), Color("#fff0ac"), false, 2)
	for y in range(72, int(extent.y - 40), 92):
		draw_rect(Rect2(351, y, 18, 3), Color("#eeedcb"))
	draw_rect(Rect2(340, extent.y - 26, 40, 8), Color("#6ddab9"))
	_sign(Vector2(342, extent.y - 30), "SALIDA", 9)
	if Map.floor_count(room_id) > 1:
		Floors._stairs(self, Vector2(329, extent.y - 130))
		_sign(Vector2(312, extent.y - 137), "E: SUBIR / BAJAR", 9)


func _sign(point: Vector2, text: String, font_size: int) -> void:
	var font: Font = Neon.PIXEL_FONT
	var width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	draw_rect(Rect2(point + Vector2(-2, -font_size), Vector2(width + 4, font_size + 4)), Color("#162c35"))
	draw_string(font, point, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color("#e3e5cb"))


func _draw_player() -> void:
	var variant := "back" if facing.y < -0.4 else ("side" if absf(facing.x) > absf(facing.y) else "front")
	var frame := posmod(int(stride), 2) if moving else 0
	var key := variant + str(frame)
	if not _textures.has(key):
		var picture := Image.create(12, 16, false, Image.FORMAT_RGBA8)
		var palette := {"h": Color("#273447"), "s": Color("#d3a67d"), "b": Color("#4189a8"), "p": Color("#e4ad61"), "d": Color("#31465e"), "k": Color("#172d3d")}
		for y in range(SPRITE.size()):
			for x in range(SPRITE[y].length()):
				var symbol: String = SPRITE[y][x]
				if palette.has(symbol):
					var color: Color = palette[symbol]
					if variant == "back" and y in [2, 3]:
						color = palette["h"]
					picture.set_pixel(x, y + (frame if y > 10 and x < 6 else 0), color)
		if variant == "front":
			picture.set_pixel(4, 3, Color("#263445"))
			picture.set_pixel(7, 3, Color("#263445"))
		_textures[key] = ImageTexture.create_from_image(picture)
	var shadow := Vector2(12, 3) if room_id.is_empty() else Vector2(24, 6)
	draw_rect(Rect2(player.round() - shadow / 2, shadow), Color("#304a46"))
	draw_texture_rect(_textures[key], player_sprite_rect(), false)


func player_sprite_rect() -> Rect2:
	# Godot mirrors negative texture widths inside the same destination bounds.
	var extent := Scale.OUTDOOR_SIZE if room_id.is_empty() else Scale.PLAYER_SIZE
	var rect := Rect2(player.round() - Vector2(extent.x / 2, extent.y - extent.y / 16), extent)
	if facing.x < -0.4:
		rect.size.x *= -1
	return rect


func _near_road(point: Vector2) -> bool:
	for route in Map.routes():
		for index in range(route.size() - 1):
			if point.distance_to(Geometry2D.get_closest_point_to_segment(point, route[index], route[index + 1])) < 34:
				return true
	return false
