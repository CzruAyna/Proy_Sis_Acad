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


static func draw(canvas: CanvasItem, view: Rect2) -> void:
	if _entries.is_empty():
		for path in walkways():
			_entries.append({"path": path, "area": Geo.bounds(path).grow(12), "width": WALK_WIDTH, "fill": Color("#857d6b")})
		for path in paths():
			_entries.append({"path": path, "area": Geo.bounds(path).grow(30), "width": ROAD_WIDTH, "fill": SURFACE})
	# Paint shoulders first, then surfaces. Asphalt covers joined footpaths.
	for shoulder in [true, false]:
		for entry in _entries:
			if not Rect2(entry["area"]).intersects(view):
				continue
			var path: PackedVector2Array = entry["path"]
			var width: float = entry["width"] + (8 if shoulder else 0)
			var color := Color("#c0b296") if shoulder else Color(entry["fill"])
			canvas.draw_polyline(path, color, width, false)
			for endpoint in [path[0], path[-1]]:
				canvas.draw_circle(endpoint, width / 2, color, true, -1, false)
