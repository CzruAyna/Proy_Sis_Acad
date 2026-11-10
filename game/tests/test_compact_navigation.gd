extends SceneTree

class TestGame extends "res://tests/test_neon_visuals.gd".PreviewGame:
	func _save_settings() -> void:
		pass

var failures: Array[String] = []
var assertions := 0
var game: Control
var viewport: SubViewport


func _initialize() -> void:
	_run.call_deferred()


func _check(value: bool, message: String) -> void:
	assertions += 1
	if not value:
		failures.append(message)


func _settle() -> void:
	for index in range(16):
		await process_frame


func _inspect(screen: String) -> void:
	await _settle()
	for class_type in ["Slider", "ScrollBar", "ScrollContainer", "OptionButton", "TextEdit", "RichTextLabel"]:
		_check(game.find_children("*", class_type, true, false).is_empty(), screen + ": no contiene " + class_type)
	var pager = game.find_child("PageNavigator", true, false)
	if screen == "inicio":
		_check(pager == null, "Inicio utiliza un solo menú sin paginación")
		var panel: Control = game.find_child("MainMenuPanel", true, false)
		_check(panel != null and Rect2(Vector2.ZERO, viewport.size).encloses(panel.get_global_rect()), "Inicio compacto dentro de la ventana")
		_check(panel.get_global_rect().get_center().distance_to(Vector2(viewport.size) * 0.5) <= 1, "Inicio centrado")
		for control in panel.find_children("*", "Control", true, false):
			if control is Button or control is Label:
				_check(panel.get_global_rect().encloses(control.get_global_rect()), "Inicio: acción o texto visible completo: " + str(control.get("text")))
		return
	if screen in ["opciones", "jugar", "exploración-mapa", "mapa interactivo", "malla", "malla con materia arrastrada", "exploración-mundo", "mundo-ampliado", "exploración-aula", "exploración-ayuda", "exploración-progreso", "exploración-progreso-partida"]:
		_check(pager == null, screen + ": vista directa sin paginador")
		for control in game.find_children("*", "Control", true, false):
			if control.is_visible_in_tree() and (control is Button or control is Label):
				_check(Rect2(Vector2.ZERO, viewport.size).grow(1).encloses(control.get_global_rect()), screen + ": control visible dentro de la ventana")
		return
	_check(pager != null, screen + ": navegación explícita")
	if pager == null:
		return
	_check(pager.viewport.get_global_rect().end.y <= viewport.size.y + 1, screen + ": contenido dentro de la ventana")
	var controls := []
	for control in pager.content.find_children("*", "Control", true, false):
		if control.is_visible_in_tree() and (control is Button or control is LineEdit or control is Label):
			controls.append(control)
	var reachable := {}
	for page in range(pager.page_offsets.size()):
		pager.change_page(page - pager.page_index)
		await process_frame
		var clip: Rect2 = pager._page_clip.get_global_rect()
		for control in controls:
			var rect: Rect2 = control.get_global_rect()
			if rect.position.y >= clip.position.y - 1 and rect.end.y <= clip.end.y + 1 and rect.position.x >= clip.position.x - 1 and rect.end.x <= clip.end.x + 1:
				reachable[control.get_instance_id()] = true
	for control in controls:
		_check(reachable.has(control.get_instance_id()), "%s: contenido alcanzable completo sin rueda: %s %s" % [screen, control.name, str(control.get("text")).left(65)])
	pager.change_page(-pager.page_index)
	var identity = game.find_child("PlayerIdentity", true, false)
	if not game.current_profile.is_empty() and game.simulation != null and screen != "opciones":
		_check(identity != null and identity.text.contains("Prueba compacta"), screen + ": identidad de la partida visible")


func _run() -> void:
	viewport = SubViewport.new()
	root.add_child(viewport)
	game = TestGame.new()
	viewport.add_child(game)
	game.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	game.active_slot = 1
	game.draft_player_name = "Prueba compacta"
	for dimensions in [Vector2i(900, 640), Vector2i(1152, 720), Vector2i(1600, 900)]:
		viewport.size = dimensions
		for scale in [1.0, 1.2]:
			game.settings["font_scale"] = scale
			game.current_profile = {}
			game.simulation = null
			game._show_main()
			await _inspect("inicio")
			game._show_options()
			await _inspect("opciones")
			game._show_solo_slots()
			await _inspect("partidas")
			game._show_new_solo()
			await _inspect("carreras")
			game._show_mentions("sistemas")
			await _inspect("menciones")
			game._create_solo_save("sistemas", "gestion_sistemas")
			var before := JSON.stringify(game.simulation.snapshot())
			for section in ["resumen", "materias", "tramites", "historial", "auxiliatura", "graduacion", "malla"]:
				game._show_campus_section(section)
				await _inspect(section)
			game._campus().open_office(game._show_solo_hub)
			game._campus()._new_request_form()
			await _inspect("formulario")
			game._show_course_preview(str(game.simulation.curriculum()[0]))
			await _inspect("repaso")
			game._show_simulation_console()
			await _inspect("consola")
			game._close_simulation_console()
			game._show_global_achievements()
			await _inspect("logros")
			_check(before == JSON.stringify(game.simulation.snapshot()), "Navegar páginas no modifica el estado académico")
	game.settings["font_scale"] = 1.0
	viewport.size = Vector2i(1152, 720)
	game._create_solo_save("sistemas", "gestion_sistemas")
	var request: Dictionary = game.simulation.snapshot()["procedures"][0]
	game.simulation.pay("matricula")
	for index in range(3):
		var step: Dictionary = game.SimulationProcedures.current_step(game.simulation.procedure(str(request["id"])))
		game.simulation.advance_procedure(str(request["id"]), str(step["office"]))
	game.simulation.start_term()
	var first_key := str(game.simulation.state["enrollments"].keys()[0])
	game._start_subject(first_key)
	await _inspect("evaluación")
	var model_parameter = game.find_child("ModelParameter", true, false)
	var demo = model_parameter.get_parent()
	var factor: float = demo.factor
	demo.increase.pressed.emit()
	_check(demo.factor > factor, "El botón aumenta el parámetro didáctico")
	demo.decrease.pressed.emit()
	_check(is_equal_approx(demo.factor, factor), "El botón disminuye el parámetro didáctico")
	game._answer_subject(int(game.current_question["answer"]))
	await _inspect("resultado")
	for key in game.simulation.state["enrollments"].keys().duplicate():
		var entry: Dictionary = game.simulation.state["enrollments"][key]
		for partial in range(entry["answers"].size(), 3):
			game.simulation.answer(str(key), partial, not str(key).ends_with("SIS 1110"))
	game.simulation.close_term()
	game._show_campus_section("malla")
	var graph = game.find_child("ExpandedCurriculumGraph", true, false)
	graph.move_semester(2)
	await _inspect("malla con materia arrastrada")
	var retained := []
	for node in graph.visible_nodes:
		if node.get("retained", false):
			retained.append(node)
	_check(retained.size() == 1 and retained[0]["sigla"] == "SIS 1110" and retained[0]["semester"] == 1, "La malla posterior conserva la materia reprobada de primer semestre")
	_check(graph.personal_states["SIS 1110"].contains("recursar"), "Una reinscripción mantiene visible que es recursado")
	var mixed: Dictionary = game.simulation.snapshot().duplicate(true)
	var expected: int = game._campus()._current_graph_semester(mixed)
	mixed["subjects"].append({"program_id": "informatica", "mention_id": "desarrollo_sw", "semester": 9, "enrollment": {"answers": []}})
	_check(game._campus()._current_graph_semester(mixed) == expected, "Una materia externa no cambia el nivel consultado del plan propio")
	var zoom: float = graph.view_zoom
	var offset: Vector2 = graph.view_offset
	var wheel := InputEventMouseButton.new()
	wheel.button_index = MOUSE_BUTTON_WHEEL_DOWN
	wheel.pressed = true
	graph._gui_input(wheel)
	_check(graph.view_zoom < zoom, "La rueda aleja el grafo sin cambiar la selección")
	graph.fit_view()
	graph.pan_view(Vector2.LEFT)
	_check(graph.view_offset != offset, "Se puede explorar el entorno con botones")
	graph.zoom_at_center(1.15)
	graph.fit_view()
	_check(is_equal_approx(graph.view_zoom, zoom) and graph.view_offset.is_equal_approx(offset), "Encuadrar restaura la vista inicial sin rueda")
	game._show_options()
	var tabs: TabContainer = game.find_child("OptionsCategories", true, false)
	tabs.current_tab = 1
	_check(tabs.get_tab_title(1) == "Accesibilidad", "Opciones con pestañas por categoría")
	game._set_font_scale(0.8)
	_check(is_equal_approx(float(game.settings["font_scale"]), 0.8), "El botón permite texto al 80%")
	game._set_font_scale(1.2)
	_check(is_equal_approx(float(game.settings["font_scale"]), 1.2), "El botón permite texto al 120%")
	var options = game.find_child("TextScalePreview", true, false)
	_check(options != null and options.is_visible_in_tree() and options.text.contains("120%"), "Vista previa de letras actualizada sin perder la categoría")
	game._campus().open_office(game._show_solo_hub)
	game._campus()._new_request_form()
	await _settle()
	var chooser: Control
	for control in game.find_children("*", "Button", true, false):
		if control.get_script() == preload("res://scripts/choice_picker.gd") and control.item_count > 10:
			chooser = control
	_check(chooser != null, "La solicitud ofrece un selector largo con búsqueda")
	if chooser != null:
		chooser._open()
		await _settle()
		_check(chooser._results.get_child_count() <= 4, "El selector muestra grupos pequeños de opciones")
		chooser._change(1)
		_check(chooser._page == 1, "El selector largo avanza mediante botones")
		chooser._query = "FÍSICA"
		chooser._render()
		_check(chooser._matches.size() < chooser.item_count, "La búsqueda filtra las opciones")
		if not chooser._matches.is_empty():
			var chosen: int = chooser._matches[0]
			var key: String = chooser.get_item_metadata(chosen)
			chooser._choose(chosen)
			_check(game._campus().form_course == key, "La selección transmite el ID de materia al formulario")
	viewport.queue_free()
	await process_frame
	for failure in failures:
		push_error(failure)
	print("COMPACT_NAVIGATION_TESTS: %d assertions, %d failures" % [assertions, failures.size()])
	quit(0 if failures.is_empty() else 1)
