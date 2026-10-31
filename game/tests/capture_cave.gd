extends "res://tests/capture_frontend.gd"

class RecentGame extends "res://tests/capture_frontend.gd".PreviewGame:
	func _recent_slot() -> int:
		return 1
	func _read_save(_slot: int, _mode: String) -> Dictionary:
		return {"player_name": "Alex"}


func _capture(name: String) -> void:
	# Freeze one valid mid-cycle frame after layout; all panels keep one clock.
	for frame in range(16):
		await process_frame
	var panel = game.find_child("MainMenuPanel", true, false)
	var dimensions: Vector2 = panel.size if panel != null else Vector2(minf(game._page_width, game.size.x - 64), game.size.y - 48)
	var seed := int(dimensions.x + dimensions.y) % 6
	game._effects.elapsed = fposmod(6.0 - seed * 1.7, 10)
	game._effects._process(0.2)
	game._effects.set_process(false)
	await super._capture(name)


func _run() -> void:
	target = "res://.test-artifacts/cave/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(target))
	root.mode = Window.MODE_WINDOWED
	root.size = Vector2i(1152, 720)
	root.content_scale_size = Vector2i(1152, 720)
	game = RecentGame.new()
	root.add_child(game)
	game.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	game.settings["animations"] = true
	game._show_main()
	await _capture("01-logo-y-caverna")
	root.size = Vector2i(900, 640)
	root.content_scale_size = Vector2i(900, 640)
	game.settings["font_scale"] = 1.2
	game._show_main()
	await _capture("02-menu-compacto-120")
	root.size = Vector2i(1152, 720)
	root.content_scale_size = Vector2i(1152, 720)
	game.settings["font_scale"] = 1.0
	game.active_slot = 1
	game.draft_player_name = "Alex"
	game._create_solo_save("sistemas", "gestion_informacion")
	await _capture("03-campus-sistemas")
	game._show_campus_section("materias")
	await _capture("04-materias")
	game._show_options()
	await _capture("05-opciones")
	game._create_solo_save("informatica", "telematica")
	await _capture("06-campus-informatica")
	game._show_campus_section("malla")
	await _capture("07-grafo")
	game._show_exploration()
	var world = game.find_child("CampusWorld", true, false)
	world.enter_room("sis_a", "LSIA-1")
	await _capture("08-exploracion")
	game.queue_free()
	await process_frame
	quit(0)
