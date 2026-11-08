extends "res://tests/test_compact_navigation.gd"

const Map = preload("res://scripts/campus_map.gd")
const Land = preload("res://scripts/campus_landscape.gd")
const Geo = preload("res://scripts/campus_cartography.gd")
const Scale = preload("res://scripts/campus_scale.gd")
const World = preload("res://scripts/campus_world.gd")
const Foliage = preload("res://scripts/campus_foliage.gd")
const Art = preload("res://scripts/campus_landmark_art.gd")
const Cast = preload("res://scripts/campus_cast.gd")
const Inspection = preload("res://scripts/campus_inspection_overlay.gd")


func _run() -> void:
	var started := Time.get_ticks_msec()
	var trees := Foliage.all()
	print("CAMPUS_FOLIAGE_INIT_MS: ", Time.get_ticks_msec() - started, " TREES: ", trees.size())
	_check(Map.SIZE / Scale.UNITS_PER_METRE == Vector2(880, 488), "El recorte cubre el sector FNI a escala exterior")
	_check(Land.routes().size() >= 10 and Geo.shapes("walkways").size() > 100 and Geo.shapes("parking").size() == 2, "Se distinguen vías, senderos y estacionamientos")
	_check(trees.size() > 200, "Bosque y jardines conservan arbolado")
	_check(Foliage.visible(Rect2(Land.destination("bosque")["point"], Vector2(200, 130))).size() < trees.size() / 4, "Consulta espacial acotada a árboles visibles")
	var probe := World.new()
	probe._life_saved = {"version": 1, "seed": "20261108", "rare": false}
	root.add_child(probe)
	probe.set_process(false)
	_check(probe._can_stand(Map.SPAWN), "Aparición segura en ingreso")
	_check(not probe._can_stand(Land.at(96, 82)), "La laguna bloquea caminar sobre el agua")
	for item in Land.landmarks():
		_check(probe._can_stand(item["approach"]), "Acceso transitable a " + item["id"])
		_check(not probe._can_stand(item["point"]), "La base del monumento bloquea el paso")
		_check(Art.texture(item["id"]).get_size() == Vector2(160, 192), "Retrato procedural detallado de " + item["id"])
		_check(Art.texture(item["id"]) == Art.texture(item["id"]), "Retrato reutilizado desde caché")
	_check(Art.texture("chivato").get_image().get_data() != Art.texture("piedritas").get_image().get_data(), "Monumentos con diseños diferentes")
	for row in Cast.PROFESSIONS:
		_check(Cast.texture(row[0]).get_size() == Vector2(24, 32), "Diseño profesional " + row[0])
		_check(Cast.texture(row[0], 0).get_image().get_data() != Cast.texture(row[0], 1).get_image().get_data(), "Fotogramas de paso diferentes")
	for actor in probe.cast_instances:
		_check(actor["id"] != "piedritas_recuerdo", "El encuentro raro no se convierte en aparición garantizada")
		_check(probe._can_stand_outside(actor["point"], actor["radius"]), "Muestra de personaje accesible: " + actor["id"])
	_check(Map.floor_count("fis_mat") == 2 and Map.floor_count("basicas") == 5, "Dos y cinco niveles diferenciados")
	_check(Map.floor_rooms("fis_mat", 0).size() == 4 and Map.floor_rooms("fis_mat", 1).size() == 3, "Bloque 100: tres aulas por piso y laboratorio virtual en PB")
	for level in range(5):
		var toilets := 0
		for room in Map.floor_rooms("basicas", level):
			if room.get("kind") == "restroom":
				toilets += 1
		_check(toilets == (2 if level % 2 == 0 else 0), "Baños separados cada dos niveles, esquema provisional")
	var old_point := Vector2(1200, 1500)
	probe.restore({"version": 1, "map_id": Map.LEGACY_ID, "position": [old_point.x, old_point.y], "visited": ["sis_c/CU-SIC1"]})
	var expected := Map.migrate_outside(old_point, Map.LEGACY_ID)
	_check(probe.player.distance_to(expected) <= 64 and probe._can_stand(probe.player) and probe.visited.has("sis_c/CU-SIC1"), "Migración proporcional del exterior y visitas")
	probe.restore({"version": 1, "map_id": Map.LEGACY_ID, "position": [100, 100], "room_id": "sis_c", "room_name": "CU-SIC4", "visited": ["sis_c/CU-SIC4"]})
	_check(probe.room_id == "sis_c" and probe.room_name == "CU-SIC4" and probe._can_stand(probe.player), "Migración conserva el aula y una posición interior segura")
	_check(probe.snapshot()["map_id"] == Map.ID, "El nuevo guardado identifica la versión ampliada")
	probe.queue_free()
	await process_frame
	viewport = SubViewport.new()
	root.add_child(viewport)
	game = TestGame.new()
	viewport.add_child(game)
	game.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	game._show_exploration()
	var ui = game.exploration_ui
	ui.guest_name = "Prueba campus ampliado"
	for dimensions in [Vector2i(900, 640), Vector2i(1152, 720)]:
		viewport.size = dimensions
		for scale in [1.0, 1.2]:
			game.settings["font_scale"] = scale
			ui.show_world()
			await _inspect("mundo-ampliado")
			var world = game.find_child("CampusWorld", true, false)
			var before: Dictionary = world.snapshot()
			var collections: Array = [Inspection.monument_pages("chivato"), Inspection.monument_pages("piedritas"), Inspection.floor_pages("fis_mat"), Inspection.floor_pages("basicas"), Inspection.catalog_pages()]
			for content in collections:
				ui._inspect(content)
				await _settle()
				var overlay = game.find_child("CampusInspection", true, false)
				_check(world.paused, "La inspección pausa el recorrido")
				for page in range(content.size()):
					overlay.page_index = page
					overlay._rebuild()
					await _settle()
					_check(Rect2(Vector2.ZERO, viewport.size).encloses(overlay.panel.get_global_rect()), "Ficha completa en %s texto %s: %s" % [dimensions, scale, content[page]["title"]])
					_check(overlay.is_ancestor_of(viewport.gui_get_focus_owner()), "El teclado permanece dentro de la ficha")
					for control in overlay.panel.find_children("*", "Control", true, false):
						if control is Button or control is Label:
							_check(overlay.panel.get_global_rect().encloses(control.get_global_rect()), "Texto y acción dentro de ficha: " + str(control.get("text")).left(50))
					for forbidden in ["Slider", "ScrollContainer", "ScrollBar"]:
						_check(overlay.find_children("*", forbidden, true, false).is_empty(), "Inspección sin desplazamiento ni deslizadores")
				overlay.close()
				await _settle()
				var after: Dictionary = world.snapshot()
				_check(not world.paused and before["position"] == after["position"] and before["room_name"] == after["room_name"] and before["visited"] == after["visited"], "Cerrar conserva posición, aula y visitas mientras las rutinas se reanudan")
			if not world.room_id.is_empty():
				world.leave_room()
			world.player = Land.landmarks()[0]["approach"]
			world.interact()
			await _settle()
			_check(game.find_child("CampusInspection", true, false) != null, "E abre la estatua por la señal conectada")
			game._active_back.call()
			await _settle()
			_check(not world.paused, "Volver restaura el control del personaje")
			world.enter_building("fis_mat")
			world.player = Vector2(360, Map.HALL_SIZE.y - 108)
			world.interact()
			await _settle()
			_check(game.find_child("CampusInspection", true, false) != null, "E abre los planos desde la escalera")
			game._active_back.call()
			await _settle()
			_check(world.room_id == "fis_mat" and world.room_name.is_empty(), "La vista de pisos no simula un cambio de nivel del motor")
			ui.show_map()
			await _inspect("mapa interactivo")
	game.queue_free()
	viewport.queue_free()
	await process_frame
	for failure in failures:
		push_error(failure)
	print("LARGE_CAMPUS_TESTS: %d assertions, %d failures" % [assertions, failures.size()])
	quit(0 if failures.is_empty() else 1)
