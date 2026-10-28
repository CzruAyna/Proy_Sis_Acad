class_name CurriculumGraph
extends Control

signal subject_selected(sigla: String, data: Dictionary)
signal semester_changed(index: int, count: int)

const NODE_RADIUS := 36.0
const Neon = preload("res://scripts/neon_visuals.gd")
const SOURCE_RADIUS := 32.0
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


func _ready() -> void:
	focus_mode = Control.FOCUS_ALL
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
	semesters = UniCatalog.semesters_for(program_id, mention_id)
	semester_index = 0
	_build_semester()


func move_semester(step: int) -> void:
	var next_index := clampi(semester_index + step, 0, maxi(semesters.size() - 1, 0))
	if next_index == semester_index:
		return
	semester_index = next_index
	_build_semester()
	if animations_enabled:
		modulate.a = 0.72
		create_tween().tween_property(self, "modulate:a", 1.0, 0.15)
	semester_changed.emit(semester_index, semesters.size())


func _build_semester() -> void:
	visible_nodes.clear()
	edges.clear()
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
	var row_count := maxi(ceili(float(maxi(subjects.size(), prerequisites.size())) / 2.0), 1)
	var area_height := maxf(320.0, float(row_count - 1) * 100.0 + 144.0)
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
	var base: Vector2 = visible_nodes[index].get("pos", Vector2.ZERO)
	var phase := motion_time * 1.2 + float(index) * 0.92
	return base + (Vector2(sin(phase) * 2.1, cos(phase * 0.8) * 2.1) if animations_enabled else Vector2.ZERO)


func _draw() -> void:
	if semesters.is_empty():
		return
	var glow: Color = graph_theme["neon"]
	if has_focus():
		draw_rect(Rect2(Vector2(2, 2), size - Vector2(4, 4)), Color(glow, 0.9), false, 2.0)
	for edge_index in range(edges.size()):
		var edge := edges[edge_index]
		var start: Vector2 = _animated_position(edge.x)
		var finish: Vector2 = _animated_position(edge.y)
		var direction := (finish - start).normalized()
		var start_radius := SOURCE_RADIUS if visible_nodes[edge.x].get("source", false) else NODE_RADIUS
		start += direction * (start_radius + 2.0)
		finish -= direction * (NODE_RADIUS + 2.0)
		var bend := 28.0 + float((edge_index % 4) * 12)
		var curve := Curve2D.new()
		curve.add_point(start, Vector2.ZERO, Vector2(bend, 0))
		curve.add_point(finish, Vector2(bend, 0), Vector2.ZERO)
		Neon.path(self, curve.get_baked_points(), Color(glow, 0.86), 2.0, low_performance)
	for index in range(visible_nodes.size()):
		var item: Dictionary = visible_nodes[index]
		var position := _animated_position(index)
		var source := bool(item.get("source", false))
		var radius := SOURCE_RADIUS if source else NODE_RADIUS
		if animations_enabled:
			radius *= 1.0 + sin(motion_time * 1.6 + float(index)) * 0.025
		var status := str(personal_states.get(item.get("sigla", ""), ""))
		var active := index == hovered or index == selected
		draw_circle(position, radius - 1.0, graph_theme["panel"])
		Neon.ring(self, position, radius, glow, low_performance)
		if active:
			draw_arc(position, radius + 5.0, 0, TAU, 48, graph_theme["core"], 1.8, true)
		var font_size := int((12 if not source else 11) * font_scale)
		var code := str(item.get("sigla", ""))
		var code_width := ThemeDB.fallback_font.get_string_size(code, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
		Neon.text(self, ThemeDB.fallback_font, position + Vector2(-code_width * 0.5, 4), code, font_size, glow, low_performance)
		var label := _short_name(str(item.get("name", "")), bool(item.get("admission", false)))
		draw_string(ThemeDB.fallback_font, position + Vector2(-68, radius + 19), label, HORIZONTAL_ALIGNMENT_CENTER, 136, int(11 * font_scale), graph_theme["text"])
		if not status.is_empty():
			var indicator := glow
			if status == "Aprobada":
				indicator = Color("#61ffc4")
			elif status.contains("Reprobada") or status.contains("recursar"):
				indicator = Color("#ffd36a")
			elif status == "Bloqueada":
				indicator = Color("#a0a7bb")
			var badge := position + Vector2(radius * 0.77, radius * 0.62)
			draw_circle(badge, 5.0, indicator)
			Neon.ring(self, badge, 5.0, indicator, low_performance)
	if hovered >= 0 and hovered < visible_nodes.size():
		var item: Dictionary = visible_nodes[hovered]
		Neon.text(self, ThemeDB.fallback_font, Vector2(4, 18), "%s · %s" % [item.get("sigla", ""), item.get("name", "")], int(12 * font_scale), glow, low_performance, graph_width - 8)


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
	elif event is InputEventMouseMotion:
		var previous := hovered
		hovered = _node_at(event.position)
		if previous != hovered:
			queue_redraw()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var index := _node_at(event.position)
		if index >= 0:
			grab_focus()
			selected = index
			subject_selected.emit(str(visible_nodes[index].get("sigla", "")), visible_nodes[index].duplicate(true))
			queue_redraw()


func _node_at(point: Vector2) -> int:
	for index in range(visible_nodes.size()):
		var item: Dictionary = visible_nodes[index]
		var radius := SOURCE_RADIUS if item.get("source", false) else NODE_RADIUS
		if point.distance_to(_animated_position(index)) <= radius + 5.0:
			return index
	return -1


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and size.x > 10 and not semesters.is_empty():
		if not is_equal_approx(graph_width, size.x):
			var remembered := str(visible_nodes[selected].get("sigla", "")) if selected >= 0 and selected < visible_nodes.size() else ""
			graph_width = size.x
			_build_semester()
			for index in range(visible_nodes.size()):
				if visible_nodes[index].get("sigla", "") == remembered:
					selected = index
