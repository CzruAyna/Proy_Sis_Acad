extends Control

signal progress_changed(state: Dictionary)
signal menu_requested
signal map_requested
signal activity_requested(building: Dictionary, room: String)
signal context_changed(text: String)

const Map = preload("res://scripts/campus_map.gd")
const Neon = preload("res://scripts/neon_visuals.gd")
const SPEED := 112.0
const PLAYER_RADIUS := 7.0
const SPRITE := [
	"....hhhh....", "...hhhhhh...", "...hssssh...", "...hssssh...", "....ssss....",
	"...bbbbbb...", "..sbbbbbbs..", "..sbbppbbs..", "..sbbppbbs..", "...bbbbbb...",
	"...dddddd...", "...dd.ddd...", "...dd.ddd...", "...kk.kkk..."
]

var player := Map.SPAWN
var camera := Map.SPAWN
var room_id := ""
var room_name := ""
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


func _ready() -> void:
	focus_mode = Control.FOCUS_ALL
	clip_contents = true
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	mouse_filter = Control.MOUSE_FILTER_STOP
	_take_focus.call_deferred()
	var rng := RandomNumberGenerator.new()
	rng.seed = 81030
	for index in range(170):
		var point := Vector2(rng.randf_range(30, Map.SIZE.x - 30), rng.randf_range(40, Map.SIZE.y - 60)).snapped(Vector2(8, 8))
		if _can_stand(point) and point.distance_to(Map.SPAWN) > 80 and not _near_road(point):
			_tree_positions.append(point)
	set_process(true)


func _take_focus() -> void:
	if is_inside_tree() and is_visible_in_tree():
		grab_focus()


func restore(saved: Dictionary) -> void:
	player = Map.SPAWN
	room_id = ""
	room_name = ""
	visited.clear()
	if saved.get("map_id", "") != Map.ID or int(saved.get("version", 0)) != 1:
		camera = player
		return
	var stored: Variant = saved.get("position", [])
	if stored is Array and stored.size() == 2 and (stored[0] is float or stored[0] is int) and (stored[1] is float or stored[1] is int):
		var point := Vector2(float(stored[0]), float(stored[1]))
		if point.is_finite() and _can_stand(point):
			player = point
	var previous: Variant = saved.get("visited", [])
	if previous is Array:
		for id in previous:
			if id is String and not visited.has(id) and _valid_visit(id):
				visited.append(id)
	var building := Map.building(str(saved.get("room_id", "")))
	var stored_room := str(saved.get("room_name", ""))
	if not building.is_empty() and stored_room == Map.LEGACY_ROOMS.get(building["id"], "__none__"):
		stored_room = "" # Old whole-block interiors now resume in their corridor.
	if not building.is_empty() and (building["rooms"].has(stored_room) or (stored_room.is_empty() and building["rooms"].size() > 1)):
		_outside = building["door"]
		room_id = building["id"]
		room_name = stored_room
		player = Map.hall_spawn(room_id) if room_name.is_empty() else Vector2(240, 278)
	camera = player


func _valid_visit(id: String) -> bool:
	for building in buildings:
		if Map.LEGACY_ROOMS.has(building["id"]) and id == str(building["id"]) + "/" + str(Map.LEGACY_ROOMS[building["id"]]):
			return true
		for room in building["rooms"]:
			if id == str(building["id"]) + "/" + str(room):
				return true
	return false


func snapshot() -> Dictionary:
	var outside := player if room_id.is_empty() else _outside
	return {"version": 1, "map_id": Map.ID, "position": [outside.x, outside.y], "room_id": room_id, "room_name": room_name, "visited": visited.duplicate()}


func _process(delta: float) -> void:
	if paused:
		return
	var direction := Vector2(float(_pressed(KEY_D) or _pressed(KEY_RIGHT)) - float(_pressed(KEY_A) or _pressed(KEY_LEFT)), float(_pressed(KEY_S) or _pressed(KEY_DOWN)) - float(_pressed(KEY_W) or _pressed(KEY_UP)))
	move_player(direction, delta, _pressed(KEY_SHIFT))
	var current := interaction_text()
	if current != _last_context:
		_last_context = current
		context_changed.emit(current)
	queue_redraw()


func _pressed(key: Key) -> bool:
	return bool(_held.get(key, false))


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key: int = event.physical_keycode if event.physical_keycode != 0 else event.keycode
		if key in [KEY_W, KEY_A, KEY_S, KEY_D, KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT, KEY_SHIFT]:
			_held[key] = event.pressed
			get_viewport().set_input_as_handled()
		if event.pressed and not event.echo:
			if key in [KEY_E, KEY_ENTER]:
				interact()
				get_viewport().set_input_as_handled()
			elif key in [KEY_P, KEY_TAB]:
				_held.clear()
				menu_requested.emit()
				get_viewport().set_input_as_handled()
			elif key == KEY_M:
				_held.clear()
				map_requested.emit()
				get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	if what in [NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_WM_WINDOW_FOCUS_OUT]:
		_held.clear()


func move_player(direction: Vector2, delta: float, running: bool = false) -> void:
	if paused or not direction.is_finite() or not is_finite(delta) or delta <= 0:
		return
	var motion := direction.limit_length() * SPEED * (1.65 if running else 1.0) * minf(delta, 0.1)
	moving = motion.length_squared() > 0.001
	if moving:
		facing = direction.normalized()
		stride += motion.length() * 0.12
		var steps := maxi(1, ceili(motion.length() / 4.0))
		for step in range(steps):
			var offset := motion / float(steps)
			var candidate := player + Vector2(offset.x, 0)
			if _can_stand(candidate):
				player = candidate
			candidate = player + Vector2(0, offset.y)
			if _can_stand(candidate):
				player = candidate
		progress_changed.emit(snapshot())
	camera = player.round()


func _can_stand(point: Vector2) -> bool:
	if not point.is_finite():
		return false
	if room_id.is_empty():
		if not Rect2(Vector2.ONE * 16, Map.SIZE - Vector2.ONE * 32).has_point(point):
			return false
		for building in buildings:
			if Rect2(building["rect"]).grow(PLAYER_RADIUS).has_point(point):
				return false
	else:
		var bounds := Rect2(Vector2(22, 30), Map.hall_size(room_id) - Vector2(44, 50)) if room_name.is_empty() else Rect2(22, 30, 436, 270)
		if not bounds.grow(-PLAYER_RADIUS).has_point(point):
			return false
		var key := room_id + "/" + room_name
		if key != _interior_key:
			_interior_key = key
			_interior_walls = Map.interior_obstacles(room_id, room_name)
		for obstacle in _interior_walls:
			if obstacle.grow(PLAYER_RADIUS).has_point(point):
				return false
	return true


func nearby_building() -> Dictionary:
	var closest := {}
	var distance := 29.0
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
			var space := nearby_room()
			return "E · Entrar a " + str(space["name"]) if not space.is_empty() else "Pasillo · Acércate a una puerta iluminada y pulsa E"
		if player.distance_to(Vector2(240, 286)) < 36:
			return "E · Volver al pasillo" if Map.building(room_id)["rooms"].size() > 1 else "E · Salir al campus"
		if player.y < 92:
			return "E · Consultar actividades y otras aulas de este bloque"
		return room_name + " · Acércate al tablero o a la puerta"
	var building := nearby_building()
	return "E · Entrar: " + str(building["name"]) if not building.is_empty() else "WASD / flechas · Camina hacia una puerta iluminada"


func interact() -> void:
	if paused:
		return
	if not room_id.is_empty():
		if room_name.is_empty():
			if player.distance_to(Map.hall_exit(room_id)) < 36:
				leave_room()
			else:
				var space := nearby_room()
				if not space.is_empty():
					enter_room(room_id, str(space["name"]))
		elif player.distance_to(Vector2(240, 286)) < 36:
			if Map.building(room_id)["rooms"].size() > 1:
				return_to_hall()
			else:
				leave_room()
		elif player.y < 92:
			activity_requested.emit(Map.building(room_id), room_name)
	else:
		var building := nearby_building()
		if not building.is_empty():
			enter_building(str(building["id"]))


func nearby_room() -> Dictionary:
	for space in Map.hall_rooms(room_id):
		if player.distance_to(space["door"]) < 30:
			return space
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
	player = Map.hall_spawn(id)
	camera = player
	_held.clear()
	progress_changed.emit(snapshot())
	context_changed.emit(interaction_text())
	queue_redraw()
	return true


func return_to_hall() -> void:
	var previous_room := room_name
	if not enter_building(room_id):
		return
	for space in Map.hall_rooms(room_id):
		if space["name"] == previous_room:
			player = space["door"]
			camera = player
	progress_changed.emit(snapshot())
	context_changed.emit(interaction_text())
	queue_redraw()


func enter_room(id: String, selected_room: String) -> bool:
	var building := Map.building(id)
	if building.is_empty() or not building["rooms"].has(selected_room):
		return false
	_outside = building["door"]
	room_id = id
	room_name = selected_room
	player = Vector2(240, 278)
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
	player = _outside
	camera = player
	_held.clear()
	progress_changed.emit(snapshot())
	context_changed.emit(interaction_text())
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("#0c1720"))
	zoom = maxf(2, floorf(minf(size.x / 420.0, size.y / 220.0)))
	var world_size := Map.SIZE if room_id.is_empty() else (Map.hall_size(room_id) if room_name.is_empty() else Map.ROOM_SIZE)
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
	draw_rect(Rect2(Vector2.ZERO, Map.SIZE), Color("#74886b"))
	for x in range(maxi(0, int(view.position.x / 32)) * 32, mini(int(Map.SIZE.x), int(view.end.x) + 32), 32):
		for y in range(maxi(0, int(view.position.y / 32)) * 32, mini(int(Map.SIZE.y), int(view.end.y) + 32), 32):
			var h := posmod(x * 17 + y * 31, 13)
			draw_rect(Rect2(x + h, y + 8, 3, 2), Color("#879674"))
	for route in Map.routes():
		draw_polyline(route, Color("#50616b"), 38, false)
		draw_polyline(route, Color("#8d9695"), 28, false)
	for row in Map.COURTS:
		var rect := Rect2(Vector2(float(row[1]), float(row[2])) * Map.SIZE / 100, Vector2(float(row[3]), float(row[4])) * Map.SIZE / 100)
		if not view.intersects(rect):
			continue
		draw_rect(rect, Color("#537768"))
		draw_rect(rect.grow(-6), Color("#c6d7b3"), false, 2)
		draw_line(Vector2(rect.get_center().x, rect.position.y + 6), Vector2(rect.get_center().x, rect.end.y - 6), Color("#c6d7b3"), 2)
		_sign(rect.position + Vector2(4, 16), str(row[0]), 10)
	for building in buildings:
		var rect: Rect2 = building["rect"]
		if not view.grow(80).intersects(rect):
			continue
		_draw_building(building)
	for point in _tree_positions:
		if view.grow(24).has_point(point):
			_tree(point)
	for point in [Vector2(1136, 832), Vector2(1264, 1360)]:
		draw_rect(Rect2(point - Vector2(24, 16), Vector2(48, 32)), Color("#c6c8b8"))
		draw_rect(Rect2(point - Vector2(18, 10), Vector2(36, 20)), Color("#537e94"))
		draw_rect(Rect2(point - Vector2(4, 6), Vector2(8, 12)), Color("#b3ddda"))
	_sign(Map.SPAWN + Vector2(-48, 32), "INGRESO FNI", 12)
	_sign(Vector2(1088, 1604), "AVENIDA DEHENE", 12)
	_sign(Vector2(1296, 792), "PLAZA FNI", 10)


func _draw_building(building: Dictionary) -> void:
	var rect: Rect2 = building["rect"]
	var kind := str(building["kind"])
	var color := Color("#796c65")
	if kind == "lab":
		color = Color("#657d85")
	elif kind == "office":
		color = Color("#8b725c")
	elif kind == "social":
		color = Color("#68795d")
	if str(building["id"]).begins_with("sis_") or building["id"] == "admin_sis":
		color = Color("#345e7f")
	draw_rect(Rect2(rect.position + Vector2(8, 14), rect.size), Color("#42524c"))
	draw_rect(Rect2(rect.position + Vector2(0, 18), rect.size), Color("#c5b596"))
	draw_rect(rect, color.darkened(0.3))
	draw_rect(rect.grow(-4), color)
	for y in range(int(rect.position.y + 8), int(rect.end.y - 4), 8):
		draw_line(Vector2(rect.position.x + 4, y), Vector2(rect.end.x - 4, y), color.lightened(0.12), 1)
	draw_rect(Rect2(rect.position + Vector2(8, 5), Vector2(rect.size.x - 16, 3)), color.lightened(0.3))
	for x in range(int(rect.position.x + 10), int(rect.end.x - 8), 24):
		draw_rect(Rect2(x - 2, rect.end.y + 3, 14, 10), Color("#888d7b"))
		draw_rect(Rect2(x, rect.end.y + 4, 10, 7), Color("#28494e"))
		draw_rect(Rect2(x + 4, rect.end.y + 4, 2, 7), Color("#a1b1a2"))
	if building["rooms"].size() > 1:
		# Separate roof bays and a long glazed front read as a multi-room block.
		var bays := mini(building["rooms"].size(), 5)
		for bay in range(1, bays):
			var x := snappedf(rect.position.x + rect.size.x * bay / bays, 2)
			draw_rect(Rect2(x, rect.position.y + 6, 2, rect.size.y - 12), color.darkened(0.25))
		_sign(rect.position + Vector2(4, 16), "%d AMBIENTES" % building["rooms"].size(), 8)
	var door: Vector2 = building["door"]
	draw_rect(Rect2(door - Vector2(10, 18), Vector2(20, 17)), Color("#223a40"))
	draw_rect(Rect2(door - Vector2(6, 15), Vector2(12, 14)), Color("#6ddab9"))
	draw_rect(Rect2(door - Vector2(14, 0), Vector2(28, 4)), Color("#d4c7a0"))
	_sign(rect.position + Vector2(3, -8), str(building["name"]), 10)
	if player.distance_to(door) < 29:
		draw_rect(Rect2(door - Vector2(13, 20), Vector2(26, 24)), Color("#fff1a6"), false, 2)


func _tree(point: Vector2) -> void:
	draw_rect(Rect2(point + Vector2(-9, 8), Vector2(22, 6)), Color("#576b57"))
	draw_rect(Rect2(point + Vector2(-2, -1), Vector2(4, 14)), Color("#78614b"))
	draw_rect(Rect2(point + Vector2(-11, -16), Vector2(22, 20)), Color("#355f50"))
	draw_rect(Rect2(point + Vector2(-7, -21), Vector2(14, 26)), Color("#416c52"))
	draw_rect(Rect2(point + Vector2(-8, -15), Vector2(10, 8)), Color("#64805a"))


func _draw_room() -> void:
	var building := Map.building(room_id)
	var kind := Map.room_kind(room_id, room_name)
	draw_rect(Rect2(Vector2.ZERO, Map.ROOM_SIZE), Color("#182732"))
	draw_rect(Rect2(16, 24, 448, 284), Color("#c1b796"))
	for x in range(24, 458, 16):
		for y in range(32, 300, 16):
			draw_rect(Rect2(x, y, 15, 15), Color("#b6af93") if (x / 16 + y / 16) % 2 == 0 else Color("#c5bd9f"))
	draw_rect(Rect2(16, 16, 448, 20), Color("#727a77"))
	draw_rect(Rect2(152, 28, 176, 32), Color("#345c53"))
	_sign(Vector2(166, 48), room_name, 10)
	for x in [28, 444]:
		for y in [64, 112, 160, 208]:
			draw_rect(Rect2(x, y, 8, 28), Color("#59898f"))
	for desk in Map.room_obstacles("lab" if kind == "computer_lab" else kind):
		draw_rect(Rect2(desk.position + Vector2(2, 4), desk.size), Color("#6d6858"))
		draw_rect(desk, Color("#8b6b4f"))
		draw_rect(Rect2(desk.position + Vector2(2, 2), Vector2(desk.size.x - 4, 3)), Color("#c79b67"))
		if kind == "computer_lab":
			draw_rect(Rect2(desk.position + Vector2(12, -8), Vector2(16, 12)), Color("#263f51"))
			draw_rect(Rect2(desk.position + Vector2(14, -6), Vector2(12, 7)), Color("#75b3bc"))
			draw_rect(Rect2(desk.position + Vector2(11, 6), Vector2(18, 4)), Color("#bbc6bc"))
			draw_rect(Rect2(desk.position + Vector2(32, 5), Vector2(3, 4)), Color("#324353"))
		elif kind == "lab":
			draw_rect(Rect2(desk.position + Vector2(9, -4), Vector2(7, 9)), Color("#adc8c1"))
			draw_rect(Rect2(desk.position + Vector2(24, -8), Vector2(3, 12)), Color("#728b91"))
			draw_rect(Rect2(desk.position + Vector2(20, 4), Vector2(12, 3)), Color("#c9dac9"))
		elif kind == "classroom":
			draw_rect(Rect2(desk.position + Vector2(6, 4), Vector2(10, 8)), Color("#e2dbc0"))
	for x in [112, 352]:
		draw_rect(Rect2(x, 38, 36, 3), Color("#eff0c8"))
	if kind == "computer_lab":
		# Network cabinet, projector and cable trunking are illustrative furnishings.
		draw_rect(Rect2(424, 38, 20, 30), Color("#233642"))
		for y in range(42, 65, 6):
			draw_rect(Rect2(428, y, 12, 3), Color("#4f6873"))
			draw_rect(Rect2(429, y, 2, 2), Color("#72d8b7"))
		draw_rect(Rect2(230, 66, 20, 8), Color("#dbe0d5"))
		draw_rect(Rect2(30, 40, 2, 240), Color("#8a9688"))
	_sign(Vector2(32, 80), "E: ACTIVIDADES / AULAS", 10)
	draw_rect(Rect2(222, 292, 36, 16), Color("#6ddab9"))
	_sign(Vector2(220, 290), "PASILLO" if building["rooms"].size() > 1 else "SALIR", 10)


func _draw_hall() -> void:
	var extent := Map.hall_size(room_id)
	draw_rect(Rect2(Vector2.ZERO, extent), Color("#15212b"))
	draw_rect(Rect2(20, 28, 680, extent.y - 44), Color("#a1a394"))
	for y in range(36, int(extent.y - 24), 16):
		for x in range(28, 694, 16):
			draw_rect(Rect2(x, y, 15, 15), Color("#adb0a0") if (x + y) % 32 == 0 else Color("#989f96"))
	draw_rect(Rect2(22, 24, 676, 16), Color("#666c69"))
	var heading := str(Map.building(room_id)["name"]) + " · PASILLO"
	var heading_width := Neon.PIXEL_FONT.get_string_size(heading, HORIZONTAL_ALIGNMENT_LEFT, -1, 11).x
	_sign(Vector2(360 - heading_width * 0.5, 22), heading, 11)
	for space in Map.hall_rooms(room_id):
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
	draw_rect(Rect2(player.round() + Vector2(-6, -2), Vector2(12, 4)), Color("#304a46"))
	var rect := Rect2(player.round() - Vector2(6, 14), Vector2(12, 16))
	if facing.x < -0.4:
		rect.position.x += rect.size.x
		rect.size.x *= -1
	draw_texture_rect(_textures[key], rect, false)


func _near_road(point: Vector2) -> bool:
	for route in Map.routes():
		for index in range(route.size() - 1):
			if point.distance_to(Geometry2D.get_closest_point_to_segment(point, route[index], route[index + 1])) < 34:
				return true
	return false
