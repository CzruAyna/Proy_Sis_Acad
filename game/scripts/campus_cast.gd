extends RefCounted
## Costume studies, not an institutional roster or autonomous population model.
const Painter = preload("res://scripts/pixel_painter.gd")
const STUDENT_COUNT := 24
const STAFF := [
	["personal_docente", "Docente", "#a5826e", "book", "matematicas"],
	["personal_biblioteca", "Biblioteca", "#698d87", "book", "biblioteca"],
	["personal_laboratorio", "Técnica de laboratorio", "#d0d6c8", "flask", "quimica_lab"],
	["personal_mantenimiento", "Mantenimiento", "#bc8c4d", "wrench", "industrial"],
	["personal_jardines", "Jardinería", "#749767", "vest", "admin_sis"],
	["personal_seguridad", "Seguridad", "#54718a", "badge", "decanato"],
	["personal_administracion", "Administración", "#957ca2", "badge", "admin_sis"],
	["personal_visitante", "Visitante", "#ba7e88", "book", "minas"]
]
const PROFESSIONS := [
	["minas", "Ingeniería de Minas", "#c68b35", "helmet", "minas"],
	["civil", "Ingeniería Civil", "#e7e3c6", "plan", "civil"],
	["electrica", "Ingeniería Eléctrica", "#e0c74d", "electric", "electrica"],
	["electronica", "Ingeniería Electrónica", "#638eae", "circuit", "electrica_aulas"],
	["mecanica", "Ingeniería Mecánica", "#5e8fa3", "wrench", "mecanica"],
	["electromecanica", "Ingeniería Electromecánica", "#ca864b", "electric", "mecanica"],
	["mecatronica", "Mecatrónica · diseño", "#a2768e", "circuit", "mecanica"],
	["metalurgia", "Ingeniería Metalúrgica", "#a8aeab", "visor", "metalurgia"],
	["materiales", "Ciencia de Materiales · diseño", "#d8ddd5", "flask", "metalurgia2"],
	["quimica", "Ingeniería Química", "#e3e8d7", "flask", "quimica_lab"],
	["geologia", "Ingeniería Geológica", "#bda273", "field", "geologia"],
	["industrial", "Ingeniería Industrial", "#b8bb72", "plan", "industrial"],
	["sistemas", "Ingeniería de Sistemas", "#378bc0", "laptop", "sis_a"],
	["informatica", "Ingeniería Informática", "#be4d57", "laptop", "sis_b"]
]
const DOGS := [["perro_arena", "Compañero arena", "#ba9b6d"], ["perro_negro", "Compañero negro", "#343e42"], ["perro_manchado", "Compañero manchado", "#d9d5bd"], ["perro_canelo", "Compañero canelo", "#9d6344"], ["perro_gris", "Compañero gris", "#909894"], ["piedritas_recuerdo", "Recuerdo de Piedritas", "#725339"]]
static var _textures: Dictionary = {}


static func texture(id: String, frame: int = 0, back: bool = false) -> Texture2D:
	var key := id + str(frame % 2) + str(back)
	if _textures.has(key):
		return _textures[key]
	var p := Painter.new(24, 32)
	if id.begins_with("perro_") or id == "piedritas_recuerdo":
		_dog(p, id, frame)
	else:
		_person(p, id, frame, back)
	_textures[key] = p.texture()
	return _textures[key]


static func _person(p: RefCounted, id: String, frame: int, back: bool) -> void:
	var index := int(id.get_slice("_", 1)) if id.begins_with("estudiante_") else posmod(id.hash(), 24)
	var skin: Color = [Color("#d9ae85"), Color("#b78662"), Color("#8e624b"), Color("#e6c39c")][index % 4]
	var hair: Color = [Color("#273039"), Color("#4e3e32"), Color("#8a6745")][index % 3]
	var cloth := Color("#7c86a0")
	var accessory := "student"
	for row in PROFESSIONS + STAFF:
		if row[0] == id:
			cloth = Color(row[2])
			accessory = row[3]
	if id.begins_with("estudiante"):
		cloth = [Color("#6f9a8c"), Color("#9d6985"), Color("#4f88a9"), Color("#c19a63"), Color("#885f66"), Color("#68759c"), Color("#a0a878"), Color("#b86e57")][index % 8]
	p.rect(8, 4, 8, 9, hair)
	if id.begins_with("estudiante") and index % 3 == 1:
		p.rect(7, 5, 2, 11, hair)
		p.rect(15, 5, 2, 11, hair)
	elif id.begins_with("estudiante") and index % 3 == 2:
		p.ellipse(Vector2(12, 5), Vector2(6, 4), hair)
	p.rect(9, 7, 6, 6, hair if back else skin)
	if not back:
		p.dot(10, 9, Color("#22333d"))
		p.dot(14, 9, Color("#22333d"))
	p.rect(7, 14, 10, 9, cloth)
	p.rect(5, 15, 2, 9, cloth.darkened(0.18))
	p.rect(17, 15, 2, 9, cloth.darkened(0.18))
	p.rect(5, 22, 2, 3, skin)
	p.rect(17, 22, 2, 3, skin)
	p.rect(8, 23, 3, 6 + frame % 2, Color("#344757"))
	p.rect(13, 23, 3, 7 - frame % 2, Color("#344757"))
	p.rect(7, 29 + frame % 2, 5, 2, Color("#20303b"))
	p.rect(13, 30 - frame % 2, 5, 2, Color("#20303b"))
	if back:
		p.rect(9, 15, 7, 8, cloth.darkened(0.35))
	elif accessory in ["helmet", "plan", "electric", "visor"]:
		p.rect(7, 3, 10, 4, cloth.lightened(0.35))
		p.rect(6, 6, 12, 2, cloth.lightened(0.2))
		p.rect(7, 16, 2, 6, Color("#e0cd70"))
		p.rect(15, 16, 2, 6, Color("#e0cd70"))
	if accessory == "helmet":
		p.rect(11, 4, 3, 3, Color("#fff3b0"))
	elif accessory == "plan":
		p.rect(16, 19, 5, 8, Color("#d1e0ce"))
		p.rect(17, 20, 3, 1, Color("#4b8191"))
	elif accessory == "electric":
		p.polygon([[11, 16], [14, 16], [12, 19], [15, 19], [11, 22], [12, 19], [10, 19]], Color("#e7dc8a"))
	elif accessory == "visor":
		p.rect(8, 8, 8, 5, Color("#7faaa8"))
		p.rect(9, 15, 6, 10, Color("#67574b"))
	elif accessory == "flask":
		p.rect(8, 14, 8, 10, Color("#e5e7d8"))
		p.rect(9, 9, 6, 1, Color("#5b99a2"))
		p.rect(19, 20, 2, 5, Color("#a5c9b4"))
		p.rect(18, 24, 4, 3, Color("#66a58c"))
	elif accessory == "wrench":
		p.rect(19, 20, 2, 8, Color("#b9c4c0"))
		p.rect(18, 19, 4, 2, Color("#b9c4c0"))
	elif accessory == "field":
		p.rect(7, 3, 10, 4, Color("#bfa374"))
		p.rect(5, 6, 14, 2, Color("#937c58"))
		p.rect(15, 18, 5, 7, Color("#796346"))
	elif accessory in ["laptop", "circuit"]:
		p.rect(16, 19, 6, 6, Color("#304b5e"))
		p.rect(17, 20, 4, 3, Color("#64afaa") if accessory == "laptop" else Color("#72a879"))
	elif accessory == "book":
		p.rect(16, 18, 6, 9, Color("#c4d1bd"))
		p.rect(17, 19, 1, 7, Color("#547a85"))
	elif accessory == "vest":
		p.rect(8, 15, 2, 8, Color("#d6d884"))
		p.rect(14, 15, 2, 8, Color("#d6d884"))
	elif accessory == "badge":
		p.rect(10, 16, 5, 6, Color("#cbd9d1"))
		p.rect(11, 17, 3, 2, Color("#537e97"))
	elif index % 2 == 0:
		p.rect(7, 14, 2, 8, cloth.darkened(0.5))
		p.rect(15, 14, 2, 8, cloth.darkened(0.5))
	if accessory == "student" and index % 3 == 1:
		p.rect(8, 8, 3, 3, Color("#344956"))
		p.rect(13, 8, 3, 3, Color("#344956"))


static func _dog(p: RefCounted, id: String, frame: int) -> void:
	var coat := Color("#b59770")
	for row in DOGS:
		if row[0] == id:
			coat = Color(row[2])
	p.ellipse(Vector2(11, 22), Vector2(8, 5), coat)
	p.rect(7, 24, 3, 6 - frame % 2, coat.darkened(0.2))
	p.rect(16, 24, 3, 5 + frame % 2, coat.darkened(0.2))
	p.ellipse(Vector2(17, 16), Vector2(5, 6), coat)
	p.polygon([[13, 13], [12, 6], [17, 11], [20, 6], [22, 14]], coat.darkened(0.3))
	p.rect(18, 17, 5, 3, coat.lightened(0.15))
	p.rect(22, 17, 2, 2, Color("#1a2d34"))
	p.dot(18, 13, Color("#e7c980"))
	p.line(Vector2(4, 22), Vector2(1, 16 + frame % 2 * 3), coat, 3)
	if id in ["perro_manchado", "piedritas_recuerdo"]:
		p.rect(7, 19, 7, 5, Color("#3c4140"))
	if id == "piedritas_recuerdo":
		p.rect(15, 17, 6, 3, Color("#b6a177"))
