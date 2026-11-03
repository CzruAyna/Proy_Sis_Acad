extends RefCounted
## Read-only curriculum presentation. Virtual commands never execute a shell.
signal chapter_changed(cue: Dictionary)
signal pause_changed(cue: Dictionary)

const Catalog = preload("res://scripts/catalog.gd")
const COMMAND := "sis-inf demo --loop"
const NOTICE := "Orientación didáctica · planes de referencia 2011; vigencia pendiente de verificación."
const PAUSE_ACTORS := [
	{"id": "systems_engineer", "name": "Ingeniería de Sistemas", "theme": "sistemas", "prop": "diagrama de procesos"},
	{"id": "informatics_engineer", "name": "Ingeniería Informática", "theme": "informatica", "prop": "terminal de programación"},
	{"id": "arch_linux", "name": "Entusiasta de Arch Linux", "theme": "linux", "prop": "portátil y terminal propia"},
	{"id": "cybersecurity", "name": "Especialista en ciberseguridad", "theme": "security", "prop": "análisis defensivo y escudo geométrico"},
	{"id": "network_engineer", "name": "Especialista en redes", "theme": "network", "prop": "conexiones y equipos de red"},
	{"id": "data_analyst", "name": "Analista de datos", "theme": "data", "prop": "gráfico y libreta"}
]
const SCENES := {
	"gestion_sistemas": "systems_flow", "gestion_informacion": "information",
	"modelamiento_optimizacion": "optimization", "desarrollo_sw": "software",
	"telematica": "network"
}

var chapters: Array[Dictionary] = []
var index := 0
var cycle := 1
var elapsed := 0.0
var paused := false
var speed := 1.0
var phase := "IDLE"
var detailed := false
var overview: Array[int] = []
var pause_actor: Dictionary = {}
var pause_sequence := 0
var _pause_random := RandomNumberGenerator.new()
var _last_actor := -1


func _init(seed_value: int = -1) -> void:
	if seed_value < 0:
		_pause_random.randomize()
	else:
		_pause_random.seed = seed_value
	_add("inicio", "SIS-INF", "Bienvenido al recorrido automático. Conocerás las dos carreras, sus cinco menciones, materias y ejemplos de aplicación. Puedes pausar, avanzar o volver al modo interactivo en cualquier momento.", "overview", "", "", COMMAND)
	_add("alcance", "Una guía para explorar", NOTICE + " Las explicaciones y ejemplos orientan; no certifican competencias ni sustituyen programas analíticos oficiales.", "overview")
	for program in Catalog.PROGRAMS:
		var pid := str(program["id"])
		_add(pid, str(program["name"]), str(program["summary"]) + " " + str(program["description"]), "overview", pid)
		for mention in Catalog.mentions_for_program(pid):
			var mid := str(mention["id"])
			var scene := str(SCENES[mid])
			_add(pid + "/" + mid, str(mention["name"]), str(mention["focus"]) + " Ejemplo didáctico: " + str(mention["activity"]), scene, pid, mid, 'sis-inf mencion "' + mid + '"')
			for semester in Catalog.semesters_for(pid, mid):
				var sid := "%s/%s/%d" % [pid, mid, int(semester["order"])]
				_add(sid, str(semester["name"]), "Este tramo del plan agrupa %d materias. Las conexiones de la malla representan requisitos; aprobar una materia puede habilitar otras." % semester["subjects"].size(), "curriculum", pid, mid, "sis-inf malla", {"detail": true})
				for subject in semester["subjects"]:
					var code := str(subject["sigla"])
					var context := {"subject": code, "semester": int(semester["order"]), "topics": subject.get("topics", []).duplicate(), "prereq": subject.get("prereq", []).duplicate()}
					_add(sid + "/" + code, code + " · " + str(subject["name"]), str(subject.get("desc", "Descripción pendiente de revisión.")), scene, pid, mid, 'sis-inf explicar "' + code + '"', context)
					_add(sid + "/" + code + "/temas", code + " · Qué explorar", "Temas: " + "; ".join(subject.get("topics", [])) + ". Requisitos en el plan: " + (", ".join(subject.get("prereq", [])) if not subject.get("prereq", []).is_empty() else "sin requisito previo registrado") + ".", "curriculum", pid, mid, 'sis-inf temas "' + code + '"', context)
		_processes(pid)
	_add("cierre", "Volvemos a comenzar", "Terminó el recorrido de Sistemas e Informática. En el modo interactivo puedes crear tu carrera, explorar la facultad y practicar. Esta presentación vuelve al inicio automáticamente.", "overview")
	for chapter in range(chapters.size()):
		if not chapters[chapter].has("subject") and not chapters[chapter].get("detail", false):
			overview.append(chapter)


func _processes(pid: String) -> void:
	var entries := [
		["inscripcion", "Ingreso e inscripción", "En la simulación empiezas con las materias de ingreso. La planificación manual comienza en el segundo periodo; matrícula, comprobantes e historial se representan como documentos simulados."],
		["resultados", "Aprobación, recursado y correlativas", "Cada materia puede aprobarse o reprobarse. En el periodo siguiente se conservan aprobadas, se recursan reprobadas y se consultan desbloqueos. Una correlativa exige llevar su regular; su aprobación se conserva aunque la regular se repruebe."],
		["tramites", "Trámites y cambios de recorrido", "El juego representa materias por carta, materias externas y cambios de carrera o mención como expedientes con pasos y documentos. Los formularios y el orden real de oficinas requieren originales vigentes; aquí son una simulación."],
		["auxiliatura", "Auxiliatura y trabajo con docente", "Aprobar materias permite consultar elegibilidad. En el juego hay postulación, documentos, competencia, resultado y asignación de docente y paralelo. Después se simulan plan firmado, permiso de aula, apoyo e informe."],
		["titulacion", "Egreso y titulación", "En las reglas del juego, excelencia exige todas las materias, ninguna reprobación y promedio mayor de 65. De lo contrario se representa tesis o proyecto de grado con defensa. Egresar y obtener el título son etapas distintas; falta verificar la normativa vigente."]
	]
	for item in entries:
		_add(pid + "/proceso/" + str(item[0]), str(item[1]), str(item[2]), "graduation" if item[0] == "titulacion" else "procedure", pid)


func _add(id: String, title: String, text: String, scene: String, program: String = "", mention: String = "", command: String = "sis-inf continuar", extra: Dictionary = {}) -> void:
	# Bounded cards replace terminal history; no unbounded line buffer or scrolling.
	var remaining := text
	var part := 0
	while not remaining.is_empty():
		var end := mini(190, remaining.length())
		if end < remaining.length():
			var boundary := remaining.rfind(" ", end)
			if boundary > 0:
				end = boundary
		var entry := extra.duplicate(true)
		entry.merge({"id": id + "/" + str(part), "title": title, "text": remaining.left(end).strip_edges(), "scene": scene, "program_id": program, "mention_id": mention, "command": command}, true)
		chapters.append(entry)
		remaining = remaining.substr(end).strip_edges()
		part += 1


func execute(command: String) -> bool:
	if command.strip_edges() != COMMAND:
		return false
	index = 0
	cycle = 1
	set_paused(false)
	_select()
	return true


func _select() -> void:
	elapsed = 0
	phase = "COMMAND"
	chapter_changed.emit(current())


func current() -> Dictionary:
	return chapters[index].duplicate(true)


func set_paused(value: bool) -> void:
	if paused == value:
		return
	paused = value
	if paused:
		var chosen := _pause_random.randi_range(0, PAUSE_ACTORS.size() - 1) if _last_actor < 0 else (_last_actor + _pause_random.randi_range(1, PAUSE_ACTORS.size() - 1)) % PAUSE_ACTORS.size()
		_last_actor = chosen
		pause_actor = PAUSE_ACTORS[chosen].duplicate(true)
		pause_sequence += 1
	pause_changed.emit(pause_cue())


func pause_cue() -> Dictionary:
	return {"version": 1, "paused": paused, "sequence": pause_sequence, "actor": pause_actor.duplicate(true), "facing": "viewer", "action": "idle_wait", "opening": "screen_fracture"}


func next() -> void:
	var position := index + 1 if detailed else overview.find(index) + 1
	var count := chapters.size() if detailed else overview.size()
	if position == count:
		index = 0
		cycle += 1
	else:
		index = position if detailed else overview[position]
	_select()


func previous() -> void:
	index = posmod(index - 1, chapters.size()) if detailed else overview[posmod(overview.find(index) - 1, overview.size())]
	_select()


func toggle_detail() -> void:
	detailed = not detailed
	if not detailed and not overview.has(index):
		var requested := index
		for candidate in overview:
			if candidate > requested:
				break
			index = candidate
	_select()


func position_text() -> String:
	return "Bucle %d · %s %d/%d · %.0fx" % [cycle, "Completo" if detailed else "Resumen", index + 1 if detailed else overview.find(index) + 1, chapters.size() if detailed else overview.size(), speed]


func durations() -> Vector2:
	var entry: Dictionary = chapters[index]
	return Vector2(str(entry["command"]).length() / 28.0, str(entry["text"]).length() / 38.0)


func advance(delta: float) -> void:
	if phase == "IDLE" or paused or not is_finite(delta) or delta <= 0:
		return
	elapsed += minf(delta, 0.25) * speed
	var times := durations()
	if elapsed < times.x:
		phase = "COMMAND"
	elif elapsed < times.x + times.y:
		phase = "EXPLANATION"
	elif elapsed < times.x + times.y + 6:
		phase = "HOLD"
	else:
		next()


func visible_command() -> int:
	return mini(str(chapters[index]["command"]).length(), int(elapsed * 28))


func visible_text() -> int:
	return clampi(int((elapsed - durations().x) * 38), 0, str(chapters[index]["text"]).length())


func progress() -> float:
	var times := durations()
	return clampf(elapsed / (times.x + times.y + 6), 0, 1)
