extends SceneTree

class TestGame extends "res://scripts/game.gd":
	var writes: Array = []

	func _ready() -> void:
		settings["animations"] = false
		_setup_theme()
		_use_neutral_theme()

	func _save_profile() -> void:
		if not current_profile.is_empty():
			writes.append({"slot": active_slot, "profile": current_profile.duplicate(true)})

	func _save_global_profile() -> void:
		pass


var failures: Array[String] = []
var assertions := 0


func _initialize() -> void:
	_run.call_deferred()


func _check(condition: bool, description: String) -> void:
	assertions += 1
	if not condition:
		failures.append(description)


func _run() -> void:
	var game := TestGame.new()
	root.add_child(game)
	game.size = Vector2(1152, 720)
	game.active_slot = 1
	game.draft_player_name = "Prueba aislada"
	game._create_solo_save("sistemas", "gestion_sistemas")
	_check(game.simulation != null, "El controlador crea el motor")
	_check(game.simulation.state["enrollments"].size() == 5, "Hub recibe las cinco materias iniciales")
	_check(not game.has_method("_show_multi_slots") and not game.has_method("_show_team_hub"), "Multijugador retirado del controlador")
	_check(not game.has_method("_show_admin_interview") and not game.has_method("_show_dean_vote"), "Otros roles jugables retirados")
	game._show_simulation_console()
	await process_frame
	_check(is_instance_valid(game.simulation_console), "Consola de integración abre")
	var fields := game.simulation_console.find_children("*", "LineEdit", true, false)
	var outputs := game.simulation_console.find_children("*", "RichTextLabel", true, false)
	_check(fields.size() == 1 and outputs.size() == 1, "Consola ofrece entrada y resultados")
	if fields.size() == 1 and outputs.size() == 1:
		game._submit_simulation_command("/desbloquear todo", fields[0], outputs[0])
		_check(game.simulation.state["unlocked_all"], "Truco alcanza el motor y se guarda")
		_check(game.writes.back()["profile"]["simulation"]["unlocked_all"], "Truco persiste en perfil")
	game._show_simulation_console()
	_check(game.simulation_console == null, "F10 cierra y refresca hub")
	var request: Dictionary = game.simulation.open_procedure("matricula")
	_check(game.simulation.pay("matricula")["ok"], "Pago simulado")
	for index in range(3):
		var step: Dictionary = game.SimulationProcedures.current_step(game.simulation.procedure(request["request_id"]))
		_check(game.simulation.advance_procedure(request["request_id"], step["office"])["ok"], "Completar matrícula")
	game._run_simulation_action("/iniciar")
	_check(game.simulation.state["phase"] == "CURSANDO", "Control de inicio enlazado")
	var key := str(game.simulation.state["enrollments"].keys()[0])
	game._start_subject(key)
	_check(game.current_question.has("answer"), "Estudio usa el banco de preguntas")
	for partial in range(3):
		if partial > 0:
			game._show_exam()
		game._answer_subject(int(game.current_question["answer"]))
	_check(game.simulation.state["enrollments"][key]["score"] == 100.0, "Tres parciales generan nota final")
	_check(not game.current_profile["passed_subjects"].has(game.simulation.courses[key]["sigla"]), "El resultado espera al cierre semestral")
	var count: int = game.writes.size()
	game._answer_subject(0)
	_check(game.writes.size() == count, "Un doble clic no registra otro parcial")
	game._show_solo_hub()
	game._show_curriculum_graph("sistemas", true)
	game._show_solo_hub()
	game._begin_new_game(2)
	_check(game.current_profile.is_empty() and game.simulation == null, "Nueva partida limpia perfil antes de cambiar espacio")
	_check(game.writes.back()["slot"] == 1, "Partida anterior se guarda en su espacio")
	game._return_to_menu()
	_check(game.active_slot == 0, "Salir sin nueva partida no copia el perfil anterior")
	game.queue_free()
	await process_frame
	for failure in failures:
		push_error(failure)
	print("GAME_INTEGRATION_TESTS: %d assertions, %d failures" % [assertions, failures.size()])
	quit(0 if failures.is_empty() else 1)
