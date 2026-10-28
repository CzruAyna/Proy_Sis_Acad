class_name GraphRouting
extends RefCounted

# The rendered polylines are also the geometry checked here: no unchecked
# animation or smoothing is applied after validation.
const CLEARANCE := 24.0
const NODE_CLEARANCE := 16.0


static func segment_distance_squared(a: Vector2, b: Vector2, c: Vector2, d: Vector2) -> float:
	var ab := b - a
	var cd := d - c
	var denominator := ab.cross(cd)
	if absf(denominator) > 0.000001:
		var offset := c - a
		var t := offset.cross(cd) / denominator
		var u := offset.cross(ab) / denominator
		if t >= 0 and t <= 1 and u >= 0 and u <= 1:
			return 0.0
	return minf(minf(a.distance_squared_to(Geometry2D.get_closest_point_to_segment(a, c, d)), b.distance_squared_to(Geometry2D.get_closest_point_to_segment(b, c, d))), minf(c.distance_squared_to(Geometry2D.get_closest_point_to_segment(c, a, b)), d.distance_squared_to(Geometry2D.get_closest_point_to_segment(d, a, b))))


static func valid(nodes: Array[Dictionary], edges: Array[Vector2i], paths: Array[PackedVector2Array], radii: Array[float]) -> bool:
	if paths.size() != edges.size():
		return false
	for a in range(nodes.size()):
		var center: Vector2 = nodes[a]["pos"]
		if not center.is_finite():
			return false
		for b in range(a + 1, nodes.size()):
			if center.distance_to(nodes[b]["pos"]) < radii[a] + radii[b] + 34.0:
				return false
	var bounds: Array[Rect2] = []
	for index in range(paths.size()):
		var points := paths[index]
		if points.size() < 2:
			return false
		var box := Rect2(points[0], Vector2.ZERO)
		for point in points:
			if not point.is_finite():
				return false
			box = box.expand(point)
		bounds.append(box.grow(CLEARANCE))
		for node in range(nodes.size()):
			if node == edges[index].x or node == edges[index].y:
				continue
			var center: Vector2 = nodes[node]["pos"]
			var distance := radii[node] + NODE_CLEARANCE
			if not box.grow(distance).has_point(center):
				continue
			for part in range(points.size() - 1):
				if center.distance_squared_to(Geometry2D.get_closest_point_to_segment(center, points[part], points[part + 1])) < distance * distance:
					return false
	for a in range(paths.size()):
		for b in range(a + 1, paths.size()):
			if not bounds[a].intersects(bounds[b]):
				continue
			for part_a in range(paths[a].size() - 1):
				var box := Rect2(paths[a][part_a], Vector2.ZERO).expand(paths[a][part_a + 1]).grow(CLEARANCE)
				for part_b in range(paths[b].size() - 1):
					if not box.intersects(Rect2(paths[b][part_b], Vector2.ZERO).expand(paths[b][part_b + 1]).grow(0.01)):
						continue
					if segment_distance_squared(paths[a][part_a], paths[a][part_a + 1], paths[b][part_b], paths[b][part_b + 1]) < CLEARANCE * CLEARANCE:
						return false
	return true
