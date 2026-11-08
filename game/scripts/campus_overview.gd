extends Control

signal view_changed
signal closed

const Map = preload("res://scripts/campus_map.gd")
const Neon = preload("res://scripts/neon_visuals.gd")
const Land = preload("res://scripts/campus_landscape.gd")
const Terrain = preload("res://scripts/campus_terrain.gd")
const Compass = preload("res://scripts/campus_compass.gd")
const Geo = preload("res://scripts/campus_cartography.gd")
const Scale = preload("res://scripts/campus_scale.gd")
const ZOOM_LEVELS := [1.0, 1.5, 2.2, 3.2, 4.5]
const SECTORS := {
	"metalurgia": "Metalurgia", "mecanica": "Mecánica", "admin_sis": "Sistemas e Informática",
	"electrica_aulas": "Eléctrica", "civil": "Civil", "industrial": "Industrial",
	"geologia": "Geología", "minas": "Minas", "quimica_lab": "Química",
	"basicas": "Ciclo Básico", "matematicas": "Matemáticas", "fisica": "Física",
	"decanato": "Decanatura"
}

var state: Dictionary = {}
var label_size := 14
var zoom_index := 0
var map_center := Map.SIZE * 0.5
var _player := Map.SPAWN
var _heading := Vector2.UP
var _dragging := false
var _follow_player := true
var _visited := {}


func _ready() -> void:
	focus_mode = Control.FOCUS_ALL
	accessibility_name = "Mapa de Ciudad Universitaria"
	accessibility_description = "Flechas para desplazar. Más y menos para el zoom."
	mouse_default_cursor_shape = Control.CURSOR_DRAG
	var point: Variant = state.get("position", [])
	if point is Array and point.size() == 2:
		_player = Map.migrate_outside(Vector2(float(point[0]), float(point[1])), str(state.get("map_id", Map.ID)))
	var facing: Variant = state.get("exterior_facing", [])
	if facing is Array and facing.size() == 2:
		_heading = Vector2(float(facing[0]), float(facing[1])).normalized()
		if not _heading.is_finite() or _heading == Vector2.ZERO:
			_heading = Vector2.UP
	for id in state.get("visited", []):
		_visited[str(id).get_slice("/", 0)] = true
	resized.connect(_clamp_view)


func can_zoom(direction: int) -> bool:
	return zoom_index + direction >= 0 and zoom_index + direction < ZOOM_LEVELS.size()


func change_zoom(direction: int) -> void:
	if not can_zoom(direction):
		return
	if _follow_player:
		map_center = _player
	zoom_index += direction
	_clamp_view()
	view_changed.emit()


func reset_view() -> void:
	zoom_index = 0
	_follow_player = true
	_clamp_view()
	view_changed.emit()


func _map_scale() -> float:
	return maxf(0.01, minf((size.x - 24) / Map.SIZE.x, (size.y - 24) / Map.SIZE.y)) * ZOOM_LEVELS[zoom_index]


func _clamp_view() -> void:
	var half := (size * 0.5 / _map_scale()).min(Map.SIZE * 0.5)
	map_center = Map.SIZE * 0.5 if zoom_index == 0 else map_center.clamp(half, Map.SIZE - half)
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		grab_focus()
		_dragging = event.pressed
		mouse_default_cursor_shape = Control.CURSOR_MOVE if _dragging else Control.CURSOR_DRAG
		accept_event()
	elif event is InputEventMouseMotion and _dragging and zoom_index > 0:
		_follow_player = false
		map_center -= event.relative / _map_scale()
		_clamp_view()
		accept_event()
	elif event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_LEFT, KEY_RIGHT, KEY_UP, KEY_DOWN:
				var direction: Vector2 = {KEY_LEFT: Vector2.LEFT, KEY_RIGHT: Vector2.RIGHT, KEY_UP: Vector2.UP, KEY_DOWN: Vector2.DOWN}[event.keycode]
				_follow_player = zoom_index == 0
				map_center += direction * (44 / _map_scale())
				_clamp_view()
			_:
				return
		accept_event()


func _shortcut_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	match event.keycode:
		KEY_PLUS, KEY_EQUAL, KEY_KP_ADD:
			change_zoom(1)
		KEY_MINUS, KEY_KP_SUBTRACT:
			change_zoom(-1)
		KEY_M:
			closed.emit()
		_:
			return
	get_viewport().set_input_as_handled()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("#13252a"))
	var scale := _map_scale()
	var offset := size * 0.5 - map_center * scale
	var view := Rect2(-offset / scale, size / scale).intersection(Rect2(Vector2.ZERO, Map.SIZE))
	draw_set_transform(offset, 0, Vector2.ONE * scale)
	Terrain.draw(self, view, 0, false)
	for row in Map.COURTS:
		var rect := Map.court_rect(row)
		if not view.intersects(rect):
			continue
		var polygon := Geo.shape("courts", row[0])
		var color := Color("#7c9361") if str(row[0]).begins_with("FÚTBOL") else Color("#738f8b")
		if polygon.is_empty():
			draw_rect(rect, color)
		else:
			draw_colored_polygon(polygon, color)
	for building in Map.buildings():
		if not view.intersects(building["rect"]):
			continue
		draw_colored_polygon(building["footprint"], Color("#87c7ab") if _visited.has(building["id"]) else Color("#4d6970"))
	draw_set_transform(Vector2.ZERO)
	var player_position := offset + _player * scale
	_draw_labels(offset, scale, player_position)
	if Rect2(Vector2.ZERO, size).grow(18).has_point(player_position):
		_draw_player_arrow(player_position)
	Compass.draw(self, Vector2(size.x - 50, 50), 11)
	_draw_footer(scale)


func _draw_labels(offset: Vector2, scale: float, player_position: Vector2) -> void:
	var taken: Array[Rect2] = [
		Rect2(size.x - 96, 0, 96, 96),
		Rect2(0, size.y - 28, size.x, 28),
		Rect2(player_position - Vector2.ONE * 17, Vector2.ONE * 34)
	]
	var visible_area := Rect2(Vector2.ONE * 5, size - Vector2.ONE * 10)
	for id in SECTORS:
		var building := Map.building(id)
		_place_label(SECTORS[id], offset + Rect2(building["rect"]).get_center() * scale, label_size, visible_area, taken)
	if zoom_index > 0:
		for item in Land.landmarks():
			_place_label(item["title"], offset + Vector2(item["point"]) * scale, label_size - 2, visible_area, taken)
		for building in Map.buildings():
			if not SECTORS.has(building["id"]):
				_place_label(building["name"], offset + Rect2(building["rect"]).get_center() * scale, label_size - 2, visible_area, taken)


func _place_label(title: String, point: Vector2, font_size: int, area: Rect2, taken: Array[Rect2]) -> void:
	if not area.has_point(point):
		return
	var width := Neon.PIXEL_FONT.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x + 10
	var label_extent := Vector2(width, font_size + 6)
	for shift in [Vector2(-width * 0.5, -font_size - 12), Vector2(7, 5), Vector2(-width - 7, 5), Vector2(-width * 0.5, 15), Vector2(-width * 0.5, -font_size - 34)]:
		var box := Rect2((point + shift).round(), label_extent)
		if not area.encloses(box):
			continue
		if taken.any(func(other: Rect2) -> bool: return box.grow(2).intersects(other)):
			continue
		taken.append(box)
		draw_line(point, point.clamp(box.position, box.end), Color("#203439"), 2)
		draw_rect(box, Color("#13282e"))
		draw_string(Neon.PIXEL_FONT, box.position + Vector2(5, font_size + 1), title, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color("#f5f1d8"))
		return


func _draw_player_arrow(point: Vector2) -> void:
	var side := _heading.orthogonal()
	var outline := PackedVector2Array([point + _heading * 15, point - _heading * 10 + side * 10, point - _heading * 5, point - _heading * 10 - side * 10])
	draw_colored_polygon(outline, Color("#161a25"))
	var fill := PackedVector2Array()
	for vertex in outline:
		fill.append(point.lerp(vertex, 0.72))
	draw_colored_polygon(fill, Color("#fff196"))


func _draw_footer(scale: float) -> void:
	draw_rect(Rect2(0, size.y - 25, size.x, 25), Color("#10191f"))
	draw_string(Neon.PIXEL_FONT, Vector2(10, size.y - 8), Geo.CREDIT, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("#ecedcf"))
	var distance := 25 if zoom_index > 1 else 50
	var end := Vector2(size.x - 80, size.y - 13)
	var start := end - Vector2(distance * Scale.UNITS_PER_METRE * scale, 0)
	draw_line(start, end, Color("#ecedcf"), 2)
	for tick in [start, end]:
		draw_line(tick - Vector2(0, 3), tick + Vector2(0, 3), Color("#ecedcf"), 1)
	draw_string(Neon.PIXEL_FONT, end + Vector2(6, 5), "%d m aprox." % distance, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("#ecedcf"))
