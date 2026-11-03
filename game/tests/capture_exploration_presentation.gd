extends "res://tests/capture_frontend.gd"


func _run() -> void:
	target = "res://.test-artifacts/presentation/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(target))
	root.mode = Window.MODE_WINDOWED
	root.size = Vector2i(900, 640)
	root.content_scale_size = Vector2i(900, 640)
	game = PreviewGame.new()
	root.add_child(game)
	game.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	game.settings["font_scale"] = 1.2
	game._show_main()
	await _capture("01-menu")
	game._show_career_presentation()
	var view = game.find_child("CareerPresentation", true, false)
	view.model.paused = true
	view.model.index = 5
	view.model._select()
	view.model.elapsed = 100
	view._sync()
	await _capture("02-demo")
	game._show_exploration()
	game.exploration_ui.guest_name = "Alex"
	for direction in [Vector2.LEFT, Vector2.RIGHT]:
		game.exploration_ui.show_world()
		var world = game.find_child("CampusWorld", true, false)
		world.player = Vector2(1220, 1110)
		world.camera = world.player
		world.facing = direction
		world.set_process(false)
		world.queue_redraw()
		await _capture("03-izquierda" if direction.x < 0 else "04-derecha")
	for id in ["billar", "ping_pong", "ajedrez", "monopolio"]:
		game.exploration_ui.show_world()
		var world = game.find_child("CampusWorld", true, false)
		world.enter_building("sis_e")
		for station in world.Map.game_stations():
			if station["id"] == id:
				world.player = station["approach"]
		var key := InputEventKey.new()
		key.physical_keycode = KEY_E
		key.pressed = true
		root.push_input(key, true)
		key.pressed = false
		root.push_input(key, true)
		await _capture("05-entrada-" + id)
	game.queue_free()
	await process_frame
	quit(0)
