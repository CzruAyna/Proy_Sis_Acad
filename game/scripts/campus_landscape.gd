extends RefCounted
## Exterior georeferenced against OSM, with scenery from the annotated plan.
const Geo = preload("res://scripts/campus_cartography.gd")
const SIZE := Vector2(7040, 3904)
const SOURCE := "FNI-MAPA-MARCADO-2026-11-03"
const FOREST := [[60.8, 55], [63.2, 53.4], [63.4, 89], [61.8, 91], [60.9, 86]]
const POND := [[91.2, 82], [93, 79.7], [96.2, 78.8], [99.7, 77], [99.7, 84], [97.3, 85.4], [93, 87], [91.1, 85]]
const FNI_SEATS := Vector2(3296, 1216)
const PIEDRITAS := Vector2(3600, 3480)
static var _water_outline := PackedVector2Array()


static func at(x: float, y: float) -> Vector2:
	return (Vector2(x, y) * SIZE / 100).snapped(Vector2(2, 2))


static func polygon(points: Array) -> PackedVector2Array:
	var result := PackedVector2Array()
	for point in points:
		result.append(at(point[0], point[1]))
	return result


static func routes() -> Array[PackedVector2Array]:
	var result := Geo.shapes("roads")
	# Gameplay link from the central bend to the eastern service road.
	result.append(PackedVector2Array([result[1][0], result[8][1]]))
	return result


static func landmarks() -> Array[Dictionary]:
	return [
		{"id": "piedritas", "title": "Piedritas", "kind": "statue", "point": PIEDRITAS, "approach": PIEDRITAS + Vector2(0, 22), "source": SOURCE},
		{"id": "chivato", "title": "El Chivato de la FNI", "kind": "statue", "point": Geo.anchor("chivato"), "approach": Geo.anchor("chivato") + Vector2(0, 26), "source": "OSM nodo 4682413170"}
	]


static func fountains() -> Array[Dictionary]:
	var shapes := Geo.shapes("fountains")
	return [
		{"id": "fuente_ingreso", "point": Geo.bounds(shapes[0]).get_center(), "radius": 42},
		{"id": "fuente_bloque_100", "point": Vector2(4650, 2730), "radius": 24},
		{"id": "fuente_decanato", "point": Geo.bounds(shapes[1]).get_center(), "radius": 52}
	]


static func destination(id: String) -> Dictionary:
	for item in landmarks():
		if item["id"] == id:
			return {"id": id, "name": item["title"], "point": item["approach"]}
	if id == "bosque":
		return {"id": id, "name": "Bosque del ingreso", "point": at(62, 85)}
	if id == "laguna":
		return {"id": id, "name": "Laguna de Civil", "point": at(90, 83)}
	return {}


static func obstacles() -> Array[Rect2]:
	var result: Array[Rect2] = []
	for item in landmarks():
		result.append(Rect2(item["point"] - Vector2(9, 5), Vector2(18, 10)))
	for item in fountains():
		var radius: float = item["radius"] * 0.8
		result.append(Rect2(item["point"] - Vector2.ONE * radius, Vector2.ONE * radius * 2))
	return result


static func water_blocks(point: Vector2, margin: float = 0) -> bool:
	if _water_outline.is_empty():
		_water_outline = polygon(POND)
	var outline := _water_outline
	if Geometry2D.is_point_in_polygon(point, outline):
		return true
	for index in range(outline.size()):
		if point.distance_to(Geometry2D.get_closest_point_to_segment(point, outline[index], outline[(index + 1) % outline.size()])) < margin:
			return true
	return false
