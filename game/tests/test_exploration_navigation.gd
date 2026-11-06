extends "res://tests/test_compact_navigation.gd"

const Map = preload("res://scripts/campus_map.gd")


func _run() -> void:
	viewport = SubViewport.new()
	root.add_child(viewport)
	game = TestGame.new()
	viewport.add_child(game)
	game.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	game._show_main()
	_check(game.find_child("SisInfLogo", true, false).get_script() == game.CareerLogo, "Emblema dibujado con geometría en el fondo")
	game._show_play()
	_check(game.find_child("ExplorationEntry", true, false) != null, "Acceso independiente dentro de Jugar")
	game._show_exploration()
	var ui = game.exploration_ui
	_check(game.find_child("StartExploration", true, false).disabled, "Nombre obligatorio en visita libre")
	ui.guest_name = "Prueba compacta"
	for dimensions in [Vector2i(900, 640), Vector2i(1152, 720)]:
		viewport.size = dimensions
		for scale in [1.0, 1.2]:
			game.settings["font_scale"] = scale
			ui.show_welcome()
			await _inspect("exploración-bienvenida")
			ui.show_world()
			await _inspect("exploración-mundo")
			var world = game.find_child("CampusWorld", true, false)
			_check(world != null and world.size.y >= 160, "Lienzo de movimiento disponible")
			world.enter_room("sis_c", "CU-SIC4")
			ui.show_room(Map.building("sis_c"), "CU-SIC4")
			await _inspect("exploración-aula")
			ui.show_world()
			world = game.find_child("CampusWorld", true, false)
			_check(world.room_id == "sis_c" and world.room_name == "CU-SIC4", "Regresar conserva el interior")
			ui.show_help()
			await _inspect("exploración-ayuda")
			ui.show_progress()
			await _inspect("exploración-progreso")
			ui.show_map()
			await _inspect("exploración-mapa")
			ui.show_map_guide()
			await _inspect("exploración-plano")
			_check(game.current_profile.is_empty() and game.simulation == null, "Visita libre sin crear expediente académico")
	game.draft_player_name = "Prueba compacta"
	game.active_slot = 1
	game._create_solo_save("sistemas", "gestion_sistemas")
	var before := JSON.stringify(game.simulation.snapshot())
	game._show_exploration()
	var world = game.find_child("CampusWorld", true, false)
	world.enter_room("sis_c", "CU-SIC1")
	ui.show_progress()
	await _inspect("exploración-progreso-partida")
	_check(game.current_profile["campus_exploration"]["visited"].has("sis_c/CU-SIC1"), "Se conserva visita en perfil académico")
	_check(before == JSON.stringify(game.simulation.snapshot()), "La visita no cambia el estado académico")
	game._show_campus_section("materias")
	_check(game.find_child("CampusNavigation", true, false) != null, "Integración con navegación de materias")
	game._show_campus_section("exploracion")
	_check(game.find_child("CampusWorld", true, false) != null, "Regreso al personaje desde las vistas académicas")
	game.queue_free()
	await process_frame
	viewport.queue_free()
	await process_frame
	for failure in failures:
		push_error(failure)
	print("EXPLORATION_NAVIGATION_TESTS: %d assertions, %d failures" % [assertions, failures.size()])
	quit(0 if failures.is_empty() else 1)
