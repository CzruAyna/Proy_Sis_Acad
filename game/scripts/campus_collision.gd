extends RefCounted
## Shared broad phase. Exact polygon/foot-radius checks remain authoritative.
const Map = preload("res://scripts/campus_map.gd")
const Land = preload("res://scripts/campus_landscape.gd")
const CELL := 512.0
static var _buckets: Dictionary = {}
static var _items: Array[Dictionary] = []
static var queries := 0
static var candidates := 0


static func prepare() -> void:
	if not _items.is_empty():
		return
	for block in Map.buildings():
		_add({"bounds": block["rect"], "polygon": block["footprint"], "water": false})
	for rect in Land.obstacles():
		_add({"bounds": rect, "polygon": PackedVector2Array(), "water": false})
	var pond := Land.polygon(Land.POND)
	var bounds := Rect2(pond[0], Vector2.ZERO)
	for point in pond:
		bounds = bounds.expand(point)
	_add({"bounds": bounds, "polygon": pond, "water": true})


static func _add(item: Dictionary) -> void:
	var id := _items.size()
	_items.append(item)
	var box: Rect2 = item["bounds"]
	for y in range(floori(box.position.y / CELL), floori(box.end.y / CELL) + 1):
		for x in range(floori(box.position.x / CELL), floori(box.end.x / CELL) + 1):
			var key := Vector2i(x, y)
			if not _buckets.has(key):
				_buckets[key] = []
			_buckets[key].append(id)


static func can_stand(point: Vector2, radius: float = 12) -> bool:
	if not point.is_finite() or not is_finite(radius) or radius < 0 or not Rect2(Vector2.ONE * 16, Map.SIZE - Vector2.ONE * 32).has_point(point):
		return false
	prepare()
	queries += 1
	var seen := {}
	for y in range(floori((point.y - radius) / CELL), floori((point.y + radius) / CELL) + 1):
		for x in range(floori((point.x - radius) / CELL), floori((point.x + radius) / CELL) + 1):
			for id in _buckets.get(Vector2i(x, y), []):
				if seen.has(id):
					continue
				seen[id] = true
				candidates += 1
				var item: Dictionary = _items[id]
				if not Rect2(item["bounds"]).grow(radius).has_point(point):
					continue
				var polygon: PackedVector2Array = item["polygon"]
				if polygon.is_empty() or Geometry2D.is_point_in_polygon(point, polygon):
					return false
				for i in range(polygon.size()):
					var distance := point.distance_squared_to(Geometry2D.get_closest_point_to_segment(point, polygon[i], polygon[(i + 1) % polygon.size()]))
					if distance < radius * radius or (not item["water"] and distance == radius * radius):
						return false
	return true
