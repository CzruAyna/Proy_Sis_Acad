extends "res://tests/capture_frontend.gd"


func _run() -> void:
	target = "res://.test-artifacts/minigames/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(target))
	root.mode = Window.MODE_WINDOWED
	root.size = Vector2i(1152, 720)
	root.content_scale_size = Vector2i(1152, 720)
	game = PreviewGame.new()
	root.add_child(game)
	game.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	game._show_exploration()
	game.exploration_ui.guest_name = "Alex"
	game.exploration_ui.show_games()
	await _capture("01-catalogo")
	for id in ["billar", "ping_pong", "ajedrez", "monopolio"]:
		game.exploration_ui.show_minigame(id)
		await _capture("02-" + id)
		var ui = game.exploration_ui.minigames
		if id == "ping_pong":
			ui.action({"type": "serve"})
			await _capture("03-ping-pong-jugando")
		if id == "monopolio":
			ui.action({"type": "roll"})
			await _capture("04-dados")
	root.size = Vector2i(900, 640)
	root.content_scale_size = Vector2i(900, 640)
	game.settings["font_scale"] = 1.2
	for id in ["ajedrez", "billar", "ping_pong", "monopolio"]:
		game.exploration_ui.show_minigame(id)
		await _capture("05-compacto-" + id)
	game.queue_free()
	await process_frame
	quit(0)
