extends SceneTree

const World = preload("res://scripts/campus_world.gd")
const Map = preload("res://scripts/campus_map.gd")
const Simulation = preload("res://scripts/student_simulation.gd")
const Store = preload("res://scripts/simulation_save_store.gd")
const Scale = preload("res://scripts/campus_scale.gd")
const GRID_STEP := 16

var assertions := 0
var failures: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func _check(value: bool, message: String) -> void:
	assertions += 1
	if not value:
		failures.append(message)


func _walking_grid(world: Control) -> AStarGrid2D:
	var grid := AStarGrid2D.new()
	grid.region = Rect2i(Vector2i.ZERO, Vector2i(Map.SIZE / GRID_STEP))
	grid.cell_size = Vector2.ONE * GRID_STEP
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	grid.update()
	for y in range(grid.region.size.y):
		for x in range(grid.region.size.x):
			var cell := Vector2i(x, y)
			grid.set_point_solid(cell, not world._can_stand(grid.get_point_position(cell)))
	return grid


func _walk_to(world: Control, grid: AStarGrid2D, door: Vector2) -> PackedVector2Array:
	var center := Vector2i((door / GRID_STEP).round())
	for offset in [Vector2i.ZERO, Vector2i.DOWN, Vector2i.UP, Vector2i.RIGHT, Vector2i.LEFT,
			Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)]:
		var cell: Vector2i = center + offset
		if not grid.region.has_point(cell) or grid.is_point_solid(cell):
			continue
		if not world.ambient_cast.routes.clear_line(grid.get_point_position(cell), door):
			continue
		var path := grid.get_point_path(Vector2i(Map.SPAWN / GRID_STEP), cell)
		if not path.is_empty():
			path.append(door)
			return path
	return PackedVector2Array()


func _time_walk(world: Control, path: PackedVector2Array) -> float:
	world.player = Map.SPAWN
	var seconds := 0.0
	for point in path:
		var distance: float = world.player.distance_to(point)
		while distance > 0.025:
			var step := minf(distance / Scale.WALK_SPEED, 0.05)
			world.move_player(world.player.direction_to(point), step)
			seconds += step
			var remaining: float = world.player.distance_to(point)
			if remaining >= distance - 0.001:
				return INF
			distance = remaining
	return seconds


func _run() -> void:
	_check(ProjectSettings.get_setting("application/config/name") == "SIS-INF", "Nombre nuevo aplicado")
	_check(ProjectSettings.get_setting("application/config/icon") == "res://assets/branding/sis_inf_pixel.png", "Síntesis pixel art del emblema como icono")
	_check(OS.get_user_data_dir().replace("\\", "/").ends_with("Godot/app_userdata/CAMPUS EN JUEGO"), "Conserva el directorio de partidas anterior en Windows")
	var world := World.new()
	root.add_child(world)
	world.set_process(false)
	world.size = Vector2(1000, 460)
	_check(world._can_stand(Map.SPAWN), "Ingreso libre de obstáculos")
	var grid := _walking_grid(world)
	# Even the straight-line minimum in v2 was longer for these journeys.
	var v2_minimum := {"fisica": 8.85, "sis_a": 19.88, "basicas": 18.92}
	var ids := {}
	for building in Map.buildings():
		_check(not ids.has(building["id"]), "Identificador único")
		ids[building["id"]] = true
		var door: Vector2 = building["door"]
		_check(world._can_stand(door), "Puerta libre: " + str(building["id"]))
		var path := _walk_to(world, grid, door)
		_check(not path.is_empty(), "Puerta accesible a pie desde el ingreso: " + str(building["id"]))
		if v2_minimum.has(building["id"]) and not path.is_empty():
			var elapsed := _time_walk(world, path)
			print("CAMPUS_WALK ", building["id"], ": ", snappedf(elapsed, 0.01), " s (v2 en recta: ", v2_minimum[building["id"]], " s)")
			_check(elapsed < float(v2_minimum[building["id"]]), "El trayecto jugado mejora el mínimo de v2")
		var polygon: PackedVector2Array = building["footprint"]
		var triangle := Geometry2D.triangulate_polygon(polygon)
		_check(not triangle.is_empty() and not world._can_stand((polygon[triangle[0]] + polygon[triangle[1]] + polygon[triangle[2]]) / 3), "La huella del edificio bloquea el paso")
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
	var v2 := {"version": 1, "map_id": Map.PREVIOUS_ID, "position": [6784, 8144], "visited": ["sis_a/LSIA-1"],
		"life": {"version": 1, "seed": "82", "rare": true, "petted": ["ambient/piedritas_recuerdo"],
			"actors": [{"instance_id": "ambient/piedritas_recuerdo", "point": [6784, 8144], "pet_count": 2}]}}
	var migrated := World.new()
	migrated.restore(v2)
	root.add_child(migrated)
	migrated.set_process(false)
	var rare := migrated.ambient_cast.find_instance("ambient/piedritas_recuerdo")
	_check(migrated.player == Map.SPAWN and migrated.visited.has("sis_a/LSIA-1"), "La partida v2 conserva el ingreso y las visitas")
	_check(migrated.snapshot()["map_id"] == Map.ID and not rare.is_empty() and rare["point"] == Map.SPAWN and rare["pet_count"] == 2, "La vida persistida migra coordenadas y caricias sin volver a sortear")
	_check(migrated.ambient_cast.petted.has("ambient/piedritas_recuerdo"), "La migración conserva las interacciones registradas")
	migrated.free()
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
