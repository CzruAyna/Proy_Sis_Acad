extends RefCounted

const Map = preload("res://scripts/campus_map.gd")
const Catalog = preload("res://scripts/catalog.gd")
const Daily = preload("res://scripts/campus_daily.gd")
const BUILDING := "basicas"
const ROOMS := ["BAS-Q1", "BAS-Q2", "BAS-Q4", "CB-F4", "CU-F1", "LAF-FIS", "CB-AUD"]
const DAYS := ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes"]
const STARTS := [570, 660, 750, 840, 930, 1020]
const DURATION := 60
const EXAMPLES := {
	"MAT 1100": ["2x + y = 7; x - y = 2", "3x = 9", "x = 3; y = 1"],
	"MAT 1101": ["f(x) = x²", "f'(x) = lim (2x + h), h → 0", "f'(x) = 2x"],
	"MAT 1102": ["f(x) = 2x", "Una primitiva es F(x) = x²", "Área de 0 a 3: F(3) - F(0) = 9"],
	"MAT 1103": ["T(x, y) = (2x, y)", "T(1, 0) = (2, 0)", "Autovalor 2 para (1, 0)"],
	"MAT 1135": ["Datos: 2, 4, 6", "Media = suma / cantidad", "Media = (2 + 4 + 6) / 3 = 4"],
	"MAT 1207": ["dy/dt = ky", "Para y > 0: dy / y = k dt", "y(t) = y(0) e^(kt)"],
	"FIS 1100": ["v = v₀ + at", "v₀ = 0; a = 2 m/s²", "A los 3 s, v = 6 m/s"],
	"FIS 1102": ["V = I R", "R = 4 Ω; I = 2 A", "V = 8 V"],
	"FIS 1200": ["v = λ f", "λ = 2 m; f = 3 Hz", "v = 6 m/s"],
	"QMC 1100": ["2 H₂ + O₂ → 2 H₂O", "Se conservan H y O", "2 mol de H₂ dan 2 mol de H₂O"],
	"SIS 1110": ["suma ← 0", "Para n en [2, 3, 4]: suma ← suma + n", "Mostrar suma → 9"],
	"SIS 2210": ["función doble(n)", "    devolver 2 × n", "doble(4) → 8"],
	"INF 1210": ["A = {1, 2, 3}; B = {2, 4}", "A ∩ B contiene sus elementos comunes", "A ∩ B = {2}"],
	"INF 2430": ["SELECT nombre", "FROM estudiantes", "WHERE periodo = 1;"]
}


const WORKSHOPS := [
	["CU-100", "Álgebra aplicada", "MAT 1100"], ["CU-101", "Derivadas", "MAT 1101"],
	["CU-102", "Integración", "MAT 1102"], ["CU-103", "Transformaciones", "MAT 1103"],
	["CU-104", "Estadística", "MAT 1135"], ["CU-105", "Ondas", "FIS 1200"],
	["CU-106", "Laboratorio de movimiento", "FIS 1100"], ["Taller 300", "Reacciones químicas", "QMC 1100"],
	["Taller 301", "Circuitos", "FIS 1102"], ["Taller 302", "Algoritmos", "SIS 1110"],
	["Taller 303", "Conjuntos", "INF 1210"], ["Taller 304", "Bases de datos", "INF 2430"]
]


static func workshops() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for index in WORKSHOPS.size():
		var item: Array = WORKSHOPS[index]
		var id := "taller-" + str(index)
		var building := "fis_mat" if index < 7 else BUILDING
		rows.append({"key": id, "course": id, "code": item[2], "name": item[1], "room": item[0],
			"building": building, "floor": Map.room_floor(building, item[0]), "teacher": ["Vega", "Quispe", "Flores"][index % 3],
			"day": index % 5, "start": STARTS[index / 5], "seed": index, "lines": EXAMPLES[item[2]], "workshop": true})
	return rows


static func schedule(snapshot: Dictionary) -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var room_counts := {}
	for subject: Dictionary in snapshot.get("subjects", []):
		if subject["enrollment"].is_empty():
			continue
		var index := rows.size()
		var code := str(subject["sigla"])
		var course := Catalog.course_for_sigla(str(subject["program_id"]), code, str(subject["mention_id"]))
		var term := int(snapshot["term"])
		var seed_key := "%s/%d/%s" % [snapshot.get("student_seed", ""), term, subject["id"]]
		var parallel := int(subject["enrollment"].get("parallel", 0))
		var slot := index if term == 1 else posmod(seed_key.hash() + parallel * 7, DAYS.size() * STARTS.size())
		var preferred_room := index if term == 1 else posmod(code.hash(), ROOMS.size())
		var room: String = ROOMS[preferred_room % ROOMS.size()]
		for offset in range(1, ROOMS.size()):
			var candidate: String = ROOMS[(preferred_room + offset) % ROOMS.size()]
			if int(room_counts.get(candidate, 0)) < int(room_counts.get(room, 0)):
				room = candidate
		room_counts[room] = int(room_counts.get(room, 0)) + 1
		rows.append({
			"key": "%d/%s" % [int(snapshot["term"]), subject["id"]],
			"course": str(subject["id"]), "code": code, "name": str(subject["name"]),
			"parallel": ["A", "B", "C"][posmod(parallel, 3)], "room": room, "floor": Map.room_floor(BUILDING, room), "teacher": ["Vega", "Quispe", "Flores", "Mamani", "Rojas"][posmod(code.hash(), 5)], "seed": seed_key.hash(), "day": slot % DAYS.size(),
			"start": STARTS[(slot / DAYS.size()) % STARTS.size()], "lines": _lines(code, course)
		})
	return rows


static func _lines(code: String, course: Dictionary) -> Array:
	if EXAMPLES.has(code):
		return EXAMPLES[code]
	# A board with the existing course's own syllabus, including adapted external courses.
	var topics: Array = course.get("topics", [])
	if not topics.is_empty():
		return topics.slice(0, 4)
	return [str(course.get("desc", code))]


static func next_start(row: Dictionary, minutes: float) -> float:
	var week := floori(minutes / Daily.WEEK)
	for offset in 3:
		var session := appointment(row, week + offset)
		if not session["cancelled"] and minutes < float(session["start"]) + DURATION:
			return float(session["start"])
	return INF


static func appointment(row: Dictionary, week: int) -> Dictionary:
	var start := week * Daily.WEEK + int(row["day"]) * Daily.DAY + int(row["start"])
	var exam: bool = week % 3 == 2 and not row.get("workshop", false)
	# A regular week always follows a cancelled week.
	var roll := posmod(hash("%s/%d" % [row.get("seed", 0), week]), 10) if week % 2 == 1 else 9
	var cancelled := roll == 0 and not exam
	var message := "Clase confirmada."
	if cancelled:
		message = "Hoy no podré asistir. Retomamos la próxima semana."
	elif exam and roll < 3:
		start += Daily.DAY
		message = "Postergué el examen hasta mañana, en la misma aula."
	elif roll < 4:
		start += 20
		message = "Llegaré veinte minutos tarde."
	if exam:
		message = "Examen programado. " + message
	return {"start": start, "cancelled": cancelled, "exam": exam, "message": message}


static func conflicts(row: Dictionary, schedule_rows: Array[Dictionary]) -> PackedStringArray:
	var others := PackedStringArray()
	for other in schedule_rows:
		if row["course"] != other["course"] and row["day"] == other["day"] and row["start"] == other["start"]:
			others.append(str(other["code"]))
	return others


static func active(rows: Array[Dictionary], room: String, minutes: float) -> Dictionary:
	for row in rows:
		if row["room"] == room and minutes >= next_start(row, minutes):
			return row
	return {}


static func visible_lines(row: Dictionary, minutes: float) -> int:
	var elapsed := minutes - next_start(row, minutes)
	return clampi(1 + floori(elapsed / 12.0), 0, row["lines"].size())


static func timing(row: Dictionary) -> String:
	var start := int(row["start"])
	var end := start + DURATION
	return "%s %02d:%02d–%02d:%02d · %s · Piso %d" % [
		DAYS[row["day"]], start / 60, start % 60, end / 60, end % 60, row["room"], row["floor"]
	]
