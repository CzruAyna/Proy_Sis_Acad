extends "res://tests/capture_frontend.gd"
const Map = preload("res://scripts/campus_map.gd")


func _run() -> void:
	target = "res://.test-artifacts/campus-life/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(target))
	root.mode = Window.MODE_WINDOWED
	root.size = Vector2i(1152, 720)
	root.content_scale_size = Vector2i(1152, 720)
	game = PreviewGame.new()
	root.add_child(game)
	game.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	game.active_slot = 1
	game.draft_player_name = "Alex"
	game._create_solo_save("sistemas", "gestion_sistemas")
	game._show_exploration()
	var world = game.find_child("CampusWorld", true, false)
	world.enter_building("basicas")
	world.player = Vector2(360, Map.hall_size("basicas").y - 108)
	game.exploration_ui.show_floors("basicas")
	await _capture("01-escalera-funcional")
	var overlay = game.find_child("CampusInspection", true, false)
	overlay._request_action({"type": "floor", "level": 1})
	await _capture("02-primer-piso")
	world.leave_room()
	var dog: Dictionary = {}
	for actor in world.cast_instances:
		if world.ambient_cast.is_dog(actor):
			dog = actor
			break
	world.player = dog["point"] + Vector2(0, 34)
	world.camera = world.player
	game.exploration_ui.show_actor(dog["instance_id"])
	await _capture("03-acariciar")
	overlay = game.find_child("CampusInspection", true, false)
	overlay._request_action({"type": "pet", "instance_id": dog["instance_id"]})
	await _capture("04-reaccion")
	game.exploration_ui.capture()
	game.settings["low_performance"] = true
	game._show_options()
	await _capture("05-bajo-consumo")
	game.queue_free()
	await process_frame
	quit()
