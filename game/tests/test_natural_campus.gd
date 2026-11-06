extends "res://tests/test_compact_navigation.gd"
const Map = preload("res://scripts/campus_map.gd")
const World = preload("res://scripts/campus_world.gd")
const Compass = preload("res://scripts/campus_compass.gd")
const Roads = preload("res://scripts/campus_roads.gd")

class MenuGame extends "res://tests/test_compact_navigation.gd".TestGame:
	var has_save := false
	func _recent_slot() -> int:
		return 1 if has_save else 0
	func _read_save(_slot: int, _mode: String) -> Dictionary:
		return {"player_name": "Persona con una partida guardada"} if has_save else {}


func _run() -> void:
	_check(Compass.DIRECTIONS["N"] == Vector2.RIGHT and Compass.DIRECTIONS["S"] == Vector2.LEFT and Compass.DIRECTIONS["E"] == Vector2.DOWN and Compass.DIRECTIONS["O"] == Vector2.UP, "La rosa conserva la orientación expresa del usuario")
	var paths := Roads.paths()
	for index in range(paths.size()):
		var path: PackedVector2Array = paths[index]
		var raw: PackedVector2Array = Map.routes()[index]
		_check(path.size() > raw.size() if raw.size() > 2 else path == raw, "Los giros se suavizan y los tramos rectos conservan sus extremos")
		var connected := false
		for other_index in range(paths.size()):
			if index == other_index:
				continue
			var other: PackedVector2Array = paths[other_index]
			for endpoint in [path[0], path[-1]]:
				for segment in range(other.size() - 1):
					if endpoint.distance_to(Geometry2D.get_closest_point_to_segment(endpoint, other[segment], other[segment + 1])) < 80:
						connected = true
		_check(connected, "El camino enlaza con otra vía sin quedar aislado: %d" % index)
	var world := World.new()
	root.add_child(world)
	world.set_process(false)
	var sizes := {}
	var kinds := {}
	var activity_events: Array = []
	world.activity_requested.connect(func(_block: Dictionary, _room: String) -> void: activity_events.append(true))
	for block in Map.buildings():
		for room in block["rooms"]:
			world.paused = false
			_check(world.enter_room(block["id"], room), "Se puede entrar al ambiente " + room)
			var layout := Map.room_layout(block["id"], room)
			sizes[str(layout["size"])] = true
			kinds[layout["kind"]] = true
			_check(world._can_stand(world.player) and world._can_stand(layout["exit"]), "Aparición y salida seguras con la huella ampliada")
			_check(not world._can_stand(Vector2(12, 12)), "La pared exterior bloquea el paso")
			for item in layout["items"]:
				_check(not world._can_stand(Rect2(item["rect"]).get_center()), "El mobiliario dibujado conserva colisión")
			if layout["kind"] != "games_room":
				for y in range(int(world.player.y), 72, -8):
					_check(world._can_stand(Vector2(world.player.x, y)), "Pasillo central continuo desde puerta hasta actividades")
				world.player.y = 80
				var before := activity_events.size()
				world.interact()
				_check(activity_events.size() == before + 1, "E conserva el acceso a actividades del ambiente")
			world.paused = false
			world.player = layout["spawn"]
			world.interact()
			_check(world.room_name.is_empty(), "E conserva el regreso sin perder al jugador")
	_check(sizes.size() >= 8 and kinds.size() >= 9, "Ambientes con proporciones y usos realmente distintos")
	world.free()
	viewport = SubViewport.new()
	root.add_child(viewport)
	game = MenuGame.new()
	viewport.add_child(game)
	game.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for dimensions in [Vector2i(900, 640), Vector2i(1152, 720), Vector2i(1600, 900)]:
		viewport.size = dimensions
		for scale in [0.8, 1.0, 1.2]:
			game.settings["font_scale"] = scale
			for saved in [false, true]:
				game.has_save = saved
				game._show_main()
				await _inspect("inicio")
				var labels: Array[String] = []
				for button in game.find_child("MainMenuPanel", true, false).find_children("*", "Button", true, false):
					labels.append(button.text)
				_check(labels == ["Jugar", "Simular", "Opciones", "Salir"], "El inicio mantiene cuatro acciones incluso con guardados")
			game._show_play()
			await _inspect("jugar")
			_check(game.find_child("ExplorationEntry", true, false) != null, "Explorar se conserva dentro de Jugar")
			game._show_simulate()
			await _inspect("simular")
			_check(game.find_child("CareerStoryEntry", true, false) != null and game.find_child("CareerPresentationEntry", true, false) != null, "Ambas simulaciones siguen accesibles")
	game.queue_free()
	viewport.queue_free()
	await process_frame
	for failure in failures:
		push_error(failure)
	print("NATURAL_CAMPUS_TESTS: %d assertions, %d failures" % [assertions, failures.size()])
	quit(0 if failures.is_empty() else 1)
