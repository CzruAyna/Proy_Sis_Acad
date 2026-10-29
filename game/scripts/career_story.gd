extends RefCounted

const Simulation = preload("res://scripts/student_simulation.gd")
const Catalog = preload("res://scripts/catalog.gd")
const Procedures = preload("res://scripts/simulation_procedures.gd")
const MAX_TERMS := 60
const APPROACHES := {
	"constancia": {"name": "Constancia", "description": "Prioriza hábitos de estudio y recuperación de materias.", "bonus": 0.04},
	"colaboracion": {"name": "Colaboración", "description": "Busca apoyo de compañeros y oportunidades de auxiliatura.", "bonus": 0.02},
	"exploracion": {"name": "Exploración", "description": "Prueba correlativas y solicitudes académicas con más frecuencia.", "bonus": 0.0}
}
const EVENTS := [
	{"title": "Un grupo que acompaña", "text": "Organizaste un grupo de repaso: explicar los ejercicios ayudó a ordenar las ideas.", "effect": 0.06},
	{"title": "Semana de entregas", "text": "Coincidieron varias entregas. Tuviste que repartir el tiempo entre práctica y descanso.", "effect": -0.07},
	{"title": "Una consulta a tiempo", "text": "Una consulta al docente aclaró una dificultad que venías arrastrando.", "effect": 0.04},
	{"title": "Imprevistos cotidianos", "text": "Los imprevistos redujeron el tiempo disponible; reajustaste tu rutina de estudio.", "effect": -0.04},
	{"title": "Práctica sostenida", "text": "La rutina de prácticas permitió conectar temas que antes parecían aislados.", "effect": 0.03}
]

var model: RefCounted
var random := RandomNumberGenerator.new()
var chapters: Array[Dictionary] = []
var error := ""
var approach := "constancia"
var favorable := false
var run_seed := 0
var _events: Array = []


func generate(player_name: String, program_id: String, mention_id: String, style: String = "constancia", seed_value: int = -1) -> Dictionary:
	chapters.clear()
	error = ""
	model = null
	if player_name.strip_edges().is_empty():
		return {"ok": false, "message": "Escribe un nombre o apodo para crear la historia."}
	if Catalog.mention_by_id(program_id, mention_id).is_empty() or not APPROACHES.has(style):
		return {"ok": false, "message": "Elige una carrera, mención y enfoque válidos."}
	approach = style
	if seed_value < 0:
		random.randomize()
		run_seed = int(random.randi())
	else:
		run_seed = seed_value
	random.seed = run_seed
	favorable = random.randf() < 0.18
	model = Simulation.new({"player_name": player_name.strip_edges(), "program_id": program_id, "mention_id": mention_id})
	while not model.state["studies_complete"] and int(model.state["term"]) <= MAX_TERMS and error.is_empty():
		_simulate_term()
	if model.state["studies_complete"] and error.is_empty():
		_graduate()
	elif error.is_empty():
		error = "El recorrido alcanzó el límite de 60 periodos. Quedan materias pendientes; no se ha inventado una titulación."
	return {"ok": true, "version": 1, "seed": run_seed, "player_name": player_name.strip_edges(), "program_id": program_id,
		"mention_id": mention_id, "approach": approach, "chapters": chapters.duplicate(true), "complete": bool(model.state["graduated"]),
		"graduation_mode": model.state.get("graduation_mode", ""), "average": model.average(), "had_failure": model.state["had_failure"],
		"terms": int(model.state["term"]) - 1, "message": error, "history": model.state["history"].duplicate(true)}


func _checked(result: Dictionary) -> bool:
	if not result.get("ok", false) and error.is_empty():
		error = str(result.get("message", "No se pudo completar una acción de la demostración."))
	return bool(result.get("ok", false))


func _event(kind: String, text: String, extra: Dictionary = {}) -> void:
	var item := {"kind": kind, "text": text}
	item.merge(extra)
	_events.append(item)


func _process_request(id: String) -> void:
	var request: Dictionary = model.procedure(id)
	for guard in range(24):
		var step := Procedures.current_step(request)
		if step.is_empty() or not error.is_empty():
			return
		for document in step.get("documents", []):
			if document == "historial":
				_checked(model.pay("historial"))
				_checked(model.issue_document("historial"))
			elif document in ["perfil", "borrador", "plan_aux"]:
				_checked(model.issue_document(str(document), id))
			elif document == "solvencia":
				_checked(model.issue_document("solvencia"))
		if step.has("receipt"):
			_checked(model.pay(str(step["receipt"]), "" if step["receipt"] == "matricula" else id))
		if step.get("requires_sessions", false):
			for session in range(3):
				_checked(model.support_session(id, session, true))
			_event("apoyo", "Realizaste tres actividades de apoyo y preparaste el informe para el docente.")
		if step.get("requires_defense", false):
			for attempt in range(5):
				var pass_defense := random.randf() < minf(0.78 + attempt * 0.06, 0.99)
				for partial in range(3):
					_checked(model.defense_answer(id, partial, partial < (3 if pass_defense else 1)))
				_event("defensa", "Defensa aprobada ante el tribunal." if pass_defense else "La defensa requirió correcciones y una nueva presentación.")
				if request["payload"].get("defense_passed", false):
					break
		var result: Dictionary = model.advance_procedure(id, str(step["office"]))
		if not _checked(result):
			return
		_event("tramite", "%s → %s: %s" % [request["name"], step["office"], step["label"]], {"office": step["office"], "documents": step.get("documents", []).duplicate(), "receipt": step.get("receipt", "")})


func _simulate_term() -> void:
	_events = []
	var term := int(model.state["term"])
	if term == 1:
		_event("ingreso", "La historia comienza con el ingreso habilitado y las materias iniciales asignadas. La convocatoria real de admisión y sus requisitos deben consultarse por separado.")
	var circumstance: Dictionary = EVENTS[random.randi_range(0, EVENTS.size() - 1)]
	_event("vida", circumstance["text"], {"title": circumstance["title"], "effect": circumstance["effect"]})
	for request in model.state["procedures"].duplicate():
		if request["kind"] == "matricula" and int(request["term"]) == term:
			_process_request(str(request["id"]))
	if term >= 2:
		_plan_term()
		_assistant()
	if not error.is_empty() or not _checked(model.start_term()):
		return
	var before: Dictionary = model.approved_results().duplicate(true)
	var results: Array = []
	for key in model.state["enrollments"]:
		var subject: Dictionary = model.courses[key]
		var attempts := 0
		for record in model.state["history"]:
			if record["course_id"] == key:
				attempts += 1
		var chance := 0.988 + float(APPROACHES[approach]["bonus"]) * 0.15 + float(circumstance["effect"]) * 0.05 if favorable else 0.83 + float(APPROACHES[approach]["bonus"]) + float(circumstance["effect"]) + minf(attempts * 0.07, 0.12)
		chance = clampf(chance, 0.65, 0.997)
		var passed := random.randf() < chance
		var successes := (3 if random.randf() < 0.65 else 2) if passed else random.randi_range(0, 1)
		var answers := [false, false, false]
		for index in range(successes):
			answers[index] = true
		for index in range(2, 0, -1):
			var swap := random.randi_range(0, index)
			var previous: bool = answers[index]
			answers[index] = answers[swap]
			answers[swap] = previous
		for partial in range(3):
			_checked(model.answer(key, partial, bool(answers[partial])))
		results.append({"course_id": key, "sigla": subject["sigla"], "name": subject["name"], "semester": subject["semester"],
			"score": model.state["enrollments"][key]["score"], "passed": passed, "retake": attempts > 0,
			"origin": model.state["enrollments"][key]["origin"], "topics": subject.get("topics", []).duplicate(),
			"description": subject.get("desc", ""), "chance": chance})
	if not _checked(model.close_term()):
		return
	var states := _states(results)
	var unlocked: Array = []
	for key in model.curriculum():
		if model.eligibility(key, false)["ok"]:
			unlocked.append(str(model.courses[key]["sigla"]))
	var passed_count := 0
	var recovered := 0
	for item in results:
		if item["passed"]:
			passed_count += 1
			if item["retake"]:
				recovered += 1
	var title := "Primeros pasos" if term == 1 else ("Volver a levantarse" if recovered > 0 else ("Un periodo de avances" if passed_count == results.size() else "Aprender y reorganizarse"))
	var story := "%s, en el periodo %d aprobaste %d de %d materias." % [model.profile["player_name"], term, passed_count, results.size()]
	if recovered > 0:
		story += " Recuperaste %d materia(s) pendiente(s): el nuevo intento queda junto al anterior en tu historial." % recovered
	if passed_count < results.size():
		story += " Las reprobadas serán prioritarias en tu próxima inscripción; la vía de excelencia queda descartada."
	else:
		story += " Consolidaste estas materias y abriste nuevas conexiones en la malla."
	chapters.append({"kind": "term", "term": term, "title": title, "story": story, "events": _events.duplicate(true), "results": results,
		"states": states, "unlocked": unlocked, "passed": passed_count, "failed": results.size() - passed_count,
		"average": model.average(), "approved_before": before.size(), "approved_total": model.approved_results().size()})


func _plan_term() -> void:
	_event("planificacion", "Planificaste el periodo: las materias reprobadas conservan prioridad y las nuevas dependen de sus regulares.")
	if approach != "exploracion":
		return
	for key in model.curriculum():
		if model.state["enrollments"].has(key):
			continue
		var eligible: Dictionary = model.eligibility(key)
		if eligible["ok"] and not eligible.get("regulars", []).is_empty():
			var result: Dictionary = model.enroll(key)
			if result["ok"]:
				_event("correlativa", "Inscribiste %s junto a sus regulares obligatorias. Cada resultado será independiente." % model.courses[key]["sigla"])
				break
	if int(model.state["term"]) == 3:
		for key in model.curriculum():
			if not model.is_approved(key) and not model.state["enrollments"].has(key):
				var opened: Dictionary = model.open_procedure("carta", {"course_id": key, "reason": "Explorar una materia del plan en este recorrido demostrativo."})
				if opened["ok"]:
					_process_request(str(opened["request_id"]))
					var enrolled: Dictionary = model.enroll(key)
					_event("carta", "Permiso por carta registrado para %s. %s" % [model.courses[key]["sigla"], "Se incorporó al periodo." if enrolled["ok"] else "La carga máxima impidió incorporarla; el permiso no reemplaza el cupo."])
				break


func _assistant() -> void:
	if random.randf() > (0.75 if approach == "colaboracion" else 0.25):
		return
	for key in model.curriculum():
		if not model.assistant_eligibility(key)["ok"]:
			continue
		var application: Dictionary = model.apply_assistant(key)
		if not _checked(application):
			return
		_process_request(str(application["request_id"]))
		var good := random.randf() < 0.72
		var outcome := {}
		for partial in range(3):
			outcome = model.assistant_answer(str(application["application_id"]), partial, partial < (3 if good else 1))
			_checked(outcome)
		var competition: Dictionary = model._application(str(application["application_id"]))
		_event("competencia", "Competiste por la auxiliatura de %s: nota %.2f, puesto %d, resultado %s." % [model.courses[key]["sigla"], competition["score"], competition["ranking"], competition["status"]], {"candidates": competition["candidates"].duplicate(true)})
		if outcome.get("selected", false):
			var assignment: Dictionary = model.state["assignments"][-1]
			_event("designacion", "Asignación al paralelo %s con %s. Preparaste plan, firma, aula e informe." % [assignment["parallel"], assignment["teacher"]])
			_process_request(str(outcome["request_id"]))
		return


func _states(results: Array) -> Dictionary:
	var states := {}
	for key in model.curriculum():
		states[str(model.courses[key]["sigla"])] = "Aprobada" if model.is_approved(key) else ("Disponible" if model.eligibility(key, false)["ok"] else "Bloqueada")
	for item in results:
		if not item["passed"]:
			states[str(item["sigla"])] = "Reprobada · recursar"
	for key in model.retakes():
		states[str(model.courses[key]["sigla"])] = "Reprobada · recursar"
	return states


func _graduate() -> void:
	_events = []
	var mode := "excelencia" if model.excellence()["ok"] else ("tesis" if random.randf() < 0.5 else "proyecto")
	var request: Dictionary = model.open_procedure(mode)
	if not _checked(request):
		return
	_process_request(str(request["request_id"]))
	var story := "%s concluyó las materias y completó la titulación por %s." % [model.profile["player_name"], mode]
	story += " No hubo reprobaciones y el promedio fue mayor que 65: no se exigió defensa." if mode == "excelencia" else " Preparó perfil y borrador con tutor, presentó la defensa y tramitó diploma y título."
	chapters.append({"kind": "graduation", "term": int(model.state["term"]) - 1, "title": "De las aulas al título", "story": story,
		"events": _events.duplicate(true), "results": [], "states": _states([]), "unlocked": [], "average": model.average()})
