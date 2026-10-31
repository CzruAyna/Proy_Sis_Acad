extends "res://tests/capture_frontend.gd"

const Map = preload("res://scripts/campus_map.gd")


func _run() -> void:
	target = "res://.test-artifacts/exploration/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(target))
	root.mode = Window.MODE_WINDOWED
	root.size = Vector2i(1152, 720)
	root.content_scale_size = Vector2i(1152, 720)
	game = PreviewGame.new()
	root.add_child(game)
	game.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	game._show_main()
	await _capture("01-sis-inf-inicio")
	game._show_exploration()
	var ui = game.exploration_ui
	ui.guest_name = "Alex"
	ui.show_welcome()
	await _capture("02-exploracion-bienvenida")
	ui.show_world()
	await _capture("03-ingreso-campus")
	var world = game.find_child("CampusWorld", true, false)
	world.player = Map.building("sis_c")["door"] + Vector2(50, 24)
	world.camera = world.player
	await _capture("04-bloques-sistemas")
	world.enter_room("sis_c", "CU-SIC4")
	await _capture("05-aula-interior")
	ui.show_room(Map.building("sis_c"), "CU-SIC4")
	await _capture("06-aula-actividades")
	ui.show_map()
	await _capture("07-mapa-campus")
	ui.show_progress()
	await _capture("08-progreso-visita")
	game.active_slot = 1
	game.draft_player_name = "Alex"
	game._create_solo_save("informatica", "telematica")
	game._show_exploration()
	world = game.find_child("CampusWorld", true, false)
	world.enter_room("sis_c", "CU-SIC1")
	ui.show_progress()
	await _capture("09-progreso-partida")
	root.size = Vector2i(900, 640)
	root.content_scale_size = Vector2i(900, 640)
	game.settings["font_scale"] = 1.2
	ui.show_world()
	await _capture("10-exploracion-compacta-120")
	game.queue_free()
	await process_frame
	quit(0)
