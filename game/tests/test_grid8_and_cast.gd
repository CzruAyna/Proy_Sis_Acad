extends "res://tests/test_exploration.gd"
const Grid = preload("res://scripts/campus_grid.gd")
const Cast = preload("res://scripts/campus_cast.gd")


func _run() -> void:
	for path in ["res://assets/reference/fni_plan.jpg", "res://assets/reference/fni_plan.jpg.import", "res://assets/reference/fni_plan_annotated.jpg", "res://assets/reference/fni_plan_annotated.jpg.import", "res://assets/branding/sis_inf_logo.png", "res://assets/branding/sis_inf_logo.png.import"]:
		_check(not FileAccess.file_exists(path), "El original aportado queda fuera del proyecto: " + path)
	var codes := {}
	var surface := 0.0
	for row in range(8):
		for column in range(8):
			var code := Grid.code(row, column)
			_check(not codes.has(code), "Celda única " + code)
			codes[code] = true
			var area := Grid.bounds(row, column)
			_check(area.size / Scale.UNITS_PER_METRE == Vector2(110, 61) and Grid.at(area.get_center()) == code, "Celda calibrada cubre 110 × 61 m y conserva su código")
			surface += area.get_area()
	_check(surface == Map.SIZE.x * Map.SIZE.y and codes.size() == 64, "64 celdas cubren toda la superficie")
	_check(Grid.at(Vector2.ZERO) == "A1" and Grid.at(Map.SIZE) == "H8" and Grid.at(Map.SPAWN) == "H5", "Bordes y entrada se identifican sin desbordar")
	var world := World.new()
	world._life_saved = {"version": 1, "seed": "20261104", "rare": false}
	root.add_child(world)
	world.set_process(false)
	_check(Scale.OUTDOOR_SIZE.y > Scale.NPC_SIZE.y and Scale.NPC_SIZE.y > 16 and Scale.OUTDOOR_RADIUS < World.PLAYER_RADIUS, "La silueta del jugador se distingue de los NPC y conserva la huella de paso")
	var start := world.player
	world.move_player(Vector2.RIGHT, 0.1)
	_check(absf(world.player.distance_to(start) - Scale.WALK_SPEED * 0.1) < 0.01, "Paseo exterior aplica el ritmo calibrado")
	world.player = start
	var old_position: Vector2 = Map.building("sis_c")["door"] - Vector2(0, 4)
	world.restore({"version": 1, "map_id": Map.ID, "position": [old_position.x, old_position.y], "visited": ["sis_c/CU-SIC1"]})
	_check(world.player.distance_to(old_position) <= 64 and world._can_stand(world.player), "Guardado próximo a una pared se ajusta localmente a la huella nueva")
	_check(world.visited.has("sis_c/CU-SIC1"), "Ajustar la posición conserva visitas")
	world.player = start
	world.move_player(Vector2.RIGHT, 0.1, true)
	_check(absf(world.player.distance_to(start) - Scale.WALK_SPEED * Scale.RUN_MULTIPLIER * 0.1) < 0.01, "Correr aplica el multiplicador sobre el ritmo calibrado")
	world.player = start
	_check(world.cast_instances.size() == 51, "Población ambiental: profesionales, 24 estudiantes, personal y cinco perros")
	var designs := {}
	for index in range(Cast.STUDENT_COUNT):
		var bytes := Cast.texture("estudiante_%d" % index).get_image().get_data()
		designs[bytes.hex_encode()] = true
	_check(designs.size() == 24, "Los 24 estudiantes tienen apariencia distinta")
	var positions := {}
	for actor in world.cast_instances:
		positions[actor["instance_id"]] = actor["point"]
		_check(actor["id"] != "piedritas_recuerdo", "La variante rara no se fuerza en la población")
	var snapshot: Dictionary = world.snapshot()
	for tick in range(160):
		world.ambient_cast.advance(0.1, world.player)
		if tick % 16 == 0:
			for actor in world.cast_instances:
				_check(world._can_stand_outside(actor["point"], actor["radius"]), "Paseo mantiene la huella fuera de paredes, bases y agua")
	var moving_count := 0
	for actor in world.cast_instances:
		if Vector2(actor["point"]).distance_to(positions[actor["instance_id"]]) > 10:
			moving_count += 1
	_check(moving_count > 14, "La población realiza recorridos y entradas a clases")
	var current: Dictionary = world.snapshot()
	_check(current["position"] == snapshot["position"] and current["room_id"] == snapshot["room_id"] and current["visited"] == snapshot["visited"], "Las rutinas conservan la posición y visitas del jugador")
	var before := str(world.cast_instances)
	world.paused = true
	world._process(0.5)
	_check(str(world.cast_instances) == before, "Pausa detiene los paseos")
	world.paused = false
	world.animations_enabled = false
	var elapsed: float = world.ambient_cast.elapsed
	world._process(0.5)
	_check(world.ambient_cast.elapsed > elapsed, "Movimiento reducido conserva el reloj de las rutinas")
	world.enter_building("sis_e")
	world.animations_enabled = true
	elapsed = world.ambient_cast.elapsed
	world._process(0.5)
	_check(world.ambient_cast.elapsed > elapsed, "Las clases continúan al entrar en un edificio")
	world.leave_room()
	before = str(world.cast_instances)
	for tick in range(40):
		world._process(0.1)
	_check(str(world.cast_instances) != before, "El controlador del mundo activa los paseos al volver al exterior")
	for actor in world.cast_instances:
		actor["moving"] = false
		actor["cooldown"] = 1.0
	world.cast_instances[0]["moving"] = true
	world.cast_instances[0]["state"] = "WAIT"
	_check(world.ambient_cast.advance(0.1, world.cast_instances[0]["point"]), "Cambiar de paso a reposo solicita redibujado")
	world.queue_free()
	await process_frame
	for failure in failures:
		push_error(failure)
	print("GRID8_CAST_TESTS: %d assertions, %d failures" % [assertions, failures.size()])
	quit(0 if failures.is_empty() else 1)
