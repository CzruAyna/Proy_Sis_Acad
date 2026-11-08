extends RefCounted

const Geo = preload("res://scripts/campus_cartography.gd")
const Land = preload("res://scripts/campus_landscape.gd")
const FONT = preload("res://assets/fonts/campus_pixel.fnt")
const HALF_GATE := 47.0
const VEHICLE_OFFSETS := [3000, 3230, 1900, 3880, 4700, 5600, 6480]
static var _sections: Array[Dictionary] = []
static var _highway := PackedVector2Array()
static var _visible_highway: Array[PackedVector2Array] = []
static var _lane: Curve2D
static var _gate := Vector2.ZERO


static func prepare() -> void:
	if _lane != null:
		return
	_highway = Geo.shapes("public_road")[0]
	_visible_highway = Geometry2D.intersect_polyline_with_polygon(_highway, _map_outline())
	_lane = Curve2D.new()
	_lane.bake_interval = 16
	for point in _highway:
		_lane.add_point(point)
	var outline := Geo.shapes("perimeter")[0]
	var gate_x := Geo.anchor("gate").x
	for index in range(outline.size() - 1):
		var a := outline[index]
		var b := outline[index + 1]
		var wire := maxf(a.y, b.y) > 3300
		if wire and a.x < gate_x - HALF_GATE and b.x > gate_x + HALF_GATE:
			var left := a.lerp(b, (gate_x - HALF_GATE - a.x) / (b.x - a.x))
			var right := a.lerp(b, (gate_x + HALF_GATE - a.x) / (b.x - a.x))
			_gate = (left + right) * 0.5
			_add_section(a, left, true)
			_add_section(right, b, true)
		else:
			_add_section(a, b, wire)


static func _add_section(a: Vector2, b: Vector2, wire: bool) -> void:
	var clipped := Geometry2D.intersect_polyline_with_polygon(PackedVector2Array([a, b]), _map_outline())
	if clipped.is_empty():
		return
	a = clipped[0][0]
	b = clipped[0][-1]
	var half_width := 3.0 if wire else 7.0
	var side := a.direction_to(b).orthogonal() * half_width
	var shape := PackedVector2Array([a - side, b - side, b + side, a + side])
	_sections.append({"a": a, "b": b, "wire": wire, "polygon": shape, "bounds": Geo.bounds(shape)})


static func _map_outline() -> PackedVector2Array:
	return PackedVector2Array([Vector2.ZERO, Vector2(Land.SIZE.x, 0), Land.SIZE, Vector2(0, Land.SIZE.y)])


static func sections() -> Array[Dictionary]:
	prepare()
	return _sections


static func near_road(point: Vector2, reach: float) -> bool:
	prepare()
	for index in range(_highway.size() - 1):
		if point.distance_squared_to(Geometry2D.get_closest_point_to_segment(point, _highway[index], _highway[index + 1])) <= reach * reach:
			return true
	return false


static func draw_road(canvas: CanvasItem, view: Rect2, detail: bool) -> void:
	prepare()
	for road in _visible_highway:
		if not Geo.bounds(road).grow(46).intersects(view):
			continue
		canvas.draw_polyline(road, Color("#a0957e"), 78)
		canvas.draw_polyline(road, Color("#353d43"), 66)
		if not detail:
			continue
		for index in range(road.size() - 1):
			var a := road[index]
			var b := road[index + 1]
			if Geo.bounds(PackedVector2Array([a, b])).grow(46).intersects(view):
				canvas.draw_dashed_line(a, b, Color("#d3c395"), 2, 20, false)


static func draw_boundary(canvas: CanvasItem, view: Rect2, detail: bool) -> void:
	for item in sections():
		if not Rect2(item["bounds"]).grow(26).intersects(view):
			continue
		var a: Vector2 = item["a"]
		var b: Vector2 = item["b"]
		if not detail:
			canvas.draw_line(a, b, Color("#3b4542") if item["wire"] else Color("#55493e"), 14)
		elif item["wire"]:
			_draw_mesh(canvas, view, a, b)
		else:
			_draw_wall(canvas, view, a, b)
	if detail and view.grow(100).has_point(_gate):
		_draw_gate(canvas)


static func _draw_mesh(canvas: CanvasItem, view: Rect2, a: Vector2, b: Vector2) -> void:
	var height := Vector2(0, -13)
	canvas.draw_line(a, b, Color("#454d4c"), 5)
	canvas.draw_line(a + height, b + height, Color("#a8b3ab"), 3)
	var panels := maxi(1, ceili(a.distance_to(b) / 18))
	for index in range(panels + 1):
		var point := a.lerp(b, float(index) / panels)
		if not view.grow(22).has_point(point):
			continue
		var next := a.lerp(b, float(mini(index + 1, panels)) / panels)
		canvas.draw_line(point, next + height, Color("#7b8d86"), 1)
		canvas.draw_line(point + height, next, Color("#7b8d86"), 1)
		if index % 3 == 0:
			canvas.draw_rect(Rect2(point + Vector2(-2, -16), Vector2(4, 20)), Color("#414b49"))


static func _draw_wall(canvas: CanvasItem, view: Rect2, a: Vector2, b: Vector2) -> void:
	canvas.draw_line(a + Vector2(0, 4), b + Vector2(0, 4), Color("#685448"), 19)
	canvas.draw_line(a, b, Color("#a78b72"), 16)
	canvas.draw_line(a - Vector2(0, 6), b - Vector2(0, 6), Color("#c3a98b"), 4)
	var count := maxi(1, ceili(a.distance_to(b) / 24))
	var side := a.direction_to(b).orthogonal() * 7
	for index in range(1, count):
		var point := a.lerp(b, float(index) / count)
		if view.grow(18).has_point(point):
			canvas.draw_line(point - side, point + side, Color("#836b59"), 2)


static func _draw_gate(canvas: CanvasItem) -> void:
	var left := _gate - Vector2(HALF_GATE, 0)
	var right := _gate + Vector2(HALF_GATE, 0)
	for point in [left, right]:
		canvas.draw_rect(Rect2(point - Vector2(5, 24), Vector2(10, 28)), Color("#614b3e"))
		canvas.draw_rect(Rect2(point - Vector2(6, 25), Vector2(12, 5)), Color("#b89572"))
	var arch := PackedVector2Array([left - Vector2(0, 22), _gate - Vector2(31, 34), _gate - Vector2(0, 39), _gate + Vector2(31, -34), right - Vector2(0, 22)])
	canvas.draw_polyline(arch, Color("#293736"), 4)
	canvas.draw_string(FONT, _gate + Vector2(-10, -29), "FNI", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#f4e2af"))
	var cabin := Rect2(right + Vector2(9, -31), Vector2(28, 23))
	canvas.draw_rect(cabin, Color("#875e49"))
	canvas.draw_rect(Rect2(cabin.position - Vector2(2, 3), Vector2(32, 10)), Color("#ad775e"))
	canvas.draw_rect(Rect2(cabin.position + Vector2(5, 10), Vector2(15, 6)), Color("#466568"))


static func draw_traffic(canvas: CanvasItem, view: Rect2, phase: float) -> void:
	prepare()
	var length := _lane.get_baked_length()
	for index in range(VEHICLE_OFFSETS.size()):
		var truck := index % 3 == 0
		var distance := fposmod(VEHICLE_OFFSETS[index] + phase * (115 if truck else 145), length)
		var point := _lane.sample_baked(distance)
		if not view.grow(75).has_point(point):
			continue
		var tangent := _lane.sample_baked(maxf(distance - 10, 0)).direction_to(_lane.sample_baked(minf(distance + 10, length)))
		point += tangent.orthogonal() * (-14 if index % 2 == 0 else 14)
		_draw_vehicle(canvas, point, tangent.angle(), truck, index)


static func _draw_vehicle(canvas: CanvasItem, center: Vector2, angle: float, truck: bool, index: int) -> void:
	var width := 64 if truck else 38
	var height := 17 if truck else 14
	var rect := Rect2(-width * 0.5, -height * 0.5, width, height)
	var colors := [Color("#ce8650"), Color("#daeee6"), Color("#71adbc"), Color("#caa95f")]
	var transform := Transform2D(angle, center.round())
	_vehicle_rect(canvas, transform, rect.grow(2), Color("#252c31"))
	_vehicle_rect(canvas, transform, rect, colors[index % colors.size()])
	_vehicle_rect(canvas, transform, Rect2(rect.end.x - 10, rect.position.y + 2, 4, height - 4), Color("#36545c"))
	_vehicle_rect(canvas, transform, Rect2(rect.end.x - 2, rect.position.y + 1, 2, 4), Color("#fff0bb"))
	_vehicle_rect(canvas, transform, Rect2(rect.position.x, rect.end.y - 4, 2, 3), Color("#ff856c"))
	if truck:
		_vehicle_rect(canvas, transform, Rect2(rect.position + Vector2(2, 2), Vector2(40, height - 4)), Color("#d3c7ad"))
	else:
		_vehicle_rect(canvas, transform, Rect2(rect.position + Vector2(5, 1), Vector2(17, 3)), Color("#537b83"))


static func _vehicle_rect(canvas: CanvasItem, transform: Transform2D, box: Rect2, color: Color) -> void:
	canvas.draw_colored_polygon(PackedVector2Array([transform * box.position, transform * Vector2(box.end.x, box.position.y), transform * box.end, transform * Vector2(box.position.x, box.end.y)]), color)
