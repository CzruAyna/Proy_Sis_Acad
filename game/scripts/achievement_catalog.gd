extends RefCounted

const Catalog = preload("res://scripts/catalog.gd")
const ACHIEVEMENTS := [
	{"id": "first_subject", "title": "Primer paso · aprobaste una materia", "description": "Aprueba tu primera materia y cierra el semestre.", "hidden": false},
	{"id": "steady", "title": "Ritmo constante · aprobaste cinco materias en total", "description": "Acumula cinco materias aprobadas entre tus recorridos.", "hidden": false},
	{"id": "tireless", "title": "Estudiante incansable · aprobaste veinte materias distintas", "description": "Acumula veinte materias aprobadas entre tus recorridos.", "hidden": false},
	{"id": "first_term", "title": "Un semestre vivido · cerraste tu primer semestre", "description": "Completa y cierra un semestre con todos sus resultados registrados.", "hidden": false},
	{"id": "retry", "title": "Volver a intentarlo · aprobaste una materia que habías reprobado", "description": "Recursa y aprueba una materia pendiente de un periodo anterior.", "hidden": false},
	{"id": "assistant", "title": "Auxiliar docente · ganaste una auxiliatura", "description": "Consigue una plaza y recibe tu paralelo y docente asignados.", "hidden": false},
	{"id": "assistant_work", "title": "Compromiso cumplido · completaste una auxiliatura", "description": "Cumple el plan, permiso de aula, actividades e informe de una auxiliatura.", "hidden": false},
	{"id": "explorer", "title": "Explorador académico · completaste todas las carreras disponibles", "description": "Obtén el título de Sistemas y el de Informática en tus recorridos.", "hidden": false, "aliases": ["Explorador académico · completaste tres carreras diferentes"]},
	{"id": "secret_correlative", "title": "Por caminos distintos", "description": "Aprobaste una correlativa mientras reprobabas su regular en el mismo semestre.", "hidden": true},
	{"id": "secret_comeback", "title": "Remontada completa", "description": "Tras un semestre con todas las materias reprobadas, aprobaste todas las del siguiente.", "hidden": true},
	{"id": "secret_map", "title": "Fuera del mapa", "description": "Activaste el desbloqueo de materias para explorar tu carrera.", "hidden": true}
]


static func definitions() -> Array:
	var result: Array = ACHIEVEMENTS.duplicate(true)
	for program in Catalog.PROGRAMS:
		result.append({"id": "degree_" + str(program["id"]), "title": "Título: " + str(program["title"]), "description": "Completa los estudios y el trámite de titulación de " + str(program["name"]) + ".", "hidden": false})
	return result


static func ensure_profile(profile: Dictionary) -> bool:
	var changed := false
	for key in ["achievements", "achievement_ids", "completed_programs", "completed_subjects"]:
		if not profile.get(key) is Array:
			profile[key] = []
			changed = true
	for item in definitions():
		if _has_title(profile, item):
			changed = _unlock(profile, item) or changed
	return changed


static func _has_title(profile: Dictionary, item: Dictionary) -> bool:
	var titles: Array = profile.get("achievements", [])
	if titles.has(item["title"]):
		return true
	for alias in item.get("aliases", []):
		if titles.has(alias):
			return true
	return false


static func _unlock(profile: Dictionary, item: Dictionary) -> bool:
	var changed := false
	if not profile["achievement_ids"].has(item["id"]):
		profile["achievement_ids"].append(item["id"])
		changed = true
	if not profile["achievements"].has(item["title"]):
		profile["achievements"].append(item["title"])
		changed = true
	return changed


static func record_title(profile: Dictionary, title: String) -> bool:
	var changed := ensure_profile(profile)
	for item in definitions():
		if item["title"] == title or item.get("aliases", []).has(title):
			return _unlock(profile, item) or changed
	if not profile["achievements"].has(title):
		profile["achievements"].append(title)
		return true
	return changed


static func evaluate(profile: Dictionary, run: Dictionary = {}) -> bool:
	var changed := ensure_profile(profile)
	var state: Dictionary = run.get("simulation", {})
	var records: Array = state.get("history", [])
	var seen_failures := {}
	var failed_by_term := {}
	var terms := {}
	var conditions := {"retry": false, "secret_correlative": false, "secret_comeback": false, "first_term": false, "assistant": false, "assistant_work": false, "secret_map": bool(state.get("unlocked_all", false))}
	for sigla in run.get("passed_subjects", []):
		var key := "%s:%s:%s" % [run.get("program_id", ""), run.get("mention_id", ""), sigla]
		if not profile["completed_subjects"].has(key):
			profile["completed_subjects"].append(key)
			changed = true
	for record in records:
		var key := str(record.get("course_id", ""))
		var term := int(record.get("term", 0))
		if not bool(record.get("passed", false)):
			seen_failures[key] = true
			if not failed_by_term.has(term):
				failed_by_term[term] = {}
			failed_by_term[term][key] = true
		else:
			conditions["retry"] = conditions["retry"] or seen_failures.has(key)
			var parts := key.split("/", true, 2)
			if parts.size() == 3:
				var completed := "%s:%s:%s" % [parts[0], parts[1], parts[2]]
				if not profile["completed_subjects"].has(completed):
					profile["completed_subjects"].append(completed)
					changed = true
		if term > 0:
			conditions["first_term"] = true
			if not terms.has(term):
				terms[term] = {"total": 0, "passed": 0}
			terms[term]["total"] += 1
			terms[term]["passed"] += 1 if record.get("passed", false) else 0
	for record in records:
		if not record.get("passed", false) or record.get("origin", "") != "CORRELATIVA":
			continue
		var parts := str(record.get("course_id", "")).split("/", true, 2)
		if parts.size() != 3:
			continue
		var subject := Catalog.subject_by_sigla(parts[0], parts[2], parts[1])
		var failed: Dictionary = failed_by_term.get(int(record.get("term", 0)), {})
		for regular in subject.get("prereq", []):
			if failed.has("%s/%s/%s" % [parts[0], parts[1], regular]):
				conditions["secret_correlative"] = true
	for term in terms:
		if terms[term]["passed"] == 0 and terms.has(int(term) + 1):
			var next: Dictionary = terms[int(term) + 1]
			conditions["secret_comeback"] = conditions["secret_comeback"] or next["passed"] == next["total"]
	for assignment in state.get("assignments", []):
		conditions["assistant"] = true
		conditions["assistant_work"] = conditions["assistant_work"] or assignment.get("status", "") == "CUMPLIDA"
	if state.get("graduated", false) and not profile["completed_programs"].has(run.get("program_id", "")):
		profile["completed_programs"].append(run["program_id"])
		changed = true
	var count: int = profile["completed_subjects"].size()
	conditions.merge({"first_subject": count > 0, "steady": count >= 5, "tireless": count >= 20})
	var all_programs := not Catalog.PROGRAMS.is_empty()
	for program in Catalog.PROGRAMS:
		var complete: bool = profile["completed_programs"].has(program["id"])
		conditions["degree_" + str(program["id"])] = complete
		all_programs = all_programs and complete
	conditions["explorer"] = all_programs
	for item in definitions():
		if conditions.get(item["id"], false):
			changed = _unlock(profile, item) or changed
	return changed


static func presentation(profile: Dictionary) -> Dictionary:
	var public := []
	var secrets := []
	var legacy := []
	var known_titles := {}
	var public_unlocked := 0
	var hidden_total := 0
	for item in definitions():
		known_titles[item["title"]] = true
		for alias in item.get("aliases", []):
			known_titles[alias] = true
		item["unlocked"] = profile.get("achievement_ids", []).has(item["id"]) or _has_title(profile, item)
		if item["hidden"]:
			hidden_total += 1
			if item["unlocked"]:
				secrets.append(item)
		else:
			public.append(item)
			public_unlocked += 1 if item["unlocked"] else 0
	for title in profile.get("achievements", []):
		if not known_titles.has(title) and not legacy.has(title):
			legacy.append(title)
	return {"public": public, "secrets": secrets, "legacy": legacy, "public_unlocked": public_unlocked, "hidden_total": hidden_total}
