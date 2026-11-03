extends RefCounted
## Original pixel geometry, inspired by the plan and reference photographs.
const Map = preload("res://scripts/campus_map.gd")
const FONT = preload("res://assets/fonts/campus_pixel.fnt")


static func building(canvas: CanvasItem, data: Dictionary, view: Rect2 = Rect2()) -> void:
	var rect: Rect2 = data["rect"]
	var id := str(data["id"])
	var points: PackedVector2Array = data["footprint"]
	var roof_colors := [Color("#9a5e49"), Color("#796653"), Color("#59747a"), Color("#8b7456")]
	var roof: Color = roof_colors[posmod(id.hash(), roof_colors.size())]
	if id.begins_with("sis_"):
		roof = Color("#4d6b7a")
	elif id in ["fis_mat", "basicas"]:
		roof = Color("#557f94")
	elif id.begins_with("quirquincho"):
		roof = Color("#99795b") if id.ends_with("quimica") else (Color("#668b96") if id.ends_with("fisica") else Color("#82728c"))
	# Extruded silhouette, facade and roof all follow the same footprint.
	canvas.draw_colored_polygon(_offset(points, Vector2(7, 18)), Color("#425447"))
	canvas.draw_colored_polygon(_offset(points, Vector2(0, 12)), Color("#bb8662"))
	canvas.draw_colored_polygon(points, roof.darkened(0.25))
	var visible := rect if not view.has_area() else rect.intersection(view.grow(12))
	for y in range(maxi(int(rect.position.y + 4), floori(visible.position.y / 6) * 6), mini(int(rect.end.y - 2), ceili(visible.end.y)), 6):
		for x in range(maxi(int(rect.position.x + 4), floori(visible.position.x / 8) * 8), mini(int(rect.end.x - 2), ceili(visible.end.x)), 8):
			var point := Vector2(x, y)
			if Geometry2D.is_point_in_polygon(point, points):
				canvas.draw_rect(Rect2(point, Vector2(6, 3)), roof.lightened(0.08 if posmod(x + y, 3) else 0.18))
	# Edge highlights and glazing only belong to actual exterior segments.
	for index in range(points.size()):
		var a := points[index]
		var b := points[(index + 1) % points.size()]
		canvas.draw_line(a, b, roof.lightened(0.3), 2, false)
		if absf(a.y - b.y) < 1 and b.x < a.x:
			for x in range(int(b.x + 8), int(a.x - 8), 18):
				canvas.draw_rect(Rect2(x, a.y + 3, 11, 7), Color("#29444c"))
				canvas.draw_rect(Rect2(x + 4, a.y + 3, 2, 7), Color("#c8baa0"))
	var center := rect.get_center().snapped(Vector2(2, 2))
	if id in ["fis_mat", "basicas"]:
		var levels := Map.floor_count(id)
		for level in range(levels):
			for x in range(int(rect.position.x + 12), int(rect.end.x - 12), 36):
				var point := Vector2(x, rect.end.y + 2 + level * 2)
				if not view.has_area() or view.grow(16).has_point(point):
					canvas.draw_rect(Rect2(point, Vector2(22, 2)), Color("#d2ba6c") if level % 2 == 0 else Color("#88b4be"))
		for index in range(1, 4):
			var y := rect.position.y + rect.size.y * index / 4
			var a := Vector2(rect.position.x + 4, y)
			var b := Vector2(rect.end.x - 4, y)
			for x in range(int(a.x), int(b.x), 24):
				var p := Vector2(x, y)
				if Geometry2D.is_point_in_polygon(p, points) and (not view.has_area() or view.has_point(p)):
					canvas.draw_rect(Rect2(p, Vector2(16, 5)), Color("#d8c273"))
	elif id == "sis_a":
		# Staggered wings, network roof equipment, covered entry.
		canvas.draw_rect(Rect2(center - Vector2(10, 16), Vector2(20, 8)), Color("#bac5b9"))
		canvas.draw_line(center - Vector2(0, 8), center - Vector2(0, 26), Color("#c6d1c0"), 2)
	elif id == "sis_b":
		canvas.draw_rect(Rect2(rect.position + Vector2(8, 8), Vector2(20, rect.size.y - 16)), Color("#86a2a5"))
		for y in range(int(rect.position.y + 12), int(rect.end.y - 8), 10):
			canvas.draw_rect(Rect2(rect.position.x + 10, y, 16, 3), Color("#c3d3c9"))
	elif id == "sis_c":
		for y in range(int(rect.position.y + 10), int(rect.end.y - 6), 18):
			canvas.draw_rect(Rect2(rect.position.x + 9, y, rect.size.x - 18, 6), Color("#a2b1a9"))
	elif id == "sis_e":
		canvas.draw_rect(Rect2(center - Vector2(16, 8), Vector2(32, 16)), Color("#182e35"))
		canvas.draw_string(FONT, center + Vector2(-13, 4), "PLAY", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("#9fde98"))
	elif id == "coliseo":
		# Stepped barrel roof: a distinct volume rather than another classroom.
		for strip in range(6):
			var inset := absf(strip - 2.5) * 3
			canvas.draw_rect(Rect2(rect.position + Vector2(inset + 2, strip * rect.size.y / 6), Vector2(rect.size.x - inset * 2 - 4, rect.size.y / 6 - 1)), Color("#a6aaa0").darkened(absf(strip - 2.5) * 0.1))
	elif id == "decanato":
		canvas.draw_rect(Rect2(center - Vector2(14, 14), Vector2(28, 20)), Color("#cbb78d"))
		canvas.draw_rect(Rect2(center - Vector2(9, 10), Vector2(18, 12)), Color("#6d9197"))
	elif id.begins_with("quirquincho"):
		for rib in range(7):
			var line := PackedVector2Array()
			var x := rect.position.x + rect.size.x * (0.14 + rib * 0.12)
			for step in range(17):
				var t := step / 16.0
				line.append(Vector2(x + sin(t * PI) * (rib - 3) * 5, rect.position.y + rect.size.y * (0.15 + t * 0.7)).snapped(Vector2(2, 2)))
			canvas.draw_polyline(line, roof.lightened(0.28), 3, false)
		var symbol := "pH" if id.ends_with("quimica") else ("F=ma" if id.ends_with("fisica") else "x+y")
		canvas.draw_string(FONT, center - Vector2(18, 0), symbol, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#e9dfb9"))
	elif data["kind"] == "lab":
		# Industrial vents and skylights vary with the building's stable ID.
		for index in range(1 + posmod(id.hash(), 3)):
			var point := rect.position + Vector2(12 + index * 18, 12)
			if rect.grow(-6).has_point(point + Vector2(12, 12)):
				canvas.draw_rect(Rect2(point + Vector2(2, 3), Vector2(12, 9)), Color("#32434a"))
				canvas.draw_rect(Rect2(point, Vector2(12, 7)), Color("#a3bfc2"))


static func _offset(points: PackedVector2Array, displacement: Vector2) -> PackedVector2Array:
	var shifted := PackedVector2Array()
	for point in points:
		shifted.append(point + displacement)
	return shifted


static func tree(canvas: CanvasItem, point: Vector2) -> void:
	var variation := posmod(int(point.x * 3 + point.y * 7), 5)
	var tall := variation in [1, 3]
	canvas.draw_rect(Rect2(point + Vector2(-10, 5), Vector2(25, 8)), Color("#526b50"))
	canvas.draw_rect(Rect2(point + Vector2(-2, -6), Vector2(4, 18)), Color("#786048"))
	if variation == 3:
		# Cypress / conifer, narrow and tall.
		for row in range(6):
			var half := float(row + 2) * 2
			canvas.draw_rect(Rect2(point + Vector2(-half, -40 + row * 6), Vector2(half * 2, 7)), Color("#314e48").lightened(0.04 * (5 - row)))
	else:
		var height := 36 if tall else 24
		var width := 18 if tall else (30 if variation == 2 else 24)
		var base := Color("#4c7050") if variation != 4 else Color("#7e8752")
		for row in range(5):
			var inset := 4 if row in [0, 4] else (0 if row == 2 else 2)
			canvas.draw_rect(Rect2(point + Vector2(-width * 0.5 + inset, -height + row * height / 5), Vector2(width - inset * 2, height / 5 + 1)), base.darkened(float(row) * 0.045))
		canvas.draw_rect(Rect2(point + Vector2(-width * 0.5 + 5, -height + 5), Vector2(6, 7)), base.lightened(0.15))
		if variation == 4:
			canvas.draw_line(point + Vector2(0, -4), point + Vector2(-6, -15), Color("#75664f"), 2, false)


static func court_rect(row: Array) -> Rect2:
	return Rect2(Vector2(float(row[1]), float(row[2])) * Map.SIZE / 100, Vector2(float(row[3]), float(row[4])) * Map.SIZE / 100)


static func court(canvas: CanvasItem, row: Array) -> void:
	var rect := court_rect(row)
	var name := str(row[0])
	var field := rect.grow(-8)
	var ink := Color("#d6dac0")
	var football := name.begins_with("FÚTBOL")
	var tennis := name == "TENIS"
	var sand := name in ["FÚTBOL TIERRA", "VOLEIBOL"]
	canvas.draw_rect(rect.grow(4), Color("#777d68"))
	canvas.draw_rect(rect, Color("#b29a74") if sand else (Color("#658351") if football else Color("#586f72")))
	if football and not sand:
		for strip in range(8):
			canvas.draw_rect(Rect2(rect.position + Vector2(strip * rect.size.x / 8, 0), Vector2(rect.size.x / 16, rect.size.y)), Color("#6c8b57"))
	canvas.draw_rect(field, ink, false, 2)
	if tennis:
		# Two separate tennis courts, each with service boxes and a net.
		for index in range(2):
			var sub := Rect2(field.position + Vector2(index * field.size.x / 2 + 6, 4), Vector2(field.size.x / 2 - 12, field.size.y - 8))
			canvas.draw_rect(sub, ink, false, 1)
			canvas.draw_rect(Rect2(sub.position + sub.size * Vector2(0.15, 0.2), sub.size * Vector2(0.7, 0.6)), ink, false, 1)
			canvas.draw_line(Vector2(sub.position.x, sub.get_center().y), Vector2(sub.end.x, sub.get_center().y), Color("#233e48"), 3, false)
			canvas.draw_line(sub.get_center() - Vector2(0, sub.size.y * 0.25), sub.get_center() + Vector2(0, sub.size.y * 0.25), ink, 1, false)
	else:
		canvas.draw_line(Vector2(field.get_center().x, field.position.y), Vector2(field.get_center().x, field.end.y), ink, 2, false)
		if football:
			canvas.draw_arc(field.get_center(), minf(field.size.x, field.size.y) * 0.16, 0, TAU, 16, ink, 2, false)
			for side in [0, 1]:
				var x := field.position.x if side == 0 else field.end.x - field.size.x * 0.16
				canvas.draw_rect(Rect2(x, field.position.y + field.size.y * 0.25, field.size.x * 0.16, field.size.y * 0.5), ink, false, 2)
				var goal_x := rect.position.x - 4 if side == 0 else rect.end.x - 2
				canvas.draw_rect(Rect2(goal_x, rect.get_center().y - 12, 6, 24), Color("#e4dfca"), false, 2)
		elif name == "VOLEIBOL":
			canvas.draw_line(Vector2(field.get_center().x, rect.position.y - 3), Vector2(field.get_center().x, rect.end.y + 3), Color("#30454a"), 3, false)
		else:
			for x in [field.position.x + 4, field.end.x - 4]:
				canvas.draw_rect(Rect2(x - 2, field.get_center().y - 7, 4, 14), Color("#e5d8b8"))
				canvas.draw_arc(Vector2(x, field.get_center().y), 13, -PI / 2, PI / 2, 12, ink, 1, false)
	# Bleachers and fence posts. Roofed courts keep an open cutaway to see play.
	for x in range(int(rect.position.x), int(rect.end.x), 18):
		canvas.draw_rect(Rect2(x, rect.position.y - 6, 2, 5), Color("#455956"))
	for step in range(3):
		canvas.draw_rect(Rect2(rect.position.x + 8, rect.end.y + 7 + step * 4, rect.size.x - 16, 3), Color("#aaa18a").darkened(step * 0.1))
	if name in ["POLIF. QUÍMICA", "POLIF. MINAS", "POLIF. CIVIL"]:
		var ridge := PackedVector2Array([rect.position + Vector2(-6, 8), rect.position + Vector2(8, -10), Vector2(rect.get_center().x, rect.position.y - 16), Vector2(rect.end.x - 8, rect.position.y - 10), Vector2(rect.end.x + 6, rect.position.y + 8)])
		canvas.draw_polyline(ridge, Color("#b8bcae"), 5, false)
		for x in [rect.position.x - 4, rect.end.x + 4]:
			canvas.draw_rect(Rect2(x, rect.position.y + 6, 3, rect.size.y), Color("#536a72"))


static func plaza(canvas: CanvasItem) -> void:
	# The central paved walk and side planters echo the reference photographs.
	var paving := Rect2(1198, 760, 84, 616)
	canvas.draw_rect(paving, Color("#b7ad93"))
	for y in range(768, 1376, 12):
		for x in range(1200, 1280, 12):
			canvas.draw_rect(Rect2(x, y, 10, 10), Color("#c2b69a") if (x + y) % 24 == 0 else Color("#b6ac94"))
	for y in [884, 1016, 1184, 1320]:
		for x in [1182, 1292]:
			canvas.draw_rect(Rect2(x, y, 12, 4), Color("#7a624a"))
			canvas.draw_rect(Rect2(x + 1, y + 4, 2, 6), Color("#394d48"))
			canvas.draw_rect(Rect2(x + 9, y + 4, 2, 6), Color("#394d48"))
