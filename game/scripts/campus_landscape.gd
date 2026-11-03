extends RefCounted
## Playable interpretation of MAPA DETECTADO.jpg and the user's colour legend.
const SIZE := Vector2(12288, 8704)
const SOURCE := "FNI-MAPA-MARCADO-2026-11-03"
const LAWNS := [
	[[49, 36], [54, 35], [53.5, 40], [49.5, 41]],
	[[45.5, 43], [48.5, 42], [50, 50], [48, 49]],
	[[54.3, 40], [55.7, 40], [55.3, 59], [53.7, 59]],
	[[50.5, 59], [53.4, 59], [54.4, 68], [51.3, 69]],
	[[52, 69], [54.2, 70], [54.8, 78], [51.8, 77]],
	[[23, 85], [53, 87], [54.5, 92], [23, 89]],
	[[69.5, 69], [73, 69], [73, 77], [69.5, 77]]
]
const FOREST := [[63, 70], [68.8, 69.2], [69.4, 89.7], [67.6, 92], [63, 91]]
const POND := [[91.2, 82], [93, 79.7], [96.2, 78.8], [99.7, 77], [99.7, 84], [97.3, 85.4], [93, 87], [91.1, 85]]
const PARKING := [[[43.2, 31], [47.2, 30.3], [49, 41], [45, 42.7]], [[76.4, 57.5], [80.5, 58], [80.1, 66], [76.5, 66]]]
const ROAD_LINES := [
	[[55.2, 94], [55, 89], [54.8, 84], [54.6, 78], [53.8, 70], [51.6, 64], [49.8, 54], [48.4, 43], [47.7, 33]],
	[[55.2, 89], [56, 80], [55.6, 68], [55.8, 54], [55.8, 43], [56, 34]],
	[[2, 23], [3.5, 18], [7, 14.2], [11, 14], [21, 18], [32, 22], [43, 27], [47.7, 33], [51.5, 34], [56, 34], [63.5, 33.4], [66, 35], [67, 40], [67, 49], [65.7, 60], [64.1, 68]],
	[[2, 23], [1.5, 34], [1.4, 48], [1.5, 59], [9, 66], [19, 73], [29, 79], [42, 82], [53.2, 84.5]],
	[[2, 23], [11, 22], [20, 20.5], [28, 19.8]],
	[[1.5, 59], [11, 67], [22, 77], [23, 85], [54.8, 89]],
	[[54.8, 89], [58.4, 87], [62.1, 87], [63, 80], [64.1, 68], [74, 68], [81.7, 68], [83, 63]],
	[[62.1, 87], [65, 92], [72, 94], [82, 97], [96, 99]],
	[[47.7, 33], [45, 34], [44, 31]],
	[[47, 43], [50, 42], [55.8, 40]],
	[[51.8, 64], [48, 65], [44, 64], [40, 63], [38, 59]],
	[[54, 75], [49, 79], [44, 79], [39, 76], [35, 74]],
	[[55.2, 94], [57.5, 90], [60, 89], [62.1, 87]],
	[[8, 84], [8.3, 77], [12, 79]],
	[[44, 31], [42, 23]],
	[[63.5, 33.4], [62, 29]]
]
static var _water_outline := PackedVector2Array()


static func at(x: float, y: float) -> Vector2:
	return (Vector2(x, y) * SIZE / 100).snapped(Vector2(2, 2))


static func polygon(points: Array) -> PackedVector2Array:
	var result := PackedVector2Array()
	for point in points:
		result.append(at(point[0], point[1]))
	return result


static func routes() -> Array[PackedVector2Array]:
	var result: Array[PackedVector2Array] = []
	for points in ROAD_LINES:
		result.append(polygon(points))
	return result


static func landmarks() -> Array[Dictionary]:
	return [
		{"id": "piedritas", "title": "Piedritas", "kind": "statue", "point": at(54.4, 88.5), "approach": at(54.4, 88.5) + Vector2(0, 44), "source": SOURCE},
		{"id": "chivato", "title": "El Chivato de la FNI", "kind": "statue", "point": at(50.6, 38), "approach": at(50.6, 38) + Vector2(0, 52), "source": SOURCE}
	]


static func fountains() -> Array[Dictionary]:
	return [{"id": "fuente_ingreso", "point": at(53.8, 72.5), "radius": 42}, {"id": "fuente_bloque_100", "point": at(71.3, 72.2), "radius": 30}, {"id": "fuente_decanato", "point": at(48.5, 53), "radius": 34}]


static func destination(id: String) -> Dictionary:
	for item in landmarks():
		if item["id"] == id:
			return {"id": id, "name": item["title"], "point": item["approach"]}
	if id == "bosque":
		return {"id": id, "name": "Bosque del ingreso", "point": at(65.5, 85)}
	if id == "laguna":
		return {"id": id, "name": "Laguna de Civil", "point": at(90, 83)}
	return {}


static func obstacles() -> Array[Rect2]:
	var result: Array[Rect2] = []
	for item in landmarks():
		result.append(Rect2(item["point"] - Vector2(18, 10), Vector2(36, 20)))
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
