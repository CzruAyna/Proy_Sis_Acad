extends "res://tests/capture_frontend.gd"

const Map = preload("res://scripts/campus_map.gd")
class RecentGame extends "res://tests/capture_frontend.gd".PreviewGame:
	func _recent_slot() -> int:
		return 1
	func _read_save(_slot: int, _mode: String) -> Dictionary:
		return {"player_name": "Alex · recorrido de Sistemas"}


func _capture(name: String) -> void:
	var world = game.find_child("CampusWorld", true, false)
	if world != null:
		world.context_changed.emit(world.interaction_text())
	await super._capture(name)


func _run() -> void:
	target = "res://.test-artifacts/building-details/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(target))
	root.mode = Window.MODE_WINDOWED
	root.size = Vector2i(1152, 720)
	root.content_scale_size = Vector2i(1152, 720)
	game = RecentGame.new()
	root.add_child(game)
	game.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	game._show_main()
	await _capture("01-menu-unico")
	root.size = Vector2i(900, 640)
	root.content_scale_size = Vector2i(900, 640)
	game.settings["font_scale"] = 1.2
	game._show_main()
	await _capture("02-menu-compacto-120")
	root.size = Vector2i(1152, 720)
	root.content_scale_size = Vector2i(1152, 720)
	game.settings["font_scale"] = 1.0
	game._show_exploration()
	var ui = game.exploration_ui
	ui.guest_name = "Alex"
	ui.show_world()
	var world = game.find_child("CampusWorld", true, false)
	world.set_process(false)
	world.player = Map.building("sis_a")["door"] + Vector2(16, 32)
	world.camera = world.player
	await _capture("03-edificios-sistemas")
	world.enter_building("sis_a")
	world.player = Map.hall_spawn("sis_a") - Vector2(0, 40)
	world.camera = Vector2(360, 120)
	await _capture("04-pasillo-sistemas-a")
	world.enter_room("sis_a", "LSIA-1")
	world.player = Vector2(240, 180)
	world.camera = Vector2(240, 160)
	await _capture("05-laboratorio-lsia1")
	world.enter_building("sis_b")
	world.player = Vector2(360, 180)
	world.camera = world.player
	await _capture("06-pasillo-sistemas-b")
	world.enter_building("basicas")
	world.player = Vector2(360, 240)
	world.camera = world.player
	await _capture("07-bloque-varias-aulas")
	root.size = Vector2i(900, 640)
	root.content_scale_size = Vector2i(900, 640)
	game.settings["font_scale"] = 1.2
	ui.show_world()
	world = game.find_child("CampusWorld", true, false)
	world.enter_building("sis_a")
	world.player = Vector2(360, 160)
	world.camera = world.player
	world.set_process(false)
	await _capture("08-pasillo-compacto-120")
	game.queue_free()
	await process_frame
	quit(0)
