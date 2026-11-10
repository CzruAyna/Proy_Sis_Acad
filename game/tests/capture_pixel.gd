extends "res://tests/capture_frontend.gd"


func _run() -> void:
	target = "res://.test-artifacts/pixel/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(target))
	root.mode = Window.MODE_WINDOWED
	root.size = Vector2i(1152, 720)
	root.content_scale_size = Vector2i(1152, 720)
	game = PreviewGame.new()
	root.add_child(game)
	game.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	game._show_main()
	await _capture("01-inicio")
	game._show_options()
	await _capture("02-opciones")
	game._show_career_story()
	await _capture("03-historia")
	game.active_slot = 1
	game.draft_player_name = "Alex"
	game._show_new_solo()
	await _capture("04-carreras")
	game._show_mentions("informatica")
	await _capture("05-menciones")
	for pair in [["sistemas", "gestion_informacion"], ["informatica", "telematica"]]:
		var id: String = pair[1]
		game._create_solo_save(pair[0], id)
		await _capture(id + "-campus")
		game._show_campus_section("malla")
		await _capture(id + "-grafo")
		game._show_campus_section("materias")
		await _capture(id + "-materias")
		game._campus().open_office(game._show_solo_hub)
		await _capture(id + "-tramites")
		game._campus()._new_request_form()
		for frame in range(16):
			await process_frame
		game.find_child("PageNavigator", true, false).show_control(game.find_child("RequestReason", true, false))
		await _capture(id + "-formulario")
		var request: Dictionary = game.simulation.snapshot()["procedures"][0]
		game.simulation.pay("matricula")
		for index in range(3):
			var step: Dictionary = game.SimulationProcedures.current_step(game.simulation.procedure(str(request["id"])))
			game.simulation.advance_procedure(str(request["id"]), str(step["office"]))
		game.simulation.start_term()
		game._start_subject(str(game.simulation.state["enrollments"].keys()[0]))
		await _capture(id + "-estudio")
	root.size = Vector2i(900, 640)
	root.content_scale_size = Vector2i(900, 640)
	game.settings["font_scale"] = 1.2
	game._show_campus_section("malla")
	await _capture("18-grafo-900-letras120")
	game._show_options()
	await _capture("19-opciones-900-letras120")
	game.queue_free()
	await process_frame
	quit(0)
