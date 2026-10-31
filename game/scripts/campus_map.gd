extends RefCounted

const ID := "fni_ciudad_v1"
const SIZE := Vector2(2304, 1664)
const SPAWN := Vector2(1280, 1536)
const ROOM_SIZE := Vector2(480, 320)
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
	["sis_e", "SISTEMAS E", 69, 36, 3, 3, "classroom", ["SIS E"]],
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
	["fis_mat", "FÍSICA / MATEMÁTICAS", 73, 72, 4, 8, "classroom", ["CU-100", "CU-101", "CU-102", "CU-103", "CU-104", "CU-105", "CU-106"]],
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


static func buildings() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for row in ROWS:
		var rect := Rect2(Vector2(float(row[2]), float(row[3])) * SIZE / 100, Vector2(float(row[4]), float(row[5])) * SIZE / 100)
		rect.position = rect.position.snapped(Vector2(8, 8))
		rect.size = rect.size.snapped(Vector2(8, 8))
		result.append({"id": row[0], "name": row[1], "rect": rect, "kind": row[6], "rooms": row[7].duplicate(),
			"door": Vector2(rect.get_center().x, rect.end.y + 14).snapped(Vector2(2, 2))})
	return result


static func routes() -> Array[PackedVector2Array]:
	return [PackedVector2Array([Vector2(1280, 1600), Vector2(1280, 1400), Vector2(1248, 1080), Vector2(1232, 736), Vector2(1184, 592), Vector2(1056, 448), Vector2(736, 336), Vector2(384, 304), Vector2(80, 384), Vector2(48, 1408), Vector2(1280, 1504)]),
		PackedVector2Array([Vector2(1280, 1408), Vector2(1456, 1296), Vector2(1536, 1008), Vector2(1584, 784), Vector2(1568, 576), Vector2(1376, 560), Vector2(1184, 592)]),
		PackedVector2Array([Vector2(1280, 1440), Vector2(2016, 1552), Vector2(2096, 1312), Vector2(2192, 832), Vector2(2256, 336)])]


static func building(id: String) -> Dictionary:
	for item in buildings():
		if item["id"] == id:
			return item
	return {}


static func room_obstacles(kind: String) -> Array[Rect2]:
	var result: Array[Rect2] = []
	if kind in ["classroom", "lab"]:
		for y in [112, 168, 224]:
			for x in [72, 168, 288, 384]:
				result.append(Rect2(x, y, 40, 20))
	else:
		result.append(Rect2(120, 116, 240, 32))
	return result
