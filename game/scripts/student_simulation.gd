extends RefCounted

const Catalog = preload("res://scripts/catalog.gd")
const Procedures = preload("res://scripts/simulation_procedures.gd")
const VERSION := 2
const PASS_MARK := 51.0
const EXCELLENCE_THRESHOLD := 65.0
const MAX_APPLICATIONS := 3

var profile: Dictionary
var state: Dictionary
var courses: Dictionary = {}
var plans: Dictionary = {}
var _approved: Dictionary = {}
var _failed: Dictionary = {}


static func validate_profile(saved: Dictionary) -> Dictionary:
	var program := str(saved.get("program_id", ""))
	var mention := str(saved.get("mention_id", ""))
	if Catalog.mention_by_id(program, mention).is_empty():
		return {"ok": false, "message": "La carrera o mención guardada no está disponible en esta versión."}
	for key in ["passed_subjects", "failed_subjects", "chanchullo_used"]:
		if saved.has(key) and not saved[key] is Array:
			return {"ok": false, "message": "El archivo tiene un historial antiguo inválido."}
	if not saved.has("simulation"):
		return {"ok": true}
	var data: Variant = saved["simulation"]
	if not data is Dictionary or int(data.get("version", 0)) != VERSION:
		return {"ok": false, "message": "El formato de simulación no es compatible; se conserva el archivo sin convertirlo."}
	for key in ["history", "procedures", "permissions", "applications", "assignments", "plan_changes", "benefits"]:
		if not data.get(key) is Array:
			return {"ok": false, "message": "Falta una colección del expediente: " + key}
		for item in data[key]:
			if not item is Dictionary:
				return {"ok": false, "message": "El expediente contiene un registro inválido: " + key}
	for key in ["enrollments", "documents", "receipts"]:
		if not data.get(key) is Dictionary:
			return {"ok": false, "message": "Falta el registro de " + key}
	for key in ["had_failure", "legacy_incomplete", "studies_complete", "graduated", "unlocked_all"]:
		if not data.get(key) is bool:
			return {"ok": false, "message": "Falta un estado de la simulación: " + key}
	if int(data.get("term", 0)) < 1 or int(data.get("next_id", 0)) < 1 or not ["INSCRIPCION", "CURSANDO", "TITULADO"].has(data.get("phase")):
		return {"ok": false, "message": "El semestre o la fase guardados no son válidos."}
	for record in data["history"]:
		if not record.get("course_id") is String or not record.get("passed") is bool or not record.has("score") or not record.has("term"):
			return {"ok": false, "message": "El historial académico contiene un resultado incompleto."}
	for key in data["enrollments"]:
		var parts := str(key).split("/")
		var entry: Variant = data["enrollments"][key]
		if parts.size() != 3 or Catalog.subject_by_sigla(parts[0], parts[2], parts[1]).is_empty():
			return {"ok": false, "message": "Una materia inscrita no existe en el catálogo actual."}
		if not entry is Dictionary or not entry.get("answers") is Array or not entry.get("regulars") is Array or not entry.has("score") or not entry.has("origin") or entry["answers"].size() > 3:
			return {"ok": false, "message": "Una inscripción guardada está incompleta."}
	for request in data["procedures"]:
		if not request.get("steps") is Array or not request.get("payload") is Dictionary or not request.get("events") is Array or not request.has("kind") or not request.has("id") or not request.has("status") or not request.has("step") or not request.has("term"):
			return {"ok": false, "message": "Un trámite guardado está incompleto."}
	return {"ok": true}


func _init(saved_profile: Dictionary, fixture_courses: Array = []) -> void:
	profile = saved_profile
	_build_catalog(fixture_courses)
	if profile.get("simulation") is Dictionary and int(profile["simulation"].get("version", 0)) == VERSION:
		state = profile["simulation"]
		_refresh_indexes()
	else:
		_create_state()
	profile["mode"] = "solo"
	profile["role_id"] = "estudiante"
	_sync_profile()


func _build_catalog(fixtures: Array) -> void:
	var rows := fixtures.duplicate(true)
	if rows.is_empty():
		for program in Catalog.PROGRAMS:
			for mention in program.get("mentions", []):
				for subject in Catalog.all_subjects(str(program["id"]), str(mention["id"])):
					subject["program_id"] = program["id"]
					subject["mention_id"] = mention["id"]
					rows.append(subject)
	for row in rows:
		var subject: Dictionary = row.duplicate(true)
		var plan := "%s/%s" % [subject["program_id"], subject["mention_id"]]
		var key := "%s/%s" % [plan, subject["sigla"]]
		subject["id"] = key
		subject["graduation_node"] = str(subject["sigla"]) == "SIS 5100"
		courses[key] = subject
		if not plans.has(plan):
			plans[plan] = []
		if not subject["graduation_node"]:
			plans[plan].append(key)


func _create_state() -> void:
	state = {"version": VERSION, "term": 1, "phase": "INSCRIPCION", "history": [],
		"enrollments": {}, "procedures": [], "documents": {}, "receipts": {},
		"permissions": [], "applications": [], "assignments": [], "plan_changes": [],
		"unlocked_all": false, "had_failure": false, "legacy_incomplete": false,
		"studies_complete": false, "graduated": false, "next_id": 1, "benefits": []}
	var old_passed: Array = profile.get("passed_subjects", [])
	var old_failed: Array = profile.get("failed_subjects", [])
	for sigla in old_passed:
		var key := resolve_course(str(sigla))
		if not key.is_empty():
			state["history"].append(_legacy_result(key, true))
	for sigla in old_failed:
		var key := resolve_course(str(sigla))
		if not key.is_empty():
			state["history"].append(_legacy_result(key, false))
	state["legacy_incomplete"] = not old_passed.is_empty() or not old_failed.is_empty() or bool(profile.get("career_complete", false))
	state["had_failure"] = not old_failed.is_empty()
	profile["simulation"] = state
	_refresh_indexes()
	_put_document("ci", "", false)
	_update_completion()
	if not state["studies_complete"]:
		_auto_enroll()
		_new_procedure("matricula", {})


func _legacy_result(key: String, passed: bool) -> Dictionary:
	return {"course_id": key, "term": 0, "passed": passed, "score": null,
		"origin": "LEGADO", "program_id": profile.get("program_id", ""),
		"mention_id": profile.get("mention_id", ""), "credits": 1.0}


func plan_id() -> String:
	return "%s/%s" % [profile.get("program_id", ""), profile.get("mention_id", "")]


func curriculum() -> Array:
	return plans.get(plan_id(), []).duplicate()


func resolve_course(value: String) -> String:
	if courses.has(value):
		return value
	var key := "%s/%s" % [plan_id(), value.strip_edges().to_upper()]
	return key if courses.has(key) else ""


func course_data(value: String) -> Dictionary:
	return courses.get(resolve_course(value), {}).duplicate(true)


func _identity(key: String) -> String:
	var course: Dictionary = courses.get(key, {})
	return "%s|%s" % [course.get("sigla", key), str(course.get("name", key)).strip_edges().to_upper()]


func _refresh_indexes() -> void:
	_approved.clear()
	_failed.clear()
	for record in state["history"]:
		if bool(record["passed"]):
			_approved[_identity(str(record["course_id"]))] = record
		else:
			_failed[_identity(str(record["course_id"]))] = true
			state["had_failure"] = true


func approved_results() -> Dictionary:
	return _approved.duplicate(true)


func is_approved(key: String) -> bool:
	return _approved.has(_identity(key))


func retakes() -> Array:
	var result := []
	for key in curriculum():
		if _failed.has(_identity(key)) and not is_approved(key):
			result.append(key)
	return result


func average(previous_term: bool = false) -> Variant:
	var total := 0.0
	var weights := 0.0
	var results: Array = state["history"] if previous_term else approved_results().values()
	var identities := {}
	for key in curriculum():
		identities[_identity(key)] = true
	for record in results:
		if previous_term and int(record["term"]) != int(state["term"]) - 1:
			continue
		if not previous_term and not identities.has(_identity(str(record["course_id"]))):
			continue
		if record.get("score") == null:
			if not previous_term:
				return null
			continue
		var weight := float(record.get("credits", 1.0))
		total += float(record["score"]) * weight
		weights += weight
	return total / weights if weights > 0.0 else null


func load_limit() -> int:
	var prior: Variant = average(true)
	return 7 if prior != null and float(prior) >= 65.0 else 6


func _has_permission(key: String) -> bool:
	for permit in state["permissions"]:
		if permit["course_id"] == key and int(permit["term"]) == int(state["term"]):
			return true
	return false


func eligibility(value: String, allow_concurrent: bool = true) -> Dictionary:
	var key := resolve_course(value)
	return _eligibility(key, allow_concurrent, [])


func _eligibility(key: String, allow_concurrent: bool, visiting: Array) -> Dictionary:
	if key.is_empty() or bool(courses[key].get("graduation_node", false)):
		return _error("La materia no existe en el catálogo de cursado.")
	if visiting.has(key):
		return _error("La malla contiene un ciclo de requisitos que necesita revisión.")
	if is_approved(key):
		return _error("La materia ya está aprobada.")
	if bool(state["graduated"]) or bool(state["studies_complete"]):
		return _error("El plan ya está concluido.")
	var subject: Dictionary = courses[key]
	var external := not curriculum().has(key)
	if external and not _has_permission(key):
		return _error("Necesitas autorización de materia de otra carrera o mención.")
	if bool(state["unlocked_all"]) and not external:
		return _ok("Materia desbloqueada para exploración.", {"regulars": [], "origin": "EXPLORACION"})
	if _has_permission(key):
		return _ok("Permiso vigente para este semestre.", {"regulars": [], "origin": "CARTA"})
	var requirements: Array = Array(subject.get("prereq", []))
	if requirements.is_empty() and int(subject.get("semester", 1)) > int(state["term"]):
		return _error("Esta electiva se habilita desde su semestre sugerido.")
	var regulars := []
	var path := visiting.duplicate()
	path.append(key)
	for requirement in requirements:
		if str(requirement) == "INGRESO":
			continue
		var regular := "%s/%s/%s" % [subject["program_id"], subject["mention_id"], requirement]
		if not courses.has(regular):
			return _error("Falta definir el requisito %s en la malla." % requirement)
		if is_approved(regular):
			continue
		if not allow_concurrent or not bool(subject.get("allow_concurrent", true)):
			return _error("Falta aprobar la regular %s." % requirement)
		var regular_eligibility := _eligibility(regular, true, path)
		if not regular_eligibility["ok"]:
			return regular_eligibility
		for dependency in regular_eligibility.get("regulars", []):
			if not regulars.has(dependency):
				regulars.append(dependency)
		if not regulars.has(regular):
			regulars.append(regular)
	return _ok("Habilitada con regular obligatoria." if not regulars.is_empty() else "Habilitada.", {"regulars": regulars, "origin": "CORRELATIVA" if not regulars.is_empty() else "ORDINARIA"})


func enroll(value: String) -> Dictionary:
	if state["phase"] != "INSCRIPCION":
		return _error("Las inscripciones se modifican antes de iniciar el semestre.")
	var key := resolve_course(value)
	var check := eligibility(key)
	if not check["ok"]:
		return check
	var bundle: Array = check.get("regulars", []).duplicate()
	if not bundle.has(key):
		bundle.append(key)
	var missing := 0
	for course_id in bundle:
		if not state["enrollments"].has(course_id):
			missing += 1
	if state["enrollments"].size() + missing > load_limit():
		return _error("La materia y sus regulares superan el límite de %d materias." % load_limit())
	for course_id in bundle:
		if not state["enrollments"].has(course_id):
			var course_check := eligibility(str(course_id))
			state["enrollments"][course_id] = {"answers": [], "score": null, "regulars": course_check.get("regulars", []), "origin": course_check.get("origin", "ORDINARIA")}
	_sync_profile()
	return _ok("Inscripción registrada; las regulares pendientes quedan incluidas.")


func withdraw(value: String) -> Dictionary:
	if state["phase"] != "INSCRIPCION":
		return _error("El semestre ya comenzó.")
	var key := resolve_course(value)
	if not state["enrollments"].has(key):
		return _error("No existe esa inscripción.")
	if retakes().slice(0, load_limit()).has(key):
		return _error("Debes recursar esta materia reprobada.")
	for other in state["enrollments"]:
		if other != key and state["enrollments"][other]["regulars"].has(key):
			return _error("La regular es obligatoria mientras curses %s." % courses[other]["sigla"])
	state["enrollments"].erase(key)
	_sync_profile()
	return _ok("Inscripción retirada.")


func _auto_enroll() -> void:
	state["enrollments"] = {}
	for key in retakes().slice(0, load_limit()):
		enroll(key)
	for key in curriculum():
		if state["enrollments"].size() >= load_limit():
			break
		if eligibility(key, false)["ok"]:
			enroll(key)


func start_term() -> Dictionary:
	if state["phase"] != "INSCRIPCION" or state["enrollments"].is_empty():
		return _error("Necesitas materias inscritas en un semestre pendiente de inicio.")
	if not _valid_document("matricula", ""):
		return _error("Completa primero el trámite de matrícula de este semestre.")
	for key in retakes().slice(0, load_limit()):
		if not state["enrollments"].has(key):
			return _error("Falta inscribir una materia reprobada obligatoria.")
	for key in state["enrollments"]:
		var check := eligibility(key)
		if not check["ok"]:
			return check
		for regular in check.get("regulars", []):
			if not state["enrollments"].has(regular):
				return _error("Falta inscribir la regular obligatoria.")
	state["phase"] = "CURSANDO"
	return _ok("Semestre iniciado. Cada materia tendrá tres parciales y un resultado independiente.")


func answer(value: String, expected_partial: int, correct: bool) -> Dictionary:
	var key := resolve_course(value)
	if state["phase"] != "CURSANDO" or not state["enrollments"].has(key):
		return _error("La materia no está cursándose.")
	var entry: Dictionary = state["enrollments"][key]
	if entry["answers"].size() != expected_partial or expected_partial >= 3:
		return _error("Este parcial ya fue registrado o está fuera de secuencia.")
	entry["answers"].append(100.0 if correct else 0.0)
	if entry["answers"].size() == 3:
		entry["score"] = (float(entry["answers"][0]) + float(entry["answers"][1]) + float(entry["answers"][2])) / 3.0
	_sync_profile()
	return _ok("Parcial registrado.", {"finished": entry["score"] != null, "score": entry["score"], "passed": entry["score"] != null and float(entry["score"]) >= PASS_MARK})


func close_term() -> Dictionary:
	if state["phase"] != "CURSANDO":
		return _error("No hay un semestre cursándose.")
	for key in state["enrollments"]:
		if state["enrollments"][key]["score"] == null:
			return _error("Todavía faltan resultados: %s." % courses[key]["sigla"])
	var passed := 0
	var failed := 0
	for key in state["enrollments"]:
		var entry: Dictionary = state["enrollments"][key]
		var approved := float(entry["score"]) >= PASS_MARK
		state["history"].append({"course_id": key, "term": state["term"], "score": entry["score"], "passed": approved, "origin": entry["origin"], "program_id": profile["program_id"], "mention_id": profile["mention_id"], "credits": float(courses[key].get("credits", 1.0))})
		if approved:
			passed += 1
		else:
			failed += 1
			state["had_failure"] = true
	state["term"] = int(state["term"]) + 1
	state["phase"] = "INSCRIPCION"
	state["enrollments"] = {}
	_refresh_indexes()
	_expire_term_activities()
	_update_completion()
	if not state["studies_complete"]:
		_auto_enroll()
		_new_procedure("matricula", {})
	_sync_profile()
	return _ok("Semestre cerrado: %d aprobadas y %d reprobadas. El historial conserva todos los intentos." % [passed, failed])


func _update_completion() -> void:
	var ids := curriculum()
	var complete := not ids.is_empty()
	for key in ids:
		if not is_approved(key):
			complete = false
	state["studies_complete"] = complete
	if complete:
		_put_document("conclusion", "", false)


func excellence() -> Dictionary:
	if not state["studies_complete"]:
		return _error("Falta concluir el plan de estudios.")
	if state["had_failure"]:
		return _error("Una reprobación de materia exige tesis o proyecto, aunque después la apruebes.")
	if state["legacy_incomplete"]:
		return _error("La partida antigua no conserva el historial completo necesario para acreditar excelencia.")
	var value: Variant = average()
	if value == null or float(value) <= EXCELLENCE_THRESHOLD:
		return _error("La excelencia requiere promedio estrictamente mayor que 65.")
	return _ok("Habilitada la graduación por excelencia sin defensa.", {"average": value})


func _sync_profile() -> void:
	var passed := []
	var failed := []
	for key in curriculum():
		if is_approved(key):
			passed.append(courses[key]["sigla"])
	for key in retakes():
		failed.append(courses[key]["sigla"])
	profile["passed_subjects"] = passed
	profile["failed_subjects"] = failed
	profile["completed_subjects"] = passed.size()
	profile["career_complete"] = bool(state["graduated"])
	var progress := {}
	for key in state["enrollments"]:
		var entry: Dictionary = state["enrollments"][key]
		progress[courses[key]["sigla"]] = {"partial": entry["answers"].size(), "complete": entry["score"] != null}
	profile["subject_progress"] = progress
	profile["simulation"] = state


func _receipt_key(concept: String, request_id: String) -> String:
	return "%s@%s" % [concept, request_id if not request_id.is_empty() else "semestre:%d" % int(state["term"])]


func pay(concept: String, request_id: String = "") -> Dictionary:
	if not ["matricula", "historial", "auxiliatura", "defensa", "titulo"].has(concept):
		return _error("Concepto de pago desconocido.")
	if ["auxiliatura", "defensa", "titulo"].has(concept):
		var request := procedure(request_id)
		if request.is_empty() or not ["PENDIENTE", "OBSERVADO"].has(request["status"]):
			return _error("Indica un trámite pendiente para este comprobante.")
		if concept == "auxiliatura" and request["kind"] != "auxiliatura":
			return _error("El comprobante no corresponde a ese trámite.")
		if concept == "defensa" and not ["tesis", "proyecto"].has(request["kind"]):
			return _error("Este trámite no requiere defensa.")
		if concept == "titulo" and not ["tesis", "proyecto", "excelencia"].has(request["kind"]):
			return _error("Este trámite no corresponde a titulación.")
	var key := _receipt_key(concept, request_id)
	if state["receipts"].has(key):
		return _ok("El comprobante ya está registrado.")
	state["receipts"][key] = {"id": "REC-%03d" % state["next_id"], "concept": concept, "term": state["term"], "request_id": request_id, "simulated": true}
	state["next_id"] = int(state["next_id"]) + 1
	return _ok("Pago simulado registrado. Se conserva su comprobante.")


func _document_key(kind: String, request_id: String) -> String:
	return "%s@%s" % [kind, request_id] if not request_id.is_empty() else kind


func _put_document(kind: String, request_id: String, term_specific: bool = true) -> void:
	state["documents"][_document_key(kind, request_id)] = {"kind": kind, "request_id": request_id, "term": state["term"], "term_specific": term_specific, "history_size": state["history"].size(), "program_id": profile.get("program_id", ""), "mention_id": profile.get("mention_id", ""), "simulated": true}


func _valid_document(kind: String, request_id: String) -> bool:
	var scoped := ["formulario", "plan_aux", "plan_firmado", "permiso_aula", "informe_aux", "perfil", "borrador", "acta_defensa", "diploma", "titulo"].has(kind)
	var doc: Dictionary = state["documents"].get(_document_key(kind, request_id if scoped else ""), {})
	if doc.is_empty():
		return false
	if bool(doc["term_specific"]) and int(doc["term"]) != int(state["term"]):
		return false
	if kind == "historial" and int(doc["history_size"]) != state["history"].size():
		return false
	return true


func issue_document(kind: String, request_id: String = "") -> Dictionary:
	if kind == "historial":
		if not state["receipts"].has(_receipt_key("historial", "")):
			return _error("Primero registra el pago simulado del historial.")
	elif kind == "solvencia":
		if not state["studies_complete"]:
			return _error("La solvencia final se tramita tras concluir estudios.")
	elif ["perfil", "borrador", "plan_aux"].has(kind):
		var request := procedure(request_id)
		if request.is_empty() or not ["PENDIENTE", "OBSERVADO"].has(request["status"]):
			return _error("Indica el trámite pendiente al que pertenece el documento.")
		if kind == "plan_aux" and request["kind"] != "trabajo_auxiliar":
			return _error("El plan de auxiliatura necesita su trámite de trabajo.")
		if kind != "plan_aux" and not ["tesis", "proyecto"].has(request["kind"]):
			return _error("El documento necesita un trámite de tesis o proyecto.")
	else:
		return _error("Ese documento se emite al completar su trámite.")
	_put_document(kind, request_id if ["perfil", "borrador", "plan_aux"].has(kind) else "", kind == "historial" or kind == "plan_aux")
	return _ok("Documento preparado: %s." % kind)


func _new_procedure(kind: String, payload: Dictionary) -> Dictionary:
	var definition := Procedures.definition(kind)
	var id := "TR-%03d" % int(state["next_id"])
	state["next_id"] = int(state["next_id"]) + 1
	var request := {"id": id, "kind": kind, "name": definition.get("name", kind), "steps": definition.get("steps", []), "step": 0, "status": "PENDIENTE", "term": state["term"], "payload": payload.duplicate(true), "events": [], "simulated": definition.get("simulated", false)}
	state["procedures"].append(request)
	_put_document("formulario", id)
	return request


func procedure(id: String) -> Dictionary:
	for request in state["procedures"]:
		if request["id"] == id:
			return request
	return {}


func open_procedure(kind: String, payload: Dictionary = {}) -> Dictionary:
	if Procedures.definition(kind).is_empty() or ["trabajo_auxiliar", "auxiliatura"].has(kind):
		return _error("Tipo de trámite no disponible por esta vía.")
	if state["graduated"]:
		return _error("La carrera ya está titulada.")
	if ["carta", "otra_carrera", "mencion", "carrera"].has(kind) and state["phase"] != "INSCRIPCION":
		return _error("Este trámite se completa antes de comenzar el semestre.")
	if ["carta", "otra_carrera"].has(kind):
		var key := resolve_course(str(payload.get("course_id", "")))
		if key.is_empty() or bool(courses[key]["graduation_node"]) or is_approved(key):
			return _error("Selecciona una materia pendiente válida.")
		if str(payload.get("reason", "")).strip_edges().length() < 10:
			return _error("Justifica la solicitud con al menos diez caracteres.")
		if (kind == "carta") != curriculum().has(key):
			return _error("Usa carta para tu plan y otra_carrera para materias externas.")
		payload = payload.duplicate(true)
		payload["course_id"] = key
		payload["source_plan"] = plan_id()
	if ["mencion", "carrera"].has(kind):
		var target := "%s/%s" % [payload.get("program_id", profile["program_id"]), payload.get("mention_id", "")]
		if not plans.has(target) or target == plan_id():
			return _error("Selecciona una carrera y mención de destino válidas y diferentes.")
		if kind == "mencion" and str(payload.get("program_id", profile["program_id"])) != str(profile["program_id"]):
			return _error("El K-02 cambia la mención dentro de la misma carrera.")
		if kind == "carrera" and str(payload.get("program_id", "")) == str(profile["program_id"]):
			return _error("Para cambiar solo la mención utiliza K-02.")
		payload = payload.duplicate(true)
		payload["source_plan"] = plan_id()
	if ["excelencia", "tesis", "proyecto"].has(kind):
		if not state["studies_complete"]:
			return _error("Primero debes concluir el plan de estudios.")
		if kind == "excelencia" and not excellence()["ok"]:
			return excellence()
		payload = payload.duplicate(true)
		payload["plan_id"] = plan_id()
	for existing in state["procedures"]:
		if not ["PENDIENTE", "OBSERVADO"].has(existing["status"]):
			continue
		if existing["kind"] == kind and existing["payload"] == payload:
			return _ok("Ya existe ese trámite pendiente.", {"request_id": existing["id"]})
		if ["excelencia", "tesis", "proyecto"].has(kind) and ["excelencia", "tesis", "proyecto"].has(existing["kind"]):
			return _error("Ya existe una modalidad de graduación en trámite.")
		if ["mencion", "carrera"].has(kind) and ["excelencia", "tesis", "proyecto"].has(existing["kind"]):
			return _error("Cancela primero la graduación pendiente antes de cambiar de plan.")
	var request := _new_procedure(kind, payload)
	return _ok("Trámite abierto: %s · %s." % [request["id"], request["name"]], {"request_id": request["id"]})


func advance_procedure(id: String, office: String) -> Dictionary:
	var request := procedure(id)
	var step := Procedures.current_step(request)
	if step.is_empty() or step["office"] != office:
		return _error("El trámite no está pendiente en esa oficina.")
	var kind := str(request["kind"])
	if ["matricula", "carta", "otra_carrera", "mencion", "carrera", "auxiliatura", "trabajo_auxiliar"].has(kind) and int(request["term"]) != int(state["term"]):
		return _error("El trámite ya no pertenece al semestre actual.")
	if ["carta", "otra_carrera", "mencion", "carrera"].has(kind) and state["phase"] != "INSCRIPCION":
		return _error("El cambio debe registrarse antes de iniciar el semestre.")
	if ["mencion", "carrera", "carta", "otra_carrera"].has(kind) and request["payload"]["source_plan"] != plan_id():
		return _error("El plan de origen cambió; debes presentar una nueva solicitud.")
	if ["excelencia", "tesis", "proyecto"].has(kind) and (request["payload"]["plan_id"] != plan_id() or not state["studies_complete"]):
		return _error("Esta graduación corresponde a otro plan o todavía faltan materias.")
	if ["mencion", "carrera"].has(kind):
		for other in state["procedures"]:
			if ["PENDIENTE", "OBSERVADO"].has(other["status"]) and ["excelencia", "tesis", "proyecto"].has(other["kind"]):
				return _error("Cancela primero la graduación pendiente antes de cambiar de plan.")
	if kind == "excelencia" and not excellence()["ok"]:
		return excellence()
	for doc in step.get("documents", []):
		if not _valid_document(str(doc), id):
			return _observe(request, "Falta documento vigente: %s." % doc)
	if step.has("receipt"):
		var scope := "" if step["receipt"] == "matricula" else id
		if not state["receipts"].has(_receipt_key(str(step["receipt"]), scope)):
			return _observe(request, "Falta comprobante: /pagar %s%s." % [step["receipt"], " " + scope if not scope.is_empty() else ""])
	if step.get("requires_sessions", false) and int(request["payload"].get("sessions", 0)) < 3:
		return _error("Realiza tres actividades de apoyo antes de cerrar esta etapa.")
	if step.get("requires_defense", false) and not bool(request["payload"].get("defense_passed", false)):
		return _error("Debes aprobar la defensa con el tribunal.")
	if step.has("output"):
		var output := str(step["output"])
		_put_document(output, "" if output == "matricula" else id, ["matricula", "plan_firmado", "permiso_aula", "informe_aux"].has(output))
		if output == "matricula":
			_put_document("carnet", "", false)
	request["events"].append({"step": request["step"], "office": office, "term": state["term"], "action": step["label"]})
	request["status"] = "PENDIENTE"
	request["step"] = int(request["step"]) + 1
	if int(request["step"]) == request["steps"].size():
		request["status"] = "COMPLETADO"
		_complete_procedure(request)
	_sync_profile()
	return _ok("%s: %s." % [office, step["label"]], {"status": request["status"]})


func _complete_procedure(request: Dictionary) -> void:
	var kind := str(request["kind"])
	var payload: Dictionary = request["payload"]
	if ["carta", "otra_carrera"].has(kind):
		state["permissions"].append({"course_id": payload["course_id"], "term": state["term"], "request_id": request["id"], "reason": payload["reason"]})
	elif ["mencion", "carrera"].has(kind):
		state["plan_changes"].append({"from": plan_id(), "to": "%s/%s" % [payload.get("program_id", profile["program_id"]), payload["mention_id"]], "term": state["term"], "request_id": request["id"]})
		profile["program_id"] = payload.get("program_id", profile["program_id"])
		profile["mention_id"] = payload["mention_id"]
		profile["mention_name"] = Catalog.mention_by_id(str(profile["program_id"]), str(profile["mention_id"])).get("name", profile["mention_id"])
		state["graduated"] = false
		_update_completion()
		_auto_enroll()
	elif kind == "auxiliatura":
		_application(str(payload["application_id"]))["status"] = "HABILITADA"
	elif kind == "trabajo_auxiliar":
		_assignment(str(payload["assignment_id"]))["status"] = "CUMPLIDA"
		state["benefits"].append({"assignment_id": payload["assignment_id"], "term": state["term"], "concept": "Beneficio de auxiliatura", "simulated": true})
	elif ["excelencia", "tesis", "proyecto"].has(kind):
		state["graduated"] = true
		state["phase"] = "TITULADO"
		state["graduation_mode"] = kind


func _expire_term_activities() -> void:
	for request in state["procedures"]:
		if ["PENDIENTE", "OBSERVADO"].has(request["status"]) and not ["excelencia", "tesis", "proyecto"].has(request["kind"]):
			request["status"] = "VENCIDO"
	for application in state["applications"]:
		if ["POSTULADA", "HABILITADA"].has(application["status"]):
			application["status"] = "VENCIDA"
	for assignment in state["assignments"]:
		if assignment["status"] == "ASIGNADA":
			assignment["status"] = "INCOMPLETA"


func assistant_eligibility(value: String) -> Dictionary:
	var key := resolve_course(value)
	if not curriculum().has(key) or not is_approved(key):
		return _error("Debes aprobar la materia a la que postulas.")
	if bool(courses[key].get("assistant_available", true)) == false:
		return _error("Esta materia no tiene convocatoria de auxiliatura.")
	var previous_pass := false
	for record in state["history"]:
		if int(record["term"]) == int(state["term"]) - 1 and bool(record["passed"]):
			previous_pass = true
	if not previous_pass:
		return _error("Debes tener al menos una materia aprobada en el semestre anterior.")
	if not _valid_document("matricula", ""):
		return _error("Necesitas matrícula vigente para postular.")
	return _ok("Puedes postular a esta materia.")


func apply_assistant(value: String) -> Dictionary:
	var key := resolve_course(value)
	var check := assistant_eligibility(key)
	if not check["ok"]:
		return check
	var active := 0
	for application in state["applications"]:
		if int(application["term"]) == int(state["term"]):
			if application["course_id"] == key:
				return _error("Ya postulaste a esta convocatoria; el resultado se conserva.")
			if ["POSTULADA", "HABILITADA", "SELECCIONADA"].has(application["status"]):
				active += 1
	if active >= MAX_APPLICATIONS:
		return _error("Solo puedes mantener tres postulaciones activas.")
	var seed_value := absi(hash("%s@%d" % [key, int(state["term"])]))
	var candidates := [{"name": "Postulante simulado 1", "score": float(65 + seed_value % 26), "subject_mark": float(60 + seed_value % 31)}, {"name": "Postulante simulado 2", "score": float(40 + (seed_value >> 5) % 31), "subject_mark": float(51 + (seed_value >> 3) % 40)}]
	var application := {"id": "AUX-%03d" % int(state["next_id"]), "course_id": key, "term": state["term"], "status": "POSTULADA", "answers": [], "candidates": candidates, "parallels": ["A", "B"]}
	state["next_id"] = int(state["next_id"]) + 1
	state["applications"].append(application)
	var request := _new_procedure("auxiliatura", {"application_id": application["id"], "course_id": key})
	application["request_id"] = request["id"]
	return _ok("Postulación %s. Completa %s y luego rinde el examen." % [application["id"], request["id"]], {"application_id": application["id"], "request_id": request["id"]})


func _application(id: String) -> Dictionary:
	for application in state["applications"]:
		if application["id"] == id:
			return application
	return {}


func _assignment(id: String) -> Dictionary:
	for assignment in state["assignments"]:
		if assignment["id"] == id:
			return assignment
	return {}


func assistant_answer(id: String, expected_partial: int, correct: bool) -> Dictionary:
	var application := _application(id)
	if application.is_empty() or application["status"] != "HABILITADA" or int(application["term"]) != int(state["term"]):
		return _error("La postulación no está habilitada para examen.")
	var current_eligibility := assistant_eligibility(str(application["course_id"]))
	if not current_eligibility["ok"]:
		return current_eligibility
	if application["answers"].size() != expected_partial or expected_partial >= 3:
		return _error("Pregunta fuera de secuencia o ya respondida.")
	application["answers"].append(100.0 if correct else 0.0)
	if application["answers"].size() < 3:
		return _ok("Respuesta de competencia registrada.", {"finished": false})
	var score := (float(application["answers"][0]) + float(application["answers"][1]) + float(application["answers"][2])) / 3.0
	application["score"] = score
	var subject_record: Dictionary = approved_results().get(_identity(application["course_id"]), {})
	var mark := float(subject_record.get("score", 0.0)) if subject_record.get("score") != null else 0.0
	var ranking := 1
	var tied := false
	for candidate in application["candidates"]:
		if float(candidate["score"]) > score or (is_equal_approx(float(candidate["score"]), score) and float(candidate["subject_mark"]) > mark):
			ranking += 1
		elif is_equal_approx(float(candidate["score"]), score) and is_equal_approx(float(candidate["subject_mark"]), mark):
			tied = true
	application["ranking"] = ranking
	application["status"] = "DESEMPATE" if tied else "RECHAZADA"
	if score >= PASS_MARK and ranking <= application["parallels"].size() and not tied:
		application["status"] = "SELECCIONADA"
		var assignment := {"id": "DES-%03d" % int(state["next_id"]), "application_id": id, "course_id": application["course_id"], "parallel": application["parallels"][ranking - 1], "teacher": "Docente titular de " + str(courses[application["course_id"]]["sigla"]), "term": state["term"], "status": "ASIGNADA"}
		state["next_id"] = int(state["next_id"]) + 1
		state["assignments"].append(assignment)
		var work := _new_procedure("trabajo_auxiliar", {"assignment_id": assignment["id"], "sessions": 0})
		assignment["request_id"] = work["id"]
		return _ok("Auxiliatura ganada: paralelo %s. Coordina con %s y completa %s." % [assignment["parallel"], assignment["teacher"], work["id"]], {"finished": true, "selected": true, "request_id": work["id"]})
	return _ok("Examen %.2f, puesto %d: %s." % [score, ranking, application["status"]], {"finished": true, "selected": false})


func support_session(id: String, expected_session: int, successful: bool) -> Dictionary:
	var request := procedure(id)
	if request.is_empty() or request["kind"] != "trabajo_auxiliar" or not ["PENDIENTE", "OBSERVADO"].has(request["status"]):
		return _error("No existe ese trabajo de auxiliatura pendiente.")
	if int(request["term"]) != int(state["term"]) or int(request["step"]) != 2:
		return _error("Necesitas primero plan firmado y permiso de aula vigentes.")
	if int(request["payload"].get("sessions", 0)) != expected_session or expected_session >= 3:
		return _error("Actividad ya registrada o fuera de secuencia.")
	if not successful:
		return _error("Revisa la explicación del docente antes de repetir la actividad.")
	request["payload"]["sessions"] = expected_session + 1
	return _ok("Actividad de apoyo %d/3 completada." % (expected_session + 1))


func defense_answer(id: String, expected_partial: int, correct: bool) -> Dictionary:
	var request := procedure(id)
	var step := Procedures.current_step(request)
	if step.is_empty() or not step.get("requires_defense", false):
		return _error("La defensa todavía no está habilitada.")
	if not state["studies_complete"] or request["payload"]["plan_id"] != plan_id():
		return _error("La defensa debe corresponder al plan de estudios concluido.")
	var answers: Array = request["payload"].get("defense_answers", [])
	if answers.size() != expected_partial or expected_partial >= 3 or request["payload"].get("defense_passed", false):
		return _error("Respuesta de defensa fuera de secuencia.")
	answers.append(100.0 if correct else 0.0)
	request["payload"]["defense_answers"] = answers
	if answers.size() < 3:
		return _ok("Respuesta de defensa registrada.", {"finished": false})
	var score := (float(answers[0]) + float(answers[1]) + float(answers[2])) / 3.0
	var attempts: Array = request["payload"].get("defense_attempts", [])
	attempts.append({"score": score, "passed": score >= PASS_MARK})
	request["payload"]["defense_attempts"] = attempts
	request["payload"]["defense_passed"] = score >= PASS_MARK
	if score < PASS_MARK:
		request["payload"]["defense_answers"] = []
	return _ok("Defensa %s: %.2f." % ["aprobada" if score >= PASS_MARK else "pendiente de nueva presentación", score], {"finished": true, "passed": score >= PASS_MARK})


func snapshot() -> Dictionary:
	var subjects := []
	for key in curriculum():
		var row: Dictionary = courses[key].duplicate(true)
		row["approved"] = is_approved(key)
		row["eligibility"] = eligibility(key)
		row["enrollment"] = state["enrollments"].get(key, {}).duplicate(true)
		subjects.append(row)
	for key in state["enrollments"]:
		if not curriculum().has(key):
			var row: Dictionary = courses[key].duplicate(true)
			row["approved"] = is_approved(key)
			row["eligibility"] = eligibility(key)
			row["enrollment"] = state["enrollments"][key].duplicate(true)
			subjects.append(row)
	return {"term": state["term"], "phase": state["phase"], "subjects": subjects, "load_limit": load_limit(), "history": state["history"].duplicate(true), "procedures": state["procedures"].duplicate(true), "documents": state["documents"].duplicate(true), "applications": state["applications"].duplicate(true), "assignments": state["assignments"].duplicate(true), "studies_complete": state["studies_complete"], "graduated": state["graduated"], "average": average(), "excellence": excellence(), "unlocked_all": state["unlocked_all"]}


func _ok(message: String, extra: Dictionary = {}) -> Dictionary:
	var result := {"ok": true, "message": message}
	result.merge(extra)
	return result


func _error(message: String) -> Dictionary:
	return {"ok": false, "message": message}


func unlock_all() -> Dictionary:
	if state["graduated"]:
		return _error("Esta carrera ya está titulada.")
	state["unlocked_all"] = true
	return _ok("Todas las materias del plan están desbloqueadas. Las notas y reprobaciones se conservan.")


func _observe(request: Dictionary, message: String) -> Dictionary:
	request["status"] = "OBSERVADO"
	request["events"].append({"step": request["step"], "term": state["term"], "observation": message})
	return _error(message)


func cancel_procedure(id: String) -> Dictionary:
	var request := procedure(id)
	if request.is_empty() or not ["PENDIENTE", "OBSERVADO"].has(request["status"]):
		return _error("Solo puedes cancelar un trámite pendiente u observado.")
	request["status"] = "CANCELADO"
	request["events"].append({"step": request["step"], "term": state["term"], "action": "Cancelado por el estudiante"})
	if request["kind"] == "auxiliatura":
		_application(str(request["payload"]["application_id"]))["status"] = "RETIRADA"
	return _ok("Trámite cancelado. Se conserva su expediente.")
