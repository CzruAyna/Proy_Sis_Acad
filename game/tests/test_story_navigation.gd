extends "res://tests/test_compact_navigation.gd"

const Story = preload("res://scripts/career_story.gd")


func _run() -> void:
	viewport = SubViewport.new()
	root.add_child(viewport)
	game = TestGame.new()
	viewport.add_child(game)
	game.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	game._show_career_story()
	var ui = game.career_story_ui
	ui.player_name = "María de los Ángeles"
	ui.report = Story.new().generate(ui.player_name, "sistemas", "gestion_sistemas", "exploracion", 2)
	for dimensions in [Vector2i(900, 640), Vector2i(1152, 720)]:
		viewport.size = dimensions
		for scale in [1.0, 1.2]:
			game.settings["font_scale"] = scale
			ui.show_setup()
			await _inspect("historia-configuración")
			ui.show_chapter()
			await _inspect("historia-relato")
			ui.show_graph()
			await _inspect("historia-grafo")
			ui.show_learning()
			await _inspect("historia-temas")
			ui.show_subject(ui.report["chapters"][0]["results"][0])
			await _inspect("historia-modelo")
			ui.show_summary()
			await _inspect("historia-desenlace")
	game.queue_free()
	await process_frame
	viewport.queue_free()
	await process_frame
	for failure in failures:
		push_error(failure)
	print("STORY_NAVIGATION_TESTS: %d assertions, %d failures" % [assertions, failures.size()])
	quit(0 if failures.is_empty() else 1)
