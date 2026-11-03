extends RefCounted
const Land = preload("res://scripts/campus_landscape.gd")
const FONT = preload("res://assets/fonts/campus_pixel.fnt")
static var _lawns: Array[PackedVector2Array] = []
static var _roads: Array[PackedVector2Array] = []
static var _forest := PackedVector2Array()
static var _pond := PackedVector2Array()


static func prepare() -> void:
	if not _lawns.is_empty():
		return
	for shape in Land.LAWNS:
		_lawns.append(Land.polygon(shape))
	_roads = Land.routes()
	_forest = Land.polygon(Land.FOREST)
	_pond = Land.polygon(Land.POND)


static func draw(canvas: CanvasItem, view: Rect2, phase: float = 0) -> void:
	prepare()
	canvas.draw_rect(view, Color("#a89e80"))
	for shape in _lawns:
		if _bounds(shape).intersects(view):
			canvas.draw_colored_polygon(shape, Color("#6b8656"))
	if _bounds(_forest).intersects(view):
		canvas.draw_colored_polygon(_forest, Color("#3e654c"))
	for y in range(floori(view.position.y / 48) * 48, ceili(view.end.y), 48):
		for x in range(floori(view.position.x / 48) * 48, ceili(view.end.x), 48):
			var point := Vector2(x, y)
			var green := in_garden(point)
			canvas.draw_rect(Rect2(point + Vector2(posmod(x + y, 17), 8), Vector2(3, 2)), Color("#8d9e62") if green else Color("#c2b58d"))
	for shape in Land.PARKING:
		var points := Land.polygon(shape)
		if not _bounds(points).intersects(view):
			continue
		canvas.draw_colored_polygon(points, Color("#7a807e"))
		var area := _bounds(points)
		for y in range(int(area.position.y + 24), int(area.end.y - 20), 52):
			for x in range(int(area.position.x + 16), int(area.end.x - 16), 64):
				var p := Vector2(x, y)
				if Geometry2D.is_point_in_polygon(p, points) and view.grow(48).has_point(p):
					canvas.draw_rect(Rect2(p, Vector2(46, 2)), Color("#d5d3b9"))
					if posmod(x + y, 5) == 0:
						canvas.draw_rect(Rect2(p + Vector2(10, 7), Vector2(24, 34)), Color("#3e5b6b"))
	for path in _roads:
		if _bounds(path).grow(90).intersects(view):
			canvas.draw_polyline(path, Color("#c0b89b"), 134, false)
			canvas.draw_polyline(path, Color("#343b3c"), 112, false)
			canvas.draw_polyline(path, Color("#424747"), 90, false)
	if _bounds(_pond).grow(24).intersects(view):
		canvas.draw_colored_polygon(_pond, Color("#a7805e"))
		var inner := PackedVector2Array()
		var center := _bounds(_pond).get_center()
		for p in _pond:
			inner.append(center + (p - center) * 0.97)
		canvas.draw_colored_polygon(inner, Color("#437f98"))
		for y in range(floori(view.position.y / 24) * 24, ceili(view.end.y), 24):
			for x in range(floori(view.position.x / 48) * 48, ceili(view.end.x), 48):
				var p := Vector2(x, y)
				if Geometry2D.is_point_in_polygon(p, inner):
					canvas.draw_rect(Rect2(p + Vector2(int(phase * 3) % 5, 0), Vector2(14, 2)), Color("#78b2bc"))
		for offset in [Vector2(-110, 10), Vector2(130, -38)]:
			canvas.draw_rect(Rect2(center + offset, Vector2(90, 28)), Color("#ad8a62"))
	for item in Land.fountains():
		if view.grow(70).has_point(item["point"]):
			_fountain(canvas, item["point"], item["radius"], phase)
	var seats := Land.at(50.6, 35.5)
	if view.grow(170).has_point(seats):
		_seats(canvas, seats)
	var entrance := Land.at(55.2, 93.8)
	if view.grow(120).has_point(entrance):
		for index in range(-3, 4):
			canvas.draw_rect(Rect2(entrance + Vector2(index * 18, -7), Vector2(10, 50)), Color("#d8d1b4"))
		canvas.draw_string(FONT, entrance + Vector2(-50, -24), "INGRESO FNI", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#ede6ca"))


static func _bounds(points: PackedVector2Array) -> Rect2:
	var rect := Rect2(points[0], Vector2.ZERO)
	for point in points:
		rect = rect.expand(point)
	return rect


static func in_garden(point: Vector2) -> bool:
	prepare()
	if Geometry2D.is_point_in_polygon(point, _forest):
		return true
	for shape in _lawns:
		if Geometry2D.is_point_in_polygon(point, shape):
			return true
	return false


static func in_forest(point: Vector2) -> bool:
	prepare()
	return Geometry2D.is_point_in_polygon(point, _forest)


static func _fountain(canvas: CanvasItem, point: Vector2, radius: float, phase: float) -> void:
	var rings := [[radius + 7, Color("#737f79")], [radius, Color("#c4c6b2")], [radius - 7, Color("#437c91")], [radius - 12, Color("#629fac")]]
	for ring in rings:
		var points := PackedVector2Array()
		for index in range(20):
			var angle := index * TAU / 20
			points.append((point + Vector2(cos(angle), sin(angle) * 0.65) * float(ring[0])).snapped(Vector2(2, 2)))
		canvas.draw_colored_polygon(points, ring[1])
	canvas.draw_rect(Rect2(point - Vector2(5, 21), Vector2(10, 24)), Color("#bdc6b8"))
	for offset in [-12, 0, 12]:
		var rise := 19 + posmod(int(phase * 8) + offset, 5)
		canvas.draw_line(point + Vector2(offset, -3), point + Vector2(offset * 0.3, -rise), Color("#b1e2dc"), 2, false)


static func _seats(canvas: CanvasItem, point: Vector2) -> void:
	var letters := ["11111000100011110000100010001000", "10001110011010110011100011000100", "11100010000100001000010011100000"]
	# Geometric seating blocks arranged as F N I, rather than painted lettering.
	var masks := [[31, 16, 16, 30, 16, 16, 16], [17, 25, 21, 19, 17, 17, 17], [14, 4, 4, 4, 4, 4, 14]]
	for letter in range(letters.size()):
		for row in range(7):
			for col in range(5):
				if masks[letter][row] & (1 << (4 - col)):
					var p := point + Vector2(letter * 50 + col * 8, row * 8)
					canvas.draw_rect(Rect2(p + Vector2(2, 3), Vector2(8, 7)), Color("#536f6c"))
					canvas.draw_rect(Rect2(p, Vector2(8, 6)), Color("#c1d0c4"))
