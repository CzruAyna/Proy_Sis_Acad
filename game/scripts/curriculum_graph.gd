class_name CurriculumGraph
extends Control

signal subject_selected(sigla: String, data: Dictionary)
signal semester_changed(index: int, count: int)
signal layout_changed

const NODE_RADIUS := 44.0
const Neon = preload("res://scripts/neon_visuals.gd")
const Routing = preload("res://scripts/graph_routing.gd")
const SOURCE_RADIUS := 40.0
const PALETTE := [Color("#8bb5c4"), Color("#d0ae74"), Color("#9f91c6"), Color("#80ad8d"), Color("#c98670"), Color("#75a9a0")]

var font_scale := 1.0
var animations_enabled := true
var low_performance := false
var personal_states: Dictionary = {}
var program_id := ""
var mention_id := ""
var graph_theme: Dictionary = {}
var semesters: Array = []
var visible_nodes: Array[Dictionary] = []
var edges: Array[Vector2i] = []
var hovered := -1
var selected := -1
var semester_index := 0
var graph_width := 660.0
var motion_time := 0.0
var refresh_time := 0.0
var manual_positions: Dictionary = {}
var view_zoom := 1.0
var view_offset := Vector2.ZERO
var _dragging := -1
var _panning := false
var _graph_height := 420.0
var edge_paths: Array[PackedVector2Array] = []
var reference_layout := false
var _default_positions: Array[Vector2] = []
var _sphere: Dictionary = {}
static var _sphere_cache: Dictionary = {}


func _ready() -> void:
	focus_mode = Control.FOCUS_ALL
	clip_contents = true
	set_process(animations_enabled)


func _process(delta: float) -> void:
	motion_time += delta
	refresh_time += delta
	if refresh_time >= 0.1:
		refresh_time = 0.0
		queue_redraw()


func setup(pid: String, selected_mention: String = "", available_width: float = 660.0) -> void:
	program_id = pid
	mention_id = selected_mention
	graph_width = maxf(available_width, 360.0)
	graph_theme = Neon.career(pid, selected_mention)
	_sphere = _sphere_resource(graph_theme["accent"])
	semesters = UniCatalog.semesters_for(program_id, mention_id)
	semester_index = 0
	_build_semester()


func move_semester(step: int) -> void:
	var next_index := clampi(semester_index + step, 0, maxi(semesters.size() - 1, 0))
	if next_index == semester_index:
		return
	semester_index = next_index
	reset_view()
	_build_semester()
	if animations_enabled:
		modulate.a = 0.72
		create_tween().tween_property(self, "modulate:a", 1.0, 0.15)
	semester_changed.emit(semester_index, semesters.size())


func _build_semester() -> void:
	visible_nodes.clear()
	edges.clear()
	edge_paths.clear()
	hovered = -1
	selected = -1
	if semesters.is_empty() or semester_index >= semesters.size():
		custom_minimum_size = Vector2(0, 300)
		queue_redraw()
		return
	var semester: Dictionary = semesters[semester_index]
	var subjects: Array = semester.get("subjects", [])
	var prerequisites: Array = []
	var seen := {}
	for subject in subjects:
		for requirement in subject.get("prereq", []):
			var prerequisite := str(requirement)
			if prerequisite != "INGRESO" and not seen.has(prerequisite):
				var source := UniCatalog.subject_by_sigla(program_id, prerequisite, mention_id)
				if not source.is_empty():
					seen[prerequisite] = true
					prerequisites.append(source)
	var total_nodes := subjects.size() + prerequisites.size() + (1 if semester_index == 0 else 0)
	var area_height := maxf(420.0, 120.0 + float(total_nodes) * 32.0) * maxf(font_scale, 1.0)
	_graph_height = area_height
	custom_minimum_size = Vector2(0, area_height)
	var index_by_sigla := {}
	if semester_index == 0:
		var root := {
			"sigla": "INGRESO",
			"name": "Vía de ingreso",
			"source": true,
			"admission": true,
			"pos": Vector2(graph_width * 0.22, area_height * 0.5),
			"color": Color("#d0ae74"),
			"desc": "Antes del primer semestre, la FNI habilita modalidades de admisión. La convocatoria define cuáles se abren para cada periodo y carrera.",
			"admission_modes": [
				"Examen de admisión o Prueba de Suficiencia Académica.",
				"Curso propedéutico o preuniversitario, con preparación y evaluación.",
				"Excelencia académica, según condiciones de la convocatoria.",
				"Traspaso desde otra universidad pública, sujeto a revisión.",
				"Beca deportiva u otras modalidades especiales cuando sean convocadas."
			],
			"notice": "Revisa la convocatoria vigente de la FNI para requisitos, fechas, materias, cupos y modalidades disponibles."
		}
		index_by_sigla["INGRESO"] = 0
		visible_nodes.append(root)
	for index in range(prerequisites.size()):
		var item: Dictionary = prerequisites[index].duplicate(true)
		item["source"] = true
		item["pos"] = _grid_position(index, prerequisites.size(), true, area_height)
		item["color"] = PALETTE[posmod(semester_index - 1, PALETTE.size())]
		index_by_sigla[str(item.get("sigla", ""))] = visible_nodes.size()
		visible_nodes.append(item)
	for index in range(subjects.size()):
		var item: Dictionary = subjects[index].duplicate(true)
		item["source"] = false
		item["semester"] = semester_index + 1
		item["pos"] = _grid_position(index, subjects.size(), false, area_height)
		item["color"] = PALETTE[posmod(semester_index, PALETTE.size())]
		var target_index := visible_nodes.size()
		visible_nodes.append(item)
		for requirement in item.get("prereq", []):
			var source_index := int(index_by_sigla.get(str(requirement), -1))
			if source_index >= 0:
				edges.append(Vector2i(source_index, target_index))
			elif semester_index == 0 and str(requirement) == "INGRESO":
				edges.append(Vector2i(0, target_index))
	_layout_nodes()
	queue_redraw()


func _grid_position(index: int, count: int, source: bool, area_height: float) -> Vector2:
	var column := index % 2
	var row := floori(float(index) / 2.0)
	var rows := maxi(ceili(float(count) / 2.0), 1)
	var x_slots := [0.16, 0.35] if source else [0.65, 0.84]
	var x := graph_width * float(x_slots[column])
	var y := area_height * 0.5 + (float(row) - float(rows - 1) * 0.5) * 100.0
	return Vector2(x, y)


func _animated_position(index: int) -> Vector2:
	return visible_nodes[index].get("pos", Vector2.ZERO)


func _draw() -> void:
	if semesters.is_empty():
		return
	var glow: Color = graph_theme["neon"]
	var frame := Neon.panel(graph_theme, false, low_performance)
	frame.bg_color = Color(graph_theme["bg"], 0.78)
	draw_style_box(frame, Rect2(Vector2(3, 3), size - Vector2(6, 6)))
	for column in range(40, int(size.x), 40):
		for row in range(35, int(size.y), 40):
			draw_circle(Vector2(column, row), 0.8, Color(glow, 0.13))
	if has_focus():
		draw_rect(Rect2(Vector2(4, 4), size - Vector2(8, 8)), Color(glow, 0.65), false, 1.0)
	draw_set_transform(view_offset, 0, Vector2.ONE * view_zoom)
	for edge_index in range(edges.size()):
		var points := edge_paths[edge_index]
		Neon.path(self, points, Color(glow, 0.88), 2.1, low_performance)
		if points.size() >= 3:
			var tip := points[points.size() - 1]
			var tangent := (tip - points[points.size() - 3]).normalized()
			var normal := Vector2(-tangent.y, tangent.x)
			draw_colored_polygon(PackedVector2Array([tip, tip - tangent * 12 + normal * 5, tip - tangent * 12 - normal * 5]), graph_theme["core"])
			if animations_enabled and not low_performance:
				var bead_index := int(fposmod(motion_time * 0.15 + float(edge_index) * 0.19, 1.0) * float(points.size() - 1))
				draw_circle(points[bead_index], 2.4, graph_theme["core"])
	var order: Array[int] = []
	for index in range(visible_nodes.size()):
		order.append(index)
	order.sort_custom(func(a: int, b: int) -> bool: return visible_nodes[a]["pos"].y < visible_nodes[b]["pos"].y)
	for index in order:
		_draw_sphere(index)
	draw_set_transform(Vector2.ZERO)
	if reference_layout:
		Neon.text(self, ThemeDB.fallback_font, Vector2(16, 25), "Vista por conexiones: las esferas repetidas representan la misma materia.", int(12 * font_scale), glow, low_performance, size.x - 32)
	elif hovered >= 0 and hovered < visible_nodes.size() and _dragging < 0:
		var item: Dictionary = visible_nodes[hovered]
		Neon.text(self, ThemeDB.fallback_font, Vector2(16, 25), "%s · %s" % [item.get("sigla", ""), item.get("name", "")], int(12 * font_scale), glow, low_performance, size.x - 32)


func _draw_sphere(index: int) -> void:
	var item: Dictionary = visible_nodes[index]
	var center := _animated_position(index)
	var radius := _radius(index)
	var glow: Color = graph_theme["neon"]
	var active := index == hovered or index == selected
	var shadow_center := center + Vector2(10, radius * 0.98)
	var shadow := PackedVector2Array()
	for part in range(33):
		var angle := float(part) / 32.0 * TAU
		shadow.append(shadow_center + Vector2(cos(angle) * radius * 0.94, sin(angle) * radius * 0.26))
	draw_colored_polygon(shadow, Color(0, 0, 0, 0.45))
	Neon.ring(self, center, radius + 0.6, Color(glow, 0.65), low_performance)
	draw_texture_rect(_sphere["texture"], Rect2(center - Vector2.ONE * radius, Vector2.ONE * radius * 2), false)
	draw_arc(center, radius - 1.0, PI * 1.12, PI * 1.79, 32, Color(graph_theme["core"], 0.65), 1.3, true)
	if active:
		draw_arc(center, radius + 5, 0, TAU, 48, Color(graph_theme["core"], 0.95), 1.8, true)
	var code := str(item.get("sigla", ""))
	var code_size := int(13 * font_scale)
	var code_width := ThemeDB.fallback_font.get_string_size(code, HORIZONTAL_ALIGNMENT_LEFT, -1, code_size).x
	var baseline := center + Vector2(-code_width * 0.5, 5)
	draw_string_outline(ThemeDB.fallback_font, baseline, code, HORIZONTAL_ALIGNMENT_LEFT, -1, code_size, 3, Color(0.01, 0.02, 0.04, 0.9))
	draw_string(ThemeDB.fallback_font, baseline, code, HORIZONTAL_ALIGNMENT_LEFT, -1, code_size, graph_theme["text"])
	var lines := _name_lines(str(item.get("name", "")), bool(item.get("admission", false)))
	for line_index in range(lines.size()):
		var name_position := center + Vector2(-92, radius + 20 + float(line_index) * 16 * font_scale)
		draw_string_outline(ThemeDB.fallback_font, name_position, lines[line_index], HORIZONTAL_ALIGNMENT_CENTER, 184, int(11 * font_scale), 3, Color(0.01, 0.02, 0.04, 0.9))
		draw_string(ThemeDB.fallback_font, name_position, lines[line_index], HORIZONTAL_ALIGNMENT_CENTER, 184, int(11 * font_scale), graph_theme["text"])
	var status := str(personal_states.get(item.get("sigla", ""), ""))
	if not status.is_empty():
		var indicator := glow
		if status == "Aprobada":
			indicator = Color("#61ffc4")
		elif status.contains("Reprobada") or status.contains("recursar"):
			indicator = Color("#ffd36a")
		elif status == "Bloqueada":
			indicator = Color("#a0a7bb")
		var badge := center + Vector2(radius * 0.78, radius * 0.62)
		draw_circle(badge, 5.0, indicator)
		Neon.ring(self, badge, 5.0, indicator, low_performance)


func _name_lines(value: String, admission: bool) -> Array[String]:
	if admission:
		return ["Modalidades FNI"]
	var lines: Array[String] = [""]
	for word in value.split(" ", false):
		var next := (lines[-1] + " " + word).strip_edges()
		if next.length() > 23 and not lines[-1].is_empty():
			if lines.size() == 2:
				lines[-1] = lines[-1].left(21) + "…"
				break
			lines.append(word)
		else:
			lines[-1] = next
	return lines


func _radius(index: int) -> float:
	var source := bool(visible_nodes[index].get("source", false))
	var depth := 0.94 + 0.10 * float(visible_nodes[index]["pos"].y) / maxf(_graph_height, 1)
	var degree := 0
	for edge in edges:
		if edge.x == index:
			degree += 1
	return maxf((SOURCE_RADIUS if source else NODE_RADIUS) * depth * minf(font_scale, 1.12), float(degree - 1) * Routing.CLEARANCE / 1.8 + 2.0)


func _sphere_resource(color: Color) -> Dictionary:
	var key := color.to_html(false)
	if _sphere_cache.has(key):
		return _sphere_cache[key]
	var resolution := 192
	var image := Image.create(resolution, resolution, false, Image.FORMAT_RGBA8)
	var light := Vector3(-0.55, -0.70, 1.0).normalized()
	var halfway := (light + Vector3(0, 0, 1)).normalized()
	for y in range(resolution):
		for x in range(resolution):
			var nx := (float(x) + 0.5) / float(resolution) * 2.0 - 1.0
			var ny := (float(y) + 0.5) / float(resolution) * 2.0 - 1.0
			var squared := nx * nx + ny * ny
			if squared >= 1.0:
				continue
			var z := sqrt(1.0 - squared)
			var normal := Vector3(nx, ny, z)
			var diffuse := 0.09 + 0.74 * maxf(normal.dot(light), 0.0)
			var specular := pow(maxf(normal.dot(halfway), 0.0), 48.0) * 0.88
			var rim := pow(1.0 - z, 3.0) * 0.28
			var alpha := clampf((1.0 - sqrt(squared)) * float(resolution) * 0.5, 0.0, 1.0)
			image.set_pixel(x, y, Color(clampf(color.r * (diffuse + rim) + specular, 0, 1), clampf(color.g * (diffuse + rim) + specular, 0, 1), clampf(color.b * (diffuse + rim) + specular, 0, 1), alpha))
	var result := {"texture": ImageTexture.create_from_image(image), "image": image}
	_sphere_cache[key] = result
	return result


func _short_name(value: String, admission: bool) -> String:
	if admission:
		return "modalidades FNI"
	if value.length() <= 24:
		return value
	return value.substr(0, 22).strip_edges() + "…"


func _gui_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode in [KEY_RIGHT, KEY_DOWN, KEY_LEFT, KEY_UP] and not visible_nodes.is_empty():
			selected = posmod(selected + (-1 if event.keycode in [KEY_LEFT, KEY_UP] else 1), visible_nodes.size())
			subject_selected.emit(str(visible_nodes[selected].get("sigla", "")), visible_nodes[selected].duplicate(true))
			queue_redraw()
			accept_event()
		elif event.keycode in [KEY_ENTER, KEY_SPACE] and selected >= 0:
			subject_selected.emit(str(visible_nodes[selected].get("sigla", "")), visible_nodes[selected].duplicate(true))
			accept_event()
		elif event.keycode in [KEY_PLUS, KEY_EQUAL, KEY_KP_ADD]:
			zoom_at_center(1.15)
			accept_event()
		elif event.keycode in [KEY_MINUS, KEY_KP_SUBTRACT]:
			zoom_at_center(0.85)
			accept_event()
	elif event is InputEventMouseButton:
		if event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
			_set_zoom(view_zoom * (1.12 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 0.89), event.position)
			accept_event()
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				grab_focus()
				_dragging = _node_at(event.position)
				_panning = _dragging < 0
				if _dragging >= 0:
					selected = _dragging
					subject_selected.emit(str(visible_nodes[selected].get("sigla", "")), visible_nodes[selected].duplicate(true))
			else:
				_dragging = -1
				_panning = false
			queue_redraw()
			accept_event()
	elif event is InputEventMouseMotion:
		if _dragging >= 0:
			_move_node(_dragging, (event.position - view_offset) / view_zoom)
		elif _panning:
			view_offset += event.relative
		else:
			hovered = _node_at(event.position)
		mouse_default_cursor_shape = Control.CURSOR_DRAG if _panning or _dragging >= 0 else (Control.CURSOR_POINTING_HAND if hovered >= 0 else Control.CURSOR_ARROW)
		queue_redraw()


func _node_at(point: Vector2) -> int:
	var world := (point - view_offset) / view_zoom
	var result := -1
	var closest := INF
	for index in range(visible_nodes.size()):
		var distance := world.distance_to(_animated_position(index))
		if distance <= _radius(index) + 5.0 and distance < closest:
			result = index
			closest = distance
	return result


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and size.x > 10 and not semesters.is_empty():
		var available_width := maxf(size.x, 360.0)
		if not is_equal_approx(graph_width, available_width):
			var remembered := str(visible_nodes[selected].get("sigla", "")) if selected >= 0 and selected < visible_nodes.size() else ""
			graph_width = available_width
			_build_semester()
			for index in range(visible_nodes.size()):
				if visible_nodes[index].get("sigla", "") == remembered:
					selected = index


func _layout_key(sigla: String) -> String:
	return "%s/%s/%d/%s" % [program_id, mention_id, semester_index, sigla]


func _inside(point: Vector2) -> Vector2:
	return point.clamp(Vector2(92, 76), Vector2(maxf(94, graph_width - 92), maxf(78, _graph_height - 96)))


func _groups() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var used := {}
	for node in range(visible_nodes.size()):
		var children: Array[int] = []
		for edge in edges:
			if edge.x == node:
				children.append(edge.y)
		if not children.is_empty():
			result.append({"root": node, "children": children})
			used[node] = true
			for child in children:
				used[child] = true
	for node in range(visible_nodes.size()):
		if not used.has(node):
			result.append({"root": node, "children": []})
	return result


func _is_star_forest() -> bool:
	var incoming := {}
	var outgoing := {}
	for edge in edges:
		incoming[edge.y] = int(incoming.get(edge.y, 0)) + 1
		outgoing[edge.x] = true
	for node in incoming:
		if incoming[node] > 1 or outgoing.has(node):
			return false
	return true


func _connection_references() -> void:
	# An arbitrary future graph may not admit a planar drawing. Keep EVERY
	# relationship using explicit visual references in disjoint connection cells.
	var originals := visible_nodes.duplicate(true)
	var original_edges := edges.duplicate()
	var used := {}
	visible_nodes.clear()
	edges.clear()
	for edge in original_edges:
		var source: Dictionary = originals[edge.x].duplicate(true)
		var target: Dictionary = originals[edge.y].duplicate(true)
		source["reference"] = true
		target["reference"] = true
		var offset := visible_nodes.size()
		visible_nodes.append(source)
		visible_nodes.append(target)
		edges.append(Vector2i(offset, offset + 1))
		used[edge.x] = true
		used[edge.y] = true
	for node in range(originals.size()):
		if not used.has(node):
			visible_nodes.append(originals[node].duplicate(true))
	reference_layout = true


func _set_height(value: float) -> void:
	_graph_height = value
	custom_minimum_size.y = value


func _group_layout(groups: Array[Dictionary]) -> void:
	var columns := 2 if groups.size() >= 3 and graph_width >= 820 else 1
	var cell_width := graph_width / float(columns)
	var top := 60.0
	var pitch := 154.0 * maxf(font_scale, 1.0)
	for first in range(0, groups.size(), columns):
		var row_height := 210.0 * maxf(font_scale, 1.0)
		for column in range(mini(columns, groups.size() - first)):
			row_height = maxf(row_height, float(groups[first + column]["children"].size() - 1) * pitch + 190.0 * maxf(font_scale, 1.0))
		for column in range(mini(columns, groups.size() - first)):
			var group := groups[first + column]
			var left := float(column) * cell_width
			visible_nodes[group["root"]]["pos"] = Vector2(left + cell_width * (0.23 if not group["children"].is_empty() else 0.5), top + row_height * 0.5 - 20)
			var count: int = group["children"].size()
			for rank in range(count):
				visible_nodes[group["children"][rank]]["pos"] = Vector2(left + cell_width * 0.78, top + row_height * 0.5 - 20 + (float(rank) - float(count - 1) * 0.5) * pitch)
		top += row_height + 30.0
	_set_height(maxf(420, top))


func _layout_nodes() -> void:
	reference_layout = false
	if not _is_star_forest():
		_connection_references()
	var groups := _groups()
	var routed := false
	if groups.size() == 1 and groups[0]["children"].size() > 1 and not reference_layout:
		# A fan uses the width of the canvas while distinct surface ports keep
		# even the edges incident to the same source visibly separate.
		for height in [420.0, 520.0, 620.0, 740.0]:
			_set_height(height * maxf(font_scale, 1.0))
			var group := groups[0]
			visible_nodes[group["root"]]["pos"] = Vector2(graph_width * 0.16, _graph_height * 0.5)
			for rank in range(group["children"].size()):
				var angle := lerpf(-1.18, 1.18, float(rank) / float(group["children"].size() - 1))
				visible_nodes[group["children"][rank]]["pos"] = Vector2(graph_width * (0.42 + 0.46 * cos(angle)), _graph_height * (0.5 + 0.35 * sin(angle)))
			_spread_nodes()
			if _route_edges():
				routed = true
				break
	if not routed:
		_group_layout(groups)
		routed = _route_edges()
	if not routed:
		if not reference_layout:
			_connection_references()
		_group_layout(_groups())
		routed = _route_edges()
	assert(routed, "Protected connection layout must be valid")
	_default_positions.clear()
	for node in visible_nodes:
		_default_positions.append(node["pos"])
	# Legacy or resized manual positions are never trusted without validation.
	if not reference_layout:
		for index in range(visible_nodes.size()):
			var key := _layout_key(str(visible_nodes[index]["sigla"]))
			if manual_positions.has(key):
				_try_position(index, _inside(manual_positions[key] * Vector2(graph_width, _graph_height)))


func _spread_nodes() -> void:
	for node in visible_nodes:
		node["pos"] = _inside(node["pos"])
	for iteration in range(48):
		for a in range(visible_nodes.size()):
			for b in range(a + 1, visible_nodes.size()):
				var delta: Vector2 = visible_nodes[b]["pos"] - visible_nodes[a]["pos"]
				var spacing := _radius(a) + _radius(b) + 38.0
				if delta.length() < spacing:
					var push := (delta.normalized() if delta.length() > 0.1 else Vector2.RIGHT) * (spacing - delta.length()) * 0.5
					visible_nodes[a]["pos"] = _inside(visible_nodes[a]["pos"] - push)
					visible_nodes[b]["pos"] = _inside(visible_nodes[b]["pos"] + push)


func _radii() -> Array[float]:
	var result: Array[float] = []
	for index in range(visible_nodes.size()):
		result.append(_radius(index))
	return result


func _try_position(index: int, point: Vector2) -> bool:
	var before: Vector2 = visible_nodes[index]["pos"]
	visible_nodes[index]["pos"] = point
	if _route_edges():
		return true
	visible_nodes[index]["pos"] = before
	return false


func _move_node(index: int, point: Vector2) -> bool:
	if reference_layout or index < 0 or index >= visible_nodes.size() or not point.is_finite():
		return false
	if not _try_position(index, _inside(point)):
		return false
	manual_positions[_layout_key(str(visible_nodes[index]["sigla"]))] = visible_nodes[index]["pos"] / Vector2(graph_width, _graph_height)
	layout_changed.emit()
	queue_redraw()
	return true


func reset_view() -> void:
	view_zoom = 1.0
	view_offset = Vector2.ZERO
	_dragging = -1
	_panning = false
	queue_redraw()


func reset_layout() -> void:
	for index in range(visible_nodes.size()):
		manual_positions.erase(_layout_key(str(visible_nodes[index].get("sigla", ""))))
		visible_nodes[index]["pos"] = _default_positions[index]
	reset_view()
	_route_edges()
	layout_changed.emit()
	queue_redraw()


func zoom_at_center(factor: float) -> void:
	_set_zoom(view_zoom * factor, size * 0.5)


func _set_zoom(value: float, anchor: Vector2) -> void:
	var world := (anchor - view_offset) / view_zoom
	view_zoom = clampf(value, 0.65, 1.65)
	view_offset = anchor - world * view_zoom
	queue_redraw()


func _edge_points(edge: Vector2i, _bend: float = 0.0, _animated: bool = false) -> PackedVector2Array:
	var index := edges.find(edge)
	return edge_paths[index] if index >= 0 and index < edge_paths.size() else PackedVector2Array()


func _route_edges() -> bool:
	var paths: Array[PackedVector2Array] = []
	for edge in edges:
		var siblings: Array[int] = []
		for index in range(edges.size()):
			if edges[index].x == edge.x:
				siblings.append(index)
		siblings.sort_custom(func(a: int, b: int) -> bool: return visible_nodes[edges[a].y]["pos"].y < visible_nodes[edges[b].y]["pos"].y)
		var rank := siblings.find(edges.find(edge))
		var port_y := lerpf(-0.9, 0.9, float(rank) / float(siblings.size() - 1)) if siblings.size() > 1 else 0.0
		var port_radius := _radius(edge.x) + 3.0
		var start: Vector2 = visible_nodes[edge.x]["pos"] + Vector2(sqrt(1.0 - port_y * port_y), port_y) * port_radius
		var finish: Vector2 = visible_nodes[edge.y]["pos"] - Vector2(_radius(edge.y) + 5.0, 0)
		if finish.x - start.x < 38.0:
			return false
		var handle := minf(120.0, (finish.x - start.x) * 0.38)
		var control_a := start + Vector2(handle, 0)
		var control_b := finish - Vector2(handle, 0)
		var points := PackedVector2Array()
		for sample in range(33):
			var t := float(sample) / 32.0
			var u := 1.0 - t
			points.append(start * u * u * u + control_a * 3.0 * u * u * t + control_b * 3.0 * u * t * t + finish * t * t * t)
		paths.append(points)
	if not Routing.valid(visible_nodes, edges, paths, _radii()):
		return false
	edge_paths = paths
	return true
