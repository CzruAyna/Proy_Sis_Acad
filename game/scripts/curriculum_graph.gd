class_name CurriculumGraph
extends Control

signal subject_selected(sigla: String, data: Dictionary)

const NODE_SIZE := Vector2(184, 62)
const COLUMN_GAP := 224.0
const ROW_GAP := 96.0

var program_id := ""
var graph_theme: Dictionary = {}
var nodes: Array[Dictionary] = []
var edges: Array[Vector2i] = []
var semester_labels: Array[Dictionary] = []
var hovered := -1
var selected := -1
var mention_id := ""


func setup(pid: String, selected_mention: String = "") -> void:
	program_id = pid
	mention_id = selected_mention
	graph_theme = UniCatalog.get_theme(pid)
	_build()


func _build() -> void:
	nodes.clear()
	edges.clear()
	semester_labels.clear()
	var program := UniCatalog.program_by_id(program_id)
	if program.is_empty():
		custom_minimum_size = Vector2(800, 480)
		return
	var subjects := UniCatalog.all_subjects(program_id, mention_id)
	var semester_counts: Dictionary = {}
	var maximum_rows := 1
	for subject in subjects:
		var semester := int(subject.get("semester", 1))
		semester_counts[semester] = int(semester_counts.get(semester, 0)) + 1
		maximum_rows = maxi(maximum_rows, int(semester_counts[semester]))
	var semesters: Array = UniCatalog.semesters_for(program_id, mention_id)
	var width := 300.0 + float(semesters.size()) * COLUMN_GAP
	var height := maxf(480.0, 150.0 + float(maximum_rows) * ROW_GAP)
	custom_minimum_size = Vector2(width, height)
	var center_y := height * 0.5
	var root := {"id": "INGRESO", "sigla": "INGRESO", "name": "Ingreso", "semester": 0, "semester_name": "Inicio", "prereq": [], "desc": "Punto de partida del recorrido académico.", "topics": [], "pos": Vector2(106, center_y)}
	nodes.append(root)
	var index_by_sigla := {"INGRESO": 0}
	for semester in semesters:
		var semester_number := int(semester.get("order", 1))
		var semester_subjects: Array = semester.get("subjects", [])
		var start_y := center_y - float(semester_subjects.size() - 1) * ROW_GAP * 0.5
		semester_labels.append({"name": str(semester.get("name", "SEMESTRE %d" % semester_number)), "pos": Vector2(260.0 + float(semester_number - 1) * COLUMN_GAP, 28)})
		for index in range(semester_subjects.size()):
			var subject: Dictionary = semester_subjects[index]
			var sigla := str(subject.get("sigla", ""))
			var node := subject.duplicate(true)
			node["id"] = sigla
			node["semester"] = semester_number
			node["semester_name"] = semester.get("name", "")
			node["pos"] = Vector2(260.0 + float(semester_number - 1) * COLUMN_GAP, start_y + float(index) * ROW_GAP)
			index_by_sigla[sigla] = nodes.size()
			nodes.append(node)
	for index in range(1, nodes.size()):
		var prerequisites: Array = nodes[index].get("prereq", [])
		for prerequisite in prerequisites:
			var source_index := int(index_by_sigla.get(str(prerequisite), -1))
			if source_index >= 0:
				edges.append(Vector2i(source_index, index))
	queue_redraw()


func _draw() -> void:
	if nodes.is_empty():
		return
	var accent: Color = graph_theme.get("accent", Color("#4d9bff"))
	var line: Color = graph_theme.get("grid", Color("#2a3550"))
	var panel: Color = graph_theme.get("panel", Color("#16213e"))
	var text: Color = graph_theme.get("text", Color("#e6edf3"))
	var secondary: Color = graph_theme.get("sub", Color("#9fb3c8"))
	for semester in semester_labels:
		draw_string(ThemeDB.fallback_font, semester["pos"], str(semester["name"]), HORIZONTAL_ALIGNMENT_CENTER, 200, 12, secondary)
	for edge in edges:
		var from_position: Vector2 = nodes[edge.x]["pos"]
		var to_position: Vector2 = nodes[edge.y]["pos"]
		var start := from_position + Vector2(NODE_SIZE.x * 0.5, 0)
		var finish := to_position - Vector2(NODE_SIZE.x * 0.5 + 5, 0)
		draw_line(start, finish, line, 2.0)
		draw_colored_polygon(PackedVector2Array([finish, finish + Vector2(-8, -5), finish + Vector2(-8, 5)]), accent)
	for index in range(nodes.size()):
		var node: Dictionary = nodes[index]
		var position: Vector2 = node["pos"]
		var rect := Rect2(position - NODE_SIZE * 0.5, NODE_SIZE)
		var is_active := index == hovered or index == selected
		var fill: Color = accent.darkened(0.28) if index == selected else panel.lightened(0.1) if index == hovered else panel
		draw_rect(rect, fill)
		draw_rect(rect, accent if is_active else line, false, 2.0)
		draw_string(ThemeDB.fallback_font, position + Vector2(-NODE_SIZE.x * 0.5 + 8, -4), str(node.get("sigla", "")), HORIZONTAL_ALIGNMENT_LEFT, NODE_SIZE.x - 16, 13, text)
		draw_string(ThemeDB.fallback_font, position + Vector2(-NODE_SIZE.x * 0.5 + 8, 17), str(node.get("name", "")), HORIZONTAL_ALIGNMENT_LEFT, NODE_SIZE.x - 16, 11, secondary, TextServer.JUSTIFICATION_WORD_BOUND)
	if hovered >= 0 and hovered < nodes.size():
		var node: Dictionary = nodes[hovered]
		var tooltip_size := Vector2(300, 64)
		var tooltip_pos := get_local_mouse_position() + Vector2(14, 14)
		tooltip_pos.x = clampf(tooltip_pos.x, 4, size.x - tooltip_size.x - 4)
		tooltip_pos.y = clampf(tooltip_pos.y, 4, size.y - tooltip_size.y - 4)
		var tooltip := Rect2(tooltip_pos, tooltip_size)
		draw_rect(tooltip, panel)
		draw_rect(tooltip, accent, false, 2.0)
		draw_string(ThemeDB.fallback_font, tooltip_pos + Vector2(8, 18), "%s · %s" % [node.get("sigla", ""), node.get("name", "")], HORIZONTAL_ALIGNMENT_LEFT, 284, 12, text)
		draw_string(ThemeDB.fallback_font, tooltip_pos + Vector2(8, 40), "Semestre %s · clic para ver ficha" % node.get("semester", 0), HORIZONTAL_ALIGNMENT_LEFT, 284, 11, secondary)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var previous := hovered
		hovered = _node_at(event.position)
		if previous != hovered:
			queue_redraw()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var index := _node_at(event.position)
		if index > 0:
			selected = index
			subject_selected.emit(str(nodes[index].get("sigla", "")), nodes[index].duplicate(true))
			queue_redraw()


func _node_at(point: Vector2) -> int:
	for index in range(1, nodes.size()):
		var rect := Rect2(Vector2(nodes[index]["pos"]) - NODE_SIZE * 0.5, NODE_SIZE)
		if rect.has_point(point):
			return index
	return -1
