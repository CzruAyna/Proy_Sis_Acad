extends "res://tests/capture_frontend.gd"


func _run() -> void:
	target = "res://.test-artifacts/neon/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(target))
	root.mode = Window.MODE_WINDOWED
	root.size = Vector2i(1152, 720)
	root.content_scale_size = Vector2i(1152, 720)
	game = PreviewGame.new()
	root.add_child(game)
	game.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	game._show_main()
	await _capture("00-inicio-neon")
	game._show_options()
	await _capture("02-opciones-explicadas")
	var options_pages = game.find_child("PageNavigator", true, false)
	options_pages.change_page(options_pages.page_offsets.size() - 1)
	await _capture("03-opciones-letras")
	game.active_slot = 1
	game.draft_player_name = "Alex"
	game._show_new_solo()
	await _capture("01-carreras")
	var catalog = load("res://scripts/catalog.gd")
	for program in catalog.PROGRAMS:
		var pid := str(program["id"])
		game.current_profile = {}
		game.simulation = null
		game._show_mentions(pid)
		await _capture(pid + "-menciones")
		for mention in catalog.mentions_for_program(pid):
			var mid := str(mention["id"])
			game._create_solo_save(pid, mid)
			await _capture(mid + "-campus")
			game._show_campus_section("malla")
			await _capture(mid + "-grafo")
			var graph = game.find_child("ExpandedCurriculumGraph", true, false)
			graph.move_semester(3)
			await _capture(mid + "-grafo-avanzado")
			var request: Dictionary = game.simulation.snapshot()["procedures"][0]
			game.simulation.pay("matricula")
			for index in range(3):
				var step: Dictionary = game.SimulationProcedures.current_step(game.simulation.procedure(str(request["id"])))
				game.simulation.advance_procedure(str(request["id"]), str(step["office"]))
			game.simulation.start_term()
			game._start_subject(str(game.simulation.state["enrollments"].keys()[0]))
			await _capture(mid + "-estudio")
		game._show_campus_section("tramites")
		game._campus()._new_request_form()
		await _capture(pid + "-formularios")
		game._show_campus_section("graduacion")
		await _capture(pid + "-graduacion")
		game._show_titles()
		await _capture(pid + "-logros")
	root.size = Vector2i(1152, 900)
	root.content_scale_size = Vector2i(1152, 900)
	game._create_solo_save("sistemas", "gestion_sistemas")
	game._show_campus_section("malla")
	await _capture("grafo-protegido-completo")
	root.size = Vector2i(1152, 720)
	root.content_scale_size = Vector2i(1152, 720)
	var enrollment: Dictionary = game.simulation.snapshot()["procedures"][0]
	game.simulation.pay("matricula")
	for index in range(3):
		var step: Dictionary = game.SimulationProcedures.current_step(game.simulation.procedure(str(enrollment["id"])))
		game.simulation.advance_procedure(str(enrollment["id"]), str(step["office"]))
	game.simulation.start_term()
	for key in game.simulation.state["enrollments"].keys().duplicate():
		for partial in range(3):
			game.simulation.answer(str(key), partial, not str(key).ends_with("SIS 1110"))
	game.simulation.close_term()
	game._show_campus_section("malla")
	var retained_graph = game.find_child("ExpandedCurriculumGraph", true, false)
	retained_graph.move_semester(2)
	await _capture("04-malla-pendiente-primer-semestre")
	game.settings["animations"] = true
	for mid in ["desarrollo_sw", "telematica"]:
		game._create_solo_save("informatica", mid)
		await _capture("ambiente-" + mid)
		var ambient_layer = game.find_child("MentionAmbient", true, false)
		print("AMBIENT ", mid, " rect=", ambient_layer.get_rect(), " visible=", ambient_layer.visible)
		ambient_layer.surface.get_texture().get_image().save_png(target + "ambiente-crudo-" + mid + ".png")
		game._show_campus_section("malla")
		var detail_graph = game.find_child("ExpandedCurriculumGraph", true, false)
		var selected_node: Dictionary = detail_graph.visible_nodes[-1].duplicate(true)
		detail_graph.subject_selected.emit(str(selected_node["sigla"]), selected_node)
		await _capture("ficha-ordenada-" + mid)
	game.queue_free()
	await process_frame
	quit(0)
