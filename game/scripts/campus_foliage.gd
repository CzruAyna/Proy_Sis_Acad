extends RefCounted
## Immutable layout cached once; visible trees are queried through 128px buckets.
const Map = preload("res://scripts/campus_map.gd")
const Land = preload("res://scripts/campus_landscape.gd")
const Terrain = preload("res://scripts/campus_terrain.gd")
static var _points: Array[Vector2] = []
static var _buckets: Dictionary = {}
static var _routes: Array[PackedVector2Array] = Land.routes()
static var _landmarks: Array[Dictionary] = Land.landmarks()
static var _fountains: Array[Dictionary] = Land.fountains()


static func prepare() -> void:
	if not _points.is_empty():
		return
	var blocks := Map.buildings()
	var rng := RandomNumberGenerator.new()
	rng.seed = 20261103
	for y in range(40, int(Map.SIZE.y) - 40, 36):
		for x in range(40, int(Map.SIZE.x) - 40, 36):
			var p := Vector2(x, y)
			var forest := Terrain.in_forest(p)
			if (forest and rng.randf() < 0.78) or (not forest and posmod(x + y, 4) == 0 and rng.randf() < 0.035 and Terrain.in_garden(p)):
				p += Vector2(rng.randi_range(-6, 6), rng.randi_range(-6, 6))
				if can_plant(p, blocks):
					_points.append(p.snapped(Vector2(2, 2)))
	_points.sort_custom(func(a: Vector2, b: Vector2) -> bool: return a.y < b.y)
	for point in _points:
		var key := Vector2i((point / 128).floor())
		if not _buckets.has(key):
			_buckets[key] = []
		_buckets[key].append(point)


static func all() -> Array[Vector2]:
	prepare()
	return _points


static func visible(view: Rect2) -> Array[Vector2]:
	prepare()
	var result: Array[Vector2] = []
	var area := view.grow(48)
	for y in range(floori(area.position.y / 128), floori(area.end.y / 128) + 1):
		for x in range(floori(area.position.x / 128), floori(area.end.x / 128) + 1):
			for point in _buckets.get(Vector2i(x, y), []):
				if area.has_point(point):
					result.append(point)
	result.sort_custom(func(a: Vector2, b: Vector2) -> bool: return a.y < b.y)
	return result


static func can_plant(point: Vector2, blocks: Array[Dictionary]) -> bool:
	if not point.is_finite() or not Rect2(Vector2.ONE * 40, Map.SIZE - Vector2.ONE * 80).has_point(point) or Land.water_blocks(point, 30):
		return false
	for block in blocks:
		if Rect2(block["rect"]).grow(42).has_point(point):
			return false
	for row in Map.COURTS:
		var rect := Rect2(Vector2(row[1], row[2]) * Map.SIZE / 100, Vector2(row[3], row[4]) * Map.SIZE / 100)
		if rect.grow(32).has_point(point):
			return false
	for path in _routes:
		for index in range(path.size() - 1):
			if point.distance_to(Geometry2D.get_closest_point_to_segment(point, path[index], path[index + 1])) < 82:
				return false
	for item in _landmarks:
		if point.distance_to(item["point"]) < 100:
			return false
	for item in _fountains:
		if point.distance_to(item["point"]) < 85:
			return false
	return true
