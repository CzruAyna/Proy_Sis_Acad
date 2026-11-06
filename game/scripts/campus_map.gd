extends RefCounted

const Landscape = preload("res://scripts/campus_landscape.gd")
const RoomLayout = preload("res://scripts/campus_room_layout.gd")
const ID := "fni_ciudad_v2"
const LEGACY_ID := "fni_ciudad_v1"
const LEGACY_SIZE := Vector2(2304, 1664)
const SIZE := Landscape.SIZE
const SPAWN := Vector2(6784, 8144)
const ROOM_SIZE := Vector2(480, 320)
const HALL_SIZE := Vector2(720, 480)
const COMPUTING_SOURCE := "https://www.sisinf.fni.uto.edu.bo/computacion/"
# Published room names; positions below are deliberately a playable recreation.
const SYSTEMS_ROOMS := {"sis_a": ["LSIA-1", "LSIA-4"], "sis_b": ["LSIB-1", "LSIB-2", "LSIB-4"]}
const LEGACY_ROOMS := {"sis_a": "SIS A", "sis_b": "SIS B"}
# Silhouettes adapted from the supplied plan, not surveyed footprints.
const FOOTPRINTS := {
	"sis_a": [[0.35, 0], [0.8, 0], [0.8, 0.3], [1, 0.3], [1, 0.7], [0.65, 0.7], [0.65, 1], [0.2, 1], [0.2, 0.65], [0, 0.65], [0, 0.25], [0.35, 0.25]],
	"geologia": [[0, 0.1], [0.25, 0], [0.45, 0.12], [0.45, 0.4], [0.65, 0.4], [0.65, 0.06], [0.85, 0], [1, 0.08], [1, 0.9], [0.8, 1], [0.65, 0.9], [0.65, 0.6], [0.45, 0.6], [0.45, 0.95], [0.2, 1], [0, 0.9]],
	"decanato": [[0, 0.5], [0.3, 0.5], [0.3, 0], [1, 0], [1, 0.45], [0.7, 0.45], [0.7, 0.7], [0.55, 0.7], [0.55, 1], [0, 1]],
	"basicas": [[0.35, 0], [0.65, 0], [0.65, 0.3], [1, 0.3], [1, 0.65], [0.7, 0.65], [0.7, 1], [0.35, 1], [0.35, 0.7], [0, 0.7], [0, 0.35], [0.35, 0.35]],
	"minas": [[0, 0.25], [0.2, 0.25], [0.2, 0], [0.55, 0], [0.55, 0.15], [1, 0.15], [1, 0.85], [0.75, 0.85], [0.75, 1], [0.35, 1], [0.35, 0.85], [0, 0.85]],
	"electrica_aulas": [[0, 0.25], [0.3, 0.25], [0.3, 0], [0.7, 0], [0.7, 0.25], [1, 0.25], [1, 1], [0, 1]],
	"civil": [[0, 0.2], [0.25, 0.2], [0.25, 0], [0.6, 0], [0.6, 0.25], [1, 0.25], [1, 0.7], [0.75, 0.7], [0.75, 1], [0.4, 1], [0.4, 0.8], [0, 0.8]],
	"admin_geo": [[0, 0.35], [0.35, 0.35], [0.35, 0], [0.7, 0], [0.7, 0.35], [1, 0.35], [1, 0.7], [0.65, 0.7], [0.65, 1], [0.35, 1], [0.35, 0.7], [0, 0.7]],
	"quirquincho_quimica": [[0.2, 0], [0.8, 0], [1, 0.3], [1, 0.75], [0.75, 1], [0.2, 1], [0, 0.7], [0, 0.25]],
	"quirquincho_fisica": [[0.22, 0], [0.78, 0], [1, 0.28], [1, 0.82], [0.65, 1], [0.1, 0.85], [0, 0.25]],
	"quirquincho_matem": [[0.15, 0], [0.85, 0], [1, 0.25], [0.95, 0.8], [0.75, 1], [0.25, 1], [0, 0.65], [0, 0.25]]
}
const ROWS := [
	["metalurgia", "METALURGIA", 5, 16, 12, 7, "lab", ["MET-1"]],
	["metalurgia2", "METALURGIA 2", 4, 28, 7, 7, "lab", ["Bloque Metalurgia 2"]],
	["comedor", "COMEDOR FNI", 3, 37, 8, 6, "social", ["Comedor"]],
	["matematicas", "MATEMÁTICAS", 38, 19, 11, 4, "classroom", ["CU-32", "CU-29"]],
	["geologia", "GEOLOGÍA", 53, 17, 6, 15, "classroom", ["CU-3", "CU-11"]],
	["admin_geo", "ADM. GEOLOGÍA", 62, 23, 5, 5, "office", ["Administración Geología"]],
	["posta", "POSTA SANITARIA", 50, 26, 3, 4, "social", ["Posta sanitaria"]],
	["industrial", "INDUSTRIAL", 38, 29, 5, 5, "classroom", ["Bloque Industrial"]],
	["sis_d", "SISTEMAS D", 67, 30, 4, 3, "classroom", ["SIS D"]],
	["sis_e", "SISTEMAS E · JUEGOS", 69, 36, 3, 3, "games_room", ["SIS E"]],
	["sis_c", "SISTEMAS C", 73, 36, 3, 6, "classroom", ["CU-SIC1", "CU-SIC4", "CU-SIC5"]],
	["sis_b", "SISTEMAS B", 68, 41, 4, 5, "classroom", ["SIS B"]],
	["sis_a", "SISTEMAS A", 63, 39, 3, 5, "classroom", ["SIS A"]],
	["admin_sis", "ADM. SISTEMAS", 58, 45, 3, 6, "office", ["Administración Sistemas"]],
	["decanato", "DECANATURA FNI", 42, 47, 7, 5, "office", ["Decanatura"]],
	["electrica_aulas", "AULAS ELÉCTRICA", 69, 50, 8, 4, "classroom", ["Aulas Eléctrica"]],
	["electrica", "EDIF. ELÉCTRICA", 72, 56, 4, 3, "lab", ["Edificio Eléctrica"]],
	["asfaltos", "LAB. ASFALTOS", 5, 59, 4, 4, "lab", ["Laboratorio de Asfaltos"]],
	["sanitaria", "LAB. SANITARIA", 13, 59, 4, 3, "lab", ["Laboratorio Sanitaria"]],
	["hidraulica", "LAB. HIDRÁULICA", 11, 64, 4, 4, "lab", ["Laboratorio Hidráulica"]],
	["resistencia", "LAB. RESISTENCIA", 15, 66, 4, 4, "lab", ["Laboratorio Resistencia"]],
	["diseno", "LAB. DISEÑO", 22, 62, 2, 4, "lab", ["Laboratorio Diseño"]],
	["topografia", "GAB. TOPOGRAFÍA", 21, 68, 2, 4, "lab", ["Gabinete Topografía"]],
	["quirquincho_quimica", "QUIRQUINCHO QUÍMICA", 27, 63, 4, 4, "classroom", ["CU-85"]],
	["min_sc", "AULA MIN-SC", 33, 62, 2, 5, "classroom", ["MIN-SC"]],
	["minas", "BLOQUE MINAS", 43, 60, 7, 6, "classroom", ["Bloque Minas"]],
	["fisica", "LAB. FÍSICA", 55, 64, 6, 7, "lab", ["CU-19", "CU-20"]],
	["quirquincho_fisica", "QUIRQUINCHO FÍSICA", 58, 58, 4, 3, "classroom", ["CU-204"]],
	["quimica_lab", "LAB. QUÍMICA", 28, 70, 6, 6, "lab", ["CU-L-3", "CU-L-4", "CU-L-5", "CU-L-1", "CU-L-2"]],
	["quimica_aulas", "AULAS QUÍMICA", 48, 74, 5, 7, "classroom", ["Aulas Química"]],
	["mecanica", "ADM. MECÁNICA", 18, 77, 7, 4, "office", ["Administración Mecánica"]],
	["biblioteca", "BIBLIOTECA MEC.", 7, 79, 3, 5, "library", ["MEC-5", "MEC-7", "MEC-8"]],
	["fis_mat", "BLOQUE 100", 73, 72, 4, 8, "classroom", ["CU-100", "CU-101", "CU-102", "CU-103", "CU-104", "CU-105", "CU-106"]],
	["basicas", "AULAS BÁSICAS 300", 83, 66, 7, 7, "classroom", ["BAS-Q1", "BAS-Q2", "BAS-Q4", "CB-F4", "CU-F1", "LAF-FIS", "CB-AUD"]],
	["quirquincho_matem", "QUIRQUINCHO MAT.", 58, 83, 5, 4, "classroom", ["CU-64"]],
	["civil", "AULAS CIVIL", 83, 85, 5, 7, "classroom", ["CIV-DID", "LAB.NTI", "Aulas Civil"]],
	["proc_quimicos", "PROCESOS QUÍMICOS", 40, 87, 5, 4, "office", ["Administración Procesos Químicos"]],
	["internado", "INTERNADO MET.", 69, 87, 4, 3, "social", ["Internado Metalurgia"]],
	["ppu", "PPU METALURGIA", 19, 11, 4, 4, "lab", ["PPU Metalurgia"]],
	["coliseo", "COLISEO CERRADO", 74, 16, 5, 5, "social", ["Coliseo cerrado"]]
]
const COURTS := [
	["FÚTBOL SINTÉTICO", 14, 47, 15, 12], ["FÚTBOL TIERRA", 86, 17, 9, 17],
	["VOLEIBOL", 20, 22, 5, 4], ["POLIF. MET", 12, 27, 4, 3],
	["POLIF. INDUSTRIAL", 30, 28, 4, 3], ["POLIF. QUÍMICA", 30, 38, 4, 3],
	["POLIF. MINAS", 35, 66, 5, 5], ["TENIS", 70, 60, 9, 9], ["POLIF. CIVIL", 90, 90, 5, 5]
]


static var _building_index: Dictionary = {}


static func buildings() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for row in ROWS:
		var rect := Rect2(Vector2(float(row[2]), float(row[3])) * SIZE / 100, Vector2(float(row[4]), float(row[5])) * SIZE / 100)
		rect.position = rect.position.snapped(Vector2(8, 8))
		rect.size = rect.size.snapped(Vector2(8, 8))
		var rooms: Array = SYSTEMS_ROOMS.get(row[0], row[7]).duplicate()
		var footprint := PackedVector2Array()
		for vertex in FOOTPRINTS.get(row[0], [[0, 0], [1, 0], [1, 1], [0, 1]]):
			footprint.append((rect.position + Vector2(vertex[0], vertex[1]) * rect.size).snapped(Vector2(2, 2)))
		result.append({"id": row[0], "name": row[1], "rect": rect, "footprint": footprint, "kind": row[6], "rooms": rooms,
			"room_source": COMPUTING_SOURCE if SYSTEMS_ROOMS.has(row[0]) else "FNI-PLANO-01",
			"door": Vector2(rect.get_center().x, rect.end.y + 14).snapped(Vector2(2, 2))})
	return result


static func routes() -> Array[PackedVector2Array]:
	return Landscape.routes()


static func building(id: String) -> Dictionary:
	if _building_index.is_empty():
		for item in buildings():
			_building_index[str(item["id"])] = item
	return _building_index[id].duplicate(true) if _building_index.has(id) else {}


static func room_obstacles(kind: String) -> Array[Rect2]:
	var result: Array[Rect2] = []
	if kind == "games_room":
		for station in game_stations():
			result.append(station["rect"])
	elif kind in ["classroom", "lab", "physics_lab", "chemistry_lab", "physics_virtual"]:
		for y in [112, 168, 224]:
			for x in [72, 168, 288, 384]:
				result.append(Rect2(x, y, 40, 20))
	else:
		result.append(Rect2(120, 116, 240, 32))
	return result


static func game_stations() -> Array[Dictionary]:
	return [
		{"id": "billar", "title": "Billar", "rect": Rect2(64, 88, 136, 56), "approach": Vector2(132, 164)},
		{"id": "ping_pong", "title": "Ping-pong", "rect": Rect2(280, 88, 136, 56), "approach": Vector2(348, 164)},
		{"id": "ajedrez", "title": "Ajedrez", "rect": Rect2(92, 210, 64, 48), "approach": Vector2(176, 234)},
		{"id": "monopolio", "title": "Monopolio", "rect": Rect2(316, 210, 64, 48), "approach": Vector2(296, 234)}
	]


static func room_kind(id: String, room: String) -> String:
	if id == "basicas" and room.contains("Baño"):
		return "restroom"
	if id == "fisica":
		return "physics_lab"
	if id == "quimica_lab":
		return "chemistry_lab"
	if id == "fis_mat" and room == "CU-106":
		return "physics_virtual"
	if SYSTEMS_ROOMS.has(id) and SYSTEMS_ROOMS[id].has(room):
		return "computer_lab"
	return str(building(id).get("kind", "classroom"))


static func floor_count(id: String) -> int:
	return 2 if id == "fis_mat" else (5 if id == "basicas" else 1)


static func floor_rooms(id: String, level: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if level < 0 or level >= floor_count(id):
		return result
	if id == "fis_mat":
		for index in range(3):
			result.append({"id": "CU-%d" % (100 + level * 3 + index), "label": "Aula %d" % (index + 1), "kind": "classroom", "provisional": true})
		if level == 0:
			result.append({"id": "CU-106", "label": "Laboratorio de física virtual", "kind": "physics_virtual", "provisional": true})
	elif id == "basicas":
		var legacy: Array = building(id)["rooms"]
		for index in range(4):
			var label := "Aula · ala " + str(["norte", "este", "sur", "oeste"][index])
			var old_index := level * 4 + index
			result.append({"id": str(legacy[old_index]) if old_index < legacy.size() else "P%d · %s" % [level, label], "label": label, "kind": "classroom", "provisional": true})
		if level in [0, 2, 4]:
			for gender in ["mujeres", "varones"]:
				result.append({"id": "P%d · Baño %s" % [level, gender], "label": "Baño · " + gender, "kind": "restroom", "provisional": true})
	else:
		for room in building(id).get("rooms", []):
			result.append({"id": room, "label": room, "kind": room_kind(id, room), "provisional": true})
	return result


static func room_floor(id: String, room: String) -> int:
	for level in range(floor_count(id)):
		for item in floor_rooms(id, level):
			if item["id"] == room:
				return level
	return -1


static func hall_rooms(id: String, level: int = -1) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var block := building(id)
	var names: Array = block.get("rooms", []) if level < 0 else floor_rooms(id, level).map(func(item: Dictionary) -> String: return str(item["id"]))
	for index in range(names.size()):
		var left := index % 2 == 0
		var row := index / 2
		var top := 52.0 + floorf(row) * 92
		result.append({"name": names[index],
			"rect": Rect2(36 if left else 416, top, 268, 84),
			"door": Vector2(318 if left else 402, top + 44)})
	return result


static func hall_size(id: String) -> Vector2:
	var rows := ceili(float(building(id).get("rooms", []).size()) / 2)
	return Vector2(HALL_SIZE.x, snappedf(clampf(144 + rows * 84, 240, HALL_SIZE.y), 16))


static func hall_spawn(id: String) -> Vector2:
	return Vector2(360, hall_size(id).y - 42)


static func hall_exit(id: String) -> Vector2:
	return Vector2(360, hall_size(id).y - 30)


static func interior_obstacles(id: String, room: String, level: int = -1) -> Array[Rect2]:
	if room.is_empty():
		var walls: Array[Rect2] = []
		for space in hall_rooms(id, level):
			walls.append(space["rect"])
		return walls
	if room_kind(id, room) == "games_room":
		return room_obstacles("games_room")
	return room_layout(id, room)["obstacles"]


static func room_layout(id: String, room: String) -> Dictionary:
	return RoomLayout.make(room_kind(id, room), id, room)


static func room_size(id: String, room: String) -> Vector2:
	return room_layout(id, room)["size"]


static func room_spawn(id: String, room: String) -> Vector2:
	return room_layout(id, room)["spawn"]


static func room_exit(id: String, room: String) -> Vector2:
	return room_layout(id, room)["exit"]
