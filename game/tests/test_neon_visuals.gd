extends SceneTree

const Catalog = preload("res://scripts/catalog.gd")

class PreviewGame extends "res://scripts/game.gd":
	func _ready() -> void:
		settings["animations"] = false
		_setup_theme()
		_use_neutral_theme()

	func _save_profile() -> void:
		pass

	func _save_global_profile() -> void:
		pass

	func _read_save(_slot: int, _mode: String) -> Dictionary:
		return {}


var failures: Array[String] = []
var assertions := 0


func _initialize() -> void:
	_run.call_deferred()


func _check(value: bool, message: String) -> void:
	assertions += 1
	if not value:
		failures.append(message)


func _run() -> void:
	var game := PreviewGame.new()
	root.add_child(game)
	game.size = Vector2(1152, 720)
	game.active_slot = 1
	game.draft_player_name = "Prueba visual aislada"
	var motifs: Array[String] = []
	for program in Catalog.PROGRAMS:
		var pid := str(program["id"])
		for mention in Catalog.mentions_for_program(pid):
			var mid := str(mention["id"])
			game._create_solo_save(pid, mid)
			var initial := JSON.stringify(game.simulation.snapshot())
			for section in ["resumen", "materias", "tramites", "historial", "auxiliatura", "graduacion", "malla"]:
				game._show_campus_section(section)
				await process_frame
				var theme: Dictionary = game._current_theme
				_check(theme["program_id"] == pid and theme["mention_id"] == mid, "Tema conserva carrera y mención en " + section)
				var accent: Color = theme["accent"]
				_check(accent.b > accent.r * 1.5 if pid == "sistemas" else accent.r > accent.b * 1.5, "Azul Sistemas / rojo Informática en " + section)
				var border := game._button_style(true, "normal").border_color
				_check(border.b > border.r if pid == "sistemas" else border.r > border.b, "Controles conservan el color de carrera")
			motifs.append(str(game._current_theme["motif"]["kind"]))
			game._show_titles()
			_check(game._current_theme["program_id"] == pid, "Logros de la partida conserva la paleta")
			_check(initial == JSON.stringify(game.simulation.snapshot()), "Cambiar de interfaz y fondo no altera el motor")
			game.settings["low_performance"] = true
			game._show_campus_section("malla")
			_check(game._card_style(true).shadow_size <= 4, "Bajo consumo reduce el resplandor costoso")
			game.settings["low_performance"] = false
	_check(motifs.size() == 5 and not motifs.has(""), "Cinco menciones con temática")
	var unique := {}
	for motif in motifs:
		unique[motif] = true
	_check(unique.size() == 5, "Cada mención tiene un motivo de fondo diferente")
	game._return_to_menu()
	_check(game._visual_program_id.is_empty() and game._visual_mention_id.is_empty(), "El inicio no hereda la carrera anterior")
	game.queue_free()
	await process_frame
	for failure in failures:
		push_error(failure)
	print("NEON_VISUAL_TESTS: %d assertions, %d failures" % [assertions, failures.size()])
	quit(0 if failures.is_empty() else 1)
