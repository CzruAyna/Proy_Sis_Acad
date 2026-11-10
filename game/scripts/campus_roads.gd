extends RefCounted
## Opaque layers cover the entire network before the next layer is painted.
## This makes intersections continuous: no curb is drawn across another road.
const Land = preload("res://scripts/campus_landscape.gd")
const Geo = preload("res://scripts/campus_cartography.gd")
const SURFACE := Color("#424747")
const ROAD_WIDTH := 48.0
const WALK_WIDTH := 14.0
static var _paths: Array[PackedVector2Array] = []
static var _walkways: Array[PackedVector2Array] = []
static var _entries: Array[Dictionary] = []


static func paths() -> Array[PackedVector2Array]:
	if _paths.is_empty():
		for raw in Land.routes():
			_paths.append(_round_corners(raw))
	return _paths


static func walkways() -> Array[PackedVector2Array]:
	if _walkways.is_empty():
		_walkways = Geo.shapes("walkways")
	return _walkways


static func _round_corners(raw: PackedVector2Array) -> PackedVector2Array:
	var result := PackedVector2Array([raw[0]])
	for index in range(1, raw.size() - 1):
		var corner := raw[index]
		var cut := minf(24, minf(corner.distance_to(raw[index - 1]), corner.distance_to(raw[index + 1])) * 0.24)
		var start := corner.move_toward(raw[index - 1], cut)
		var end := corner.move_toward(raw[index + 1], cut)
		for step in range(9):
			var t := step / 8.0
			var point := start.lerp(corner, t).lerp(corner.lerp(end, t), t).round()
			if point != result[-1]:
				result.append(point)
	if raw[-1] != result[-1]:
		result.append(raw[-1])
	return result


static func draw(canvas: CanvasItem, view: Rect2, detail: bool = true) -> void:
	if _entries.is_empty():
		for path in walkways():
			_entries.append({"path": path, "area": Geo.bounds(path).grow(12), "width": WALK_WIDTH, "fill": Color("#857d6b")})
		for path in paths():
			_entries.append({"path": path, "area": Geo.bounds(path).grow(30), "width": ROAD_WIDTH, "fill": SURFACE})
	# Cover the whole network in each pass so bevels never stripe the junctions.
	for layer in range(3):
		for entry in _entries:
			if not Rect2(entry["area"]).intersects(view):
				continue
			var path: PackedVector2Array = entry["path"]
			var width: float = entry["width"] + [8, 2, -3][layer]
			var color: Color = [Color("#c3b394"), Color(entry["fill"]).darkened(0.32), Color(entry["fill"])][layer]
			canvas.draw_polyline(path, color, width, false)
			for endpoint in [path[0], path[-1]]:
				canvas.draw_circle(endpoint, width / 2, color, true, -1, false)
	if not detail:
		return
	for entry in _entries:
		if not Rect2(entry["area"]).intersects(view):
			continue
		var path: PackedVector2Array = entry["path"]
		var paved: bool = entry["width"] == ROAD_WIDTH
		for index in range(path.size() - 1):
			var a := path[index]
			var b := path[index + 1]
			if not Geo.bounds(PackedVector2Array([a, b])).grow(8).intersects(view):
				continue
			var side := a.direction_to(b).orthogonal()
			var length := a.distance_to(b)
			var pitch := 19 if paved else 9
			for distance in range(pitch / 2, floori(length), pitch):
				var grain := a.lerp(b, float(distance) / length).round()
				if not view.has_point(grain):
					continue
				if paved:
					var spot := grain + side * (posmod(int(grain.x + grain.y), 21) - 10)
					canvas.draw_rect(Rect2(spot.round(), Vector2(3, 2)), Color("#58605d"))
				else:
					canvas.draw_line(grain - side * 4, grain + side * 4, Color("#686252"), 1)
