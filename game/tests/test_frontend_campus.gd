extends SceneTree

class TestGame extends "res://scripts/game.gd":
	var writes := 0

	func _ready() -> void:
		settings["animations"] = false
		_setup_theme()
		_use_neutral_theme()

	func _save_profile() -> void:
		writes += 1

	func _save_global_profile() -> void:
		pass

	func _save_settings() -> void:
		pass

	func _read_save(_slot: int, _mode: String) -> Dictionary:
		return {}


var failures: Array[String] = []
var assertions := 0
var game: Control
var viewport: SubViewport


func _initialize() -> void:
	_run.call_deferred()


func _check(condition: bool, message: String) -> void:
	assertions += 1
	if not condition:
		failures.append(message)


func _settle() -> void:
	for index in range(12):
		await process_frame


func _click(text: String) -> bool:
	for button in game.find_children("*", "Button", true, false):
		if button.text == text and not button.disabled:
			button.pressed.emit()
			return true
	_check(false, "No existe acción habilitada: " + text)
	return false


func _text_present(text: String) -> bool:
	for label in game.find_children("*", "Label", true, false):
		if label.text.contains(text):
			return true
	return false


func _finish_matriculation() -> void:
	var request_id := ""
	for request in game.simulation.snapshot()["procedures"]:
		if request["kind"] == "matricula" and request["status"] == "PENDIENTE":
			request_id = request["id"]
	game._campus().open_request(request_id)
	var writes: int = game.writes
	_click("Presentar en Caja")
	_check(game.simulation.procedure(request_id)["status"] == "OBSERVADO" and game.writes == writes + 1, "La observación de documentos se guarda aunque la acción no avance")
	_click("Registrar comprobante de pago simulado")
	_click("Presentar en Caja")
	_click("Presentar en Kardex")
	_click("Presentar en Cómputo")
	_check(game.simulation.procedure(request_id)["status"] == "COMPLETADO", "Matrícula completa sin comandos")


func _run() -> void:
	viewport = SubViewport.new()
	viewport.size = Vector2i(1152, 720)
	root.add_child(viewport)
	game = TestGame.new()
	viewport.add_child(game)
	game.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	game.active_slot = 1
	game.draft_player_name = "Estudiante de prueba"
	game._show_new_solo()
	var name_field = game.find_child("StudentName", true, false)
	_check(name_field != null and name_field.text == game.draft_player_name, "El formulario conserva el nombre")
	game._show_mentions("sistemas")
	game._show_new_solo()
	_check(game.find_child("StudentName", true, false).text == "Estudiante de prueba", "Volver de menciones conserva el borrador")
	game._create_solo_save("sistemas", "gestion_sistemas")
	_check(game.find_child("CampusNavigation", true, false).get_child_count() == 8, "Ocho áreas de navegación común, incluida exploración")
	game._show_campus_section("materias")
	_check(game.find_child("SubjectResults", true, false).get_child_count() == 5, "Búsqueda vacía muestra las cinco materias inscritas")
	var search = game.find_child("SubjectSearch", true, false)
	search.text = "fís"
	search.text_changed.emit(search.text)
	_check(game.find_child("SubjectResults", true, false).get_child_count() == 1 and _text_present("FÍSICA I"), "Buscar filtra por nombre sin perder materias")
	search.text = ""
	search.text_changed.emit(search.text)
	_check(game.find_child("SubjectResults", true, false).get_child_count() == 5, "Limpiar búsqueda recupera la lista")
	_finish_matriculation()
	game._show_campus_section("resumen")
	_click("Iniciar semestre")
	_check(game.simulation.state["phase"] == "CURSANDO", "Inicio gráfico del semestre")
	var keys: Array = game.simulation.state["enrollments"].keys().duplicate()
	for key in keys:
		for partial in range(3):
			game._start_subject(str(key))
			game._answer_subject(int(game.current_question["answer"]))
	game._show_campus_section("resumen")
	_click("Cerrar semestre")
	var dialogs := game.find_children("*", "ConfirmationDialog", true, false)
	_check(dialogs.size() == 1, "El cierre explica consecuencias antes de confirmar")
	if not dialogs.is_empty():
		dialogs[0].confirmed.emit()
	_check(game.simulation.state["term"] == 2, "Cierre gráfico y siguiente periodo")
	game._show_campus_section("historial")
	_check(_text_present("Semestre cursado 1"), "Historial gráfico conserva intentos")
	var before: String = JSON.stringify(game.simulation.snapshot())
	game._show_course_preview(str(keys[0]))
	_check(before == JSON.stringify(game.simulation.snapshot()), "Repasar no registra notas ni modifica historial")
	_finish_matriculation()
	game._show_campus_section("auxiliatura")
	_click("Postular")
	var applications: Array = game.simulation.snapshot()["applications"]
	_check(applications.size() == 1, "Postulación desde tarjeta de materia aprobada")
	if not applications.is_empty():
		var application_id: String = applications[0]["id"]
		_click("Registrar comprobante de pago simulado")
		_click("Presentar en Caja")
		_click("Registrar pago de historial")
		_click("Preparar Historial académico")
		_click("Presentar en Dirección de Carrera")
		_check(game.simulation._application(application_id)["status"] == "HABILITADA", "Expediente gráfico habilita competencia")
		game._show_campus_section("auxiliatura")
		_click("Rendir competencia")
		for partial in range(3):
			if partial > 0:
				_click("Continuar")
			game._answer_simulation_activity(int(game.current_question["answer"]))
		_check(game.simulation.snapshot()["assignments"].size() == 1, "Ganar asigna paralelo y docente")
		_click("Continuar")
		var assignment: Dictionary = game.simulation.snapshot()["assignments"][0]
		var work_id: String = assignment["request_id"]
		_click("Preparar Plan de trabajo")
		_click("Presentar en Docente")
		_click("Presentar en Coordinación de aulas")
		_click("Realizar actividad de apoyo")
		for index in range(3):
			if index > 0:
				_click("Continuar")
			game._answer_simulation_activity(int(game.current_question["answer"]))
		_click("Continuar")
		_click("Presentar en Docente")
		_click("Presentar en Docente")
		_click("Presentar en Dirección de Carrera")
		_check(game.simulation.procedure(work_id)["status"] == "COMPLETADO", "Trabajo de auxiliatura termina desde su expediente")
		_check(game.simulation.snapshot()["assignments"][0]["status"] == "CUMPLIDA", "La interfaz usa el resultado del motor para el trabajo")
	await _layout_scenarios()
	_form_scenarios()
	await _graduation_scenarios()
	game._save_failed = true
	game._return_to_menu()
	_check(not game.current_profile.is_empty(), "Un error de guardado conserva abierta la partida")
	game._save_failed = false
	viewport.queue_free()
	await process_frame
	for failure in failures:
		push_error(failure)
	print("FRONTEND_CAMPUS_TESTS: %d assertions, %d failures" % [assertions, failures.size()])
	quit(0 if failures.is_empty() else 1)


func _layout_scenarios() -> void:
	for dimensions in [Vector2i(900, 640), Vector2i(1152, 720)]:
		viewport.size = dimensions
		for scale in [1.0, 1.2]:
			game.settings["font_scale"] = scale
			for destination in ["resumen", "materias", "tramites", "historial", "auxiliatura", "graduacion", "malla"]:
				game._show_campus_section(destination)
				await _settle()
				var scroll = game.find_child("PageViewport", true, false)
				_check(scroll != null, "Página tiene navegación por botones: " + destination)
				if scroll != null:
					_check(scroll.get_global_rect().end.y <= dimensions.y + 1, "El contenido paginado conserva el límite vertical: " + destination)
				var nav = game.find_child("CampusNavigation", true, false)
				_check((nav != null and nav.get_global_rect().end.x <= dimensions.x + 1) or (nav == null and destination == "malla"), "Navegación compacta o vista amplia del grafo: " + destination)
				var page = game.find_child("PageContent", true, false)
				_check(page.size.x <= scroll.size.x + 1, "No hay desborde horizontal: " + destination)
			game._show_mentions("sistemas")
			await _settle()
			var back_button: Button
			for button in game.find_children("*", "Button", true, false):
				if button.text == "← Atrás":
					back_button = button
			_check(back_button.get_global_rect().end.y <= dimensions.y + 1, "Atrás accesible en menciones con texto aumentado")
			game._show_course_preview(str(game.simulation.curriculum()[0]))
			await _settle()
			var demo = game.find_child("ModelParameter", true, false)
			_check(demo.size.x > 100 and demo.get_child_count() == 2, "La demostración tiene botones explícitos para su parámetro")
			var parent = demo.get_parent()
			_check(demo.position.y < parent.size.y and parent.size.y < 500, "La demo no colapsa a miles de píxeles")
			game._show_campus_section("malla")
			await _settle()
			var graph
			for control in game.find_children("*", "Control", true, false):
				if control.get_script() == preload("res://scripts/curriculum_graph.gd"):
					graph = control
			_check(graph != null and not graph.is_processing(), "Malla respeta animaciones reducidas")
			if graph != null:
				_check(graph.size.x >= dimensions.x - 80, "El grafo aprovecha todo el ancho disponible")
				var detail = game.find_child("GraphSubjectDetail", true, false)
				_check(not detail.get_parent().visible, "La ficha vacía no ocupa espacio junto al grafo")
				_check(not graph.personal_states.is_empty(), "Malla recibe estados personales")
				var keyboard := InputEventKey.new()
				keyboard.keycode = KEY_RIGHT
				keyboard.pressed = true
				graph._gui_input(keyboard)
				_check(graph.selected == 0, "Las flechas seleccionan nodos de la malla")
				await _settle()
				_check(detail.get_parent().visible and detail.get_global_rect().position.y >= graph.get_global_rect().end.y, "La selección abre el detalle debajo del grafo")
				var before_layout: String = JSON.stringify(game.simulation.snapshot())
				graph._move_node(0, Vector2(180, 180))
				var saved_point: Vector2 = graph.visible_nodes[0]["pos"]
				game._show_campus_section("resumen")
				game._show_campus_section("malla")
				await _settle()
				graph = game.find_child("ExpandedCurriculumGraph", true, false)
				_check(graph.visible_nodes[0]["pos"].is_equal_approx(saved_point), "Navegar conserva la distribución manual del semestre")
				_check(before_layout == JSON.stringify(game.simulation.snapshot()), "Reorganizar la malla no modifica el estado académico")
				graph.move_semester(1)
				_check(game._campus().graph_semester == graph.semester_index, "Malla conserva el semestre consultado")
	game.settings["font_scale"] = 1.0
	viewport.size = Vector2i(1152, 720)


func _graduation_scenarios() -> void:
	var model: RefCounted = game.simulation
	model.state["history"] = []
	for key in model.curriculum():
		model.state["history"].append({"course_id": key, "term": 1, "score": 100.0, "passed": true, "origin": "ORDINARIA", "program_id": game.current_profile["program_id"], "mention_id": game.current_profile["mention_id"], "credits": 1.0})
	model.state["enrollments"] = {}
	model.state["procedures"] = []
	model._refresh_indexes()
	model._update_completion()
	model._sync_profile()
	game._show_campus_section("graduacion")
	_click("Iniciar excelencia")
	_check(_text_present("Graduación por excelencia"), "Excelencia abre expediente gráfico")
	_click("Registrar pago de historial")
	_click("Preparar Historial académico")
	_click("Presentar en Dirección de Carrera")
	_click("Preparar Solvencia")
	_click("Presentar en Decanato")
	_click("Registrar comprobante de pago simulado")
	_click("Presentar en Caja")
	_click("Presentar en Kardex")
	_click("Presentar en Rectorado")
	_check(model.snapshot()["graduated"], "La ruta gráfica llega al título sin consola")
	for kind in ["tesis", "proyecto"]:
		model.state["graduated"] = false
		model.state["phase"] = "INSCRIPCION"
		model.state["procedures"] = []
		model.state["documents"] = {}
		model.state["receipts"] = {}
		model._update_completion()
		model._sync_profile()
		game._show_campus_section("graduacion")
		_click("Iniciar " + ("tesis" if kind == "tesis" else "proyecto de grado"))
		_click("Preparar Perfil y propuesta de tutor")
		_click("Presentar en Dirección de Carrera")
		_click("Preparar Borrador del trabajo")
		_click("Presentar en Docente tutor")
		_click("Registrar pago de historial")
		_click("Preparar Historial académico")
		_click("Preparar Solvencia")
		_click("Registrar comprobante de pago simulado")
		_click("Presentar en Decanato")
		_click("Presentar en Tribunal")
		_check(not model.snapshot()["graduated"], "Presentar expediente no aprueba una defensa: " + kind)
		_click("Presentar defensa")
		for index in range(3):
			if index > 0:
				_click("Continuar")
			game._answer_simulation_activity(int(game.current_question["answer"]))
		_click("Continuar")
		_click("Presentar en Tribunal")
		_click("Registrar comprobante de pago simulado")
		_click("Presentar en Caja")
		_click("Presentar en Kardex")
		_click("Presentar en Rectorado")
		_check(model.snapshot()["graduated"], "Ruta gráfica completa con defensa: " + kind)


func _form_scenarios() -> void:
	var campus: RefCounted = game._campus()
	var model: RefCounted = game.simulation
	campus._new_request_form()
	var before: int = model.snapshot()["procedures"].size()
	campus.form_reason = "breve"
	campus._submit_form()
	_check(model.snapshot()["procedures"].size() == before, "Formulario conserva validación de justificación del motor")
	campus.form_reason = "Necesito reorganizar mi recorrido académico."
	campus._submit_form()
	var request: Dictionary = model.procedure(campus.selected_request)
	_check(request.get("kind") == "carta", "Formulario gráfico de materia por carta")
	_check(request["payload"]["course_id"] == campus.form_course, "Carta transmite el identificador estable")
	campus._new_request_form()
	campus._change_form("otra_carrera", "kind")
	_check(campus.form_reason == "Necesito reorganizar mi recorrido académico.", "Cambiar selector conserva la justificación")
	campus._submit_form()
	request = model.procedure(campus.selected_request)
	_check(request.get("kind") == "otra_carrera" and not model.curriculum().has(request["payload"]["course_id"]), "Materia externa conserva plan completo")
	campus._new_request_form()
	campus._change_form("mencion", "kind")
	campus._submit_form()
	request = model.procedure(campus.selected_request)
	_check(request.get("kind") == "mencion" and request["payload"]["mention_id"] != game.current_profile["mention_id"], "Formulario K-02 propone otra mención")
	campus._new_request_form()
	campus._change_form("carrera", "kind")
	campus._submit_form()
	request = model.procedure(campus.selected_request)
	_check(request.get("kind") == "carrera" and request["payload"]["program_id"] != game.current_profile["program_id"], "Formulario K-03 propone otra carrera")
