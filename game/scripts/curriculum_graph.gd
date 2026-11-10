class_name CurriculumGraph
extends Control

signal subject_selected(sigla: String, data: Dictionary)
signal semester_changed(index: int, count: int)
signal layout_changed
signal branches_changed

const NODE_RADIUS := 44.0
const Neon = preload("res://scripts/neon_visuals.gd")
const Routing = preload("res://scripts/graph_routing.gd")
const SOURCE_RADIUS := 40.0
const CAREER_COLORS := {
	"sistemas": [Color("#3987f1"), Color("#6cc7df")],
	"informatica": [Color("#f15163"), Color("#d18bab")]
}
const STUDY_ACCENT := Color("#ffd36a")
const BRANCH_GUIDE := "Clic der. o Espacio: desplegar · N: otra rama · Enter: ficha · Rueda o +/−: zoom · Inicio: encuadrar · F: plan completo"
const KEY_GUIDE := "Flechas: elegir · Enter: abrir · Q/E: semestre · WASD o arrastre: vista · +/−: zoom · Inicio: encuadrar"

var font_scale := 1.0
var animations_enabled := true
var low_performance := false
var personal_states: Dictionary = {}
var carry_subjects: Array[Dictionary] = []
var display_height := 360.0
var _auto_fit := true
var _drag_offset := Vector2.ZERO
var _drag_start := Vector2.ZERO
var _drag_moved := false
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
var move_branch := false
var _graph_height := 420.0
var edge_paths: Array[PackedVector2Array] = []
var reference_layout := false
var _default_positions: Array[Vector2] = []
var home_semester := 0
var branch_view := false
var revealed: Dictionary = {}
var _course_by_code: Dictionary = {}
var _successors: Dictionary = {}
var _branch_references := 0
var retiring: Dictionary = {}
static var _sphere_cache: Dictionary = {}


func _ready() -> void:
	focus_mode = Control.FOCUS_ALL
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	clip_contents = true
	set_process(animations_enabled and not low_performance)
	accessibility_name = "Grafo de materias"
	accessibility_description = BRANCH_GUIDE if branch_view else KEY_GUIDE + " · 0: nivel inicial · B: mover rama · T: girar · R: restablecer"
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)
	resized.connect(_fit_after_resize)


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
	semesters = UniCatalog.semesters_for(program_id, mention_id)
	semester_index = 0
	if branch_view:
		_catalog_branches()
	_build_semester()


func move_semester(step: int) -> void:
	var next_index := clampi(semester_index + step, 0, maxi(semesters.size() - 1, 0))
	if next_index == semester_index:
		return
	semester_index = next_index
	reset_view()
	_build_semester()
	if animations_enabled and not low_performance:
		modulate.a = 0.72
		create_tween().tween_property(self, "modulate:a", 1.0, 0.15)
	semester_changed.emit(semester_index, semesters.size())


func _build_semester() -> void:
	if branch_view:
		if semesters.is_empty():
			return
		for subject in semesters[semester_index].get("subjects", []):
			_reveal_with_requirements(str(subject["sigla"]))
		for carried in carry_subjects:
			_reveal_with_requirements(str(carried["sigla"]))
		_build_branches()
		return
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
	var subjects: Array = semester.get("subjects", []).duplicate(true)
	var present := {}
	var required := {}
	for subject in subjects:
		present[str(subject["sigla"])] = true
		for requirement in subject.get("prereq", []):
			required[str(requirement)] = true
	for carried in carry_subjects:
		if int(carried.get("semester", 1)) < semester_index + 1 and not present.has(str(carried["sigla"])) and not required.has(str(carried["sigla"])):
			var extra := carried.duplicate(true)
			extra["retained"] = true
			subjects.append(extra)
	var needs_admission := false
	for subject in subjects:
		needs_admission = needs_admission or subject.get("prereq", []).has("INGRESO")
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
	var total_nodes := subjects.size() + prerequisites.size() + (1 if needs_admission else 0)
	var area_height := maxf(420.0, 120.0 + float(total_nodes) * 32.0) * maxf(font_scale, 1.0)
	_graph_height = area_height
	custom_minimum_size = Vector2(0, display_height)
	var index_by_sigla := {}
	if needs_admission:
		var root := _admission()
		root["pos"] = Vector2(graph_width * 0.22, area_height * 0.5)
		index_by_sigla["INGRESO"] = 0
		visible_nodes.append(root)
	for index in range(prerequisites.size()):
		var item: Dictionary = prerequisites[index].duplicate(true)
		item["source"] = true
		item["pos"] = _grid_position(index, prerequisites.size(), true, area_height)
		index_by_sigla[str(item.get("sigla", ""))] = visible_nodes.size()
		visible_nodes.append(item)
	for index in range(subjects.size()):
		var item: Dictionary = subjects[index].duplicate(true)
		item["source"] = false
		item["semester"] = int(item.get("semester", semester_index + 1))
		item["pos"] = _grid_position(index, subjects.size(), false, area_height)
		var target_index := visible_nodes.size()
		visible_nodes.append(item)
		for requirement in item.get("prereq", []):
			var source_index := int(index_by_sigla.get(str(requirement), -1))
			if source_index >= 0:
				edges.append(Vector2i(source_index, target_index))
			elif semester_index == 0 and str(requirement) == "INGRESO":
				edges.append(Vector2i(0, target_index))
	for node in visible_nodes:
		for carried in carry_subjects:
			if node["sigla"] == carried["sigla"]:
				node["retained"] = true
				node["semester"] = int(carried.get("semester", 1))
	_layout_nodes()
	_auto_fit = true
	fit_view.call_deferred()
	queue_redraw()


func _catalog_branches() -> void:
	_course_by_code = {"INGRESO": _admission()}
	_successors.clear()
	for semester in semesters:
		for course in semester.get("subjects", []):
			var code: String = course["sigla"]
			_course_by_code[code] = course
			for requirement in course.get("prereq", []):
				if not _successors.has(requirement):
					_successors[requirement] = []
				_successors[requirement].append(code)
	revealed["INGRESO"] = true


func _reveal_with_requirements(code: String) -> void:
	if revealed.has(code) or not _course_by_code.has(code):
		return
	revealed[code] = true
	for requirement in _course_by_code[code].get("prereq", []):
		_reveal_with_requirements(requirement)


func _build_branches() -> void:
	var focus_code := str(visible_nodes[selected]["sigla"]) if selected >= 0 and selected < visible_nodes.size() else ""
	var carried := {}
	for subject in carry_subjects:
		carried[subject["sigla"]] = subject["semester"]
	visible_nodes.clear()
	edges.clear()
	edge_paths.clear()
	reference_layout = false
	_branch_references = 0
	var indices := {}
	for code in _course_by_code:
		if not revealed.has(code):
			continue
		var node: Dictionary = _course_by_code[code].duplicate(true)
		if carried.has(code):
			node["retained"] = true
			node["semester"] = carried[code]
		indices[code] = visible_nodes.size()
		visible_nodes.append(node)
	for code in indices:
		var target: int = indices[code]
		var primary_found := false
		for requirement in _course_by_code[code].get("prereq", []):
			if not indices.has(requirement):
				continue
			var source: int = indices[requirement]
			if not primary_found and source < target:
				edges.append(Vector2i(source, target))
				primary_found = true
			else:
				var reference := visible_nodes[target].duplicate(true)
				reference["reference"] = true
				edges.append(Vector2i(source, visible_nodes.size()))
				visible_nodes.append(reference)
				_branch_references += 1
	if not _layout_branch_forest(1.0) and not _layout_branch_forest(1.75):
		_connection_references()
		_group_layout(_groups())
		if not _route_edges():
			# The reference layout gives each connection its own cell.
			push_error("No se encontró una disposición segura para las correlativas.")
			edges.clear()
			edge_paths.clear()
	hovered = -1
	selected = int(indices.get(focus_code, -1)) if not reference_layout else -1
	_auto_fit = true
	fit_view.call_deferred()
	branches_changed.emit()
	queue_redraw()


func _layout_branch_forest(spacing: float) -> bool:
	var branches := {}
	var parents := {}
	for edge in edges:
		if not branches.has(edge.x):
			branches[edge.x] = []
		branches[edge.x].append(edge.y)
		parents[edge.y] = edge.x
	var max_radius := 0.0
	var course_radius := 0.0
	for index in range(visible_nodes.size()):
		var radius := _radius(index)
		max_radius = maxf(max_radius, radius)
		if not visible_nodes[index].get("admission", false):
			course_radius = maxf(course_radius, radius)
	var levels := {}
	var y := max_radius + 85.0
	var pitch := (2 * course_radius + 92.0) * spacing
	for index in range(visible_nodes.size()):
		if not parents.has(index):
			y = _place_branch(index, 0, y, pitch, branches, levels)
	var layer_count := 1
	var gaps := {}
	for edge in edges:
		var layer: int = levels[edge.x]
		var span := absf(Vector2(visible_nodes[edge.x]["pos"]).y - Vector2(visible_nodes[edge.y]["pos"]).y)
		gaps[layer] = maxf(float(gaps.get(layer, 0.0)), span)
		layer_count = maxi(layer_count, layer + 2)
	var columns: Array[float] = [max_radius + 100.0]
	var stem := max_radius + 34.0
	for layer in range(layer_count - 1):
		columns.append(columns[-1] + 2 * stem + maxf(132.0, (float(gaps.get(layer, 0.0)) + max_radius) * 1.7 * spacing))
	for index in range(visible_nodes.size()):
		visible_nodes[index]["pos"].x = columns[levels[index]]
	graph_width = columns[-1] + max_radius + 100.0
	_set_height(y)
	var paths: Array[PackedVector2Array] = []
	for edge in edges:
		var source: Vector2 = visible_nodes[edge.x]["pos"]
		var target: Vector2 = visible_nodes[edge.y]["pos"]
		var siblings: Array = branches[edge.x]
		var port := lerpf(-0.88, 0.88, float(siblings.find(edge.y)) / float(siblings.size() - 1)) if siblings.size() > 1 else 0.0
		var start := source + Vector2(sqrt(1 - port * port), port) * (_radius(edge.x) + 4.0)
		var finish := target - Vector2(_radius(edge.y) + 5.0, 0)
		paths.append(PackedVector2Array([start, Vector2(source.x + stem, start.y), Vector2(target.x - stem, target.y), finish]))
	if not Routing.valid(visible_nodes, edges, paths, _radii()):
		return false
	edge_paths = paths
	return true


func _place_branch(index: int, layer: int, y: float, pitch: float, branches: Dictionary, levels: Dictionary) -> float:
	levels[index] = layer
	var children: Array = branches.get(index, [])
	if children.is_empty():
		visible_nodes[index]["pos"] = Vector2(0, y)
		return y + pitch
	var cursor := y
	for child in children:
		cursor = _place_branch(child, layer + 1, cursor, pitch, branches, levels)
	var first: Vector2 = visible_nodes[children[0]]["pos"]
	var last: Vector2 = visible_nodes[children[-1]]["pos"]
	visible_nodes[index]["pos"] = (first + last) * 0.5
	return cursor


func _expand_from(index: int) -> void:
	selected = index
	var code: String = visible_nodes[index]["sigla"]
	var previous := revealed.size()
	for successor in _successors.get(code, []):
		_reveal_with_requirements(successor)
	if revealed.size() > previous:
		_build_branches()
	else:
		queue_redraw()


func _next_branch() -> void:
	if visible_nodes.is_empty():
		return
	var parents := {}
	var roots: Array[int] = []
	for edge in edges:
		parents[edge.y] = edge.x
		if visible_nodes[edge.x]["sigla"] == "INGRESO":
			roots.append(edge.y)
	for index in range(visible_nodes.size()):
		if not parents.has(index) and visible_nodes[index]["sigla"] != "INGRESO":
			roots.append(index)
	if roots.is_empty():
		return
	var current := selected
	while parents.has(current) and not roots.has(current):
		current = parents[current]
	selected = roots[(roots.find(current) + 1) % roots.size()]
	var point := _animated_position(selected) * view_zoom + view_offset
	if not Rect2(Vector2(50, 40), size - Vector2(100, 80)).has_point(point):
		view_offset += size * 0.5 - point
		_auto_fit = false
	queue_redraw()


func _show_full_plan() -> void:
	for code in _course_by_code:
		revealed[code] = true
	_build_branches()


func _admission() -> Dictionary:
	return {
		"sigla": "INGRESO",
		"name": "Vía de ingreso",
		"source": true,
		"admission": true,
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
	frame.bg_color = Color(graph_theme["bg"], 1.0)
	draw_style_box(frame, Rect2(Vector2(3, 3), size - Vector2(6, 6)))
	for column in range(40, int(size.x), 40):
		for row in range(35, int(size.y), 40):
			draw_rect(Rect2(Vector2(column, row), Vector2(2, 2)), Color(glow, 0.13))
	if has_focus():
		draw_rect(Rect2(Vector2(4, 4), size - Vector2(8, 8)), Color(glow, 0.65), false, 1.0)
	draw_set_transform(view_offset, 0, Vector2.ONE * view_zoom)
	for edge_index in range(edges.size()):
		var points := edge_paths[edge_index]
		var edge := edges[edge_index]
		var edge_color := _node_color(edge.y)
		var depth := minf(_node_depth(edge.x), _node_depth(edge.y))
		Neon.path(self, points, Color(edge_color, lerpf(0.50, 0.88, depth)), 2.1, low_performance)
		if points.size() >= 3:
			var tip := points[points.size() - 1]
			var tangent := (tip - points[points.size() - 3]).normalized()
			var normal := Vector2(-tangent.y, tangent.x)
			draw_colored_polygon(PackedVector2Array([tip, tip - tangent * 12 + normal * 5, tip - tangent * 12 - normal * 5]), Color(edge_color.lerp(Color.WHITE, 0.55), lerpf(0.54, 1.0, depth)))
			if animations_enabled and not low_performance:
				var bead_index := int(fposmod(motion_time * 0.15 + float(edge_index) * 0.19, 1.0) * float(points.size() - 1))
				draw_circle(points[bead_index], 2.4, Color(edge_color.lerp(Color.WHITE, 0.55), depth))
	var order: Array[int] = []
	for index in range(visible_nodes.size()):
		order.append(index)
	order.sort_custom(func(a: int, b: int) -> bool: return _node_depth(a) < _node_depth(b))
	for index in order:
		_draw_sphere(index)
	draw_set_transform(Vector2.ZERO)
	for index in order:
		_draw_sphere_labels(index)
	var focus_index := hovered if hovered >= 0 else selected
	if focus_index >= 0 and focus_index < visible_nodes.size() and _dragging < 0:
		var item: Dictionary = visible_nodes[focus_index]
		var status := str(personal_states.get(item["sigla"], ""))
		Neon.text(self, Neon.PIXEL_FONT, Vector2(14, 24), "%s · %s%s" % [item["sigla"], item["name"], " · " + status if not status.is_empty() else ""], int(12 * font_scale), _node_color(focus_index), low_performance, size.x - 28)
	elif reference_layout or _branch_references > 0:
		Neon.text(self, Neon.PIXEL_FONT, Vector2(14, 24), "Las referencias repetidas identifican la misma materia.", int(12 * font_scale), glow, low_performance, size.x - 28)


func _node_status(index: int) -> String:
	return str(personal_states.get(visible_nodes[index]["sigla"], ""))


func _node_depth(index: int) -> float:
	if _node_status(index) != "Aprobada":
		return 1.0
	var code: String = visible_nodes[index]["sigla"]
	if retiring.has(code) and animations_enabled and not low_performance:
		return lerpf(1.0, 0.58, smoothstep(0.0, 1.15, motion_time))
	return 0.58


func _is_studying(status: String) -> bool:
	return status.begins_with("Cursando") or status.begins_with("Recursando")


func _arrival(index: int) -> float:
	if retiring.is_empty() or not animations_enabled or low_performance or motion_time >= 1.15:
		return 1.0
	var status := _node_status(index)
	if status in ["Habilitada", "Correlativa habilitada", "Inscrita"] or _is_studying(status):
		for requirement in visible_nodes[index].get("prereq", []):
			if retiring.has(requirement):
				return smoothstep(0.15, 1.15, motion_time)
	return 1.0


func _node_color(index: int) -> Color:
	var colors: Array = CAREER_COLORS.get(program_id, CAREER_COLORS["sistemas"])
	var secondary: Color = colors[1]
	var status := _node_status(index)
	if _is_studying(status) or visible_nodes[index].get("retained", false):
		return secondary.lerp(STUDY_ACCENT, _arrival(index))
	if status in ["Aprobada", "Bloqueada"] or visible_nodes[index].get("source", false):
		return secondary
	return secondary.lerp(colors[0], _arrival(index))


func _draw_sphere(index: int) -> void:
	var center := _animated_position(index)
	var radius := _radius(index)
	var status := _node_status(index)
	var glow := _node_color(index)
	var depth := _node_depth(index)
	var active := index == hovered or index == selected
	var brightness := maxf(0.54, depth) if status != "Bloqueada" else 0.60
	var body_radius := radius * lerpf(0.76, 1.0, minf(depth, _arrival(index)))
	var shadow_center := center + Vector2(10, body_radius * 0.98)
	var shadow := PackedVector2Array()
	for part in range(25):
		var angle := float(part) / 24.0 * TAU
		shadow.append(shadow_center + Vector2(cos(angle) * body_radius * 0.94, sin(angle) * body_radius * 0.26))
	draw_colored_polygon(shadow, Color(0, 0, 0, 0.45 * depth))
	# The faint outer ring retains the routed port when the sphere recedes.
	Neon.ring(self, center, radius + 0.6, Color(glow, 0.62 * brightness), low_performance)
	draw_texture_rect(_sphere_resource(glow)["texture"], Rect2(center - Vector2.ONE * body_radius, Vector2.ONE * body_radius * 2), false, Color(1, 1, 1, brightness))
	if active:
		Neon.ring(self, center, radius + 5, Color(graph_theme["core"], 0.95), low_performance)


func _draw_sphere_labels(index: int) -> void:
	var item: Dictionary = visible_nodes[index]
	var center := (_animated_position(index) * view_zoom + view_offset).round()
	var radius := _radius(index) * view_zoom
	var status := _node_status(index)
	var active := index == hovered or index == selected
	var brightness := _node_depth(index)
	var ink := Color(graph_theme["text"], 1.0 if active else maxf(0.76, brightness))
	var code_size := roundi(maxf(11.0, 13.0 * view_zoom) * font_scale)
	if branch_view and view_zoom < 0.23 and not active:
		return
	var name_size := roundi(maxf(10.0, 11.0 * view_zoom) * font_scale)
	var code := str(item.get("sigla", ""))
	_draw_node_text(center + Vector2(0, code_size * 0.35), code + (" *" if item.get("reference", false) else ""), code_size, ink, 160.0)
	var lines := _name_lines(str(item.get("name", "")), bool(item.get("admission", false)))
	var width := clampf(184.0 * view_zoom + 28.0, 126.0 * font_scale, 224.0)
	for line_index in range(lines.size()):
		var name_position := center + Vector2(0, radius + 13.0 + line_index * (name_size + 2))
		_draw_node_text(name_position, lines[line_index], name_size, ink, width)
	var tag := ""
	if _is_studying(status):
		tag = status.get_slice("·", 1).strip_edges().get_slice(" ", 0)
	elif item.get("retained", false):
		tag = "RECURSAR · S%d" % int(item.get("semester", 1))
	elif status == "Aprobada":
		tag = "✓"
	if not tag.is_empty():
		_draw_node_text(center - Vector2(0, radius + 5), tag, name_size, _node_color(index), width)


func _draw_node_text(center: Vector2, value: String, font_size: int, color: Color, width: float) -> void:
	var baseline := (center - Vector2(width * 0.5, 0)).round()
	draw_string_outline(Neon.PIXEL_FONT, baseline, value, HORIZONTAL_ALIGNMENT_CENTER, width, font_size, 2, Color.BLACK)
	draw_string(Neon.PIXEL_FONT, baseline, value, HORIZONTAL_ALIGNMENT_CENTER, width, font_size, color)


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
	if branch_view and not reference_layout:
		var branches := 0
		for edge in edges:
			branches += int(edge.x == index)
		return maxf(NODE_RADIUS * minf(font_scale, 1.12), float(branches - 1) * 21.0 + 9.0)
	var depth := 0.94 + 0.10 * float(visible_nodes[index]["pos"].y) / maxf(_graph_height, 1)
	var degree := 0
	depth = clampf(depth, 0.94, 1.04)
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
			var nx := (floorf(float(x) / 8.0) * 8.0 + 4.0) / float(resolution) * 2.0 - 1.0
			var ny := (floorf(float(y) / 8.0) * 8.0 + 4.0) / float(resolution) * 2.0 - 1.0
			var squared := nx * nx + ny * ny
			if squared >= 1.0:
				continue
			var z := sqrt(1.0 - squared)
			var normal := Vector3(nx, ny, z)
			var diffuse := 0.09 + 0.74 * maxf(normal.dot(light), 0.0)
			var specular := pow(maxf(normal.dot(halfway), 0.0), 48.0) * 0.88
			var rim := pow(1.0 - z, 3.0) * 0.28
			diffuse = snappedf(diffuse, 0.13)
			specular = snappedf(specular, 0.20)
			rim = snappedf(rim, 0.12)
			var alpha := 1.0
			image.set_pixel(x, y, Color(clampf(color.r * (diffuse + rim) + specular, 0, 1), clampf(color.g * (diffuse + rim) + specular, 0, 1), clampf(color.b * (diffuse + rim) + specular, 0, 1), alpha))
	var result := {"texture": ImageTexture.create_from_image(image), "image": image}
	_sphere_cache[key] = result
	return result


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
			_set_zoom(view_zoom * (1.16 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1.0 / 1.16), event.position)
			accept_event()
			return
		if branch_view and event.button_index == MOUSE_BUTTON_RIGHT:
			grab_focus()
			var hit := _node_at(event.position)
			if hit >= 0:
				_expand_from(hit)
			accept_event()
			return
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_RIGHT, KEY_DOWN, KEY_LEFT, KEY_UP:
				if not visible_nodes.is_empty():
					var direction := -1 if event.keycode in [KEY_LEFT, KEY_UP] else 1
					selected = posmod(selected + direction if selected >= 0 else (0 if direction > 0 else -1), visible_nodes.size())
					var screen_point := _animated_position(selected) * view_zoom + view_offset
					if not Rect2(Vector2(52, 46), size - Vector2(104, 112)).has_point(screen_point):
						view_offset += size * 0.5 - screen_point
						_auto_fit = false
					queue_redraw()
			KEY_SPACE:
				if selected >= 0 and not event.echo:
					if branch_view:
						_expand_from(selected)
					else:
						subject_selected.emit(str(visible_nodes[selected]["sigla"]), visible_nodes[selected].duplicate(true))
			KEY_N:
				if branch_view and not event.echo:
					_next_branch()
			KEY_F:
				if branch_view and not event.echo:
					_show_full_plan()
			KEY_ENTER, KEY_KP_ENTER:
				if selected >= 0 and not event.echo:
					subject_selected.emit(str(visible_nodes[selected]["sigla"]), visible_nodes[selected].duplicate(true))
			KEY_PLUS, KEY_EQUAL, KEY_KP_ADD:
				zoom_at_center(1.15)
			KEY_MINUS, KEY_KP_SUBTRACT:
				zoom_at_center(0.85)
			KEY_Q, KEY_E:
				move_semester(-1 if event.keycode == KEY_Q else 1)
			KEY_0, KEY_KP_0:
				move_semester(home_semester - semester_index)
				fit_view()
			KEY_HOME:
				fit_view()
			KEY_A, KEY_D, KEY_W, KEY_S:
				var pan: Vector2 = {KEY_A: Vector2.RIGHT, KEY_D: Vector2.LEFT, KEY_W: Vector2.DOWN, KEY_S: Vector2.UP}[event.keycode]
				pan_view(pan)
			KEY_B:
				if not branch_view and not event.echo:
					move_branch = not move_branch
					queue_redraw()
			KEY_T:
				if not branch_view and not event.echo:
					rotate_branch(PI / 6)
			KEY_R:
				if not branch_view and not event.echo:
					reset_layout()
					fit_view()
			_:
				return
		accept_event()
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				grab_focus()
				_dragging = _node_at(event.position)
				_panning = _dragging < 0
				_drag_start = event.position
				_drag_moved = false
				if _dragging >= 0:
					selected = _dragging
					_drag_offset = (event.position - view_offset) / view_zoom - Vector2(visible_nodes[selected]["pos"])
			else:
				if _dragging >= 0 and not _drag_moved:
					subject_selected.emit(str(visible_nodes[selected]["sigla"]), visible_nodes[selected].duplicate(true))
				_dragging = -1
				_panning = false
			queue_redraw()
			accept_event()
	elif event is InputEventMouseMotion:
		if _dragging >= 0:
			_drag_moved = _drag_moved or event.position.distance_to(_drag_start) > 4
			var destination: Vector2 = (event.position - view_offset) / view_zoom - _drag_offset
			if branch_view:
				if _drag_moved:
					pan_view(event.relative / 65.0)
			elif move_branch:
				_move_branch(_dragging, destination)
			else:
				_move_node(_dragging, destination)
		elif _panning:
			_auto_fit = false
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
	if what == NOTIFICATION_RESIZED and not branch_view and size.x > 10 and not semesters.is_empty():
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
	custom_minimum_size.y = display_height


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
	if not reference_layout:
		var restored: Array[Vector2] = []
		for index in range(visible_nodes.size()):
			var key := _layout_key(str(visible_nodes[index]["sigla"]))
			var point: Vector2 = manual_positions.get(key, _default_positions[index] / Vector2(graph_width, _graph_height)) * Vector2(graph_width, _graph_height)
			restored.append(point)
			visible_nodes[index]["pos"] = point
		if not _route_edges():
			for index in range(visible_nodes.size()):
				visible_nodes[index]["pos"] = _default_positions[index]
			_route_edges()
			for index in range(visible_nodes.size()):
				if restored[index].is_finite():
					_try_position(index, restored[index])


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
	var start: Vector2 = visible_nodes[index]["pos"]
	var destination := point
	if not _try_position(index, destination):
		var low := 0.0
		var high := 1.0
		for attempt in range(9):
			var weight := (low + high) * 0.5
			if _try_position(index, start.lerp(destination, weight)):
				low = weight
			else:
				high = weight
		if low < 0.001:
			_try_position(index, start)
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
	_auto_fit = false
	view_zoom = clampf(value, 0.002 if branch_view else 0.08, 1.65)
	view_offset = anchor - world * view_zoom
	queue_redraw()


func _edge_points(edge: Vector2i, _bend: float = 0.0, _animated: bool = false) -> PackedVector2Array:
	var index := edges.find(edge)
	return edge_paths[index] if index >= 0 and index < edge_paths.size() else PackedVector2Array()


func _route_edges() -> bool:
	if _route_horizontal():
		return true
	return _route_directional()


func _route_horizontal() -> bool:
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


func _route_directional() -> bool:
	var paths: Array[PackedVector2Array] = []
	for edge in edges:
		var siblings: Array[int] = []
		var center := Vector2.ZERO
		for index in range(edges.size()):
			if edges[index].x == edge.x:
				siblings.append(index)
				center += Vector2(visible_nodes[edges[index].y]["pos"])
		center /= float(siblings.size())
		var axis := (center - Vector2(visible_nodes[edge.x]["pos"])).normalized()
		if axis.is_zero_approx():
			return false
		var normal := axis.orthogonal()
		siblings.sort_custom(func(a: int, b: int) -> bool: return Vector2(visible_nodes[edges[a].y]["pos"]).dot(normal) < Vector2(visible_nodes[edges[b].y]["pos"]).dot(normal))
		var rank := siblings.find(edges.find(edge))
		var port := lerpf(-0.9, 0.9, float(rank) / float(siblings.size() - 1)) if siblings.size() > 1 else 0.0
		var start: Vector2 = visible_nodes[edge.x]["pos"] + (axis * sqrt(1.0 - port * port) + normal * port) * (_radius(edge.x) + 3)
		var finish: Vector2 = visible_nodes[edge.y]["pos"] - axis * (_radius(edge.y) + 5)
		var distance := (finish - start).dot(axis)
		if distance < 38:
			return false
		var handle := minf(120, distance * 0.38)
		var control_a := start + axis * handle
		var control_b := finish - axis * handle
		var points := PackedVector2Array()
		for sample in range(33):
			var t := float(sample) / 32
			var u := 1 - t
			points.append(start * u * u * u + control_a * 3 * u * u * t + control_b * 3 * u * t * t + finish * t * t * t)
		paths.append(points)
	if not Routing.valid(visible_nodes, edges, paths, _radii()):
		return false
	edge_paths = paths
	return true


func _branch(index: int) -> Array[int]:
	var members: Array[int] = [index]
	var cursor := 0
	while cursor < members.size():
		for edge in edges:
			var neighbor := edge.y if edge.x == members[cursor] else (edge.x if edge.y == members[cursor] else -1)
			if neighbor >= 0 and not members.has(neighbor):
				members.append(neighbor)
		cursor += 1
	return members


func _move_branch(index: int, point: Vector2) -> bool:
	if index < 0 or index >= visible_nodes.size() or not point.is_finite():
		return false
	var members := _branch(index)
	var delta := point - Vector2(visible_nodes[index]["pos"])
	var positions: Array[Vector2] = []
	for member in members:
		positions.append(visible_nodes[member]["pos"])
		visible_nodes[member]["pos"] += delta
	if not _route_edges():
		for rank in range(members.size()):
			visible_nodes[members[rank]]["pos"] = positions[rank]
		return false
	_remember_layout()
	return true


func rotate_branch(angle: float) -> bool:
	if visible_nodes.is_empty():
		return false
	var members := _branch(selected if selected >= 0 else 0)
	var center := Vector2.ZERO
	for member in members:
		center += Vector2(visible_nodes[member]["pos"])
	center /= float(members.size())
	var positions: Array[Vector2] = []
	for member in members:
		positions.append(visible_nodes[member]["pos"])
		visible_nodes[member]["pos"] = center + (Vector2(visible_nodes[member]["pos"]) - center).rotated(angle)
	if not _route_edges():
		for rank in range(members.size()):
			visible_nodes[members[rank]]["pos"] = positions[rank]
		return false
	_remember_layout()
	return true


func _remember_layout() -> void:
	for node in visible_nodes:
		manual_positions[_layout_key(str(node["sigla"]))] = Vector2(node["pos"]) / Vector2(graph_width, _graph_height)
	layout_changed.emit()
	queue_redraw()


func _fit_after_resize() -> void:
	if _auto_fit:
		fit_view.call_deferred()


func fit_view() -> void:
	if size.x < 10 or size.y < 10 or visible_nodes.is_empty():
		return
	var bounds := Rect2(visible_nodes[0]["pos"], Vector2.ZERO)
	for index in range(visible_nodes.size()):
		var radius := _radius(index)
		var center := _animated_position(index)
		bounds = bounds.expand(center - Vector2(maxf(96, radius + 7), radius + 29))
		bounds = bounds.expand(center + Vector2(maxf(96, radius + 7), radius + 54))
	view_zoom = clampf(minf((size.x - 64) / bounds.size.x, (size.y - 54) / bounds.size.y), 0.002 if branch_view else 0.08, 1.2)
	view_offset = (size * 0.5 + Vector2(0, 12)) - bounds.get_center() * view_zoom
	_auto_fit = true
	queue_redraw()

func pan_view(direction: Vector2) -> void:
	_auto_fit = false
	view_offset += direction * 65
	queue_redraw()
