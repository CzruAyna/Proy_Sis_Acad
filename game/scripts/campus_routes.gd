extends RefCounted
## Native A* over the recreated road network. No per-frame path searches.
const Land = preload("res://scripts/campus_landscape.gd")
var graph := AStar2D.new()
var segments: Array[Dictionary] = []
var _ids: Dictionary = {}
var walkable: Callable
var searches := 0


func build(can_walk: Callable) -> void:
	graph.clear()
	segments.clear()
	_ids.clear()
	searches = 0
	walkable = can_walk
	for path in Land.routes():
		for i in range(path.size() - 1):
			segments.append({"a": path[i], "b": path[i + 1], "points": [path[i], path[i + 1]]})
	for a in range(segments.size()):
		for b in range(a + 1, segments.size()):
			var point: Variant = Geometry2D.segment_intersects_segment(segments[a]["a"], segments[a]["b"], segments[b]["a"], segments[b]["b"])
			if point is Vector2:
				segments[a]["points"].append(point)
				segments[b]["points"].append(point)
	var links: Array[Dictionary] = []
	for a in segments:
		for endpoint in [a["a"], a["b"]]:
			for b in segments:
				var projection := Geometry2D.get_closest_point_to_segment(endpoint, b["a"], b["b"])
				if endpoint.distance_squared_to(projection) < 80 * 80 and clear_line(endpoint, projection):
					b["points"].append(projection)
					links.append({"a": endpoint, "b": projection})
	var split: Array[Dictionary] = []
	for segment in segments:
		var origin: Vector2 = segment["a"]
		segment["points"].sort_custom(func(a: Vector2, b: Vector2) -> bool: return a.distance_squared_to(origin) < b.distance_squared_to(origin))
		for i in range(segment["points"].size() - 1):
			var a := _node(segment["points"][i])
			var b := _node(segment["points"][i + 1])
			if a != b and clear_line(graph.get_point_position(a), graph.get_point_position(b)):
				if not graph.are_points_connected(a, b):
					graph.connect_points(a, b)
				split.append({"a": graph.get_point_position(a), "b": graph.get_point_position(b), "aid": a, "bid": b})
	for link in links:
		var a := _node(link["a"])
		var b := _node(link["b"])
		if a != b and not graph.are_points_connected(a, b):
			graph.connect_points(a, b)
	segments = split


func _node(point: Vector2) -> int:
	var key := Vector2i(point.round())
	if not _ids.has(key):
		_ids[key] = _ids.size()
		graph.add_point(_ids[key], Vector2(key))
	return int(_ids[key])


func clear_line(a: Vector2, b: Vector2, radius: float = 12) -> bool:
	var steps := maxi(1, ceili(a.distance_to(b) / 16))
	for i in range(steps + 1):
		if not walkable.call(a.lerp(b, float(i) / steps), radius):
			return false
	return true


func _connector(point: Vector2) -> Dictionary:
	var options: Array[Dictionary] = []
	for segment in segments:
		var projection := Geometry2D.get_closest_point_to_segment(point, segment["a"], segment["b"])
		options.append({"point": projection, "distance": projection.distance_squared_to(point), "segment": segment})
	options.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a["distance"] < b["distance"])
	for i in range(mini(8, options.size())):
		if clear_line(point, options[i]["point"]):
			return options[i]
	return {}


func path(start: Vector2, finish: Vector2) -> PackedVector2Array:
	searches += 1
	if start.distance_to(finish) < 220 and clear_line(start, finish):
		return PackedVector2Array([start, finish])
	var a := _connector(start)
	var b := _connector(finish)
	if a.is_empty() or b.is_empty():
		return PackedVector2Array()
	var first := _ids.size()
	graph.add_point(first, a["point"])
	graph.add_point(first + 1, b["point"])
	for pair in [[a, first], [b, first + 1]]:
		graph.connect_points(pair[1], pair[0]["segment"]["aid"])
		graph.connect_points(pair[1], pair[0]["segment"]["bid"])
	if a["segment"] == b["segment"]:
		graph.connect_points(first, first + 1)
	var route := graph.get_point_path(first, first + 1)
	graph.remove_point(first)
	graph.remove_point(first + 1)
	if route.is_empty():
		return route
	var result := PackedVector2Array([start])
	result.append_array(route)
	result.append(finish)
	return result
