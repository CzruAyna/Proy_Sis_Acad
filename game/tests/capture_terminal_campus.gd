extends "res://tests/capture_frontend.gd"

class RecentGame extends "res://tests/capture_frontend.gd".PreviewGame:
	func _recent_slot() -> int:
		return 1
	func _read_save(_slot: int, _mode: String) -> Dictionary:
		return {"player_name": "Alex"}


func _capture(name: String) -> void:
	var world = game.find_child("CampusWorld", true, false)
	if world != null:
		world.queue_redraw() # Camera placements are direct fixture changes, not input.
	for frame in range(16):
		await process_frame
	game._effects.set_process(false)
	game._effects._process(0.2)
	await super._capture(name)


func _run() -> void:
	target = "res://.test-artifacts/terminal-campus/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(target))
	root.mode = Window.MODE_WINDOWED
	root.size = Vector2i(1152, 720)
	root.content_scale_size = Vector2i(1152, 720)
	game = RecentGame.new()
	root.add_child(game)
	game.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	game.settings["animations"] = true
	game._show_main()
	game._effects.elapsed = 7.0
	await _capture("01-tree-linux")
	game._effects.elapsed = 19.0
	await _capture("02-tree-windows")
	game.active_slot = 1
	game.draft_player_name = "Alex"
	game._create_solo_save("sistemas", "gestion_informacion")
	game._show_exploration()
	var world = game.find_child("CampusWorld", true, false)
	world.set_process(false)
	world.player = Vector2(1552, 702)
	world.camera = world.player
	await _capture("03-edificios-sistemas")
	world.player = Vector2(1240, 1040)
	world.camera = world.player
	await _capture("04-paseo-arbolado")
	world.player = Vector2(564, 840)
	world.camera = world.player
	await _capture("05-cancha-futbol")
	world.player = Vector2(756, 674)
	world.camera = world.player
	await _capture("06-cancha-cubierta")
	world.enter_building("sis_e")
	await _capture("07-sala-juegos")
	for id in ["billar", "ping_pong", "ajedrez", "monopolio"]:
		game.exploration_ui.show_minigame(id)
		await _capture("08-" + id)
	game.settings["font_scale"] = 1.2
	root.size = Vector2i(900, 640)
	root.content_scale_size = Vector2i(900, 640)
	game.exploration_ui.show_minigame("ajedrez")
	await _capture("09-ajedrez-120")
	game._show_options()
	await _capture("10-opciones-pixel")
	game.queue_free()
	await process_frame
	quit(0)
