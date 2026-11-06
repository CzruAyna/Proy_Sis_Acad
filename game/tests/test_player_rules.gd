extends SceneTree

const Achievements = preload("res://scripts/achievement_catalog.gd")

class TestGame extends "res://scripts/game.gd":
	var writes := 0

	func _ready() -> void:
		settings["animations"] = false
		_setup_theme()
		_use_neutral_theme()

	func _save_profile() -> void:
		if not current_profile.is_empty():
			writes += 1
			_refresh_global_achievements()

	func _save_global_profile() -> void:
		pass

	func _read_save(_slot: int, _mode: String) -> Dictionary:
		return {}


var failures: Array[String] = []
var assertions := 0


func _initialize() -> void:
	_run.call_deferred()


func _check(condition: bool, message: String) -> void:
	assertions += 1
	if not condition:
		failures.append(message)


func _buttons(game: Control, title: String) -> Array:
	var result := []
	for button in game.find_children("*", "Button", true, false):
		if button.text == title:
			result.append(button)
	return result


func _run() -> void:
	_test_achievement_catalog()
	var game := TestGame.new()
	root.add_child(game)
	game.size = Vector2(1152, 720)
	game.active_slot = 1
	game._show_new_solo()
	var buttons := _buttons(game, "Explorar menciones")
	_check(buttons.size() == 2 and buttons[0].disabled and buttons[1].disabled, "Las carreras exigen un nombre antes de avanzar")
	game.draft_player_name = " \t "
	game._choose_new_program("sistemas")
	_check(game.find_child("StudentNameError", true, false).visible, "La selección directa valida nombre vacío y espacios")
	game._create_solo_save("sistemas", "gestion_sistemas")
	_check(game.current_profile.is_empty() and game.writes == 0, "No se crea una partida con nombre vacío ni se usa Estudiante como reemplazo")
	game._choose_faculty_from_field(game.find_child("StudentName", true, false))
	_check(game.find_child("StudentName", true, false) != null and game.current_profile.is_empty(), "Enter tampoco evita la validación")
	var field: LineEdit = game.find_child("StudentName", true, false)
	field.text = "  María López  "
	field.text_changed.emit(field.text)
	buttons = _buttons(game, "Explorar menciones")
	_check(not buttons[0].disabled and not buttons[1].disabled, "Un nombre válido habilita ambas carreras")
	game._choose_new_program("sistemas")
	game._show_new_solo()
	_check(game.find_child("StudentName", true, false).text == "María López", "El nombre normalizado se conserva al volver")
	game._create_solo_save("sistemas", "gestion_sistemas")
	_check(game.current_profile.get("player_name") == "María López", "Se guarda el nombre elegido sin espacios de borde")
	_check(_buttons(game, "Organizar mis materias").is_empty() and _buttons(game, "Ver mis materias iniciales").size() == 1, "El campus inicial presenta asignación automática")
	game._show_campus_section("materias")
	_check(_buttons(game, "Retirar del semestre").is_empty() and _buttons(game, "Inscribir").is_empty(), "El primer semestre no ofrece acciones de planificación")
	var model: RefCounted = game.simulation
	var request: Dictionary = model.open_procedure("matricula")
	model.pay("matricula")
	for index in range(3):
		var step: Dictionary = game.SimulationProcedures.current_step(model.procedure(request["request_id"]))
		_check(model.advance_procedure(request["request_id"], step["office"])["ok"], "Matrícula del primer semestre")
	_check(model.start_term()["ok"], "Inicio sin planificación manual")
	for key in model.state["enrollments"].keys():
		for index in range(3):
			model.answer(str(key), index, false)
	_check(model.close_term()["ok"], "Cierre del primer semestre")
	game._show_solo_hub()
	_check(_buttons(game, "Organizar mis materias").size() == 1, "Desde el segundo semestre se presenta planificación")
	game._show_campus_section("materias")
	_check(not _buttons(game, "Retirar del semestre").is_empty(), "Segundo semestre consume la planificación disponible del motor")
	game._show_global_achievements()
	var catalog := Achievements.presentation(game.global_profile)
	for item in catalog["public"]:
		_check(game.find_child("Achievement_" + str(item["id"]), true, false) != null, "Logro público visible aunque esté pendiente: " + str(item["id"]))
	for item in Achievements.definitions():
		if item["hidden"]:
			_check(game.find_child("Achievement_" + str(item["id"]), true, false) == null, "Un secreto pendiente no revela su nombre: " + str(item["id"]))
	model.unlock_all()
	game._show_global_achievements()
	_check(game.find_child("Achievement_secret_map", true, false) != null, "El secreto se revela al cumplir su condición")
	game._return_to_menu()
	game._show_global_achievements()
	_check(game.find_child("Achievement_secret_map", true, false) != null, "El logro oculto permanece después de salir de la partida")
	game.queue_free()
	await process_frame
	for failure in failures:
		push_error(failure)
	print("PLAYER_RULES_TESTS: %d assertions, %d failures" % [assertions, failures.size()])
	quit(0 if failures.is_empty() else 1)


func _test_achievement_catalog() -> void:
	var profile := {}
	_check(Achievements.evaluate(profile), "Se inicializa catálogo global")
	var empty := Achievements.presentation(profile)
	_check(empty["public"].size() == 12 and empty["public_unlocked"] == 0, "Todos los logros públicos existen antes de ganar el primero")
	_check(empty["secrets"].is_empty() and empty["hidden_total"] == 4, "Los secretos pendientes solo muestran su cantidad")
	_check(not Achievements.evaluate(profile), "Evaluar sin cambios no duplica logros ni provoca guardados")
	var run := {"program_id": "sistemas", "mention_id": "gestion_sistemas", "simulation": {"history": [
		{"course_id": "sistemas/gestion_sistemas/MAT 1101", "term": 1, "passed": false, "origin": "ORDINARIA"},
		{"course_id": "sistemas/gestion_sistemas/MAT 1101", "term": 2, "passed": true, "origin": "ORDINARIA"}
	], "assignments": []}}
	_check(Achievements.evaluate(profile, run), "Los resultados cerrados conceden logros")
	_check(profile["achievement_ids"].has("retry") and profile["achievement_ids"].has("first_subject"), "Se reconoce recursado aprobado")
	_check(profile["achievement_ids"].has("secret_comeback"), "Una remontada completa concede su secreto")
	var saved: Dictionary = JSON.parse_string(JSON.stringify(profile))
	_check(not Achievements.evaluate(saved, run), "Los logros se conservan sin duplicarse tras JSON")
	var mixed := {"simulation": {"history": [
		{"course_id": "sistemas/gestion_sistemas/MAT 1101", "term": 2, "passed": false, "origin": "ORDINARIA"},
		{"course_id": "sistemas/gestion_sistemas/MAT 1102", "term": 2, "passed": true, "origin": "CORRELATIVA"}
	]}}
	Achievements.evaluate(profile, mixed)
	_check(profile["achievement_ids"].has("secret_correlative"), "Resultados independientes descubren un secreto")
	var provisional := {"simulation": {"enrollments": {"A": {"score": 100.0}}, "history": []}}
	var pending := {}
	Achievements.evaluate(pending, provisional)
	_check(pending["achievement_ids"].is_empty(), "Una nota provisional no concede logros de aprobación")
	var old := {"achievements": ["Ritmo constante · aprobaste cinco materias en total", "Un logro antiguo"], "completed_programs": ["sistemas", "informatica"]}
	Achievements.evaluate(old)
	_check(old["achievement_ids"].has("steady"), "Se migran logros guardados por título")
	_check(old["achievement_ids"].has("explorer"), "El logro de explorar carreras es alcanzable con las dos carreras existentes")
	_check(Achievements.presentation(old)["legacy"].has("Un logro antiguo"), "Se conservan logros de versiones anteriores")
	Achievements.evaluate(profile, {"simulation": {"assignments": [{"status": "CUMPLIDA"}]}})
	_check(profile["achievement_ids"].has("assistant") and profile["achievement_ids"].has("assistant_work"), "Auxiliatura y trabajo cumplido conceden logros distintos")
	var ids := {}
	for item in Achievements.definitions():
		_check(not ids.has(item["id"]), "Identificador de logro único")
		ids[item["id"]] = true
