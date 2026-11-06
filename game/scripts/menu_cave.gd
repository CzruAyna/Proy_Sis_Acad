extends RefCounted
## Original procedural cave and bounded terminal stream. No OS/filesystem access.
const FONT = preload("res://assets/fonts/campus_pixel.fnt")
const MAX_LINES := 48
const MAX_DEBRIS := 36
const PRINT_RATE := 170.0
const FOLDERS := ["sistemas", "informatica", "campus", "modelos", "software", "redes", "datos", "laboratorios", "proyectos", "recursos", "simulaciones", "algoritmos", "documentos", "build", "tests", "assets"]
const FILES := ["config", "modelo", "nodo", "grafo", "kernel", "enlace", "matriz", "render", "evento", "modulo", "estado", "proceso"]
static var _frames: Dictionary = {}
static var geometry_builds := 0


static func noise(x: int, y: int, seed: int = 19) -> float:
	var value := posmod(x * 374761393 + y * 668265263 + seed * 1442695041, 2147483647)
	value = posmod((value ^ (value >> 13)) * 1274126177, 2147483647)
	return float(value ^ (value >> 16)) / 2147483647.0


static func erosion(phase: float) -> float:
	return clampf(floorf(maxf(0, phase - 12) / 8) / 10, 0, 1)


static func frame(box: Rect2, chunk: int, depth: int, phase: float) -> Dictionary:
	var amount := erosion(phase) if phase >= 0 else 0.0
	var key := "%s/%d/%d/%d" % [box, chunk, depth, roundi(amount * 10)]
	if not _frames.has(key):
		if _frames.size() >= 16:
			_frames.erase(_frames.keys()[0])
		_frames[key] = _build_frame(box, chunk, depth, amount)
	var cached: Dictionary = _frames[key]
	var debris: Array[Rect2] = []
	var age := phase - (12 + roundi(amount * 10) * 8)
	if amount > 0 and age >= 0 and age < 3.5:
		for chip in cached["chips"]:
			var p: Vector2 = chip["point"]
			var displacement := (p - box.get_center()).normalized() * age * 18 + Vector2(sin(age * 2 + int(chip["column"])) * 5, age * age * 5)
			var extent := Vector2.ONE * (8 if age < 1.5 else 4)
			debris.append(Rect2((p + displacement - extent * 0.5).snapped(Vector2(4, 4)), extent))
	return {"cells": cached["cells"], "debris": debris, "spans": cached["spans"], "bounds": cached["bounds"], "step": cached["step"]}


static func _build_frame(box: Rect2, chunk: int, depth: int, amount: float) -> Dictionary:
	geometry_builds += 1
	var step := maxf(8, chunk * 0.5)
	var bounds := box.grow(depth)
	var columns := ceili(bounds.size.x / step)
	var rows := ceili(bounds.size.y / step)
	var core := box.grow(-minf(40, box.size.x * 0.18))
	var cells: Array[Rect2] = []
	var chips: Array[Dictionary] = []
	var spans: Array = []
	var seed := int(box.size.x * 3 + box.size.y)
	for row in range(rows):
		var runs: Array[Vector2] = []
		var start := -INF
		for column in range(columns):
			var rect := Rect2(bounds.position + Vector2(column, row) * step, Vector2(minf(step, bounds.size.x - column * step), minf(step, bounds.size.y - row * step)))
			var p := rect.get_center()
			var left := bounds.position.x + noise(row / 2, 1, seed) * chunk * 1.65
			var right := bounds.end.x - noise(row / 2, 8, seed) * chunk * 1.5
			var top := bounds.position.y + noise(column / 2, 4, seed) * chunk * 1.7
			var bottom := bounds.end.y - noise(column / 2, 9, seed) * chunk * 1.6
			var solid := core.has_point(p) or (p.x >= left and p.x < right and p.y >= top and p.y < bottom)
			# Edge-first erosion with independently seeded cracks inside the mass.
			var edge_distance := minf(minf(p.x - bounds.position.x, bounds.end.x - p.x) / (bounds.size.x * 0.5), minf(p.y - bounds.position.y, bounds.end.y - p.y) / (bounds.size.y * 0.5))
			var resistance := clampf(0.04 + edge_distance * 0.53 + noise(column, row, seed + 31) * 0.42, 0.01, 0.99)
			var broken := solid and amount >= resistance
			if broken and chips.size() < MAX_DEBRIS and ceili(resistance * 10) == roundi(amount * 10) and noise(column, row, seed + 71) < 0.22:
				chips.append({"point": p, "column": column})
			if solid and not broken:
				cells.append(rect)
				if start == -INF:
					start = rect.position.x
			elif start != -INF:
				runs.append(Vector2(start, rect.position.x))
				start = -INF
		if start != -INF:
			runs.append(Vector2(start, bounds.end.x))
		spans.append(runs)
	return {"cells": cells, "chips": chips, "spans": spans, "bounds": bounds, "step": step}


static func stream_frame(height: float, phase: float) -> Dictionary:
	var local := fposmod(maxf(0, phase), 24)
	var linux := posmod(int(maxf(0, phase) / 24), 2) == 0
	var command := "sis-inf@campus:~$ tree -a /campus" if linux else "C:\\SIS-INF> tree /F /A"
	var lines: Array[String] = []
	var limit := clampi(floori((height - 24) / 14), 1, MAX_LINES)
	var printed := maxi(0, int((local - 1.6) * PRINT_RATE))
	if local < 1.6:
		lines.append(command.left(int(local * 25)) + "_")
	else:
		for index in range(maxi(0, printed - limit), printed):
			lines.append(_tree_line(index, linux))
	return {"lines": lines, "printed": printed, "command": command, "linux": linux}


static func _tree_line(index: int, linux: bool) -> String:
	var level := posmod(index / 11, 5)
	var prefix := "│ " if linux else "| "
	var branch := ("└─" if index % 11 == 10 else "├─") if linux else ("\\--" if index % 11 == 10 else "+--")
	var folder: String = FOLDERS[posmod(index / 11 + index / 121, FOLDERS.size())]
	if index % 11 == 0:
		return prefix.repeat(level) + branch + folder + "/"
	var base: String = FILES[posmod(index * 7, FILES.size())]
	var extension: String = [".gd", ".json", ".cfg", ".txt", ".ts", ".html"][posmod(index / 3, 6)]
	return prefix.repeat(level + 1) + branch + "%s_%05d%s" % [base, index, extension]


static func draw(item: RID, box: Rect2, chunk: int, depth: int, phase: float, inset_top: float = 0) -> void:
	var geometry := frame(box, chunk, depth, phase)
	var bounds: Rect2 = geometry["bounds"]
	for row in range(geometry["spans"].size()):
		for span in geometry["spans"][row]:
			RenderingServer.canvas_item_add_rect(item, Rect2(span.x, bounds.position.y + row * float(geometry["step"]), span.y - span.x, minf(geometry["step"], bounds.size.y - row * float(geometry["step"]))), Color.BLACK)
	for rect in geometry["debris"]:
		RenderingServer.canvas_item_add_rect(item, rect, Color.BLACK)
	if phase < 0:
		return
	var stream := stream_frame(box.size.y - inset_top, phase)
	for index in range(stream["lines"].size()):
		var baseline := box.position.y + inset_top + 18 + index * 14
		var row := floori((baseline - 5 - Rect2(geometry["bounds"]).position.y) / float(geometry["step"]))
		if row < 0 or row >= geometry["spans"].size():
			continue
		var span := Vector2.ZERO
		for run in geometry["spans"][row]:
			var clipped := Vector2(maxf(run.x, box.position.x + 14), minf(run.y, box.end.x - 14))
			if clipped.y - clipped.x > span.y - span.x:
				span = clipped
		if span.y - span.x < 24:
			continue
		FONT.draw_string(item, Vector2(span.x, baseline), stream["lines"][index], HORIZONTAL_ALIGNMENT_LEFT, span.y - span.x, 12, Color(0.14, 1, 0.32, 0.45))
