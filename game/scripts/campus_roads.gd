extends RefCounted
## Opaque layers cover the entire network before the next layer is painted.
## This makes intersections continuous: no curb is drawn across another road.
const Land = preload("res://scripts/campus_landscape.gd")
const SURFACE := Color("#424747")
static var _paths: Array[PackedVector2Array] = []


static func paths() -> Array[PackedVector2Array]:
	if _paths.is_empty():
		for raw in Land.routes():
			_paths.append(_round_corners(raw))
	return _paths


static func _round_corners(raw: PackedVector2Array) -> PackedVector2Array:
	var result := PackedVector2Array([raw[0]])
	for index in range(1, raw.size() - 1):
		var corner := raw[index]
		var cut := minf(76, minf(corner.distance_to(raw[index - 1]), corner.distance_to(raw[index + 1])) * 0.24)
		var start := corner.move_toward(raw[index - 1], cut)
		var end := corner.move_toward(raw[index + 1], cut)
		for step in range(9):
			var t := step / 8.0
			result.append((start.lerp(corner, t).lerp(corner.lerp(end, t), t)).snapped(Vector2(2, 2)))
	result.append(raw[-1])
	return result


static func draw(canvas: CanvasItem, view: Rect2) -> void:
	# All sidewalks first, all asphalt second. Never finish one road at a time.
	for layer in [[134.0, Color("#beb398")], [112.0, Color("#343b3c")], [96.0, SURFACE]]:
		var radius: float = layer[0] * 0.5
		for path in paths():
			var area := Rect2(path[0], Vector2.ZERO)
			for point in path:
				area = area.expand(point)
			if not area.grow(radius).intersects(view):
				continue
			canvas.draw_polyline(path, layer[1], layer[0], false)
			# Round exposed endpoints and cover branch joins, with coarse pixel edges.
			for endpoint in [path[0], path[-1]]:
				var cap := PackedVector2Array()
				for index in range(16):
					cap.append((endpoint + Vector2.from_angle(index * TAU / 16) * radius).snapped(Vector2(2, 2)))
				canvas.draw_colored_polygon(cap, layer[1])
