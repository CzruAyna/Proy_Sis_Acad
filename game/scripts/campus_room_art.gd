extends RefCounted
const FONT = preload("res://assets/fonts/campus_pixel.fnt")


static func draw(canvas: CanvasItem, layout: Dictionary, room: String) -> void:
	var extent: Vector2 = layout["size"]
	var kind: String = layout["kind"]
	var brick: bool = kind == "classroom" or layout["id"] in ["fis_mat", "basicas"]
	var floor_color := Color("#b4aa90") if brick else Color("#9bafa9")
	canvas.draw_rect(Rect2(Vector2.ZERO, extent), Color("#202b30"))
	var floor_area := Rect2(16, 24, extent.x - 32, extent.y - 36)
	canvas.draw_rect(floor_area, floor_color)
	for y in range(32, int(extent.y - 12), 24):
		for x in range(24, int(extent.x - 16), 24):
			canvas.draw_rect(Rect2(x, y, 23, 23).intersection(floor_area), floor_color.lightened(0.055) if (x + y) % 48 == 0 else floor_color.darkened(0.025))
	var wall := Color("#9f7057") if brick else Color("#c1c6b4")
	var wall_area := Rect2(16, 16, extent.x - 32, 24)
	canvas.draw_rect(wall_area, wall)
	if brick:
		for row in range(3):
			for x in range(18 + row % 2 * 12, int(extent.x - 24), 24):
				canvas.draw_rect(Rect2(x, 18 + row * 7, 21, 5).intersection(wall_area), wall.lightened(0.1))
	# Tall windows and ochre curtains observed in the RTvU classroom photograph.
	for side in [24.0, extent.x - 36]:
		for y in range(70, int(extent.y - 94), 72):
			canvas.draw_rect(Rect2(side, y, 12, 46), Color("#4f7680"))
			canvas.draw_rect(Rect2(side + 2, y + 2, 8, 20), Color("#95bdba"))
			canvas.draw_rect(Rect2(side + 2, y + 25, 8, 18), Color("#79a7ac"))
			if brick:
				canvas.draw_rect(Rect2(side - 3, y - 2, 4, 50), Color("#b18b5d"))
				canvas.draw_rect(Rect2(side + 11, y - 2, 4, 50), Color("#8c6849"))
	var board := Rect2(extent.x / 2 - 100, 30, 200, 30)
	canvas.draw_rect(board.grow(3), Color("#867a5b"))
	canvas.draw_rect(board, Color("#31594e"))
	var formula := room
	if kind == "physics_lab":
		formula = "F = ma   V = IR   E = mc2"
	elif kind == "chemistry_lab":
		formula = "pH = -log[H+]   H2O"
	elif kind in ["computer_lab", "physics_virtual"]:
		formula = "SIMULACIÓN · FÍSICA" if kind == "physics_virtual" else "algoritmo → código → prueba"
	elif kind == "classroom":
		formula = "f(x) = ax + b   ∑   ∫"
	canvas.draw_string(FONT, board.position + Vector2(8, 20), formula, HORIZONTAL_ALIGNMENT_LEFT, 188, 9, Color("#b6e1c6"))
	for x in [extent.x * 0.28, extent.x * 0.72]:
		canvas.draw_rect(Rect2(x - 20, 68, 40, 4), Color("#eff0cc"))
	for item in layout["items"]:
		_furniture(canvas, item, kind, str(layout["id"]))
	if kind in ["computer_lab", "physics_virtual", "classroom"]:
		canvas.draw_rect(Rect2(extent.x / 2 - 10, 78, 20, 8), Color("#d8dfd1"))
		canvas.draw_rect(Rect2(extent.x / 2 + 4, 80, 4, 3), Color("#4b6472"))
	# Illustrative safety detail, not a confirmed real extinguisher location.
	canvas.draw_rect(Rect2(extent.x - 36, extent.y - 62, 7, 16), Color("#b7554d"))
	canvas.draw_rect(Rect2(extent.x - 35, extent.y - 65, 5, 4), Color("#424c4f"))


static func _furniture(canvas: CanvasItem, item: Dictionary, room_kind: String, id: String) -> void:
	var rect: Rect2 = item["rect"]
	var p := rect.position
	var kind: String = item["kind"]
	canvas.draw_rect(rect, Color("#706e61"))
	if kind in ["books", "rack", "cabinet"]:
		canvas.draw_rect(rect.grow(-2), Color("#4a5a5a") if kind == "rack" else Color("#967957"))
		for y in range(int(p.y + 6), int(rect.end.y - 4), 12):
			canvas.draw_rect(Rect2(p.x + 3, y + 6, rect.size.x - 6, 2), Color("#bbac84"))
			for x in range(int(p.x + 5), int(rect.end.x - 4), 7):
				canvas.draw_rect(Rect2(x, y, 4, 6), [Color("#789594"), Color("#bc9e6b"), Color("#9b6b65")][posmod(x + y, 3)])
		return
	var top := Rect2(p + Vector2(2, 2), Vector2(rect.size.x - 4, rect.size.y - 14))
	canvas.draw_rect(top, Color("#b8986c") if kind != "experiment" else Color("#a9b9ac"))
	canvas.draw_rect(Rect2(p.x + 4, p.y + 3, rect.size.x - 8, 2), Color("#dfc494"))
	# Seats fit inside the same collision rectangle as the table.
	for x in range(int(p.x + 8), int(rect.end.x - 24), 42):
		canvas.draw_rect(Rect2(x, rect.end.y - 10, 24, 8), Color("#5d7980"))
		canvas.draw_rect(Rect2(x + 2, rect.end.y - 8, 20, 3), Color("#c09a69"))
	if kind == "computer":
		canvas.draw_rect(Rect2(p + Vector2(13, 2), Vector2(22, 14)), Color("#253c4b"))
		canvas.draw_rect(Rect2(p + Vector2(15, 4), Vector2(18, 9)), Color("#6eacae"))
		canvas.draw_rect(Rect2(p + Vector2(12, 18), Vector2(24, 4)), Color("#d1d5c5"))
	elif kind in ["desk", "counter"]:
		canvas.draw_rect(Rect2(p + Vector2(9, 6), Vector2(16, 10)), Color("#e8dec0"))
		canvas.draw_line(p + Vector2(12, 8), p + Vector2(20, 12), Color("#657778"), 1, false)
	elif kind == "hood":
		canvas.draw_rect(Rect2(p + Vector2(5, 3), Vector2(rect.size.x - 10, 21)), Color("#395b63"))
		canvas.draw_rect(Rect2(p + Vector2(8, 4), Vector2(rect.size.x - 16, 3)), Color("#c6d7ca"))
		canvas.draw_rect(Rect2(p + Vector2(18, 11), Vector2(9, 10)), Color("#8abda6"))
	elif kind == "bed":
		canvas.draw_rect(rect.grow(-3), Color("#d9ded0"))
		canvas.draw_rect(Rect2(p + Vector2(7, 6), Vector2(24, rect.size.y - 12)), Color("#f2eedb"))
		canvas.draw_rect(Rect2(p + Vector2(38, 6), Vector2(rect.size.x - 46, rect.size.y - 12)), Color("#85a9ac"))
	elif kind == "experiment":
		if room_kind == "chemistry_lab":
			for x in [16, 52, 96]:
				canvas.draw_rect(Rect2(p + Vector2(x, 6), Vector2(12, 16)), Color("#a9d0c7"))
				canvas.draw_rect(Rect2(p + Vector2(x + 3, 16), Vector2(6, 5)), Color("#a385ad"))
		elif room_kind == "physics_lab":
			canvas.draw_rect(Rect2(p + Vector2(18, 4), Vector2(2, 22)), Color("#e0ddbf"))
			canvas.draw_rect(Rect2(p + Vector2(18, 4), Vector2(28, 2)), Color("#e0ddbf"))
			canvas.draw_line(p + Vector2(42, 6), p + Vector2(37, 21), Color("#436778"), 1, false)
			canvas.draw_rect(Rect2(p + Vector2(34, 20), Vector2(8, 5)), Color("#537a91"))
			canvas.draw_rect(Rect2(p + Vector2(86, 5), Vector2(28, 18)), Color("#344e5b"))
			canvas.draw_rect(Rect2(p + Vector2(90, 8), Vector2(19, 8)), Color("#93b08c"))
		else:
			var color := Color("#b98152") if id.begins_with("metal") else Color("#709797")
			canvas.draw_rect(Rect2(p + Vector2(15, 5), Vector2(28, 20)), color)
			canvas.draw_rect(Rect2(p + Vector2(68, 8), Vector2(48, 12)), Color("#435862"))
			canvas.draw_rect(Rect2(p + Vector2(80, 11), Vector2(12, 6)), Color("#c7d1a2"))
