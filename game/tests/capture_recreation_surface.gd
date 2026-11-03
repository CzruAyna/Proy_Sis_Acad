extends "res://tests/capture_frontend.gd"


func _run() -> void:
	target = "res://.test-artifacts/recreation-v2/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(target))
	root.mode = Window.MODE_WINDOWED
	root.size = Vector2i(1152, 720)
	root.content_scale_size = Vector2i(1152, 720)
	game = PreviewGame.new()
	root.add_child(game)
	game.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	game._show_exploration()
	game.exploration_ui.guest_name = "Alex"
	for id in ["ajedrez", "billar", "ping_pong", "monopolio"]:
		game.exploration_ui.show_minigame(id)
		await _capture("01-" + id)
		var ui = game.exploration_ui.minigames
		if id == "billar":
			ui.action({"type": "aim", "angle": 0.02, "power": 95})
			ui.action({"type": "shoot"})
			await _capture("02-apertura")
		elif id == "ping_pong":
			ui._board.animations = true
			ui.action({"type": "serve"})
			ui.action({"type": "boost"})
			await _capture("03-ping-pong")
		elif id == "monopolio":
			ui._board.animations = true
			ui.action({"type": "roll"})
			await _capture("04-dados")
	root.size = Vector2i(900, 640)
	root.content_scale_size = Vector2i(900, 640)
	game.settings["font_scale"] = 1.2
	for id in ["ajedrez", "billar", "ping_pong", "monopolio"]:
		game.exploration_ui.show_minigame(id)
		await _capture("05-compacto-" + id)
	root.size = Vector2i(1600, 900)
	root.content_scale_size = Vector2i(1600, 900)
	game.settings["font_scale"] = 1.0
	game.exploration_ui.show_minigame("ajedrez")
	await _capture("06-ajedrez-grande")
	game.queue_free()
	await process_frame
	quit(0)
