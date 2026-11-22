extends SceneTree

const Daily = preload("res://scripts/campus_daily.gd")
const Classes = preload("res://scripts/campus_classes.gd")
const World = preload("res://scripts/campus_world.gd")
const Map = preload("res://scripts/campus_map.gd")

class TestGame extends "res://scripts/game.gd":
	func _ready() -> void:
		settings["animations"] = false
		_setup_theme()
		_use_neutral_theme()

	func _save_profile() -> void:
		pass

	func _save_global_profile() -> void:
		pass

	func _save_settings() -> void:
		pass

	func _read_save(_slot: int, _mode: String) -> Dictionary:
		return {}

var _errors: Array[String] = []
var _count := 0
var _game: Control
var _viewport: SubViewport
var _capture := OS.get_cmdline_user_args().has("--capture")


func _initialize() -> void:
	_run.call_deferred()


func _check(condition: bool, message: String) -> void:
	_count += 1
	if not condition:
		_errors.append(message)
		push_error(message)


func _click(label: String) -> void:
	for button in _game.find_children("*", "Button", true, false):
		if button.text == label and not button.disabled:
			button.pressed.emit()
			return
	_check(false, "Falta el botón " + label)


func _click_prefix(prefix: String) -> void:
	for button in _game.find_children("*", "Button", true, false):
		if button.text.begins_with(prefix) and not button.disabled:
			button.pressed.emit()
			return
	_check(false, "Falta la acción " + prefix)


func _key(code: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = true
	_viewport.push_input(event, true)
	event.pressed = false
	_viewport.push_input(event, true)
	for frame in 8:
		await process_frame


func _picture(name: String) -> void:
	if not _capture:
		return
	for index in 10:
		await process_frame
	await RenderingServer.frame_post_draw
	var directory := ProjectSettings.globalize_path("res://.test-artifacts/campus-routine")
	DirAccess.make_dir_recursive_absolute(directory)
	_check(_viewport.get_texture().get_image().save_png(directory.path_join(name + ".png")) == OK, "Guardar captura " + name)


func _check_economy() -> void:
	var daily := Daily.new()
	daily.advance(Daily.WEEK - Daily.START - 1)
	_check(daily.balance == Daily.ALLOWANCE, "El saldo espera al primer cambio de semana.")
	daily.advance(1)
	_check(daily.balance == 2 * Daily.ALLOWANCE, "Cruzar el límite recibe una asignación.")
	_check(daily.hunger == 100.0 and daily.thirst == 100.0, "Las necesidades crecen y tienen límite.")
	var restored := Daily.new()
	restored.restore(JSON.parse_string(JSON.stringify(daily.snapshot())))
	restored.advance(1)
	_check(restored.balance == daily.balance, "Recargar no vuelve a pagar la semana.")
	restored.buy("pollo", "pollo")
	restored.consume("pollo")
	_check(restored.load_count() == 0 and restored.balance == daily.balance - 9 and restored.hunger == 42.0, "Comprar y consumir muta saldo, carga y hambre.")
	for index in Daily.CAPACITY + 1:
		restored.buy("cafe", "agua")
	_check(restored.load_count() == Daily.CAPACITY, "La mochila rechaza exceso de carga.")
	restored.consume("agua")
	_check(restored.thirst == 55.0 and restored.load_count() == Daily.CAPACITY - 1, "Consumir agua libera espacio y reduce la sed.")
	var bottles := Daily.new()
	bottles.student_trait = "Miopía"
	_check(bottles.needs_glasses(), "La miopía requiere equipar lentes.")
	bottles.buy("tienda", "lentes")
	bottles.consume("lentes")
	_check(not bottles.needs_glasses(), "Los lentes equipados permiten leer la pizarra.")
	var before := restored.snapshot()
	restored.buy("kiosco", "pollo")
	_check(restored.snapshot() == before, "El catálogo del puesto controla la venta.")
	restored.balance = 0
	restored.buy("pollo", "pollo")
	_check(restored.load_count() == Daily.CAPACITY - 1, "Sin saldo no se agrega el producto.")


func _run() -> void:
	_check_economy()
	var row := {"day": 2, "start": 570, "seed": 15}
	for week in 32:
		var session := Classes.appointment(row, week)
		var next := Classes.next_start(row, week * Daily.WEEK)
		_check(next >= week * Daily.WEEK and next < (week + 2) * Daily.WEEK, "El calendario siempre ofrece una siguiente clase.")
		_check(session["exam"] == (week % 3 == 2), "Los exámenes corresponden a la semana anunciada.")

	_viewport = SubViewport.new()
	_viewport.size = Vector2i(1200, 780)
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(_viewport)
	_game = TestGame.new()
	_viewport.add_child(_game)
	_game.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_game.active_slot = 1
	_game.draft_player_name = "Estudiante de prueba"
	_game._create_solo_save("sistemas", "gestion_sistemas")
	_game._show_campus_section("materias")
	_click("Ver mi horario")
	var rows := Classes.schedule(_game.simulation.snapshot())
	for lesson in rows:
		_check(Classes.conflicts(lesson, rows).is_empty(), "El horario de ingreso carece de choques.")
	var next_term: Dictionary = _game.simulation.snapshot()
	next_term["term"] = 2
	var later := Classes.schedule(next_term)
	var chosen := str(later[0]["course"])
	for subject in next_term["subjects"]:
		if subject["id"] == chosen:
			subject["enrollment"]["parallel"] = 1
	var revised := Classes.schedule(next_term)
	_check(revised[0]["day"] != later[0]["day"] and revised[0]["parallel"] == "B", "Cambiar de paralelo cambia la cita del segundo semestre.")
	_check(revised == Classes.schedule(next_term), "Consultar de nuevo el horario conserva los paralelos.")
	_check(rows.size() == 5, "Cada materia inscrita aparece en el horario.")
	_check(rows[0]["lines"] != rows[1]["lines"], "Cada materia usa contenido propio.")
	_check(Classes.active(rows, rows[0]["room"], 570.0)["key"] == rows[0]["key"], "El horario activa la clase al comienzo de su franja.")
	_check(Classes.active(rows, rows[0]["room"], 630.0).is_empty(), "La clase termina al salir de la franja.")
	await _picture("02-horario")

	_game._show_exploration()
	var world := _game.find_child("CampusWorld", true, false) as Control
	await process_frame
	_check(world.size.is_equal_approx(Vector2(_viewport.size)), "El recorrido ocupa toda la superficie del juego.")
	await _picture("12-campus-completo")
	for workshop in Classes.workshops():
		_check(Map.room_floor(workshop["building"], workshop["room"]) >= 0 and workshop["lines"].size() >= 3, "Cada taller tiene puerta, piso y lección.")
	var tracker := _game.find_child("CampusSupplies", true, false) as Label
	_check(tracker.get_global_rect().end.y < world.size.y / 3, "Hambre y sed permanecen visibles en la cabecera.")
	var positions := World.vendor_positions()
	_check(positions.values().has(Map.SPAWN) == false, "Los puestos tienen ubicaciones propias en el mapa.")
	for id: String in positions:
		world.player = positions[id]
		_check(world.nearby_vendor() == id and world.nearby_building().is_empty() and world._can_stand_outside(positions[id]), "El puesto %s tiene punto transitable e interacción." % id)
	world.player = positions["camion"]
	await _key(KEY_E)
	_check(_game.find_child("CampusWorld", true, false) == null, "E abre el puesto cercano.")
	_check(_game.find_child("CampusSupplies", true, false) == null, "El puesto tiene su propia pantalla.")
	await _key(KEY_DOWN)
	await _key(KEY_ENTER)
	await _picture("05-puesto")
	await _key(KEY_TAB)
	var pocket := _game.find_child("PageContent", true, false)
	_check(pocket != null and pocket.get_meta("backpack_section", -1) == 0, "Tab desde el puesto abre alimentos.")
	_check(_game.current_profile["campus_exploration"]["daily"]["backpack"].get("milanesa", 0) == 1, "Comprar en el puesto guarda el producto.")
	await _key(KEY_DOWN)
	await _picture("08-mochila-con-producto")
	await _key(KEY_ENTER)
	_check(_game.current_profile["campus_exploration"]["daily"]["backpack"].is_empty(), "Consumir desde la mochila guarda la carga.")

	_game._show_exploration()
	world = _game.find_child("CampusWorld", true, false) as Control
	world.player = Map.building("decanato")["door"]
	world.interact()
	world.player = Vector2(146, 82)
	world.interact()
	await process_frame
	_click("Abrir expediente")
	_check(_game.find_child("ProcedureDetail", true, false) != null, "Decanato abre el expediente con sus requisitos.")
	await _picture("01-decanato")

	_game._campus()._leave_office()
	world = _game.find_child("CampusWorld", true, false) as Control
	world.enter_room(Classes.BUILDING, str(rows[0]["room"]))
	world.player = Vector2(146, 82)
	world.interact()
	await process_frame
	_click("Esperar aquí hasta la clase")
	if _game._explorer()._daily().needs_glasses():
		_click("Pedir lentes prestados y ponérmelos")
	var board := _game.find_child("LiveClassBoard", true, false)
	_check(board != null, "La pizarra abre tras esperar en el aula asignada.")
	if board != null:
		var writing := board.get_node("LiveClassWriting") as Label
		_check(writing.text == str(rows[0]["lines"][0]), "La clase comienza con el primer apunte.")
		var timer := board.find_children("*", "Timer", true, false)[0] as Timer
		for index in rows[0]["lines"].size() - 1:
			timer.timeout.emit()
		_check(writing.text == "\n".join(rows[0]["lines"]), "La clase revela los apuntes por etapas.")
		if _game.find_children("*", "Button", true, false).any(func(b: Button) -> bool: return b.text == "Copiar apunte"):
			_click("Copiar apunte")
		_check(_game.current_profile["campus_exploration"]["daily"]["notes"].has(rows[0]["key"]), "La clase completa guarda el apunte.")
		await _picture("03-clase")
	_game._show_exploration()
	await _key(KEY_TAB)
	await _key(KEY_RIGHT)
	pocket = _game.find_child("PageContent", true, false)
	_check(pocket.get_meta("backpack_section", -1) == 1, "Flecha derecha abre carpetas.")
	await _key(KEY_3)
	pocket = _game.find_child("PageContent", true, false)
	_check(pocket.get_meta("backpack_section", -1) == 2, "3 abre los apuntes.")
	await _picture("04-mochila")
	await _key(KEY_TAB)
	_check(_game.find_child("CampusWorld", true, false) != null, "Tab cierra la mochila y retoma el recorrido.")
	_check(_game.current_profile["campus_exploration"]["daily"]["notes"].has(rows[0]["key"]), "La mochila conserva el apunte tras cambiar de pantalla.")
	_game._show_exploration()
	world = _game.find_child("CampusWorld", true, false) as Control
	_check(world.daily.notes.has(rows[0]["key"]), "Al volver al aula se restaura el apunte en el mundo.")
	world.player = Vector2(146, 82)
	world.camera = world.player
	world.queue_redraw()
	await _picture("06-aula")
	await _key(KEY_ESCAPE)
	_check(_game.find_child("CampusWorld", true, false) == null, "Esc abre la pausa del recorrido.")
	await _key(KEY_ESCAPE)
	_check(_game.find_child("CampusWorld", true, false) != null, "Esc sale de pausa sin abrir otra pantalla.")
	await _key(KEY_M)
	_check(_game.find_child("CampusOverview", true, false) != null, "M abre el mapa.")
	await _key(KEY_M)
	_check(_game.find_child("CampusWorld", true, false) != null, "M cierra el mapa.")
	_game._explorer().mark_building(Classes.BUILDING)
	var overview := _game.find_child("CampusOverview", true, false)
	_check(overview != null and overview.destination == Map.building(Classes.BUILDING)["door"], "La guía marca la puerta en el mapa.")
	await _picture("07-mapa")
	_game._show_exploration()
	await _key(KEY_C)
	await _picture("08-celular")
	_click("Mi historia")
	await _picture("09-historia")
	var model: RefCounted = _game.simulation
	model.pay("matricula")
	var request: Dictionary = model.snapshot()["procedures"][0]
	for office in ["Caja", "Kardex", "Cómputo"]:
		model.advance_procedure(request["id"], office)
	model.start_term()
	_game._show_exploration()
	world = _game.find_child("CampusWorld", true, false) as Control
	world.enter_room(Classes.BUILDING, str(rows[0]["room"]))
	world.player = Vector2(146, 82)
	world.interact()
	await process_frame
	if _game.find_child("LiveClassBoard", true, false) == null:
		_click("Esperar aquí hasta la clase")
	_click("Resolver tarea de aula")
	_click(str(rows[0]["lines"][0]))
	_check(_game.current_profile["campus_exploration"]["daily"]["tasks"].has(rows[0]["key"]), "La tarea completada queda en el recorrido.")
	_click_prefix("Esperar al examen")
	_click("Rendir parcial")
	_check(not _game.current_question.is_empty(), "El examen abre desde la pizarra en la fecha anunciada.")
	await _picture("10-examen")
	if _game.current_question.is_empty():
		quit(1)
		return
	_game._answer_subject(int(_game.current_question["answer"]))
	var enrollment: Dictionary = model.state["enrollments"][rows[0]["course"]]
	_check(enrollment["answers"] == [100.0] and enrollment.get("last_assessment_week", -1) == 2, "El parcial se registra en la semana programada.")
	for lesson in rows:
		if lesson["code"] == "SIS 1110":
			_game._start_subject(lesson["course"])
			_game._project_draft(int(_game.current_question["answer"]))
			await _picture("11-proyecto")
			_game._deliver_project(0)
			_check(model.state["enrollments"][lesson["course"]]["answers"] == [100.0], "La propuesta y el hito registran un único avance evaluado.")
	_game._show_exploration()
	world = _game.find_child("CampusWorld", true, false) as Control
	var practice := Classes.workshops()[6]
	world.daily.student_trait = "Miopía"
	world.daily.equipment.erase("lentes")
	world.daily.minutes = Classes.appointment(practice, 0)["start"]
	world.enter_room("fis_mat", practice["room"])
	world.player = Vector2(146, 82)
	world.interact()
	await process_frame
	_check(_game.find_child("LiveClassBoard", true, false) == null, "El taller requiere lentes a quien tiene miopía.")
	_click("Pedir lentes prestados y ponérmelos")
	_check(_game.find_child("LiveClassBoard", true, false) != null, "El laboratorio del Bloque 100 imparte clase con los lentes puestos.")
	await _picture("13-taller")
	_viewport.queue_free()
	await process_frame
	print("CAMPUS_ROUTINE_TESTS: %d assertions, %d failures" % [_count, _errors.size()])
	quit(0 if _errors.is_empty() else 1)
