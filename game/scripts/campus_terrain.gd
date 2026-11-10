extends RefCounted
const Land = preload("res://scripts/campus_landscape.gd")
const Geo = preload("res://scripts/campus_cartography.gd")
const Roads = preload("res://scripts/campus_roads.gd")
const Perimeter = preload("res://scripts/campus_perimeter.gd")
const FONT = preload("res://assets/fonts/campus_pixel.fnt")
const GRASS_ACCENTS := [
	[Vector2(3752, 3496), Vector2(3970, 3516), Vector2(3948, 3618), Vector2(3778, 3618)],
	[Vector2(3428, 3410), Vector2(3548, 3372), Vector2(3583, 3430), Vector2(3528, 3497), Vector2(3432, 3480)],
	[Vector2(4027, 1576), Vector2(4087, 1632), Vector2(4080, 1804), Vector2(4044, 1752)],
	[Vector2(3018, 1160), Vector2(3099, 1157), Vector2(3130, 1280), Vector2(3064, 1294)]
]
const TILE := 128
static var _lawns: Array[PackedVector2Array] = []
static var _lawn_bounds: Array[Rect2] = []
static var _parking: Array[PackedVector2Array] = []
static var _forest := PackedVector2Array()
static var _pond := PackedVector2Array()
static var _details: Dictionary = {}


static func prepare() -> void:
	if not _lawns.is_empty():
		return
	_lawns = Geo.shapes("gardens")
	for patch in GRASS_ACCENTS:
		_lawns.append(PackedVector2Array(patch))
	for shape in _lawns:
		_lawn_bounds.append(_bounds(shape))
	_parking = Geo.shapes("parking")
	_forest = Land.polygon(Land.FOREST)
	_pond = Land.polygon(Land.POND)


static func draw(canvas: CanvasItem, view: Rect2, phase: float = 0, detail: bool = true, map_grain: bool = false) -> void:
	prepare()
	canvas.draw_rect(view, Color("#ad9b7c"))
	for index in range(_lawns.size()):
		if _lawn_bounds[index].intersects(view):
			canvas.draw_colored_polygon(_lawns[index], Color("#708d53").lerp(Color("#557443"), float(index % 5) * 0.15))
	if _bounds(_forest).intersects(view):
		canvas.draw_colored_polygon(_forest, Color("#3e654c"))
	if detail:
		_draw_details(canvas, view, phase)
	elif map_grain:
		for y in range(floori(view.position.y / 38) * 38, ceili(view.end.y), 38):
			for x in range(floori(view.position.x / 38) * 38, ceili(view.end.x), 38):
				var seed := posmod(x * 7 + y * 11, 25)
				var point := Vector2(x + seed, y + seed % 13)
				if in_garden(point):
					canvas.draw_rect(Rect2(point, Vector2(7, 3)), Color("#a0b46f"))
	for points in _parking:
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
	Roads.draw(canvas, view, detail)
	Perimeter.draw_road(canvas, view, detail)
	if _bounds(_pond).grow(24).intersects(view):
		canvas.draw_colored_polygon(_pond, Color("#a7805e"))
		var inner := PackedVector2Array()
		var center := _bounds(_pond).get_center()
		for p in _pond:
			inner.append(center + (p - center) * 0.97)
		canvas.draw_colored_polygon(inner, Color("#437f98"))
		for y in range(floori(view.position.y / 24) * 24, ceili(view.end.y) if detail else 0, 24):
			for x in range(floori(view.position.x / 48) * 48, ceili(view.end.x), 48):
				var p := Vector2(x, y)
				if Geometry2D.is_point_in_polygon(p, inner):
					canvas.draw_rect(Rect2(p + Vector2(int(phase * 3) % 5, 0), Vector2(14, 2)), Color("#78b2bc"))
		for offset in [Vector2(-110, 10), Vector2(130, -38)]:
			canvas.draw_rect(Rect2(center + offset, Vector2(90, 28)), Color("#ad8a62"))
	for item in Land.fountains():
		if view.grow(70).has_point(item["point"]):
			_fountain(canvas, item["point"], item["radius"], phase)
	var seats := Land.FNI_SEATS
	if view.grow(170).has_point(seats):
		_seats(canvas, seats)
	var entrance := Geo.anchor("gate")
	if view.grow(120).has_point(entrance):
		for index in range(-3, 4):
			canvas.draw_rect(Rect2(entrance + Vector2(index * 8, -4), Vector2(4, 16)), Color("#d8d1b4"))
		canvas.draw_string(FONT, entrance + Vector2(-50, -24), "INGRESO FNI", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#ede6ca"))
	Perimeter.draw_boundary(canvas, view, detail)


static func _draw_details(canvas: CanvasItem, view: Rect2, phase: float) -> void:
	for y in range(floori(view.position.y / TILE), ceili(view.end.y / TILE)):
		for x in range(floori(view.position.x / TILE), ceili(view.end.x / TILE)):
			for item in _detail_tile(Vector2i(x, y)):
				var point := Vector2(item.x, item.y)
				if not view.grow(4).has_point(point):
					continue
				if item.z == 0:
					canvas.draw_rect(Rect2(point, Vector2(5, 2)), Color("#b3a17e"))
					canvas.draw_rect(Rect2(point + Vector2(1, 2), Vector2(3, 1)), Color("#958064"))
					continue
				var sway := roundf(sin(phase * 3.0 + (point.x + point.y) * 0.043))
				canvas.draw_rect(Rect2(point + Vector2(-3, 1), Vector2(7, 2)), Color("#49673d"))
				canvas.draw_line(point + Vector2(-2, 1), point + Vector2(-4 + sway, -3), Color("#91ab5e"), 1)
				canvas.draw_line(point, point + Vector2(sway, -6), Color("#afbd73"), 1)
				canvas.draw_line(point + Vector2(2, 1), point + Vector2(4 + sway, -2), Color("#75944d"), 1)
				if int(item.z) % 11 == 0:
					canvas.draw_rect(Rect2(point + Vector2(sway, -6), Vector2(2, 2)), Color("#e5c989"))


static func _detail_tile(cell: Vector2i) -> PackedVector3Array:
	if _details.has(cell):
		return _details[cell]
	if _details.size() >= 96:
		_details.erase(_details.keys()[0])
	var points := PackedVector3Array()
	var origin := cell * TILE
	for y in range(origin.y, origin.y + TILE, 13):
		for x in range(origin.x, origin.x + TILE, 13):
			var seed := posmod(x * 13 + y * 7, 53) + 1
			var point := Vector2(x + seed % 10, y + seed % 9)
			if in_garden(point):
				points.append(Vector3(point.x, point.y, seed))
			elif seed % 5 == 0:
				points.append(Vector3(point.x, point.y, 0))
	_details[cell] = points
	return points


static func lawn_near(point: Vector2) -> bool:
	for bounds in _lawn_bounds:
		if bounds.grow(120).has_point(point):
			return true
	return false


static func _bounds(points: PackedVector2Array) -> Rect2:
	var rect := Rect2(points[0], Vector2.ZERO)
	for point in points:
		rect = rect.expand(point)
	return rect


static func in_garden(point: Vector2) -> bool:
	prepare()
	if Geometry2D.is_point_in_polygon(point, _forest):
		return true
	for index in range(_lawns.size()):
		if _lawn_bounds[index].has_point(point) and Geometry2D.is_point_in_polygon(point, _lawns[index]):
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
