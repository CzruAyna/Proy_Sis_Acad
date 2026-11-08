extends "res://tests/test_compact_navigation.gd"
const World = preload("res://scripts/campus_world.gd")
const Map = preload("res://scripts/campus_map.gd")
const Life = preload("res://scripts/campus_life.gd")
const Collision = preload("res://scripts/campus_collision.gd")
const Land = preload("res://scripts/campus_landscape.gd")
const Achievements = preload("res://scripts/achievement_catalog.gd")
const Cave = preload("res://scripts/menu_cave.gd")


func _legacy_collision(point: Vector2, radius: float) -> bool:
	if not Rect2(Vector2.ONE * 16, Map.SIZE - Vector2.ONE * 32).has_point(point):
		return false
	for block in Map.buildings():
		if not Rect2(block["rect"]).grow(radius).has_point(point):
			continue
		if Geometry2D.is_point_in_polygon(point, block["footprint"]):
			return false
		var poly: PackedVector2Array = block["footprint"]
		for i in range(poly.size()):
			if point.distance_to(Geometry2D.get_closest_point_to_segment(point, poly[i], poly[(i + 1) % poly.size()])) <= radius:
				return false
	for obstacle in Land.obstacles():
		if obstacle.grow(radius).has_point(point):
			return false
	return not Land.water_blocks(point, radius)


func _run() -> void:
	Cave._frames.clear()
	var builds := Cave.geometry_builds
	var sample := Rect2(90, 80, 420, 330)
	for i in range(120):
		Cave.frame(sample, 16, 48, float(i) / 60)
	_check(Cave.geometry_builds - builds == 1, "La geometría estable no se reconstruye cada fotograma")
	for i in range(40):
		Cave.frame(Rect2(i, 80, 420, 330), 16, 48, 1)
	_check(Cave._frames.size() <= 16, "La caché de ruptura tiene un límite de memoria")
	for i in range(2500):
		var point := Vector2(30 + posmod(i * 173, int(Map.SIZE.x) - 60), 30 + posmod(i * 347, int(Map.SIZE.y) - 60))
		_check(Collision.can_stand(point, 12) == _legacy_collision(point, 12), "Índice conserva las colisiones exactas")
	var world := World.new()
	for block in ["fis_mat", "basicas"]:
		world.enter_building(block)
		for level in range(Map.floor_count(block)):
			world.player = Vector2(360, Map.hall_size(block).y - 108)
			if level > 0:
				_check(world.change_floor(level), "Subir sólo un nivel desde la escalera")
			_check(world.floor_level == level, "Nivel efectivo")
			for item in Map.floor_rooms(block, level):
				_check(world.enter_room(block, item["id"]), "Entra en cada ambiente de la planta")
				_check(world._can_stand(world.player), "Aparición interior libre de obstáculos")
				var restored := World.new()
				restored.restore(JSON.parse_string(JSON.stringify(world.snapshot())))
				_check(restored.floor_level == level and restored.room_name == item["id"], "Recarga aula y nivel sin alterar visitas")
				restored.free()
				world.return_to_hall()
				_check(world.floor_level == level, "Salir del aula conserva planta")
			if block == "basicas":
				var bathrooms := 0
				for room in Map.floor_rooms(block, level):
					bathrooms += int(room["kind"] == "restroom")
				_check(bathrooms == (2 if level in [0, 2, 4] else 0), "Baños recreados sólo en PB, 2 y 4")
		world.player = Vector2(360, Map.hall_size(block).y - 108)
		_check(not world.change_floor(99), "Rechaza nivel inexistente")
		for level in range(Map.floor_count(block) - 2, -1, -1):
			_check(world.change_floor(level), "Baja por la escalera")
	world.free()
	var rng := RandomNumberGenerator.new()
	var rare_seed := -1
	for value in range(1000):
		rng.seed = value
		if rng.randi_range(1, 100) == 1:
			rare_seed = value
			break
	var life := Life.new()
	life.build(Collision.can_stand, {}, rare_seed)
	_check(life.rare and life.actors.size() > 40, "Encuentro 1/100 reproducible con semilla")
	var rare_actor := life.find_instance("ambient/piedritas_recuerdo")
	_check(not rare_actor.is_empty(), "Personaje raro se incorpora una sola vez")
	_check(not life.pet(rare_actor["instance_id"], Vector2.ZERO)["ok"], "No permite acariciar a distancia")
	_check(life.pet(rare_actor["instance_id"], rare_actor["point"])["ok"], "Caricia real por ID de instancia")
	_check(not life.pet(rare_actor["instance_id"], rare_actor["point"])["ok"] and life.petted.size() == 1, "No duplica caricia durante la reacción")
	var before := life.snapshot()
	var recovered := Life.new()
	recovered.build(Collision.can_stand, JSON.parse_string(JSON.stringify(before)), 999)
	_check(recovered.rare and recovered.petted.size() == 1 and recovered.actors.size() == life.actors.size(), "Recarga no vuelve a sortear ni duplica población")
	var damaged: Dictionary = before.duplicate(true)
	damaged["actors"][0]["cooldown"] = {"invalid": true}
	damaged["actors"][0]["class_count"] = INF
	damaged["elapsed"] = ["invalid"]
	var guarded := Life.new()
	guarded.build(Collision.can_stand, damaged)
	_check(guarded.elapsed == 0 and guarded.actors[0]["cooldown"] == 0 and guarded.actors[0]["class_count"] == 0, "Guardado malformado descarta tiempos y contadores inválidos")
	guarded.build(Collision.can_stand, {}, 42)
	_check(guarded.petted.is_empty() and guarded.monuments.is_empty(), "Reconstruir no arrastra interacciones de otra partida")
	for i in range(1200):
		life.advance(0.1, Map.SPAWN)
	var classes := 0
	for actor in life.actors:
		_check(Collision.can_stand(actor["point"], actor["radius"]), "NPC conserva posición válida")
		classes += int(actor["class_count"] > 0 or actor["state"] == "CLASS")
	_check(classes > 0 and life.routes.searches > 0, "NPC caminan y completan clases simuladas con A*")
	print("CAMPUS_ROUTINES: ", classes, " actors with simulated classes; ", life.routes.searches, " bounded route searches")
	var run := {"campus_exploration": {"life": recovered.snapshot()}}
	var profile := {}
	Achievements.evaluate(profile, run)
	_check(profile["achievement_ids"].has("campus_friend") and profile["achievement_ids"].has("secret_campus_friend"), "Logros derivan de interacción validada")
	Achievements.evaluate(profile, run)
	_check(profile["achievement_ids"].count("campus_friend") == 1, "Logro no se duplica al recargar")
	viewport = SubViewport.new()
	viewport.size = Vector2i(900, 640)
	root.add_child(viewport)
	game = TestGame.new()
	viewport.add_child(game)
	game.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	game.settings["low_performance"] = true
	game._apply_image_settings()
	_check(Engine.max_fps == 30, "Bajo consumo limita a 30 FPS")
	game._notification(Control.NOTIFICATION_APPLICATION_FOCUS_OUT)
	_check(Engine.max_fps == 10, "Ventana inactiva reduce el trabajo a 10 FPS")
	game.settings["low_performance"] = false
	game._notification(Control.NOTIFICATION_APPLICATION_FOCUS_IN)
	_check(Engine.max_fps == 60, "Recuperar foco restaura el límite normal")
	game.active_slot = 1
	game.draft_player_name = "Prueba compacta"
	game._create_solo_save("sistemas", "gestion_sistemas")
	var academic := JSON.stringify(game.simulation.snapshot())
	game._show_exploration()
	world = game.find_child("CampusWorld", true, false)
	world.enter_building("fis_mat")
	world.player = Vector2(360, Map.hall_size("fis_mat").y - 108)
	game.exploration_ui.show_floors("fis_mat")
	await _settle()
	var overlay = game.find_child("CampusInspection", true, false)
	_check(overlay != null, "Escalera muestra acciones reales")
	overlay._request_action({"type": "floor", "level": 1})
	await _settle()
	_check(world.floor_level == 1 and not world.paused, "Botón de escalera aplica planta y devuelve foco")
	game.exploration_ui.show_progress()
	game.exploration_ui.show_world()
	world = game.find_child("CampusWorld", true, false)
	_check(world.floor_level == 1, "Abrir progreso no pierde planta")
	_check(JSON.stringify(game.simulation.snapshot()) == academic, "Vida del campus no modifica notas ni trámites")
	game.queue_free()
	viewport.queue_free()
	await process_frame
	for failure in failures:
		push_error(failure)
	print("CAMPUS_LIFE: %d assertions, %d failures" % [assertions, failures.size()])
	quit(0 if failures.is_empty() else 1)
