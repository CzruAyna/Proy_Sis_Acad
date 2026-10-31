extends "res://tests/capture_terminal_campus.gd"


func _snap(name: String, phase: float) -> void:
	game._effects.set_process(false)
	game._effects.elapsed = phase
	game._effects._process(0.06)
	game.set_process(false)
	await super._capture(name)


func _run() -> void:
	target = "res://.test-artifacts/dynamic-menu/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(target))
	root.mode = Window.MODE_WINDOWED
	root.size = Vector2i(1152, 720)
	root.content_scale_size = Vector2i(1152, 720)
	game = RecentGame.new()
	root.add_child(game)
	game.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	game.settings["animations"] = true
	game._show_main()
	for index in range(16):
		await process_frame
	for item in [["01-orden", 0.4], ["02-salida-masiva", 4.0], ["03-windows", 27.0], ["04-primeras-grietas", 36.0], ["05-desintegracion", 60.0], ["06-destruido", 96.0]]:
		await _snap(item[0], item[1])
	root.size = Vector2i(900, 640)
	root.content_scale_size = Vector2i(900, 640)
	game.settings["font_scale"] = 1.2
	game._show_main()
	await _snap("07-menu-120", 5)
	game.settings["animations"] = false
	game._sync_ambient()
	await super._capture("08-movimiento-reducido")
	# A short render sequence also verifies actual writing and independent logos.
	root.size = Vector2i(1152, 720)
	root.content_scale_size = Vector2i(1152, 720)
	game.settings["font_scale"] = 1.0
	game.settings["animations"] = true
	game._show_main()
	for index in range(24):
		await _snap("anim-%02d" % index, index * 0.25)
	game.queue_free()
	await process_frame
	quit(0)
