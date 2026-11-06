extends SceneTree

const Story = preload("res://scripts/career_story.gd")
const Catalog = preload("res://scripts/catalog.gd")
const Graph = preload("res://scripts/curriculum_graph.gd")
const Routing = preload("res://scripts/graph_routing.gd")

class PreviewGame extends "res://scripts/game.gd":
	var writes := 0
	func _ready() -> void:
		settings["animations"] = false
		settings["fullscreen"] = false
		_setup_theme()
	func _save_profile() -> void:
		writes += 1
	func _save_global_profile() -> void:
		writes += 1
	func _save_settings() -> void:
		writes += 1
	func _read_save(_slot: int, _mode: String) -> Dictionary:
		return {}

var assertions := 0
var failures: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func _check(value: bool, message: String) -> void:
	assertions += 1
	if not value:
		failures.append(message)


func _run() -> void:
	var runner := Story.new()
	_check(not runner.generate("  ", "sistemas", "gestion_sistemas")["ok"], "Rechaza nombre vacío")
	_check(not runner.generate("Alex", "sistemas", "inexistente")["ok"], "Rechaza plan desconocido")
	_check(not runner.generate("Alex", "sistemas", "gestion_sistemas", "desconocido")["ok"], "Rechaza enfoque desconocido")
	var modes := {}
	var found_aux := false
	var found_retry := false
	var found_carta := false
	var found_correlative := false
	var examples := {}
	for program in Catalog.PROGRAMS:
		for mention in program["mentions"]:
			for seed_value in range(20):
				var style: String = Story.APPROACHES.keys()[seed_value % 3]
				var report := runner.generate(" Alex ", program["id"], mention["id"], style, seed_value)
				_check(report["complete"], "Termina el plan %s semilla %d: %s" % [mention["id"], seed_value, report["message"]])
				_check(report["player_name"] == "Alex" and report["terms"] > 1, "Nombre normalizado y recorrido de varios periodos")
				_check(report["terms"] <= Story.MAX_TERMS, "Recorrido acotado")
				modes[report["graduation_mode"]] = true
				examples[report["graduation_mode"]] = report
				if report["graduation_mode"] == "excelencia":
					_check(not report["had_failure"] and float(report["average"]) > 65, "Excelencia respeta las reglas")
				var approvals := {}
				for item in report["chapters"]:
					for result in item["results"]:
						_check(result["passed"] == (float(result["score"]) >= 51), "La narración coincide con la nota del motor")
						if result["retake"] and result["passed"]:
							found_retry = true
						if result["passed"]:
							approvals[result["sigla"]] = true
						_check(result["chance"] > 0 and result["chance"] < 1, "Probabilidades válidas sin éxito garantizado")
					for code in item["states"]:
						_check((item["states"][code] == "Aprobada") == approvals.has(code), "El grafo no adelanta aprobaciones de capítulos futuros")
					for event in item["events"]:
						found_aux = found_aux or event["kind"] == "designacion"
						found_carta = found_carta or event["kind"] == "carta"
						found_correlative = found_correlative or event["kind"] == "correlativa"
						if item["term"] == 1:
							_check(event["kind"] != "planificacion", "Primer periodo sin planificación")
				_check(runner.model.state["graduated"] and not runner.model.state["unlocked_all"], "Titula mediante el motor, sin trucos")
				var final_request: Dictionary = runner.model.state["procedures"][-1]
				_check(final_request["status"] == "COMPLETADO", "Expediente de título completo")
				_check(runner.model._valid_document("titulo", str(final_request["id"])), "Título emitido por el trámite")
	_check(modes.has("excelencia") and modes.has("tesis") and modes.has("proyecto"), "La muestra cubre las tres modalidades")
	_check(found_aux and found_retry and found_carta and found_correlative, "La muestra demuestra auxiliatura, recuperación, carta y correlativas")
	var first := runner.generate("Ana", "sistemas", "gestion_sistemas", "constancia", 43)
	var same := runner.generate("Ana", "sistemas", "gestion_sistemas", "constancia", 43)
	_check(first == same, "La misma semilla reproduce toda la historia")
	var other_name := runner.generate("Luis", "sistemas", "gestion_sistemas", "constancia", 43)
	_check(first["history"] == other_name["history"], "El nombre personaliza el texto y no decide las notas")
	_check(JSON.parse_string(JSON.stringify(first)) is Dictionary, "Informe serializable")
	var graph := Graph.new()
	graph.animations_enabled = false
	root.add_child(graph)
	graph.size = Vector2(1090, 420)
	graph.setup("sistemas", "gestion_sistemas", 1090)
	for turn in range(12):
		_check(graph.rotate_branch(PI / 6), "La rama gira libremente con conexiones seguras")
		_check(Routing.valid(graph.visible_nodes, graph.edges, graph.edge_paths, graph._radii()), "El giro conserva separación de esferas y aristas")
	var point: Vector2 = graph.visible_nodes[0]["pos"]
	_check(graph._move_branch(0, point + Vector2(650, 350)), "Traslada toda la rama fuera del encuadre inicial")
	graph.fit_view()
	for node in graph.visible_nodes:
		_check(Rect2(Vector2.ZERO, graph.size).has_point(Vector2(node["pos"]) * graph.view_zoom + graph.view_offset), "Ver todo encuadra la distribución trasladada")
	_check(not graph._move_branch(0, Vector2(INF, NAN)), "Rama rechaza coordenadas inválidas")
	graph.free()
	var game := PreviewGame.new()
	root.add_child(game)
	game.size = Vector2(1152, 720)
	game._show_main()
	game._show_simulate()
	_check(game.find_child("CareerStoryEntry", true, false) != null, "La historia es accesible dentro de Simular")
	game._show_career_story()
	var ui = game.career_story_ui
	var field: LineEdit = game.find_child("StoryPlayerName", true, false)
	var generate: Button = game.find_child("GenerateCareerStory", true, false)
	_check(generate.disabled, "Generación deshabilitada sin nombre")
	field.text = "Eva"
	field.text_changed.emit("Eva")
	_check(not generate.disabled, "Un nombre habilita la generación")
	ui.create_story(2)
	_check(game.find_child("CareerStoryNarrative", true, false) != null, "Historia visible")
	ui.show_graph()
	_check(game.find_child("StoryCurriculumGraph", true, false) != null, "Grafo visible")
	ui.show_learning()
	ui.show_subject(ui.report["chapters"][0]["results"][0])
	_check(game.find_child("InteractiveModel", true, false) != null, "Incluye modelo didáctico")
	ui.show_summary()
	_check(game.current_profile.is_empty() and game.simulation == null and game.writes == 0, "Demostración no escribe partidas ni logros")
	game.queue_free()
	await process_frame
	for failure in failures:
		push_error(failure)
	print("CAREER_STORY_TESTS: %d assertions, %d failures" % [assertions, failures.size()])
	quit(0 if failures.is_empty() else 1)
