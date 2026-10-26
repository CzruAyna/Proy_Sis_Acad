extends SceneTree

class PreviewGame extends "res://scripts/game.gd":
	func _ready() -> void:
		settings["animations"] = false
		settings["fullscreen"] = false
		random.seed = 42
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


var game: Control
var target := "res://.test-artifacts/frontend/"


func _initialize() -> void:
	_run.call_deferred()


func _capture(name: String) -> void:
	for index in range(4):
		await process_frame
	await RenderingServer.frame_post_draw
	var output := root.get_texture().get_image()
	var result := output.save_png(target + name + ".png")
	if result != OK:
		push_error("No se pudo generar " + name)
	print("CAPTURE ", name, " ", output.get_size())


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(target))
	root.mode = Window.MODE_WINDOWED
	root.size = Vector2i(1152, 720)
	root.content_scale_size = Vector2i(1152, 720)
	game = PreviewGame.new()
	root.add_child(game)
	game.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	game._show_main()
	await _capture("01-inicio")
	game.active_slot = 1
	game.draft_player_name = ""
	game._show_new_solo()
	await _capture("02a-nombre-obligatorio")
	game._choose_new_program("sistemas")
	await _capture("02b-nombre-requerido")
	game.draft_player_name = "Alex"
	game._show_new_solo()
	await _capture("02-nueva-carrera")
	game._show_mentions("sistemas")
	await _capture("03-menciones")
	game._create_solo_save("sistemas", "gestion_sistemas")
	await _capture("04-campus")
	game._show_campus_section("materias")
	await _capture("05-materias")
	var request: Dictionary = game.simulation.snapshot()["procedures"][0]
	game._campus().open_request(str(request["id"]))
	await _capture("06-matricula")
	game._campus()._new_request_form()
	await _capture("07-solicitud")
	game._show_campus_section("malla")
	await _capture("08-malla")
	game.simulation.pay("matricula")
	for index in range(3):
		var step: Dictionary = game.SimulationProcedures.current_step(game.simulation.procedure(str(request["id"])))
		game.simulation.advance_procedure(str(request["id"]), str(step["office"]))
	game.simulation.start_term()
	game._start_subject(str(game.simulation.state["enrollments"].keys()[0]))
	await _capture("09-estudio")
	game._show_campus_section("auxiliatura")
	await _capture("10-auxiliatura")
	game._show_campus_section("graduacion")
	await _capture("11-graduacion")
	game.current_profile = {}
	game.simulation = null
	game.settings["font_scale"] = 1.2
	game._show_mentions("sistemas")
	await _capture("12-menciones-texto120")
	game.settings["font_scale"] = 1.0
	game._show_global_achievements()
	await _capture("13-catalogo-logros")
	var achievements_scroll: ScrollContainer = game.find_child("PageScroll", true, false)
	achievements_scroll.scroll_vertical = int(achievements_scroll.get_v_scroll_bar().max_value)
	await _capture("14-logros-ocultos")
	game.queue_free()
	await process_frame
	quit(0)
