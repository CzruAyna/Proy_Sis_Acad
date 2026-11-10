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
			_check(world != null and world.size.y >= 340, "El lienzo de exploración utiliza el espacio disponible")
			var clock: Label = game.find_child("CampusClock", true, false)
			_check(clock.get_line_count() == 1 and clock.size.x >= clock.get_minimum_size().x, "Reloj completo en una línea")
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
			var map = game.find_child("CampusOverview", true, false)
			_check(map._heading == Vector2.UP, "La flecha señala la última orientación exterior al abrir el mapa desde un aula")
			var overview: Vector2 = map.map_center
			var plus: Button = game.find_child("CampusZoomIn", true, false)
			plus.pressed.emit()
			plus.pressed.emit()
			_check(map.zoom_index == 2 and map.map_center != overview, "Acercar centra el zoom en el personaje")
			var marker: Vector2 = map.size * 0.5 + (map._player - map.map_center) * map._map_scale()
			_check(Rect2(Vector2.ZERO, map.size - Vector2(0, 25)).has_point(marker), "La flecha queda visible tras acercar dos veces")
			var position_before: Vector2 = map.map_center
			var wheel := InputEventMouseButton.new()
			wheel.button_index = MOUSE_BUTTON_WHEEL_UP
			wheel.pressed = true
			map._gui_input(wheel)
			_check(map.zoom_index == 2 and map.map_center == position_before, "El mapa no depende de la rueda")
			var arrow := InputEventKey.new()
			arrow.keycode = KEY_LEFT
			arrow.pressed = true
			map._gui_input(arrow)
			_check(map.map_center.x < position_before.x, "Flechas desplazan la vista ampliada")
			game.find_child("CampusZoomReset", true, false).pressed.emit()
			_check(map.zoom_index == 0 and map.map_center == overview, "Vista general restaura el encuadre")
			var map_keys: Array[String] = []
			for button in game.find_children("*", "Button", true, false):
				map_keys.append(button.text)
			_check(map_keys == ["−", "Vista general", "+", "Créditos del mapa", "← Atrás"], "Mapa sin lista de destinos ni cuadrícula")
			_check(game.current_profile.is_empty() and game.simulation == null, "Visita libre sin crear expediente académico")
	game.draft_player_name = "Prueba compacta"
	game.active_slot = 1
	game._create_solo_save("sistemas", "gestion_sistemas")
	var before := JSON.stringify(game.simulation.snapshot())
	game._show_exploration()
	var world = game.find_child("CampusWorld", true, false)
	world.lighting_minutes = 540
	_check(world._night_strength() < 0.01 and world.clock_text() == "Día 1 · 09:00", "El ciclo comienza de día")
	world._advance_lighting(180)
	_check(world._night_strength() > 0.95 and world.clock_text() == "Día 1 · 21:00", "Tres minutos reales llevan al anochecer")
	world._advance_lighting(180)
	_check(world.clock_text() == "Día 2 · 09:00" and world._night_strength() < 0.01, "El día reinicia la iluminación a los seis minutos")
	world.enter_room("sis_c", "CU-SIC1")
	ui.show_progress()
	await _inspect("exploración-progreso-partida")
	_check(game.current_profile["campus_exploration"]["visited"].has("sis_c/CU-SIC1"), "Se conserva visita en perfil académico")
	_check(before == JSON.stringify(game.simulation.snapshot()), "La visita no cambia el estado académico")
	game._show_campus_section("materias")
	_check(game.find_child("CampusNavigation", true, false) != null, "Integración con navegación de materias")
	game._show_campus_section("exploracion")
	world = game.find_child("CampusWorld", true, false)
	_check(world != null and world.clock_text().begins_with("Día 2"), "Volver al personaje conserva el reloj visual de la sesión")
	game.queue_free()
	await process_frame
	viewport.queue_free()
	await process_frame
	for failure in failures:
		push_error(failure)
	print("EXPLORATION_NAVIGATION_TESTS: %d assertions, %d failures" % [assertions, failures.size()])
	quit(0 if failures.is_empty() else 1)
