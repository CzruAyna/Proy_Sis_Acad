extends SceneTree

const World = preload("res://scripts/campus_world.gd")
const Map = preload("res://scripts/campus_map.gd")
const Simulation = preload("res://scripts/student_simulation.gd")
const Store = preload("res://scripts/simulation_save_store.gd")
const GRID_STEP := 16

var assertions := 0
var failures: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func _check(value: bool, message: String) -> void:
	assertions += 1
	if not value:
		failures.append(message)


func _reachable() -> PackedByteArray:
	var width := int(Map.SIZE.x / GRID_STEP)
	var height := int(Map.SIZE.y / GRID_STEP)
	var blocked := PackedByteArray()
	blocked.resize(width * height)
	for building in Map.buildings():
		var rect: Rect2 = Rect2(building["rect"]).grow(World.PLAYER_RADIUS)
		for y in range(maxi(0, int(rect.position.y / GRID_STEP)), mini(height, ceili(rect.end.y / GRID_STEP))):
			for x in range(maxi(0, int(rect.position.x / GRID_STEP)), mini(width, ceili(rect.end.x / GRID_STEP))):
				if rect.has_point(Vector2(x, y) * GRID_STEP):
					blocked[y * width + x] = 1
	var seen := PackedByteArray()
	seen.resize(width * height)
	var start := Vector2i(Map.SPAWN / GRID_STEP)
	var queue: Array[Vector2i] = [start]
	seen[start.y * width + start.x] = 1
	var cursor := 0
	while cursor < queue.size():
		var point := queue[cursor]
		cursor += 1
		for direction in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var next: Vector2i = point + direction
			if next.x < 2 or next.y < 2 or next.x >= width - 2 or next.y >= height - 2:
				continue
			var index := next.y * width + next.x
			if seen[index] == 0 and blocked[index] == 0:
				seen[index] = 1
				queue.append(next)
	return seen


func _run() -> void:
	_check(ProjectSettings.get_setting("application/config/name") == "SIS-INF", "Nombre nuevo aplicado")
	_check(ProjectSettings.get_setting("application/config/icon") == "res://assets/branding/sis_inf_pixel.png", "Síntesis pixel art del emblema como icono")
	_check(OS.get_user_data_dir().replace("\\", "/").ends_with("Godot/app_userdata/CAMPUS EN JUEGO"), "Conserva el directorio de partidas anterior en Windows")
	var world := World.new()
	root.add_child(world)
	world.set_process(false)
	world.size = Vector2(1000, 460)
	_check(world._can_stand(Map.SPAWN), "Ingreso libre de obstáculos")
	var seen := _reachable()
	var width := int(Map.SIZE.x / GRID_STEP)
	var ids := {}
	for building in Map.buildings():
		_check(not ids.has(building["id"]), "Identificador único")
		ids[building["id"]] = true
		var door: Vector2 = building["door"]
		_check(world._can_stand(door), "Puerta libre: " + str(building["id"]))
		# Use an exterior grid cell: rounding the narrow door clearance can hit a wall.
		var grid := Vector2i(((door + Vector2(0, GRID_STEP)) / GRID_STEP).round())
		_check(seen[grid.y * width + grid.x] == 1, "Puerta accesible a pie desde el ingreso: " + str(building["id"]))
		var approach := Vector2(grid) * GRID_STEP
		_check(world._can_stand(approach) and world._can_stand(door.lerp(approach, 0.5)), "El tramo final desde la rejilla admite la huella ampliada")
		_check(not world._can_stand(Rect2(building["rect"]).get_center()), "El edificio bloquea caminar a través")
		for room in building["rooms"]:
			_check(world.enter_room(str(building["id"]), str(room)), "Entrada a " + str(room))
			_check(world._can_stand(world.player), "Aparición segura en interior")
			var before := world.visited.size()
			world.enter_room(str(building["id"]), str(room))
			_check(world.visited.size() == before, "Visitas sin duplicados")
			var restored := World.new()
			restored.restore(JSON.parse_string(JSON.stringify(world.snapshot())))
			_check(restored.room_id == building["id"] and restored.room_name == room and restored._can_stand(restored.player), "Recarga segura del aula")
			restored.free()
			world.leave_room()
			_check(world.player == door and world.room_id.is_empty(), "Salida junto a la puerta correcta")
	world.player = Map.SPAWN
	var start := world.player
	world.move_player(Vector2.RIGHT, 0.1)
	var distance := world.player.distance_to(start)
	world.player = start
	world.move_player(Vector2.ONE, 0.1)
	_check(absf(world.player.distance_to(start) - distance) < 0.01, "Diagonal normalizada, con precisión de Vector2 en el mapa grande")
	world.player = start
	world.move_player(Vector2.RIGHT, 0.1, true)
	_check(world.player.distance_to(start) > distance, "Shift acelera")
	world.paused = true
	start = world.player
	world.move_player(Vector2.RIGHT, 0.1)
	_check(world.player == start, "La pausa detiene el movimiento")
	world.paused = false
	var key := InputEventKey.new()
	key.physical_keycode = KEY_W
	key.pressed = true
	world._input(key)
	_check(world._pressed(KEY_W), "WASD físico registrado")
	world._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	_check(not world._pressed(KEY_W), "Perder el foco libera controles")
	var first: Dictionary = Map.buildings()[0]
	world.player = first["door"]
	world.interact()
	_check(world.room_id == first["id"], "E entra desde una puerta")
	world.interact()
	_check(world.room_id.is_empty(), "E sale desde la puerta interior")
	world.restore({"version": 1, "map_id": Map.ID, "position": [INF, NAN], "room_id": "fake", "visited": ["fake", 7]})
	_check(world.player == Map.SPAWN and world.visited.is_empty(), "Sanea estado corrupto")
	_check(not world.enter_room("fake", "fake") and not world.enter_room("sis_c", "fake"), "No admite aulas inexistentes")
	var profile := {"slot": 1, "player_name": "Prueba", "program_id": "sistemas", "mention_id": "gestion_sistemas"}
	var simulation := Simulation.new(profile)
	var academic := JSON.stringify(simulation.snapshot())
	profile["campus_exploration"] = world.snapshot()
	_check(Simulation.validate_profile(profile)["ok"], "Extensión compatible con validación académica")
	_check(academic == JSON.stringify(simulation.snapshot()), "Explorar no modifica notas, requisitos ni trámites")
	var directory := "res://.test-artifacts/exploration-storage"
	var store := Store.new(directory, 1)
	_check(store.save_slot(1, profile) == OK, "Estado espacial persiste con el perfil")
	var loaded_world := World.new()
	loaded_world.restore(store.read_slot(1)["campus_exploration"])
	_check(loaded_world.player == world.player and loaded_world.room_id == world.room_id and loaded_world.visited == world.visited, "Estado espacial se recupera")
	loaded_world.free()
	_check(store.remove_slot(1) == OK, "Limpieza del perfil ficticio")
	world.queue_free()
	await process_frame
	for failure in failures:
		push_error(failure)
	print("EXPLORATION_TESTS: %d assertions, %d failures" % [assertions, failures.size()])
	quit(0 if failures.is_empty() else 1)
