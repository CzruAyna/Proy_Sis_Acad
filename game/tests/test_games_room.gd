extends "res://tests/test_building_interiors.gd"

const Preview = preload("res://scripts/minigame_preview.gd")
const Fracture = preload("res://scripts/fracture_geometry.gd")


func _pixel_text(screen: String) -> void:
	for control in game.find_children("*", "Control", true, false):
		if control is Label or control is Button or control is LineEdit:
			_check(control.get_theme_font("font") == Preview.FONT, screen + ": tipografía pixel en " + control.name)
	_check(game._home_panel_style().bg_color == Color.BLACK and game._card_style(false).bg_color == Color.BLACK, "Superficies en negro puro")


func _run() -> void:
	viewport = SubViewport.new()
	root.add_child(viewport)
	game = RecentGame.new()
	viewport.add_child(game)
	game.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	game.active_slot = 1
	game.draft_player_name = "Prueba compacta"
	game._create_solo_save("sistemas", "gestion_sistemas")
	var academic := JSON.stringify(game.simulation.snapshot())
	game._show_exploration()
	var world = game.find_child("CampusWorld", true, false)
	var courts_clear := true
	for point in world._tree_positions:
		for row in Map.COURTS:
			var area := Rect2(Vector2(float(row[1]), float(row[2])) * Map.SIZE / 100, Vector2(float(row[3]), float(row[4])) * Map.SIZE / 100)
			courts_clear = courts_clear and not area.grow(24).has_point(point)
	_check(courts_clear, "La vegetación no aparece sobre las canchas ni su margen")
	var outline: Rect2 = Map.building("sis_a")["rect"]
	_check(world._can_stand(outline.position + outline.size * 0.05), "La esquina recortada de A permite caminar, sin pared rectangular invisible")
	_check(not world._can_stand(outline.get_center()), "La parte sólida del bloque A mantiene la colisión")
	for id in Map.FOOTPRINTS:
		_check(Map.building(id)["footprint"].size() > 4, "Contorno propio compartido por dibujo, colisión y mapa: " + str(id))
	_check(world.enter_building("sis_e") and world.room_name == "SIS E", "E conserva la sala existente y su identificador de guardado")
	var origin: Vector2 = world.player
	for station in Map.game_stations():
		_check(_walkable_route(world, origin, station["approach"]), "Se llega andando a " + str(station["title"]))
		_check(not world._can_stand(Rect2(station["rect"]).get_center()), "La mesa impide atravesarla")
	game.exploration_ui.capture()
	var resumed := World.new()
	resumed.restore(game.exploration_ui.saved)
	viewport.add_child(resumed)
	resumed.set_process(false)
	_check(resumed._tree_positions == world._tree_positions, "Recargar dentro de E conserva la misma vegetación exterior")
	resumed.queue_free()
	for dimensions in [Vector2i(900, 640), Vector2i(1152, 720), Vector2i(1600, 900)]:
		viewport.size = dimensions
		for scale in [0.8, 1.0, 1.2]:
			game.settings["font_scale"] = scale
			game.exploration_ui.show_games()
			await _inspect("sala E")
			_pixel_text("sala E")
			for station in Map.game_stations():
				game.exploration_ui.show_world()
				world = game.find_child("CampusWorld", true, false)
				world.set_process(false)
				_check(world.room_id == "sis_e", "La partida vuelve a la sala E")
				world.player = station["approach"]
				_check(world.interaction_text().contains(station["title"]), "La interacción identifica la mesa")
				world.interact()
				await _inspect(str(station["title"]))
				_pixel_text(str(station["title"]))
				var view = game.find_child("MinigameBoard", true, false)
				_check(view != null and view.model.game_id == station["id"], "E abre una partida de la mesa correcta")
				var workspace = game.find_child("MinigameWorkspace", true, false)
				var pager = game.find_child("PageNavigator", true, false)
				_check(workspace.size.y <= pager.viewport.size.y + 1, "Tablero y controles accesibles juntos sin cambiar de página")
				_check(not view.model.paused, "La partida está activa")
				view.model.command({"type": "pause"}, view.model.revision)
			_check(academic == JSON.stringify(game.simulation.snapshot()), "Explorar mesas no cambia notas, trámites ni inscripciones")
	game._show_main()
	await _inspect("inicio")
	_pixel_text("inicio")
	game._show_options()
	await _inspect("opciones")
	_pixel_text("opciones")
	for character in "$@{}├└│─πΣ∇φρλεμωθατΔ∂√∞±≤≥":
		_check(Preview.FONT.has_char(character.unicode_at(0)), "Glifo pixel de terminal / ecuación: " + character)
	_check(Fracture.LINUX_TREE[0].contains("tree -L") and Fracture.WINDOWS_TREE[0].contains("tree /A"), "Ambas sintaxis de árbol están representadas")
	game.queue_free()
	viewport.queue_free()
	await process_frame
	for failure in failures:
		push_error(failure)
	print("GAMES_ROOM_TESTS: %d assertions, %d failures" % [assertions, failures.size()])
	quit(0 if failures.is_empty() else 1)
