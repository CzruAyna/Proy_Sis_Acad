extends RefCounted
## Access to the local projected OSM extract. Game art uses its own data.
const CREDIT := "© OpenStreetMap contributors · ODbL"
const COPYRIGHT_URL := "https://www.openstreetmap.org/copyright"
const FILE := "res://assets/cartography/fni_osm.json"
static var _data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(FILE))


static func point(raw: Array) -> Vector2:
	return Vector2(raw[0], raw[1])


static func polygon(raw: Array) -> PackedVector2Array:
	var result := PackedVector2Array()
	for pair in raw:
		result.append(point(pair))
	return result


static func shape(group: String, id: String) -> PackedVector2Array:
	var feature: Dictionary = _data[group].get(id, {})
	return polygon(feature.get("points", []))


static func shapes(group: String) -> Array[PackedVector2Array]:
	var result: Array[PackedVector2Array] = []
	for feature in _data[group]:
		result.append(polygon(feature["points"]))
	return result


static func anchor(id: String) -> Vector2:
	return point(_data[id] if id == "gate" else _data[id]["point"])


static func bounds(points: PackedVector2Array) -> Rect2:
	var result := Rect2(points[0], Vector2.ZERO)
	for vertex in points:
		result = result.expand(vertex)
	return result
