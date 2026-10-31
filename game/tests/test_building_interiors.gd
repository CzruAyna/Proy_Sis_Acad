extends "res://tests/test_compact_navigation.gd"

const World = preload("res://scripts/campus_world.gd")
const Map = preload("res://scripts/campus_map.gd")

class RecentGame extends "res://tests/test_compact_navigation.gd".TestGame:
	func _recent_slot() -> int:
		return 1
	func _read_save(_slot: int, _mode: String) -> Dictionary:
		return {"player_name": "Prueba compacta con un nombre largo en la partida"}


func _walkable_route(world: Control, start: Vector2, finish: Vector2) -> bool:
	# Independent four-neighbour traversal of the actual collision surface.
	var first := Vector2i((start / 4).round())
	var goal := Vector2i((finish / 4).round())
	var queue: Array[Vector2i] = [first]
	var seen := {first: true}
	var cursor := 0
	while cursor < queue.size():
		var point := queue[cursor]
		cursor += 1
		if point.distance_to(goal) < 2:
			return true
		for direction in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var next: Vector2i = point + direction
			if not seen.has(next) and world._can_stand(Vector2(next) * 4):
				seen[next] = true
				queue.append(next)
	return false


func _run() -> void:
	viewport = SubViewport.new()
	root.add_child(viewport)
	game = RecentGame.new()
	viewport.add_child(game)
	game.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for dimensions in [Vector2i(900, 640), Vector2i(1152, 720), Vector2i(1600, 900)]:
		viewport.size = dimensions
		for scale in [0.8, 1.0, 1.2]:
			game.settings["font_scale"] = scale
			game._show_main()
			await _inspect("inicio")
			_check(game.find_children("*", "PanelContainer", true, false).size() == 1, "Un solo contenedor en el inicio")
			_check(game.find_child("MainMenuPanel", true, false).size.y < dimensions.y - 40, "El menú tiene altura contenida")
	game.settings["font_scale"] = 1.0
	var world := World.new()
	root.add_child(world)
	world.set_process(false)
	for building in Map.buildings():
		if building["rooms"].size() < 2:
			continue
		world.leave_room()
		world.player = building["door"]
		world.interact()
		_check(world.room_id == building["id"] and world.room_name.is_empty(), "La entrada lleva al pasillo de " + str(building["id"]))
		var hall_spawn: Vector2 = world.player
		_check(world._can_stand(hall_spawn), "Aparición segura en pasillo")
		for space in Map.hall_rooms(str(building["id"])):
			_check(_walkable_route(world, hall_spawn, space["door"]), "Puerta interior accesible a pie: " + str(space["name"]))
			_check(not world._can_stand(Rect2(space["rect"]).get_center()), "No atraviesa la pared del aula")
			world.player = space["door"]
			world.interact()
			_check(world.room_name == space["name"], "E entra en el aula elegida")
			_check(world.visited.has(str(building["id"]) + "/" + str(space["name"])), "Registra el aula exacta")
			world.interact()
			_check(world.room_id == building["id"] and world.room_name.is_empty(), "E vuelve al pasillo sin salir del bloque")
			_check(world.player.distance_to(space["door"]) < 1 and world._can_stand(world.player), "Regresa a la misma puerta sin colisión")
		var restored := World.new()
		restored.restore(JSON.parse_string(JSON.stringify(world.snapshot())))
		_check(restored.room_id == building["id"] and restored.room_name.is_empty() and restored._can_stand(restored.player), "Guardar y recargar el pasillo")
		restored.free()
	_check(Map.building("sis_a")["rooms"] == ["LSIA-1", "LSIA-4"], "Ambientes A publicados en la fuente institucional")
	_check(Map.room_kind("sis_a", "LSIA-4") == "computer_lab", "Sistemas tiene equipamiento informático propio")
	world.enter_room("sis_a", "LSIA-1")
	_check(not world._can_stand(Vector2(432, 50)), "El armario del laboratorio bloquea el paso")
	world.restore({"version": 1, "map_id": Map.ID, "position": [1280, 1536], "room_id": "sis_a", "room_name": "SIS A", "visited": ["sis_a/SIS A"]})
	_check(world.room_id == "sis_a" and world.room_name.is_empty(), "La antigua sala genérica se recupera en el pasillo")
	_check(world.visited.has("sis_a/SIS A"), "No pierde la visita histórica del bloque")
	world.free()
	game.queue_free()
	viewport.queue_free()
	await process_frame
	for failure in failures:
		push_error(failure)
	print("BUILDING_INTERIORS_TESTS: %d assertions, %d failures" % [assertions, failures.size()])
	quit(0 if failures.is_empty() else 1)
