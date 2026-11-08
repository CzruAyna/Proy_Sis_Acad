extends "res://tests/capture_frontend.gd"

const Land = preload("res://scripts/campus_landscape.gd")


func _run() -> void:
	target = "res://.test-artifacts/large-campus/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(target))
	root.mode = Window.MODE_WINDOWED
	root.size = Vector2i(1152, 720)
	root.content_scale_size = root.size
	game = PreviewGame.new()
	root.add_child(game)
	game.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	game._show_exploration()
	var ui = game.exploration_ui
	ui.guest_name = "Visita FNI"
	ui.show_world()
	await _capture("01-ingreso")
	var world = game.find_child("CampusWorld", true, false)
	world.player = Land.landmarks()[0]["approach"]
	world.camera = world.player
	world.queue_redraw()
	await _capture("02-piedritas-campus")
	world.interact()
	await _capture("03-piedritas-homenaje")
	game._active_back.call()
	await process_frame
	world.player = Land.landmarks()[1]["approach"]
	world.camera = world.player + Vector2(0, -100)
	world.queue_redraw()
	await _capture("04-chivato-asientos-fni")
	world.interact()
	await _capture("05-chivato-homenaje")
	game._active_back.call()
	await process_frame
	for feature in [["06-bosque", 66, 82], ["07-laguna-civil", 90.7, 83], ["08-fuente", 53.1, 72.5]]:
		world.player = Land.at(feature[1], feature[2])
		world.camera = world.player
		world.queue_redraw()
		await _capture(feature[0])
	world.enter_building("fis_mat")
	world.queue_redraw()
	await _capture("09-bloque100-pasillo")
	ui.show_floors("fis_mat")
	await _capture("10-bloque100-plano")
	game._active_back.call()
	await process_frame
	ui.show_floors("basicas")
	await _capture("11-cruz-plano-pb")
	var overlay = game.find_child("CampusInspection", true, false)
	overlay._change(4)
	await _capture("12-cruz-plano-piso4")
	game._active_back.call()
	await process_frame
	ui.show_designs()
	await _capture("13-profesionales")
	overlay = game.find_child("CampusInspection", true, false)
	overlay._change(3)
	await _capture("14-estudiantes")
	overlay.page_index = overlay.pages.size() - 1
	overlay._rebuild()
	await _capture("15-perros")
	overlay.page_index = overlay.pages.size() - 3
	overlay._rebuild()
	await _capture("15b-personal")
	game._active_back.call()
	await process_frame
	for room in [["fisica", "CU-19", "16-lab-fisica"], ["quimica_lab", "CU-L-3", "17-lab-quimica"], ["fis_mat", "CU-106", "18-lab-virtual"]]:
		world.enter_room(room[0], room[1])
		world.queue_redraw()
		await _capture(room[2])
	ui.show_map()
	await _capture("19-mapa-campus")
	game.find_child("CampusZoomIn", true, false).pressed.emit()
	await _capture("20-mapa-ampliado")
	game.queue_free()
	await process_frame
	quit(0)
