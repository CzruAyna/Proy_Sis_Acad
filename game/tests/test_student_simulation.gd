extends SceneTree

const Simulation = preload("res://scripts/student_simulation.gd")
const Commands = preload("res://scripts/simulation_commands.gd")
const Procedures = preload("res://scripts/simulation_procedures.gd")
var failures: Array[String] = []
var assertions := 0


func _initialize() -> void:
	_test_mixed_results_and_correlatives()
	_test_all_failed_and_all_passed()
	_test_excellence_and_graduation()
	_test_procedures_and_plan_changes()
	_test_auxiliatura()
	_test_application_limit_and_rejection()
	_test_atomic_load_limit()
	_test_legacy_and_json()
	_test_catalog_and_commands()
	_test_full_real_curricula()
	_test_plan_scopes_and_validation()
	for failure in failures:
		push_error(failure)
	print("SIMULATION_TESTS: %d assertions, %d failures" % [assertions, failures.size()])
	quit(0 if failures.is_empty() else 1)


func _check(condition: bool, description: String) -> void:
	assertions += 1
	if not condition:
		failures.append(description)


func _fixtures() -> Array:
	return [
		{"program_id": "p", "mention_id": "m", "sigla": "A", "name": "Regular A", "semester": 1, "prereq": ["INGRESO"]},
		{"program_id": "p", "mention_id": "m", "sigla": "B", "name": "Regular B", "semester": 1, "prereq": ["INGRESO"]},
		{"program_id": "p", "mention_id": "m", "sigla": "C", "name": "Correlativa A", "semester": 2, "prereq": ["A"]},
		{"program_id": "p", "mention_id": "m", "sigla": "D", "name": "Correlativa B", "semester": 2, "prereq": ["B"]},
		{"program_id": "p", "mention_id": "m", "sigla": "E", "name": "Avanzada", "semester": 3, "prereq": ["C"]},
		{"program_id": "p", "mention_id": "n", "sigla": "A", "name": "Regular A", "semester": 1, "prereq": ["INGRESO"]},
		{"program_id": "p", "mention_id": "n", "sigla": "N", "name": "Nueva mención", "semester": 1, "prereq": ["INGRESO"]},
		{"program_id": "q", "mention_id": "x", "sigla": "A", "name": "Otra materia con igual sigla", "semester": 1, "prereq": ["INGRESO"]},
		{"program_id": "q", "mention_id": "x", "sigla": "X", "name": "Materia externa", "semester": 1, "prereq": ["INGRESO"]}
	]


func _new_sim() -> RefCounted:
	return Simulation.new({"program_id": "p", "mention_id": "m", "player_name": "Prueba"}, _fixtures())


func _finish_procedure(sim: RefCounted, id: String) -> void:
	for index in range(12):
		var request: Dictionary = sim.procedure(id)
		var step := Procedures.current_step(request)
		if step.is_empty():
			return
		var result: Dictionary = sim.advance_procedure(id, str(step["office"]))
		_check(result["ok"], "Trámite %s: %s" % [id, result["message"]])
		if not result["ok"]:
			return


func _matriculate(sim: RefCounted) -> void:
	_check(sim.pay("matricula")["ok"], "Pago de matrícula")
	var result: Dictionary = sim.open_procedure("matricula")
	_finish_procedure(sim, str(result["request_id"]))


func _history_document(sim: RefCounted) -> void:
	_check(sim.pay("historial")["ok"], "Pago historial")
	_check(sim.issue_document("historial")["ok"], "Emisión historial")


func _answer_course(sim: RefCounted, key: String, count: int) -> void:
	for partial in range(3):
		_check(sim.answer(key, partial, partial < count)["ok"], "Registrar parcial de %s" % key)


func _test_mixed_results_and_correlatives() -> void:
	var sim := _new_sim()
	_check(sim.state["enrollments"].size() == 2, "Solo materias de ingreso inicialmente")
	_check(sim.eligibility("E")["ok"] and sim.eligibility("E")["regulars"].size() == 2, "Una correlativa identifica todas sus regulares obligatorias")
	_check(sim.enroll("C")["ok"], "Correlativa con regular simultánea")
	_check(not sim.withdraw("A")["ok"], "La regular no se retira mientras curse correlativa")
	_check(not sim.start_term()["ok"], "La matrícula es obligatoria")
	_matriculate(sim)
	_check(sim.start_term()["ok"], "Inicio de semestre")
	_check(not sim.enroll("D")["ok"], "Inscripción congelada durante semestre")
	_check(sim.answer("A", 0, false)["ok"], "Primer parcial registrado")
	_check(not sim.answer("A", 0, true)["ok"], "Una doble respuesta no cambia la nota")
	_check(sim.answer("A", 1, false)["ok"], "Segundo parcial")
	_check(sim.answer("A", 2, true)["ok"], "Resultado de regular reprobada")
	_answer_course(sim, "B", 3)
	_answer_course(sim, "C", 2)
	_check(not sim.is_approved(sim.resolve_course("C")), "El desbloqueo se aplica al cerrar el semestre")
	_check(sim.close_term()["ok"], "Cierre con resultados mixtos")
	_check(sim.state["term"] == 2, "Avanza aunque una materia esté reprobada")
	_check(sim.is_approved(sim.resolve_course("C")), "La correlativa aprobada se conserva")
	_check(sim.retakes().has(sim.resolve_course("A")), "La regular reprobada debe recursarse")
	_check(sim.state["enrollments"].has(sim.resolve_course("A")), "Arrastre automático de la regular")
	_check(not sim.withdraw("A")["ok"], "La materia reprobada es obligatoria")
	_check(sim.eligibility("E", false)["ok"], "La correlativa aprobada habilita su siguiente materia")
	_check(sim.state["history"].size() == 3, "Se conserva un resultado independiente por materia")
	_check(sim.state["had_failure"], "La reprobación queda registrada permanentemente")
	_check(not sim.start_term()["ok"], "La matrícula anterior no habilita un nuevo semestre")


func _test_all_failed_and_all_passed() -> void:
	for count in [0, 3]:
		var sim := _new_sim()
		_matriculate(sim)
		_check(sim.start_term()["ok"], "Inicio caso uniforme")
		_check(not sim.close_term()["ok"], "No se cierra un semestre con notas pendientes")
		_answer_course(sim, "A", count)
		_answer_course(sim, "B", count)
		_check(sim.close_term()["ok"], "Se permite aprobar o reprobar todo")
		_check(sim.retakes().size() == (2 if count == 0 else 0), "Arrastre según resultado")
		_check(sim.load_limit() == (6 if count == 0 else 7), "Carga de seis o siete según promedio anterior")


func _completed_sim(mark: float, had_failure: bool = false) -> RefCounted:
	var sim := _new_sim()
	sim.state["history"].clear()
	for key in sim.curriculum():
		sim.state["history"].append({"course_id": key, "term": 1, "score": mark, "passed": true, "origin": "ORDINARIA", "credits": 1.0})
	if had_failure:
		sim.state["history"].push_front({"course_id": sim.resolve_course("A"), "term": 0, "score": 30.0, "passed": false, "origin": "ORDINARIA", "credits": 1.0})
	sim.state["studies_complete"] = true
	sim.state["enrollments"] = {}
	sim.state["term"] = 2
	sim.state["procedures"] = []
	sim = Simulation.new(sim.profile, _fixtures())
	sim._update_completion()
	return sim


func _test_excellence_and_graduation() -> void:
	_check(not _completed_sim(65.0).excellence()["ok"], "Promedio 65 exacto no habilita excelencia")
	_check(_completed_sim(65.01).excellence()["ok"], "Promedio mayor que 65 sí habilita excelencia")
	var failed := _completed_sim(100.0, true)
	_check(not failed.excellence()["ok"], "Recursar y aprobar no recupera excelencia")
	_check(not failed.open_procedure("excelencia")["ok"], "No se elude la regla abriendo el trámite")
	var excellent := _completed_sim(90.0)
	_history_document(excellent)
	_check(excellent.issue_document("solvencia")["ok"], "Solvencia final")
	var graduation: Dictionary = excellent.open_procedure("excelencia")
	_check(graduation["ok"], "Inicio graduación por excelencia")
	var id := str(graduation["request_id"])
	_check(excellent.pay("titulo", id)["ok"], "Derecho de título")
	_finish_procedure(excellent, id)
	_check(excellent.state["graduated"], "Excelencia emite título sin defensa")
	_check(excellent.state["phase"] == "TITULADO", "Estado final distinto de egreso")
	for kind in ["tesis", "proyecto"]:
		var sim := _completed_sim(80.0, true)
		_history_document(sim)
		_check(sim.issue_document("solvencia")["ok"], "Solvencia de defensa")
		var opened: Dictionary = sim.open_procedure(kind)
		id = str(opened["request_id"])
		_check(not sim.open_procedure("excelencia")["ok"], "Solo una modalidad activa")
		_check(sim.issue_document("perfil", id)["ok"], "Perfil de graduación")
		_check(sim.issue_document("borrador", id)["ok"], "Borrador de graduación")
		_check(sim.pay("defensa", id)["ok"], "Derecho de defensa")
		_check(sim.pay("titulo", id)["ok"], "Derecho de título por defensa")
		for index in range(3):
			var step := Procedures.current_step(sim.procedure(id))
			_check(sim.advance_procedure(id, str(step["office"]))["ok"], "Preparación de defensa")
		_check(not sim.advance_procedure(id, "Tribunal")["ok"], "No se salta defensa")
		for index in range(3):
			_check(sim.defense_answer(id, index, false)["ok"], "Defensa fallida registrada")
		_check(not sim.state["graduated"], "Defensa fallida no entrega título")
		for index in range(3):
			_check(sim.defense_answer(id, index, true)["ok"], "Nueva defensa")
		_finish_procedure(sim, id)
		_check(sim.state["graduated"], "Título tras defensa y documentos")
		_check(sim.procedure(id)["payload"]["defense_attempts"].size() == 2, "Se conservan intentos de defensa")


func _test_procedures_and_plan_changes() -> void:
	var sim := _new_sim()
	_matriculate(sim)
	_history_document(sim)
	_check(not sim.open_procedure("carta", {"course_id": "E", "reason": "corta"})["ok"], "Carta requiere justificación")
	var opened: Dictionary = sim.open_procedure("carta", {"course_id": "E", "reason": "Solicito explorar esta asignatura por interés académico"})
	var id := str(opened["request_id"])
	_check(not sim.advance_procedure(id, "Cómputo")["ok"], "Se respeta el orden de oficinas")
	_finish_procedure(sim, id)
	_check(sim.eligibility("E", false)["ok"], "Carta habilita su materia específica")
	_check(not sim.eligibility("q/x/X")["ok"], "Una carta propia no habilita materias externas")
	opened = sim.open_procedure("otra_carrera", {"course_id": "q/x/X", "reason": "Solicito formación complementaria en esta otra carrera"})
	_finish_procedure(sim, str(opened["request_id"]))
	_check(sim.enroll("q/x/X")["ok"], "Permiso externo habilita inscripción")
	_check(sim.snapshot()["subjects"].back()["id"] == "q/x/X", "Snapshot publica materia externa")
	sim.state["term"] = 2
	_check(not sim.eligibility("q/x/X")["ok"], "Permiso externo expira al cambiar semestre")
	var common := _completed_sim(80.0, true)
	common.state["studies_complete"] = false
	_matriculate(common)
	var changes: Dictionary = common.open_procedure("mencion", {"program_id": "p", "mention_id": "n"})
	_check(changes["ok"], "Abrir K02")
	var history_size: int = common.state["history"].size()
	_finish_procedure(common, str(changes["request_id"]))
	_check(common.profile["mention_id"] == "n", "K02 actualiza mención")
	_check(common.state["history"].size() == history_size, "El cambio conserva historial")
	_check(common.is_approved(common.resolve_course("A")), "Se reconoce materia común con misma sigla y nombre")
	_check(common.state["had_failure"], "El cambio no borra reprobaciones")
	changes = common.open_procedure("carrera", {"program_id": "q", "mention_id": "x"})
	_finish_procedure(common, str(changes["request_id"]))
	_check(common.profile["program_id"] == "q", "K03 actualiza carrera")
	_check(not common.is_approved(common.resolve_course("A")), "Igual sigla con contenido distinto no equivale automáticamente")


func _test_auxiliatura() -> void:
	var sim := _new_sim()
	_check(not sim.apply_assistant("A")["ok"], "No se postula sin aprobar la materia")
	_matriculate(sim)
	_check(sim.start_term()["ok"], "Semestre previo a auxiliares")
	_answer_course(sim, "A", 3)
	_answer_course(sim, "B", 3)
	_check(sim.close_term()["ok"], "Cierre previo a auxiliares")
	_matriculate(sim)
	_history_document(sim)
	var opened: Dictionary = sim.apply_assistant("A")
	_check(opened["ok"], "Auxiliatura habilitada durante carrera")
	var id := str(opened["request_id"])
	var application_id := str(opened["application_id"])
	_check(not sim.assistant_answer(application_id, 0, true)["ok"], "Primero se habilita documentación")
	_check(not sim.advance_procedure(id, "Caja")["ok"], "La postulación requiere comprobante")
	_check(sim.pay("auxiliatura", id)["ok"], "Derecho por materia")
	_finish_procedure(sim, id)
	var result := {}
	for partial in range(3):
		result = sim.assistant_answer(application_id, partial, true)
		_check(result["ok"], "Examen de competencia")
	_check(result.get("selected", false), "La mejor nota obtiene plaza")
	_check(sim.profile["role_id"] == "estudiante", "Auxiliatura no cambia rol jugable")
	_check(not sim.apply_assistant("A")["ok"], "No se repite convocatoria para cambiar resultado")
	id = str(result["request_id"])
	_check(not sim.support_session(id, 0, true)["ok"], "No hay tutorías sin aula y plan")
	_check(sim.issue_document("plan_aux", id)["ok"], "Preparar plan de auxiliatura")
	for index in range(2):
		var step := Procedures.current_step(sim.procedure(id))
		_check(sim.advance_procedure(id, str(step["office"]))["ok"], "Firma docente y permiso de aula")
	for index in range(3):
		_check(sim.support_session(id, index, true)["ok"], "Actividades de apoyo")
	_check(not sim.support_session(id, 0, true)["ok"], "No se duplica actividad de apoyo")
	_finish_procedure(sim, id)
	_check(sim.state["assignments"][0]["status"] == "CUMPLIDA", "Trabajo cumplido")
	_check(sim.state["benefits"].size() == 1, "Beneficio se registra tras cumplir trabajo")


func _test_legacy_and_json() -> void:
	var profile := {"program_id": "p", "mention_id": "m", "passed_subjects": ["A"], "failed_subjects": ["B"], "role_id": "auxiliar", "career_complete": true}
	var sim := Simulation.new(profile, _fixtures())
	_check(sim.profile["role_id"] == "estudiante", "Partida antigua pasa al único rol jugable")
	_check(sim.state["history"][0]["score"] == null, "Migración no inventa calificaciones")
	_check(sim.state["legacy_incomplete"], "Se informa historial antiguo incompleto")
	_check(sim.state["had_failure"], "Se conserva reprobación antigua")
	_check(not sim.state["graduated"], "Completar plan antiguo no fabrica título nuevo")
	var copy: Variant = JSON.parse_string(JSON.stringify(profile))
	var restored := Simulation.new(copy, _fixtures())
	_check(restored.state["history"].size() == sim.state["history"].size(), "Historial sobrevive JSON")
	for index in range(sim.state["history"].size()):
		var original: Dictionary = sim.state["history"][index]
		var reloaded: Dictionary = restored.state["history"][index]
		_check(original["course_id"] == reloaded["course_id"] and original["passed"] == reloaded["passed"] and original["score"] == reloaded["score"] and int(original["term"]) == int(reloaded["term"]), "Resultado académico se conserva al recargar JSON")
	_check(restored.state["procedures"].size() == sim.state["procedures"].size(), "Recarga no duplica trámites")
	_check(restored.retakes() == sim.retakes(), "Recarga conserva arrastre")
	var before: int = restored.state["history"].size()
	_check(Commands.execute(restored, "/desbloquear todo")["ok"], "Comando de exploración")
	_check(restored.state["history"].size() == before and restored.state["had_failure"], "Truco no altera historial")
	_check(restored.eligibility("E", false)["ok"], "Truco habilita materias avanzadas")


func _test_catalog_and_commands() -> void:
	var sim := Simulation.new({"program_id": "sistemas", "mention_id": "gestion_sistemas", "player_name": "Catálogo"})
	_check(sim.curriculum().size() > 40, "Catálogo real de Sistemas disponible")
	_check(sim.state["enrollments"].size() == 5, "Cinco materias de ingreso en Sistemas")
	_check(not sim.curriculum().has(sim.resolve_course("SIS 5100")), "Graduación es proceso separado del cursado")
	for key in sim.courses:
		var subject: Dictionary = sim.courses[key]
		for prerequisite in subject.get("prereq", []):
			if prerequisite != "INGRESO":
				_check(sim.courses.has("%s/%s/%s" % [subject["program_id"], subject["mention_id"], prerequisite]), "Requisito existe: %s → %s" % [key, prerequisite])
	_check(Commands.execute(sim, "/ayuda")["ok"], "Ayuda accesible")
	_check(not Commands.execute(sim, "/inventado")["ok"], "Comandos desconocidos se rechazan")
	_check(Commands.execute(sim, "/estado")["ok"], "Consulta de estado")
	_check(Commands.execute(sim, "/materias")["ok"], "Consulta de materias")


func _test_application_limit_and_rejection() -> void:
	var sim := _completed_sim(80.0)
	sim.state["history"].pop_back()
	sim.state["studies_complete"] = false
	sim = Simulation.new(sim.profile, _fixtures())
	_matriculate(sim)
	_history_document(sim)
	var first := {}
	for sigla in ["A", "B", "C"]:
		var opened: Dictionary = sim.apply_assistant(sigla)
		_check(opened["ok"], "Postulación activa dentro del límite")
		if sigla == "A":
			first = opened
	_check(not sim.apply_assistant("D")["ok"], "Máximo tres postulaciones activas")
	_check(sim.pay("auxiliatura", str(first["request_id"]))["ok"], "Pago para examen rechazado")
	_finish_procedure(sim, str(first["request_id"]))
	for index in range(3):
		_check(sim.assistant_answer(str(first["application_id"]), index, false)["ok"], "Examen fallido conservado")
	_check(sim.state["applications"][0]["status"] == "RECHAZADA", "No gana plaza un examen reprobado")
	_check(not sim.assistant_answer(str(first["application_id"]), 0, true)["ok"], "No se repite el mismo concurso después de conocer resultado")
	_check(sim.apply_assistant("D")["ok"], "Postulación rechazada libera límite activo")


func _test_atomic_load_limit() -> void:
	var rows := []
	for index in range(6):
		rows.append({"program_id": "p", "mention_id": "m", "sigla": "R%d" % index, "name": "Regular %d" % index, "semester": 1, "prereq": ["INGRESO"]})
	rows.append({"program_id": "p", "mention_id": "m", "sigla": "C", "name": "Correlativa", "semester": 2, "prereq": ["R0"]})
	var sim := Simulation.new({"program_id": "p", "mention_id": "m"}, rows)
	_check(sim.state["enrollments"].size() == 6, "Carga inicial de seis")
	_check(not sim.enroll("C")["ok"], "La correlativa respeta el límite de carga")
	_check(sim.state["enrollments"].size() == 6, "Inscripción rechazada no deja un paquete parcial")
	_check(sim.withdraw("R5")["ok"], "Se libera un espacio opcional")
	_check(sim.enroll("C")["ok"], "Se inscribe correlativa al haber capacidad")
	_check(not sim.withdraw("R0")["ok"], "Se conserva su regular obligatoria")


func _test_full_real_curricula() -> void:
	var catalog_sim := Simulation.new({"program_id": "sistemas", "mention_id": "gestion_sistemas"})
	for plan in catalog_sim.plans:
		var parts := str(plan).split("/")
		var sim := Simulation.new({"program_id": parts[0], "mention_id": parts[1], "player_name": "Recorrido completo"})
		for term_index in range(24):
			if sim.state["studies_complete"]:
				break
			_check(not sim.state["enrollments"].is_empty(), "Malla sin callejón sin salida: %s semestre %d" % [plan, int(sim.state["term"])])
			if sim.state["enrollments"].is_empty():
				break
			_matriculate(sim)
			_check(sim.start_term()["ok"], "Cursado real: " + str(plan))
			for key in sim.state["enrollments"].keys():
				_answer_course(sim, str(key), 3)
			_check(sim.close_term()["ok"], "Cierre real: " + str(plan))
		_check(sim.state["studies_complete"], "Cada malla se puede concluir: " + str(plan))
		_check(not sim.state["graduated"], "Concluir cada malla no entrega título automáticamente")
		_check(sim.excellence()["ok"], "Recorrido limpio habilita excelencia: " + str(plan))


func _test_plan_scopes_and_validation() -> void:
	var sim := _completed_sim(90.0)
	_matriculate(sim)
	var change: Dictionary = sim.open_procedure("mencion", {"program_id": "p", "mention_id": "n"})
	_check(change["ok"], "Cambio abierto antes de graduación")
	var graduation: Dictionary = sim.open_procedure("tesis")
	_check(graduation["ok"], "Graduación anclada a su plan")
	var step := Procedures.current_step(sim.procedure(change["request_id"]))
	_check(not sim.advance_procedure(change["request_id"], step["office"])["ok"], "No se cambia de plan con titulación pendiente")
	_check(sim.cancel_procedure(graduation["request_id"])["ok"], "Graduación cancelable sin borrar expediente")
	_finish_procedure(sim, change["request_id"])
	_check(not sim.advance_procedure(graduation["request_id"], "Dirección de Carrera")["ok"], "Graduación cancelada no entrega título en otro plan")
	var letter_sim := _new_sim()
	_matriculate(letter_sim)
	_history_document(letter_sim)
	var letter: Dictionary = letter_sim.open_procedure("carta", {"course_id": "E", "reason": "Solicito cursado excepcional de esta asignatura"})
	change = letter_sim.open_procedure("carrera", {"program_id": "q", "mention_id": "x"})
	_finish_procedure(letter_sim, change["request_id"])
	step = Procedures.current_step(letter_sim.procedure(letter["request_id"]))
	_check(not letter_sim.advance_procedure(letter["request_id"], step["office"])["ok"], "Carta de plan anterior no se convierte en permiso externo")
	var real := Simulation.new({"program_id": "sistemas", "mention_id": "gestion_sistemas"})
	_check(Simulation.validate_profile(real.profile)["ok"], "Formato actual reconocido")
	var future: Dictionary = real.profile.duplicate(true)
	future["simulation"]["version"] = 999
	_check(not Simulation.validate_profile(future)["ok"], "Versión desconocida no se convierte perdiendo datos")
	var broken: Dictionary = real.profile.duplicate(true)
	broken["simulation"]["history"] = "inválido"
	_check(not Simulation.validate_profile(broken)["ok"], "Historial mal formado no se carga")
	var chain := _new_sim()
	_check(chain.enroll("E")["ok"], "Paquete de correlativas incorpora todas las regulares")
	_check(chain.state["enrollments"].has(chain.resolve_course("C")), "Regular intermedia incorporada")
	_check(not chain.withdraw("C")["ok"] and not chain.withdraw("A")["ok"], "Todas las regulares del paquete son obligatorias")
	var rows := _fixtures()
	rows[0]["prereq"] = ["E"]
	var cyclic := Simulation.new({"program_id": "p", "mention_id": "m"}, rows)
	_check(not cyclic.eligibility("E")["ok"], "Un ciclo curricular no provoca recursión infinita")
